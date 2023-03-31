#!/bin/bash

process_filter_type() {
    local extension
    extension=$(uppercase_to_lowercase "$(get_file_extension "$1")")
    if [ "$extension" = "ass" ]; then
        echo "ass"
    elif [ "$extension" = "srt" ]; then
        echo "subtitles"
    fi
}

personal_work_add_subtitle() {
    local output_path="personal_work_add_subtitle"
    local feature_name feature_intro feature_note
    feature_name="添加字幕（硬编码，libx264）"
    feature_intro="给路径下的mp4文件或者flv文件或者mov文件添加字幕$(description_append_intro "手动选择视频文件（有多个视频文件）；手动选择字幕文件（有多个字幕文件且无视频同名的字幕文件）；设置压制视频的crf值；设置压制视频的最大码率；设置压制视频的preset值；是否添加版权文字水印")"
    feature_note="$(set_color "blue")字幕文件要求为ass格式或者srt格式；$(set_color "reset")$(description_append_note "option_false" "directory" "$output_path")"
    description "$feature_name" "$feature_intro" "$feature_note"
    change_directory
    if [ $? -eq 10 ]; then
        return 20
    fi

    local video_count mp4_count flv_count mov_count subtitle_count ass_count srt_count
    mp4_count=$(file_count "mp4")
    flv_count=$(file_count "flv")
    mov_count=$(file_count "mov")
    video_count=$(("$mp4_count" + "$flv_count" + "$mov_count"))
    ass_count=$(file_count "ass")
    srt_count=$(file_count "srt")
    subtitle_count=$(("$ass_count" + "$srt_count"))
    if [ "$video_count" -eq 0 ] || [ "$subtitle_count" -eq 0 ]; then
        if [ "$video_count" -eq 0 ]; then
            log_file_not_detected "mp4" "flv" "mov"
            return 0
        fi
        if [ "$subtitle_count" -eq 0 ]; then
            log_file_not_detected "ass" "srt"
            return 0
        fi
    fi

    local video_crf
    video_crf=$(input_number "请输入压制视频的crf值" "默认crf值为18" "允许输入范围「0-51」，x264编码器默认23" "18" "(^$|^00$|^[0-9]$|^[1-4][0-9]$|^5[0-1]$)")
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
        video_max_bitrate_unit="k"
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
    video_bufsize_number=$(echo $video_max_bitrate_number | gawk '{ printf "%.2f", $1 * 2 }')
    video_bufsize_number=$(remove_last_zero "$video_bufsize_number")
    video_bufsize="${video_bufsize_number}${video_max_bitrate_unit}"

    local video_preset video_preset_array_to_string
    video_preset_array_to_string="ultrafast superfast veryfast faster fast medium slow slower veryslow placebo"
    video_preset=$(input_string "请输入压制视频的preset值" "默认preset值为slow" "允许输入「ultrafast, superfast, veryfast, faster, fast, medium, slow, slower, veryslow, placebo」，要求全部小写或者全部大写，x264编码器默认medium" "slow" "$video_preset_array_to_string" "(^$|^00$|^[a-zA-Z]{4,9}$)")
    if [ $? -eq 10 ]; then
        return 20
    fi

    local watermark_flag
    watermark_flag=$(input_bool "是否添加版权文字水印" "默认否「即不默认添加版权文字水印」" "false")
    if [ $? -eq 10 ]; then
        return 20
    fi

    draw_line_echo "-"
    text_echo "当前已设置压制视频的crf值为「$video_crf」，设置压制视频的最大码率为「$video_max_bitrate」，设置压制视频的码率控制缓冲区大小为「$video_bufsize」，设置压制视频的preset值为「$video_preset」，设置添加版权文字水印为「$watermark_flag」"

    shopt -s nullglob

    local input_video
    if [ "$video_count" -eq 1 ]; then
        for file in $(file_extension_for_loop "mp4" "flv" "mov"); do
            input_video="$file"
        done
    else
        draw_line_echo "-"
        text_echo "提示：使用上下方向键↑↓选择文件，回车键Enter确认选项"
        text_echo "当前路径下检测到多个视频文件"
        text_echo "现在进入手动选择视频模式，请选择需要添加字幕的视频："
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

    local subtitle_file filter_type
    if [ "$subtitle_count" -eq 1 ]; then
        for file in $(file_extension_for_loop "ass" "srt"); do
            subtitle_file="$file"
            filter_type=$(process_filter_type "$subtitle_file")
        done
    fi
    if [ "$subtitle_count" -gt 1 ]; then
        local video_file_name subtitle_file_name check_name_flag
        for file in $(file_extension_for_loop "ass" "srt"); do
            video_file_name=$(get_file_name "$input_video")
            subtitle_file_name=$(get_file_name "$file")
            if [ "$video_file_name" = "$subtitle_file_name" ]; then
                check_name_flag=true
                subtitle_file="$file"
                filter_type=$(process_filter_type "$subtitle_file")
                break
            else
                check_name_flag=false
            fi
        done
        if [ "$check_name_flag" = false ]; then
            draw_line_echo "~"
            text_echo "提示：使用上下方向键↑↓选择文件，回车键Enter确认选项"
            text_echo "当前路径下检测到多个字幕文件，但未检测到和「$input_video」同名的字幕文件"
            text_echo "现在进入手动选择字幕文件模式，请选择需要添加的字幕文件："
            local -a subtitle_file_array=()
            if [ "$ass_count" -ne 0 ]; then
                subtitle_file_array+=(*.ass)
                subtitle_file_array+=(*.ASS)
            fi
            if [ "$srt_count" -ne 0 ]; then
                subtitle_file_array=(*.srt)
                subtitle_file_array=(*.SRT)
            fi
            subtitle_file_array+=("取消功能操作，返回菜单")
            arrow_select_option "${subtitle_file_array[@]}"
            local choice=$?
            local choice_exit=$((${#subtitle_file_array[@]} - 1))
            if [ $choice -eq $choice_exit ]; then
                return 20
            fi
            subtitle_file="${subtitle_file_array[$choice]}"
            filter_type=$(process_filter_type "$subtitle_file")
        fi
    fi
    shopt -u nullglob

    local watermark_effect filter_effect
    watermark_effect=$(copyright_watermark)

    if [ "$watermark_flag" = false ]; then
        filter_effect="$filter_type='${subtitle_file}', format=yuv420p"
    else
        filter_effect="${watermark_effect}[watermark_effect]; [watermark_effect] $filter_type='${subtitle_file}', format=yuv420p"
    fi

    log_start
    make_directory "$output_path"
    local operation_count=0
    draw_line_echo "~"
    show_progress_bar "1" "$operation_count"
    ffmpeg_no_banner -i "$input_video" -c:v libx264 -crf:v "$video_crf" -preset:v "$video_preset" -maxrate:v "$video_max_bitrate" -bufsize:v "$video_bufsize" -vf "$filter_effect" -c:a copy "$output_path/$(lowercase_file_name_extension "$input_video")"
    ((operation_count++))
    show_progress_bar "1" "$operation_count"
    log_end "$operation_count" "$video_count"
    log_result "option_false" "directory" "$output_path"
}
