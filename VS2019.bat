@ECHO OFF

SET TargetVisualStudioNumericVersion=16.0
SET TargetVisualStudioNumericNextVersion=17.0
SET VSShortVersion=VS2019
SET VSYear=2019

SETX TargetVisualStudioNumericVersion %TargetVisualStudioNumericVersion% /M > NUL
SETX TargetVisualStudioNumericNextVersion %TargetVisualStudioNumericNextVersion% /M > NUL
SETX VSShortVersion %VSShortVersion% /M > NUL
SETX VSYear %VSYear% /M > NUL

IF NOT DEFINED TargetFrameworkVersion (SET TargetFrameworkVersion=v4.7.2)
