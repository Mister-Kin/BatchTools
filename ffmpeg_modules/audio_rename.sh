#!/bin/bash

rename_audio() {
    description "重命名音频" "使用音频文件的元数据（metadata），重命名mp3文件或者m4a文件或者flac文件；生成的文件输出在「audio_rename」文件夹" "确保路径下没有名为「audio_rename」文件夹，否则本功能操作将生成同名文件夹强制覆盖；如果路径下已有该文件夹，请先自行处理好文件再执行该功能"
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

    local output_path="audio_rename"
    make_directory "$output_path"

    draw_line "-"
    local user_input
    local drop_chapter_flag
    echo "提示：不输入（等待15s）或直接回车，则默认保留章节标记（默认否，允许输入「是/否/yes/no/y/n」，不区分大小写）"
    if read -t 15 -r -p "是否删除章节标记（默认否）：" user_input; then
        while ! [[ "$user_input" =~ (^$|^[YyNn]$|^[Yy][Ee][Ss]$|^[Nn][Oo]$) ]] && [ "$user_input" != "是" ] && [ "$user_input" != "否" ]; do
            echo "当前输入错误，请重新输入。允许输入「是/否/yes/no/y/n」，不区分大小写。"
            if ! read -t 15 -r -p "是否删除章节标记（默认否）：" user_input; then
                echo
                drop_chapter_flag=false
            fi
        done
        if [ "$user_input" = "是" ] || [[ "$user_input" =~ (^[Yy]$|^[Yy][Ee][Ss]$) ]]; then
            drop_chapter_flag=true
        elif [ "$user_input" = "否" ] || [[ "$user_input" =~ (^$|^[Nn]$|^[Nn][Oo]) ]]; then
            drop_chapter_flag=false
        fi
    else
        echo
        drop_chapter_flag=false
    fi

    draw_line "-"
    echo "已开始本次的功能操作"
    draw_line "~"
    local operation_count=0
    local audio_title audio_artist
    shopt -s nullglob
    for file in *.mp3 *.m4a *.flac; do
        audio_title=$(ffprobe -loglevel error -show_entries format_tags=title -of default=noprint_wrappers=1:nokey=1 "$file")
        audio_artist=$(ffprobe -loglevel error -show_entries format_tags=artist -of default=noprint_wrappers=1:nokey=1 "$file")
        if [ "$audio_title" = "" ] || [ "$audio_artist" = "" ]; then
            echo "$file 没有元数据信息，无法完成重命名操作"
            draw_line "~"
        else
            if [ "$drop_chapter_flag" = false ]; then
                cp "$file" "$output_path/$audio_title - $audio_artist.${file##*.}"
                echo "已将 $file 重命名为 $audio_title - $audio_artist.${file##*.}"
                draw_line "~"
                ((operation_count++))
            else
                ffmpeg_no_banner -i "$file" -c copy -map_chapters -1 "$output_path/$audio_title - $audio_artist.${file##*.}"
                draw_line "~"
                ((operation_count++))
            fi
        fi
    done
    shopt -u nullglob
    echo "已结束本次的功能操作，总共执行了$operation_count次转换操作（当前路径检测到$all_count个可操作文件）"

    finished_word "directory" "$output_path"
}
