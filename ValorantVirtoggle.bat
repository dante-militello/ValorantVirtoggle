@echo off
:: Check for admin privileges
>nul 2>&1 "%SYSTEMROOT%\system32\cacls.exe" "%SYSTEMROOT%\system32\config\system"

if '%errorlevel%' NEQ '0' (
    echo Requesting administrative privileges...
    goto UACPrompt
) else ( goto gotAdmin )

:UACPrompt
    echo Set UAC = CreateObject^("Shell.Application"^) > "%temp%\getadmin.vbs"
    echo UAC.ShellExecute "%~s0", "", "", "runas", 1 >> "%temp%\getadmin.vbs"
    "%temp%\getadmin.vbs"
    exit /B

:gotAdmin
if exist "%temp%\getadmin.vbs" ( del "%temp%\getadmin.vbs" )
pushd "%CD%"
CD /D "%~dp0"

:: Script starts here
for /f "tokens=2 delims= " %%a in ('bcdedit ^| findstr /i "hypervisorlaunchtype"') do set status=%%a

echo ----------------------------------------
if /i "%status%"=="Auto" (
    echo Current state: Virtualization ENABLED
) else if /i "%status%"=="Off" (
    echo Current state: Virtualization DISABLED
) else (
    echo Could not determine the current state of virtualization.
    pause
    exit
)
echo ----------------------------------------

:menu
echo.
echo Select an option:
echo.
echo 1. Disable virtualization (for Valorant)
echo 2. Enable virtualization (for virtualization tasks)
echo.
set /p choice="Enter 1 or 2 and press Enter: "

if "%choice%"=="1" (
    echo.
    echo Disabling virtualization...
    dism.exe /Online /Disable-Feature /NoRestart /FeatureName:Microsoft-Hyper-V
    bcdedit /set hypervisorlaunchtype off
    echo.
    echo Virtualization disabled.
) else if "%choice%"=="2" (
    echo.
    echo Enabling virtualization...
    dism.exe /Online /Enable-Feature /NoRestart /FeatureName:Microsoft-Hyper-V
    bcdedit /set hypervisorlaunchtype auto
    echo.
    echo Virtualization enabled.
) else (
    echo.
    echo Invalid option. Please try again.
    goto menu
)



echo ----------------------------------------
echo.
set /p restart="Do you want to restart now? Press 'Y' to restart or 'N' to exit without restarting: "
if /i "%restart%"=="y" (
    echo.
    echo Restarting...
    timeout /t 5
    shutdown /r /t 0
) else (
    echo.
    echo Exiting without restarting.
    pause
    exit
)
