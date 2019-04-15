
Func CustomEnd()

	Local $s64Bit = ""
	If @OSArch = "X64" Then $s64Bit = "64"

;~ 	######### ZHP
	If FileExists(@AppDataDir & "\ZHP") Then

		Local Const $taskName = "kprm-zhp-appdata"

		If FileExists(@HomeDrive & "\KPRM\kprm-zhp-appdata.bat") Then
			FileDelete(@HomeDrive & "\KPRM\kprm-zhp-appdata.bat")
		EndIf

		FileWrite(@HomeDrive & "\KPRM\kprm-zhp-appdata.bat", 'schtasks /delete /f /tn "' & $taskName & '" ' & @CRLF)
		FileWrite(@HomeDrive & "\KPRM\kprm-zhp-appdata.bat", "RMDIR /S /Q " & @AppDataDir & "\ZHP " & @CRLF)
		FileWrite(@HomeDrive & "\KPRM\kprm-zhp-appdata.bat", "DEL /F /Q " & @HomeDrive & "\KPRM\kprm-zhp-appdata.bat " & @CRLF)

		Local $tasksDate = _DateTimeFormat(_DateAdd('d', 3, _NowCalcDate()), 2)
		$tasksDate = StringReplace($tasksDate, ".", "/")
		$tasksDate = StringReplace($tasksDate, "-", "/")

		Local $tasksEnd = _DateTimeFormat(_DateAdd('y', 1, _NowCalcDate()), 2)
		$tasksEnd = StringReplace($tasksEnd, ".", "/")
		$tasksEnd = StringReplace($tasksEnd, "-", "/")

		Local $task = 'schtasks /create /f /tn "kprm-zhp-appdata" /tr ' & @HomeDrive & "\KPRM\kprm-zhp-appdata.bat" & ' /sc MINUTE /mo 5  /st 00:01 /sd ' & $tasksDate & ' /ed ' & $tasksEnd & ' /RU SYSTEM'

		Run($task)
	EndIf

;~ 	MBAR

	If FileExists(@AppDataCommonDir & "\Malwarebytes\Malwarebytes' Anti-Malware\Quarantine") Then
		Local $FileList = _FileListToArray(@AppDataCommonDir & "\Malwarebytes\Malwarebytes' Anti-Malware\Quarantine")

		If @error = 0 Then
			For $i = 1 To $FileList[0]
				FileDelete(@AppDataCommonDir & "\Malwarebytes\Malwarebytes' Anti-Malware\Quarantine" & '\' & $FileList[$i])
			Next
		EndIf
	EndIf

;~  All

	Local Const $reg[2] = [ _
			"HKLM" & $s64Bit & "\SOFTWARE\Microsoft\Windows\Windows Error Reporting\LocalDumps\RogueKiller.exe", _
			"HKLM" & $s64Bit & "\SOFTWARE\Microsoft\Windows\CurrentVersion\App Paths\combofix.exe"]

	For $r = 0 To UBound($reg) - 1
		RemoveRegistryKey($reg[$r])
	Next

EndFunc   ;==>CustomEnd
