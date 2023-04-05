#!/bin/bash

video_converter_flv2mp4() {
    local feature_name feature_intro feature_note
    feature_name="flv格式转mp4格式"
    feature_intro="将路径下的flv文件转换为mp4文件，仅仅是转换封装格式，不涉及重编码"
    feature_note="$(description_append_note "option_false" "file" "mp4")"
    description "$feature_name" "$feature_intro" "$feature_note"
    change_directory
    if [ $? -eq 10 ]; then
        return 20
    fi

    local all_count
    all_count=$(file_count "flv")
    if [ "$all_count" -eq 0 ]; then
        log_file_not_detected "flv"
        return 0
    fi

    log_start
    local operation_count=0
    shopt -s nullglob
    draw_line_blank "~"
    show_progress_bar "$all_count" "$operation_count"
    for file in $(file_extension_for_loop "flv"); do
        detect_and_remove "file" "${file%.*}.mp4"
        ffmpeg_no_banner -i "$file" -c copy "$(get_file_name "$file").mp4"
        ((operation_count++))
        show_progress_bar "$all_count" "$operation_count"
    done
    log_end "$operation_count" "$all_count"
    log_result "$feature_note"
    shopt -u nullglob
}
