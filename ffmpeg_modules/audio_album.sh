#!/bin/bash
# to-do：删除音频封面
audio_album() {
    while true; do
        clear
        draw_line_echo "="
        echo -e "FFmpeg批处理工具子菜单：\n\n处理音频封面图：获取、添加、删除\n"
        options=("获取音频封面图" "添加音频封面图" "退出子菜单")
        PS3=$'\n请选择子菜单：'
        select option in "${options[@]}"; do
            case $option in
            "获取音频封面图")
                while [ $? -ne 20 ]; do
                    audio_album_get
                done
                break
                ;;
            "添加音频封面图")
                while [ $? -ne 20 ]; do
                    audio_album_attach
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
