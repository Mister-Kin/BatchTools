#!/bin/bash

audio_converter_lossless2m4a() {
    local output_path="audio_converter_lossless2m4a"
    local feature_name feature_intro feature_note
    feature_name="无损音频转m4a格式"
    feature_intro="将路径下的flac文件或者wav文件重新压制为aac编码的m4a文件（libfdk_aac）$(description_append_intro "设置压制音频的码率")"
    feature_note="$(description_append_note "option_false" "directory" "$output_path")"
    description "$feature_name" "$feature_intro" "$feature_note"
    change_directory
    if [ $? -eq 10 ]; then
        return 20
    fi

    local all_count wav_count flac_count
    wav_count=$(file_count "wav")
    flac_count=$(file_count "flac")
    all_count=$((wav_count + flac_count))
    if [ "$all_count" -eq 0 ]; then
        log_file_not_detected "wav" "flac"
        return 0
    fi

    local audio_bitrate
    audio_bitrate=$(input_number "请输入压制音频的码率" "默认码率为192k" "允许输入「16/32/64/96/128/192/256/320」，程序会自动设置单位为k" "192" "(^$|^00$|^16$|^32$|^64$|^96$|^128$|^192$|^256$|^320$)")
    if [ $? -eq 10 ]; then
        return 20
    fi
    audio_bitrate="${audio_bitrate}k"

    draw_line_blank "-"
    text_blank "当前已设置压制音频的码率为「${audio_bitrate}」"

    log_start
    make_directory "$output_path"
    local operation_count=0
    shopt -s nullglob
    draw_line_blank "~"
    show_progress_bar "$all_count" "$operation_count"
    local media_stream_number
    for file in $(file_extension_for_loop "wav" "flac"); do
        media_stream_number=$(get_media_info "$file" "format=nb_streams")
        if [ "$media_stream_number" -eq 2 ]; then
            ffmpeg_no_banner -i "$file" -c:a libfdk_aac -b:a "$audio_bitrate" -c:v copy "${output_path}/$(get_file_name "$file").m4a"
        else
            ffmpeg_no_banner -i "$file" -c:a libfdk_aac -b:a "$audio_bitrate" "${output_path}/$(get_file_name "$file").m4a"
        fi
        ((operation_count++))
        show_progress_bar "$all_count" "$operation_count"
    done
    log_end "$operation_count" "$all_count"
    log_result "$feature_note"
    shopt -u nullglob
}
