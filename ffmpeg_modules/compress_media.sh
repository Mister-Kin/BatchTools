#!/bin/bash

# to-do：压缩音频

compress_media() {
    local -a menu_options_array
    menu_options_array+=("压缩图片（原格式压缩或者转换为webp格式）")
    menu_options_array+=("压缩视频，转换为hevc编码的mp4格式（libx265）")
    menu_options_array+=("退出子菜单")
    while true; do
        clear
        draw_line_echo "="
        echo -e "FFmpeg批处理工具子菜单 —— 压缩媒体资源\n"
        echo "提示：使用上下方向键↑↓选择，回车键Enter确认选项："
        echo -e "\n请选择子菜单：\n"
        arrow_select_option "${menu_options_array[@]}"
        local choice=$?
        case ${menu_options_array[$choice]} in
        "压缩图片（原格式压缩或者转换为webp格式）")
            while [ $? -ne 20 ]; do
                compress_media_image
            done
            ;;
        "压缩视频，转换为hevc编码的mp4格式（libx265）")
            while [ $? -ne 20 ]; do
                compress_media_video
            done
            ;;
        "退出子菜单")
            return 20
            ;;
        esac
    done
}
