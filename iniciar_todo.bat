@echo off
set PY=C:\Users\galea\AppData\Local\Programs\Python\Python312\python.exe

echo Iniciando backend...
start "Backend" cmd /k "cd /d C:\Users\galea\plant-scanner\backend && "%PY%" -m uvicorn main:app --host 127.0.0.1 --port 8000"

echo Esperando que inicie el backend...
timeout /t 5 /nobreak > nul

echo Iniciando servidor web...
start "App Web" cmd /k ""%PY%" -m http.server 5050 --directory C:\Users\galea\plant-scanner\mobile\build\web"

echo Esperando que inicie el servidor web...
timeout /t 3 /nobreak > nul

echo Abriendo Chrome...
start chrome "http://localhost:5050"

echo Listo! Deja estas ventanas abiertas mientras usas la app.
