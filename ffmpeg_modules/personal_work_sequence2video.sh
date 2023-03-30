#!/bin/bash

process_image_sequence() {
    local image_sequence_flag file_name_for_ffmpeg remove_num file_name_length
    local -a result
    remove_num=$(($(get_string_length "$1") + 1))
    for file in $(file_extension_for_loop "$1"); do
        file_name=$(remove_last_any_char "$file" "$remove_num")
        if [[ "$file_name" =~ ^[0-9]+$ ]]; then
            image_sequence_flag=true
            file_name_length=$(get_string_length "$file_name")
            text_echo "当前检测到$1图片序列，文件名长度为$file_name_length，文件数量为$2" >&2
        else
            image_sequence_flag=false
            text_echo "当前检测到$2个$1文件，但不符合图片序列命名要求，已退出本次的功能操作" >&2
        fi
        break
    done
    file_name_for_ffmpeg="%0${file_name_length}d.$1"
    result+=("$image_sequence_flag")
    result+=("$file_name_for_ffmpeg")
    echo "${result[@]}"
}

personal_work_sequence2video() {
    local feature_name feature_intro feature_note
    feature_name="图片序列导出mp4格式视频（libx264）"
    feature_intro="将路径下的png图片序列或者jpg图片序列或者jpeg图片序列合成导出mp4格式视频（avc编码，libx264）$(description_append_intro "设置压制视频的帧率；设置压制视频的crf值；设置压制视频的最大码率；设置压制视频的preset值；是否添加版权文字水印")"
    feature_note="$(set_color "blue")图片序列仅支持纯数字的文件名，如0001.png，并且图片序列文件数量不能小于24；$(set_color "reset")$(description_append_note "option_false" "file" "output.mp4")"
    description "$feature_name" "$feature_intro" "$feature_note"
    change_directory
    if [ $? -eq 10 ]; then
        return 20
    fi

    local all_count png_count jpg_count jpeg_count
    png_count=$(file_count "png")
    jpg_count=$(file_count "jpg")
    jpeg_count=$(file_count "jpeg")
    all_count=$(("$png_count" + "$jpg_count" + "$jpeg_count"))

    if [ "$png_count" -lt 24 ] && [ "$jpg_count" -lt 24 ] && [ "$jpeg_count" -lt 24 ]; then
        image_sequence_flag=false
        echo "当前并未检测到png图片序列或者jpg图片序列或者jpeg图片序列，已退出本次的功能操作"
    fi

    local process_result input_file image_sequence_flag
    if [ "$png_count" -ge 24 ]; then
        process_result=($(process_image_sequence "png" "$png_count"))
        image_sequence_flag=${process_result[0]}
        input_file=${process_result[1]}
    elif [ "$jpg_count" -ge 24 ]; then
        process_result=($(process_image_sequence "jpg" "$jpg_count"))
        image_sequence_flag=${process_result[0]}
        input_file=${process_result[1]}
    elif [ "$jpeg_count" -ge 24 ]; then
        process_result=($(process_image_sequence "jpeg" "$jpeg_count"))
        image_sequence_flag=${process_result[0]}
        input_file=${process_result[1]}
    fi

    if [ "$image_sequence_flag" = false ]; then
        return 0
    fi

    local sequence_video_fps
    sequence_video_fps=$(input_number "请输入压制视频的帧率" "默认帧率为24" "允许输入范围「24/25/30/50/60/100/120」" "24" "(^$|^00$|^24$|^25$|^30$|^50$|^60$|^100$|^120$)")
    if [ $? -eq 10 ]; then
        return 20
    fi

    local video_crf
    video_crf=$(input_number "请输入压制视频的crf值" "默认crf值为18" "允许输入范围「0-51」" "18" "(^$|^00$|^[0-9]$|^[1-4][0-9]$|^5[0-1]$)")
    if [ $? -eq 10 ]; then
        return 20
    fi

    local video_max_bitrate
    video_max_bitrate=$(input_number "请输入压制视频的最大码率" "默认最大码率值为20M" "允许输入格式为「数字（允许带小数）+单位（k/K/M）」，例如300k、1.5M等" "20M" "(^$|^00$|^[0-9]+\.?[0-9]*[kKM]$)")
    if [ $? -eq 10 ]; then
        return 20
    fi

    local video_max_bitrate_unit video_max_bitrate_number video_bufsize_number video_bufsize
    video_max_bitrate_unit=$(get_last_char "$video_max_bitrate")
    video_max_bitrate_number=$(remove_last_char "$video_max_bitrate")
    video_bufsize_number=$(echo $video_max_bitrate_number | gawk '{ printf "%.2f", $1 * 2 }')
    video_bufsize="${video_bufsize_number}${video_max_bitrate_unit}"

    local video_preset video_preset_array_to_string
    video_preset_array_to_string="ultrafast superfast veryfast faster fast medium slow slower veryslow placebo ULTRAFAST SUPERFAST VERYFAST FASTER FAST MEDIUM SLOW SLOWER VERYSLOW PLACEBO"
    video_preset=$(input_string "请输入压制视频的preset值" "默认preset值为slow" "允许输入「ultrafast, superfast, veryfast, faster, fast, medium, slow, slower, veryslow, placebo」，要求全部小写或者全部大写" "slow" "$video_preset_array_to_string" "(^$|^00$|^[a-zA-Z]{4,9}$)")
    if [ $? -eq 10 ]; then
        return 20
    fi

    local watermark_flag
    watermark_flag=$(input_bool "是否添加版权文字水印" "默认是「即不默认添加版权文字水印」" "false")
    if [ $? -eq 10 ]; then
        return 20
    fi

    local watermark_effect filter_effect
    watermark_effect=$(copyright_watermark)
    if [ "$watermark_flag" = true ]; then
        filter_effect="${watermark_effect}[watermark_effect]; [watermark_effect] format=yuv420p"
    elif [ "$watermark_flag" = false ]; then
        filter_effect="format=yuv420p"
    fi

    log_start
    detect_and_remove "file" "output.mp4"
    local operation_count=0
    draw_line_echo "~"
    ffmpeg_no_banner -r "$sequence_video_fps" -f image2 -i "$input_file" -r "$sequence_video_fps" -c:v libx264 -crf:v "$video_crf" -preset:v "$video_preset" -profile:v high -maxrate:v "$video_max_bitrate" -bufsize:v "$video_bufsize" -vf "$filter_effect" "output.mp4"
    ((operation_count++))
    show_progress_bar "1" "$operation_count"
    log_end "$operation_count" "$all_count"
    log_result "option_false" "file" "output.mp4"
}
