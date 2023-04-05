#!/bin/bash

media() {
    local -a menu_options_array
    menu_options_array+=("合并音视频：mp4+m4a/mp3")
    menu_options_array+=("分割视频")
    menu_options_array+=("退出子菜单")
    while true; do
        clear
        draw_line_blank "="
        text_blank "FFmpeg批处理工具子菜单 —— 媒体资源工具：合并、分割、缩放"
        text_blank "提示：使用上下方向键↑↓选择，回车键Enter确认选项"
        text_blank "请选择子菜单："
        arrow_select_option "${menu_options_array[@]}"
        local choice=$?
        case ${menu_options_array[$choice]} in
        "分割视频")
            while [ $? -ne 20 ]; do
                media_split_video
            done
            ;;
        "合并音视频：mp4+m4a/mp3")
            while [ $? -ne 20 ]; do
                media_merge_video_audio
            done
            ;;
        "退出子菜单")
            return 20
            ;;
        esac
    done
}
