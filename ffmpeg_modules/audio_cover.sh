#!/bin/bash

audio_cover() {
    local -a menu_options_array
    menu_options_array+=("获取音频封面图")
    menu_options_array+=("添加音频封面图")
    menu_options_array+=("删除音频封面图")
    menu_options_array+=("退出子菜单")
    while true; do
        clear
        draw_line_blank "="
        text_blank "FFmpeg批处理工具子菜单 —— 音频封面图工具：获取、添加、删除"
        text_blank "提示：使用上下方向键↑↓选择，回车键Enter确认选项"
        text_blank "请选择子菜单："
        arrow_select_option "${menu_options_array[@]}"
        local choice=$?
        case ${menu_options_array[$choice]} in
        "获取音频封面图")
            while [ $? -ne 20 ]; do
                audio_cover_get
            done
            ;;
        "添加音频封面图")
            while [ $? -ne 20 ]; do
                audio_cover_attach
            done
            ;;
        "删除音频封面图")
            while [ $? -ne 20 ]; do
                audio_cover_delete
            done
            ;;
        "退出子菜单")
            return 20
            ;;
        esac
    done
}
