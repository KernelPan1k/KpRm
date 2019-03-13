Dim $nbrTask

$nbrTask += 1

Func RemoveRogueKiller($retry = False)
	Dim $KPDebug

	If $KPDebug Then logMessage(@CRLF & "- Search RogueKiller Files -" & @CRLF)

	Local $return = 0
	Local Const $descriptionPattern = "(?i)^RogueKiller"

	$return += CloseProcessAndWait("RogueKiller.exe")

	RunWait('schtasks.exe /delete /tn "RogueKiller Anti-Malware" /f', @TempDir, @SW_HIDE)

	If @error = 0 Then
		If $KPDebug Then logMessage("  [OK] RogueKiller.exe was deleted from schedule")
		$return += 1
	EndIf

	Local $s64Bit = ""
	If @OSArch = "X64" Then $s64Bit = "64"

	Local $installReg = searchRegistryKeyStrings("HKLM" & $s64Bit & "\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall", "(?i)^RogueKiller", "DisplayName")

	If $installReg Then
		$return += RemoveRegistryKey($installReg)
	EndIf

	$return += RemoveFolder(@HomeDrive & "\Program Files(x86)" & "\RogueKiller")
	$return += RemoveFolder(@HomeDrive & "\Program Files" & "\RogueKiller")
	$return += RemoveFolder(@AppDataCommonDir & "\RogueKiller")
	$return += RemoveFolder(@AppDataCommonDir & "\Microsoft\Windows\Start Menu\Programs\RogueKiller")
	$return += RemoveFile(@DesktopDir & "\RogueKiller.lnk")
	$return += RemoveGlobFile(@DesktopDir, "RogueKiller*.exe", "(?i)^RogueKiller(.*)\.exe$", $descriptionPattern)
	$return += RemoveFile(@DesktopCommonDir & "\RogueKiller.lnk")

	Local Const $userDownloadFolder = @UserProfileDir & "\Downloads"
	Local $iFileExists = FileExists($userDownloadFolder)

	If $iFileExists Then
		$return += RemoveGlobFile($userDownloadFolder, "RogueKiller*.exe", "(?i)^RogueKiller(.*)\.exe$", $descriptionPattern)
	EndIf

	If $return > 0 Then
		If Not $KPDebug And $retry = False Then
			logMessage(@CRLF & "- Search RogueKiller Files -" & @CRLF)
		EndIf

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

		$installReg = searchRegistryKeyStrings("HKLM" & $s64Bit & "\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall", "(?i)^RogueKiller", "DisplayName")

		If $installReg Then
			$errors += " [X] SOFTWARE KEY stell exists" & @CRLF
		EndIf

		If TasksExist("RogueKiller Anti-Malware") Then
			$errors += " [X] Schedule Tasks stell exists" & @CRLF
		EndIf

		If $errors <> "" Then
			If $retry = False Then
				RemoveRogueKiller(True)
			Else
				logMessage($errors)
			EndIf
		Else
			logMessage("  [OK] RogueKiller has been successfully removed")
		EndIf

	EndIf

	ProgressBarUpdate()
EndFunc   ;==>RemoveRogueKiller

