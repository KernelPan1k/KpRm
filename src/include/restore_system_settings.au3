
Func RestoreSystemSettingsByDefault()
	logMessage(@CRLF & "- Restore Default System Settings -" & @CRLF)

	Local $status = RunWait(@ComSpec & " /c " & "ipconfig /flushdns", @TempDir, @SW_HIDE)

	If @error <> 0 Then
		logMessage("  [X] Flush DNS failure")
	Else
		logMessage("  [OK] Flush DNS successfully completed")
	EndIf

;~ #################

	Local Const $commands[7] = [ _
			"netsh winsock reset", _
			"netsh winhttp reset proxy", _
			"netsh winhttp reset tracing", _
			"netsh winsock reset catalog", _
			"netsh int ip reset all", _
			"netsh int ipv4 reset catalog", _
			"netsh int ipv6 reset catalog" _
			]

	$status = 0

	For $i = 0 To UBound($commands) -1
		RunWait(@ComSpec & " /c " & $commands[$i], @TempDir, @SW_HIDE)

		If @error <> 0 Then
			$status += 1
		EndIf
	Next

	If $status = 0 Then
		logMessage("  [OK] Reset WinSock successfully completed")
	Else
		logMessage("  [X] Reset WinSock failure")
	EndIf

	$regvar = "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced"

	$status = RegWrite($regvar, "Hidden", "REG_DWORD", "2")

	If $status = 1 Then
		logMessage("  [OK] Hide Hidden file successfully.")
	Else
		logMessage("  [X] Hide Hidden File failure")
	EndIf

	$status = RegWrite($regvar, "HideFileExt", "REG_DWORD", "1")

	If $status = 1 Then
		logMessage("  [OK] Hide Extensions for known file types successfully.")
	Else
		logMessage("  [X] Hide Extensions for known file types failure")
	EndIf

	$status = RegWrite($regvar, "ShowSuperHidden", "REG_DWORD", "0")

	If $status = 1 Then
		logMessage("  [OK] Hide protected operating system files successfully.")
	Else
		logMessage("  [X] Hide protected operating system files failure")
	EndIf

	_Restart_Windows_Explorer()

EndFunc   ;==>RestoreSystemSettingsByDefault
