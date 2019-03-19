
Func CustomEnd()

;~ 	######### ZHP
	If FileExists(@AppDataDir & "\ZHP") Then

		Local Const $taskName = "kprm-zhp-appdata"

		FileWrite(@HomeDrive & "\KPRM\kprm-zhp-appdata.bat", "RMDIR /S /Q " & @AppDataDir & "\ZHP")
		FileWrite(@HomeDrive & "\KPRM\kprm-zhp-appdata.bat", "DEL /F /Q " & @HomeDrive & "\KPRM\kprm-zhp-appdata.bat")
		FileWrite(@HomeDrive & "\KPRM\kprm-zhp-appdata.bat", "schtasks /delete " & $taskName)

		If Not _TaskExists($taskName) Then
			Local $tasksDate = _DateTimeFormat(_DateAdd('d', 3, _NowCalcDate()), 2)
		$tasksDate = StringReplace($tasksDate, ".", "/")
		$tasksDate = StringReplace($tasksDate, "-", "/")

		Local $task = 'schtasks /create /tn "kprm-zhp-appdata" /tr ' & @HomeDrive & "\KPRM\kprm-zhp-appdata.bat" & ' /sc once /st 06:33 /sd ' & $tasksDate & ' /RU SYSTEM'

		Run($task)
		EndIf
	EndIf
EndFunc