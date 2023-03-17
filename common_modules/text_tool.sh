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
