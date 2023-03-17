#!/bin/bash

ffmpeg_no_banner() {
    ffmpeg -hide_banner "$@"
}
