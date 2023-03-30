#!/bin/bash

personal_work_image_watermark() {
    local output_path1="personal_work_image_watermark_webp"
    local output_path2="personal_work_image_watermark_original"
    local feature_name feature_intro feature_note
    feature_name="给图片添加版权水印并压缩"
    feature_intro="将路径下的png文件或者jpg文件或者jpeg文件或者gif文件，按原格式和webp格式压缩，并添加版权水印"
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
    if [ "$all_count" -eq 0 ]; then
        log_file_not_detected "png" "jpg" "jpeg" "gif"
        return 0
    fi

    log_start
    make_directory "$output_path1" "$output_path2"
    local operation_count=0
    shopt -s nullglob
    draw_line_echo "~"
    for file in $(file_extension_for_loop "png"); do
        ffmpeg_no_banner -i "$file" -vf "$(copyright_watermark)" "$output_path1/$(get_file_name "$file").webp"
        ffmpeg_no_banner -i "$file" -vf "$(filter_for_compress_with_copyright "png")" -pix_fmt pal8 "$output_path2/$(lowercase_file_name_extension "$file")"
        ((operation_count += 2))
        show_progress_bar $(("$all_count" * 2)) "$operation_count"
    done
    for file in $(file_extension_for_loop "jpg" "jpeg"); do
        ffmpeg_no_banner -i "$file" -vf "$(copyright_watermark)" "$output_path1/$(get_file_name "$file").webp"
        ffmpeg_no_banner -i "$file" -vf "$(copyright_watermark)" "$output_path2/$(lowercase_file_name_extension "$file")"
        ((operation_count += 2))
        show_progress_bar $(("$all_count" * 2)) "$operation_count"
    done
    for file in $(file_extension_for_loop "gif"); do
        ffmpeg_no_banner -i "$file" -vf "$(copyright_watermark)" "$output_path1/$(get_file_name "$file").webp"
        ffmpeg_no_banner -i "$file" -vf "$(filter_for_compress_with_copyright "gif")" "$output_path2/$(lowercase_file_name_extension "$file")"
        ((operation_count += 2))
        show_progress_bar $(("$all_count" * 2)) "$operation_count"
    done
    log_end "$operation_count" "$all_count"
    log_result "$feature_note"
    shopt -u nullglob
}
