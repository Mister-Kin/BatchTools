#!/bin/bash

make_video_with_libx264() {
    description "生成avc编码的mp4格式视频（libx264）" "使用libx264，将png图片序列或者jpg图片序列合成为avc编码的mp4格式视频；也可以将mp4文件或者flv文件或者mov文件重新编码，生成avc编码的mp4格式视频；生成的文件输出在「video_x264」文件夹" "图片序列仅支持纯数字的文件名，如0001.png，并且图片序列文件数量不能小于24；重新编码音频是基于aac编码，使用libfdk_aac；确保路径下没有名为「video_x264」文件夹，否则本功能操作将生成同名文件夹强制覆盖；如果路径下已有该文件夹，请先自行处理好文件再执行该功能"
    change_directory
    if [ $? -eq 10 ]; then
        return 20
    fi

    local png_count jpg_count mp4_count flv_count mov_count all_count
    png_count=$(file_count "png")
    jpg_count=$(file_count "jpg")
    mp4_count=$(file_count "mp4")
    flv_count=$(file_count "flv")
    mov_count=$(file_count "mov")
    all_count=$(("$png_count" + "$jpg_count" + "$mp4_count" + "$flv_count" + "$mov_count"))

    if [ "$png_count" -lt 24 ] && [ "$jpg_count" -lt 24 ] && [ "$mp4_count" -eq 0 ] && [ "$flv_count" -eq 0 ] && [ "$mov_count" -eq 0 ]; then
        echo "当前并未检测到png图片序列或者jpg图片序列或者mp4文件或者flv文件或者mov文件，已退出本次的功能操作"
        return 0
    fi

    local file_name file_name_length input_file image_sequence_flag
    if [ "$png_count" -ge 24 ] || [ "$jpg_count" -ge 24 ]; then
        if [ "$png_count" -ge 24 ]; then
            for file in *.png; do
                file_name=${file::-4}
                if [[ "$file_name" =~ ^[0-9]+$ ]]; then
                    image_sequence_flag=true
                    file_name_length=${#file_name}
                    echo "当前检测到png图片序列，文件名长度为$file_name_length，文件数量为$png_count"
                else
                    image_sequence_flag=false
                    echo "当前检测到$png_count个png文件，但不是png图片序列"
                fi
                break
            done
            input_file="%0${file_name_length}d.png"
        elif [ "$jpg_count" -ge 24 ]; then
            for file in *.jpg; do
                file_name=${file::-4}
                if [[ "$file_name" =~ ^[0-9]+$ ]]; then
                    image_sequence_flag=true
                    file_name_length=${#file_name}
                    echo "当前检测到jpg图片序列，文件名长度为$file_name_length，文件数量为$jpg_count"
                else
                    image_sequence_flag=false
                    echo "当前检测到$jpg_count个jpg文件，但不是jpg图片序列"
                fi
                break
            done
            input_file="%0${file_name_length}d.jpg"
        fi
    fi

    if [ "$png_count" -lt 24 ] && [ "$jpg_count" -lt 24 ]; then
        image_sequence_flag=false
        echo "当前并未检测到png图片序列或者jpg图片序列"
    fi

    local video_flag
    if [ "$mp4_count" -gt 0 ]; then
        video_flag=true
        echo "当前检测到$mp4_count个mp4文件"
    fi
    if [ "$flv_count" -gt 0 ]; then
        video_flag=true
        echo "当前检测到$flv_count个flv文件"
    fi
    if [ "$mov_count" -gt 0 ]; then
        video_flag=true
        echo "当前检测到$mov_count个mov文件"
    fi

    if [ "$mp4_count" -eq 0 ] && [ "$flv_count" -eq 0 ] && [ "$mov_count" -eq 0 ]; then
        video_flag=false
        if [ "$image_sequence_flag" = false ]; then
            echo "当前并未检测到mp4文件或者flv文件或者mov文件，已退出本次的功能操作"
            return 0
        fi
    fi

    local output_path="video_x264"
    make_directory "$output_path"

    draw_line "-"
    local user_input
    local video_maxrate
    echo "提示：不输入（等待15s）或直接回车，则默认最大码率为20M（允许输入格式为「数字（允许带小数）+单位（k/K/M）」，例如300k、1.5M等）"
    if read -t 15 -r -p "请输入压制视频的最大码率（默认20M）：" user_input; then
        while ! [[ "$user_input" =~ (^$|^[0-9]+\.?[0-9]*[kKM]$) ]]; do
            echo "当前输入错误，请重新输入。允许输入格式为「数字（允许带小数）+单位（k/K/M）」，例如300k、1.5M等。"
            if ! read -t 15 -r -p "请输入压制视频的最大码率（默认20M）：" user_input; then
                echo
                video_maxrate="20M"
            fi
        done
        if [[ "$user_input" =~ ^$ ]]; then
            video_maxrate="20M"
        else
            video_maxrate="$user_input"
        fi
    else
        echo
        video_maxrate="20M"
    fi

    local video_maxrate_unit=${video_maxrate: -1}   # 获取最后一个字符
    local video_maxrate_number=${video_maxrate::-1} # 删除最后一个字符
    local video_bufsize_number
    video_bufsize_number=$(echo $video_maxrate_number | awk '{ printf "%.2f", $1 * 2 }')
    local video_bufsize="${video_bufsize_number}${video_maxrate_unit}"

    draw_line "-"
    local watermark_flag
    echo "提示：不输入（等待15s）或直接回车，则默认添加文字水印（默认是，允许输入「是/否/yes/no/y/n」，不区分大小写）"
    if read -t 15 -r -p "是否添加版权水印（默认是）：" user_input; then
        while ! [[ "$user_input" =~ (^$|^[YyNn]$|^[Yy][Ee][Ss]$|^[Nn][Oo]$) ]] && [ "$user_input" != "是" ] && [ "$user_input" != "否" ]; do
            echo "当前输入错误，请重新输入。允许输入「是/否/yes/no/y/n」，不区分大小写。"
            if ! read -t 15 -r -p "是否添加版权水印（默认是）：" user_input; then
                echo
                # 这条语句代码逻辑上应该显式地声明，没有的话也无影响，read命令超时后，user_input的值会重置为空，所以后面正则表达会识别出来。
                watermark_flag=true
            fi
        done
        if [ "$user_input" = "是" ] || [[ "$user_input" =~ (^$|^[Yy]$|^[Yy][Ee][Ss]$) ]]; then
            watermark_flag=true
        elif [ "$user_input" = "否" ] || [[ "$user_input" =~ (^[Nn]$|^[Nn][Oo]) ]]; then
            watermark_flag=false
        fi
    else
        echo
        watermark_flag=true
    fi

    draw_line "-"
    local subtitle_flag
    echo "提示：不输入（等待15s）或直接回车，则默认不添加字幕（默认否，允许输入「是/否/yes/no/y/n」，不区分大小写）"
    if read -t 15 -r -p "是否添加字幕（默认否）：" user_input; then
        while ! [[ "$user_input" =~ (^$|^[YyNn]$|^[Yy][Ee][Ss]$|^[Nn][Oo]$) ]] && [ "$user_input" != "是" ] && [ "$user_input" != "否" ]; do
            echo "当前输入错误，请重新输入。允许输入「是/否/yes/no/y/n」，不区分大小写。"
            if ! read -t 15 -r -p "是否删除添加字幕（默认否）：" user_input; then
                echo
                subtitle_flag=false
            fi
        done
        if [ "$user_input" = "是" ] || [[ "$user_input" =~ (^[Yy]$|^[Yy][Ee][Ss]$) ]]; then
            subtitle_flag=true
        elif [ "$user_input" = "否" ] || [[ "$user_input" =~ (^$|^[Nn]$|^[Nn][Oo]) ]]; then
            subtitle_flag=false
        fi
    else
        echo
        subtitle_flag=false
    fi

    local subtitle_file filter_type ass_count srt_count
    if [ "$subtitle_flag" = true ]; then
        ass_count=$(file_count "ass")
        srt_count=$(file_count "srt")
        if [ "$ass_count" -gt 0 ]; then
            subtitle_file=(*.ass)
            filter_type="ass"
        elif [ "$srt_count" -gt 0 ]; then
            subtitle_file=(*.srt)
            filter_type="subtitles"
        elif [ "$ass_count" -eq 0 ] && [ "$srt_count" -eq 0 ]; then
            draw_line "-"
            echo "当前路径并未检测到ass或者srt字幕文件，将无法添加字幕。"
            subtitle_flag=false
        fi
    fi

    local watermark_effect filter_effect
    watermark_effect=$(copyright_watermark)
    if [ "$watermark_flag" = true ] && [ "$subtitle_flag" = false ]; then
        filter_effect="${watermark_effect}[watermark_effect]; [watermark_effect] format=yuv420p"
    elif [ "$watermark_flag" = false ] && [ "$subtitle_flag" = true ]; then
        filter_effect="$filter_type='${subtitle_file[0]}', format=yuv420p"
    elif [ "$watermark_flag" = true ] && [ "$subtitle_flag" = true ]; then
        filter_effect="${watermark_effect}[watermark_effect]; [watermark_effect] $filter_type='${subtitle_file[0]}', format=yuv420p"
    elif [ "$watermark_flag" = false ] && [ "$subtitle_flag" = false ]; then
        filter_effect="format=yuv420p"
    fi

    local encode_audio_flag
    if [ "$video_flag" = true ]; then
        draw_line "-"
        echo "提示：不输入（等待15s）或直接回车，则默认不重新编码音频，即复制音频流（默认否，允许输入「是/否/yes/no/y/n」，不区分大小写）"
        if read -t 15 -r -p "是否重新编码音频（默认否）：" user_input; then
            while ! [[ "$user_input" =~ (^$|^[YyNn]$|^[Yy][Ee][Ss]$|^[Nn][Oo]$) ]] && [ "$user_input" != "是" ] && [ "$user_input" != "否" ]; do
                echo "当前输入错误，请重新输入。允许输入「是/否/yes/no/y/n」，不区分大小写。"
                if ! read -t 15 -r -p "是否重新编码音频（默认否）：" user_input; then
                    echo
                    encode_audio_flag=false
                fi
            done
            if [ "$user_input" = "是" ] || [[ "$user_input" =~ (^[Yy]$|^[Yy][Ee][Ss]$) ]]; then
                encode_audio_flag=true
            elif [ "$user_input" = "否" ] || [[ "$user_input" =~ (^$|^[Nn]$|^[Nn][Oo]) ]]; then
                encode_audio_flag=false
            fi
        else
            echo
            encode_audio_flag=false
        fi
    fi

    local audio_rate
    if [ "$encode_audio_flag" = true ]; then
        draw_line "-"
        echo "提示：不输入（等待15s）或直接回车，则默认码率为128k（允许输入格式为「数字」，单位由程序设置为k，例如输入192，程序会自动设置为192k）"
        if read -t 15 -r -p "请输入压制音频的码率（默认128k）：" user_input; then
            while ! [[ "$user_input" =~ (^$|^[0-9]+$) ]]; do
                echo "当前输入错误，请重新输入。允许输入格式为「数字」，单位由程序设置为k，例如输入192，程序会自动设置为192k。"
                if ! read -t 15 -r -p "请输入压制音频的码率（默认128k）：" user_input; then
                    echo
                    audio_rate="128k"
                fi
            done
            if [[ "$user_input" =~ ^$ ]]; then
                audio_rate="128k"
            else
                audio_rate="${user_input}k"
            fi
        else
            echo
            audio_rate="128k"
        fi
    fi

    draw_line "-"
    echo "已开始本次的功能操作"
    draw_line "~"
    local operation_count=0
    if [ "$image_sequence_flag" = true ]; then
        ffmpeg_no_banner -r 24 -f image2 -i "$input_file" -r 24 -c:v libx264 -crf:v 23 -profile:v high -maxrate:v "$video_maxrate" -bufsize:v "$video_bufsize" -vf "$filter_effect" "$output_path/output.mp4"
        draw_line "~"
        ((operation_count++))
    fi
    if [ "$video_flag" = true ]; then
        shopt -s nullglob
        if [ "$encode_audio_flag" = true ]; then
            for file in *.mp4 *.flv *.mov; do
                ffmpeg_no_banner -i "$file" -c:v libx264 -crf:v 23 -profile:v high -maxrate:v "$video_maxrate" -bufsize:v "$video_bufsize" -vf "$filter_effect" -c:a libfdk_aac -b:a "$audio_rate" "$output_path/${file%.*}.mp4"
                draw_line "~"
                ((operation_count++))
            done
        else
            for file in *.mp4 *.flv *.mov; do
                ffmpeg_no_banner -i "$file" -c:v libx264 -crf:v 23 -profile:v high -maxrate:v "$video_maxrate" -bufsize:v "$video_bufsize" -vf "$filter_effect" -c:a copy "$output_path/${file%.*}.mp4"
                draw_line "~"
                ((operation_count++))
            done
        fi
        shopt -u nullglob
    fi
    echo "已结束本次的功能操作，总共执行了$operation_count次转换操作（当前路径检测到$all_count个可操作文件）"

    finished_word "directory" "$output_path"
}
