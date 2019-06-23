
Func CreateBackupRegistry()
	LogMessage(@CRLF & "- Create Registry Backup -" & @CRLF)

	Local Const $sBackUpPath = @HomeDrive & "\KPRM\backup"

	If Not FileExists($sBackUpPath) Then
		DirCreate($sBackUpPath)
	EndIf

	If Not FileExists($sBackUpPath) Then
		MsgBox(16, $lFail, $lRegistryBackupError)
		Exit
	EndIf

	Local Const $sBackupLocation = $sBackUpPath & "\regedit-backup-" & @YEAR & @MON & @MDAY & @HOUR & @MIN & ".reg"

	If FileExists($sBackupLocation) Then
		FileMove($sBackupLocation, $sBackupLocation & ".old")
	EndIf

	Local Const $status = RunWait("Regedit /e " & $sBackupLocation)

	If Not FileExists($sBackupLocation) Or @error <> 0 Then
		LogMessage("  [X] Failed to create registry backup")
		MsgBox(16, $lFail, $lRegistryBackupError)
		QuitKprm()
	Else
		LogMessage("  [OK] Registry Backup: " & $sBackupLocation)
	EndIf
EndFunc   ;==>CreateBackupRegistry
