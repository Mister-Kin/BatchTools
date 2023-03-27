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
        draw_line_echo "~" >&2
        text_echo "当前选择的封面图「$1」宽高比不为1" >&2
        text_echo "这会导致生成的音频封面图非正方形" >&2
    fi
    if [ "$image_file_size" -lt "$mega_byte" ]; then
        file_size_flag=true
    else
        file_size_flag=false
        draw_line_echo "~" >&2
        local image_file_size_to_mega
        image_file_size_to_mega=$(echo $image_file_size | awk '{ printf "%.2f", $1 / 1024 /1024 }')
        text_echo "当前选择的封面图「$1」文件大小为${image_file_size_to_mega}MB，已超过1MB" >&2
        text_echo "本程序将自动压缩封面图「$1」，生成临时文件再添加音频封面图" >&2
        file_extension=$(uppercase_to_lowercase $(get_file_extension "$1"))
        if [ "$file_extension" = "png" ]; then
            draw_line_echo "~" >&2
            ffmpeg_no_banner -i "$1" -vf "$(filter_for_compress "png")" -pix_fmt pal8 "image_temp.png" >&2
            echo >&2
        else
            draw_line_echo "~" >&2
            ffmpeg_no_banner -i "$1" "image_temp.jpg" >&2
            echo >&2
        fi
        image_file_size=$(get_media_info "image_temp.$file_extension" "format=size")
        image_file_size_to_kilo=$(echo $image_file_size | awk '{ printf "%.2f", $1 / 1024 }')
        draw_line_echo "~" >&2
        text_echo "已生成临时文件「image_temp.$file_extension」，文件大小为${image_file_size_to_kilo}KB" >&2
        text_echo "已完成压缩「$1」，从${image_file_size_to_mega}MB压缩到${image_file_size_to_kilo}KB" >&2
    fi
    result_array+=("$file_size_flag")
    result_array+=("$image_resolution_flag")
    result_array+=("image_temp.$file_extension")
    echo "${result_array[@]}"
}

audio_cover_attach() {
    local output_path="audio_cover_attach"
    local feature_name feature_intro feature_note
    feature_name="添加音频封面图"
    feature_intro="为mp3文件或者m4a文件或者flac文件添加封面图$(description_append_intro "手动选择封面图（有多张封面图且无音频同名的封面图）")"
    feature_note="$(set_color "blue")封面图要求png格式或者jpg格式；封面图分辨率建议不低于300×300px，推荐为960×960px；建议封面图宽高比为1，否则生成的封面图非正方形；建议封面图大小不超过1MB，否则本程序会自动将超过1MB的图片进行压缩后再进行添加音频封面图；$(set_color "reset")$(description_append_note "option_false" "directory" "$output_path")"
    description "$feature_name" "$feature_intro" "$feature_note"
    change_directory
    if [ $? -eq 10 ]; then
        return 20
    fi

    local audio_all_count m4a_count mp3_count flac_count image_all_count png_count jpg_count
    m4a_count=$(file_count "m4a")
    mp3_count=$(file_count "mp3")
    flac_count=$(file_count "flac")
    audio_all_count=$(("$m4a_count" + "$mp3_count" + "$flac_count"))
    png_count=$(file_count "png")
    jpg_count=$(file_count "jpg")
    image_all_count=$(("$png_count" + "$jpg_count"))
    if [ "$audio_all_count" -eq 0 ] || [ "$image_all_count" -eq 0 ]; then
        if [ "$audio_all_count" -eq 0 ]; then
            log_file_not_detected "m4a" "mp3" "flac"
            return 0
        fi
        if [ "$image_all_count" -eq 0 ]; then
            log_file_not_detected "png" "jpg"
            return 0
        fi
    fi

    log_start
    make_directory "$output_path"
    local operation_count=0 bad_resolution_count=0
    shopt -s nullglob
    local -a check_image_flag
    if [ "$image_all_count" -eq 1 ]; then
        for file in $(file_extension_for_loop "mp3" "m4a" "flac"); do
            for image_file in $(file_extension_for_loop "png" "jpg"); do
                check_image_flag=($(check_image_good "$image_file"))
                if [ "${check_image_flag[0]}" = false ]; then
                    image_file="${check_image_flag[2]}"
                fi
                if [ "${check_image_flag[1]}" = false ]; then
                    ((bad_resolution_count++))
                fi
                draw_line_echo "~"
                ffmpeg_no_banner -i "$file" -i "$image_file" -map 0 -map 1 -c copy -map_chapters -1 -disposition:v:0 attached_pic "$output_path/$file"
                ((operation_count++))
                echo
                if [ "${check_image_flag[0]}" = false ]; then
                    rm -rf "${check_image_flag[2]}"
                    draw_line_echo "~"
                    text_echo "已删除临时文件「${check_image_flag[2]}」"
                fi
            done
        done
    fi
    if [ "$image_all_count" -gt 1 ]; then
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
                    fi
                    if [ "${check_image_flag[1]}" = false ]; then
                        ((bad_resolution_count++))
                    fi
                    draw_line_echo "~"
                    ffmpeg_no_banner -i "$file" -i "$image_file" -map 0 -map 1 -c copy -map_chapters -1 -disposition:v:0 attached_pic "$output_path/$file"
                    ((operation_count++))
                    echo
                    if [ "${check_image_flag[0]}" = false ]; then
                        rm -rf "${check_image_flag[2]}"
                        draw_line_echo "~"
                        text_echo "已删除临时文件「${check_image_flag[2]}」"
                    fi
                    break
                else
                    check_name_flag=false
                fi
            done
            if [ "$check_name_flag" = false ]; then
                draw_line_echo "~"
                text_echo "提示：使用上下方向键↑↓选择文件，回车键Enter确认选项"
                text_echo "当前路径下检测到多张封面图，但未检测到和「$file」同名的封面图"
                text_echo "现在进入手动选择封面图模式："
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
                fi
                if [ "${check_image_flag[1]}" = false ]; then
                    ((bad_resolution_count++))
                fi
                draw_line_echo "~"
                ffmpeg_no_banner -i "$file" -i "$image_file" -map 0 -map 1 -c copy -map_chapters -1 -disposition:v:0 attached_pic "$output_path/$file"
                ((operation_count++))
                echo
                if [ "${check_image_flag[0]}" = false ]; then
                    rm -rf "${check_image_flag[2]}"
                    draw_line_echo "~"
                    text_echo "已删除临时文件「${check_image_flag[2]}」"
                fi
            fi
        done
    fi
    if [ "$bad_resolution_count" -eq 0 ]; then
        log_end "$operation_count" "$audio_all_count"
    else
        log_end "$operation_count" "$audio_all_count" "其中生成的文件有$bad_resolution_count个因采用的封面图宽高比不为1，生成的封面图非正方形"
    fi
    log_result "option_false" "directory" "$output_path"
    shopt -u nullglob
}
