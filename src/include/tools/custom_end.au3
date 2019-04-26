
Func CustomEnd()
	Local $s64Bit = ""
	If @OSArch = "X64" Then $s64Bit = "64"

;~ 	MBAR

	If FileExists(@AppDataCommonDir & "\Malwarebytes\Malwarebytes' Anti-Malware\Quarantine") Then
		Local $FileList = _FileListToArray(@AppDataCommonDir & "\Malwarebytes\Malwarebytes' Anti-Malware\Quarantine")

		If @error = 0 Then
			For $i = 1 To $FileList[0]
				FileDelete(@AppDataCommonDir & "\Malwarebytes\Malwarebytes' Anti-Malware\Quarantine" & '\' & $FileList[$i])
			Next
			UpdateToolCpt("mbar", 'special', @AppDataCommonDir & "\Malwarebytes\Malwarebytes' Anti-Malware\Quarantine\*")
		EndIf
	EndIf

;~  All

	Local Const $reg[2] = [ _
			"HKLM" & $s64Bit & "\SOFTWARE\Microsoft\Windows\Windows Error Reporting\LocalDumps\RogueKiller.exe", _
			"HKLM" & $s64Bit & "\SOFTWARE\Microsoft\Windows\CurrentVersion\App Paths\combofix.exe"]

	For $r = 0 To UBound($reg) - 1
		RemoveRegistryKey($reg[$r], "roguekiller")
	Next

EndFunc   ;==>CustomEnd
