#!/bin/bash

source "$(dirname $0)/common.sh"

ffmpeg_no_banner() {
    ffmpeg -hide_banner "$@"
}

copyright_watermark() {
    local copyright_text="© Mr. Kin"
    local font_path="C\:\/Windows\/fonts\/SourceSans3-Semibold.otf"
    local watermark_effect="split [main][tmp]; [tmp] drawtext=text='$copyright_text':fontfile='$font_path':fontcolor=white:fontsize=50:bordercolor=black:borderw=1.5:shadowcolor=black:shadowx=1.8:shadowy=1.8:x=50:y=50 [toplayer]; [main][toplayer] overlay"
    echo "$watermark_effect"
}

image_add_watermark() {
    description "给图片添加版权水印并压缩" "将所有png文件或者jpg文件或者gif文件转换为webp和jpg格式，并添加版本水印，分别输出在「image_for_web」文件夹和「image_for_general」文件夹；" "确保路径下没有名为「image_for_web」文件夹和「image_for_general」文件夹，否则本功能操作将生成同名文件夹强制覆盖；如果路径下已有这些文件夹，请先自行处理好文件再执行该功能"
    change_directory
    if [ $? -eq 10 ]; then
        return 20
    fi

    local png_count jpg_count gif_count all_count
    png_count=$(file_count "png")
    jpg_count=$(file_count "jpg")
    gif_count=$(file_count "gif")
    all_count=$(("$png_count" + "$jpg_count" + "$gif_count"))

    if [ "$png_count" -eq 0 ] && [ "$jpg_count" -eq 0 ] && [ "$gif_count" -eq 0 ]; then
        echo "当前并未检测到png文件或者jpg文件或者gif文件，已退出本次的功能操作"
        return 0
    fi
    if [ "$png_count" -gt 0 ]; then
        echo "当前检测到$png_count个png文件"
    fi
    if [ "$jpg_count" -gt 0 ]; then
        echo "当前检测到$jpg_count个jpg文件"
    fi
    if [ "$gif_count" -gt 0 ]; then
        echo "当前检测到$gif_count个gif文件"
    fi

    local output_path1="image_for_web"
    local output_path2="image_for_general"
    make_directory "$output_path1" "$output_path2"

    local filter_effect
    filter_effect=$(copyright_watermark)
    local filter_effect_for_gif="$filter_effect, split[main][tmp]; [tmp]palettegen[palette]; [main][palette]paletteuse"

    draw_line "-"
    echo "已开始本次的功能操作"
    draw_line "~"
    local operation_count=0
    shopt -s nullglob
    for file in *.png *.jpg; do
        ffmpeg_no_banner -i "$file" -vf "$filter_effect" "$output_path1/${file%.*}.webp"
        draw_line "~"
        ffmpeg_no_banner -i "$file" -vf "$filter_effect" "$output_path2/${file%.*}.jpg"
        draw_line "~"
        ((operation_count += 2))
    done
    for file in *.gif; do
        ffmpeg_no_banner -i "$file" -vf "$filter_effect" "$output_path1/${file%.*}.webp"
        draw_line "~"
        ffmpeg_no_banner -i "$file" -vf "$filter_effect_for_gif" "$output_path2/${file%.*}.gif"
        draw_line "~"
        ((operation_count += 2))
    done
    shopt -u nullglob
    echo "已结束本次的功能操作，总共执行了$operation_count次转换操作（当前路径检测到$all_count个可操作文件）"

    finished_word "directory" "$output_path1" "$output_path2"
}

