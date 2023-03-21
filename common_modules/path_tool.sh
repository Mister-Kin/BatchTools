#!/bin/bash

detect_and_remove() {
    if [ "$1" = "file" ]; then
        if [ -f "$2" ]; then
            rm "$2"
            draw_line_echo "~"
            echo -e "当前检测到「$2」\n\n已强制删除「$2」\n"
        fi
    elif [ "$1" = "directory" ]; then
        if [ -d "$2" ]; then
            rm -rf "$2"
            draw_line_echo "~"
            echo -e "当前检测到「$2」文件夹\n\n已强制删除「$2」文件夹\n"
        fi
    fi
}

change_directory() {
    draw_line "-"
    echo_text_echo "提示：输入0并回车，则返回主菜单"
    local path
    read -r -p "请输入文件夹路径并回车：" path
    if [ "$path" = "0" ]; then
        return 10
    fi
    while ! cd "$path" 2>/dev/null || [ "$path" = "" ]; do
        echo
        read -r -p "当前输入路径不存在，请重新输入文件夹路径并回车：" path
        if [ "$path" = "0" ]; then
            return 10
        fi
    done
    echo_text_echo_normal "工作路径已切换到「$path」"
}

make_directory() {
    if [ $# -ge 1 ]; then
        detect_and_remove "directory" "$1"
        mkdir "$1"
        draw_line_echo "~"
        text_echo "已创建「$1」文件夹"
        if [ $# -ge 2 ]; then
            detect_and_remove "directory" "$2"
            mkdir "$2"
            draw_line_echo "~"
            text_echo "已创建「$2」文件夹"
            if [ $# -ge 3 ]; then
                detect_and_remove "directory" "$3"
                mkdir "$3"
                draw_line_echo "~"
                text_echo "已创建「$3」文件夹"
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
    all_count=$(("$file_lowercase_count" + "$file_uppercase_count"))
    local count="$all_count"
    # 临时重定向至STDERR，避免无关的echo命令影响函数的返回值
    if [ "$file_lowercase_count" -gt 0 ] || [ "$file_uppercase_count" -gt 0 ]; then
        draw_line_echo "-" >&2
        if [ "$file_lowercase_count" -gt 0 ]; then
            echo "当前路径检测到$file_lowercase_count个$1文件" >&2
            echo >&2
        fi
        if [ "$file_uppercase_count" -gt 0 ]; then
            echo "当前路径检测到$file_uppercase_count个$file_uppercase_extension文件" >&2
            echo >&2
        fi
    fi
    echo "$count"
}

file_not_detected() {
    local detected_text="$1文件"
    if [ $# -ge 2 ]; then
        detected_text+="、$2文件"
        if [ $# -ge 3 ]; then
            detected_text+="、$3文件"
            if [ $# -ge 4 ]; then
                detected_text+="、$4文件"
                if [ $# -ge 5 ]; then
                    detected_text+="、$5文件"
                    if [ $# -ge 6 ]; then
                        detected_text+="、$6文件"
                    fi
                fi
            fi
        fi
    fi
    draw_line "-"
    echo_text "由于当前路径并未检测到任何$detected_text，已退出本次的功能操作"
}
