@echo off
setlocal

:: =========================================
:: Setup Rename Folders (HKCU)
:: =========================================

set "DEST=%LOCALAPPDATA%\rename_folders"

echo Install path: "%DEST%"

:: 1) Create destination folder
if not exist "%DEST%" (
    mkdir "%DEST%"
    if errorlevel 1 (
        echo Failed to create folder "%DEST%"
        pause
        exit /b 1
    )
)

:: 2) Copy files
copy "%~dp0rename_folders.ps1" "%DEST%\" /Y >nul || (
    echo Failed to copy rename_folders.ps1
    pause
    exit /b 1
)
copy "%~dp0run_rename_folders.vbs" "%DEST%\" /Y >nul || (
    echo Failed to copy run_rename_folders.vbs
    pause
    exit /b 1
)
copy "%~dp0add_context_menu.reg" "%DEST%\" /Y >nul || (
    echo Failed to copy add_context_menu.reg
    pause
    exit /b 1
)

:: 3) Create registry file from template with runtime path
set "REGFILE=%DEST%\add_context_menu.generated.reg"
set "DEST_ESC=%DEST:\=\\%"
(

    echo Windows Registry Editor Version 5.00
    echo.
    echo [HKEY_CURRENT_USER\Software\Classes\Directory\shell\RenameFoldersPS]
    echo @="Rename Folders (PS)"
    echo "Icon"="powershell.exe"
    echo.
    echo [HKEY_CURRENT_USER\Software\Classes\Directory\shell\RenameFoldersPS\command]
    echo @="wscript.exe \"%DEST_ESC%\\run_rename_folders.vbs\" \"%%1\""
) > "%REGFILE%"

reg import "%REGFILE%"
if errorlevel 1 (
    echo Registry import failed.
    pause
    exit /b 1
)

echo.
echo Installed successfully.
echo Right-click on a folder and select "Rename Folders (PS)".
pause
