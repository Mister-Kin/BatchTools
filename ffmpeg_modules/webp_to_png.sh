#!/bin/bash

webp_to_png() {
    description "webp格式转png格式（删除源文件）" "将webp文件转换为png文件，并删除webp源文件"
    change_directory
    if [ $? -eq 10 ]; then
        return 20
    fi

    local webp_count all_count
    webp_count=$(file_count "webp")
    all_count=$webp_count
    if [ "$webp_count" -eq 0 ]; then
        echo "当前并未检测到webp文件，已退出本次的功能操作"
        return 0
    fi
    if [ "$webp_count" -gt 0 ]; then
        echo "当前检测到$webp_count个webp文件"
    fi

    draw_line "-"
    echo "已开始本次的功能操作"
    draw_line "~"
    local operation_count=0
    for file in *.webp; do
        ffmpeg_no_banner -i "$file" "${file%.*}.png"
        draw_line "~"
        rm "$file"
        echo "已删除 $file"
        draw_line "~"
        ((operation_count++))
    done
    echo "已结束本次的功能操作，总共执行了$operation_count次转换操作（当前路径检测到$all_count个可操作文件）"

    finished_word
}
