#!/bin/bash

merge_text_file_line_by_line() {
    description "合并文本文件（逐行合并）" "将两个txt文件逐行合并为一个名为「merged.txt」文件" "确保路径下没有名为「merged.txt」文件，否则本功能操作将生成同名文件强制覆盖；如果路径下已有该文件，请先自行处理好文件再执行该功能"
    change_directory
    if [ $? -eq 10 ]; then
        return 20
    fi

    local txt_count
    detect_and_remove "file" "merged.txt"
    txt_count=$(file_count "txt")
    all_count=$txt_count

    if [ "$txt_count" -eq 0 ]; then
        echo "当前并未检测到txt文件，已退出本次的功能操作"
        return 0
    fi
    if [ "$txt_count" -eq 1 ]; then
        echo "当前只检测到1个txt文件，无需进行合并操作，已退出本次的功能操作"
        return 0
    fi
    if [ "$txt_count" -ge 2 ]; then
        echo "当前检测到$txt_count个txt文件"
        if [ "$txt_count" -gt 2 ]; then
            echo "txt文件的数量已超过2个，本功能操作只能合并前两个txt文件；请确保自己所需操作的文件在最前的两个之中，或者路径中只有两个文件"
        fi
    fi

    draw_line "-"
    echo "已开始本次的功能操作"
    draw_line "~"
    local txt_file
    txt_file=(*.txt)
    paste -d "\n" "${txt_file[0]}" "${txt_file[1]}" >merged.txt
    echo "已将${txt_file[0]}和${txt_file[1]}逐行合并"
    draw_line "~"
    echo "已结束本次的功能操作，总共执行了1次合并操作（当前路径检测到$all_count个可操作文件）"

    finished_word "file" "merged.txt"
}
