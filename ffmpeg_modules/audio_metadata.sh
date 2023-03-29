#!/bin/bash

audio_metadata() {
    local -a menu_options_array
    menu_options_array+=("根据元数据标签重命名音频文件")
    menu_options_array+=("根据音频文件名修改元数据标签")
    menu_options_array+=("设置音频文件的专辑名")
    menu_options_array+=("设置音频文件的歌曲名")
    menu_options_array+=("设置音频文件的歌手名")
    menu_options_array+=("退出子菜单")
    while true; do
        clear
        draw_line_echo "="
        echo -e "FFmpeg批处理工具子菜单 —— 音频元数据标签工具\n"
        echo "提示：使用上下方向键↑↓选择，回车键Enter确认选项："
        echo -e "\n请选择子菜单：\n"
        arrow_select_option "${menu_options_array[@]}"
        local choice=$?
        case ${menu_options_array[$choice]} in
        "设置音频文件的歌手名")
            while [ $? -ne 20 ]; do
                audio_metadata_set_artist
            done
            ;;
        "设置音频文件的歌曲名")
            while [ $? -ne 20 ]; do
                audio_metadata_set_title
            done
            ;;
        "设置音频文件的专辑名")
            while [ $? -ne 20 ]; do
                audio_metadata_set_album
            done
            ;;
        "根据元数据标签重命名音频文件")
            while [ $? -ne 20 ]; do
                audio_metadata_rename_file
            done
            ;;
        "根据音频文件名修改元数据标签")
            while [ $? -ne 20 ]; do
                audio_metadata_by_file_name
            done
            ;;
        "退出子菜单")
            return 20
            ;;
        esac
    done
}
