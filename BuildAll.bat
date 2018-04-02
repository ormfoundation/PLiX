@ECHO OFF
SETLOCAL

:: TargetVisualStudioNumericVersion settings:
::   8.0 = Visual Studio 2005 (Code Name "Whidbey")
::   9.0 = Visual Studio 2008 (Code Name "Orcas")
::   15.0 = Visual Studio 2017
SET TargetVisualStudioNumericVersion=15.0

:: VS 8.0
REM IF NOT DEFINED FrameworkSDKDir (CALL "%VS80COMNTOOLS%\vsvars32.bat")

:: VS 15.0
IF NOT DEFINED FrameworkSDKDir (CALL "%VS150COMNTOOLS%VsDevCmd.bat")

SET RootDir=%~dp0.

:: VS 8.0
REM MSBuild.exe /nologo "%RootDir%\CodeGen.sln" %*
REM MSBuild.exe /nologo "%RootDir%\PLiXReflector.sln" %*
REM MSBuild.exe /nologo "%RootDir%\Setup\Setup.sln" %*

:: VS 15.0
MSBuild.exe /nologo "%RootDir%\CodeGen.sln" %* /toolsversion:15.0
REM MSBuild.exe /nologo "%RootDir%\PLiXReflector.sln" %* /toolsversion:15.0
MSBuild.exe /nologo "%RootDir%\Setup.2017\Setup.sln" %* /toolsversion:15.0
