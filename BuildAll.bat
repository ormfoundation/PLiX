@ECHO OFF
SETLOCAL

:: VS 8.0
REM IF NOT DEFINED FrameworkSDKDir (CALL "%VS80COMNTOOLS%\vsvars32.bat")

SET RootDir=%~dp0.

:: VS 8.0
REM MSBuild.exe /nologo "%RootDir%\CodeGen.sln" %*
REM MSBuild.exe /nologo "%RootDir%\PLiXReflector.sln" %*
REM MSBuild.exe /nologo "%RootDir%\Setup\Setup.sln" %*

:: VS 15.0 and up
:: Determine the correct ToolsVersion for MSBuild
FOR /f "usebackq tokens=*" %%i IN (`"%ProgramFiles(x86)%\Microsoft Visual Studio\Installer\vswhere.exe" -version [%TargetVisualStudioNumericVersion%^,%TargetVisualStudioNumericNextVersion%^) -products * -requires Microsoft.Component.MSBuild -property installationPath`) DO (
	SET VSInstallDir=%%i
)
FOR /f "usebackq tokens=*" %%i in (`"%ProgramFiles(x86)%\Microsoft Visual Studio\Installer\vswhere.exe" -version [%TargetVisualStudioNumericVersion%^,%TargetVisualStudioNumericNextVersion%^) -requires Microsoft.Component.MSBuild -find MSBuild\**\Bin\MSBuild.exe`) do (
	SET CurrentMSBuildPath=%%i
)
REM Remove the trailing "\Bin\MSBuild.exe"
SET CurrentToolsVersionPath=%CurrentMSBuildPath:~0,-16%
REM Remove the path up to the current version
CALL SET CurrentMSBuildToolsVersion=%%CurrentToolsVersionPath:%VSInstallDir%\MSBuild\=%%

SET ProjectToolsVersion=%CurrentMSBuildToolsVersion%

SETX ProjectToolsVersion %ProjectToolsVersion% /M > NUL
SETX TargetFrameworkVersion %TargetFrameworkVersion% /M > NUL

MSBuild.exe /nologo "%RootDir%\CodeGen.sln" %* /toolsversion:%CurrentMSBuildToolsVersion%
MSBuild.exe /nologo "%RootDir%\Setup.2017+\Setup.sln" %* /toolsversion:%CurrentMSBuildToolsVersion%
