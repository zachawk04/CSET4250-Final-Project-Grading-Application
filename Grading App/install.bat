@echo off
setlocal

:: 1. Batch Script to check for Admin rights and launch PowerShell
echo Starting installer...

:: Check for permissions
>nul 2>&1 "%SYSTEMROOT%\system32\cacls.exe" "%SYSTEMROOT%\system32\config\system"

:: If error level is not 0, we do not have admin rights.
if '%errorlevel%' NEQ '0' (
    echo Requesting administrator permissions...
    goto UACPrompt
) else (
    goto gotAdmin
)

:UACPrompt
    :: Relaunch this same batch file with admin rights
    echo Set UAC = CreateObject^("Shell.Application"^) > "%temp%\getadmin.vbs"
    echo UAC.ShellExecute "%~s0", "", "", "runas", 1 >> "%temp%\getadmin.vbs"
    "%temp%\getadmin.vbs"
    del "%temp%\getadmin.vbs"
    exit /B

:gotAdmin
    :: We have admin rights, so we can run the PowerShell script.
    
    :: Get the directory where this .bat file is located
    set "scriptPath=%~dp0"
    
    :: Launch the PowerShell script, bypassing execution policy for this one run
    powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%scriptPath%installer.ps1"
    
    echo.
    echo Script finished.
    pause
    exit /B