#!/bin/bash

image_add_watermark() {
    description "给图片添加版权水印并压缩" "将所有png文件或者jpg文件或者gif文件转换为webp和jpg格式，并添加版本水印，分别输出在「watermark_image_for_web」文件夹和「watermark_image_for_original_format」文件夹；" "确保路径下没有名为「watermark_image_for_web」文件夹和「watermark_image_for_original_format」文件夹，否则本功能操作将生成同名文件夹强制覆盖；如果路径下已有这些文件夹，请先自行处理好文件再执行该功能"
    change_directory
    if [ $? -eq 10 ]; then
        return 20
    fi

    local png_count jpg_count gif_count all_count
    png_count=$(file_count "png")
    jpg_count=$(file_count "jpg")
    gif_count=$(file_count "gif")
    all_count=$(("$png_count" + "$jpg_count" + "$gif_count"))

    if [ "$png_count" -eq 0 ] && [ "$jpg_count" -eq 0 ] && [ "$gif_count" -eq 0 ]; then
        echo "当前并未检测到png文件或者jpg文件或者gif文件，已退出本次的功能操作"
        return 0
    fi
    if [ "$png_count" -gt 0 ]; then
        echo "当前检测到$png_count个png文件"
    fi
    if [ "$jpg_count" -gt 0 ]; then
        echo "当前检测到$jpg_count个jpg文件"
    fi
    if [ "$gif_count" -gt 0 ]; then
        echo "当前检测到$gif_count个gif文件"
    fi

    local output_path1="watermark_image_for_web"
    local output_path2="watermark_image_for_original_format"
    make_directory "$output_path1" "$output_path2"

    local filter_effect filter_png filter_gif
    filter_effect=$(copyright_watermark)
    filter_png=$(filter_effect_for_compress "png")
    filter_gif=$(filter_effect_for_compress "gif")
    local filter_effect_for_gif="$filter_effect, $filter_gif"
    local filter_effect_for_png="$filter_effect, $filter_png"

    draw_line "-"
    echo "已开始本次的功能操作"
    draw_line "~"
    local operation_count=0
    shopt -s nullglob
    for file in *.png; do
        ffmpeg_no_banner -i "$file" -vf "$filter_effect" "$output_path1/${file%.*}.webp"
        draw_line "~"
        ffmpeg_no_banner -i "$file" -vf "$filter_effect_for_png" -pix_fmt pal8 "$output_path2/${file%.*}.png"
        draw_line "~"
        ((operation_count += 2))
    done
    for file in *.jpg; do
        ffmpeg_no_banner -i "$file" -vf "$filter_effect" "$output_path1/${file%.*}.webp"
        draw_line "~"
        ffmpeg_no_banner -i "$file" -vf "$filter_effect" "$output_path2/${file%.*}.jpg"
        draw_line "~"
        ((operation_count += 2))
    done
    for file in *.gif; do
        ffmpeg_no_banner -i "$file" -vf "$filter_effect" "$output_path1/${file%.*}.webp"
        draw_line "~"
        ffmpeg_no_banner -i "$file" -vf "$filter_effect_for_gif" "$output_path2/${file%.*}.gif"
        draw_line "~"
        ((operation_count += 2))
    done
    shopt -u nullglob
    echo "已结束本次的功能操作，总共执行了$operation_count次转换操作（当前路径检测到$all_count个可操作文件）"

    finished_word "directory" "$output_path1" "$output_path2"
}
