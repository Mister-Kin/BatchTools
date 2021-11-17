@echo off & title FFmpeg Media Tools & color 70
@chcp 65001>nul
:menu
cls
echo ======================================================
echo.
echo        1、给图片添加版权水印并压缩
echo.
echo        2、图片压缩：转 webp
echo.
echo        3、合并音视频：mp4 + m4a
echo.
echo        4、视频转封装：flv -^> mp4
echo.
echo        5、视频压缩：转 hevc 编码（libx265）
echo.
echo        6、显卡加速图片序列合成视频：普通录屏（jpg + wav -^> h264_nvenc + aac）
echo.
echo        7、显卡加速图片序列合成视频：CG（png + wav -^> h264_nvenc + aac）
echo.
echo ======================================================
echo.
set /p menu_number=请输入菜单对应数字：

if %menu_number% equ 1 goto ImageAddWatermark
if %menu_number% equ 2 goto Image2Webp
if %menu_number% equ 3 goto MergeMp4_M4a
if %menu_number% equ 4 goto Flv2Mp4
if %menu_number% equ 5 goto Video2hevc
if %menu_number% equ 6 goto ImageSequence2Video_Normal
if %menu_number% equ 7 goto ImageSequence2Video_CG

rem ffmpeg for语句中的变量 %%i 还是需要用 "" ，否则无法识别带（）的文件名。文件名或含有特殊符号，（）或者空格啥的。

:MergeMp4_M4a
cls
echo ======================================================
echo.
echo             功能：合并 mp4视频 和 m4a音频
echo.
echo   输入路径可执行该操作，路径有特殊符号时，请用 "" 包含路径。
echo.
echo                  输入 0 返回主菜单
echo.
echo ======================================================
echo.
set /p file_path=请输入：
if %file_path% equ 0 (goto menu) else cd /d %file_path%
ren *.* 1.*
ffmpeg -i 1.mp4 -i 1.m4a -c:v copy -c:a copy output.mp4
echo ======================================================
echo.
echo         转换结束，若成功则输出 output.mp4 文件
echo.
echo                    按任意键继续
echo.
echo ======================================================
@pause>nul
goto MergeMp4_M4a

:ImageAddWatermark
cls
echo ======================================================
echo.
echo            功能：给图片添加版权水印并压缩
echo.
echo   输入路径可执行该操作，路径有特殊符号时，请用 "" 包含路径。
echo.
echo                  输入 0 返回主菜单
echo.
echo ======================================================
echo.
set /p file_path=请输入：
if %file_path% equ 0 (goto menu) else cd /d %file_path%
if exist ForWeb (del /q ForWeb) else mkdir ForWeb
if exist ForDoc (del /q ForDoc) else mkdir ForDoc
for %%i in (*.png) do ffmpeg -i "%%i" -vf "split [main][tmp]; movie=G\\:/VideoTemplate/WaterMark.png[Logo]; [tmp][Logo] overlay=x=35:y=35 [tmp_output]; [main][tmp_output] overlay" "ForWeb\%%~ni.webp"
for %%i in (*.png) do ffmpeg -i "%%i" -vf "split [main][tmp]; movie=G\\:/VideoTemplate/WaterMark.png[Logo]; [tmp][Logo] overlay=x=35:y=35 [tmp_output]; [main][tmp_output] overlay" "ForDoc\%%~ni.jpg"
for %%i in (*.gif) do ffmpeg -i "%%i" -vf "split [main][tmp]; movie=G\\:/VideoTemplate/WaterMark.png[Logo]; [tmp][Logo] overlay=x=35:y=35 [tmp_output]; [main][tmp_output] overlay" "ForWeb\%%~ni.webp"
echo ======================================================
echo.
echo       转换结束，若成功请查看 ForWeb 和 ForDoc 文件夹
echo.
echo                    按任意键继续
echo.
echo ======================================================
@pause>nul
goto ImageAddWatermark

