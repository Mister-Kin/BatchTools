#!/bin/bash

ffmpeg_no_banner() {
    ffmpeg -hide_banner "$@"
}

preparational_work() {
    clear
    echo "功能：$1"
    echo "输入 0 则返回主菜单"
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

    finished_work
}

image_sequence_to_video_with_gpu() {
    local description="显卡加速将图片序列合成为视频"
    local output_path1="output"
    preparational_work "$description" "$output_path1"
    if [ $? -eq 10 ]; then
        return 0
    fi

    local name_length
    read -r -p "请输入图片序列名的长度（不输入直接回车则默认长度为4）：" name_length
    if [ "$name_length" == "" ]; then
        name_length=4
    fi
    ffmpeg_no_banner -hwaccel cuda -hwaccel_output_format cuda -r 24 -f image2 -i %0"$name_length"d.png -r 24 -c:v h264_nvenc -profile:v high -preset slow -rc:v vbr -cq:v 19 -b:v 2500k -maxrate:v 5000k "output/output.mp4"

    finished_work
}

test() {
    local description="测试"
    local output_path1="for_web"
    preparational_work "$description" "$output_path1"
    if [ $? -eq 10 ]; then
        return 0
    fi

    finished_work
}

while true; do
    echo "========================================"
    options=("给图片添加版权水印并压缩" "显卡加速将图片序列合成为视频" "退出程序" "测试")
    PS3="请选择菜单："
    select option in "${options[@]}"; do
        case $option in
        "测试")
            test
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
