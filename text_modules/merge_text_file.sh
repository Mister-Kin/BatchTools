#!/bin/bash

merge_text_file() {
    description "合并文本文件" "将所有txt文件或者srt文件合并为一个名为「merged.xxx」文件" "确保路径下没有名为「merged.xxx」文件，否则本功能操作将生成同名文件强制覆盖；如果路径下已有该文件，请先自行处理好文件再执行该功能"
    change_directory
    if [ $? -eq 10 ]; then
        return 20
    fi

    local txt_count srt_count all_count
    detect_and_remove "file" "merged.txt"
    detect_and_remove "file" "merged.srt"
    txt_count=$(file_count "txt")
    srt_count=$(file_count "srt")
    all_count=$(("$srt_count" + "$txt_count"))

    if [ "$txt_count" -eq 0 ] && [ "$srt_count" -eq 0 ]; then
        echo "当前并未检测到txt文件或者srt文件，已退出本次的功能操作"
        return 0
    fi
    if [ "$txt_count" -eq 1 ] && [ "$srt_count" -eq 0 ]; then
        echo "当前只检测到1个txt文件，无需进行合并操作，已退出本次的功能操作"
        return 0
    fi
    if [ "$txt_count" -eq 0 ] && [ "$srt_count" -eq 1 ]; then
        echo "当前只检测到1个srt文件，无需进行合并操作，已退出本次的功能操作"
        return 0
    fi
    if [ "$txt_count" -eq 1 ] && [ "$srt_count" -eq 1 ]; then
        echo "当前只检测到1个txt文件和1个srt文件，无需进行合并操作，已退出本次的功能操作"
        return 0
    fi

    local file_type output_file
    if [ "$txt_count" -ge 2 ] && [ "$srt_count" -lt 2 ]; then
        echo "当前检测到$txt_count个txt文件"
        file_type="*.txt"
        output_file="merged.txt"
    fi
    if [ "$txt_count" -lt 2 ] && [ "$srt_count" -ge 2 ]; then
        echo "当前检测到$srt_count个srt文件"
        file_type="*.srt"
        output_file="merged.srt"
    fi
    if [ "$txt_count" -ge 2 ] && [ "$srt_count" -ge 2 ]; then
        echo "当前检测到$txt_count个txt文件和$srt_count个srt文件"
        file_type="*.txt *.srt"
        output_file="merged.txt和merged.srt"
    fi

    draw_line "-"
    echo "已开始本次的功能操作"
    draw_line "~"
    local operation_count=0
    for file in $file_type; do
        cat "$file" >>"merged.${file##*.}"
        echo "已将$file合并进merged.${file##*.}"
        draw_line "~"
        ((operation_count++))
    done
    echo "已结束本次的功能操作，总共执行了$operation_count次合并操作（当前路径检测到$all_count个可操作文件）"

    finished_word "file" "$output_file"
}
