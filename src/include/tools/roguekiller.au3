
Func RemoveRogueKiller()
	logMessage(@CRLF & "- Search RogueKiller Files -" & @CRLF)

	CloseProcessAndWait("RogueKiller.exe")

	ShellExecuteWait("schtasks.exe", '/delete /tn "RogueKiller Anti-Malware" /f', @SW_HIDE)

	If @error = 0 Then
		logMessage("  [OK] RogueKiller.exe was deleted from schedule")
	EndIf

	Local Const $installReg = searchRegistryKeyStrings("HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall", "(?i)^RogueKiller", "DisplayName")

	If $installReg Then
		RemoveRegistryKey($installReg)
	EndIf

	RemoveFolder(@HomeDrive & "\Program Files(x86)" & "\RogueKiller")
	RemoveFolder(@HomeDrive & "\Program Files" & "\RogueKiller")

	RemoveFolder(@AppDataCommonDir & "\RogueKiller")
	RemoveFolder(@AppDataCommonDir & "\Microsoft\Windows\Start Menu\Programs\RogueKiller")

	ProgressBarUpdate()
EndFunc   ;==>RemoveRogueKiller

