
Func DosPathNameToPathName($sPath)
	Local $sName, $aDrive = DriveGetDrive('ALL')

	If Not IsArray($aDrive) Then
		Return SetError(1, 0, $sPath)
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
	Dim $sCurrentHumanTime

	Local Const $sRegistryTmp = $sTmpDir & "\registry"
	Local Const $sBackUpPath = @HomeDrive & "\KPRM\backup\" & $sCurrentHumanTime
	Local Const $sSuffixKey = GetSuffixKey()
	Local $sHiveList = "HKLM" & $sSuffixKey & "\System\CurrentControlSet\Control\hivelist"
	Local $i = 0

	DirCreate($sRegistryTmp)
	DirCreate($sBackUpPath)

	If @OSArch = "X64" Then
		FileInstall(".\binaries\hobocopy64\HoboCopy.exe", $sRegistryTmp & "\HoboCopy.exe")
		FileInstall(".\binaries\hobocopy64\msvcp100.dll", $sRegistryTmp & "\msvcp100.dll")
		FileInstall(".\binaries\hobocopy64\msvcr100.dll", $sRegistryTmp & "\msvcr100.dll")
	Else
		FileInstall(".\binaries\hobocopy32\HoboCopy.exe", $sRegistryTmp & "\HoboCopy.exe")
		FileInstall(".\binaries\hobocopy32\msvcp100.dll", $sRegistryTmp & "\msvcp100.dll")
		FileInstall(".\binaries\hobocopy32\msvcr100.dll", $sRegistryTmp & "\msvcr100.dll")
	EndIf

	If Not FileExists($sBackUpPath) Then
		DirCreate($sBackUpPath)
	EndIf

	If Not FileExists($sBackUpPath) _
			Or Not FileExists($sRegistryTmp & "\HoboCopy.exe") _
			Or Not FileExists($sRegistryTmp & "\msvcp100.dll") _
			Or Not FileExists($sRegistryTmp & "\msvcr100.dll") Then
		MsgBox(16, $lFail, $lRegistryBackupError)
		QuitKprm(False, False)
	EndIf

	Local $oHives = ObjCreate("Scripting.Dictionary")

	While True
		$i += 1
		Local $sEntry = RegEnumVal($sHiveList, $i)
		If @error <> 0 Or $i > 100 Then ExitLoop

		Local $sName = RegRead($sHiveList, $sEntry)

		If $sName Then
			Local $sPathName = DosPathNameToPathName($sName)

			If StringRegExp($sPathName, '(?i)^[A-Z]\:\\') Then
				Local $sDrive = "", $sDir = "", $sFileName = "", $sExtension = ""
				Local $aPathSplit = _PathSplit($sPathName, $sDrive, $sDir, $sFileName, $sExtension)
				$sDir = StringRegExpReplace($sDir, "\\$", "")
				Local $sHiveName = $sFileName & $sExtension
				Local $sHivePath = $sDrive & $sDir
				Local $sScriptBackUpPath = $sBackUpPath & $sDir

				If $sHiveName And $sHivePath And $sScriptBackUpPath Then
					If $oHives.Exists($sHivePath) Then
						Local $oDataHive = $oHives.Item($sHivePath)
						Local $sFiles = $oDataHive.Item("files")
						$sFiles &= "||" & $sHiveName
						$oDataHive.Item("files") = $sFiles
						$oHives.Item($sHivePath) = $oDataHive
					Else
						Local $oDataHive = ObjCreate("Scripting.Dictionary")
						$oDataHive.add("files", $sHiveName)
						$oDataHive.add("backup", $sScriptBackUpPath)
						$oHives.add($sHivePath, $oDataHive)
					EndIf
				EndIf
			EndIf
		EndIf
	WEnd

	For $sHivePath In $oHives
		Local $oDataHive = $oHives.Item($sHivePath)
		Local $sScriptBackUpPath = $oDataHive.Item("backup")
		Local $sFiles = $oDataHive.Item("files")

		If Not FileExists($sScriptBackUpPath) Then
			DirCreate($sScriptBackUpPath)
		EndIf

		Local $sAllFiles = StringReplace($sFiles, "||", " ")

		UpdateStatusBar("Backup registry  " & $sAllFiles & " in " & $sHivePath)

		RunWait(@ComSpec & ' /c HoboCopy.exe "' & $sHivePath & '" "' & $sScriptBackUpPath & '" ' & $sAllFiles, $sRegistryTmp, @SW_HIDE)

		Local $aHivesFiles = StringSplit($sFiles, '||', $STR_ENTIRESPLIT)

		For $i = 1 To $aHivesFiles[0]
			Local $sCurrentHiveInBackup = $sScriptBackUpPath & "\" & $aHivesFiles[$i]
			Local $sCurrentHiveInSystem = $sHivePath & "\" & $aHivesFiles[$i]

			If Not FileExists($sCurrentHiveInBackup) Then
				MsgBox(16, $lFail, $lRegistryBackupError & @CRLF & $sCurrentHiveInSystem)
				LogMessage("  [X] Failed Registry Backup: " & $sCurrentHiveInSystem)
				QuitKprm(False)
			Else
				Local $sAttrib = FileGetAttrib($sCurrentHiveInBackup)

				If StringInStr($sAttrib, "R") Then
					FileSetAttrib($sCurrentHiveInBackup, "-R")
				EndIf

				If StringInStr($sAttrib, "S") Then
					FileSetAttrib($sCurrentHiveInBackup, "-S")
				EndIf

				If StringInStr($sAttrib, "H") Then
					FileSetAttrib($sCurrentHiveInBackup, "-H")
				EndIf

				If StringInStr($sAttrib, "A") Then
					FileSetAttrib($sCurrentHiveInBackup, "-A")
				EndIf
			EndIf
		Next
	Next

	LogMessage("  [OK] Registry Backup: " & $sBackUpPath)
EndFunc   ;==>CreateBackupRegistry


