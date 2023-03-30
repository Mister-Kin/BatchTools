#!/bin/bash

# 风格编程统一原则：涉及分割线的，全部先draw_line，每个函数尾部且必须添加空行。

draw_line() {
    printf %"$(tput cols)"s | tr " " "$1"
}

echo_draw_line() {
    echo
    draw_line "$1"
}

draw_line_echo() {
    draw_line "$1"
    echo -e "\n"
}

echo_draw_line_echo() {
    echo
    draw_line "$1"
    echo -e "\n"
}

echo_text() {
    echo -e "\n"
    echo "$1"
}

echo_text_normal() {
    echo
    echo "$1"
}

text_echo() {
    echo "$1"
    echo
}

echo_text_echo() {
    echo -e "\n"
    echo "$1"
    echo
}

echo_text_echo_normal() {
    echo
    echo "$1"
    echo
}

set_color() {
    case "$1" in
    "black")
        echo -n "$(tput setaf 0)"
        ;;
    "red")
        echo -n "$(tput setaf 1)"
        ;;
    "green")
        echo -n "$(tput setaf 2)"
        ;;
    "yellow")
        echo -n "$(tput setaf 3)"
        ;;
    "blue")
        echo -n "$(tput setaf 4)"
        ;;
    "magenta")
        echo -n "$(tput setaf 5)"
        ;;
    "cyan")
        echo -n "$(tput setaf 6)"
        ;;
    "white")
        echo -n "$(tput setaf 7)"
        ;;
    "reset")
        echo -n "$(tput sgr0)"
        return 0
        ;;
    esac
    if [ $# -eq 2 ]; then
        echo -n "$2$(tput sgr0)"
    fi
}

lowercase_to_uppercase() {
    echo "$1" | tr '[:lower:]' '[:upper:]'
}

uppercase_to_lowercase() {
    echo "$1" | tr '[:upper:]' '[:lower:]'
}

