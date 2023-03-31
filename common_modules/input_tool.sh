#!/bin/bash

# 函数: input_bool，处理用户的布尔值输入，需要输入三个参数
# 参数1：提示用户输入的信息，如「是否删除源文件」
# 参数2：提示默认值的信息，如「默认删除源文件」
# 参数3：设置默认值，只接受两个值，true和false
input_bool() {
    draw_line_echo "-" >&2
    local user_input user_input_hint user_input_default_value_hint user_input_range_hint
    local bool_value
    user_input_default_value_hint="$2"
    user_input_hint="$1（$user_input_default_value_hint）："
    user_input_range_hint="允许输入「是/否/1/0/yes/no/y/n」，不区分大小写"
    text_echo "提示：输入00并回车，则返回菜单" >&2
    text_echo "提示：不输入（等待30s）或直接回车，则$user_input_default_value_hint（$user_input_range_hint）" >&2
    if read -e -t 30 -r -p "$user_input_hint" user_input; then
        while ! [[ "$user_input" =~ (^$|^00$|^[01]$|^[YyNn]$|^[Yy][Ee][Ss]$|^[Nn][Oo]$) ]] && [ "$user_input" != "是" ] && [ "$user_input" != "否" ]; do
            echo_text_echo_normal "当前输入错误，请重新输入。$user_input_range_hint。" >&2
            if ! read -e -t 30 -r -p "$user_input_hint" user_input; then
                echo >&2
                bool_value="$3"
            fi
        done
        if [ "$user_input" = "00" ]; then
            return 10
        fi
        local regular_expr_true regular_expr_false
        if [ "$3" = true ]; then
            regular_expr_true="(^$|^1$|^[Yy]$|^[Yy][Ee][Ss]$)"
            regular_expr_false="(^0$|^[Nn]$|^[Nn][Oo]$)"
        elif [ "$3" = false ]; then
            regular_expr_true="(^1$|^[Yy]$|^[Yy][Ee][Ss]$)"
            regular_expr_false="(^$|^0$|^[Nn]$|^[Nn][Oo]$)"
        fi
        if [ "$user_input" = "是" ] || [[ "$user_input" =~ $regular_expr_true ]]; then
            bool_value=true
        elif [ "$user_input" = "否" ] || [[ "$user_input" =~ $regular_expr_false ]]; then
            bool_value=false
        fi
    else
        echo >&2
        bool_value="$3"
    fi
    echo >&2
    echo "$bool_value"
}

# 函数: input_number，处理用户的数值输入，需要输入五个参数
# 参数1：提示用户输入的信息，如「请输入压制视频的crf值」
# 参数2：提示默认值的信息，如「默认crf值为28」
# 参数3：提示可输入值的信息，如「允许输入范围「0-51」」
# 参数4：设置默认值，如「28」
# 参数5：设置限制输入格式的正则表达式，需用圆括号括住，如「(^$|^[0-9]$|^[1-4][0-9]$|^5[0-1]$)」——该正则只允许输入：单回车键（不输入数字，直接回车）和数字范围0-51。
input_number() {
    draw_line_echo "-" >&2
    local user_input user_input_hint user_input_default_value_hint user_input_range_hint
    local number_value
    user_input_default_value_hint="$2"
    user_input_hint="$1（$user_input_default_value_hint）："
    user_input_range_hint="$3"
    text_echo "提示：输入00并回车，则返回菜单" >&2
    text_echo "提示：不输入（等待30s）或直接回车，则$user_input_default_value_hint（$user_input_range_hint）" >&2
    if read -e -t 30 -r -p "$user_input_hint" user_input; then
        while ! [[ "$user_input" =~ $5 ]]; do # 传递正则表达式参数，不用加双引号
            echo_text_echo_normal "当前输入错误，请重新输入。$user_input_range_hint。" >&2
            if ! read -e -t 30 -r -p "$user_input_hint" user_input; then
                echo >&2
                number_value="$4"
            fi
        done
        if [ "$user_input" = "00" ]; then
            return 10
        fi
        if [[ "$user_input" =~ ^$ ]]; then
            number_value="$4"
        else
            number_value="$user_input"
        fi
    else
        echo >&2
        number_value="$4"
    fi
    echo >&2
    echo "$number_value"
}

