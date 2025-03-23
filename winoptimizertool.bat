@echo off
:checkPrivileges
:: Check if the script is running as administrator
net session >nul 2>&1
if %errorLevel% neq 0 (
    echo Requesting administrative privileges...
    :: Re-run the script as administrator and close the current window
    powershell -Command "Start-Process cmd -ArgumentList '/c %~f0' -Verb RunAs"
    exit /b
)

:: Maximize the Command Prompt window
mode con: cols=150 lines=300
powershell -command "& { (New-Object -ComObject Shell.Application).Windows() | ForEach-Object { $_.Width = 1600; $_.Height = 900; $_.Left = 0; $_.Top = 0 } }"

:: Set the background color to grey and text color to red
color 4F

title Windows Optimizer V1.0
color 4

:: Display the welcome message
cls
echo Welcome to Windows Optimizer V1.0 [The best tool to optimize your PC!]
echo [ WARNING ] THIS WINDOW WILL CLOSE AUTOMATICALLY!
echo [ CREDIT ] MADE BY XKITZ7
echo [ REQUIREMENTS ] MUST RUN AS ADMINISTRATOR TO WORK AND SOME COMMANDS MAY REQUIRE INTERNET CONNECTION
echo [ DISCLAIMER ] USE AT YOUR OWN RISK!
echo [ SUPPORTED OS ] WINDOWS 7 TO WINDOWS 11
echo.
pause

:: Prompt the user for the drive letter
set /p driveLetter=[ NOTICE ] Please enter the drive letter you want to optimize (e.g., C, D, E): 
set driveLetter=%driveLetter%:

:: Execute the series of commands
echo Running DISM /Online /Cleanup-Image /RestoreHealth...
DISM /Online /Cleanup-Image /RestoreHealth
timeout /t 5 /nobreak >nul

echo Running sfc /scannow...
sfc /scannow
timeout /t 5 /nobreak >nul

echo Opening Windows Store for updates...
start ms-windows-store://updates
timeout /t 5 /nobreak >nul

echo Running defrag %driveLetter% /L...
defrag %driveLetter% /L
timeout /t 5 /nobreak >nul

echo Deleting temporary files...
del /q/f/s %TEMP%\*
timeout /t 20 /nobreak >nul

echo Opening Privacy Settings for Background Apps...
start ms-settings:privacy-backgroundapps
timeout /t 10 /nobreak >nul

echo Running chkdsk %driveLetter% /f /r /x...
chkdsk %driveLetter% /f /r /x
timeout /t 15 /nobreak >nul

:: Additional commands
echo Resetting IP settings...
netsh int ip reset
timeout /t 5 /nobreak >nul

echo Resetting Winsock...
netsh winsock reset
timeout /t 5 /nobreak >nul

echo Enabling Ultimate Performance power plan...
powercfg -duplicatescheme e9a42b02-d5df-448d-aa00-03f14749eb61
timeout /t 5 /nobreak >nul

echo Disabling hibernation...
powercfg -h off
timeout /t 5 /nobreak >nul

echo Starting component cleanup...
Dism /Online /Cleanup-Image /StartComponentCleanup
timeout /t 5 /nobreak >nul

echo Running idle tasks...
rundll32.exe advapi32.dll,ProcessIdleTasks
timeout /t 5 /nobreak >nul

echo Resetting firewall settings...
netsh advfirewall reset
timeout /t 5 /nobreak >nul

echo Opening Storage Sense settings...
start ms-settings:storagesense
timeout /t 5 /nobreak >nul

echo Running Disk Cleanup...
cleanmgr /sageset:1
cleanmgr /sagerun:1
timeout /t 5 /nobreak >nul

echo Opening Device Manager...
start devmgmt.msc
timeout /t 5 /nobreak >nul

echo Setting TCP autotuning level to normal...
netsh int tcp set global autotuninglevel=normal
timeout /t 5 /nobreak >nul

echo Setting TCP congestion provider to CTCP...
netsh int tcp set global congestionprovider=ctcp
timeout /t 5 /nobreak >nul

:: Additional registry and system commands
echo Disabling startup delay...
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Serialize" /v StartupDelayInMSec /t REG_DWORD /d 0 /f
timeout /t 3 /nobreak >nul

echo Disabling Windows Error Reporting...
reg add "HKLM\SOFTWARE\Microsoft\Windows\Windows Error Reporting" /v Disabled /t REG_DWORD /d 1 /f
timeout /t 3 /nobreak >nul

echo Disabling new app notifications...
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v Start_NotifyNewApps /t REG_DWORD /d 0 /f
timeout /t 3 /nobreak >nul

echo Running idle tasks...
rundll32.exe advapi32.dll,ProcessIdleTasks
timeout /t 3 /nobreak >nul

echo Setting processor throttle to 100%...
powercfg /setacvalueindex SCHEME_CURRENT SUB_PROCESSOR PROCTHROTTLEMIN 100
powercfg /setacvalueindex SCHEME_CURRENT SUB_PROCESSOR PROCTHROTTLEMAX 100
powercfg /setactive SCHEME_CURRENT
timeout /t 3 /nobreak >nul

echo Resetting Windows Update components...
net stop wuauserv
net stop bits
rd /s /q %windir%\SoftwareDistribution
net start wuauserv
net start bits
timeout /t 5 /nobreak >nul

echo Deleting prefetch files...
del /q /f "%SystemRoot%\Prefetch\*.*"
timeout /t 3 /nobreak >nul

echo Disabling CEIP...
reg add "HKLM\SOFTWARE\Microsoft\SQMClient\Windows" /v CEIPEnable /t REG_DWORD /d 0 /f
timeout /t 2 /nobreak >nul

echo Disabling toast notifications...
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\PushNotifications" /v ToastEnabled /t REG_DWORD /d 0 /f
timeout /t 2 /nobreak >nul

:: Ask the user if they want to create a system restore point
set /p restoreChoice=[ ALERT ] Do you want to create a system restore point in case anything goes wrong? (YES/NO): 
if /i "%restoreChoice%"=="YES" (
    echo Creating a system restore point...
    powershell -Command "Checkpoint-Computer -Description 'Windows Optimizer Restore Point' -RestorePointType 'MODIFY_SETTINGS'"
    timeout /t 5 /nobreak >nul
)

:: Ask the user if they want to restart the PC
set /p restartChoice=[ ALERT ] Do you want to allow "winoptimizertool.bat" to restart this PC? (YES/NO): 
if /i "%restartChoice%"=="YES" (
    echo Restarting the computer...
    shutdown /r /f /t 0
) else (
    echo No restart will be performed. Exiting...
    timeout /t 5 /nobreak >nul
    exit /b
)
