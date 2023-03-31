#!/bin/bash

personal_work_video_watermark() {
    local output_path="personal_work_video_watermark"
    local feature_name feature_intro feature_note
    feature_name="给视频添加版权文字水印（libx264）"
    feature_intro="给路径下的mp4文件或者flv文件或者mov文件添加文字版权水印$(description_append_intro "设置压制视频的crf值；设置压制视频的最大码率；设置压制视频的preset值")"
    feature_note="$(description_append_note "option_false" "directory" "$output_path")"
    description "$feature_name" "$feature_intro" "$feature_note"
    change_directory
    if [ $? -eq 10 ]; then
        return 20
    fi

    local all_count mp4_count flv_count mov_count
    mp4_count=$(file_count "mp4")
    flv_count=$(file_count "flv")
    mov_count=$(file_count "mov")
    all_count=$(("$mp4_count" + "$flv_count" + "$mov_count"))
    if [ "$all_count" -eq 0 ]; then
        log_file_not_detected "mp4" "flv" "mov"
        return 0
    fi

    local video_crf
    video_crf=$(input_number "请输入压制视频的crf值" "默认crf值为18" "允许输入范围「0-51」，x264编码器默认23" "18" "(^$|^00$|^[0-9]$|^[1-4][0-9]$|^5[0-1]$)")
    if [ $? -eq 10 ]; then
        return 20
    fi

    local video_max_bitrate
    video_max_bitrate=$(input_number "请输入压制视频的最大码率" "默认最大码率值缺省为0" "允许输入格式为「数字+单位」，数字允许带小数点（精度限制两位小数），单位可为[k/K/M/G][i][b/B]，例如300kib、1.5M等（k为10^3——国际单位制SI，ki为2^10——国际电工委员会IEC，k和K二者含义一样，B=8b）单位缺省时默认为kbit/s，x264编码器默认0" "0" "(^$|^00$|^[0-9]+\.?[0-9]{0,2}[kKMG]?i?[bB]?$)")
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
        video_max_bitrate_unit=""
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

    draw_line_echo "-"
    text_echo "当前已设置压制视频的crf值为「$video_crf」，设置压制视频的最大码率为「$video_max_bitrate」，设置压制视频的码率控制缓冲区大小为「$video_bufsize」，设置压制视频的preset值为「$video_preset」"

    local watermark_effect filter_effect
    watermark_effect=$(copyright_watermark)
    filter_effect="${watermark_effect}[watermark_effect]; [watermark_effect] format=yuv420p"

    log_start
    make_directory "$output_path"
    local operation_count=0
    shopt -s nullglob
    draw_line_echo "~"
    show_progress_bar "$all_count" "$operation_count"
    for file in $(file_extension_for_loop "mp4" "flv" "mov"); do
        ffmpeg_no_banner -i "$file" -c:v libx264 -crf:v "$video_crf" -preset:v "$video_preset" -maxrate:v "$video_max_bitrate" -bufsize:v "$video_bufsize" -vf "$filter_effect" -c:a copy "$output_path/$(get_file_name "$file").mp4"
        ((operation_count++))
        show_progress_bar "$all_count" "$operation_count"
    done
    log_end "$operation_count" "$all_count"
    log_result "$feature_note"
    shopt -u nullglob
}
