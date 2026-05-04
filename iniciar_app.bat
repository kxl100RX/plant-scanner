@echo off
title Plant Scanner - Flutter App
color 0B
echo ==========================================
echo   Plant Scanner - App Flutter
echo ==========================================
echo.

cd /d "%~dp0mobile"

:: Verificar que Flutter existe
where flutter >nul 2>&1
if %errorlevel% neq 0 (
    :: Intentar con la ruta de instalacion por defecto
    if exist "C:\Users\%USERNAME%\flutter\bin\flutter.bat" (
        set PATH=C:\Users\%USERNAME%\flutter\bin;%PATH%
    ) else (
        echo [ERROR] Flutter no esta instalado o no esta en el PATH.
        echo Ejecuta primero: instalar_flutter.bat
        pause
        exit /b 1
    )
)

echo Descargando dependencias de Flutter...
flutter pub get

echo.
echo Conecta tu telefono Android (USB debugging activado) o abre un emulador.
echo.
flutter run
pause
