
Func searchUninstallStrings()
	$i = 0
	$uninstall_path = "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall"
	While True
		$i += 1
		Local $entry = RegEnumKey($uninstall_path, $i)
		If @error <> 0 Then ExitLoop
		$regPath = $uninstall_path & "\" & $entry
		$DisplayName = RegRead($regPath, "DisplayName")

		If StringRegExp($DisplayName, "^Roguekiller") Then
			Return $regPath
		EndIf
	WEnd

	Return Null
EndFunc   ;==>searchUninstallStrings

Func RemoveRogueKiller()
	logMessage(@CRLF & "- Search RogueKiller Files -" & @CRLF)

	Local $status = ProcessWaitClose("RogueKiller.exe", 10)

	If $status = 1 Then
		logMessage("  [OK] RogueKiller.exe was stopped correctly")
	EndIf

	ShellExecuteWait("schtasks.exe", '/delete /tn "RogueKiller Anti-Malware" /f', @SW_HIDE)

	If @error = 0 Then
		logMessage("  [OK] RogueKiller.exe was deleted from schedule")
	EndIf

	Local Const $installReg = searchUninstallStrings()

	If $installReg Then
		RemoveRegistryKey($installReg)
	EndIf

	RemoveFolder(@HomeDrive & "\Program Files(x86)" & "\RogueKiller")
	RemoveFolder(@HomeDrive & "\Program Files" & "\RogueKiller")

	RemoveFolder(@AppDataCommonDir & "\RogueKiller")
	RemoveFolder(@AppDataCommonDir & "\Microsoft\Windows\Start Menu\Programs\RogueKiller")

	ProgressBarUpdate()
EndFunc   ;==>RemoveRogueKiller

