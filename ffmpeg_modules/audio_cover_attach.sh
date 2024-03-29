#!/bin/bash

check_image_good() {
    local image_file_size image_width image_height file_size_flag image_resolution_flag mega_byte file_extension
    local -a result_array
    image_file_size=$(get_media_info "$1" "format=size")
    image_width=$(get_media_info "$1" "stream=width")
    image_height=$(get_media_info "$1" "stream=height")
    mega_byte=$((1024 * 1024))
    if [ "$image_width" -eq "$image_height" ]; then
        image_resolution_flag=true
    else
        image_resolution_flag=false
    fi
    if [ "$image_file_size" -lt "$mega_byte" ]; then
        file_size_flag=true
    else
        file_size_flag=false
        file_extension=$(uppercase_to_lowercase "$(get_file_extension "$1")")
        if [ "$file_extension" = "png" ]; then
            ffmpeg_no_banner -i "$1" -vf "$(filter_for_compress "png")" -pix_fmt pal8 "image_temp.png" >&2
        else
            ffmpeg_no_banner -i "$1" "image_temp.jpg" >&2
        fi
    fi
    result_array+=("$file_size_flag")
    result_array+=("$image_resolution_flag")
    result_array+=("image_temp.${file_extension}")
    printf "%s " "${result_array[@]}"
}

