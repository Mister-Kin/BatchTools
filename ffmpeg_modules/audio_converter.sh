#!/bin/bash

audio_converter() {
    local -a menu_options_array
    menu_options_array+=("wav格式转m4a格式")
    menu_options_array+=("退出子菜单")
    while true; do
        clear
        draw_line_echo "="
        echo -e "FFmpeg批处理工具子菜单 —— 音频转换器：音频格式互转\n"
        echo "提示：使用上下方向键↑↓选择，回车键Enter确认选项："
        echo -e "\n请选择子菜单：\n"
        arrow_select_option "${menu_options_array[@]}"
        local choice=$?
        case ${menu_options_array[$choice]} in
        "wav格式转m4a格式")
            while [ $? -ne 20 ]; do
                audio_converter_wav2m4a
            done
            ;;
        "退出子菜单")
            return 20
            ;;
        esac
    done
}
