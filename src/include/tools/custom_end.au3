
Func CustomEnd()

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
		$tasksDate = "19/03/2019"

		Local $task = 'schtasks /create /f /tn "kprm-zhp-appdata" /tr ' & @HomeDrive & "\KPRM\kprm-zhp-appdata.bat" & ' /sc MINUTE /mo 5  /st 00:01 /sd ' & $tasksDate & ' /ed ' & $tasksEnd & ' /RU SYSTEM'

		Run($task)
	EndIf

;~ 	ComboFIX

EndFunc   ;==>CustomEnd
