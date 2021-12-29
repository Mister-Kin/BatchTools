#!/bin/bash

preparational_work() {
    clear
    echo "功能：$1"
    echo "提示：输入0并回车，则返回主菜单"
    local path
    read -r -p "请输入路径并回车：" path
    if [ "$path" = "0" ]; then
        return 10
    fi
    if cd "$path" 2>/dev/null; then
        echo "已切换到路径$path"
    else
        while ! cd "$path" 2>/dev/null; do
            read -r -p "当前输入路径不存在，请重新输入路径并回车：" path
        done
        echo "已切换到路径$path"
    fi
    if [ $# -gt 1 ]; then
        if [ -d "$path/$2" ]; then
            rm -rf "$2"
            mkdir "$2"
        else
            mkdir "$2"
        fi
    fi
    if [ $# -eq 3 ]; then
        if [ -d "$path/$3" ]; then
            rm -rf "$3"
            mkdir "$3"
        else
            mkdir "$3"
        fi
    fi
}

finished_work() {
    echo "已结束操作"
    if [ $# -eq 1 ]; then
        echo "请查看$1文件夹"
    fi
    if [ $# -eq 2 ]; then
        echo "请查看$1文件夹和$2文件夹"
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
