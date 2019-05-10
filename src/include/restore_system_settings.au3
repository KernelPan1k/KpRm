
Func RestoreSystemSettingsByDefault()
	logMessage(@CRLF & "- Restore Default System Settings -" & @CRLF)

	Local $status = RunWait(@ComSpec & " /c " & "ipconfig /flushdns", @TempDir, @SW_HIDE)

	If @error <> 0 Then
		logMessage("  [X] Flush DNS")
	Else
		logMessage("  [OK] Flush DNS")
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
		logMessage("  [OK] Reset WinSock")
	Else
		logMessage("  [X] Reset WinSock")
	EndIf

	Local $regvar = "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced"

	$status = RegWrite($regvar, "Hidden", "REG_DWORD", "2")

	If $status = 1 Then
		logMessage("  [OK] Hide Hidden file.")
	Else
		logMessage("  [X] Hide Hidden File")
	EndIf

	$status = RegWrite($regvar, "HideFileExt", "REG_DWORD", "0")

	If $status = 1 Then
		logMessage("  [OK] Show Extensions for known file types")
	Else
		logMessage("  [X] Show Extensions for known file types")
	EndIf

	$status = RegWrite($regvar, "ShowSuperHidden", "REG_DWORD", "0")

	If $status = 1 Then
		logMessage("  [OK] Hide protected operating system files")
	Else
		logMessage("  [X] Hide protected operating system files")
	EndIf

	_Restart_Windows_Explorer()

EndFunc   ;==>RestoreSystemSettingsByDefault
