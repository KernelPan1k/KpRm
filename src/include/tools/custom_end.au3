
Func CustomEnd()
	Local $s64Bit = ""
	If @OSArch = "X64" Then $s64Bit = "64"

;~ 	MBAR

	If FileExists(@AppDataCommonDir & "\Malwarebytes\Malwarebytes' Anti-Malware\Quarantine") Then
		Local $FileList = _FileListToArray(@AppDataCommonDir & "\Malwarebytes\Malwarebytes' Anti-Malware\Quarantine")

		If @error = 0 Then
			For $i = 1 To $FileList[0]
				RemoveFile(@AppDataCommonDir & "\Malwarebytes\Malwarebytes' Anti-Malware\Quarantine" & '\' & $FileList[$i], "mbar", Null, True)
			Next
		EndIf
	EndIf

;~  All

	RemoveRegistryKey("HKLM" & $s64Bit & "\SOFTWARE\Microsoft\Windows\CurrentVersion\App Paths\combofix.exe", "combofix")
	RemoveRegistryKey("HKLM" & $s64Bit & "\SYSTEM\CurrentControlSet\Enum\Root\LEGACY_ASWMBR", "aswmbr", True)

EndFunc   ;==>CustomEnd