image_sequence_to_video_with_gpu() {
    description "显卡加速将图片序列合成为视频（不再维护该功能）" "使用h264_nvenc，将png图片序列或者jpg图片序列合成为avc编码的mp4视频；生成的文件输出在「output_video」文件夹" "本功能已不再维护，存在着早期的代码逻辑设计，并未考虑文件检测逻辑和规范输入格式；确保路径下没有名为「output_video」文件夹，否则本功能操作将生成同名文件夹强制覆盖；如果路径下已有该文件夹，请先自行处理好文件再执行该功能"
    change_directory
    if [ $? -eq 10 ]; then
        return 20
    fi

    local output_path="output_video"
    make_directory "$output_path"

    local name_length
    echo "提示：不输入（等待10s）或直接回车，则默认长度为4，如0001.png"
    if read -t 10 -r -p "请输入图片序列名的长度：" name_length; then
        if [ "$name_length" == "" ]; then
            name_length=4
        fi
    else
        echo
        name_length=4
    fi
    local video_bitrate video_maxrate
    echo "提示：不输入（等待10s）或直接回车，则默认为8M 10M，用空格分割两个参数，如2.5M 5M"
    if read -t 10 -r -p "请输入压制视频的码率和最大码率：" video_bitrate video_maxrate; then
        if [ "$video_bitrate" = "" ]; then
            video_bitrate="8M"
        fi
        if [ "$video_maxrate" = "" ]; then
            video_maxrate="10M"
        fi
    else
        echo
        video_bitrate="8M"
        video_maxrate="10M"

    fi
    local png_count
    png_count=$(file_count "png")
    if [ "$png_count" -gt 0 ]; then
        ffmpeg_no_banner -hwaccel cuda -hwaccel_output_format cuda -r 24 -f image2 -i %0"$name_length"d.png -r 24 -c:v h264_nvenc -profile:v high -preset:v slow -rc:v vbr -cq:v 19 -b:v "$video_bitrate" -maxrate:v "$video_maxrate" "$output_path/output.mp4"
    else
        ffmpeg_no_banner -hwaccel cuda -hwaccel_output_format cuda -c:v mjpeg_cuvid -r 24 -f image2 -i %0"$name_length"d.jpg -r 24 -c:v h264_nvenc -profile:v high -preset:v slow -rc:v vbr -cq:v 19 -b:v "$video_bitrate" -maxrate:v "$video_maxrate" "$output_path/output.mp4"
    fi

    finished_word "directory" "$output_path"
}

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

image_to_webp() {
    description "压缩图片，全部转为webp格式" "将所有png文件或者jpg文件或者gif文件转换成webp格式；生成的文件输出在「image_compress」文件夹" "确保路径下没有名为「image_compress」文件夹，否则本功能操作将生成同名文件夹强制覆盖；如果路径下已有该文件夹，请先自行处理好文件再执行该功能"
    change_directory
    if [ $? -eq 10 ]; then
        return 20
    fi

    local png_count jpg_count gif_count all_count
    png_count=$(file_count "png")
    jpg_count=$(file_count "jpg")
    gif_count=$(file_count "gif")
    all_count=$(("$png_count" + "$jpg_count" + "$gif_count"))

    if [ "$png_count" -eq 0 ] && [ "$jpg_count" -eq 0 ] && [ "$gif_count" -eq 0 ]; then
        echo "当前并未检测到png文件或者jpg文件或者gif文件，已退出本次的功能操作"
        return 0
    fi
    if [ "$png_count" -gt 0 ]; then
        echo "当前检测到$png_count个png文件"
    fi
    if [ "$jpg_count" -gt 0 ]; then
        echo "当前检测到$jpg_count个jpg文件"
    fi
    if [ "$gif_count" -gt 0 ]; then
        echo "当前检测到$gif_count个gif文件"
    fi

    local output_path="image_compress"
    make_directory "$output_path"

    draw_line "-"
    echo "已开始本次的功能操作"
    draw_line "~"
    local operation_count=0
    shopt -s nullglob
    for file in *.png *.jpg; do
        ffmpeg_no_banner -i "$file" "$output_path/${file%.*}.webp"
        draw_line "~"
        ((operation_count++))
    done
    for file in *.gif; do
        ffmpeg_no_banner -i "$file" -vf "split[main][tmp]; [tmp]palettegen[palette]; [main][palette]paletteuse" "$output_path/${file%.*}.webp"
        draw_line "~"
        ((operation_count++))
    done
    shopt -u nullglob
    echo "已结束本次的功能操作，总共执行了$operation_count次转换操作（当前路径检测到$all_count个可操作文件）"

    finished_word "directory" "$output_path"
}

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

