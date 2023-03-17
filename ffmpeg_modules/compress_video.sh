#!/bin/bash

compress_video() {
    description "压缩视频，转换为hevc编码的mp4格式（libx265）" "使用libx265，将所有mp4文件或者flv文件或者mov文件转换hevc编码的mp4格式视频；生成的文件输出在「video_compress_to_hevc」文件夹" "确保路径下没有名为「video_compress_to_hevc」文件夹，否则本功能操作将生成同名文件夹强制覆盖；如果路径下已有该文件夹，请先自行处理好文件再执行该功能"
    change_directory
    if [ $? -eq 10 ]; then
        return 20
    fi

    local mp4_count flv_count mov_count MP4_count FLV_count MOV_count all_count
    mp4_count=$(file_count "mp4")
    flv_count=$(file_count "flv")
    mov_count=$(file_count "mov")
    MP4_count=$(file_count "MP4")
    FLV_count=$(file_count "FLV")
    MOV_count=$(file_count "MOV")
    all_count=$(("$mp4_count" + "$flv_count" + "$mov_count" + "$MP4_count" + "$FLV_count" + "$MOV_count"))

    if [ "$mp4_count" -eq 0 ] && [ "$flv_count" -eq 0 ] && [ "$mov_count" -eq 0 ] && [ "$MP4_count" -eq 0 ] && [ "$FLV_count" -eq 0 ] && [ "$MOV_count" -eq 0 ]; then
        echo "当前并未检测到任何mp4文件或者flv文件或者mov文件或者MP4文件或者FLV文件或者MOV文件，已退出本次的功能操作"
        return 0
    fi
    if [ "$mp4_count" -gt 0 ] || [ "$MP4_count" -gt 0 ]; then
        echo "当前检测到$mp4_count个mp4文件，$MP4_count个MP4文件"
    fi
    if [ "$flv_count" -gt 0 ] || [ "$FLV_count" -gt 0 ]; then
        echo "当前检测到$flv_count个flv文件，$FLV_count个FLV文件"
    fi
    if [ "$mov_count" -gt 0 ] || [ "$MOV_count" -gt 0 ]; then
        echo "当前检测到$mov_count个mov文件，$MOV_count个MOV文件"
    fi

    local output_path="video_compress_to_hevc"
    make_directory "$output_path"

    draw_line "-"
    echo "已开始本次的功能操作"
    draw_line "~"
    local operation_count=0
    shopt -s nullglob
    for file in *.mp4 *.flv *.mov *.MP4 *.FLV *.MOV; do
        ffmpeg_no_banner -i "$file" -c:v libx265 -crf:v 28 -preset:v medium -c:a copy "$output_path/${file%.*}.mp4"
        draw_line "~"
        ((operation_count++))
    done
    shopt -u nullglob
    echo "已结束本次的功能操作，总共执行了$operation_count次转换操作（当前路径检测到$all_count个可操作文件）"

    finished_word "directory" "$output_path"
}