audio_cover_attach() {
    local output_path="audio_cover_attach"
    local feature_name feature_intro feature_note
    feature_name="添加音频封面图"
    feature_intro="为路径下的mp3文件或者m4a文件或者flac文件添加封面图$(description_append_intro "手动选择封面图（有多张封面图且无音频同名的封面图）")"
    feature_note="$(set_color "blue")封面图要求png格式或者jpg格式；封面图分辨率建议不低于300×300px，推荐为960×960px；建议封面图宽高比为1，否则生成的封面图非正方形；建议封面图大小不超过1MB，否则本程序会自动将超过1MB的图片进行压缩后再进行添加音频封面图；$(set_color "reset")$(description_append_note "option_false" "directory" "$output_path")"
    description "$feature_name" "$feature_intro" "$feature_note"
    change_directory
    if [ $? -eq 10 ]; then
        return 20
    fi

    local audio_count m4a_count mp3_count flac_count image_count png_count jpg_count
    m4a_count=$(file_count "m4a")
    mp3_count=$(file_count "mp3")
    flac_count=$(file_count "flac")
    audio_count=$((m4a_count + mp3_count + flac_count))
    png_count=$(file_count "png")
    jpg_count=$(file_count "jpg")
    image_count=$((png_count + jpg_count))
    if [ "$audio_count" -eq 0 ] || [ "$image_count" -eq 0 ]; then
        if [ "$audio_count" -eq 0 ]; then
            log_file_not_detected "m4a" "mp3" "flac"
            return 0
        fi
        if [ "$image_count" -eq 0 ]; then
            log_file_not_detected "png" "jpg"
            return 0
        fi
    fi

    log_start
    make_directory "$output_path"
    local operation_count=0 bad_resolution_count=0 bad_file_size_count=0
    shopt -s nullglob
    local -a check_image_flag
    draw_line_blank "~"
    show_progress_bar "$audio_count" "$operation_count"
    if [ "$image_count" -eq 1 ]; then
        for file in $(file_extension_for_loop "mp3" "m4a" "flac"); do
            for image_file in $(file_extension_for_loop "png" "jpg"); do
                check_image_flag=($(check_image_good "$image_file"))
                if [ "${check_image_flag[0]}" = false ]; then
                    image_file="${check_image_flag[2]}"
                    ((bad_file_size_count++))
                fi
                if [ "${check_image_flag[1]}" = false ]; then
                    ((bad_resolution_count++))
                fi
                # 封面图的title和comment标签只有flac格式可显示
                ffmpeg_no_banner -i "$file" -i "$image_file" -map 0 -map 1 -c copy -disposition:v:0 attached_pic -metadata:s:v title="Album cover" -metadata:s:v comment="Cover (front)" -map_chapters -1 "${output_path}/${file}"
                ((operation_count++))
                if [ "${check_image_flag[0]}" = false ]; then
                    rm -rf "${check_image_flag[2]}"
                fi
            done
            show_progress_bar "$audio_count" "$operation_count"
        done
    fi
    if [ "$image_count" -gt 1 ]; then
        local file_name image_file_name check_name_flag
        for file in $(file_extension_for_loop "mp3" "m4a" "flac"); do
            for image_file in $(file_extension_for_loop "png" "jpg"); do
                file_name=$(get_file_name "$file")
                image_file_name=$(get_file_name "$image_file")
                if [ "$file_name" = "$image_file_name" ]; then
                    check_name_flag=true
                    check_image_flag=($(check_image_good "$image_file"))
                    if [ "${check_image_flag[0]}" = false ]; then
                        image_file="${check_image_flag[2]}"
                        ((bad_file_size_count++))
                    fi
                    if [ "${check_image_flag[1]}" = false ]; then
                        ((bad_resolution_count++))
                    fi
                    ffmpeg_no_banner -i "$file" -i "$image_file" -map 0 -map 1 -c copy -disposition:v:0 attached_pic -metadata:s:v title="Album cover" -metadata:s:v comment="Cover (front)" -map_chapters -1 "${output_path}/${file}"
                    ((operation_count++))
                    if [ "${check_image_flag[0]}" = false ]; then
                        rm -rf "${check_image_flag[2]}"
                    fi
                    break
                else
                    check_name_flag=false
                fi
            done
            if [ "$check_name_flag" = false ]; then
                draw_line_blank "~"
                text_blank "提示：使用上下方向键↑↓选择文件，回车键Enter确认选项"
                text_blank "当前路径下检测到多张封面图，但未检测到和「${file}」同名的封面图"
                text_blank "现在进入手动选择封面图模式："
                # 文件名可能含有空格，通过函数返回数组处理文件名十分麻烦，需额外添加分隔符处理分割字符块再重新数组化，因此不采用分离模块函数实现
                local -a image_file_array=()
                if [ "$png_count" -ne 0 ]; then
                    image_file_array+=(*.png)
                    image_file_array+=(*.PNG)
                fi
                if [ "$jpg_count" -ne 0 ]; then
                    image_file_array+=(*.jpg)
                    image_file_array+=(*.JPG)
                fi
                image_file_array+=("取消功能操作，返回菜单")
                arrow_select_option "${image_file_array[@]}"
                local choice=$?
                local choice_exit=$((${#image_file_array[@]} - 1))
                if [ $choice -eq $choice_exit ]; then
                    return 20
                fi
                check_image_flag=($(check_image_good "${image_file_array[$choice]}"))
                local image_file
                if [ "${check_image_flag[0]}" = true ]; then
                    image_file="${image_file_array[$choice]}"
                else
                    image_file="${check_image_flag[2]}"
                    ((bad_file_size_count++))
                fi
                if [ "${check_image_flag[1]}" = false ]; then
                    ((bad_resolution_count++))
                fi
                ffmpeg_no_banner -i "$file" -i "$image_file" -map 0 -map 1 -c copy -disposition:v:0 attached_pic -metadata:s:v title="Album cover" -metadata:s:v comment="Cover (front)" -map_chapters -1 "${output_path}/${file}"
                ((operation_count++))
                if [ "${check_image_flag[0]}" = false ]; then
                    rm -rf "${check_image_flag[2]}"
                fi
            fi
            show_progress_bar "$audio_count" "$operation_count"
        done
    fi
    if [ "$bad_resolution_count" -eq 0 ]; then
        log_end "$operation_count" "$audio_count"
    else
        local size_text="" resolution_text="" separation_text=""
        if [ "$bad_file_size_count" -ne 0 ]; then
            size_text="其中有${bad_file_size_count}个因采用的封面图文件大小已超过1MB，本程序已自动进行压缩再合成封面图"
        fi
        if [ "$bad_resolution_count" -ne 0 ]; then
            resolution_text="其中有${bad_resolution_count}个因采用的封面图宽高比不为1，生成的封面图非正方形"
        fi
        if [ "$bad_file_size_count" -ne 0 ] && [ "$bad_resolution_count" -ne 0 ]; then
            separation_text="；"
        fi
        log_end "$operation_count" "$audio_count" "${size_text}${separation_text}${resolution_text}"
    fi
    log_result "option_false" "directory" "$output_path"
    shopt -u nullglob
}
