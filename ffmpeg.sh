#!/bin/bash

# 使用gawk改进处理函数返回字符串数组：未操作的文件打印数组列表。

for file in ./common_modules/* ./ffmpeg_modules/*; do
    source "$file"
done

main_menu_options_array+=("个人工作：批量操作媒体资源")
main_menu_options_array+=("压缩媒体资源")
main_menu_options_array+=("图片转换器：图片格式互转")
main_menu_options_array+=("视频转换器：视频格式互转")
main_menu_options_array+=("音频转换器：音频格式互转")
main_menu_options_array+=("音频元数据标签工具")
main_menu_options_array+=("音频封面图工具：获取、添加、删除")
main_menu_options_array+=("媒体资源工具：合并、分割、缩放")
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
    "个人工作：批量操作媒体资源")
        while [ $? -ne 20 ]; do
            personal_work
        done
        ;;
    "媒体资源工具：合并、分割、缩放")
        while [ $? -ne 20 ]; do
            media
        done
        ;;
    "图片转换器：图片格式互转")
        while [ $? -ne 20 ]; do
            image_converter
        done
        ;;
    "视频转换器：视频格式互转")
        while [ $? -ne 20 ]; do
            video_converter
        done
        ;;
    "音频转换器：音频格式互转")
        while [ $? -ne 20 ]; do
            audio_converter
        done
        ;;
    "压缩媒体资源")
        while [ $? -ne 20 ]; do
            compress_media
        done
        ;;
    "音频元数据标签工具")
        while [ $? -ne 20 ]; do
            audio_metadata
        done
        ;;
    "音频封面图工具：获取、添加、删除")
        while [ $? -ne 20 ]; do
            audio_cover
        done
        ;;
    "退出程序")
        break
        ;;
    esac
done
