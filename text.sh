#!/bin/bash

for file in ./common_modules/* ./text_modules/*; do
    source "$file"
done

while true; do
    clear
    draw_line "="
    echo "文本批处理工具主菜单："
    options=("合并文本文件" "合并文本文件（逐行合并）" "退出程序")
    PS3="请选择菜单："
    select option in "${options[@]}"; do
        case $option in
        "合并文本文件（逐行合并）")
            while [ $? -ne 20 ]; do
                merge_text_file_line_by_line
            done
            break
            ;;
        "合并文本文件")
            while [ $? -ne 20 ]; do
                merge_text_file
            done
            break
            ;;
        "退出程序")
            break 2
            ;;
        *)
            echo "错误的选项，请重新选择菜单" >&2
            ;;
        esac
    done
done
