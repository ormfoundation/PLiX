@echo off
setlocal

IF NOT DEFINED TargetVisualStudioNumericVersion (
	ECHO TargetVisualStudioNumericVersion not defined.
	EXIT /B 1
)

IF "%ProgramFiles(X86)%"=="" (
	SET ResolvedProgramFiles=%ProgramFiles%
	SET ResolvedCommonProgramFiles=%CommonProgramFiles%
	SET WOWRegistryAdjust=
) ELSE (
	CALL:SET6432
)

if '%1'=='' (
	set rootPath=%~dp0
) else (
	set rootPath=%~dp1
)
if '%2'=='' (
	set outDir=bin\Debug\
) else (
	set outDir=%~2
)
REM set envPath=%ResolvedProgramFiles%\Microsoft Visual Studio 8\
:: Can't use '(' due to the x86 in program files...
if '%3'=='' (
	set "envPath=%ResolvedProgramFiles%\Microsoft Visual Studio\%VSYear%\Community\"
) else (
	set "envPath=%~3"
)

SET VSRegistryRootBase=SOFTWARE%WOWRegistryAdjust%\Microsoft\VisualStudio
SET VSRegistryRootVersion=%TargetVisualStudioNumericVersion%

:: PRE VS 15
REM FOR /F "usebackq skip=2 tokens=2*" %%A IN (`REG QUERY "HKLM\%VSRegistryRootBase%\VSIP\%VSRegistryRootVersion%" /v "InstallDir"`) DO SET VSIPDir=%%~fB
REM IF "%TargetVisualStudioNumericVersion%"=="9.0" (SET vsipbin=%VSIPDir%VisualStudioIntegration\Tools\Bin\VS2005\) ELSE (SET vsipbin=%VSIPDir%VisualStudioIntegration\Tools\Bin\)
:: VS 15 and up
SET VSWhereLocation=%ProgramFiles(x86)%\Microsoft Visual Studio\Installer\vswhere.exe
FOR /f "usebackq tokens=*" %%i IN (`"%VSWhereLocation%" -version [%TargetVisualStudioNumericVersion%^,%TargetVisualStudioNumericNextVersion%^) -products * -requires Microsoft.Component.MSBuild -property installationPath`) DO (
	SET VSInstallDir=%%i
)
FOR /f "usebackq tokens=*" %%i IN (`"%VSWhereLocation%" -version [%TargetVisualStudioNumericVersion%^,%TargetVisualStudioNumericNextVersion%^) -products * -requires Microsoft.Component.MSBuild -property instanceId`) DO (
	SET VSInstanceId=%%i
)
SET VSIPDir=%VSInstallDir%\VSSDK\
SET vsipbin=%VSInstallDir%\VSSDK\VisualStudioIntegration\Tools\Bin\
SET VSIXInstallDir=%LocalAppData%\Microsoft\VisualStudio\%TargetVisualStudioNumericVersion%_%VSInstanceId%Exp\Extensions\ORM Solutions\PLiX\1.0
:: Update the path for dlls needed by the build, we don't want to add them to the GAC
for %%i in (Microsoft.VisualStudio.Shell.15.0.dll) do (set INPATH="%%~$PATH:i")
if '%INPATH%'=='' (
	CALL:EXTENDPATH "%VSInstallDir%\Common7\IDE\PublicAssemblies"
)
SET INPATH=
for %%i in (Microsoft.VisualStudio.Utilities.dll) do (set INPATH="%%~$PATH:i")
if '%INPATH%'=='' (
	CALL:EXTENDPATH "%VSInstallDir%\VSSDK\VisualStudioIntegration\Common\Assemblies\v4.0"
)
SET INPATH=
for %%i in (Microsoft.Build.Framework.dll) do (set INPATH="%%~$PATH:i")
if '%INPATH%'=='' (
	CALL:EXTENDPATH "%VSInstallDir%\MSBuild\%ProjectToolsVersion%\Bin"
)
SET INPATH=
for %%i in (vsct.exe) do (set INPATH="%%~$PATH:i")
if '%INPATH%'=='' (
	CALL:EXTENDPATH "%VSInstallDir%\VSSDK\VisualStudioIntegration\Tools\Bin"
)
SET INPATH=

:: PRE VS 15
REM set plixBinaries=%ResolvedProgramFiles%\Neumont\PLiX for Visual Studio\bin\
REM set plixHelp=%ResolvedProgramFiles%\Neumont\PLiX for Visual Studio\Help\
:: VS 15+
set plixBinaries=%ResolvedProgramFiles%\Neumont\PLiX for Visual Studio %VSYear%\bin\
set plixHelp=%ResolvedProgramFiles%\Neumont\PLiX for Visual Studio %VSYear%\Help\

set plixXML=%ResolvedCommonProgramFiles%\Neumont\PLiX\
set plixTool=Neumont.Tools.CodeGeneration.PLiX
set plixToolClass=Neumont.Tools.CodeGeneration.Plix.PlixLoaderCustomTool

:: PRE VS 15
REM IF EXIST "%plixBinaries%%plixTool%.dll" (
REM "%vsipbin%regpkg.exe" /root:"%VSRegistryRootBase%\%VSRegistryRootVersion%" /unregister "%plixBinaries%%plixTool%.dll"
REM "%vsipbin%regpkg.exe" /root:"%VSRegistryRootBase%\%VSRegistryRootVersion%Exp" /unregister "%plixBinaries%%plixTool%.dll"
REM )

:: Clean old install locations
if exist "%envPath%Common7\IDE\PrivateAssemblies\Neumont.Tools.CodeGeneration.CustomTools.dll" (
del "%envPath%Common7\IDE\PrivateAssemblies\Neumont.Tools.CodeGeneration.CustomTools.dll"
)
if exist "%envPath%Common7\IDE\PrivateAssemblies\Neumont.Tools.CodeGeneration.CustomTools.pdb" (
del "%envPath%Common7\IDE\PrivateAssemblies\Neumont.Tools.CodeGeneration.CustomTools.pdb"
)
del /f /q "%envPath%Xml\Schemas\Plix*.xsd" 1>NUL 2>&1
if exist "%envPath%Neumont" rd /s /q "%envPath%Neumont"
if exist "%plixBinaries%Neumont.Tools.CodeGeneration.CustomTools.dll" (
del "%plixBinaries%Neumont.Tools.CodeGeneration.CustomTools.dll"
)
if exist "%plixBinaries%Neumont.Tools.CodeGeneration.CustomTools.pdb" (
del "%plixBinaries%Neumont.Tools.CodeGeneration.CustomTools.pdb"
)

:: Create new directories
if not exist "%plixBinaries%" md "%plixBinaries%"
if not exist "%plixHelp%" md "%plixHelp%"
if not exist "%plixXML%Schemas" md "%plixXML%Schemas"
if not exist "%plixXML%Formatters" md "%plixXML%Formatters"

xcopy /Y /D /Q "%rootPath%%outDir%%plixTool%.dll" "%plixBinaries%"
if exist "%rootPath%%outDir%%plixTool%.pdb" (
xcopy /Y /D /Q "%rootPath%%outDir%%plixTool%.pdb" "%plixBinaries%"
) else (
if exist "%plixBinaries%%plixTool%.pdb" (
del "%plixBinaries%%plixTool%.pdb"
)
)
REM xcopy /Y /D /Q "%rootPath%%outDir%*.dll" "%plixBinaries%"
REM xcopy /Y /D /Q "%rootPath%%outDir%*.pdb" "%plixBinaries%"

xcopy /Y /D /Q "%rootPath%PlixXsd.html" "%plixHelp%"
xcopy /Y /D /Q "%rootPath%PlixLoaderXsd.html" "%plixHelp%"
xcopy /Y /D /Q "%rootPath%VSIntegrationInstructions.html" "%plixHelp%"
xcopy /Y /D /Q "%rootPath%%outDir%PlixLoader.xsd" "%plixXML%Schemas"
xcopy /Y /D /Q "%rootPath%%outDir%Plix.xsd" "%plixXML%Schemas"
xcopy /Y /D /Q "%rootPath%%outDir%PlixRedirect.xsd" "%plixXML%Schemas"
xcopy /Y /D /Q "%rootPath%%outDir%PlixSettings.xsd" "%plixXML%Schemas"
xcopy /Y /D /Q "%rootPath%%outDir%catalog.xml" "%plixXML%Schemas"
xcopy /Y /D /Q "%rootPath%%outDir%PlixSettings.xml" "%plixXML%"
xcopy /Y /D /Q "%rootPath%%outDir%PlixMain.xslt" "%plixXML%Formatters"
xcopy /Y /D /Q "%rootPath%%outDir%PlixCS.xslt" "%plixXML%Formatters"
xcopy /Y /D /Q "%rootPath%%outDir%PlixVB.xslt" "%plixXML%Formatters"
xcopy /Y /D /Q "%rootPath%%outDir%PlixPHP.xslt" "%plixXML%Formatters"
xcopy /Y /D /Q "%rootPath%%outDir%PlixJSL.xslt" "%plixXML%Formatters"
xcopy /Y /D /Q "%rootPath%%outDir%PlixPY.xslt" "%plixXML%Formatters"
ECHO F | xcopy /Y /D /Q "%rootPath%..\Setup\PLiXSchemaCatalog.xml" "%envPath%Xml\Schemas"

:: PRE VS 15
REM "%vsipbin%regpkg.exe" /root:"%VSRegistryRootBase%\%VSRegistryRootVersion%" /codebase "%plixBinaries%%plixTool%.dll"
REM "%vsipbin%regpkg.exe" /root:"%VSRegistryRootBase%\%VSRegistryRootVersion%Exp" /codebase "%plixBinaries%%plixTool%.dll"

CALL:_InstallCustomTool "%TargetVisualStudioNumericVersion%"
CALL:_InstallCustomTool "%TargetVisualStudioNumericVersion%Exp"

:: Install the extension
IF %TargetVisualStudioNumericVersion% GEQ 15.0 (
	IF NOT EXIST "%VSIXInstallDir%" (MKDIR "%VSIXInstallDir%")
	XCOPY /Y /D /V /Q "%rootPath%..\VSIXInstall\%VSShortVersion%\extension.vsixmanifest" "%VSIXInstallDir%\"
	XCOPY /Y /D /V /Q "%rootPath%..\VSIXInstall\%VSShortVersion%\PLiX.pkgdef" "%VSIXInstallDir%\"
	XCOPY /Y /D /V /Q "%rootPath%..\VSIXInstall\%VSShortVersion%\Package.ico" "%VSIXInstallDir%\"
	XCOPY /Y /D /V /Q "%rootPath%..\LICENSE.txt" "%VSIXInstallDir%\"
	:: PRE VS 15
	REM REG ADD HKLM\%VSRegistryRootBase%\%VSRegistryRootVersion%Exp\ExtensionManager\EnabledExtensions /v "bc129a03-26c4-4667-8e12-96225b2d3cd2,1.0.0" /d "%VSIXInstallDir%\\" /f 1>NUL
	:: VS 15+
	REM https://visualstudioextensions.vlasovstudio.com/2017/06/29/changing-visual-studio-2017-private-registry-settings/
	for /d %%f in (%LOCALAPPDATA%\Microsoft\VisualStudio\16.0_*Exp) do (
		reg load HKLM\_TMPVS_%%~nxf "%%f\privateregistry.bin"
		REG ADD "HKLM\_TMPVS_%%~nxf\Software\Microsoft\VisualStudio\%%~nxf\ExtensionManager\EnabledExtensions" /v "bc129a03-26c4-4667-8e12-96225b2d3cd2,1.0.0" /d "%VSIXInstallDir%\\" /f 1>NUL
		reg unload HKLM\_TMPVS_%%~nxf
	)
)
GOTO:EOF

:_InstallCustomTool
CALL:_AddCustomToolReg "%~1"
CALL:_AddRegGenerator "%~1" "{fae04ec1-301f-11d3-bf4b-00c04f79efbc}" "Neumont C# Plix Loader"
CALL:_AddRegGenerator "%~1" "{164b10b9-b200-11d0-8c61-00a0c91e29d5}" "Neumont VB Plix Loader"
CALL:_AddRegGenerator "%~1" "{e6fdf8b0-f3d1-11d4-8576-0002a516ece8}" "Neumont J# Plix Loader"

:_AddCustomToolReg
REG DELETE "HKLM\SOFTWARE%WOWRegistryAdjust%\Microsoft\VisualStudio\%~1\CLSID\{12f1fc1e-20a6-4286-9c43-25209bba5997}" /f 1>NUL 2>&1
REG ADD HKLM\SOFTWARE%WOWRegistryAdjust%\Microsoft\VisualStudio\%~1\CLSID\{12f1fc1e-20a6-4286-9c43-25209bba5997} /f /ve /d "%plixToolClass%" 1>NUL
REG ADD HKLM\SOFTWARE%WOWRegistryAdjust%\Microsoft\VisualStudio\%~1\CLSID\{12f1fc1e-20a6-4286-9c43-25209bba5997}\InprocServer32 /f /ve /d "%SystemRoot%\System32\mscoree.dll" 1>NUL
REG ADD HKLM\SOFTWARE%WOWRegistryAdjust%\Microsoft\VisualStudio\%~1\CLSID\{12f1fc1e-20a6-4286-9c43-25209bba5997}\InprocServer32 /f /v "ThreadingModel" /d "Both" 1>NUL
REG ADD HKLM\SOFTWARE%WOWRegistryAdjust%\Microsoft\VisualStudio\%~1\CLSID\{12f1fc1e-20a6-4286-9c43-25209bba5997}\InprocServer32 /f /v "Class" /d "%plixToolClass%" 1>NUL
REG ADD HKLM\SOFTWARE%WOWRegistryAdjust%\Microsoft\VisualStudio\%~1\CLSID\{12f1fc1e-20a6-4286-9c43-25209bba5997}\InprocServer32 /f /v "CodeBase" /d "%plixBinaries%%plixTool%.dll" 1>NUL
REG ADD HKLM\SOFTWARE%WOWRegistryAdjust%\Microsoft\VisualStudio\%~1\CLSID\{12f1fc1e-20a6-4286-9c43-25209bba5997}\InprocServer32 /f /v "Assembly" /d "%plixTool%, Version=1.0, Culture=neutral, PublicKeyToken=7a0c83ac6f8a469f" 1>NUL
GOTO:EOF

:_AddRegGenerator
REG ADD HKLM\SOFTWARE%WOWRegistryAdjust%\Microsoft\VisualStudio\%~1\Generators\%~2\NUPlixLoader /f /ve /d "%~3" 1>NUL
REG ADD HKLM\SOFTWARE%WOWRegistryAdjust%\Microsoft\VisualStudio\%~1\Generators\%~2\NUPlixLoader /f /v "CLSID" /d "{12f1fc1e-20a6-4286-9c43-25209bba5997}" 1>NUL
GOTO:EOF

:SET6432
::Do this somewhere the resolved parens will not cause problems.
SET ResolvedProgramFiles=%ProgramFiles(x86)%
SET ResolvedCommonProgramFiles=%CommonProgramFiles(x86)%
SET WOWRegistryAdjust=\Wow6432Node
GOTO:EOF

:EXTENDPATH
SET PATH=%PATH%;%~1
GOTO:EOF