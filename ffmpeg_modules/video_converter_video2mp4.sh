#!/bin/bash

video_converter_video2mp4() {
    local output_path="video_converter_video2mp4"
    local feature_name feature_intro feature_note
    feature_name="视频转mp4格式"
    feature_intro="将路径下的mov或者flv文件转换为mp4文件，仅仅是转换封装格式，不涉及重编码$(description_append_intro "是否删除源文件")"
    feature_note="$(description_append_note "option_false" "directory" "directory_delete_option" "$output_path")"
    description "$feature_name" "$feature_intro" "$feature_note"
    change_directory
    if [ $? -eq 10 ]; then
        return 20
    fi

    local all_count flv_count mov_count
    flv_count=$(file_count "flv")
    mov_count=$(file_count "mov")
    all_count=$((flv_count + mov_count))
    if [ "$all_count" -eq 0 ]; then
        log_file_not_detected "flv" "mov"
        return 0
    fi

    local delete_source_files
    delete_source_files=$(input_bool "是否删除源文件" "默认否「即保留源文件」" "false")
    if [ $? -eq 10 ]; then
        return 20
    fi

    draw_line_blank "-"
    text_blank "当前已设置删除源文件为「${delete_source_files}」"

    log_start
    make_directory "$output_path"
    local operation_count=0
    shopt -s nullglob
    draw_line_blank "~"
    show_progress_bar "$all_count" "$operation_count"
    for file in $(file_extension_for_loop "flv" "mov"); do
        ffmpeg_no_banner -i "$file" -c copy "${output_path}/$(get_file_name "$file").mp4"
        ((operation_count++))
        show_progress_bar "$all_count" "$operation_count"
    done
    if [ "$delete_source_files" = true ]; then
        for file in $(file_extension_for_loop "flv" "mov"); do
            rm -rf "$file"
            ((delete_count++))
        done
        mv "$output_path"/* ./
        rm -rf "$output_path"
        log_end "$operation_count" "$all_count" "$delete_count"
        log_result "option_false" "file" "mp4"
    else
        log_end "$operation_count" "$all_count"
        log_result "$feature_note"
    fi
    shopt -u nullglob
}
