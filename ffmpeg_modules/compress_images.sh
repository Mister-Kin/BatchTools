#!/bin/bash

compress_images() {
    description "压缩图片（原格式压缩或者转换为webp格式）" "将所有png文件或者jpg文件或者gif文件按原格式压缩或者转换成webp格式；生成的文件输出在「image_compress_to_original_format」文件夹或者「image_compress_to_webp」文件夹；如果选择删除源文件，最终输出的文件是在原路径，上述所创建的文件夹只是作为临时文件夹" "确保路径下没有名为「image_compress_to_original_format」文件夹或者「image_compress_to_webp」文件夹，否则本功能操作将生成同名文件夹强制覆盖；如果路径下已有该文件夹，请先自行处理好文件再执行该功能"
    change_directory
    if [ $? -eq 10 ]; then
        return 20
    fi

    local png_count jpg_count gif_count all_count PNG_count JPG_count GIF_count
    png_count=$(file_count "png")
    jpg_count=$(file_count "jpg")
    gif_count=$(file_count "gif")
    PNG_count=$(file_count "PNG")
    JPG_count=$(file_count "JPG")
    GIF_count=$(file_count "GIF")
    all_count=$(("$png_count" + "$jpg_count" + "$gif_count" + "$PNG_count" + "$JPG_count" + "$GIF_count"))

    if [ "$png_count" -eq 0 ] && [ "$jpg_count" -eq 0 ] && [ "$gif_count" -eq 0 ] && [ "$PNG_count" -eq 0 ] && [ "$JPG_count" -eq 0 ] && [ "$GIF_count" -eq 0 ]; then
        echo "当前并未检测到png文件或者jpg文件或者gif文件或者PNG文件或者JPG文件或者GIF文件，已退出本次的功能操作"
        return 0
    fi
    if [ "$png_count" -gt 0 ] || [ "$PNG_count" -gt 0 ]; then
        echo "当前检测到$png_count个png文件和$PNG_count个PNG文件"
    fi
    if [ "$jpg_count" -gt 0 ] || [ "$JPG_count" -gt 0 ]; then
        echo "当前检测到$jpg_count个jpg文件和$JPG_count个JPG文件"
    fi
    if [ "$gif_count" -gt 0 ] || [ "$GIF_count" -gt 0 ]; then
        echo "当前检测到$gif_count个gif文件和$GIF_count个GIF文件"
    fi

    draw_line "-"
    local user_input
    local webp_flag
    echo "提示：不输入（等待15s）或直接回车，则默认不转换成webp格式（默认否，允许输入「是/否/yes/no/y/n」，不区分大小写）"
    if read -t 15 -r -p "是否转换成webp格式（默认否）：" user_input; then
        while ! [[ "$user_input" =~ (^$|^[YyNn]$|^[Yy][Ee][Ss]$|^[Nn][Oo]$) ]] && [ "$user_input" != "是" ] && [ "$user_input" != "否" ]; do
            echo "当前输入错误，请重新输入。允许输入「是/否/yes/no/y/n」，不区分大小写。"
            if ! read -t 15 -r -p "是否转换成webp格式（默认否）：" user_input; then
                echo
                webp_flag=false
            fi
        done
        if [ "$user_input" = "是" ] || [[ "$user_input" =~ (^[Yy]$|^[Yy][Ee][Ss]$) ]]; then
            webp_flag=true
        elif [ "$user_input" = "否" ] || [[ "$user_input" =~ (^$|^[Nn]$|^[Nn][Oo]) ]]; then
            webp_flag=false
        fi
    else
        echo
        webp_flag=false
    fi

    draw_line "-"
    local delete_source_files
    echo "提示：不输入（等待15s）或直接回车，则默认删除源文件（默认是，允许输入「是/否/yes/no/y/n」，不区分大小写）"
    if read -t 15 -r -p "是否删除源文件（默认是）：" user_input; then
        while ! [[ "$user_input" =~ (^$|^[YyNn]$|^[Yy][Ee][Ss]$|^[Nn][Oo]$) ]] && [ "$user_input" != "是" ] && [ "$user_input" != "否" ]; do
            echo "当前输入错误，请重新输入。允许输入「是/否/yes/no/y/n」，不区分大小写。"
            if ! read -t 15 -r -p "是否删除源文件（默认是）：" user_input; then
                echo
                delete_source_files=true
            fi
        done
        if [ "$user_input" = "是" ] || [[ "$user_input" =~ (^$|^[Yy]$|^[Yy][Ee][Ss]$) ]]; then
            delete_source_files=true
        elif [ "$user_input" = "否" ] || [[ "$user_input" =~ (^[Nn]$|^[Nn][Oo]) ]]; then
            delete_source_files=false
        fi
    else
        echo
        delete_source_files=true
    fi

    draw_line "-"
    echo "已开始本次的功能操作"
    draw_line "~"
    local operation_count=0 delete_count=0
    shopt -s nullglob
    local output_path
    if [ "$webp_flag" = false ]; then
        output_path="image_compress_to_original_format"
        make_directory_with_no_line "$output_path"
        draw_line "~"
        for file in *.jpg *.JPG; do
            ffmpeg_no_banner -i "$file" "$output_path/${file%.*}.jpg"
            draw_line "~"
            ((operation_count++))
        done
        for file in *.png *.PNG; do
            ffmpeg_no_banner -i "$file" -vf "$(filter_effect_for_compress "png")" -pix_fmt pal8 "$output_path/${file%.*}.png"
            draw_line "~"
            ((operation_count++))
        done
        for file in *.gif *.GIF; do
            ffmpeg_no_banner -i "$file" -vf "$(filter_effect_for_compress "gif")" "$output_path/${file%.*}.webp"
            draw_line "~"
            ((operation_count++))
        done
    else
        output_path="image_compress_to_webp"
        make_directory_with_no_line "$output_path"
        draw_line "~"
        for file in *.png *.jpg *.gif *.PNG *.JPG *.GIF; do
            ffmpeg_no_banner -i "$file" "$output_path/${file%.*}.webp"
            draw_line "~"
            ((operation_count++))
        done
    fi
    local print_info
    if [ "$delete_source_files" = true ]; then
        for file in *.png *.jpg *.gif *.PNG *.JPG *.GIF; do
            rm -rf "$file"
            echo "当前已删除$file"
            ((delete_count++))
            draw_line "~"
        done
        mv "$output_path"/* ./
        rm -rf "$output_path"
        echo "已删除临时文件夹$output_path"
        draw_line "~"
        print_info="已结束本次的功能操作，总共执行了$operation_count次转换操作（当前路径检测到$all_count个可操作文件），删除了$delete_count个源文件"
    else
        print_info="已结束本次的功能操作，总共执行了$operation_count次转换操作（当前路径检测到$all_count个可操作文件）"
    fi
    shopt -u nullglob
    echo "$print_info"

    if [ "$delete_source_files" = true ]; then
        if [ "$webp_flag" = false ]; then
            finished_word "file" "xxx.xxx"
        else
            finished_word "file" "xxx.webp"
        fi
    else
        finished_word "directory" "$output_path"
    fi
}
