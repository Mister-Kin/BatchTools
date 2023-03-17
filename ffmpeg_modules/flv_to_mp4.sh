#!/bin/bash

flv_to_mp4() {
    description "flv格式转mp4格式" "将所有flv文件转换为mp4文件，仅仅是转换封装格式，不涉及重新编码"
    change_directory
    if [ $? -eq 10 ]; then
        return 20
    fi

    local flv_count all_count
    flv_count=$(file_count "flv")
    all_count=$flv_count

    if [ "$flv_count" -eq 0 ]; then
        echo "当前并未检测到任何flv文件，已退出本次的功能操作"
        return 0
    fi
    if [ "$flv_count" -gt 0 ]; then
        echo "当前检测到$flv_count个flv文件"
    fi

    draw_line "-"
    echo "已开始本次的功能操作"
    draw_line "~"
    local operation_count=0
    for file in *.flv; do
        ffmpeg_no_banner -i "$file" -c copy "${file%.*}.mp4"
        draw_line "~"
        ((operation_count++))
    done
    echo "已结束本次的功能操作，总共执行了$operation_count次转换操作（当前路径检测到$all_count个可操作文件）"

    finished_word "file" "xxx.mp4"
}
