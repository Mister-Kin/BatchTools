#!/bin/bash

audio_converter() {
    while true; do
        clear
        draw_line_echo "="
        echo -e "FFmpeg批处理工具子菜单：\n\n音频转换器：音频格式互转\n"
        options=("wav格式转m4a格式" "退出子菜单")
        PS3=$'\n请选择子菜单：'
        select option in "${options[@]}"; do
            case $option in
            "wav格式转m4a格式")
                while [ $? -ne 20 ]; do
                    audio_converter_wav2m4a
                done
                break
                ;;
            "退出子菜单")
                return 20
                ;;
            *)
                echo -e "\n错误的选项，请重新选择子菜单" >&2
                ;;
            esac
        done
    done
}
