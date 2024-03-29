#!/bin/bash

audio_metadata_by_file_name() {
    local output_path="audio_metadata_by_file_name"
    local feature_name feature_intro feature_note
    feature_name="根据音频文件名修改元数据标签"
    feature_intro="根据路径下的mp3文件或者m4a文件或者flac文件的文件名，修改音频文件内部的元数据标签（metadata tag）"
    feature_note="$(set_color "blue" "文件名要求：「歌曲名 - 歌手名」，歌名在前，歌手在后，短杠分割，短杠前后均有一个空格")；$(description_append_note "option_false" "directory" "$output_path")"
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

    log_start
    make_directory "$output_path"
    local operation_count=0 no_good_name_count=0
    shopt -s nullglob
    local audio_title audio_artist file_name
    draw_line_blank "~"
    show_progress_bar "$all_count" $(("$operation_count" + "$no_good_name_count"))
    for file in $(file_extension_for_loop "mp3" "m4a" "flac"); do
        file_name=$(get_file_name "$file")
        if [[ "$file_name" == *" - "* ]]; then
            audio_title=$(remove_after_last_delimiter "$file_name" " - ")
            audio_artist=$(remove_before_last_delimiter "$file_name" " - ")
            ffmpeg_no_banner -i "$file" -c copy -map_chapters -1 -metadata title="$audio_title" -metadata artist="$audio_artist" "${output_path}/${file}"
            ((operation_count++))
        else
            ((no_good_name_count++))
        fi
        show_progress_bar "$all_count" "$((operation_count + no_good_name_count))"
    done
    if [ "$no_good_name_count" -eq 0 ]; then
        log_end "$operation_count" "$all_count"
    else
        log_end "$operation_count" "$all_count" "有${no_good_name_count}个音频的文件名格式不符合要求，无法修改内部元数据标签"
    fi
    log_result "option_false" "directory" "$output_path"
    shopt -u nullglob
}
