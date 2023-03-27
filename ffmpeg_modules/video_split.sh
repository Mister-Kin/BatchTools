#!/bin/bash

caculate_end_time_for_splitting_video() {
    local end_time hour_time minute_time second_time temp_time
    if [[ "$1" =~ ^[0-5]?[0-9]$ ]]; then
        end_time="$1"
    elif [[ "$1" =~ ^[0-5]?[0-9]\.[0-5]?[0-9]$ ]]; then
        minute_time=${1%.*}
        second_time=${1##*.}
        end_time=$(("$minute_time" * 60 + "$second_time"))

    elif [[ "$1" =~ ^[0-9]+\.[0-5]?[0-9]\.[0-5]?[0-9]$ ]]; then
        hour_time=${1%%.*}
        temp_time=${1%.*}
        minute_time=${temp_time##*.}
        second_time=${1##*.}
        end_time=$(("$hour_time" * 60 * 60 + "$minute_time" * 60 + "$second_time"))
    elif [[ "$1" =~ ^[Ee][Nn][Dd]$ ]]; then
        end_time="$2"
    fi
    echo "$end_time"
}

split_video() {
    description "无损分割视频" "将mp4文件或者flv文件或者mov文件按时间点连续无损分割为多个文件；生成的文件输出在「video_split」文件夹" "确保路径下没有名为「video_split」文件夹，否则本功能操作将生成同名文件夹强制覆盖；如果路径下已有该文件夹，请先自行处理好文件再执行该功能"
    change_directory
    if [ $? -eq 10 ]; then
        return 20
    fi

    local mp4_count flv_count mov_count all_count
    mp4_count=$(file_count "mp4")
    flv_count=$(file_count "flv")
    mov_count=$(file_count "mov")
    all_count=$(("$mp4_count" + "$flv_count" + "$mov_count"))

    if [ "$mp4_count" -eq 0 ] && [ "$flv_count" -eq 0 ] && [ "$mov_count" -eq 0 ]; then
        echo "当前并未检测到任何mp4文件或者flv文件或者mov文件，已退出本次的功能操作"
        return 0
    elif [ "$all_count" -gt 1 ]; then
        echo "当前检测到多个视频文件，已退出本次的功能操作，请确保路径中只有一个视频文件"
        return 0
    fi

    local video_file video_extension
    if [ "$mp4_count" -gt 0 ]; then
        echo "当前检测到$mp4_count个mp4文件"
        video_file=(*.mp4)
        video_extension="mp4"
    fi
    if [ "$flv_count" -gt 0 ]; then
        echo "当前检测到$flv_count个flv文件"
        video_file=(*.flv)
        video_extension="flv"
    fi
    if [ "$mov_count" -gt 0 ]; then
        echo "当前检测到$mov_count个mov文件"
        video_file=(*.mov)
        video_extension="mov"
    fi
    local original_video_duration video_duration video_duration_integer
    original_video_duration=$(ffprobe -loglevel error -show_entries format=duration -of default=noprint_wrappers=1:nokey=1 "${video_file[0]}")
    video_duration=${original_video_duration::-3} # 删除三个小数（ffprobe输出6位小数）
    video_duration_integer=${video_duration%.*}
    echo "视频总时长为$video_duration秒"

    local output_path="video_split"
    make_directory "$output_path"

    draw_line "-"
    echo "已开始本次的功能操作"
    draw_line "~"
    local operation_count=0
    shopt -s nullglob
    local user_input
    local start_time=0 end_time=0 start_time_text=0 end_time_text hour_time minute_time second_time cut_time

    while [ "$end_time" -lt "$video_duration_integer" ]; do
        echo "提示：允许输入格式为「小时.分钟.秒钟」，例如1.5=1分5秒，注意分钟和秒钟限制为六十进制。输入「end」或者「大于视频总时长的时间点」即代表视频末尾处，不区分大小写。"
        read -r -p "当前时间点为$start_time_text，请输入下一个时间点：" user_input
        while ! [[ "$user_input" =~ (^[0-5]?[0-9]$|^[0-5]?[0-9]\.[0-5]?[0-9]$|^[0-9]+\.[0-5]?[0-9]\.[0-5]?[0-9]$|^[Ee][Nn][Dd]$) ]] || [ "$(caculate_end_time_for_splitting_video "$user_input" "$video_duration_integer")" -le "$start_time" ]; do
            if ! [[ "$user_input" =~ (^[0-5]?[0-9]$|^[0-5]?[0-9]\.[0-5]?[0-9]$|^[0-9]+\.[0-5]?[0-9]\.[0-5]?[0-9]$|^[Ee][Nn][Dd]$) ]]; then
                echo "当前输入错误，请重新输入。允许输入格式为「小时.分钟.秒钟」，例如1.5=1分5秒，注意分钟和秒钟限制为六十进制。输入「end」或者「大于视频总时长的时间点」即代表视频末尾处，不区分大小写。"
            else
                echo "当前输入的时间点小于或等于上一次输入的时间点，请重新输入一个大于的时间点："
            fi
            read -r -p "当前时间点为$start_time_text，请输入下一个时间点：" user_input
        done

        # 处理前面只有0的输入情况
        if [[ "$user_input" =~ ^0+\.[0-5]?[0-9]$ ]]; then
            end_time_text=${user_input#*.}
        elif [[ "$user_input" =~ ^0+\.[0-5]?[0-9]\.[0-5]?[0-9]$ ]]; then
            end_time_text=${user_input#*.}
        else
            end_time_text="$user_input"
        fi

        end_time=$(caculate_end_time_for_splitting_video "$user_input" "$video_duration_integer")
        if [ "$end_time" -ge "$video_duration_integer" ]; then
            if [ "$end_time" -eq "$video_duration_integer" ]; then
                echo "当前输入的时间点为视频末尾处"
            else
                echo "当前输入的时间点已超过视频总时长，本程序已自动将时间点设置为视频末尾处"
            fi
            end_time="$video_duration"
            end_time_text="end"
        fi

        ffmpeg_no_banner -i "${video_file[0]}" -ss "$start_time" -to "$end_time" -c copy "$output_path/$start_time_text - $end_time_text.$video_extension"
        if [ "$end_time" = "$video_duration" ]; then
            cut_time=$(echo $start_time "$end_time" | awk '{ printf "%.3f", $2 - $1 }')
        else
            cut_time=$(("$end_time" - "$start_time"))
        fi
        echo "当前剪切$cut_time秒视频，已在$output_path文件夹中输出文件 $start_time_text - $end_time_text.$video_extension"
        start_time="$end_time"
        start_time_text="$end_time_text"
        if [ "$end_time" = "$video_duration" ]; then
            end_time="$video_duration_integer"
        fi
        ((operation_count++))
        draw_line "~"
    done
    shopt -u nullglob
    echo "已结束本次的功能操作，视频总时长为$video_duration秒，总共执行了$operation_count次分割操作"

    finished_word "directory" "$output_path"
}
