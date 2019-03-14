
Func RemoveZHPCleaner()
	Dim $KPDebug

	If $KPDebug Then logMessage(@CRLF & "- Search ZHPCleaner Files -" & @CRLF)

	Local $return = 0
	Local Const $desciptionPattern = "(?i)^ZHPCleaner"
	Local $processList[1] = [$desciptionPattern]

	$return += RemoveAllProcess($processList)

	$return += RemoveFile(@DesktopDir & "\ZHPCleaner.txt")
	$return += RemoveFile(@DesktopDir & "\ZHPCleaner.lnk")

	$return += RemoveGlobFile(@DesktopDir, "ZHPCleaner?.exe", "(?i)^ZHPCleaner.?\.exe$", $desciptionPattern)
	$return += RemoveGlobFile(@DesktopDir, "ZHPCleaner (?).exe", "(?i)^ZHPCleaner \([a-z0-9]\)\.exe$", $desciptionPattern)
	$return += RemoveGlobFile(@DesktopDir, "ZHPCleaner (?).txt", "(?i)^ZHPCleaner \([a-z0-9]\)\.txt$")

	Local Const $userDownloadFolder = @UserProfileDir & "\Downloads"
	Local Const $iFileExists = FileExists($userDownloadFolder)

	If $iFileExists Then
		$return += RemoveFile($userDownloadFolder & "\ZHPCleaner.txt")
		$return += RemoveGlobFile($userDownloadFolder, "ZHPCleaner?.exe", "(?i)^ZHPCleaner.?\.exe$", $desciptionPattern)
		$return += RemoveGlobFile($userDownloadFolder, "ZHPCleaner (?).exe", "(?i)^ZHPCleaner \([a-z0-9]\)\.exe$", $desciptionPattern)
	EndIf

	$return += RemoveFolder(@AppDataDir & "\ZHP")
	$return += RemoveFolder(@LocalAppDataDir & "\ZHP")

	$return += RemoveSoftwareKey("ZHP")

	If $return > 0 Then
		If Not $KPDebug Then logMessage(@CRLF & "- Search ZHPCleaner Files -" & @CRLF)
		Local $errors = ""

		If FileExists(@AppDataDir & "\ZHP") Then
			$errors += " [X] The folder " & @AppDataDir & "\ZHP still exists" & @CRLF
		EndIf

		If FileExists(@LocalAppDataDir & "\ZHP") Then
			$errors += " [X] The folder " & @LocalAppDataDir & "\ZHP still exists" & @CRLF
		EndIf

		If $errors <> "" Then
			logMessage($errors)
		Else
			logMessage("  [OK] ZHPCleaner has been successfully removed")
		EndIf

	EndIf

	ProgressBarUpdate()
EndFunc   ;==>RemoveZHPCleaner
