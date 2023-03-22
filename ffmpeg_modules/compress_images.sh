#!/bin/bash

compress_images() {
    local feature_name feature_intro feature_note
    feature_name="压缩图片（原格式压缩或者转换为webp格式）"
    feature_intro="将所有png文件或者jpg文件或者jpeg文件或者gif文件，按原格式压缩或者转换成webp格式$(description_append_intro "是否转换成webp格式；是否删除源文件")"
    feature_note="$(description_append_note "option_true" "directory" "directory_delete_option" "image_compress_to_original_format" "image_compress_to_webp")"
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
    if [ "$png_count" -eq 0 ] && [ "$jpg_count" -eq 0 ] && [ "$jpeg_count" -eq 0 ] && [ "$gif_count" -eq 0 ]; then
        file_not_detected "png" "jpg" "jpeg" "gif"
        return 0
    fi

    local webp_flag
    webp_flag=$(input_bool "是否转换成webp格式" "默认否「即按原格式转换」" "false")
    local delete_source_files
    delete_source_files=$(input_bool "是否删除源文件" "默认是「即删除源文件」" "true")

    log_start
    local operation_count=0 delete_count=0
    shopt -s nullglob
    local output_path
    if [ "$webp_flag" = false ]; then
        output_path="image_compress_to_original_format"
        make_directory "$output_path"
        for file in *.jpg *.JPG; do
            draw_line_echo "~"
            ffmpeg_no_banner -i "$file" "$output_path/${file%.*}.jpg"
            ((operation_count++))
            echo
        done
        for file in *.jpeg *.JPEG; do
            draw_line_echo "~"
            ffmpeg_no_banner -i "$file" "$output_path/${file%.*}.jpeg"
            ((operation_count++))
            echo
        done
        for file in *.png *.PNG; do
            draw_line_echo "~"
            ffmpeg_no_banner -i "$file" -vf "$(filter_for_compress "png")" -pix_fmt pal8 "$output_path/${file%.*}.png"
            ((operation_count++))
            echo
        done
        for file in *.gif *.GIF; do
            draw_line_echo "~"
            ffmpeg_no_banner -i "$file" -vf "$(filter_for_compress "gif")" "$output_path/${file%.*}.webp"
            ((operation_count++))
            echo
        done
    else
        output_path="image_compress_to_webp"
        make_directory "$output_path"
        for file in *.png *.jpg *.jpeg *.gif *.PNG *.JPG *.JPEG *.GIF; do
            draw_line_echo "~"
            ffmpeg_no_banner -i "$file" "$output_path/${file%.*}.webp"
            ((operation_count++))
            echo
        done
    fi
    if [ "$delete_source_files" = true ]; then
        draw_line_echo "~"
        for file in *.png *.jpg *.jpeg *.gif *.PNG *.JPG *.JPEG *.GIF; do
            rm -rf "$file"
            ((delete_count++))
            text_echo "当前已删除「$file」"
        done
        mv "$output_path"/* ./
        rm -rf "$output_path"
        draw_line_echo "~"
        text_echo "已删除「$output_path」临时文件夹"
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
