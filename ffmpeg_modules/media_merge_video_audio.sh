#!/bin/bash

media_merge_video_audio() {
    local output_path="media_merge_video_audio"
    local feature_name feature_intro feature_note
    feature_name="合并音视频：mp4+m4a/mp3"
    feature_intro="将路径下的不含音频流的mp4文件或者flv文件或者mov文件和m4a文件或者mp3文件合并输出为mp4格式的视频，不涉及重新编码"
    feature_note="$(description_append_note "option_false" "directory" "$output_path")"
    description "$feature_name" "$feature_intro" "$feature_note"
    change_directory
    if [ $? -eq 10 ]; then
        return 20
    fi

    local video_count mp4_count flv_count mov_count audio_count m4a_count mp3_count
    mp4_count=$(file_count "mp4")
    flv_count=$(file_count "flv")
    mov_count=$(file_count "mov")
    video_count=$(("$mp4_count" + "$flv_count" + "$mov_count"))
    m4a_count=$(file_count "m4a")
    mp3_count=$(file_count "mp3")
    audio_count=$(("$m4a_count" + "$mp3_count"))

    if [ "$audio_count" -eq 0 ] || [ "$video_count" -eq 0 ]; then
        if [ "$video_count" -eq 0 ]; then
            log_file_not_detected "mp4" "flv" "mov"
            return 0
        fi
        if [ "$audio_count" -eq 0 ]; then
            log_file_not_detected "m4a" "mp3"
            return 0
        fi
    fi

    shopt -s nullglob
    local input_video
    if [ "$video_count" -eq 1 ]; then
        for file in $(file_extension_for_loop "mp4" "flv" "mov"); do
            input_video="$file"
        done
    else
        draw_line_blank "-"
        text_blank "提示：使用上下方向键↑↓选择文件，回车键Enter确认选项"
        text_blank "当前路径下检测到多个视频文件"
        text_blank "现在进入手动选择视频文件模式，请选择需要合并的视频文件："
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

    local input_audio
    if [ "$audio_count" -eq 1 ]; then
        for file in $(file_extension_for_loop "m4a" "mp3"); do
            input_audio="$file"
        done
    fi
    if [ "$audio_count" -gt 1 ]; then
        local video_file_name audio_file_name check_name_flag
        for file in $(file_extension_for_loop "m4a" "mp3"); do
            video_file_name=$(get_file_name "$input_video")
            audio_file_name=$(get_file_name "$file")
            if [ "$video_file_name" = "$audio_file_name" ]; then
                check_name_flag=true
                input_audio="$file"
                break
            else
                check_name_flag=false
            fi
        done
        if [ "$check_name_flag" = false ]; then
            draw_line_blank "-"
            text_blank "提示：使用上下方向键↑↓选择文件，回车键Enter确认选项"
            text_blank "当前路径下检测到多个音频文件，但并未检测到和「$input_video」同名的音频文件"
            text_blank "现在进入手动选择音频文件模式，请选择需要合并的音频文件："
            local -a audio_file_array=()
            if [ "$mp3_count" -ne 0 ]; then
                audio_file_array+=(*.mp3)
                audio_file_array+=(*.MP3)
            fi
            if [ "$m4a_count" -ne 0 ]; then
                audio_file_array+=(*.m4a)
                audio_file_array+=(*.M4A)
            fi
            audio_file_array+=("取消功能操作，返回菜单")
            arrow_select_option "${audio_file_array[@]}"
            local choice=$?
            local choice_exit=$((${#audio_file_array[@]} - 1))
            if [ $choice -eq $choice_exit ]; then
                return 20
            fi
            input_audio="${audio_file_array[$choice]}"
        fi
    fi
    shopt -u nullglob

    log_start
    make_directory "$output_path"
    local operation_count=0
    draw_line_blank "~"
    show_progress_bar "1" "$operation_count"
    ffmpeg_no_banner -i "$input_video" -i "$input_audio" -c copy "$output_path/$(lowercase_file_name_extension "$input_video")"
    ((operation_count++))
    show_progress_bar "1" "$operation_count"
    log_end "$operation_count" "$video_count"
    log_result "$feature_note"
}
