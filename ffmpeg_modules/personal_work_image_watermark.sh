#!/bin/bash

image_add_watermark() {
    local output_path1="watermark_image_for_web"
    local output_path2="watermark_image_for_original_format"
    local feature_name feature_intro feature_note
    feature_name="给图片添加版权水印并压缩"
    feature_intro="将所有png文件或者jpg文件或者jpeg文件或者gif文件，按原格式和webp格式压缩，并添加版权水印"
    feature_note="$(description_append_note "option_false" "directory" "$output_path1" "$output_path2")"
    description "$feature_name" "$feature_intro" "$feature_note"
    change_directory
    if [ $? -eq 10 ]; then
        return 20
    fi

    local all_count png_count jpg_count jpeg_count gif_count
    png_count=$(file_count "png")
    jpg_count=$(file_count "jpg")
    jpeg_count=$(file_count "jpeg")
    gif_count=$(file_count "gif")
    all_count=$(("$png_count" + "$jpg_count" + "$jpeg_count" + "$gif_count"))
    if [ "$png_count" -eq 0 ] && [ "$jpg_count" -eq 0 ] && [ "$jpeg_count" -eq 0 ] && [ "$gif_count" -eq 0 ]; then
        file_not_detected "png" "jpg" "jpeg" "gif"
        return 0
    fi

    log_start
    make_directory "$output_path1" "$output_path2"
    local operation_count=0
    shopt -s nullglob
    for file in *.png *.PNG; do
        draw_line_echo "~"
        ffmpeg_no_banner -i "$file" -vf "$(copyright_watermark)" "$output_path1/${file%.*}.webp"
        echo_draw_line_echo "~"
        ffmpeg_no_banner -i "$file" -vf "$(filter_for_compress_with_copyright "png")" -pix_fmt pal8 "$output_path2/${file%.*}.png"
        ((operation_count += 2))
        echo
    done
    for file in *.jpg *.JPG; do
        draw_line_echo "~"
        ffmpeg_no_banner -i "$file" -vf "$(copyright_watermark)" "$output_path1/${file%.*}.webp"
        echo_draw_line_echo "~"
        ffmpeg_no_banner -i "$file" -vf "$(copyright_watermark)" "$output_path2/${file%.*}.jpg"
        ((operation_count += 2))
        echo
    done
    for file in *.jpeg *.JPEG; do
        draw_line_echo "~"
        ffmpeg_no_banner -i "$file" -vf "$(copyright_watermark)" "$output_path1/${file%.*}.webp"
        echo_draw_line_echo "~"
        ffmpeg_no_banner -i "$file" -vf "$(copyright_watermark)" "$output_path2/${file%.*}.jpeg"
        ((operation_count += 2))
        echo
    done
    for file in *.gif *.GIF; do
        draw_line_echo "~"
        ffmpeg_no_banner -i "$file" -vf "$(copyright_watermark)" "$output_path1/${file%.*}.webp"
        echo_draw_line_echo "~"
        ffmpeg_no_banner -i "$file" -vf "$(filter_for_compress_with_copyright "gif")" "$output_path2/${file%.*}.gif"
        ((operation_count += 2))
        echo
    done
    shopt -u nullglob
    log_end "$operation_count" "$all_count"
    log_result "$feature_note"
}
