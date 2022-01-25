#!/bin/bash

draw_line() {
    printf %"$(tput cols)"s | tr " " "$1"
}

description() {
    echo
    draw_line "="
    echo "功能：$1"
    echo "介绍：$2"
    if [ $# -eq 3 ]; then
        echo "注意事项：$3"
    fi
}

detect_and_remove() {
    if [ "$1" = "file" ]; then
        if [ -f "$2" ]; then
            rm "$2"
            echo "当前检测到$2，已强制删除$2"
        fi
    elif [ "$1" = "directory" ]; then
        if [ -d "$2" ]; then
            rm -rf "$2"
            echo "当前检测到$2文件夹，已强制删除$2文件夹"
            if [ $# -eq 3 ]; then
                mkdir "$2"
                echo "已重新创建$2文件夹"
            fi
        elif [ $# -eq 3 ]; then
            mkdir "$2"
            echo "已创建$2文件夹"
        fi
    fi
}

change_directory() {
    draw_line "-"
    echo "提示：输入0并回车，则返回主菜单"
    local path
    read -r -p "请输入文件夹路径并回车：" path
    if [ "$path" = "0" ]; then
        return 10
    fi
    while ! cd "$path" 2>/dev/null || [ "$path" = "" ]; do
        read -r -p "当前输入路径不存在，请重新输入文件夹路径并回车：" path
        if [ "$path" = "0" ]; then
            return 10
        fi
    done
    echo "工作路径已切换到$path"
    draw_line "-"
}

make_directory() {
    draw_line "-"
    if [ $# -gt 0 ]; then
        detect_and_remove "directory" "$1" "mkdir"
    fi
    if [ $# -eq 2 ]; then
        detect_and_remove "directory" "$2" "mkdir"
    fi
}

finished_word() {
    draw_line "-"
    if [ $# -gt 0 ]; then
        if [ "$1" = "file" ]; then
            echo -n "文件已输出为$2"
            if [ $# -eq 3 ]; then
                echo -n "和$3"
            fi
            echo
        elif [ "$1" = "directory" ]; then
            echo -n "文件已输出在$2文件夹"
            if [ $# -eq 3 ]; then
                echo -n "和$3文件夹"
            fi
            echo
        fi
    fi
    cd ~- || return
    echo "已切换回上一次的工作路径"
}

file_count() {
    shopt -s nullglob
    local file=(*."$1")
    shopt -u nullglob
    local file_count=${#file[@]}
    echo "$file_count"
}
