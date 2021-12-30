#!/bin/bash

source "$(dirname $0)/common.sh"

ffmpeg_no_banner() {
    ffmpeg -hide_banner "$@"
}

copyright_watermark() {
    local copyright_text="© Mr. Kin"
    local font_path="C\:\/Windows\/fonts\/SourceSans3-Semibold.otf"
    local watermark_effect="split [main][tmp]; [tmp] drawtext=text='$copyright_text':fontfile='$font_path':fontcolor=white:fontsize=50:bordercolor=black:borderw=1:shadowcolor=black:shadowx=1.8:shadowy=1.8:x=50:y=50 [toplayer]; [main][toplayer] overlay"
    echo "$watermark_effect"
}

image_add_watermark() {
    local description="给图片添加版权水印并压缩"
    local output_path1="image_for_web"
    local output_path2="image_for_general"
    preparational_work "$description" "$output_path1" "$output_path2"
    if [ $? -eq 10 ]; then
        return 0
    fi

    local filter_effect
    filter_effect=$(copyright_watermark)
    local filter_effect_for_gif="$filter_effect, split[main][tmp]; [tmp]palettegen[palette]; [main][palette]paletteuse"
    shopt -s nullglob
    for file in *.png *.jpg; do
        ffmpeg_no_banner -i "$file" -vf "$filter_effect" "$output_path1/${file%.*}.webp"
        ffmpeg_no_banner -i "$file" -vf "$filter_effect" "$output_path2/${file%.*}.jpg"
    done
    for file in *.gif; do
        ffmpeg_no_banner -i "$file" -vf "$filter_effect" "$output_path1/${file%.*}.webp"
        ffmpeg_no_banner -i "$file" -vf "$filter_effect_for_gif" "$output_path2/${file%.*}.gif"
    done
    shopt -u nullglob

    finished_work "$output_path1" "$output_path2"
}

image_sequence_to_video_with_gpu() {
    local description="显卡加速将图片序列合成为视频（不再维护该功能）"
    local output_path="output_video"
    preparational_work "$description" "$output_path"
    if [ $? -eq 10 ]; then
        return 0
    fi

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

    finished_work "$output_path"
}

