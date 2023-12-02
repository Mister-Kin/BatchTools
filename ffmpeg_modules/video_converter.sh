#!/bin/bash

video_converter() {
    local -a menu_options_array
    menu_options_array+=("视频转mp4格式")
    menu_options_array+=("退出子菜单")
    while true; do
        clear
        draw_line_blank "="
        text_blank "FFmpeg批处理工具子菜单 —— 视频转换器：视频格式互转"
        text_blank "提示：使用上下方向键↑↓选择，回车键Enter确认选项"
        text_blank "请选择子菜单："
        arrow_select_option "${menu_options_array[@]}"
        local choice=$?
        case ${menu_options_array[$choice]} in
        "视频转mp4格式")
            while [ $? -ne 20 ]; do
                video_converter_video2mp4
            done
            ;;
        "退出子菜单")
            return 20
            ;;
        esac
    done
}
