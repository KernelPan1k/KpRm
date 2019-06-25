
Func CreateBackupRegistry()
	LogMessage(@CRLF & "- Create Registry Backup -" & @CRLF)

	Dim $sTmpDir

	Local Const $sRegistryTmp = $sTmpDir & "\registry"
	Local Const $sBackUpPath = @HomeDrive & "\KPRM\backup\" & @YEAR & @MON & @MDAY & @HOUR & @MIN
	Local Const $sBackUpUserPath = @HomeDrive & "\KPRM\backup\" & @YEAR & @MON & @MDAY & @HOUR & @MIN & "\" & @UserName

	DirCreate($sBackUpUserPath)
	DirCreate($sRegistryTmp)

	FileInstall("C:\Users\IEUser\Desktop\KpRm\src\binary\dosdev.exe", $sRegistryTmp & "\dosdev.exe")

	If @OSArch = "X64" Then
		FileInstall("C:\Users\IEUser\Desktop\KpRm\src\binary\vscsc64.exe", $sRegistryTmp & "\vscsc.exe")
	Else
		FileInstall("C:\Users\IEUser\Desktop\KpRm\src\binary\vscsc32.exe", $sRegistryTmp & "\vscsc.exe")
	EndIf

	If Not FileExists($sBackUpPath) Then
		DirCreate($sBackUpPath)
	EndIf

	If Not FileExists($sBackUpPath) Then
		MsgBox(16, $lFail, $lRegistryBackupError)
		Exit
	EndIf

	Local $sScript = "@echo off" & @CRLF
	$sScript &= "" & @CRLF
	$sScript &= 'set HomeDrive="' & @HomeDrive & '"' & @CRLF
	$sScript &= 'set SNAPDOS=B:' & @CRLF
	$sScript &= "set SYSTEM_HIVES=%SNAPDOS%\Windows\System32\config" & @CRLF
	$sScript &= "set USER_HIVES=" & StringReplace(@UserProfileDir, @HomeDrive, "B:") & @CRLF
	$sScript &= "set BACKUP=" & $sBackUpPath & @CRLF
	$sScript &= "set BACKUP_USER=" & $sBackUpUserPath & @CRLF
	$sScript &= "dosdev %SNAPDOS% %1%" & @CRLF
	$sScript &= 'robocopy "%SYSTEM_HIVES%" "%BACKUP%" SOFTWARE' & @CRLF
	$sScript &= 'robocopy "%SYSTEM_HIVES%" "%BACKUP%" SAM' & @CRLF
	$sScript &= 'robocopy "%SYSTEM_HIVES%" "%BACKUP%" SECURITY' & @CRLF
	$sScript &= 'robocopy "%SYSTEM_HIVES%" "%BACKUP%" SYSTEM' & @CRLF
	$sScript &= 'robocopy "%SYSTEM_HIVES%" "%BACKUP%" DEFAULT' & @CRLF
	$sScript &= 'robocopy "%USER_HIVES%" "%BACKUP_USER%" NTUSER.DAT' & @CRLF
	$sScript &= 'dosdev /D %SNAPDOS%' & @CRLF
	$sScript &= 'attrib -H -S ' & $sBackUpUserPath & "\NTUSER.DAT" & @CRLF

	FileWrite($sRegistryTmp & "\backup.bat", $sScript)

	Local Const $status = RunWait(@ComSpec & ' /c vscsc.exe -exec=backup.bat ' & @HomeDrive, $sRegistryTmp, @SW_HIDE)

	If Not FileExists($sBackUpPath & "\SOFTWARE") Or _
			Not FileExists($sBackUpPath & "\SAM") Or _
			Not FileExists($sBackUpPath & "\SECURITY") Or _
			Not FileExists($sBackUpPath & "\SYSTEM") Or _
			Not FileExists($sBackUpPath & "\DEFAULT") Or _
			Not FileExists($sBackUpUserPath & "\NTUSER.DAT") Or _
			@error <> 0 Then
		LogMessage("  [X] Failed to create completly registry backup")
		MsgBox(16, $lFail, $lRegistryBackupError)
		QuitKprm()
	Else
		LogMessage("  [OK] Registry Backup: " & $sBackUpPath)
	EndIf
EndFunc   ;==>CreateBackupRegistry
