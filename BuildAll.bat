@ECHO OFF
SETLOCAL

:: TargetVisualStudioNumericVersion settings:
::   8.0 = Visual Studio 2005 (Code Name "Whidbey")
::   9.0 = Visual Studio 2008 (Code Name "Orcas")
::   15.0 = Visual Studio 2017
::   16.0 = Visual Studio 2019
SET TargetVisualStudioNumericVersion=16.0

:: VS 8.0
REM IF NOT DEFINED FrameworkSDKDir (CALL "%VS80COMNTOOLS%\vsvars32.bat")

:: VS 15.0
REM IF NOT DEFINED FrameworkSDKDir (CALL "%VS150COMNTOOLS%VsDevCmd.bat")

SET RootDir=%~dp0.

:: VS 8.0
REM MSBuild.exe /nologo "%RootDir%\CodeGen.sln" %*
REM MSBuild.exe /nologo "%RootDir%\PLiXReflector.sln" %*
REM MSBuild.exe /nologo "%RootDir%\Setup\Setup.sln" %*

:: VS 15.0 and up
:: Determine the correct ToolsVersion for MSBuild
FOR /f "usebackq tokens=*" %%i IN (`"%ProgramFiles(x86)%\Microsoft Visual Studio\Installer\vswhere.exe" -latest -products * -requires Microsoft.Component.MSBuild -property installationPath`) DO (
	SET VSInstallDir=%%i
)
FOR /f "usebackq tokens=*" %%i in (`"%ProgramFiles(x86)%\Microsoft Visual Studio\Installer\vswhere.exe" -latest -requires Microsoft.Component.MSBuild -find MSBuild\**\Bin\MSBuild.exe`) do (
	SET CurrentMSBuildPath=%%i
)
REM Remove the trailing "\Bin\MSBuild.exe"
SET CurrentToolsVersionPath=%CurrentMSBuildPath:~0,-16%
REM Remove the path up to the current version
CALL SET CurrentMSBuildToolsVersion=%%CurrentToolsVersionPath:%VSInstallDir%\MSBuild\=%%

IF NOT DEFINED TargetFrameworkVersion (SET TargetFrameworkVersion=v4.7.2)

SETX ProjectToolsVersion "%CurrentMSBuildToolsVersion%" /M > NUL
SETX TargetFrameworkVersion "%TargetFrameworkVersion%" /M > NUL

MSBuild.exe /nologo "%RootDir%\CodeGen.sln" %* /toolsversion:%CurrentMSBuildToolsVersion%
MSBuild.exe /nologo "%RootDir%\Setup.2017+\Setup.sln" %* /toolsversion:%CurrentMSBuildToolsVersion%
