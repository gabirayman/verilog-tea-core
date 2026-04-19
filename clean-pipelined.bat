@echo off

:: Only run if the folder exists
if exist "build\pipelined" (
    del /f /q build\pipelined\*.vvp build\pipelined\*.vcd 2>nul
    
    echo ===============================
    echo    SUCCESS: Pipelined Environment Cleaned
    echo ===============================
) else (
    echo ===============================
    echo    NOTICE: Nothing to clean.
    echo ===============================
)