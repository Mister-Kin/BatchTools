#!/bin/bash

# 风格编程统一原则：涉及分割线的，全部先draw_line，每个函数尾部且必须添加空行。

draw_line() {
    printf %"$(tput cols)"s | tr " " "$1"
}

blank_draw_line() {
    printf "\n"
    draw_line "$1"
}

draw_line_blank() {
    draw_line "$1"
    printf "\n\n"
}

blank_draw_line_blank() {
    printf "\n"
    draw_line "$1"
    printf "\n\n"
}

blank_text() {
    printf "%b" "\n\n$1\n"
}

blank_text_normal() {
    printf "%b" "\n$1\n"
}

text_blank() {
    printf "%b" "$1\n\n"
}

blank_text_blank() {
    printf "%b" "\n\n$1\n\n"
}

blank_text_blank_normal() {
    printf "%b" "\n$1\n\n"
}

set_color() {
    case "$1" in
    "black")
        printf "%s" "$(tput setaf 0)"
        ;;
    "red")
        printf "%s" "$(tput setaf 1)"
        ;;
    "green")
        printf "%s" "$(tput setaf 2)"
        ;;
    "yellow")
        printf "%s" "$(tput setaf 3)"
        ;;
    "blue")
        printf "%s" "$(tput setaf 4)"
        ;;
    "magenta")
        printf "%s" "$(tput setaf 5)"
        ;;
    "cyan")
        printf "%s" "$(tput setaf 6)"
        ;;
    "white")
        printf "%s" "$(tput setaf 7)"
        ;;
    "reset")
        printf "%s" "$(tput sgr0)"
        ;;
    esac
    if [ $# -eq 2 ]; then
        printf "%s" "$2$(tput sgr0)"
    fi
}

lowercase_to_uppercase() {
    printf "%s" "$1" | tr "[:lower:]" "[:upper:]"
}

uppercase_to_lowercase() {
    printf "%s" "$1" | tr "[:upper:]" "[:lower:]"
}

# 获取任意位置的字符
# ${str:position:length}
# position仅指明位置，为负数时，则从尾部数起。例如-1就是指倒数第一个位置。
# length：指定长度，从左往右计算长度。
get_any_char() {
    printf "%s" "${1:$2:$3}"
}

# 获取首个字符
# ${str:0:1}可简写为${str::1}
get_first_char() {
    printf "%s" "${1::1}"
}

# 获取前面任意个字符
get_first_any_char() {
    printf "%s" "${1::$2}"
}

# 获取最后一个字符
get_last_char() {
    printf "%s" "${1: -1}"
}

# 获取最后任意个字符
get_last_any_char() {
    printf "%s" "${1: -$2}"
}

# 删除首个字符
remove_first_char() {
    printf "%s" "${1:1}"
}

# 删除前面任意个字符
remove_first_any_char() {
    printf "%s" "${1:$2}"
}

# 删除最后一个字符
remove_last_char() {
    printf "%s" "${1::-1}"
}

# 删除最后任意个字符
remove_last_any_char() {
    printf "%s" "${1::-$2}"
}

get_string_length() {
    printf "%s" "${#1}"
}

remove_after_first_delimiter() {
    printf "%s" "${1%%"$2"*}"
}

remove_after_last_delimiter() {
    printf "%s" "${1%"$2"*}"
}

remove_before_first_delimiter() {
    printf "%s" "${1#*"$2"}"
}

remove_before_last_delimiter() {
    printf "%s" "${1##*"$2"}"
}

get_file_name() {
    printf "%s" "$(remove_after_last_delimiter "$1" ".")"
}

get_file_extension() {
    printf "%s" "$(remove_before_last_delimiter "$1" ".")"
}

