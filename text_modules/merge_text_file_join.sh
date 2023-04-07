#!/bin/bash

merge_text_file_join() {
    local feature_name feature_intro feature_note
    feature_name="合并文本文件（文件首尾拼接）"
    feature_intro="将路径下的txt文件或者srt文件合并为一个文件，程序会自动将同类型文件按扫描到的顺序进行首尾拼接"
    feature_note="$(description_append_note "option_true" "file" "merged.srt" "merged.txt")"
    description "$feature_name" "$feature_intro" "$feature_note"
    change_directory
    if [ $? -eq 10 ]; then
        return 20
    fi

    detect_and_remove "file" "merged.txt"
    detect_and_remove "file" "merged.srt"
    local txt_count srt_count all_count
    txt_count=$(file_count "txt")
    srt_count=$(file_count "srt")
    all_count=$((srt_count + txt_count))

    if [ "$all_count" -eq 0 ]; then
        log_file_not_detected "srt" "txt"
        return 0
    fi

    local txt_flag srt_flag
    if [ "$txt_count" -lt 2 ]; then
        draw_line_blank "~"
        text_blank "当前检测到txt文件数量不足两个，无需进行合并txt文件操作"
        txt_flag=false
    else
        txt_flag=true
    fi
    if [ "$srt_count" -lt 2 ]; then
        draw_line_blank "~"
        text_blank "当前检测到srt文件数量不足两个，无需进行合并srt文件操作"
        srt_flag=false
    else
        srt_flag=true
    fi

    if [ "$txt_flag" = false ] && [ "$srt_flag" = false ]; then
        draw_line_blank "~"
        text_blank "当前检测到的txt文件和srt文件的数量均不足两个，无需进行合并操作，已退出本次的功能操作"
        return 0
    fi

    log_start
    local operation_count1=0
    local operation_count2=0
    shopt -s nullglob
    if [ "$txt_flag" = true ]; then
        draw_line_blank "~"
        for file in $(file_extension_for_loop "txt"); do
            cat "$file" >>"merged.txt"
            ((operation_count1++))
            show_progress_bar "$txt_count" "$operation_count1"
        done
    fi
    if [ "$srt_flag" = true ]; then
        draw_line_blank "~"
        for file in $(file_extension_for_loop "srt"); do
            cat "$file" >>"merged.srt"
            ((operation_count2++))
            show_progress_bar "$srt_count" "$operation_count2"
        done
    fi

    log_end "$(("$operation_count1" + "$operation_count2"))" "$all_count"
    log_result "$feature_note"
    shopt -u nullglob
}
