@echo off
:: =========================================
:: Setup Rename Folders (PS) для HKCU
:: =========================================

setlocal

:: Дестинація
set "DEST=D:\rename_folders"

:: 1. Створюємо папку
if not exist "%DEST%" (
    mkdir "%DEST%"
    if errorlevel 1 (
        echo Не вдалося створити папку %DEST%
        pause
        exit /b 1
    )
    echo Папка %DEST% створена.
) else (
    echo Папка %DEST% вже існує.
)

:: 2. Копіюємо файли
echo Копіюємо файли...
copy "%~dp0rename_folders.ps1" "%DEST%\" /Y >nul
if errorlevel 1 echo Помилка копіювання rename_folders.ps1
copy "%~dp0run_rename_folders.vbs" "%DEST%\" /Y >nul
if errorlevel 1 echo Помилка копіювання run_rename_folders.vbs
copy "%~dp0add_context_menu.reg" "%DEST%\" /Y >nul
if errorlevel 1 echo Помилка копіювання add_context_menu.reg

:: 3. Інсталюємо контекстне меню
echo Імпортуємо контекстне меню...
reg import "%DEST%\add_context_menu.reg"
if errorlevel 1 (
    echo Помилка імпорту реєстру! Перевірте кодування .reg (UTF-16 LE)
    pause
    exit /b 1
)

echo.
echo Установка завершена.
echo Контекстне меню "Перейменувати папки (PS)" готове.
pause