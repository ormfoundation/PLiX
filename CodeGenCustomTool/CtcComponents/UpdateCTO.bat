@echo off
setlocal
:: TargetVisualStudioNumericVersion settings:
::   8.0 = Visual Studio 2005 (Code Name "Whidbey")
::   9.0 = Visual Studio 2008 (Code Name "Orcas")
::   15.0 = Visual Studio 2017
::   16.0 = Visual Studio 2019
SET TargetVisualStudioNumericVersion=16.0

:: CTC - Compiled by CTC
:: VSCT - Compiled by VSCT
SET CommandTableType=VSCT

SET VSRegistryRootBase=SOFTWARE\Microsoft\VisualStudio
SET VSRegistryRootVersion=%TargetVisualStudioNumericVersion%

REM Only update if the newest file is not the .cto
for /F "usebackq tokens=2 delims=." %%A in (`dir /b /od "%~dp0PLiXPackage.ctc" "%~dp0PLiXPackage.cto"`) do set NewestExtension=%%A

CALL:Compile%CommandTableType%

GOTO:EOF

:CompileCTC
FOR /F "usebackq skip=2 tokens=2*" %%A IN (`REG QUERY "HKLM\%VSRegistryRootBase%\VSIP\%VSRegistryRootVersion%" /v "InstallDir"`) DO SET VSIPDir=%%~fB
SET vsipbin=%VSIPDir%VisualStudioIntegration\Tools\Bin\

if NOT "%NewestExtension%"=="cto" (
@echo on
"%vsipbin%ctc.exe" -nologo "%~dp0PLiXPackage.ctc" "%~dp0PLiXPackage.cto" -Ccl -s- -I"%VSIPDir%VisualStudioIntegration\Common\Inc" -I"%VSIPDir%VisualStudioIntegration\Common\Inc\office10"
)
GOTO:EOF

:CompileVSCT
:: Find the VS Install Directory
SET VSWhereLocation=%ProgramFiles(x86)%\Microsoft Visual Studio\Installer\vswhere.exe
FOR /f "usebackq tokens=*" %%i IN (`"%VSWhereLocation%" -latest -products * -requires Microsoft.Component.MSBuild -property installationPath`) DO (
	SET VSInstallDir=%%i
)
SET VSIPDir=%VSInstallDir%\VSSDK\
SET vsipbin=%VSInstallDir%\VSSDK\VisualStudioIntegration\Tools\Bin\

if NOT "%NewestExtension%"=="cto" (
@echo on
"%vsipbin%vsct.exe" -nologo "%~dp0PLiXPackage.vsct" "%~dp0PLiXPackage.cto" -I"%VSIPDir%VisualStudioIntegration\Common\Inc" -I"%VSIPDir%VisualStudioIntegration\Common\Inc\office10"
)
GOTO:EOF