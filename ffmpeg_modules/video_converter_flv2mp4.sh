#!/bin/bash

flv_to_mp4() {
    local feature_name feature_intro feature_note
    feature_name="flv格式转mp4格式"
    feature_intro="将所有flv文件转换为mp4文件，仅仅是转换封装格式，不涉及重新编码音视频"
    feature_note="$(description_append_note "option_false" "file" "mp4")"
    description "$feature_name" "$feature_intro" "$feature_note"
    change_directory
    if [ $? -eq 10 ]; then
        return 20
    fi

    local all_count
    all_count=$(file_count "flv")
    if [ "$all_count" -eq 0 ]; then
        file_not_detected "flv"
        return 0
    fi

    log_start
    local operation_count=0
    shopt -s nullglob
    for file in *.flv *.FLV; do
        detect_and_remove "file" "${file%.*}.mp4"
        draw_line_echo "~"
        ffmpeg_no_banner -i "$file" -c copy "${file%.*}.mp4"
        ((operation_count++))
        echo
    done
    shopt -u nullglob
    log_end "$operation_count" "$all_count"
    log_result "$feature_note"
}
