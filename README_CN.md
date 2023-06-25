语言: [英][Readme] 中

[Readme]: ./README.md

# 批处理工具
![Shell Type][] [![License][]](./LICENSE)

[Shell Type]: https://img.shields.io/badge/shell-Git_Bash_|_Zsh-blue
[License]: https://img.shields.io/github/license/Mister-Kin/BatchTools?color=blue

## 介绍
一些方便工作的批处理脚本。

## 功能
- ffmpeg.sh
  - 个人工作：批量操作媒体资源
    - 给图片添加版权文字水印并压缩
    - 给视频添加文字版权水印（libx264）
    - 图片序列导出mp4格式视频（libx264）
    - 重编码视频导出mp4格式视频（libx264）
    - 添加字幕（硬编码，libx264）
    - 显卡加速将图片序列合成为视频（不再维护该功能）
  - 压缩媒体资源
    - 压缩图片（原格式压缩或者转换为webp格式）
    - 压缩视频，转换为hevc编码的mp4格式（libx265）
  - 图片转换器：图片格式互转
    - 图片转png格式
  - 视频转换器：视频格式互转
    - flv格式转mp4格式
  - 音频转换器：音频格式互转
    - 无损音频转m4a格式
  - 音频元数据标签工具
    - 根据元数据标签重命名音频文件
    - 根据音频文件名修改元数据标签
    - 设置音频文件的专辑名
    - 设置音频文件的歌曲名
    - 设置音频文件的歌手名
  - 音频封面图工具：获取、添加、删除
    - 获取音频封面图
    - 添加音频封面图
    - 删除音频封面图
  - 媒体资源工具：合并、分割、缩放
    - 合并音视频：mp4+m4a/mp3
    - 分割视频
- text.sh
  - 合并文本文件
    - 合并文本文件（文件首尾拼接）
    - 合并文本文件（逐行拼接合并）
- ffmpeg.bat（不再维护bat）
  - 给图片添加版权水印并压缩
  - 图片压缩：转 webp
  - 合并音视频：mp4 + m4a
  - 视频转封装：flv -> mp4
  - 视频压缩：转 hevc 编码（libx265）
  - 显卡加速图片序列合成视频：普通录屏（jpg + wav -> h264_nvenc + aac）
  - 显卡加速图片序列合成视频：CG（png + wav -> h264_nvenc + aac）

## 用法
[跳转到文档页面][]

[跳转到文档页面]: https://mister-kin.github.io/works/software-works/batch-tools/

1. 克隆本仓库到本地机器上。
2. 将 FFmpeg 可执行二进制文件的路径添加到系统环境变量 `PATH` 中。
3. 在 shell 终端中输入以下命令，执行脚本文件并按照提示操作。

`cd drive:/path/BatchTools/ && ./ffmpeg.sh`

上方命令中的 `drive:/path` 取决于实际的文件路径。

## 作者
**批处理工具** © Mr. Kin，所有文件均采用 [WTFPL][] 许可协议进行发布。

由 Mr. Kin 著作并维护。

> [博客][] · [GitHub][] · [微博][] · [知乎][] · [AcFun][] · [哔哩哔哩][] · [优酷][] · [头条][] · [油管][]

[WTFPL]: ./LICENSE
[博客]: https://mister-kin.github.io
[GitHub]: https://github.com/mister-kin
[微博]: https://weibo.com/6270111192
[知乎]: https://www.zhihu.com/people/drwu-94
[哔哩哔哩]: http://space.bilibili.com/17025250?
[优酷]: http://i.youku.com/i/UNjA3MTk5Mjgw?spm=a2hzp.8253869.0.0
[头条]: https://www.toutiao.com/c/user/835254071079053/#mid=1663279303982091
[油管]: https://www.youtube.com/@Mister-Kin
[AcFun]: https://www.acfun.cn/u/73269306