# 函数: input_string，处理用户的字符串输入，需要输入六个参数
# 参数1：提示用户输入的信息，如「请输入压制视频的preset值」
# 参数2：提示默认值的信息，如「默认preset值为medium」
# 参数3：提示可输入值的信息，如「允许输入「ultrafast, superfast, veryfast, faster, fast, medium, slow, slower, veryslow, placebo」，要求全部小写或者全部大写」
# 参数4：设置默认值，如「medium」
# 参数5：设置可输入的字符串数组（需要以字符串形式传递给函数，否则函数的参数会剧增），格式要求每个单词相隔一个空格，如「ultrafast superfast veryfast faster fast medium slow slower veryslow placebo」，无需定义大写词组，程序会自动处理
# 参数6：设置限制输入格式的正则表达式，需用圆括号括住，如「(^$|^[a-zA-Z]{4,9}$)」——该正则只允许输入：单回车键（不输入数字，直接回车）和4-9位的英文字母（不限大小写）。
input_string() {
    draw_line_echo "-" >&2
    local user_input user_input_hint user_input_default_value_hint user_input_range_hint
    local string_value
    local input_string uppercase_input
    input_string="$5"
    uppercase_input=$(lowercase_to_uppercase "$5")
    input_string="${input_string} ${uppercase_input}"
    local string_to_array=($input_string) # 使用圆括号重新定义变回数组，不能加双引号，否则定义失败导致仍是字符串
    local found_flag=0
    user_input_default_value_hint="$2"
    user_input_hint="$1（$user_input_default_value_hint）："
    user_input_range_hint="$3"
    text_echo "提示：输入00并回车，则返回菜单" >&2
    text_echo "提示：不输入（等待30s）或直接回车，则$user_input_default_value_hint（$user_input_range_hint）" >&2
    if read -e -t 30 -r -p "$user_input_hint" user_input; then
        while ! [ $found_flag -eq 1 ] || ! [[ "$user_input" =~ $6 ]]; do
            if [[ "$user_input" =~ ^$ ]]; then
                string_value="$4"
                break
            else
                for i in "${string_to_array[@]}"; do
                    if [ "$i" == "$user_input" ]; then
                        string_value=$(uppercase_to_lowercase "$user_input")
                        found_flag=1
                        break 2
                    fi
                done
                echo_text_echo_normal "当前输入错误，请重新输入。$user_input_range_hint。" >&2
                if ! read -e -t 30 -r -p "$user_input_hint" user_input; then
                    echo >&2
                    string_value="$4"
                fi
            fi
        done
        if [ "$user_input" = "00" ]; then
            return 10
        fi
    else
        echo >&2
        string_value="$4"
    fi
    echo >&2
    echo "$string_value"
}

# 函数: input_anything，处理用户的任意输入，需要输入一个参数
# 参数1：提示用户输入的信息，如「请输入压制视频的crf值」
input_anything() {
    draw_line_echo "-" >&2
    local user_input user_input_hint
    local anthing_value
    user_input_hint="$1："
    text_echo "提示：输入00并回车，则返回菜单" >&2
    read -e -r -p "$user_input_hint" user_input
    while [[ "$user_input" =~ (^$) ]]; do # 传递正则表达式参数，不用加双引号
        echo_text_echo_normal "当前输入为空，请重新输入。$user_input_range_hint。" >&2
        read -e -r -p "$user_input_hint" user_input
    done
    if [ "$user_input" = "00" ]; then
        return 10
    fi
    anthing_value="$user_input"
    echo >&2
    echo "$anthing_value"
}
