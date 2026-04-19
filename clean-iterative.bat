@echo off

:: Only run if the folder exists
if exist "build\iterative" (
    del /f /q build\iterative\*.vvp build\iterative\*.vcd 2>nul
    
    echo ===============================
    echo    SUCCESS: Iterative Environment Cleaned
    echo ===============================
) else (
    echo ===============================
    echo    NOTICE: Nothing to clean.
    echo ===============================
)