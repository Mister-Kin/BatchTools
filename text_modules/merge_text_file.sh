#!/bin/bash

merge_text_file() {
    local -a menu_options_array
    menu_options_array+=("合并文本文件（文件首尾拼接）")
    menu_options_array+=("合并文本文件（逐行拼接合并）")
    menu_options_array+=("退出子菜单")
    while true; do
        clear
        draw_line_echo "="
        echo -e "文本批处理工具子菜单： —— 合并文本文件\n"
        echo "提示：使用上下方向键↑↓选择，回车键Enter确认选项："
        echo -e "\n请选择子菜单：\n"
        arrow_select_option "${menu_options_array[@]}"
        local choice=$?
        case ${menu_options_array[$choice]} in
        "合并文本文件（逐行拼接合并）")
            while [ $? -ne 20 ]; do
                merge_text_file_line_by_line
            done
            ;;
        "合并文本文件（文件首尾拼接）")
            while [ $? -ne 20 ]; do
                merge_text_file_join
            done
            ;;
        "退出子菜单")
            return 20
            ;;
        esac
    done
}
