
Func CreateBackupRegistry()
	logMessage(@CRLF & "- Create Registry Backup -" & @CRLF)

	Local Const $backUpPath = @HomeDrive & "\KPRM"

	Local Const $backupLocation = $backUpPath & "\regedit-backup-" & @YEAR & @MON & @MDAY & @HOUR & @MIN & ".reg"

	If FileExists($backupLocation) Then
		FileMove($backupLocation, $backupLocation & ".old")
	EndIf

	Local Const $status = RunWait("Regedit /e " & $backupLocation)

	If Not FileExists($backupLocation) Or @error <> 0 Then
		logMessage("  [X] Failed to create registry backup")
		MsgBox(16, $lFail, $lRegistryBackupError)
		quitKprm()
	Else
		logMessage("  [OK] Registry Backup created successfully at " & $backupLocation)
	EndIf
EndFunc   ;==>CreateBackupRegistry
