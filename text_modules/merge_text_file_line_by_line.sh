#!/bin/bash

merge_text_file_line_by_line() {
    local feature_name feature_intro feature_note
    feature_name="合并文本文件（逐行拼接合并）"
    feature_intro="将路径下的txt文件逐行合并为一个文件$(description_append_intro "手动选择txt文件（txt文件数量超过两个）")"
    feature_note="$(description_append_note "option_false" "file" "merged.txt")"
    description "$feature_name" "$feature_intro" "$feature_note"
    change_directory
    if [ $? -eq 10 ]; then
        return 20
    fi

    local txt_count
    detect_and_remove "file" "merged.txt"
    txt_count=$(file_count "txt")

    if [ "$txt_count" -eq 0 ]; then
        log_file_not_detected "txt"
        return 0
    fi
    if [ "$txt_count" -eq 1 ]; then
        printf "当前只检测到1个txt文件，无需进行合并操作，已退出本次的功能操作\n"
        return 0
    fi

    log_start
    local operation_count=0
    shopt -s nullglob
    local -a txt_file_array
    txt_file_array+=(*.txt)
    txt_file_array+=(*.TXT)
    if [ "$txt_count" -ge 2 ]; then
        paste -d "\n" "${txt_file_array[0]}" "${txt_file_array[1]}" >merged.txt
        ((operation_count++))
        if [ "$txt_count" -gt 2 ]; then
            draw_line_blank "~"
            text_blank "提示：使用上下方向键↑↓选择文件，回车键Enter确认选项"
            text_blank "当前路径下检测到超过两个txt文件"
            text_blank "现在进入手动选择txt文件模式，请选择需要合并的两个txt文件："
            txt_file_array+=("取消功能操作，返回菜单")
            local select_txt1 select_opt1 select_txt2
            arrow_select_option "${txt_file_array[@]}"
            local choice=$?
            local choice_exit=$((${#txt_file_array[@]} - 1))
            if [ $choice -eq $choice_exit ]; then
                return 20
            fi
            select_txt1="${txt_file_array[$choice]}"
            select_opt1=$choice
            while [ $choice -eq $select_opt1 ]; do
                draw_line_blank "~"
                text_blank "提示：使用上下方向键↑↓选择文件，回车键Enter确认选项"
                text_blank "请选择需要合并的第二个txt文件，不能是刚才第一个选择的文件："
                arrow_select_option "${txt_file_array[@]}"
                choice=$?
                choice_exit=$((${#txt_file_array[@]} - 1))
                if [ $choice -eq $choice_exit ]; then
                    return 20
                fi
            done
            select_txt2="${txt_file_array[$choice]}"
            paste -d "\n" "$select_txt1" "$select_txt2" >merged.txt
            ((operation_count++))
        fi
    fi
    log_end "$operation_count" "$txt_count"
    log_result "$feature_note"
    shopt -u nullglob
}
