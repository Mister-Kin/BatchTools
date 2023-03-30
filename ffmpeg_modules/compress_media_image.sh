#!/bin/bash

compress_media_image() {
    local feature_name feature_intro feature_note
    feature_name="压缩图片（原格式压缩或者转换为webp格式）"
    feature_intro="将路径下的png文件或者jpg文件或者jpeg文件或者gif文件，按原格式压缩或者转换成webp格式$(description_append_intro "是否转换成webp格式；是否删除源文件")"
    feature_note="$(description_append_note "option_true" "directory" "directory_delete_option" "compress_media_image_original" "compress_media_image_webp")"
    description "$feature_name" "$feature_intro" "$feature_note"
    change_directory
    if [ $? -eq 10 ]; then
        return 20
    fi

    local all_count png_count jpg_count jpeg_count gif_count
    png_count=$(file_count "png")
    jpg_count=$(file_count "jpg")
    jpeg_count=$(file_count "jpeg")
    gif_count=$(file_count "gif")
    all_count=$(("$png_count" + "$jpg_count" + "$jpeg_count" + "$gif_count"))
    if [ "$all_count" -eq 0 ]; then
        log_file_not_detected "png" "jpg" "jpeg" "gif"
        return 0
    fi

    local webp_flag
    webp_flag=$(input_bool "是否转换成webp格式" "默认否「即按原格式转换」" "false")
    if [ $? -eq 10 ]; then
        return 20
    fi
    local delete_source_files
    delete_source_files=$(input_bool "是否删除源文件" "默认是「即删除源文件」" "true")
    if [ $? -eq 10 ]; then
        return 20
    fi

    draw_line_echo "-"
    text_echo "当前已设置转换成webp格式为「$webp_flag」，设置删除源文件为「$delete_source_files」"

    log_start
    local operation_count=0 delete_count=0
    shopt -s nullglob
    local output_path
    if [ "$webp_flag" = false ]; then
        output_path="compress_media_image_original"
        make_directory "$output_path"
        draw_line_echo "~"
        show_progress_bar "$all_count" "$operation_count"
        for file in $(file_extension_for_loop "jpg" "jpeg"); do
            ffmpeg_no_banner -i "$file" "$output_path/$(lowercase_file_name_extension "$file")"
            ((operation_count++))
            show_progress_bar "$all_count" "$operation_count"
        done
        for file in $(file_extension_for_loop "png"); do
            ffmpeg_no_banner -i "$file" -vf "$(filter_for_compress "png")" -pix_fmt pal8 "$output_path/$(lowercase_file_name_extension "$file")"
            ((operation_count++))
            show_progress_bar "$all_count" "$operation_count"
        done
        for file in $(file_extension_for_loop "gif"); do
            ffmpeg_no_banner -i "$file" -vf "$(filter_for_compress "gif")" "$output_path/$(lowercase_file_name_extension "$file")"
            ((operation_count++))
            show_progress_bar "$all_count" "$operation_count"
        done
    else
        output_path="compress_media_image_webp"
        make_directory "$output_path"
        draw_line_echo "~"
        for file in $(file_extension_for_loop "png" "jpg" "jpeg" "gif"); do
            ffmpeg_no_banner -i "$file" "$output_path/$(get_file_name "$file").webp"
            ((operation_count++))
            show_progress_bar "$all_count" "$operation_count"
        done
    fi
    if [ "$delete_source_files" = true ]; then
        for file in $(file_extension_for_loop "png" "jpg" "jpeg" "gif"); do
            rm -rf "$file"
            ((delete_count++))
        done
        mv "$output_path"/* ./
        rm -rf "$output_path"
        log_end "$operation_count" "$all_count" "$delete_count"
        if [ "$webp_flag" = false ]; then
            log_result "option_true" "file" "png" "jpg" "jpeg" "gif"
        else
            log_result "option_false" "file" "webp"
        fi
    else
        log_end "$operation_count" "$all_count"
        log_result "option_false" "directory" "directory_delete_option" "$output_path"
    fi
    shopt -u nullglob
}
