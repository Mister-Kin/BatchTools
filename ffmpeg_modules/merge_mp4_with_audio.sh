#!/bin/bash

merge_mp4_with_audio() {
    description "合并视频和音频：mp4+m4a/mp3" "将不含音频流的mp4文件和m4a文件或者mp3文件合并输出为mp4格式的视频，不涉及重新编码；生成的文件输出在「video_with_audio」文件夹" "确保路径下没有名为「video_with_audio」文件夹，否则本功能操作将生成同名文件夹强制覆盖；如果路径下已有该文件夹，请先自行处理好文件再执行该功能"
    change_directory
    if [ $? -eq 10 ]; then
        return 20
    fi

    local mp4_count m4a_count mp3_count all_count
    mp4_count=$(file_count "mp4")
    m4a_count=$(file_count "m4a")
    mp3_count=$(file_count "mp3")
    all_count=$mp4_count

    if [ "$m4a_count" -eq 0 ] && [ "$mp3_count" -eq 0 ] || [ "$mp4_count" -eq 0 ]; then
        echo "当前并未同时检测到mp4文件和m4a/mp3文件，已退出本次的功能操作"
        return 0
    fi
    if [ "$mp4_count" -ge 1 ]; then
        echo "当前检测到$mp4_count个mp4文件"
        if [ "$mp4_count" -gt 1 ]; then
            echo "mp4文件的数量已超过1个，本功能操作只能选择最前一个mp4文件作为视频流；请确保自己所需操作的文件在第一个，或者路径中只有一个mp4文件"
        fi
    fi
    if [ "$m4a_count" -eq 1 ] && [ "$mp3_count" -eq 1 ]; then
        echo "当前检测到1个m4a文件和1个mp3文件，本程序将选用m4a文件作为封面图"
    fi
    if [ "$m4a_count" -ge 1 ]; then
        echo "当前检测到$m4a_count个m4a文件"
        if [ "$m4a_count" -gt 1 ]; then
            echo "m4a文件的数量已超过1个，本功能操作只能选择最前一个m4a文件作为音频流；请确保自己所需操作的文件在第一个，或者路径中只有一个m4a文件"
        fi
    fi
    if [ "$mp3_count" -ge 1 ]; then
        echo "当前检测到$mp3_count个mp3文件"
        if [ "$mp3_count" -gt 1 ]; then
            echo "mp3文件的数量已超过1个，本功能操作只能选择最前一个mp3文件作为音频流；请确保自己所需操作的文件在第一个，或者路径中只有一个mp3文件"
        fi
    fi

    local output_path="video_with_audio"
    make_directory "$output_path"

    draw_line "-"
    echo "已开始本次的功能操作"
    draw_line "~"
    local audio_file mp4_file
    local operation_count=0
    shopt -s nullglob
    mp4_file=(*.mp4)
    if [ "$m4a_count" -gt 0 ]; then
        audio_file=(*.m4a)
    else
        audio_file=(*.mp3)
    fi
    shopt -u nullglob

    ffmpeg_no_banner -i "${mp4_file[0]}" -i "${audio_file[0]}" -c copy "$output_path/${mp4_file[0]}"
    draw_line "~"
    ((operation_count++))
    echo "已结束本次的功能操作，总共执行了$operation_count次转换操作（当前路径检测到$all_count个可操作文件）"

    finished_word "directory" "$output_path"
}
