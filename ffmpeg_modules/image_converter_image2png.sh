#!/bin/bash

image_converter_image2png() {
    local output_path="image_converter_image2png"
    local feature_name feature_intro feature_note
    feature_name="图片转png格式"
    feature_intro="将路径下的webp文件或者jpg文件或者jpeg文件或者gif文件或者tga文件转换成png格式$(description_append_intro "是否删除源文件")"
    feature_note="$(description_append_note "option_false" "directory" "directory_delete_option" "image2png")"
    description "$feature_name" "$feature_intro" "$feature_note"
    change_directory
    if [ $? -eq 10 ]; then
        return 20
    fi

    local all_count tga jpg_count jpeg_count gif_count webp_count
    tga=$(file_count "tga")
    jpg_count=$(file_count "jpg")
    jpeg_count=$(file_count "jpeg")
    gif_count=$(file_count "gif")
    webp_count=$(file_count "webp")
    all_count=$(("$tga" + "$jpg_count" + "$jpeg_count" + "$gif_count" + "$webp_count"))
    if [ "$all_count" -eq 0 ]; then
        log_file_not_detected "tga" "jpg" "jpeg" "gif" "webp"
        return 0
    fi

    local delete_source_files
    delete_source_files=$(input_bool "是否删除源文件" "默认是「即删除源文件」" "true")
    if [ $? -eq 10 ]; then
        return 20
    fi

    log_start
    make_directory "$output_path"
    local operation_count=0
    shopt -s nullglob
    draw_line_echo "~"
    for file in $(file_extension_for_loop "tga" "jpg" "jpeg" "gif" "webp"); do
        ffmpeg_no_banner -i "$file" "$output_path/$(get_file_name "$file").png"
        ((operation_count++))
        show_progress_bar "$all_count" "$operation_count"
    done
    if [ "$delete_source_files" = true ]; then
        for file in $(file_extension_for_loop "tga" "jpg" "jpeg" "gif" "webp"); do
            rm -rf "$file"
            ((delete_count++))
        done
        mv "$output_path"/* ./
        rm -rf "$output_path"
        log_end "$operation_count" "$all_count" "$delete_count"
        log_result "option_false" "file" "png"
    else
        log_end "$operation_count" "$all_count"
        log_result "$feature_note"
    fi
    shopt -u nullglob
}
