@echo off
setlocal
cd /d "%~dp0"
where git >nul 2>&1 || goto :git
if exist "WacOS-build" goto :exists
git -c core.autocrlf=false clone --no-checkout https://github.com/renzyxx/WacOS.git WacOS-build || goto :failed
cd WacOS-build || goto :failed
git -c core.autocrlf=false checkout --detach c5ce3361edd949a52f878ca1b73135cd0ba96f14 || goto :failed
git apply --whitespace=nowarn "..\wacos-fixes.patch" || goto :failed
call build.cmd || goto :failed
call build.cmd janelas || goto :failed
if not exist bin\WacOSSetup.exe goto :failed
>bin\versao.txt echo local-liquid-glass-c5ce336
powershell -NoProfile -ExecutionPolicy Bypass -File tools\empacotar.ps1 -Atualizacao -SemSistema || goto :failed
powershell -NoProfile -Command "$zip = Get-ChildItem dist\*.zip | Select-Object -First 1; Expand-Archive -LiteralPath $zip.FullName -DestinationPath dist\setup -Force" || goto :failed
start "" "dist\setup\WacOSSetup.exe"
exit /b
:git
echo Install Git for Windows and run this file again.
goto :failed
:exists
echo Choose a fresh folder for this build. WacOS-build already exists here.
:failed
echo The build stopped. Review the message above.
pause
exit /b 1
