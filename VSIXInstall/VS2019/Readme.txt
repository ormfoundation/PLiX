The registry settings in the pkgdef file are mostly generated using the regpkg utility, with a call (after the source is built) from this directory similar to:

"C:\Program Files (x86)\Microsoft Visual Studio\<REPLACE WITH YEAR>\Community\VSSDK\VisualStudioIntegration\Tools\Bin\CreatePkgDef.exe" /out=C:\Projects\temp.pkgdef "C:\Projects\PLiX\CodeGenCustomTool\bin\Debug\Neumont.Tools.CodeGeneration.PLiX.dll"

The registry file needs to be regenerated when any of the registration attributes on the ORMDesignerPackage class are modified.

Adding the registory entries from the Setup package that goes into VS since the values are no longer in the actual registry but a private registry bin file
	https://docs.microsoft.com/en-us/visualstudio/extensibility/breaking-changes-2017

If menu or other packages changes are made and VS2017 does not recognize them, then the .vsixmanifest file can be modified in place as follows:
1) Shut down VS Experimental Hive
2) Find the vsix install location for the package. Starting from the directory in the LocalAppData environment variable (or "%userprofile%\Local Settings\Application Data" if LocalAppData is not set), find the extension.vsixmanifest file in "Microsoft\VisualStudio\14.0Exp\Extensions\ORM Solutions\Natural ORM Architect\1.0".
3) Change the contents of the <InstalledByMsi> tag from true to false (this enables you to disable the extension below).
4) Delete any .cache files you find in the Extensions directory (three directories above the directory with the manifest file).
5) Relaunch VS Experimental Hive (devenv /RootSuffix Exp) and open the Tools/Extension Manager dialog.
6) Disable the NORMA tool and restart VS from the dialog.
7) Reopen the Extension Manager dialog and reenable the NORMA extension
8) Any cached settings should be updated after a final relaunch of the environment.