:Flv2Mp4
cls
echo ======================================================
echo.
echo             功能：flv 格式转 mp4 格式
echo.
echo   输入路径可执行该操作，路径有特殊符号时，请用 "" 包含路径。
echo.
echo                  输入 0 返回主菜单
echo.
echo ======================================================
echo.
set /p file_path=请输入：
if %file_path% equ 0 (goto menu) else cd /d %file_path%
for %%i in (*.flv) do (ffmpeg -i "%%i" -c copy "%%~ni.mp4")
echo ======================================================
echo.
echo             转换结束，若成功则输出 mp4 文件
echo.
echo                    按任意键继续
echo.
echo ======================================================
@pause>nul
goto Flv2Mp4

:Image2Webp
cls
echo ======================================================
echo.
echo           功能：压缩图片，全部转为 webp 格式
echo.
echo    输入路径可执行该操作，路径有特殊符号时，请用 "" 包含路径。
echo.
echo                  输入 0 返回主菜单
echo.
echo ======================================================
echo.
set /p file_path=请输入：
if %file_path% equ 0 (goto menu) else cd /d %file_path%
if exist ImageCompress (del /q ImageCompress) else mkdir ImageCompress
for %%i in (*.png) do (ffmpeg -i "%%i" "ImageCompress\%%~ni.webp")
for %%i in (*.jpg) do (ffmpeg -i "%%i" "ImageCompress\%%~ni.webp")
for %%i in (*.gif) do (ffmpeg -i "%%i" "ImageCompress\%%~ni.webp")
echo ======================================================
echo.
echo         转换结束，若成功则查看 ImageCompress 文件夹
echo.
echo                    按任意键继续
echo.
echo ======================================================
cd /d %~dp0
@pause>nul
goto Image2Webp

:Video2hevc
cls
echo ======================================================
echo.
echo         功能：视频压缩，全部转为 hevc 编码（libx265）
echo.
echo    输入路径可执行该操作，路径有特殊符号时，请用 "" 包含路径。
echo.
echo                  输入 0 返回主菜单
echo.
echo ======================================================
echo.
set /p file_path=请输入：
if %file_path% equ 0 (goto menu) else cd /d %file_path%
if exist VideoCompress (del /q VideoCompress) else mkdir VideoCompress
for %%i in (*.mp4) do (ffmpeg -i "%%i" -c:v libx265 -c:a copy "VideoCompress\%%~ni.mp4")
for %%i in (*.flv) do (ffmpeg -i "%%i" -c:v libx265 -c:a copy "VideoCompress\%%~ni.mp4")
for %%i in (*.mov) do (ffmpeg -i "%%i" -c:v libx265 -c:a copy "VideoCompress\%%~ni.mp4")
echo ======================================================
echo.
echo         转换结束，若成功则查看 VideoCompress 文件夹
echo.
echo                    按任意键继续
echo.
echo ======================================================
cd /d %~dp0
@pause>nul
goto Video2hevc

:ImageSequence2Video_Normal
cls
echo ======================================================
echo.
echo  功能：显卡加速图片序列合成视频：普通录屏（jpg + wav -^> h264_nvenc + aac）
echo.
echo    输入路径可执行该操作，路径有特殊符号时，请用 "" 包含路径。
echo.
echo                  输入 0 返回主菜单
echo.
echo ======================================================
echo.
set /p file_path=请输入：
if %file_path% equ 0 (goto menu) else cd /d %file_path%
set /p name_length=请输入图片序列名的长度：
ffmpeg -r 24 -f image2 -i %%name_length%d.jpg -r 24 -c:v h264_nvenc -profile:v high -level 5.1 -preset slow -rc:v vbr_hq -cq:v 19 -b:v 2500k -maxrate:v 5000k output.mp4
echo ======================================================
echo.
echo         转换结束，若成功则
echo.
echo                    按任意键继续
echo.
echo ======================================================
@pause>nul
goto ImageSequence2Video_Normal

rem ffmpeg -f concat -i filelist.txt -c copy output.mp4
