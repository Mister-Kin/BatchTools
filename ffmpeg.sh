#!/bin/bash

ffmpeg_no_banner() {
    ffmpeg -hide_banner "$@"
}

preparational_work() {
    clear
    echo "功能：$1"
    echo "提示：输入0回车，则返回主菜单"
    local path
    read -r -p "请输入路径并回车：" path
    if [ "$path" = "0" ]; then
        return 10
    fi
    cd "$path" || return
    echo "已切换到路径$path"
    if [ $# -gt 1 ]; then
        if [ -d "$path/$2" ]; then
            rm -rf "$2"
            mkdir "$2"
        else
            mkdir "$2"
        fi
    fi
    if [ $# -eq 3 ]; then
        if [ -d "$path/$3" ]; then
            rm -rf "$3"
            mkdir "$3"
        else
            mkdir "$3"
        fi
    fi
}

finished_work() {
    echo "已结束操作"
    if [ $# -eq 1 ]; then
        echo "请查看$1文件夹"
    fi
    if [ $# -eq 2 ]; then
        echo "请查看$1文件夹和$2文件夹"
    fi
    cd ~- || return
    echo "已切换回上一次的工作路径"
}

image_add_watermark() {
    local description="给图片添加版权水印并压缩"
    local output_path1="for_web"
    local output_path2="for_general"
    preparational_work "$description" "$output_path1" "$output_path2"
    if [ $? -eq 10 ]; then
        return 0
    fi

    local copyright_text="© Mr. Kin"
    local font_path="C\:\/Windows\/fonts\/SourceSans3-Semibold.otf"
    local filter_effect="split [main][tmp]; [tmp] drawtext=text='$copyright_text':fontfile='$font_path':fontcolor=white:fontsize=35:bordercolor=black:borderw=1:shadowcolor=black:shadowx=1.8:shadowy=1.8:x=20:y=20 [toplayer]; [main][toplayer] overlay"
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
    local description="显卡加速将图片序列合成为视频"
    local output_path1="output"
    preparational_work "$description" "$output_path1"
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
    png_count=$(ls -1 *.png 2>/dev/null | wc -l)
    if [ $png_count -gt 0 ]; then
        ffmpeg_no_banner -hwaccel cuda -hwaccel_output_format cuda -r 24 -f image2 -i %0"$name_length"d.png -r 24 -c:v h264_nvenc -profile:v high -preset:v slow -rc:v vbr -cq:v 19 -b:v "$video_bitrate" -maxrate:v "$video_maxrate" "output/output.mp4"
    else
        ffmpeg_no_banner -hwaccel cuda -hwaccel_output_format cuda -c:v mjpeg_cuvid -r 24 -f image2 -i %0"$name_length"d.jpg -r 24 -c:v h264_nvenc -profile:v high -preset:v slow -rc:v vbr -cq:v 19 -b:v "$video_bitrate" -maxrate:v "$video_maxrate" "output/output.mp4"
    fi

    finished_work "$output_path1"
}

image_to_webp() {
    local description="压缩图片，全部转为webp格式"
    local output_path1="output"
    preparational_work "$description" "$output_path1"
    if [ $? -eq 10 ]; then
        return 0
    fi

    shopt -s nullglob
    for file in *.png *.jpg; do
        ffmpeg_no_banner -i "$file" "$output_path1/${file%.*}.webp"
    done
    for file in *.gif; do
        ffmpeg_no_banner -i "$file" "$output_path1/${file%.*}.webp"
    done
    shopt -u nullglob

    finished_work "$output_path1"
}

merge_mp4_audio() {
    local description="合并视频和音频：mp4 + m4a/mp3"
    local output_path1="output"
    preparational_work "$description" "$output_path1"
    if [ $? -eq 10 ]; then
        return 0
    fi

    mp4_file=$(ls *.mp4 2>/dev/null)
    m4a_count=$(ls -1 *.m4a 2>/dev/null | wc -l)
    if [ $m4a_count -gt 0 ]; then
        audio_file=$(ls *.m4a)
    else
        audio_file=$(ls *.mp3 2>/dev/null)
    fi
    ffmpeg_no_banner -i "$mp4_file" -i "$audio_file" -c copy "output/$mp4_file"

    finished_work "$output_path1"
}

test() {
    local description="测试"
    local output_path1="output"
    preparational_work "$description" "$output_path1"
    if [ $? -eq 10 ]; then
        return 0
    fi

    finished_work
}

while true; do
    echo "========================================"
    options=("给图片添加版权水印并压缩" "显卡加速将图片序列合成为视频" "压缩图片，全部转为webp格式" "合并视频和音频：mp4 + m4a/mp3" "退出程序" "测试")
    PS3="请选择菜单："
    select option in "${options[@]}"; do
        case $option in
        "测试")
            test
            break
            ;;
        "合并视频和音频：mp4 + m4a/mp3")
            merge_mp4_audio
            break
            ;;
        "压缩图片，全部转为webp格式")
            image_to_webp
            break
            ;;
        "显卡加速将图片序列合成为视频")
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