video_to_hevc() {
    description "压缩视频，全部转为hevc编码的mp4格式（libx265）" "使用libx264，将所有mp4文件或者flv文件或者mov文件转换hevc编码的mp4格式视频；生成的文件输出在「video_compress」文件夹" "确保路径下没有名为「video_compress」文件夹，否则本功能操作将生成同名文件夹强制覆盖；如果路径下已有该文件夹，请先自行处理好文件再执行该功能"
    change_directory
    if [ $? -eq 10 ]; then
        return 20
    fi

    local mp4_count flv_count mov_count all_count
    mp4_count=$(file_count "mp4")
    flv_count=$(file_count "flv")
    mov_count=$(file_count "mov")
    all_count=$(("$mp4_count" + "$flv_count" + "$mov_count"))

    if [ "$mp4_count" -eq 0 ] && [ "$flv_count" -eq 0 ] && [ "$mov_count" -eq 0 ]; then
        echo "当前并未检测到任何mp4文件或者flv文件或者mov文件，已退出本次的功能操作"
        return 0
    fi
    if [ "$mp4_count" -gt 0 ]; then
        echo "当前检测到$mp4_count个mp4文件"
    fi
    if [ "$flv_count" -gt 0 ]; then
        echo "当前检测到$flv_count个flv文件"
    fi
    if [ "$mov_count" -gt 0 ]; then
        echo "当前检测到$mov_count个mov文件"
    fi

    local output_path="video_compress"
    make_directory "$output_path"

    draw_line "-"
    echo "已开始本次的功能操作"
    draw_line "~"
    local operation_count=0
    shopt -s nullglob
    for file in *.mp4 *.flv *.mov; do
        ffmpeg_no_banner -i "$file" -c:v libx265 -c:a copy "$output_path/${file%.*}.mp4"
        draw_line "~"
        ((operation_count++))
    done
    shopt -u nullglob
    echo "已结束本次的功能操作，总共执行了$operation_count次转换操作（当前路径检测到$all_count个可操作文件）"

    finished_word "directory" "$output_path"
}

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

