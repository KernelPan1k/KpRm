
Func RemoveMBAR($retry = False)
	Dim $KPDebug

	If $KPDebug Then logMessage(@CRLF & "- Search MBAR Files -" & @CRLF)

	Local $return = 0
	Local Const $descriptionPattern = "(?i)^Malwarebytes"
	Local $processList[1] = [$descriptionPattern]

	$return += RemoveAllProcess($processList)

	If FileExists(@DesktopDir & "\mbar\mbar.exe") Then
		$return = 1
		RemoveFolder(@DesktopDir & "\mbar")
	EndIf

	$return += RemoveGlobFile(@DesktopDir, "mbar-*.exe", "(?i)^mbar-[0-9.-]+\.exe$", $descriptionPattern)

	Local Const $userDownloadFolder = @UserProfileDir & "\Downloads"

	If FileExists($userDownloadFolder) Then
		$return += RemoveFolder($userDownloadFolder & "\mbar")
		$return += RemoveGlobFile($userDownloadFolder, "mbar-*.exe", "(?i)^mbar-[0-9.-]+\.exe$", $descriptionPattern)
	EndIf

	$return += RemoveSoftwareKey("Malwarebytes Anti-Rootkit")
	$return += RemoveFolder(@AppDataCommonDir & "\Malwarebytes")
	$return += RemoveGlobFolder(@AppDataCommonDir, "Malwarebytes*", $descriptionPattern)
	$return += RemoveFile(@WindowsDir & "\System32" & "\drivers\MbamChameleon.sys", $descriptionPattern)
	$return += RemoveFile(@WindowsDir & "\SYSWOW32" & "\drivers\MbamChameleon.sys", $descriptionPattern)

	If $return > 0 Then
		If Not $KPDebug And $retry = False Then
			logMessage(@CRLF & "- Search MBAR Files -" & @CRLF)
		EndIf

		Local $errors = ""

		If FileExists(@DesktopDir & "\mbar\mbar.exe") Then
			$errors += " [X] The folder " & @DesktopDir & "\mbar still exists" & @CRLF
		EndIf

		If FileExists($userDownloadFolder & "\mbar\mbar.exe") Then
			$errors += " [X] The folder " & $userDownloadFolder & "\mbar still exists" & @CRLF
		EndIf

		If FileExists(@WindowsDir & "\System32" & "\drivers\MbamChameleon.sys") Then
			$errors += " [X] " & @WindowsDir & "\System32" & "\drivers\MbamChameleon.sys still exists" & @CRLF
		EndIf

		If FileExists(@WindowsDir & "\SYSWOW64" & "\drivers\MbamChameleon.sys") Then
			$errors += " [X] " & @WindowsDir & "\SYSWOW64" & "\drivers\MbamChameleon.sys still exists" & @CRLF
		EndIf

		If $errors <> "" Then
			If $retry = False Then
				RemoveMBAR(True)
			Else
				logMessage($errors)
			EndIf
		Else
			logMessage("  [OK] MBAR has been successfully removed")
		EndIf

	EndIf


	ProgressBarUpdate()
EndFunc   ;==>RemoveMBAR
