#!/bin/bash

detect_and_remove() {
    if [ "$1" = "file" ]; then
        if [ -f "$2" ]; then
            rm "$2"
            draw_line_blank "~"
            printf "%b" "当前检测到「$2」\n\n已强制删除「$2」\n\n"
        fi
    elif [ "$1" = "directory" ]; then
        if [ -d "$2" ]; then
            rm -rf "$2"
            draw_line_blank "~"
            printf "%b" "当前检测到「$2」文件夹\n\n已强制删除「$2」文件夹\n\n"
        fi
    fi
}

change_directory() {
    draw_line "-"
    blank_text_blank "提示：输入0并回车，则返回菜单"
    local path
    read -e -r -p "请输入文件夹路径并回车：" path
    if [ "$path" = "0" ]; then
        return 10
    fi
    while ! cd "$path" 2>/dev/null || [ "$path" = "" ]; do
        printf "\n"
        read -e -r -p "当前输入路径不存在，请重新输入文件夹路径并回车：" path
        if [ "$path" = "0" ]; then
            return 10
        fi
    done
    blank_text_blank_normal "工作路径已切换到「${path}」"
}

make_directory() {
    if [ $# -ge 1 ]; then
        detect_and_remove "directory" "$1"
        mkdir "$1"
        draw_line_blank "~"
        text_blank "已创建「$1」文件夹"
        if [ $# -ge 2 ]; then
            detect_and_remove "directory" "$2"
            mkdir "$2"
            draw_line_blank "~"
            text_blank "已创建「$2」文件夹"
            if [ $# -ge 3 ]; then
                detect_and_remove "directory" "$3"
                mkdir "$3"
                draw_line_blank "~"
                text_blank "已创建「$3」文件夹"
            fi
        fi
    fi
}

file_count() {
    local file_uppercase_extension
    file_uppercase_extension=$(lowercase_to_uppercase "$1")
    shopt -s nullglob
    local file_lowercase=(*."$1")
    local file_uppercase=(*."$file_uppercase_extension")
    shopt -u nullglob
    local file_lowercase_count=${#file_lowercase[@]}
    local file_uppercase_count=${#file_uppercase[@]}
    local all_count
    all_count=$((file_lowercase_count + file_uppercase_count))
    if [ "$file_lowercase_count" -gt 0 ] || [ "$file_uppercase_count" -gt 0 ]; then
        # 临时重定向至STDERR，避免无关的printf命令影响函数的返回值
        draw_line_blank "-" >&2
        if [ "$file_lowercase_count" -gt 0 ]; then
            printf "%b" "当前路径检测到${file_lowercase_count}个$1文件\n\n" >&2
        fi
        if [ "$file_uppercase_count" -gt 0 ]; then
            printf "%b" "当前路径检测到${file_uppercase_count}个${file_uppercase_extension}文件\n\n" >&2
        fi
    fi
    printf "%d" "$all_count"
}