description() {
    blank_draw_line_blank "="
    text_blank "功能名称：$1"
    local text
    text="${2//；/\\n\\t}"
    printf "%b" "功能介绍：${text}\n\n"
    if [ $# -eq 3 ]; then
        text="${3//；/\\n\\t}"
        printf "%b" "注意事项：${text}\n\n"
    fi
}

description_append_intro() {
    printf "%b" "\n\n功能参数：$(set_color "blue")$1$(set_color "reset")"
}

# 函数: description_append_note，补充description函数的注意事项小节
# 参数1：如果结果不确定，如可能输出在这个文件夹或者其他文件夹中。确定结果：option_false；不确定结果：option_true
# 参数2：设置文件或者文件夹。file/directory
# 参数3：如果操作中会创建文件夹，并且有删除源文件的选项。设置为directory_delete_option。没有删除源文件选项就不用设置此项，缺省设置为文件或者文件夹的正常名称。
# 参数4-参数8：文件或者文件夹的名称。
description_append_note() {
    local hint_text_name hint_text_path hint_text_type hint_text_type_prefix hint_text_option hint_text_append
    if [ "$1" = "option_false" ]; then
        hint_text_option="、"
    elif [ "$1" = "option_true" ]; then
        hint_text_option="或者"
    fi
    if [ "$2" = "file" ]; then
        hint_text_name="$3文件"
        hint_text_path="为"
        hint_text_type=""
        hint_text_type_prefix="同名"
        if [ $# -ge 4 ]; then
            hint_text_name+="${hint_text_option}$4文件"
            if [ $# -ge 5 ]; then
                hint_text_name+="${hint_text_option}$5文件"
                if [ $# -ge 6 ]; then
                    hint_text_name+="${hint_text_option}$6文件"
                    if [ $# -ge 7 ]; then
                        hint_text_name+="${hint_text_option}$7文件"
                    fi
                fi
            fi
        fi
    elif [ "$2" = "directory" ]; then
        if [ "$3" = "directory_delete_option" ]; then
            hint_text_append="$(set_color "red")如果选择删除源文件，最终的文件输出为当前路径下所对应文件，上述所创建的文件夹只是作为临时文件夹，会在结束时清除；$(set_color "reset")"
            hint_text_name="「$4」文件夹"
        else
            hint_text_append=""
            hint_text_name="「$3」文件夹"
            if [ $# -ge 4 ]; then
                hint_text_name+="${hint_text_option}「$4」文件夹"
            fi
        fi
        hint_text_path="在"
        hint_text_type="夹"
        hint_text_type_prefix=""
        if [ $# -ge 5 ]; then
            hint_text_name+="${hint_text_option}「$5」文件夹"
            if [ $# -ge 6 ]; then
                hint_text_name+="${hint_text_option}「$6」文件夹"
                if [ $# -ge 7 ]; then
                    hint_text_name+="${hint_text_option}「$7」文件夹"
                    if [ $# -ge 8 ]; then
                        hint_text_name+="${hint_text_option}「$8」文件夹"
                    fi
                fi
            fi
        fi
    fi
    printf "%s" "$(set_color "red" "生成的文件输出${hint_text_path}当前路径下${hint_text_type_prefix}的${hint_text_name}")；${hint_text_append}请先确保路径下没有同名的${hint_text_name}，否则本功能操作将$(set_color "red" "强制删除")同名文件${hint_text_type}并重新生成；如果路径下已有同名的${hint_text_name}，请先自行处理好相关文件再执行该功能"
}

log_start() {
    draw_line_blank "-"
    text_blank "已开始本次的功能操作"
}

log_end() {
    local log_end_append="" text=""
    if [ $# -eq 3 ]; then
        if [[ "$3" =~ (^[1-9][0-9]*$) ]]; then
            log_end_append="\n\n总共删除了$3个源文件"
        else
            text="${3//；/\\n\\t}"
            log_end_append="\n\n${text}"
        fi
    fi
    draw_line_blank "~"
    printf "%b" "已结束本次的功能操作：\n\n总共执行了$1次操作（当前路径检测到$2个可操作文件）${log_end_append}\n\n"
}

log_result() {
    draw_line_blank "-"
    text_blank "当前路径为「${PWD}」"
    local result_text
    if [ $# -eq 1 ]; then
        result_text="$1"
    else
        result_text=$(description_append_note "$@")
    fi
    printf "%b" "$(remove_after_first_delimiter "$result_text" "；")\n"
    # 「cd ~-」回到上一工作路径，和「cd -」效果一样，但不会输出切换后的新路径到标准输出STDOUT中。如果cd失败就结束函数。
    cd ~- || return
    blank_text_normal "当前已切换回上一次的工作路径「${PWD}」"
}

log_file_not_detected() {
    local detected_text
    detected_text="$1文件"
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
    blank_text "由于当前路径并未检测到任何${detected_text}，已退出本次的功能操作"
}

# 使用传入的数组值绘制菜单：使用上下方向键和enter回车键确认选择
# 参数：数组，传入的数组数量最大可为256
# 返回值：返回选项的索引值
ESC=$(printf "\033")
arrow_select_option_cursor_blink_on() {
    printf "%s" "${ESC}[?25h"
}
arrow_select_option_cursor_blink_off() {
    printf "%s" "${ESC}[?25l"
}
arrow_select_option_cursor_to() {
    printf "%s" "${ESC}[$1;${2:-1}H"
}
arrow_select_option_print_option() {
    printf "%s" "     $1"
}
arrow_select_option_print_selected() {
    printf "%s" "     ${ESC}[7m$1${ESC}[27m"
}
arrow_select_option_get_cursor_row() {
    IFS=';' read -sdR -r -p $'\E[6n' ROW COL
    printf "%s" "$(remove_before_first_delimiter "$ROW" "[")"
}
arrow_select_option_key_input() {
    read -s -n3 -r key 2>/dev/null >&2
    if [[ "$key" = "${ESC}[A" ]]; then
        printf up
    fi
    if [[ "$key" = "${ESC}[B" ]]; then
        printf down
    fi
    if [[ "$key" = "" ]]; then
        printf enter
    fi
}
arrow_select_option() {
    # initially print empty new lines (scroll down if at bottom of screen)
    for opt; do printf "\n"; done
    # determine current screen position for overwriting the options
    local lastrow startrow
    lastrow=$(arrow_select_option_get_cursor_row)
    startrow=$((lastrow - $#))
    # ensure cursor and input echoing back on upon a ctrl+c during read -s
    trap "arrow_select_option_cursor_blink_on; stty echo; printf '\n'; exit" 2
    arrow_select_option_cursor_blink_off
    local selected=0
    while true; do
        # print options by overwriting the last lines
        local idx=0
        for opt; do
            arrow_select_option_cursor_to $((startrow + idx))
            if [ $idx -eq $selected ]; then
                arrow_select_option_print_selected "$opt"
            else
                arrow_select_option_print_option "$opt"
            fi
            ((idx++))
        done
        # user key control
        case $(arrow_select_option_key_input) in
        enter) break ;;
        up)
            ((selected--))
            if [ $selected -lt 0 ]; then selected=$(($# - 1)); fi
            ;;
        down)
            ((selected++))
            if [ $selected -ge $# ]; then selected=0; fi
            ;;
        esac
    done
    # cursor position back to normal
    arrow_select_option_cursor_to "$lastrow"
    printf "\n"
    arrow_select_option_cursor_blink_on
    return $selected
}

file_extension_for_loop() {
    local file_extension
    file_extension="*.$(uppercase_to_lowercase "$1") *.$(lowercase_to_uppercase "$1")"
    if [ $# -ge 2 ]; then
        file_extension+=" *.$(uppercase_to_lowercase "$2") *.$(lowercase_to_uppercase "$2")"
        if [ $# -ge 3 ]; then
            file_extension+=" *.$(uppercase_to_lowercase "$3") *.$(lowercase_to_uppercase "$3")"
            if [ $# -ge 4 ]; then
                file_extension+=" *.$(uppercase_to_lowercase "$4") *.$(lowercase_to_uppercase "$4")"
                if [ $# -ge 5 ]; then
                    file_extension+=" *.$(uppercase_to_lowercase "$5") *.$(lowercase_to_uppercase "$5")"
                fi
            fi
        fi
    fi
    printf "%s" "$file_extension"
}

lowercase_file_name_extension() {
    local file="$1"
    printf "%s" "$(get_file_name "$file").$(uppercase_to_lowercase "$(get_file_extension "$file")")"
}

show_progress_bar() {
    local current total bar_size bar_char_done bar_char_todo percent done_num todo_num done_sub_bar todo_sub_bar
    total="$1"
    current="$2"

    bar_size=$(($(tput cols) - 24))
    bar_char_done="#"
    bar_char_todo="-"
    # calculate the progress in percentage
    percent=$(printf "%s" "$current $total" | gawk '{ printf "%.2f", $1 / $2 * 100 }')
    # The number of done and todo characters
    done_num=$(printf "%s" "$bar_size $percent" | gawk '{ printf "%.0f", $1 * $2 / 100 }')
    todo_num=$(printf "%s" "$bar_size $done_num" | gawk '{ printf "%.0f", $1 - $2 }')

    # build the done and todo sub-bars
    done_sub_bar=$(printf "%${done_num}s" | tr " " "${bar_char_done}")
    todo_sub_bar=$(printf "%${todo_num}s" | tr " " "${bar_char_todo}")

    # output the bar
    printf "%b" "\r当前处理进度：[${done_sub_bar}${todo_sub_bar}] ${percent}%"

    if [ "$total" -eq "$current" ]; then
        printf "\n\n"
    fi
}

calc_last_letter_length() {
    local last_char unit_length copy_str str_len
    copy_str="$1"
    unit_length=0
    str_len=$(get_string_length "$1")
    for ((i = 1; i <= str_len; i++)); do
        last_char=$(get_last_char "$copy_str")
        if [[ "$last_char" =~ ([0-9]|\.) ]]; then
            break
        fi
        copy_str=$(remove_last_char "$copy_str")
        ((unit_length++))
    done
    printf "%d" "$unit_length"
}

remove_last_zero() {
    local last_char copy_str str_len
    copy_str="$1"
    str_len=$(get_string_length "$1")
    for ((i = 1; i <= str_len; i++)); do
        last_char=$(get_last_char "$copy_str")
        if [[ "$last_char" =~ (0|\.) ]]; then
            copy_str=$(remove_last_char "$copy_str")
            # 一旦检测到小数点，移除后便终止删除0
            if [ "$last_char" = "." ]; then
                break
            fi
        else
            break
        fi
    done
    printf "%s" "$copy_str"
}

remove_first_zero() {
    local first_char second_char copy_str str_len
    copy_str="$1"
    str_len=$(get_string_length "$1")
    # i+1：当copy_str实际缩减到second_char不存在时则终止
    for ((i = 0; i + 1 < str_len; i++)); do
        first_char=$(get_first_char "$copy_str")
        second_char=$(get_any_char "$copy_str" "1" "1")
        if [ "$first_char" = "0" ] && [ "$second_char" != "." ]; then
            copy_str=$(remove_first_char "$copy_str")
        else
            break
        fi
    done
    printf "%s" "$copy_str"
}
