
Func DosPathNameToPathName($sPath)
	Local $sName, $aDrive = DriveGetDrive('ALL')

	If Not IsArray($aDrive) Then
		Return SetError(1, 0, $sPath)
	EndIf

	For $i = 1 To $aDrive[0]
		$sName = _WinAPI_QueryDosDevice($aDrive[$i])

		If StringInStr($sPath, $sName) = 1 Then
			Return StringReplace($sPath, $sName, StringUpper($aDrive[$i]), 1)
		EndIf
	Next

	Return SetError(2, 0, $sPath)
EndFunc   ;==>DosPathNameToPathName


Func CreateBackupRegistry()
	LogMessage(@CRLF & "- Create Registry Backup -" & @CRLF)

	Dim $sTmpDir
	Dim $lFail
	Dim $lRegistryBackupError

	Local $sDirBackup = @YEAR & '-' & @MON & '-' & @MDAY & '-' & @HOUR & '-' & @MIN
	Local Const $sRegistryTmp = $sTmpDir & "\registry"
	Local Const $sBackUpPath = @HomeDrive & "\KPRM\backup\" & $sDirBackup
	Local Const $sSuffixKey = GetSuffixKey()
	Local $sHiveList = "HKLM" & $sSuffixKey & "\System\CurrentControlSet\Control\hivelist"
	Local $aCheckPath[0]
	Local $i = 0

	DirCreate($sRegistryTmp)
	DirCreate($sBackUpPath)

	FileInstall(".\binaries\dosdev.exe", $sRegistryTmp & "\dosdev.exe")

	If @OSArch = "X64" Then
		FileInstall(".\binaries\vscsc64.exe", $sRegistryTmp & "\vscsc.exe")
	Else
		FileInstall(".\binaries\vscsc32.exe", $sRegistryTmp & "\vscsc.exe")
	EndIf

	If Not FileExists($sBackUpPath) Then
		DirCreate($sBackUpPath)
	EndIf

	If Not FileExists($sBackUpPath) Then
		MsgBox(16, $lFail, $lRegistryBackupError)
		Exit
	EndIf

	Local $sScript = "@echo off" & @CRLF
	Local $sScript = 'for /f "tokens=2 delims=:." %%x in (''chcp'') do set cp=%%x' & @CRLF
	$sScript &= 'chcp 1252>nul' & @CRLF
	$sScript &= 'set SNAPDOS=B:' & @CRLF
	$sScript &= "dosdev %SNAPDOS% %1%" & @CRLF

	While True
		$i += 1
		Local $sEntry = RegEnumVal($sHiveList, $i)
		If @error <> 0 Then ExitLoop

		Local $sName = RegRead($sHiveList, $sEntry)

		If $sName Then
			Local $sPathName = DosPathNameToPathName($sName)

			If StringRegExp($sPathName, '(?i)^[A-Z]\:\\') Then
				Local $sDrive = "", $sDir = "", $sFileName = "", $sExtension = ""
				Local $aPathSplit = _PathSplit($sPathName, $sDrive, $sDir, $sFileName, $sExtension)
				$sDir = StringRegExpReplace($sDir, "\\$", "")
				Local $sHiveName = $sFileName & $sExtension
				Local $sHivePath = "B:" & $sDir
				Local $sScriptBackUpPath = $sBackUpPath & $sDir

				If Not FileExists($sScriptBackUpPath) Then
					DirCreate($sScriptBackUpPath)
				EndIf

				$sScript &= 'robocopy "' & $sHivePath & '" "' & $sScriptBackUpPath & '" ' & $sHiveName & @CRLF
				$sScript &= 'attrib -H -S ' & $sScriptBackUpPath & "\" & $sHiveName & @CRLF

				_ArrayAdd($aCheckPath, $sScriptBackUpPath & "\" & $sHiveName)
			EndIf
		EndIf
	WEnd

	$sScript &= 'dosdev /D %SNAPDOS%' & @CRLF
	$sScript &= 'chcp %cp%>nul' & @CRLF

	Local $hFileOpen = FileOpen($sRegistryTmp & "\backup.bat", 514)

	If $hFileOpen = -1 Then
		LogMessage("  [X] Failed to create completly registry backup")
		MsgBox(16, $lFail, $lRegistryBackupError)
		QuitKprm()
	EndIf

	FileWrite($hFileOpen, $sScript)
	FileClose($hFileOpen)

	Local Const $status = RunWait(@ComSpec & ' /c vscsc.exe -exec=backup.bat ' & @HomeDrive, $sRegistryTmp, @SW_HIDE)

	Local $bComplete = True

	For $i = 0 To UBound($aCheckPath) - 1
		If Not FileExists($aCheckPath[$i]) Then
			LogMessage("  [X] Failed to create completly registry backup")
			MsgBox(16, $lFail, $lRegistryBackupError)
			QuitKprm()
		EndIf
	Next

	LogMessage("  [OK] Registry Backup: " & $sBackUpPath)
EndFunc   ;==>CreateBackupRegistry