make_video_with_libx264() {
    local description="生成avc编码的mp4格式视频（libx264）"
    local output_path="video_x264"
    preparational_work "$description" "$output_path"
    if [ $? -eq 10 ]; then
        return 0
    fi

    local png_count jpg_count
    png_count=$(file_count "png")
    jpg_count=$(file_count "jpg")
    local file_name file_name_length input_file
    if [ "$png_count" -gt 0 ] || [ "$jpg_count" -gt 0 ]; then
        if [ "$png_count" -gt 0 ]; then
            for file in *.png; do
                file_name=${file::-4}
                file_name_length=${#file_name}
                echo "当前检测到png图片序列，文件名长度为$file_name_length"
                break
            done
            input_file="%0${file_name_length}d.png"
        elif [ "$jpg_count" -gt 0 ]; then
            for file in *.jpg; do
                file_name=${file::-4}
                file_name_length=${#file_name}
                echo "当前检测到jpg图片序列，文件名长度为$file_name_length"
                break
            done
            input_file="%0${file_name_length}d.jpg"
        fi
    fi

    local video_maxrate
    echo "提示：不输入（等待10s）或直接回车，则默认最大码率为3M。"
    if read -t 10 -r -p "请输入压制视频的最大码率（默认3M）：" video_maxrate; then
        if [ "$video_maxrate" = "" ]; then
            video_maxrate="3M"
        fi
    else
        echo
        video_maxrate="3M"
    fi

    local video_maxrate_unit=${video_maxrate: -1}   # 获取最后一个字符
    local video_maxrate_number=${video_maxrate::-1} # 删除最后一个字符
    local video_bufsize_number
    video_bufsize_number=$(echo $video_maxrate_number | awk '{ printf "%.2f", $1 * 2 }')
    local video_bufsize="${video_bufsize_number}${video_maxrate_unit}"

    local watermark_flag
    echo "提示：不输入（等待10s）或直接回车，则默认添加文字水印，若不需要请输入n。"
    if read -t 10 -r -p "是否添加版权水印（默认y）：" watermark_flag; then
        if [ "$watermark_flag" = "" ]; then
            watermark_flag="y"
        fi
    else
        echo
        watermark_flag="y"
    fi

    local subtitle_flag
    echo "提示：不输入（等待10s）或直接回车，则默认不添加字幕，若需要请输入y。"
    if read -t 10 -r -p "是否添加字幕（默认n）：" subtitle_flag; then
        if [ "$subtitle_flag" = "" ]; then
            subtitle_flag="n"
        fi
    else
        echo
        subtitle_flag="n"
    fi

    local subtitle_file filter_type ass_count srt_count
    if [ "$subtitle_flag" = "y" ]; then
        ass_count=$(file_count "ass")
        srt_count=$(file_count "srt")
        if [ "$ass_count" -gt 0 ]; then
            subtitle_file=(*.ass)
            filter_type="ass"
        elif [ "$srt_count" -gt 0 ]; then
            subtitle_file=(*.srt)
            filter_type="subtitles"
        fi
    fi

    local watermark_effect filter_effect
    watermark_effect=$(copyright_watermark)
    if [ "$watermark_flag" = "y" ] && [ "$subtitle_flag" = "n" ]; then
        filter_effect="${watermark_effect}[watermark_effect]; [watermark_effect] format=yuv420p"
    elif [ "$watermark_flag" = "n" ] && [ "$subtitle_flag" = "y" ]; then
        filter_effect="$filter_type='${subtitle_file[0]}', format=yuv420p"
    elif [ "$watermark_flag" = "y" ] && [ "$subtitle_flag" = "y" ]; then
        filter_effect="${watermark_effect}[watermark_effect]; [watermark_effect] $filter_type='${subtitle_file[0]}', format=yuv420p"
    elif [ "$watermark_flag" = "n" ] && [ "$subtitle_flag" = "n" ]; then
        filter_effect="format=yuv420p"
    fi

    if [ "$png_count" -gt 0 ] || [ "$jpg_count" -gt 0 ]; then
        ffmpeg_no_banner -r 24 -f image2 -i "$input_file" -r 24 -c:v libx264 -crf:v 23 -profile:v high -maxrate:v "$video_maxrate" -bufsize:v "$video_bufsize" -vf "$filter_effect" "$output_path/output.mp4"
    else
        shopt -s nullglob
        for file in *.mp4 *.flv *.mov; do
            ffmpeg_no_banner -i "$file" -c:v libx264 -crf:v 23 -profile:v high -maxrate:v "$video_maxrate" -bufsize:v "$video_bufsize" -vf "$filter_effect" -c:a copy "$output_path/${file%.*}.mp4"
        done
        shopt -u nullglob
    fi

    finished_work "$output_path"
}

image_to_webp() {
    local description="压缩图片，全部转为webp格式"
    local output_path="image_compress"
    preparational_work "$description" "$output_path"
    if [ $? -eq 10 ]; then
        return 0
    fi

    shopt -s nullglob
    for file in *.png *.jpg; do
        ffmpeg_no_banner -i "$file" "$output_path/${file%.*}.webp"
    done
    for file in *.gif; do
        ffmpeg_no_banner -i "$file" "$output_path/${file%.*}.webp"
    done
    shopt -u nullglob

    finished_work "$output_path"
}

merge_mp4_with_audio() {
    local description="合并视频和音频：mp4+m4a/mp3"
    local output_path="video_with_audio"
    preparational_work "$description" "$output_path"
    if [ $? -eq 10 ]; then
        return 0
    fi

    local audio_file m4a_count
    m4a_count=$(file_count "m4a")

    shopt -s nullglob
    local mp4_file=(*.mp4)
    if [ "$m4a_count" -gt 0 ]; then
        audio_file=(*.m4a)
    else
        audio_file=(*.mp3)
    fi
    shopt -u nullglob

    ffmpeg_no_banner -i "${mp4_file[0]}" -i "${audio_file[0]}" -c copy "$output_path/${mp4_file[0]}"

    finished_work "$output_path"
}

flv_to_mp4() {
    local description="flv格式转mp4格式"
    preparational_work "$description"
    if [ $? -eq 10 ]; then
        return 0
    fi

    shopt -s nullglob
    for file in *.flv; do
        ffmpeg_no_banner -i "$file" -c copy "${file%.*}.mp4"
    done
    shopt -u nullglob

    finished_work
}

video_to_hevc() {
    local description="压缩视频，全部转为hevc编码的mp4格式（libx265）"
    local output_path="video_compress"
    preparational_work "$description" "$output_path"
    if [ $? -eq 10 ]; then
        return 0
    fi

    shopt -s nullglob
    for file in *.mp4 *.flv *.mov; do
        ffmpeg_no_banner -i "$file" -c:v libx265 -c:a copy "$output_path/${file%.*}.mp4"
    done
    shopt -u nullglob

    finished_work "$output_path"
}

retrieve_audio_album() {
    local description="获取音频封面图"
    local output_path="audio_album"
    preparational_work "$description" "$output_path"
    if [ $? -eq 10 ]; then
        return 0
    fi

    shopt -s nullglob
    for file in *.mp3 *.m4a *.flac; do
        ffmpeg_no_banner -i "$file" -an -c:v copy "$output_path/${file%.*}.png"
    done
    shopt -u nullglob

    finished_work "$output_path"
}

attach_image_to_audio() {
    local description="为音频添加封面图"
    local output_path="audio_attach_image"
    preparational_work "$description" "$output_path"
    if [ $? -eq 10 ]; then
        return 0
    fi

    local png_count image_file
    png_count=$(file_count "png")

    shopt -s nullglob
    if [ "$png_count" -gt 0 ]; then
        image_file=(*.png)
    else
        image_file=(*.jpg)
    fi

    for file in *.mp3 *.m4a *.flac; do
        ffmpeg_no_banner -i "$file" -i "${image_file[0]}" -map 0 -map 1 -c copy -map_chapters -1 -disposition:v:0 attached_pic "$output_path/$file"
    done
    shopt -u nullglob

    finished_work "$output_path"
}

rename_audio() {
    local description="重命名音频"
    local output_path="audio_rename"
    preparational_work "$description" "$output_path"
    if [ $? -eq 10 ]; then
        return 0
    fi

    local drop_chapter_flag
    echo "提示：不输入（等待10s）或直接回车，则默认保留章节标记，若需要删除请输入y。"
    if read -t 10 -r -p "是否删除章节标记（默认n）：" watermark_flag; then
        if [ "$watermark_flag" = "" ]; then
            drop_chapter_flag="n"
        fi
    else
        echo
        drop_chapter_flag="n"
    fi

    local audio_title audio_artist
    shopt -s nullglob
    for file in *.mp3 *.m4a *.flac; do
        audio_title=$(ffprobe -loglevel error -show_entries format_tags=title -of default=noprint_wrappers=1:nokey=1 "$file")
        audio_artist=$(ffprobe -loglevel error -show_entries format_tags=artist -of default=noprint_wrappers=1:nokey=1 "$file")
        if [ "$audio_title" = "" ] || [ "$audio_artist" = "" ]; then
            echo "$file 没有元数据信息，无法完成重命名操作"
        else
            if [ "$drop_chapter_flag" = "n" ]; then
                cp "$file" "$output_path/$audio_title - $audio_artist.${file##*.}"
                echo "已将 $file 重命名为 $audio_title - $audio_artist.${file##*.}"
            else
                ffmpeg_no_banner -i "$file" -c copy -map_chapters -1 "$output_path/$audio_title - $audio_artist.${file##*.}"
            fi
        fi
    done
    shopt -u nullglob

    finished_work "$output_path"
}

webp_to_png() {
    local description="webp格式转png格式（删除源文件）"
    preparational_work "$description"
    if [ $? -eq 10 ]; then
        return 0
    fi

    shopt -s nullglob
    for file in *.webp; do
        ffmpeg_no_banner -i "$file" "${file%.*}.png"
        rm "$file"
        echo "已删除 $file"
    done
    shopt -u nullglob

    finished_work
}

while true; do
    echo "========================================"
    options=("给图片添加版权水印并压缩" "合并视频和音频：mp4+m4a/mp3" "生成avc编码的mp4格式视频（libx264）" "压缩图片，全部转为webp格式" "压缩视频，全部转为hevc编码的mp4格式（libx265）" "重命名音频" "为音频添加封面图" "获取音频封面图" "webp格式转png格式（删除源文件）" "flv格式转mp4格式" "显卡加速将图片序列合成为视频（不再维护该功能）" "退出程序")
    PS3="请选择菜单："
    select option in "${options[@]}"; do
        case $option in
        "webp格式转png格式（删除源文件）")
            webp_to_png
            break
            ;;
        "重命名音频")
            rename_audio
            break
            ;;
        "为音频添加封面图")
            attach_image_to_audio
            break
            ;;
        "获取音频封面图")
            retrieve_audio_album
            break
            ;;
        "生成avc编码的mp4格式视频（libx264）")
            make_video_with_libx264
            break
            ;;
        "压缩视频，全部转为hevc编码的mp4格式（libx265）")
            video_to_hevc
            break
            ;;
        "flv格式转mp4格式")
            flv_to_mp4
            break
            ;;
        "合并视频和音频：mp4+m4a/mp3")
            merge_mp4_with_audio
            break
            ;;
        "压缩图片，全部转为webp格式")
            image_to_webp
            break
            ;;
        "显卡加速将图片序列合成为视频（不再维护该功能）")
            image_sequence_to_video_with_gpu
            break
            ;;
        "给图片添加版权水印并压缩")
            image_add_watermark
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
