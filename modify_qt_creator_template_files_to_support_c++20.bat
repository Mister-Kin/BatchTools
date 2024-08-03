@chcp 936>nul
@echo off & title ÐÞ¸ÄQT CreatorÄ£°åÎÄ¼þÒÔÖ§³ÖC++20 & color F0
cd /d "%~dp0"

goto :start_job

:draw_line
@REM ¾Ö²¿»·¾³ÉèÖÃ´òÓ¡µÄ·ûºÅºÍÊýÁ¿£¬²¢´«µÝµ½È«¾Ö»·¾³draw_line_chars±äÁ¿ÖÐ
setlocal enabledelayedexpansion
@REM ²éÑ¯µ±Ç°ÖÕ¶Ë´°¿ÚµÄÁÐÊý´óÐ¡£¬delimsºóÃæ:Ö®ºóÃ»ÓÐ¿Õ¸ñ£¬»òÕßÓÐ¶à¸ö¿Õ¸ñ¶¼ÊÇÒ»ÑùµÄÐ§¹û£¬ËüÎÞ·¨trim¶àÓàµÄ¿Õ¸ñ¡£²¢ÇÒ:ºóÃæ²»ÄÜµ¥¶À¼ÓÒ»¸ö¿Õ¸ñ£¬·ñÔòÎÞ·¨ÕýÈ·»ñÈ¡¡£
for /f "tokens=2 delims=:" %%c in ('mode con ^| findstr "ÁÐ"') do set cols=%%c
@REM ÒÆ³ý±äÁ¿ÖÐ×ó±ß¶àÓàµÄ¿Õ¸ñ
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
echo [32mÒÑ³É¹¦ÐÞ¸ÄÄ£°åÎÄ¼þÊÊÅäC++20¡¸%~1¡¹[30m
echo.
exit /b

:copy_failed_text
echo [31mÎÞ·¨ÐÞ¸ÄÄ£°åÎÄ¼þÊÊÅäC++20¡¸%~1¡¹£¬Çë¹Øµô³ÌÐò³¢ÊÔÖØÐÂÔËÐÐ»òÕßÊÖ¶¯½øÐÐ¸´ÖÆ[30m
echo.
echo Çë°´ÈÎÒâ¼üÍË³ö»òÕß¹Ø±ÕÖÕ¶Ë´°¿ÚÍË³ö
echo.
@pause>nul
exit

:start_job
cls
call :draw_line "="
echo.

@REM ¼ì²âÈ¨ÏÞ£º¸ù¾ÝÏµÍ³°æ±¾³¢ÊÔ·ÃÎÊÏµÍ³ÎÄ¼þÂ·¾¶
if "%PROCESSOR_ARCHITECTURE%" equ "amd64" (
    "%SYSTEMROOT%\SysWOW64\cacls.exe" "%SYSTEMROOT%\SysWOW64\config\system" >nul 2>&1
) else (
    "%SYSTEMROOT%\system32\cacls.exe" "%SYSTEMROOT%\system32\config\system" >nul 2>&1
)

@REM ¸ù¾ÝÈ¨ÏÞÇé¿öÌø×ª±êÇ©
if "%errorlevel%" neq "0" (
    call :log "µ±Ç°¼ì²âÎÞ¹ÜÀíÔ±È¨ÏÞ¡£ÕýÔÚÇëÇó¹ÜÀíÔ±È¨ÏÞ..."
    echo.
    goto uac_prompt
) else (
    goto got_admin
)

@REM »ñÈ¡¹ÜÀíÔ±È¨ÏÞ
:uac_prompt
powershell -Command "Start-Process -Verb RunAs -FilePath '%0' -ArgumentList 'am_admin'"
exit /b

@REM ÒÑ»ñÈ¡¹ÜÀíÔ±È¨ÏÞ£¬´æ´¢µ±Ç°Ä¿Â¼²¢ÇÐ»»µ½½Å±¾³ÌÐòÄ¿Â¼
:got_admin
pushd "%cd%"
cd /d "%~dp0"

cls
call :draw_line "="
echo.
call :log "»¶Ó­Ê¹ÓÃ¡¸×Ô¶¯ÐÞ¸ÄQT Creator¹¤³ÌÄ£°åÎÄ¼þÒÔÖ§³ÖC++20¡¹×ÔÖú³ÌÐò"
echo.
call :log_with_quote "³ÌÐò×÷Õß£ºMr. Kin im.misterkin@gmail.com"
echo.
call :draw_line "="
echo.
call :log "±¾³ÌÐò¸ù¾ÝÓÃ»§ÊäÈëÂ·¾¶£¬×Ô¶¯²éÑ¯²¢ÐÞ¸ÄQT Creator¹¤³ÌÄ£°åÎÄ¼þÒÔÖ§³ÖC++20"
echo.
call :draw_line "="
echo.
pushd "%cd%"

setlocal
set /p user_input="ÇëÊäÈëQT CreatorµÄ°²×°Â·¾¶£º"
echo.
call :draw_line "-"
echo.
:cd_loop
if not exist "%user_input%" (
    set /p user_input="µ±Ç°ÊäÈëÂ·¾¶²»´æÔÚ£¬ÇëÖØÐÂÊäÈëQT CreatorµÄ°²×°Â·¾¶£º"
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
    echo µ±Ç°¼ì²âµ½ÊäÈëÂ·¾¶ÖÐº¬ÓÐ¡¸share\qtcreator\templates\wizards\projects¡¹¹¤³ÌÄ£°åÎÄ¼þ¼Ð
    echo.
    set "file_path=%user_input%\share\qtcreator\templates\wizards\projects"
    set qt_flag=true
)
if %qt_flag% == false (
    echo µ±Ç°²¢Î´¼ì²âµ½ÊäÈëÂ·¾¶º¬ÓÐ¡¸share\qtcreator\templates\wizards\projects¡¹¹¤³ÌÄ£°åÎÄ¼þ¼Ð
    echo.
    set /p user_input="ÇëÖØÐÂÊäÈëQT CreatorµÄ°²×°Â·¾¶²¢»Ø³µ£º"
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
echo µ±Ç°Â·¾¶Îª¡¸%cd%¡¹
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
echo ÒÑÍê³ÉÄ£°åÎÄ¼þµÄÐÞ¸Ä³ÌÐò£¬Çë²é¿´ÉÏÊöÈÕÖ¾£¬È·ÈÏÊÇ·ñÒÑ³É¹¦
echo.
call :draw_line "="
echo.
echo Çë°´ÈÎÒâ¼ü»òÕß¹Ø±Õ´Ë´°¿ÚÍË³ö
echo.
@pause >nul
exit
