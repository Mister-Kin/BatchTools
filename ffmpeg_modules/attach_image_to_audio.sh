#!/bin/bash

attach_image_to_audio() {
    description "为音频添加封面图" "为mp3文件或者m4a文件或者flac文件添加封面图；生成的文件输出在「audio_attach_image」文件夹" "封面图只能为png格式或者jpg格式；确保路径下没有名为「audio_attach_image」文件夹，否则本功能操作将生成同名文件夹强制覆盖；如果路径下已有该文件夹，请先自行处理好文件再执行该功能"
    change_directory
    if [ $? -eq 10 ]; then
        return 20
    fi

    local png_count jpg_count mp3_count m4a_count flac_count all_count
    png_count=$(file_count "png")
    jpg_count=$(file_count "jpg")
    m4a_count=$(file_count "m4a")
    mp3_count=$(file_count "mp3")
    flac_count=$(file_count "flac")
    all_count=$(("$m4a_count" + "$mp3_count" + "$flac_count"))
    if [ "$png_count" -eq 0 ] && [ "$jpg_count" -eq 0 ]; then
        echo "当前并未检测到任何png文件或者jpg文件，已退出本次的功能操作"
        return 0
    fi
    if [ "$png_count" -eq 1 ] && [ "$jpg_count" -eq 1 ]; then
        echo "当前检测到1个png文件和1个jpg文件，本程序将选用png文件作为封面图"
    fi
    if [ "$png_count" -ge 1 ]; then
        echo "当前检测到$png_count个png文件"
        if [ "$png_count" -gt 1 ]; then
            echo "png文件的数量已超过1个，本程序将选用第一个文件作为封面图"
        fi
    fi
    if [ "$jpg_count" -ge 1 ]; then
        echo "当前检测到$jpg_count个jpg文件"
        if [ "$jpg_count" -gt 1 ]; then
            echo "jpg文件的数量已超过1个，本程序将选用第一个文件作为封面图"
        fi
    fi
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

    local output_path="audio_attach_image"
    make_directory "$output_path"

    draw_line "-"
    echo "已开始本次的功能操作"
    draw_line "~"
    local operation_count=0
    shopt -s nullglob
    local image_file
    if [ "$png_count" -gt 0 ]; then
        image_file=(*.png)
    else
        image_file=(*.jpg)
    fi
    for file in *.mp3 *.m4a *.flac; do
        ffmpeg_no_banner -i "$file" -i "${image_file[0]}" -map 0 -map 1 -c copy -map_chapters -1 -disposition:v:0 attached_pic "$output_path/$file"
        draw_line "~"
        ((operation_count++))
    done
    shopt -u nullglob
    echo "已结束本次的功能操作，总共执行了$operation_count次转换操作（当前路径检测到$all_count个可操作文件）"

    finished_word "directory" "$output_path"
}
