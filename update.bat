@echo off
chcp 65001 >nul
setlocal enabledelayedexpansion

:: 读取配置文件
set "CONFIG=%TEMP%\daokits_update_config.txt"
if not exist "%CONFIG%" (
    echo 配置文件不存在
    pause
    exit /b 1
)

set "EXE_PATH="
set "DOWNLOAD_URL="
set /p EXE_PATH=<"%CONFIG%"
<"%CONFIG%" (
    set /p EXE_PATH=
    set /p DOWNLOAD_URL=
)

:: 等待程序退出
timeout /t 2 /nobreak >nul

:: 下载新文件到临时位置
set "TEMP_EXE=%TEMP%\DaoKits_new.exe"
echo 正在下载更新...
powershell -Command "Invoke-WebRequest -Uri '%DOWNLOAD_URL%' -OutFile '%TEMP_EXE%' -UseBasicParsing"

if not exist "%TEMP_EXE%" (
    echo 下载失败
    pause
    exit /b 1
)

:: 备份旧文件
set "OLD_EXE=%EXE_PATH%.old"
if exist "%EXE_PATH%" (
    move /y "%EXE_PATH%" "%OLD_EXE%" >nul
)

:: 替换为新文件
move /y "%TEMP_EXE%" "%EXE_PATH%" >nul

if not exist "%EXE_PATH%" (
    echo 更新失败，正在恢复...
    if exist "%OLD_EXE%" move /y "%OLD_EXE%" "%EXE_PATH%" >nul
    pause
    exit /b 1
)

:: 删除备份
del /q "%OLD_EXE%" 2>nul

:: 清理配置文件
del /q "%CONFIG%" 2>nul

:: 启动新程序
start "" "%EXE_PATH%"

exit /b 0
