#!/bin/bash

source "$(dirname $0)/common.sh"

merge_text_file() {
    local description="合并文本文件"
    preparational_work "$description"
    if [ $? -eq 10 ]; then
        return 0
    fi

    shopt -s nullglob
    for file in *.txt *.srt; do
        cat "$file" >>"merged.${file##*.}"
    done
    shopt -u nullglob

    finished_work
}

merge_text_file_line_by_line() {
    local description="合并文本文件（中英逐行合并）"
    preparational_work "$description"
    if [ $? -eq 10 ]; then
        return 0
    fi

    local txt_file
    txt_file=(*.txt)

    shopt -s nullglob
    paste -d "\n" "${txt_file[0]}" "${txt_file[1]}" >merged.txt
    shopt -u nullglob

    finished_work
}

while true; do
    echo "========================================"
    options=("合并文本文件" "合并文本文件（中英逐行合并）" "退出程序")
    PS3="请选择菜单："
    select option in "${options[@]}"; do
        case $option in
        "合并文本文件（中英逐行合并）")
            merge_text_file_line_by_line
            break
            ;;
        "合并文本文件")
            merge_text_file
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
