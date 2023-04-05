#!/bin/bash

ffmpeg_no_banner() {
    # ffmpeg -hide_banner "$@" # 用以调试
    ffmpeg -hide_banner -loglevel error "$@"
}

copyright_watermark() {
    local copyright_text="© Mr. Kin"
    local font_path="C\:\/Windows\/fonts\/SourceSans3-Semibold.otf"
    local watermark_effect="split [main][tmp]; [tmp] drawtext=text='$copyright_text':fontfile='$font_path':fontcolor=white:fontsize=50:bordercolor=black:borderw=1.5:shadowcolor=black:shadowx=1.8:shadowy=1.8:x=50:y=50 [toplayer]; [main][toplayer] overlay"
    printf "%s" "$watermark_effect"
}

filter_for_compress() {
    if [ "$1" = "png" ]; then
        printf "split[main][tmp]; [tmp]palettegen=max_colors=256:stats_mode=single[palette]; [main][palette] paletteuse"
    elif [ "$1" = "gif" ]; then
        printf "split[main][tmp]; [tmp]palettegen[palette]; [main][palette]paletteuse"
    fi
}

filter_for_compress_with_copyright() {
    local effect_copyright
    effect_copyright=$(copyright_watermark)
    if [ "$1" = "png" ]; then
        local compress_png
        compress_png=$(filter_for_compress "png")
        printf "%s" "$effect_copyright, $compress_png"
    elif [ "$1" = "gif" ]; then
        local compress_gif
        compress_gif=$(filter_for_compress "gif")
        printf "%s" "$effect_copyright, $compress_gif"
    fi
}

get_media_info() {
    printf "%s" "$(ffprobe -hide_banner -loglevel error -show_entries "$2" -of default=noprint_wrappers=1:nokey=1 "$1")"
}

get_media_info_for_time() {
    printf "%s" "$(ffprobe -hide_banner -loglevel error -show_entries "$2" -of default=noprint_wrappers=1:nokey=1 -sexagesimal "$1")"
}
