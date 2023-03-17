#!/bin/bash

copyright_watermark() {
    local copyright_text="© Mr. Kin"
    local font_path="C\:\/Windows\/fonts\/SourceSans3-Semibold.otf"
    local watermark_effect="split [main][tmp]; [tmp] drawtext=text='$copyright_text':fontfile='$font_path':fontcolor=white:fontsize=50:bordercolor=black:borderw=1.5:shadowcolor=black:shadowx=1.8:shadowy=1.8:x=50:y=50 [toplayer]; [main][toplayer] overlay"
    echo "$watermark_effect"
}

filter_effect_for_compress() {
    if [ "$1" = "png" ]; then
        echo "split[main][tmp]; [tmp]palettegen=max_colors=256:stats_mode=single[palette]; [main][palette] paletteuse"
    elif [ "$1" = "gif" ]; then
        echo "split[main][tmp]; [tmp]palettegen[palette]; [main][palette]paletteuse"
    fi
}
