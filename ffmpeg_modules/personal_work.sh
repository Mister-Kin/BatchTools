#!/bin/bash

personal_work() {
    local -a menu_options_array
    menu_options_array+=("图片序列导出mp4格式视频（libx264）")
    menu_options_array+=("给图片添加版权水印并压缩")
    menu_options_array+=("退出子菜单")
    while true; do
        clear
        draw_line_echo "="
        echo -e "FFmpeg批处理工具子菜单 —— 个人工作：批量操作媒体资源\n"
        echo "提示：使用上下方向键↑↓选择，回车键Enter确认选项："
        echo -e "\n请选择子菜单：\n"
        arrow_select_option "${menu_options_array[@]}"
        local choice=$?
        case ${menu_options_array[$choice]} in
        "图片序列导出mp4格式视频（libx264）")
            while [ $? -ne 20 ]; do
                personal_work_sequence2video
            done
            ;;
        "给图片添加版权水印并压缩")
            while [ $? -ne 20 ]; do
                personal_work_image_watermark
            done
            ;;
        "退出子菜单")
            return 20
            ;;
        esac
    done
}
