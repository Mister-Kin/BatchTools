#!/bin/bash

for file in ./common_modules/* ./ffmpeg_modules/*; do
    source "$file"
done

while true; do
    clear
    draw_line_echo "="
    echo -e "FFmpeg批处理工具主菜单：\n"
    options=("给图片添加版权水印并压缩" "合并视频和音频：mp4+m4a/mp3" "生成avc编码的mp4格式视频（libx264）" "压缩图片（原格式压缩或者转换为webp格式）" "压缩视频，转换为hevc编码的mp4格式（libx265）" "重命名音频" "为音频添加封面图" "获取音频封面图" "webp格式转png格式（删除源文件）" "tga格式转png格式" "无损分割视频" "flv格式转mp4格式" "显卡加速将图片序列合成为视频（不再维护该功能）" "退出程序")
    PS3=$'\n请选择菜单：'
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
        "压缩视频，转换为hevc编码的mp4格式（libx265）")
            while [ $? -ne 20 ]; do
                compress_video
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
        "压缩图片（原格式压缩或者转换为webp格式）")
            while [ $? -ne 20 ]; do
                compress_images
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
            echo -e "\n错误的选项，请重新选择菜单" >&2
            ;;
        esac
    done
done
