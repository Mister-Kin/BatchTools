#!/bin/bash

tga_to_png() {
    description "tga格式转png格式" "将所有tga文件转换成png格式；生成的文件输出在「tga_to_png_output」文件夹" "确保路径下没有名为「tga_to_png_output」文件夹，否则本功能操作将生成同名文件夹强制覆盖；如果路径下已有该文件夹，请先自行处理好文件再执行该功能"
    change_directory
    if [ $? -eq 10 ]; then
        return 20
    fi

    local tga_count TGA_count all_count
    tga_count=$(file_count "tga")
    TGA_count=$(file_count "TGA")
    all_count=$(("$tga_count" + "$TGA_count"))
    if [ "$tga_count" -eq 0 ] && [ "$TGA_count" -eq 0 ]; then
        echo "当前并未检测到tga文件和TGA文件，已退出本次的功能操作"
        return 0
    fi
    if [ "$tga_count" -gt 0 ] || [ "$TGA_count" -gt 0 ]; then
        echo "当前检测到$tga_count个tga文件和$TGA_count个TGA文件"
    fi

    local output_path="tga_to_png_output"
    make_directory "$output_path"

    draw_line "-"
    echo "已开始本次的功能操作"
    draw_line "~"
    local operation_count=0
    shopt -s nullglob
    for file in *.tga *.TGA; do
        ffmpeg_no_banner -i "$file" "$output_path/${file%.*}.png"
        draw_line "~"
        ((operation_count++))
    done
    shopt -u nullglob
    echo "已结束本次的功能操作，总共执行了$operation_count次转换操作（当前路径检测到$all_count个可操作文件，其中$tga_count个tga文件和$TGA_count个TGA文件）"

    finished_word "directory" "$output_path"
}
