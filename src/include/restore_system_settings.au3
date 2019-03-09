
Func RestoreSystemSettingsByDefault()
	logMessage(@CRLF & "=> ************* Restore Default System Settings ************** <=" & @CRLF)

	Local $status = RunWait(@ComSpec & " /c " & "ipconfig /flushdns")

	If @error <> 0 Then
		logMessage("  [X] Flush DNS failed")
	Else
		logMessage("  [OK] Flush DNS successfully.")
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

	For $i = 0 To 6
		RunWait(@ComSpec & " /c " & $commands[$i])

		If @error <> 0 Then
			$status += 1
		EndIf
	Next

	If $status = 0 Then
		logMessage("  [OK] Flush DNS successfully.")
	Else
		logMessage("  [X] Flush DNS failed")
	EndIf

	$regvar = "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced"

	$status = RegWrite($regvar, "Hidden", "REG_DWORD", "2")

	If $status = 1 Then
		logMessage("  [OK] Hide Hidden file successfully.")
	Else
		logMessage("  [X] Hide Hidden File failed")
	EndIf

	$status = RegWrite($regvar, "HideFileExt", "REG_DWORD", "1")

	If $status = 1 Then
		logMessage("  [OK] Hide Extensions for known file types successfully.")
	Else
		logMessage("  [X] Hide Extensions for known file types failed")
	EndIf

	$status = RegWrite($regvar, "ShowSuperHidden", "REG_DWORD", "0")

	If $status = 1 Then
		logMessage("  [OK] Hide protected operating system files successfully.")
	Else
		logMessage("  [X] Hide protected operating system files failed")
	EndIf

	_Restart_Windows_Explorer()

EndFunc   ;==>RestoreSystemSettingsByDefault
