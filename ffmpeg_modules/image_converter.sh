#!/bin/bash

image_converter() {
    local -a menu_options_array
    menu_options_array+=("图片转png格式")
    menu_options_array+=("退出子菜单")
    while true; do
        clear
        draw_line_echo "="
        echo -e "FFmpeg批处理工具子菜单 —— 图片转换器：图片格式互转\n"
        echo "提示：使用上下方向键↑↓选择，回车键Enter确认选项："
        echo -e "\n请选择子菜单：\n"
        arrow_select_option "${menu_options_array[@]}"
        local choice=$?
        case ${menu_options_array[$choice]} in
        "图片转png格式")
            while [ $? -ne 20 ]; do
                image_converter_image2png
            done
            ;;
        "退出子菜单")
            return 20
            ;;
        esac
    done
}
