#!/bin/bash

audio_metadata_set_album() {
    local output_path="audio_metadata_set_album"
    local feature_name feature_intro feature_note
    feature_name="设置音频文件的专辑名"
    feature_intro="设置路径下的mp3文件或者m4a文件或者flac文件元数据标签的专辑名$(description_append_intro "设置元数据标签-专辑名")"
    feature_note="$(description_append_note "option_false" "directory" "$output_path")"
    description "$feature_name" "$feature_intro" "$feature_note"
    change_directory
    if [ $? -eq 10 ]; then
        return 20
    fi

    local all_count m4a_count mp3_count flac_count
    m4a_count=$(file_count "m4a")
    mp3_count=$(file_count "mp3")
    flac_count=$(file_count "flac")
    all_count=$((m4a_count + mp3_count + flac_count))
    if [ "$all_count" -eq 0 ]; then
        log_file_not_detected "m4a" "mp3" "flac"
        return 0
    fi

    local audio_ablum
    audio_ablum=$(input_anything "请输入元数据标签-专辑名")
    if [ $? -eq 10 ]; then
        return 20
    fi

    draw_line_blank "-"
    text_blank "当前已设置元数据标签-专辑名为「${audio_ablum}」"

    log_start
    make_directory "$output_path"
    local operation_count=0
    shopt -s nullglob
    draw_line_blank "~"
    show_progress_bar "$all_count" "$operation_count"
    for file in $(file_extension_for_loop "mp3" "m4a" "flac"); do
        ffmpeg_no_banner -i "$file" -c copy -map_chapters -1 -metadata album="$audio_ablum" "${output_path}/${file}"
        ((operation_count++))
        show_progress_bar "$all_count" "$operation_count"
    done
    log_end "$operation_count" "$all_count"
    log_result "$feature_note"
    shopt -u nullglob
}
