Func CreateBackupRegistryHobocopy($aAllHives)
	Dim $sTmpDir
	Dim $lFail
	Dim $lRegistryBackupError
	Dim $sCurrentHumanTime

	UpdateStatusBar("Create Registry Backup in another way ...")

	Local Const $sRegistryTmp = $sTmpDir & "\registry"
	Local Const $sBackUpPath = @HomeDrive & "\KPRM\backup\" & $sCurrentHumanTime

	If Not FileExists($sRegistryTmp) Then
		DirCreate($sRegistryTmp)
	EndIf

	If Not FileExists($sBackUpPath) Then
		DirCreate($sBackUpPath)
	EndIf

	; https://github.com/candera/hobocopy

	If @OSArch = "X64" Then
		FileInstall(".\binaries\hobocopy64\HoboCopy.exe", $sRegistryTmp & "\HoboCopy.exe")
		FileInstall(".\binaries\hobocopy64\msvcp100.dll", $sRegistryTmp & "\msvcp100.dll")
		FileInstall(".\binaries\hobocopy64\msvcr100.dll", $sRegistryTmp & "\msvcr100.dll")
	Else
		FileInstall(".\binaries\hobocopy32\HoboCopy.exe", $sRegistryTmp & "\HoboCopy.exe")
		FileInstall(".\binaries\hobocopy32\msvcp100.dll", $sRegistryTmp & "\msvcp100.dll")
		FileInstall(".\binaries\hobocopy32\msvcr100.dll", $sRegistryTmp & "\msvcr100.dll")
	EndIf

	If Not FileExists($sBackUpPath) _
			Or Not FileExists($sRegistryTmp & "\HoboCopy.exe") _
			Or Not FileExists($sRegistryTmp & "\msvcp100.dll") _
			Or Not FileExists($sRegistryTmp & "\msvcr100.dll") Then
		MsgBox(16, $lFail, $lRegistryBackupError)
		QuitKprm(False, False)
	EndIf

	If @AutoItX64 = 0 Then _WinAPI_Wow64EnableWow64FsRedirection(False)

	For $i = 0 To UBound($aAllHives) - 1
		Local $sHive = $aAllHives[$i][0]
		Local $sBackupHivePath = $aAllHives[$i][1]

		If Not FileExists($sBackupHivePath) Then
			DirCreate($sBackupHivePath)
		EndIf

		Local $sDrive = "", $sDir = "", $sFileName = "", $sExtension = ""
		Local $aPathSplit = _PathSplit($sHive, $sDrive, $sDir, $sFileName, $sExtension)
		Local $sHiveFile = $sFileName & $sExtension
		$sDir = StringRegExpReplace($sDir, "\\$", "")
		Local $sBackupFile = $sBackUpPath & '\' & $sDir & '\' & $sHiveFile
		Local $sHivePath = $sDrive & $sDir

		If Not FileExists($sBackupFile) Then
			UpdateStatusBar("Backup registry  " & $sHive)

			RunWait(@ComSpec & ' /c HoboCopy.exe "' & $sHivePath & '" "' & $sBackupHivePath & '" ' & $sHiveFile, $sRegistryTmp, @SW_HIDE)

			Sleep(1000)

			If Not FileExists($sBackupFile) Then
				MsgBox(16, $lFail, $lRegistryBackupError & @CRLF & $sHive)
				LogMessage("  [X] Failed Registry Backup: " & $sHive)
				QuitKprm(False)
			Else
				ClearAttributes($sBackupFile)
				LogMessage("    ~ [OK] Hive " & $sHive & " backed up")
			EndIf
		EndIf
	Next

	LogMessage(@CRLF & "  [OK] Registry Backup: " & $sBackUpPath)
EndFunc   ;==>CreateBackupRegistryHobocopy


