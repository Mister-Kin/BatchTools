#!/bin/bash

# 右起计算第一个非数字的位置
calc_non_numeric_index() {
    local last_char copy_str str_len non_numeric_idx=0
    copy_str="$1"
    str_len=$(get_string_length "$1")
    for ((i = str_len; i > 0; i--)); do
        last_char=$(get_last_char "$copy_str")
        if [[ "$last_char" =~ [0-9] ]]; then
            copy_str=$(remove_last_char "$copy_str")
        else
            non_numeric_idx=$i
            break
        fi
    done
    printf "%d" "$non_numeric_idx"
}

# 根据用户输入计算总秒数
# 参数1：用户输入
# 参数2：预设的视频秒数终点
calc_second_time() {
    local result_second=0 hour=0 minute=0 second=0 copy_str str_len
    copy_str="$1"

    if [[ "$1" =~ (^[0-5]?[0-9][Ss]?$|^[0-5]?[0-9][Mm\.][0-5]?[0-9][Ss]?$|^[0-9]+[Hh\.][0-5]?[0-9][Mm\.][0-5]?[0-9][Ss]?$) ]]; then
        local non_numeric_idx
        # 右起计算第一个非数字的位置和字符串长度
        non_numeric_idx=$(calc_non_numeric_index "$copy_str")
        str_len=$(get_string_length "$copy_str")
        # 移除尾缀s
        if [ "$non_numeric_idx" -eq "$str_len" ]; then
            copy_str=$(remove_last_char "$copy_str")
        fi
        # 重新右起计算第一个非数字的位置和字符串长度
        non_numeric_idx=$(calc_non_numeric_index "$copy_str")
        str_len=$(get_string_length "$copy_str")
        # 获取秒钟的数值，此时非数字指针non_numeric_idx的位置刚好是get_any_char函数要截取数字的首位（该函数下标0才是左起第一个。）
        second=$(get_any_char "$copy_str" "$non_numeric_idx" "$((str_len - non_numeric_idx))")
        # 移除秒钟数值首位可能存在0的情况
        second=$(remove_first_zero "$second")
        if [[ "$1" =~ (^[0-5]?[0-9][Mm\.][0-5]?[0-9][Ss]?$|^[0-9]+[Hh\.][0-5]?[0-9][Mm\.][0-5]?[0-9][Ss]?$) ]]; then
            # 截断秒钟数值，表达式+1是包括分钟的分隔符
            copy_str=$(remove_last_any_char "$copy_str" "$((str_len - non_numeric_idx + 1))")
            # 重新右起计算第一个非数字的位置和字符串长度
            non_numeric_idx=$(calc_non_numeric_index "$copy_str")
            str_len=$(get_string_length "$copy_str")
            minute=$(get_any_char "$copy_str" "$non_numeric_idx" "$((str_len - non_numeric_idx))")
            minute=$(remove_first_zero "$minute")
            if [[ "$1" =~ ^[0-9]+[Hh\.][0-5]?[0-9][Mm\.][0-5]?[0-9][Ss]?$ ]]; then
                copy_str=$(remove_last_any_char "$copy_str" "$((str_len - non_numeric_idx + 1))")
                non_numeric_idx=$(calc_non_numeric_index "$copy_str")
                str_len=$(get_string_length "$copy_str")
                hour=$(get_any_char "$copy_str" "$non_numeric_idx" "$((str_len - non_numeric_idx))")
                hour=$(remove_first_zero "$hour")
            fi
        fi
        # 计算总秒数
        result_second=$((hour * 60 * 60 + minute * 60 + second))
    elif [[ "$1" =~ ^[Ee][Nn][Dd]$ ]]; then
        result_second="$2"
    fi
    local -a result_array
    result_array+=("$result_second")
    result_array+=("$hour")
    result_array+=("$minute")
    result_array+=("$second")
    printf "%s " "${result_array[@]}" # printf输出数组，相当于多个变量，必须加空格分割开。echo语句则不需要
}

