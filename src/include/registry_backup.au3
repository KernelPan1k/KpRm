
Func CreateBackupRegistry()
	logMessage(@CRLF & "=> ************* Create Registry Backup ************** <=" & @CRLF)

	Local Const $backUpPath = @WindowsDir & "\KPRM-REGISTRY-BACKUP"

	If Not FileExists($backUpPath) Then
		DirCreate($backUpPath)
	EndIf

	If Not FileExists($backUpPath) Then
		logMessage("  [X] Failed to create " & $backUpPath & " directory")
		Exit
	EndIf

	Local Const $backupLocation = $backUpPath & "\kprm-registry-backup-" & @MON & @MDAY & @HOUR & @MIN & ".reg"

	If FileExists($backupLocation) Then
		FileMove($backupLocation, $backupLocation & ".old")
	EndIf

	Local Const $status = RunWait("Regedit /e " & $backupLocation)

	Sleep(3000)

	If Not FileExists($backupLocation) Or @error <> 0 Then
		logMessage("  [X] Failed to create backup registry")
		Exit
	Else
		logMessage("  [OK] Backup Registry ceated successfully at " & $backupLocation)
	EndIf
EndFunc   ;==>CreateBackupRegistry
