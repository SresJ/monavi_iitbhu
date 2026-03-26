@echo off
echo ================================
echo Clinical Dashboard Backend
echo ================================
echo.

echo Installing missing dependencies...
pip install email-validator

echo.
echo Clearing Python cache...
for /d /r . %%d in (__pycache__) do @if exist "%%d" rd /s /q "%%d"
del /s /q *.pyc 2>nul

echo.
echo Starting server...
echo Access Swagger UI at: http://localhost:8000/docs
echo.
uvicorn app.main:app --reload --host 0.0.0.0 --port 8000
