#!/bin/bash

for file in ./common_modules/* ./text_modules/*; do
    source "$file"
done

main_menu_options_array+=("合并文本文件")
main_menu_options_array+=("退出程序")

while true; do
    clear
    draw_line "="
    echo -e "文本批处理工具主菜单：\n"
    echo "提示：使用上下方向键↑↓选择，回车键Enter确认选项："
    echo -e "\n请选择菜单：\n"
    arrow_select_option "${main_menu_options_array[@]}"
    choice=$?
    case ${main_menu_options_array[$choice]} in
    "合并文本文件")
        while [ $? -ne 20 ]; do
            merge_text_file
        done
        ;;
    "退出程序")
        break
        ;;
    esac
done
