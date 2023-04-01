# Batch Tools

## Introduction
Some batch scripts for easily doing work.

## Features
- ffmpeg.sh
  - 个人工作：批量操作媒体资源
    - 给图片添加文字版权水印并压缩
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
    - wav格式转m4a格式
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
  - 合并文本文件（文件首尾拼接）
  -  合并文本文件（逐行拼接合并）

## Usage
[Jump to Documentation Page][]

[Jump to Documentation Page]: https://mister-kin.github.io/works/software-works/batch-tools/

Just execute the script file and follow the hint after inputting following command in shell terminal:

`cd drive:/path/BatchTools/ && ./ffmpeg.sh`

## Author
**BatchTools** © Mr. Kin, all files released under the [WTFPL][] license.

Authored and maintained by Mr. Kin.

> [Blog][] · [GitHub][] · [Weibo][] · [Zhihu][] · [AcFun][] · [Bilibili][] · [Youku][] · [Headline][] · [YouTube][]

[WTFPL]: ./LICENSE
[Blog]: https://mister-kin.github.io
[GitHub]: https://github.com/mister-kin
[Weibo]: https://weibo.com/6270111192/profile?topnav=1&wvr=6&is_all=1
[Bilibili]: http://space.bilibili.com/17025250?
[Youku]: http://i.youku.com/i/UNjA3MTk5Mjgw?spm=a2hzp.8253869.0.0
[YouTube]: https://www.youtube.com/channel/UCNhtdG6whC5mlRDkrhQ0wLA?view_as=public
[Headline]: https://www.toutiao.com/c/user/835254071079053/#mid=1663279303982091
[Zhihu]: https://www.zhihu.com/people/drwu-94
[AcFun]: https://www.acfun.cn/u/73269306
