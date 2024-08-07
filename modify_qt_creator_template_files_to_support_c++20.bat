@chcp 936>nul
@echo off & title 修改QT Creator模板文件以支持C++20 & color F0
cd /d "%~dp0"

goto :start_job

:draw_line
@REM 局部环境设置打印的符号和数量，并传递到全局环境draw_line_chars变量中
setlocal enabledelayedexpansion
@REM 查询当前终端窗口的列数大小，delims后面:之后没有空格，或者有多个空格都是一样的效果，它无法trim多余的空格。并且:后面不能单独加一个空格，否则无法正确获取。
for /f "tokens=2 delims=:" %%c in ('mode con ^| findstr "列"') do set cols=%%c
@REM 移除变量中左边多余的空格
for /f "tokens=* delims=: " %%c in ('echo %cols%') do set cols=%%c
set "char=%~1"
set /a "count=%cols%"
set "line="
for /l %%i in (1,1,%count%) do set "line=!line!%char%"
endlocal & set "draw_line_chars=%line%"
echo %draw_line_chars%
exit /b

:log
setlocal
for /f "tokens=1-3 delims=/ " %%a in ('date /t') do (set "yy=%%a" & set "mm=%%b" & set "dd=%%c")
for /f "tokens=1-3 delims=:." %%a in ('echo %time%') do (set "hh=%%a" & set "mn=%%b" & set "ss=%%c")
set time_stamp=%yy%-%mm%-%dd%T%hh%:%mn%:%ss%+08:00
echo %time_stamp% %~1
endlocal
exit /b

:log_with_quote
setlocal
for /f "tokens=1-3 delims=/ " %%a in ('date /t') do (set "yy=%%a" & set "mm=%%b" & set "dd=%%c")
for /f "tokens=1-3 delims=:." %%a in ('echo %time%') do (set "hh=%%a" & set "mn=%%b" & set "ss=%%c")
set time_stamp=%yy%-%mm%-%dd%T%hh%:%mn%:%ss%+08:00
echo %time_stamp% "%~1"
endlocal
exit /b

:replace_string_in_file
setlocal
set "search_string=%~2"
set "replace_string=%~3"
set "file_path=%~1"
powershell -Command "(Get-Content -Path '%file_path%') -replace '%search_string%', '%replace_string%' | Set-Content -Path '%file_path%'"
if "%errorlevel%" EQU "0" (
    call :copy_success_text "%file_path%"
) else (
    call :copy_failed_text "%file_path%"
)
endlocal
exit /b

:copy_success_text
echo [32m已成功修改模板文件适配C++20「%~1」[30m
echo.
exit /b

:copy_failed_text
echo [31m无法修改模板文件适配C++20「%~1」，请关掉程序尝试重新运行或者手动进行复制[30m
echo.
echo 请按任意键退出或者关闭终端窗口退出
echo.
@pause>nul
exit

:start_job
cls
call :draw_line "="
echo.

@REM 检测权限：根据系统版本尝试访问系统文件路径
if "%PROCESSOR_ARCHITECTURE%" equ "amd64" (
    "%SYSTEMROOT%\SysWOW64\cacls.exe" "%SYSTEMROOT%\SysWOW64\config\system" >nul 2>&1
) else (
    "%SYSTEMROOT%\system32\cacls.exe" "%SYSTEMROOT%\system32\config\system" >nul 2>&1
)

@REM 根据权限情况跳转标签
if "%errorlevel%" neq "0" (
    call :log "当前检测无管理员权限。正在请求管理员权限..."
    echo.
    goto uac_prompt
) else (
    goto got_admin
)

@REM 获取管理员权限
:uac_prompt
powershell -Command "Start-Process -Verb RunAs -FilePath '%0' -ArgumentList 'am_admin'"
exit /b

@REM 已获取管理员权限，存储当前目录并切换到脚本程序目录
:got_admin
pushd "%cd%"
cd /d "%~dp0"

cls
call :draw_line "="
echo.
call :log "欢迎使用「自动修改QT Creator工程模板文件以支持C++20」自助程序"
echo.
call :log_with_quote "程序作者：Mr. Kin im.misterkin@gmail.com"
echo.
call :draw_line "="
echo.
call :log "本程序根据用户输入路径，自动查询并修改QT Creator工程模板文件以支持C++20"
echo.
call :draw_line "="
echo.
pushd "%cd%"

setlocal
set /p user_input="请输入QT Creator的安装路径："
echo.
call :draw_line "-"
echo.
:cd_loop
if not exist "%user_input%" (
    set /p user_input="当前输入路径不存在，请重新输入QT Creator的安装路径："
    echo.
    call :draw_line "-"
    echo.
    goto :cd_loop
)
if "%user_input:~-1%" == "\" (
    set user_input=%user_input:~0,-1%
)
set qt_flag=false
if exist "%user_input%\share\qtcreator\templates\wizards\projects" (
    echo 当前检测到输入路径中含有「share\qtcreator\templates\wizards\projects」工程模板文件夹
    echo.
    set "file_path=%user_input%\share\qtcreator\templates\wizards\projects"
    set qt_flag=true
)
if %qt_flag% == false (
    echo 当前并未检测到输入路径含有「share\qtcreator\templates\wizards\projects」工程模板文件夹
    echo.
    set /p user_input="请重新输入QT Creator的安装路径并回车："
    echo.
    call :draw_line "-"
    echo.
    goto :cd_loop
)
endlocal & set "template_path=%file_path%"
goto :replace_template

:replace_template
call :draw_line "="
echo.
echo 当前路径为「%cd%」
echo.
call :draw_line "="
echo.

call :replace_string_in_file "%template_path%\consoleapp\CMakeLists.txt" "17" "20"
call :replace_string_in_file "%template_path%\cpplibrary\CMakeLists.txt" "17" "20"
call :replace_string_in_file "%template_path%\plaincpp\CMakeLists.txt" "17" "20"
call :replace_string_in_file "%template_path%\qtquickapplication_compat\CMakeLists.txt" "17" "20"
call :replace_string_in_file "%template_path%\qtwidgetsapplication\CMakeLists.txt" "17" "20"

call :replace_string_in_file "%template_path%\consoleapp\file.pro" "17" "20"
call :replace_string_in_file "%template_path%\cpplibrary\project.pro" "17" "20"
call :replace_string_in_file "%template_path%\plaincpp\file.pro" "17" "20"
call :replace_string_in_file "%template_path%\qtwidgetsapplication\project.pro" "17" "20"

call :draw_line "="
echo.
echo 已完成模板文件的修改程序，请查看上述日志，确认是否已成功
echo.
call :draw_line "="
echo.
echo 请按任意键或者关闭此窗口退出
echo.
@pause >nul
exit