media_split_video() {
    local output_path="media_split_video"
    local feature_name feature_intro feature_note
    feature_name="分割视频"
    feature_intro="将路径下的mp4文件或者flv文件或者mov文件按输入的时间点连续分割为多个视频文件$(description_append_intro "手动选择视频文件（有多个视频文件）；是否精确剪辑时间点；设置压制视频的crf值；设置压制视频的最大码率；设置压制视频的preset值；是否重新编码音频；设置压制音频的码率")"
    feature_note="$(set_color "blue")精确剪辑时间点方案采用重编码（基于libx264，可能有损，可自调参数控制质量）；非精确剪辑时间点方案可实现原版无损切割，但因为没有进行重编码，读取的关键帧依然是原视频的旧编码，切割时间点可能会有些许偏移；$(set_color "reset")$(description_append_note "option_false" "directory" "$output_path")"
    description "$feature_name" "$feature_intro" "$feature_note"
    change_directory
    if [ $? -eq 10 ]; then
        return 20
    fi

    local all_count mp4_count flv_count mov_count
    mp4_count=$(file_count "mp4")
    flv_count=$(file_count "flv")
    mov_count=$(file_count "mov")
    all_count=$((mp4_count + flv_count + mov_count))
    if [ "$all_count" -eq 0 ]; then
        log_file_not_detected "mp4" "flv" "mov"
        return 0
    fi

    shopt -s nullglob
    local input_video input_video_extension
    if [ "$all_count" -eq 1 ]; then
        for file in $(file_extension_for_loop "mp4" "flv" "mov"); do
            input_video="$file"
        done
    else
        draw_line_blank "-"
        text_blank "提示：使用上下方向键↑↓选择文件，回车键Enter确认选项"
        text_blank "当前路径下检测到多个视频文件"
        text_blank "现在进入手动选择视频模式，请选择需要添加字幕的视频："
        local -a video_file_array=()
        if [ "$mp4_count" -ne 0 ]; then
            video_file_array+=(*.mp4)
            video_file_array+=(*.MP4)
        fi
        if [ "$flv_count" -ne 0 ]; then
            video_file_array+=(*.flv)
            video_file_array+=(*.FLV)
        fi
        if [ "$mov_count" -ne 0 ]; then
            video_file_array+=(*.mov)
            video_file_array+=(*.MOV)
        fi
        video_file_array+=("取消功能操作，返回菜单")
        arrow_select_option "${video_file_array[@]}"
        local choice=$?
        local choice_exit=$((${#video_file_array[@]} - 1))
        if [ $choice -eq $choice_exit ]; then
            return 20
        fi
        input_video="${video_file_array[$choice]}"
    fi
    input_video_extension="$(uppercase_to_lowercase "$(get_file_extension "$input_video")")"
    shopt -u nullglob

    local accurate_clip_time
    accurate_clip_time=$(input_bool "是否精确剪辑时间点" "默认是「即采用精确剪辑时间点方案」" "true")
    if [ $? -eq 10 ]; then
        return 20
    fi

    if [ "$accurate_clip_time" = true ]; then
        local video_crf
        video_crf=$(input_number "请输入压制视频的crf值" "默认crf值为23" "允许输入范围「0-51」，x264编码器默认23" "23" "(^$|^00$|^[0-9]$|^[1-4][0-9]$|^5[0-1]$)")
        if [ $? -eq 10 ]; then
            return 20
        fi

        local video_max_bitrate
        video_max_bitrate=$(input_number "请输入压制视频的最大码率" "默认最大码率值缺省为0" "允许输入格式为「数字+单位」，单位缺省时默认为kbit/s，数字允许带小数点（精度限制两位小数），单位可为[k/K/M/G][i][B]，例如300kib、1.5MB等（k为10^3——国际单位制SI，ki为2^10——国际电工委员会IEC，k和K二者含义一样，B=8bit），x264编码器默认0" "0" "(^$|^00$|^[0-9]+\.?[0-9]{0,2}[kKMG]?i?[B]?$)")
        if [ $? -eq 10 ]; then
            return 20
        fi
        local unit_length
        unit_length=$(calc_last_letter_length "$video_max_bitrate")
        local video_max_bitrate_unit video_max_bitrate_number video_bufsize_number video_bufsize
        if [ "$unit_length" -ne 0 ]; then
            video_max_bitrate_unit=$(get_last_any_char "$video_max_bitrate" "$unit_length")
            video_max_bitrate_number=$(remove_last_any_char "$video_max_bitrate" "$unit_length")
        else
            if [ "$video_max_bitrate" -eq 0 ]; then
                video_max_bitrate_unit=""
            else
                video_max_bitrate_unit="k"
            fi
            video_max_bitrate_number="$video_max_bitrate"
        fi
        local last_char
        last_char=$(get_last_char "$video_max_bitrate_number")
        if [ "$last_char" = "." ]; then
            video_max_bitrate_number=$(remove_last_char "$video_max_bitrate_number")
        fi
        video_max_bitrate_number=$(printf "%.2f" "$video_max_bitrate_number")
        video_max_bitrate_number=$(remove_last_zero "$video_max_bitrate_number")
        video_max_bitrate="${video_max_bitrate_number}${video_max_bitrate_unit}"
        video_bufsize_number=$(printf "%s" "$video_max_bitrate_number" | gawk '{ printf "%.2f", $1 * 2 }')
        video_bufsize_number=$(remove_last_zero "$video_bufsize_number")
        video_bufsize="${video_bufsize_number}${video_max_bitrate_unit}"

        local video_preset video_preset_array_to_string
        video_preset_array_to_string="ultrafast superfast veryfast faster fast medium slow slower veryslow placebo"
        video_preset=$(input_string "请输入压制视频的preset值" "默认preset值为slow" "允许输入「ultrafast, superfast, veryfast, faster, fast, medium, slow, slower, veryslow, placebo」，要求全部小写或者全部大写，x264编码器默认medium" "slow" "$video_preset_array_to_string" "(^$|^00$|^[a-zA-Z]{4,9}$)")
        if [ $? -eq 10 ]; then
            return 20
        fi

        local encode_audio_flag
        encode_audio_flag=$(input_bool "是否重新编码音频" "默认否「即默认不重新编码音频」" "false")
        if [ $? -eq 10 ]; then
            return 20
        fi

        local audio_bitrate
        if [ "$encode_audio_flag" = true ]; then
            audio_bitrate=$(input_number "请输入压制音频的码率" "默认码率为128k" "允许输入「16/32/64/96/128/192/256/320」，程序会自动设置单位为k" "128" "(^$|^00$|^16$|^32$|^64$|^96$|^128$|^192$|^256$|^320$)")
            if [ $? -eq 10 ]; then
                return 20
            fi
            audio_bitrate="${audio_bitrate}k"
        fi

        draw_line_blank "-"
        if [ "$encode_audio_flag" = true ]; then
            text_blank "当前已设置精确剪辑时间点为「${accurate_clip_time}」，设置压制视频的crf值为「${video_crf}」，设置压制视频的最大码率为「${video_max_bitrate}」，设置压制视频的码率控制缓冲区大小为「${video_bufsize}」，设置压制视频的preset值为「${video_preset}」，设置重新编码音频为「${encode_audio_flag}」，设置压制音频的码率为「${audio_bitrate}」"
        else
            text_blank "当前已设置精确剪辑时间点为「${accurate_clip_time}」，设置压制视频的crf值为「${video_crf}」，设置压制视频的最大码率为「${video_max_bitrate}」，设置压制视频的码率控制缓冲区大小为「${video_bufsize}」，设置压制视频的preset值为「${video_preset}」，设置重新编码音频为「${encode_audio_flag}」"
        fi
    else
        draw_line_blank "-"
        text_blank "当前已设置精确剪辑时间点为「${accurate_clip_time}」"
    fi

    local original_duration_second_total original_duration_time_total duration_second_total duration_time_total
    original_duration_second_total=$(get_media_info "$input_video" "format=duration")
    original_duration_time_total=$(get_media_info_for_time "$input_video" "format=duration")
    duration_second_total=$(remove_last_any_char "$original_duration_second_total" "3") # 删除三个小数（ffprobe输出6位小数）
    duration_time_total=$(remove_last_any_char "$original_duration_time_total" "3")
    # 处理小时，分钟，秒数
    local duration_hour duration_minute duration_second
    duration_hour=$(remove_after_first_delimiter "$duration_time_total" ":")
    local duration_time_min_sec
    duration_time_min_sec=$(remove_before_first_delimiter "$duration_time_total" ":")
    duration_minute=$(remove_after_first_delimiter "$duration_time_min_sec" ":")
    duration_second=$(remove_before_last_delimiter "$duration_time_total" ":")
    # 移除分钟和秒数首位可能存在0的情况
    duration_minute=$(remove_first_zero "$duration_minute")
    duration_second=$(remove_first_zero "$duration_second")
    local duration_time_total_text=""
    if [ "$duration_hour" -ne 0 ]; then
        duration_time_total_text+="${duration_hour}小时"
    fi
    if [ "$duration_minute" -ne 0 ]; then
        duration_time_total_text+="${duration_minute}分"
    fi
    duration_time_total_text+="${duration_second}秒"
    draw_line_blank "-"
    text_blank "当前选择的「${input_video}」："
    text_blank "视频总时长为${duration_time_total_text}"
    text_blank "视频时长总秒数为${duration_second_total}秒"

    log_start
    make_directory "$output_path"
    local operation_count=0

    # 总秒数转换成整数
    local duration_second_total_int
    duration_second_total_int=$(remove_after_last_delimiter "$duration_second_total" ".")
    local clip_start_time=0 clip_end_time=0 clip_duration=0 clip_start_time_text="0s" clip_end_time_text=""
    local user_input_time
    local -a get_time
    local get_time_hour get_time_minute get_time_second
    while [ "$clip_end_time" -lt "$duration_second_total_int" ]; do
        draw_line_blank "~"
        text_blank "当前已设置剪辑起始时间点为「${clip_start_time_text}」"
        user_input_time=$(input_number_waiting_user "请输入下一个时间点" "允许输入格式为「小时[分隔符]分钟[分隔符]秒钟[分隔符]」，注意分钟和秒钟数值限制为六十进制。分隔符可为「小数点.或者字母hms（字母不区分大小写）」，秒钟后面的分隔符只能为字母s（此项可有可无）。例如1小时10分5秒，这些例子均满足要求「1.10.5」「1H10m5s」「1.10M5s」「1h10.5」。输入「end」或者「大于视频总时长的时间点」即代表视频末尾处（字母不区分大小写）。若分隔符包含时钟分隔符和分钟分隔符，则要求小时、分钟、秒钟都必须输入数值。若分隔符只有分钟分隔符，则要求分钟、秒钟都必须输入数值。若无分隔符，则只要求输入秒钟" "(^00$|^[0-5]?[0-9][Ss]?$|^[0-5]?[0-9][Mm\.][0-5]?[0-9][Ss]?$|^[0-9]+[Hh\.][0-5]?[0-9][Mm\.][0-5]?[0-9][Ss]?$|^[Ee][Nn][Dd]$)")
        if [ $? -eq 10 ]; then
            return 20
        fi

        get_time=($(calc_second_time "$user_input_time" "$duration_second_total_int"))
        while [ "${get_time[0]}" -le "$clip_start_time" ]; do
            draw_line_blank "~"
            text_blank "$(set_color "red")当前输入的时间点小于或等于剪辑起始时间点，请重新输入一个大于剪辑起始时间点的时间点：$(set_color "reset")"
            text_blank "当前已设置剪辑起始时间点为「${clip_start_time_text}」"
            user_input_time=$(input_number_waiting_user "请输入下一个时间点" "允许输入格式为「小时[分隔符]分钟[分隔符]秒钟[分隔符]」，注意分钟和秒钟数值限制为六十进制。分隔符可为「小数点.或者字母hms（字母不区分大小写）」，秒钟后面的分隔符只能为字母s（此项可有可无）。例如1小时10分5秒，这些例子均满足要求「1.10.5」「1H10m5s」「1.10M5s」「1h10.5」。输入「end」或者「大于视频总时长的时间点」即代表视频末尾处（字母不区分大小写）。若分隔符包含时钟分隔符和分钟分隔符，则要求小时、分钟、秒钟都必须输入数值。若分隔符只有分钟分隔符，则要求分钟、秒钟都必须输入数值。若无分隔符，则只要求输入秒钟" "(^00$|^[0-5]?[0-9][Ss]?$|^[0-5]?[0-9][Mm\.][0-5]?[0-9][Ss]?$|^[0-9]+[Hh\.][0-5]?[0-9][Mm\.][0-5]?[0-9][Ss]?$|^[Ee][Nn][Dd]$)")
            if [ $? -eq 10 ]; then
                return 20
            fi
            get_time=($(calc_second_time "$user_input_time" "$duration_second_total_int"))
        done

        # 设置剪辑终止时间点文本
        get_time_hour="${get_time[1]}"
        get_time_minute="${get_time[2]}"
        get_time_second="${get_time[3]}"
        # 清空剪辑终止时间点文本，重新使用累加字符串方式赋值
        clip_end_time_text=""
        if [ "$get_time_hour" -ne 0 ]; then
            clip_end_time_text+="${get_time_hour}h"
            clip_end_time_text+="${get_time_minute}m"
        else
            if [ "$get_time_minute" -ne 0 ]; then
                clip_end_time_text+="${get_time_minute}m"
            else
                clip_end_time_text+=""
            fi
        fi
        clip_end_time_text+="${get_time_second}s"

        # 计算并设置剪辑终止时间点的秒数
        clip_end_time="${get_time[0]}"
        if [ "$clip_end_time" -ge "$duration_second_total_int" ]; then
            draw_line_blank "~"
            if [ "$clip_end_time" -eq "$duration_second_total_int" ]; then
                text_blank "当前输入的时间点为视频末尾处"
            else
                text_blank "当前输入的时间点已超过视频总时长，本程序已自动将时间点设置为视频末尾处"
            fi
            clip_end_time="$duration_second_total"
            clip_end_time_text="end"
        fi

        if [ "$accurate_clip_time" = true ]; then
            if [ "$encode_audio_flag" = false ]; then
                ffmpeg_no_banner -i "$input_video" -ss "$clip_start_time" -to "$clip_end_time" -c:v libx264 -crf:v "$video_crf" -preset:v "$video_preset" -maxrate:v "$video_max_bitrate" -bufsize:v "$video_bufsize" -vf "format=yuv420p" -c:a copy -bsf:v filter_units=remove_types=6 "${output_path}/${clip_start_time_text} - ${clip_end_time_text}.${input_video_extension}"
                ((operation_count++))
            else
                ffmpeg_no_banner -i "$input_video" -ss "$clip_start_time" -to "$clip_end_time" -c:v libx264 -crf:v "$video_crf" -preset:v "$video_preset" -maxrate:v "$video_max_bitrate" -bufsize:v "$video_bufsize" -vf "format=yuv420p" -c:a libfdk_aac -b:a "$audio_bitrate" -bsf:v filter_units=remove_types=6 "${output_path}/${clip_start_time_text} - ${clip_end_time_text}.${input_video_extension}"
                ((operation_count++))
            fi
        else
            ffmpeg_no_banner -i "$input_video" -ss "$clip_start_time" -to "$clip_end_time" -c copy "${output_path}/${clip_start_time_text} - ${clip_end_time_text}.${input_video_extension}"
            ((operation_count++))
        fi

        if [ "$clip_end_time" = "$duration_second_total" ]; then
            clip_duration=$(printf "%s" "$clip_start_time $clip_end_time" | gawk '{ printf "%.3f", $2 - $1 }')
        else
            clip_duration=$((clip_end_time - clip_start_time))
        fi

        draw_line_blank "~"
        text_blank "当前剪切${clip_duration}秒视频，已在「${output_path}」文件夹中输出文件「${clip_start_time_text} - ${clip_end_time_text}.${input_video_extension}」"

        # 剪辑终止时间点若等于视频总时长终点，则转换为整数，避免循环条件中的test比较数值时出错
        if [ "$clip_end_time" = "$duration_second_total" ]; then
            clip_end_time="$duration_second_total_int"
        fi

        # 设置剪辑起始时间点和文本
        clip_start_time="$clip_end_time"
        clip_start_time_text="$clip_end_time_text"
    done

    log_end "$operation_count" "$all_count" "视频总时长为${duration_time_total_text}；视频时长总秒数为${duration_second_total}秒；总共执行了${operation_count}次分割操作"
    log_result "option_false" "directory" "$output_path"
}
