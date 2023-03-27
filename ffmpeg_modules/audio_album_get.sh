#!/bin/bash

audio_album_get() {
    local output_path="audio_album_get"
    local feature_name feature_intro feature_note
    feature_name="获取音频封面图"
    feature_intro="获取所有mp3文件或者m4a文件或者flac文件的音频封面图"
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
    local operation_count=0
    shopt -s nullglob
    local media_stream_number
    for file in $(file_extension_for_loop "mp3" "m4a" "flac"); do
        media_stream_number=$(get_media_info "$file" "format=nb_streams")
        draw_line_echo "~"
        if [ "$media_stream_number" -eq 2 ]; then
            ffmpeg_no_banner -i "$file" -an -c:v copy "$output_path/$(get_file_name "$file").png"
            ((operation_count++))
            echo
        else
            text_echo "「$file」文件中没有图像，无法获取音频封面图"
        fi
    done
    log_end "$operation_count" "$all_count"
    log_result "option_false" "directory" "$output_path"
    shopt -u nullglob
}
