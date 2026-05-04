@echo off
title Plant Scanner - Backend
color 0A
echo ==========================================
echo   Plant Scanner Backend (FastAPI)
echo ==========================================
echo.

cd /d "%~dp0backend"

:: Verificar API key
findstr /C:"PEGAR_TU_API_KEY_AQUI" .env >nul 2>&1
if %errorlevel%==0 (
    echo [ERROR] Todavia no configuraste tu API key de Anthropic!
    echo.
    echo 1. Ve a https://console.anthropic.com
    echo 2. Copia tu API key
    echo 3. Abre el archivo: %~dp0backend\.env
    echo 4. Reemplaza PEGAR_TU_API_KEY_AQUI con tu key real
    echo.
    pause
    exit /b 1
)

echo Iniciando servidor en http://localhost:8000 ...
echo (Dejá esta ventana abierta)
echo.
python -m uvicorn main:app --host 0.0.0.0 --port 8000 --reload
pause
