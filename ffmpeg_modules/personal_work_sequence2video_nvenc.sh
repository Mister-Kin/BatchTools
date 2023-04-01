#!/bin/bash

personal_work_sequence2video_nvenc() {
    local output_path="personal_work_sequence2video_nvenc"
    local feature_name feature_intro feature_note
    feature_name="显卡加速将图片序列合成为视频（不再维护该功能）"
    feature_intro="将路径下的png图片序列或者jpg图片序列合成为avc编码的mp4视频（h264_nvenc）"
    feature_note="$(set_color "blue")本功能已不再维护，代码结构都是早期的逻辑设计，漏洞较多；不推荐使用：本功能并未考虑检测文件和未规范用户输入的格式；需要显卡加速的功能，建议自行研究终端、FFmpeg以及h264_nvenc编码器的参数；$(set_color "reset")$(description_append_note "option_false" "directory" "$output_path")"
    description "$feature_name" "$feature_intro" "$feature_note"
    change_directory
    if [ $? -eq 10 ]; then
        return 20
    fi

    local all_count png_count jpg_count
    png_count=$(file_count "png")
    jpg_count=$(file_count "jpg")
    all_count=$(("$png_count" + "$jpg_count"))
    if [ "$all_count" -eq 0 ]; then
        log_file_not_detected "png" "jpg"
        return 0
    fi

    local name_length
    echo "提示：不输入（等待10s）或直接回车，则默认长度为4，如0001.png"
    if read -t 10 -r -p "请输入图片序列名的长度：" name_length; then
        if [ "$name_length" == "" ]; then
            name_length=4
        fi
    else
        echo
        name_length=4
    fi

    local video_bitrate video_maxrate
    echo "提示：不输入（等待10s）或直接回车，则默认为8M 10M，用空格分割两个参数，如2.5M 5M"
    if read -t 10 -r -p "请输入压制视频的码率和最大码率：" video_bitrate video_maxrate; then
        if [ "$video_bitrate" = "" ]; then
            video_bitrate="8M"
        fi
        if [ "$video_maxrate" = "" ]; then
            video_maxrate="10M"
        fi
    else
        echo
        video_bitrate="8M"
        video_maxrate="10M"

    fi

    log_start
    make_directory "$output_path"
    if [ "$png_count" -gt 0 ]; then
        ffmpeg_no_banner -hwaccel cuda -hwaccel_output_format cuda -r 24 -f image2 -i %0"$name_length"d.png -r 24 -c:v h264_nvenc -profile:v high -preset:v slow -rc:v vbr -cq:v 19 -b:v "$video_bitrate" -maxrate:v "$video_maxrate" "$output_path/output.mp4"
    else
        ffmpeg_no_banner -hwaccel cuda -hwaccel_output_format cuda -c:v mjpeg_cuvid -r 24 -f image2 -i %0"$name_length"d.jpg -r 24 -c:v h264_nvenc -profile:v high -preset:v slow -rc:v vbr -cq:v 19 -b:v "$video_bitrate" -maxrate:v "$video_maxrate" "$output_path/output.mp4"
    fi

    log_end "1" "$all_count"
    log_result "option_false" "directory" "$output_path"
}
