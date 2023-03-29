#!/bin/bash

audio_metadata() {
    while true; do
        clear
        draw_line_echo "="
        echo -e "FFmpeg批处理工具子菜单：\n\n音频元数据标签工具\n"
        options=("根据元数据标签重命名音频文件" "根据音频文件名修改元数据标签" "设置音频文件的专辑名" "退出子菜单")
        PS3=$'\n请选择子菜单：'
        select option in "${options[@]}"; do
            case $option in
            "设置音频文件的专辑名")
                while [ $? -ne 20 ]; do
                    audio_metadata_set_album
                done
                break
                ;;
            "根据元数据标签重命名音频文件")
                while [ $? -ne 20 ]; do
                    audio_metadata_rename_file
                done
                break
                ;;
            "根据音频文件名修改元数据标签")
                while [ $? -ne 20 ]; do
                    audio_metadata_by_file_name
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