caculate_end_time_for_splitting_video() {
    local end_time hour_time minute_time second_time temp_time
    if [[ "$1" =~ ^[0-5]?[0-9]$ ]]; then
        end_time="$1"
    elif [[ "$1" =~ ^[0-5]?[0-9]\.[0-5]?[0-9]$ ]]; then
        minute_time=${1%.*}
        second_time=${1##*.}
        end_time=$(("$minute_time" * 60 + "$second_time"))

    elif [[ "$1" =~ ^[0-9]+\.[0-5]?[0-9]\.[0-5]?[0-9]$ ]]; then
        hour_time=${1%%.*}
        temp_time=${1%.*}
        minute_time=${temp_time##*.}
        second_time=${1##*.}
        end_time=$(("$hour_time" * 60 * 60 + "$minute_time" * 60 + "$second_time"))
    elif [[ "$1" =~ ^[Ee][Nn][Dd]$ ]]; then
        end_time="$2"
    fi
    echo "$end_time"
}

split_video() {
    description "无损分割视频" "将mp4文件或者flv文件或者mov文件按时间点连续无损分割为多个文件；生成的文件输出在「video_split」文件夹" "确保路径下没有名为「video_split」文件夹，否则本功能操作将生成同名文件夹强制覆盖；如果路径下已有该文件夹，请先自行处理好文件再执行该功能"
    change_directory
    if [ $? -eq 10 ]; then
        return 20
    fi

    local mp4_count flv_count mov_count all_count
    mp4_count=$(file_count "mp4")
    flv_count=$(file_count "flv")
    mov_count=$(file_count "mov")
    all_count=$(("$mp4_count" + "$flv_count" + "$mov_count"))

    if [ "$mp4_count" -eq 0 ] && [ "$flv_count" -eq 0 ] && [ "$mov_count" -eq 0 ]; then
        echo "当前并未检测到任何mp4文件或者flv文件或者mov文件，已退出本次的功能操作"
        return 0
    elif [ "$all_count" -gt 1 ]; then
        echo "当前检测到多个视频文件，已退出本次的功能操作，请确保路径中只有一个视频文件"
        return 0
    fi

    local video_file video_extension
    if [ "$mp4_count" -gt 0 ]; then
        echo "当前检测到$mp4_count个mp4文件"
        video_file=(*.mp4)
        video_extension="mp4"
    fi
    if [ "$flv_count" -gt 0 ]; then
        echo "当前检测到$flv_count个flv文件"
        video_file=(*.flv)
        video_extension="flv"
    fi
    if [ "$mov_count" -gt 0 ]; then
        echo "当前检测到$mov_count个mov文件"
        video_file=(*.mov)
        video_extension="mov"
    fi
    local original_video_duration video_duration video_duration_integer
    original_video_duration=$(ffprobe -loglevel error -show_entries format=duration -of default=noprint_wrappers=1:nokey=1 "${video_file[0]}")
    video_duration=${original_video_duration::-3} # 删除三个小数（ffprobe输出6位小数）
    video_duration_integer=${video_duration%.*}
    echo "视频总时长为$video_duration秒"

    local output_path="video_split"
    make_directory "$output_path"

    draw_line "-"
    echo "已开始本次的功能操作"
    draw_line "~"
    local operation_count=0
    shopt -s nullglob
    local user_input
    local start_time=0 end_time=0 start_time_text=0 end_time_text hour_time minute_time second_time cut_time

    while [ "$end_time" -lt "$video_duration_integer" ]; do
        echo "提示：允许输入格式为「小时.分钟.秒钟」，例如1.5=1分5秒，注意分钟和秒钟限制为六十进制。输入「end」或者「大于视频总时长的时间点」即代表视频末尾处，不区分大小写。"
        read -r -p "当前时间点为$start_time_text，请输入下一个时间点：" user_input
        while ! [[ "$user_input" =~ (^[0-5]?[0-9]$|^[0-5]?[0-9]\.[0-5]?[0-9]$|^[0-9]+\.[0-5]?[0-9]\.[0-5]?[0-9]$|^[Ee][Nn][Dd]$) ]] || [ "$(caculate_end_time_for_splitting_video "$user_input" "$video_duration_integer")" -le "$start_time" ]; do
            if ! [[ "$user_input" =~ (^[0-5]?[0-9]$|^[0-5]?[0-9]\.[0-5]?[0-9]$|^[0-9]+\.[0-5]?[0-9]\.[0-5]?[0-9]$|^[Ee][Nn][Dd]$) ]]; then
                echo "当前输入错误，请重新输入。允许输入格式为「小时.分钟.秒钟」，例如1.5=1分5秒，注意分钟和秒钟限制为六十进制。输入「end」或者「大于视频总时长的时间点」即代表视频末尾处，不区分大小写。"
            else
                echo "当前输入的时间点小于或等于上一次输入的时间点，请重新输入一个大于的时间点："
            fi
            read -r -p "当前时间点为$start_time_text，请输入下一个时间点：" user_input
        done

        # 处理前面只有0的输入情况
        if [[ "$user_input" =~ ^0+\.[0-5]?[0-9]$ ]]; then
            end_time_text=${user_input#*.}
        elif [[ "$user_input" =~ ^0+\.[0-5]?[0-9]\.[0-5]?[0-9]$ ]]; then
            end_time_text=${user_input#*.}
        else
            end_time_text="$user_input"
        fi

        end_time=$(caculate_end_time_for_splitting_video "$user_input" "$video_duration_integer")
        if [ "$end_time" -ge "$video_duration_integer" ]; then
            if [ "$end_time" -eq "$video_duration_integer" ]; then
                echo "当前输入的时间点为视频末尾处"
            else
                echo "当前输入的时间点已超过视频总时长，本程序已自动将时间点设置为视频末尾处"
            fi
            end_time="$video_duration"
            end_time_text="end"
        fi

        ffmpeg_no_banner -i "${video_file[0]}" -ss "$start_time" -to "$end_time" -c copy "$output_path/$start_time_text - $end_time_text.$video_extension"
        if [ "$end_time" = "$video_duration" ]; then
            cut_time=$(echo $start_time "$end_time" | awk '{ printf "%.3f", $2 - $1 }')
        else
            cut_time=$(("$end_time" - "$start_time"))
        fi
        echo "当前剪切$cut_time秒视频，已在$output_path文件夹中输出文件 $start_time_text - $end_time_text.$video_extension"
        start_time="$end_time"
        start_time_text="$end_time_text"
        if [ "$end_time" = "$video_duration" ]; then
            end_time="$video_duration_integer"
        fi
        ((operation_count++))
        draw_line "~"
    done
    shopt -u nullglob
    echo "已结束本次的功能操作，视频总时长为$video_duration秒，总共执行了$operation_count次分割操作"

    finished_word "directory" "$output_path"
}

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

while true; do
    clear
    draw_line "="
    echo "FFmpeg批处理工具主菜单："
    options=("给图片添加版权水印并压缩" "合并视频和音频：mp4+m4a/mp3" "生成avc编码的mp4格式视频（libx264）" "压缩图片，全部转为webp格式" "压缩视频，全部转为hevc编码的mp4格式（libx265）" "重命名音频" "为音频添加封面图" "获取音频封面图" "webp格式转png格式（删除源文件）" "tga格式转png格式" "无损分割视频" "flv格式转mp4格式" "显卡加速将图片序列合成为视频（不再维护该功能）" "退出程序")
    PS3="请选择菜单："
    select option in "${options[@]}"; do
        case $option in
        "tga格式转png格式")
            while [ $? -ne 20 ]; do
                tga_to_png
            done
            break
            ;;
        "无损分割视频")
            while [ $? -ne 20 ]; do
                split_video
            done
            break
            ;;
        "webp格式转png格式（删除源文件）")
            while [ $? -ne 20 ]; do
                webp_to_png
            done
            break
            ;;
        "重命名音频")
            while [ $? -ne 20 ]; do
                rename_audio
            done
            break
            ;;
        "为音频添加封面图")
            while [ $? -ne 20 ]; do
                attach_image_to_audio
            done
            break
            ;;
        "获取音频封面图")
            while [ $? -ne 20 ]; do
                retrieve_audio_album
            done
            break
            ;;
        "生成avc编码的mp4格式视频（libx264）")
            while [ $? -ne 20 ]; do
                make_video_with_libx264
            done
            break
            ;;
        "压缩视频，全部转为hevc编码的mp4格式（libx265）")
            while [ $? -ne 20 ]; do
                video_to_hevc
            done
            break
            ;;
        "flv格式转mp4格式")
            while [ $? -ne 20 ]; do
                flv_to_mp4
            done
            break
            ;;
        "合并视频和音频：mp4+m4a/mp3")
            while [ $? -ne 20 ]; do
                merge_mp4_with_audio
            done
            break
            ;;
        "压缩图片，全部转为webp格式")
            while [ $? -ne 20 ]; do
                image_to_webp
            done
            break
            ;;
        "显卡加速将图片序列合成为视频（不再维护该功能）")
            while [ $? -ne 20 ]; do
                image_sequence_to_video_with_gpu
            done
            break
            ;;
        "给图片添加版权水印并压缩")
            while [ $? -ne 20 ]; do
                image_add_watermark
            done
            break
            ;;
        "退出程序")
            break 2
            ;;
        *)
            echo "错误的选项，请重新选择菜单" >&2
            ;;
        esac
    done
done
