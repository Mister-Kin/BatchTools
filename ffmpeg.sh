#!/bin/bash

# 使用gawk改进处理函数返回字符串数组：未操作的文件打印数组列表。

for file in ./common_modules/* ./ffmpeg_modules/*; do
    source "$file"
done

main_menu_options_array+=("给图片添加版权水印并压缩")
main_menu_options_array+=("合并视频和音频：mp4+m4a/mp3")
main_menu_options_array+=("生成avc编码的mp4格式视频（libx264）")
main_menu_options_array+=("压缩图片（原格式压缩或者转换为webp格式）")
main_menu_options_array+=("压缩视频，转换为hevc编码的mp4格式（libx265）")
main_menu_options_array+=("音频转换器：音频格式互转")
main_menu_options_array+=("音频元数据标签工具")
main_menu_options_array+=("音频封面图工具：获取、添加、删除" "图像转png格式")
main_menu_options_array+=("无损分割视频")
main_menu_options_array+=("flv格式转mp4格式")
main_menu_options_array+=("显卡加速将图片序列合成为视频（不再维护该功能）")
main_menu_options_array+=("退出程序")

while true; do
    clear
    draw_line_echo "="
    echo -e "FFmpeg批处理工具主菜单：\n"
    echo "提示：使用上下方向键↑↓选择，回车键Enter确认选项："
    echo -e "\n请选择菜单：\n"
    arrow_select_option "${main_menu_options_array[@]}"
    choice=$?
    case ${main_menu_options_array[$choice]} in
    "音频元数据标签工具")
        while [ $? -ne 20 ]; do
            audio_metadata
        done
        ;;
    "音频转换器：音频格式互转")
        while [ $? -ne 20 ]; do
            audio_converter
        done
        ;;
    "图像转png格式")
        while [ $? -ne 20 ]; do
            image2png
        done
        ;;
    "无损分割视频")
        while [ $? -ne 20 ]; do
            video_split
        done
        ;;
    "音频封面图工具：获取、添加、删除")
        while [ $? -ne 20 ]; do
            audio_cover
        done
        ;;
    "生成avc编码的mp4格式视频（libx264）")
        while [ $? -ne 20 ]; do
            video_using_libx264
        done
        ;;
    "压缩视频，转换为hevc编码的mp4格式（libx265）")
        while [ $? -ne 20 ]; do
            video_compress
        done
        ;;
    "flv格式转mp4格式")
        while [ $? -ne 20 ]; do
            flv2mp4
        done
        ;;
    "合并视频和音频：mp4+m4a/mp3")
        while [ $? -ne 20 ]; do
            mp4_merged_with_audio
        done
        ;;
    "压缩图片（原格式压缩或者转换为webp格式）")
        while [ $? -ne 20 ]; do
            image_compress
        done
        ;;
    "显卡加速将图片序列合成为视频（不再维护该功能）")
        while [ $? -ne 20 ]; do
            image_sequence_to_video_with_gpu
        done
        ;;
    "给图片添加版权水印并压缩")
        while [ $? -ne 20 ]; do
            image_add_watermark
        done
        ;;
    "退出程序")
        break
        ;;
    esac
done
