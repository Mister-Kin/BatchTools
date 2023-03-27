#!/bin/bash

audio_rename_to_file() {
    local output_path="audio_rename_to_file"
    local feature_name feature_intro feature_note
    feature_name="根据元数据标签重命名音频文件"
    feature_intro="根据音频文件内部的元数据标签（metadata tag），重命名所有mp3文件或者m4a文件或者flac文件"
    feature_note="$(set_color "blue" "命名格式：「歌曲名 - 歌手名」")；$(description_append_note "option_false" "directory" "$output_path")"
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
    local audio_title audio_artist output_file
    for file in *.mp3 *.m4a *.flac; do
        # nokey格式的输出可以通过设置nokey=1来去除每个字段的键名，只保留值。
        audio_title=$(get_media_info "$file" "format_tags=title")
        audio_artist=$(get_media_info "$file" "format_tags=artist")
        output_file="$audio_title - $audio_artist.$(get_file_extension "$file")"
        if [ "$audio_title" = "" ] || [ "$audio_artist" = "" ]; then
            draw_line_echo "~"
            text_echo "「$file」内部没有元数据标签，无法完成重命名操作"
        else
            draw_line_echo "~"
            ffmpeg_no_banner -i "$file" -c copy -map_chapters -1 "$output_path/$output_file"
            ((operation_count++))
            echo
            draw_line_echo "~"
            text_echo "已将「$file」重命名为「$output_file」"
        fi
    done
    log_end "$operation_count" "$all_count"
    log_result "option_false" "directory" "$output_path"
    shopt -u nullglob
}
