#!/bin/bash

compress_media_video() {
    local output_path="compress_media_video"
    local feature_name feature_intro feature_note
    feature_name="压缩视频，转换为hevc编码的mp4格式（libx265）"
    feature_intro="将路径下的mp4文件或者flv文件或者mov文件或者avi文件或者wmv文件或者mpg文件转换hevc编码的mp4格式（libx265）$(description_append_intro "设置压制视频的crf值；设置压制视频的preset值；是否删除源文件")"
    feature_note="$(description_append_note "option_false" "directory" "directory_delete_option" "$output_path")"
    description "$feature_name" "$feature_intro" "$feature_note"
    change_directory
    if [ $? -eq 10 ]; then
        return 20
    fi

    local all_count mp4_count flv_count mov_count avi_count wmv_count
    mp4_count=$(file_count "mp4")
    flv_count=$(file_count "flv")
    mov_count=$(file_count "mov")
    avi_count=$(file_count "avi")
    wmv_count=$(file_count "wmv")
    mpg_count=$(file_count "mpg")
    all_count=$((mp4_count + flv_count + mov_count + avi_count + wmv_count + mpg_count))
    if [ "$all_count" -eq 0 ]; then
        log_file_not_detected "mp4" "flv" "mov" "avi" "wmv" "mpg"
        return 0
    fi

    local video_crf
    video_crf=$(input_number "请输入压制视频的crf值" "默认crf值为28" "允许输入范围「0-51」，x265编码器默认28" "28" "(^$|^00$|^[0-9]$|^[1-4][0-9]$|^5[0-1]$)")
    if [ $? -eq 10 ]; then
        return 20
    fi
    local video_preset video_preset_array_to_string
    video_preset_array_to_string="ultrafast superfast veryfast faster fast medium slow slower veryslow placebo"
    video_preset=$(input_string "请输入压制视频的preset值" "默认preset值为slow" "允许输入「ultrafast, superfast, veryfast, faster, fast, medium, slow, slower, veryslow, placebo」，要求全部小写或者全部大写，x265编码器默认medium" "slow" "$video_preset_array_to_string" "(^$|^00$|^[a-zA-Z]{4,9}$)")
    if [ $? -eq 10 ]; then
        return 20
    fi
    local delete_source_files
    delete_source_files=$(input_bool "是否删除源文件" "默认是「即删除源文件」" "true")
    if [ $? -eq 10 ]; then
        return 20
    fi

    draw_line_blank "-"
    text_blank "当前已设置压制视频的crf值为「${video_crf}」，设置压制视频的preset值为「${video_preset}」，设置删除源文件为「${delete_source_files}」"

    log_start
    make_directory "$output_path"
    local operation_count=0 delete_count=0
    shopt -s nullglob
    draw_line_blank "~"
    show_progress_bar "$all_count" "$operation_count"
    for file in $(file_extension_for_loop "mp4" "flv" "mov" "avi" "mpg"); do
        # disable_chpl参数避免mkv重编码为mp4产生多一个重复章节信息
        ffmpeg_no_banner -i "$file" -c:v libx265 -crf:v "$video_crf" -preset:v "$video_preset" -c:a copy -map_chapters 0 -movflags disable_chpl -x265-params log-level=error:info=0 "${output_path}/$(get_file_name "$file").mp4"
        ((operation_count++))
        show_progress_bar "$all_count" "$operation_count"
    done
    # wmv转mp4，音频需要指定编码，不能copy
    # Could not find tag for codec wmav2 in stream
    # MP4 doesn't take Windows Media Audio in its container
    for file in $(file_extension_for_loop "wmv"); do
        ffmpeg_no_banner -i "$file" -c:v libx265 -crf:v "$video_crf" -preset:v "$video_preset" -c:a libfdk_aac -b:a "192k" -map_chapters 0 -movflags disable_chpl -x265-params log-level=error:info=0 "${output_path}/$(get_file_name "$file").mp4"
        ((operation_count++))
        show_progress_bar "$all_count" "$operation_count"
    done
    if [ "$delete_source_files" = true ]; then
        for file in $(file_extension_for_loop "mp4" "flv" "mov" "avi" "wmv" "mpg"); do
            rm -rf "$file"
            ((delete_count++))
        done
        mv "$output_path"/* ./
        rm -rf "$output_path"
        log_end "$operation_count" "$all_count" "$delete_count"
        log_result "option_false" "file" "mp4"
    else
        log_end "$operation_count" "$all_count"
        log_result "$feature_note"
    fi
    shopt -u nullglob
}
