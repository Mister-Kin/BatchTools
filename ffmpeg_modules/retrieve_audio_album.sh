#!/bin/bash

retrieve_audio_album() {
    description "获取音频封面图" "获取所有mp3文件或者m4a文件或者flac文件的音频封面图，生成png文件输出在「audio_album」文件夹" "确保路径下没有名为「audio_album」文件夹，否则本功能操作将生成同名文件夹强制覆盖；如果路径下已有该文件夹，请先自行处理好文件再执行该功能"
    change_directory
    if [ $? -eq 10 ]; then
        return 20
    fi

    local m4a_count mp3_count flac_count all_count
    m4a_count=$(file_count "m4a")
    mp3_count=$(file_count "mp3")
    flac_count=$(file_count "flac")
    all_count=$(("$m4a_count" + "$mp3_count" + "$flac_count"))
    if [ "$m4a_count" -eq 0 ] && [ "$mp3_count" -eq 0 ] && [ "$flac_count" -eq 0 ]; then
        echo "当前并未检测到任何m4a文件或者mp3文件或者flac文件，已退出本次的功能的操作"
        return 0
    fi
    if [ "$m4a_count" -gt 0 ]; then
        echo "当前检测到$m4a_count个m4a文件"
    fi
    if [ "$mp3_count" -gt 0 ]; then
        echo "当前检测到$mp3_count个mp3文件"
    fi
    if [ "$flac_count" -gt 0 ]; then
        echo "当前检测到$flac_count个flac文件"
    fi

    local output_path="audio_album"
    make_directory "$output_path"

    draw_line "-"
    echo "已开始本次的功能操作"
    draw_line "~"
    local operation_count=0
    shopt -s nullglob
    for file in *.mp3 *.m4a *.flac; do
        ffmpeg_no_banner -i "$file" -an -c:v copy "$output_path/${file%.*}.png"
        draw_line "~"
        ((operation_count++))
    done
    shopt -u nullglob
    echo "已结束本次的功能操作，总共执行了$operation_count次转换操作（当前路径检测到$all_count个可操作文件）"

    finished_word "directory" "$output_path"
}
