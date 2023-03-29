#!/bin/bash

compress_video() {
    local output_path="video_compress_to_hevc"
    local feature_name feature_intro feature_note
    feature_name="压缩视频，转换为hevc编码的mp4格式（libx265）"
    feature_intro="使用libx265，将所有mp4文件或者flv文件或者mov文件转换hevc编码的mp4格式$(description_append_intro "设置压制视频的crf值；设置压制视频的preset值；是否删除源文件")"
    feature_note="$(description_append_note "option_false" "directory" "directory_delete_option" "$output_path")"
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
    if [ "$mp4_count" -eq 0 ] && [ "$flv_count" -eq 0 ] && [ "$mov_count" -eq 0 ]; then
        file_not_detected "mp4" "flv" "mov"
        return 0
    fi

    local video_crf
    video_crf=$(input_number "请输入压制视频的crf值" "默认crf值为28" "允许输入范围「0-51」" "28" "(^$|^[0-9]$|^[1-4][0-9]$|^5[0-1]$)")
    local video_preset video_preset_array_to_string
    video_preset_array_to_string="ultrafast superfast veryfast faster fast medium slow slower veryslow placebo ULTRAFAST SUPERFAST VERYFAST FASTER FAST MEDIUM SLOW SLOWER VERYSLOW PLACEBO"
    video_preset=$(input_string "请输入压制视频的preset值" "默认preset值为medium" "允许输入「ultrafast, superfast, veryfast, faster, fast, medium, slow, slower, veryslow, placebo」，要求全部小写或者全部大写" "medium" "$video_preset_array_to_string" "(^$|^[a-zA-Z]{4,9}$)")
    local delete_source_files
    delete_source_files=$(input_bool "是否删除源文件" "默认是「即删除源文件」" "true")

    log_start
    make_directory "$output_path"
    local operation_count=0 delete_count=0
    shopt -s nullglob
    for file in *.mp4 *.flv *.mov *.MP4 *.FLV *.MOV; do
        draw_line_echo "~"
        ffmpeg_no_banner -i "$file" -c:v libx265 -crf:v "$video_crf" -preset:v "$video_preset" -c:a copy "$output_path/${file%.*}.mp4"
        ((operation_count++))
        echo
    done
    if [ "$delete_source_files" = true ]; then
        draw_line_echo "~"
        for file in *.mp4 *.flv *.mov *.MP4 *.FLV *.MOV; do
            rm -rf "$file"
            ((delete_count++))
            text_echo "当前已删除「$file」"
        done
        mv "$output_path"/* ./
        rm -rf "$output_path"
        draw_line_echo "~"
        text_echo "已删除「$output_path」临时文件夹"
        log_end "$operation_count" "$all_count" "$delete_count"
        log_result "option_false" "file" "mp4"
    else
        log_end "$operation_count" "$all_count"
        log_result "$feature_note"
    fi
    shopt -u nullglob
}
