
Func RemoveRogueKiller()
	Dim $KPDebug

	If $KPDebug Then logMessage(@CRLF & "- Search RogueKiller Files -" & @CRLF)

	Local $return = 0

	$return += CloseProcessAndWait("RogueKiller.exe")

	ShellExecuteWait("schtasks.exe", '/delete /tn "RogueKiller Anti-Malware" /f', @SW_HIDE)

	If @error = 0 Then
		If $KPDebug Then logMessage("  [OK] RogueKiller.exe was deleted from schedule")
		$return += 1
	EndIf

	Local Const $installReg = searchRegistryKeyStrings("HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall", "(?i)^RogueKiller", "DisplayName")

	If $installReg Then
		$return += RemoveRegistryKey($installReg)
	EndIf

	$return +=  RemoveFolder(@HomeDrive & "\Program Files(x86)" & "\RogueKiller")
	$return +=  RemoveFolder(@HomeDrive & "\Program Files" & "\RogueKiller")

	$return +=  RemoveFolder(@AppDataCommonDir & "\RogueKiller")
	$return += RemoveFolder(@AppDataCommonDir & "\Microsoft\Windows\Start Menu\Programs\RogueKiller")

	$return += RemoveFile(@DesktopDir & "\RogueKiller.lnk")

	If $return > 0 Then
		If Not $KPDebug Then logMessage(@CRLF & "- Search RogueKiller Files -" & @CRLF)
		Local $errors = ""

		If FileExists(@HomeDrive & "\Program Files(x86)" & "\RogueKiller") Then
			$errors += " [X] The folder " & @HomeDrive & "\Program Files(x86)" & "\RogueKiller still exists" & @CRLF
		EndIf

		If FileExists(@HomeDrive & "\Program Files" & "\RogueKiller") Then
			$errors += " [X] The folder " & @HomeDrive & "\Program Files" & "\RogueKiller still exists" & @CRLF
		EndIf

		If FileExists(@AppDataCommonDir & "\RogueKiller") Then
			$errors += " [X] The folder " & @AppDataCommonDir & "\RogueKiller still exists" & @CRLF
		EndIf

		If FileExists(@AppDataCommonDir & "\Microsoft\Windows\Start Menu\Programs\RogueKiller") Then
			$errors += " [X] The folder " & @AppDataCommonDir & "\Microsoft\Windows\Start Menu\Programs\RogueKiller still exists" & @CRLF
		EndIf

		If $errors <> "" Then
			logMessage($errors)
		Else
			logMessage("  [OK] RogueKiller has been successfully removed")
		EndIf

	EndIf

	ProgressBarUpdate()
EndFunc   ;==>RemoveRogueKiller

