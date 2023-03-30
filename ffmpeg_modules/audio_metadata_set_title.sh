#!/bin/bash

audio_metadata_set_title() {
    local output_path="audio_metadata_set_title"
    local feature_name feature_intro feature_note
    feature_name="设置音频文件的歌曲名"
    feature_intro="设置路径下的mp3文件或者m4a文件或者flac文件元数据标签的歌曲名$(description_append_intro "设置元数据标签-歌曲名")"
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
    all_count=$(("$m4a_count" + "$mp3_count" + "$flac_count"))
    if [ "$all_count" -eq 0 ]; then
        log_file_not_detected "m4a" "mp3" "flac"
        return 0
    fi

    log_start
    make_directory "$output_path"
    local operation_count=0
    shopt -s nullglob
    local file
    if [ "$all_count" -eq 1 ]; then
        for audio_file in $(file_extension_for_loop "mp3" "m4a" "flac"); do
            file="$audio_file"
        done
    else
        draw_line_echo "~"
        text_echo "提示：使用上下方向键↑↓选择文件，回车键Enter确认选项"
        text_echo "当前路径下检测到多个音频文件"
        text_echo "现在进入手动选择音频文件模式，请选择需要修改元数据标签-歌曲名的音频："
        local -a audio_file_array=()
        if [ "$m4a_count" -ne 0 ]; then
            audio_file_array+=(*.m4a)
            audio_file_array+=(*.M4A)
        fi
        if [ "$mp3_count" -ne 0 ]; then
            audio_file_array+=(*.mp3)
            audio_file_array+=(*.MP3)
        fi
        if [ "$flac_count" -ne 0 ]; then
            audio_file_array+=(*.flac)
            audio_file_array+=(*.FLAC)
        fi
        audio_file_array+=("取消功能操作，返回菜单")
        arrow_select_option "${audio_file_array[@]}"
        local choice=$?
        local choice_exit=$((${#audio_file_array[@]} - 1))
        if [ $choice -eq $choice_exit ]; then
            return 20
        fi
        file="${audio_file_array[$choice]}"
    fi

    local audio_title
    audio_title=$(input_anything "请输入元数据标签-歌曲名")
    if [ $? -eq 10 ]; then
        return 20
    fi
    draw_line_echo "-"
    text_echo "当前已设置元数据标签-歌曲名为「$audio_title」"

    ffmpeg_no_banner -i "$file" -c copy -map_chapters -1 -metadata title="$audio_title" "$output_path/$file"
    ((operation_count++))
    draw_line_echo "~"
    show_progress_bar "1" "$operation_count"
    log_end "$operation_count" "$all_count"
    log_result "$feature_note"
    shopt -u nullglob
}
