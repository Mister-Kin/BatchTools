@chcp 936>nul
@echo off & title �޸�QT Creatorģ���ļ���֧��C++20 & color F0
cd /d "%~dp0"

goto :start_job

:draw_line
@REM �ֲ��������ô�ӡ�ķ��ź������������ݵ�ȫ�ֻ���draw_line_chars������
setlocal enabledelayedexpansion
@REM ��ѯ��ǰ�ն˴��ڵ�������С��delims����:֮��û�пո񣬻����ж���ո���һ����Ч�������޷�trim����Ŀո񡣲���:���治�ܵ�����һ���ո񣬷����޷���ȷ��ȡ��
for /f "tokens=2 delims=:" %%c in ('mode con ^| findstr "��"') do set cols=%%c
@REM �Ƴ���������߶���Ŀո�
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
echo [32m�ѳɹ��޸�ģ���ļ�����C++20��%~1��[30m
echo.
exit /b

:copy_failed_text
echo [31m�޷��޸�ģ���ļ�����C++20��%~1������ص��������������л����ֶ����и���[30m
echo.
echo �밴������˳����߹ر��ն˴����˳�
echo.
@pause>nul
exit

:start_job
cls
call :draw_line "="
echo.

@REM ���Ȩ�ޣ�����ϵͳ�汾���Է���ϵͳ�ļ�·��
if "%PROCESSOR_ARCHITECTURE%" equ "amd64" (
    "%SYSTEMROOT%\SysWOW64\cacls.exe" "%SYSTEMROOT%\SysWOW64\config\system" >nul 2>&1
) else (
    "%SYSTEMROOT%\system32\cacls.exe" "%SYSTEMROOT%\system32\config\system" >nul 2>&1
)

@REM ����Ȩ�������ת��ǩ
if "%errorlevel%" neq "0" (
    call :log "��ǰ����޹���ԱȨ�ޡ������������ԱȨ��..."
    echo.
    goto uac_prompt
) else (
    goto got_admin
)

@REM ��ȡ����ԱȨ��
:uac_prompt
powershell -Command "Start-Process -Verb RunAs -FilePath '%0' -ArgumentList 'am_admin'"
exit /b

@REM �ѻ�ȡ����ԱȨ�ޣ��洢��ǰĿ¼���л����ű�����Ŀ¼
:got_admin
pushd "%cd%"
cd /d "%~dp0"

cls
call :draw_line "="
echo.
call :log "��ӭʹ�á��Զ��޸�QT Creator����ģ���ļ���֧��C++20����������"
echo.
call :log_with_quote "�������ߣ�Mr. Kin im.misterkin@gmail.com"
echo.
call :draw_line "="
echo.
call :log "����������û�����·�����Զ���ѯ���޸�QT Creator����ģ���ļ���֧��C++20"
echo.
call :draw_line "="
echo.
pushd "%cd%"

setlocal
set /p user_input="������QT Creator�İ�װ·����"
echo.
call :draw_line "-"
echo.
:cd_loop
if not exist "%user_input%" (
    set /p user_input="��ǰ����·�������ڣ�����������QT Creator�İ�װ·����"
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
    echo ��ǰ��⵽����·���к��С�share\qtcreator\templates\wizards\projects������ģ���ļ���
    echo.
    set "file_path=%user_input%\share\qtcreator\templates\wizards\projects"
    set qt_flag=true
)
if %qt_flag% == false (
    echo ��ǰ��δ��⵽����·�����С�share\qtcreator\templates\wizards\projects������ģ���ļ���
    echo.
    set /p user_input="����������QT Creator�İ�װ·�����س���"
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
echo ��ǰ·��Ϊ��%cd%��
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
echo �����ģ���ļ����޸ĳ�����鿴������־��ȷ���Ƿ��ѳɹ�
echo.
call :draw_line "="
echo.
echo �밴��������߹رմ˴����˳�
echo.
@pause >nul
exit
