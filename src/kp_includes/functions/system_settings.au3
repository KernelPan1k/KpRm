Func RestoreSystemSettingsByDefault()
	LogMessage(@CRLF & "- Restore System Settings -" & @CRLF)

	UpdateStatusBar("Restore system settings ...")

	Local $aCommands[8]

	$aCommands[0] = "netsh winsock reset"
	$aCommands[1] = "netsh winhttp reset proxy"
	$aCommands[2] = "netsh winhttp reset tracing"
	$aCommands[3] = "netsh winsock reset catalog"
	$aCommands[4] = "netsh int ip reset all"
	$aCommands[5] = "netsh int ipv4 reset catalog"
	$aCommands[6] = "netsh int ipv6 reset catalog"
	$aCommands[7] = "ipconfig /flushdns"

	For $sCommands In $aCommands
		RunWait(@ComSpec & " /c" & $sCommands, '', @SW_HIDE)
	Next

	LogMessage("     [OK] Reset WinSock" & @CRLF & "     [OK] FLUSHDNS")

	Local $s64Bit = GetSuffixKey()
	Local $sRegvar = "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced"

	If RegWrite($sRegvar, "Hidden", "REG_DWORD", "2") Then
		LogMessage("     [OK] Hide Hidden file.")
	Else
		LogMessage("     [X] Hide Hidden File")
	EndIf

	If RegWrite($sRegvar, "HideFileExt", "REG_DWORD", "0") Then
		LogMessage("     [OK] Show Extensions for known file types")
	Else
		LogMessage("     [X] Show Extensions for known file types")
	EndIf

	If RegWrite($sRegvar, "ShowSuperHidden", "REG_DWORD", "0") Then
		LogMessage("     [OK] Hide protected operating system files")
	Else
		LogMessage("     [X] Hide protected operating system files")
	EndIf

	_Restart_Windows_Explorer()

EndFunc   ;==>RestoreSystemSettingsByDefault
