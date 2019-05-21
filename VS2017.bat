@ECHO OFF

SET TargetVisualStudioNumericVersion=15.0
SET TargetVisualStudioNumericNextVersion=16.0
SET VSShortVersion=VS2017
SET VSYear=2017
IF NOT DEFINED TargetFrameworkVersion (SET TargetFrameworkVersion=v4.6)
REM IF NOT DEFINED FrameworkSDKDir (CALL "%VS150COMNTOOLS%VsDevCmd.bat")