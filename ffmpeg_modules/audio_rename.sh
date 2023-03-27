#!/bin/bash

audio_rename() {
    while true; do
        clear
        draw_line_echo "="
        echo -e "FFmpeg批处理工具子菜单：\n\n音频重命名：重命名音频文件或者修改音频文件内部的元数据标签\n"
        options=("根据元数据标签重命名音频文件" "根据音频文件名修改音频内部的元数据标签" "退出子菜单")
        PS3=$'\n请选择子菜单：'
        select option in "${options[@]}"; do
            case $option in
            "根据元数据标签重命名音频文件")
                while [ $? -ne 20 ]; do
                    audio_rename_to_file
                done
                break
                ;;
            "根据音频文件名修改音频内部的元数据标签")
                while [ $? -ne 20 ]; do
                    audio_rename_to_metadata
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
