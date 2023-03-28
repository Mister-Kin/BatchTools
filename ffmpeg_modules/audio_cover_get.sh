#!/bin/bash

audio_cover_get() {
    local output_path="audio_cover_get"
    local feature_name feature_intro feature_note
    feature_name="获取音频封面图"
    feature_intro="获取路径下的mp3文件或者m4a文件或者flac文件的音频封面图"
    feature_note="$(set_color "blue" "封面图输出为png格式")；$(description_append_note "option_false" "directory" "$output_path")"
    description "$feature_name" "$feature_intro" "$feature_note"
    change_directory
    if [ $? -eq 10 ]; then
        return 20
    fi

    local all_count m4a_count mp3_count flac_count
    m4a_count=$(file_count "m4a")
    mp3_count=$(file_count "mp3")
    flac_count=$(file_count "flac")
    all_count=$(("$m4a_count" + "$mp3_count" + "$flac_count"))
    if [ "$all_count" -eq 0 ]; then
        log_file_not_detected "m4a" "mp3" "flac"
        return 0
    fi

    log_start
    make_directory "$output_path"
    local operation_count=0 no_cover_count=0
    shopt -s nullglob
    local media_stream_number
    draw_line_echo "~"
    for file in $(file_extension_for_loop "mp3" "m4a" "flac"); do
        media_stream_number=$(get_media_info "$file" "format=nb_streams")
        if [ "$media_stream_number" -eq 2 ]; then
            ffmpeg_no_banner -i "$file" -an -c:v copy "$output_path/$(get_file_name "$file").png"
            ((operation_count++))
        else
            draw_line_echo "~"
            text_echo "「$file」文件内部没有封面图，无法获取音频封面图"
            ((no_cover_count++))
        fi
        show_progress_bar "$all_count" $(("$operation_count" + "$no_cover_count"))
    done
    if [ "$no_cover_count" -eq 0 ]; then
        log_end "$operation_count" "$all_count"
    else
        log_end "$operation_count" "$all_count" "有$no_cover_count个音频文件内部没有封面图，无法获取音频封面图"
    fi
    log_result "option_false" "directory" "$output_path"
    shopt -u nullglob
}
