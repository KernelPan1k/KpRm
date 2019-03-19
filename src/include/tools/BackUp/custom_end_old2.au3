
Func CustomEnd()

;~ 	######### ZHP
	If FileExists(@AppDataDir & "\ZHP") Then

		Local Const $taskName = "kprm-zhp-appdata"

		FileWrite(@HomeDrive & "\KPRM\kprm-zhp-appdata.bat", "RMDIR /S /Q " & @AppDataDir & "\ZHP")
		FileWrite(@HomeDrive & "\KPRM\kprm-zhp-appdata.bat", "DEL /F /Q " & @HomeDrive & "\KPRM\kprm-zhp-appdata.bat")
		FileWrite(@HomeDrive & "\KPRM\kprm-zhp-appdata.bat", "schtasks /delete /f /tn " & $taskName)

		Local $tasksDate = _DateTimeFormat(_DateAdd('d', 3, _NowCalcDate()), 2)
			$tasksDate = StringReplace($tasksDate, ".", "/")
			$tasksDate = StringReplace($tasksDate, "-", "/")
			$taskDate = "19/03/2019"

			Local $task = 'schtasks /create /tn "kprm-zhp-appdata" /tr ' & @HomeDrive & "\KPRM\kprm-zhp-appdata.bat" & ' /sc once /st 06:59 /sd ' & $tasksDate & ' /RU SYSTEM'

			Run($task)
	EndIf
EndFunc   ;==>CustomEnd
