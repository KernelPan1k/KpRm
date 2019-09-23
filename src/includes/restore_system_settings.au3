
Func RestoreSystemSettingsByDefault()
	LogMessage(@CRLF & "- Restore System Settings -" & @CRLF)

	UpdateStatusBar("Restore system settings")

	Local $iStatus = RunWait(@ComSpec & " /c " & "ipconfig /flushdns", @TempDir, @SW_HIDE)

	If @error <> 0 Then
		LogMessage("  [X] Flush DNS")
	Else
		LogMessage("  [OK] Flush DNS")
	EndIf

;~ #################

	Local Const $aCommands[7] = [ _
			"netsh winsock reset", _
			"netsh winhttp reset proxy", _
			"netsh winhttp reset tracing", _
			"netsh winsock reset catalog", _
			"netsh int ip reset all", _
			"netsh int ipv4 reset catalog", _
			"netsh int ipv6 reset catalog" _
			]

	$iStatus = 0

	For $i = 0 To UBound($aCommands) -1
		RunWait(@ComSpec & " /c " & $aCommands[$i], @TempDir, @SW_HIDE)

		If @error <> 0 Then
			$iStatus += 1
		EndIf
	Next

	If $iStatus = 0 Then
		LogMessage("  [OK] Reset WinSock")
	Else
		LogMessage("  [X] Reset WinSock")
	EndIf

    Local $s64Bit = GetSuffixKey()
	Local $sRegvar = "HKCU" & $s64Bit & "\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced"

	$iStatus = RegWrite($sRegvar, "Hidden", "REG_DWORD", "2")

	If $iStatus = 1 Then
		LogMessage("  [OK] Hide Hidden file.")
	Else
		LogMessage("  [X] Hide Hidden File")
	EndIf

	$iStatus = RegWrite($sRegvar, "HideFileExt", "REG_DWORD", "0")

	If $iStatus = 1 Then
		LogMessage("  [OK] Show Extensions for known file types")
	Else
		LogMessage("  [X] Show Extensions for known file types")
	EndIf

	$iStatus = RegWrite($sRegvar, "ShowSuperHidden", "REG_DWORD", "0")

	If $iStatus = 1 Then
		LogMessage("  [OK] Hide protected operating system files")
	Else
		LogMessage("  [X] Hide protected operating system files")
	EndIf

	_Restart_Windows_Explorer()

EndFunc   ;==>RestoreSystemSettingsByDefault