description() {
    echo_draw_line_echo "="
    text_echo "功能名称：$1"
    local text
    text="${2//；/\\n\\t}"
    echo -e "功能介绍：$text"
    echo
    if [ $# -eq 3 ]; then
        text="${3//；/\\n\\t}"
        echo -e "注意事项：$text"
        echo
    fi
}

description_append_intro() {
    echo -e -n "\n\n功能参数：$(set_color "blue")$1$(set_color "reset")"
}

# 函数: description_append_note，补充description函数的注意事项小节
# 参数1：如果结果不确定，如可能输出在这个文件夹或者其他文件夹中。确定结果：option_false；不确定结果：eoption_true
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
            hint_text_name+="$hint_text_option$4文件"
            if [ $# -ge 5 ]; then
                hint_text_name+="$hint_text_option$5文件"
                if [ $# -ge 6 ]; then
                    hint_text_name+="$hint_text_option$6文件"
                    if [ $# -ge 7 ]; then
                        hint_text_name+="$hint_text_option$7文件"
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
                hint_text_name+="$hint_text_option「$4」文件夹"
            fi
        fi
        hint_text_path="在"
        hint_text_type="夹"
        hint_text_type_prefix=""
        if [ $# -ge 5 ]; then
            hint_text_name+="$hint_text_option「$5」文件夹"
            if [ $# -ge 6 ]; then
                hint_text_name+="$hint_text_option「$6」文件夹"
                if [ $# -ge 7 ]; then
                    hint_text_name+="$hint_text_option「$7」文件夹"
                    if [ $# -ge 8 ]; then
                        hint_text_name+="$hint_text_option「$8」文件夹"
                    fi
                fi
            fi
        fi
    fi
    echo -n "$(set_color "red" "生成的文件输出$hint_text_path当前路径下$hint_text_type_prefix的$hint_text_name")；$hint_text_append请先确保路径下没有同名的$hint_text_name，否则本功能操作将$(set_color "red" "强制删除")同名文件$hint_text_type并重新生成；如果路径下已有同名的$hint_text_name，请先自行处理好相关文件再执行该功能"
}

log_start() {
    draw_line_echo "-"
    text_echo "已开始本次的功能操作"
}

log_end() {
    local log_end_append=""
    if [ $# -eq 3 ]; then
        if [[ "$3" =~ (^[1-9][0-9]*$) ]]; then
            log_end_append="\n\n总共删除了$3个源文件"
        else
            log_end_append="\n\n$3"
        fi
    fi
    draw_line_echo "~"
    echo -e "已结束本次的功能操作：\n\n总共执行了$1次操作（当前路径检测到$2个可操作文件）$log_end_append"
    echo
}

log_result() {
    draw_line_echo "-"
    local result_text
    if [ $# -eq 1 ]; then
        result_text="$1"
    else
        result_text=$(description_append_note "$@")
    fi
    echo "${result_text%%；*}"
    # 「cd ~-」回到上一工作路径，和「cd -」效果一样，但不会输出切换后的新路径到标准输出STDOUT中。如果cd失败就结束函数。
    cd ~- || return
    echo_text_normal "当前已切换回上一次的工作路径「$PWD」"
}

log_file_not_detected() {
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

# Renders a text based list of options that can be selected by the
# user using up, down and enter keys and returns the chosen option.
#   Arguments   : list of options, maximum of 256
#                 "opt1" "opt2" ...
#   Return value: selected index (0 for opt1, 1 for opt2 ...)
arrow_select_option() {

    # little helpers for terminal print control and key input
    ESC=$(printf "\033")
    cursor_blink_on() { printf "$ESC[?25h"; }
    cursor_blink_off() { printf "$ESC[?25l"; }
    cursor_to() { printf "$ESC[$1;${2:-1}H"; }
    print_option() { printf "     $1"; }
    print_selected() { printf "     $ESC[7m$1$ESC[27m"; }
    get_cursor_row() {
        IFS=';' read -sdR -p $'\E[6n' ROW COL
        echo ${ROW#*[}
    }
    key_input() {
        read -s -n3 key 2>/dev/null >&2
        if [[ $key = $ESC[A ]]; then echo up; fi
        if [[ $key = $ESC[B ]]; then echo down; fi
        if [[ $key = "" ]]; then echo enter; fi
    }

    # initially print empty new lines (scroll down if at bottom of screen)
    for opt; do printf "\n"; done

    # determine current screen position for overwriting the options
    local lastrow=$(get_cursor_row)
    local startrow=$(($lastrow - $#))

    # ensure cursor and input echoing back on upon a ctrl+c during read -s
    trap "cursor_blink_on; stty echo; printf '\n'; exit" 2
    cursor_blink_off

    local selected=0
    while true; do
        # print options by overwriting the last lines
        local idx=0
        for opt; do
            cursor_to $(($startrow + $idx))
            if [ $idx -eq $selected ]; then
                print_selected "$opt"
            else
                print_option "$opt"
            fi
            ((idx++))
        done

        # user key control
        case $(key_input) in
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
    cursor_to $lastrow
    printf "\n"
    cursor_blink_on

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
    echo "$file_extension"
}

# 获取最后一个字符
get_last_char() {
    echo "${1: -1}"
}

# 删除最后一个字符
remove_last_char() {
    echo "${1::-1}"
}

# 删除最后任意个字符
remove_last_any_char() {
    echo "${1::-$2}"
}

get_string_length() {
    echo "${#1}"
}

remove_after_first_delimiter() {
    echo "${1%%$2*}"
}

remove_after_last_delimiter() {
    echo "${1%$2*}"
}

remove_before_first_delimiter() {
    echo "${1#*$2}"
}

remove_before_last_delimiter() {
    echo "${1##*$2}"
}

get_file_name() {
    echo "$(remove_after_last_delimiter "$1" ".")"
}

get_file_extension() {
    echo "$(remove_before_last_delimiter "$1" ".")"
}

lowercase_file_name_extension() {
    local file="$1"
    echo "$(get_file_name "$file").$(uppercase_to_lowercase "$(get_file_extension "$file")")"
}

show_progress_bar() {
    local current total bar_size bar_char_done bar_char_todo percent done_num todo_num done_sub_bar todo_sub_bar
    total="$1"
    current="$2"

    bar_size=$(($(tput cols) - 25))
    bar_char_done="#"
    bar_char_todo="-"
    # calculate the progress in percentage
    percent=$(echo $current $total | gawk '{ printf "%.2f", $1 / $2 * 100 }')
    # The number of done and todo characters
    done_num=$(echo $bar_size $percent | gawk '{ printf "%.0f", $1 * $2 / 100 }')
    todo_num=$(echo $bar_size $done_num | gawk '{ printf "%.0f", $1 - $2 }')

    # build the done and todo sub-bars
    done_sub_bar=$(printf "%${done_num}s" | tr " " "${bar_char_done}")
    todo_sub_bar=$(printf "%${todo_num}s" | tr " " "${bar_char_todo}")

    # output the bar
    echo -ne "\r当前处理进度：[${done_sub_bar}${todo_sub_bar}] ${percent}%"

    if [ $total -eq $current ]; then
        echo -e "\n"
    fi
}
