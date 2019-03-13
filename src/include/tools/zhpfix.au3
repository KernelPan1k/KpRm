
Func RemoveZHPFix()
	Dim $KPDebug

	If $KPDebug Then logMessage(@CRLF & "- Search ZHPFix Files -" & @CRLF)

	Local $return = 0

	$return += CloseProcessAndWait("ZHPFix.exe")
	$return += CloseProcessAndWait("ZHPFix2.exe")

	Local Const $desciptionPattern = "(?i)^ZHPFix"

	$return += RemoveFile(@DesktopDir & "\ZHPFix.txt")
	$return += RemoveFile(@DesktopDir & "\ZHPFix.lnk")
	$return += RemoveFile(@DesktopDir & "\ZHPFix2.lnk")
	$return += RemoveFile(@DesktopCommonDir & "\ZHPFix.lnk")
	$return += RemoveFile(@DesktopCommonDir & "\ZHPFix2.lnk")
	$return += RemoveGlobFile(@DesktopDir, "ZHPFix?.exe", "(?i)^ZHPFix2?\.exe$", $desciptionPattern)
	$return += RemoveGlobFile(@DesktopDir, "ZHPFix (?).exe", "(?i)^ZHPFix \([0-9]\)\.exe$", $desciptionPattern)
	$return += RemoveGlobFile(@DesktopDir, "ZHPFix2 (?).exe", "(?i)^ZHPFix2 \([0-9]\)\.exe$", $desciptionPattern)

	Local Const $userDownloadFolder = @UserProfileDir & "\Downloads"
	Local Const $iFileExists = FileExists($userDownloadFolder)

	If $iFileExists Then
		$return += RemoveFile($userDownloadFolder & "\ZHPFix.txt")
		$return += RemoveGlobFile($userDownloadFolder, "ZHPFix?.exe", "(?i)^ZHPFix2?\.exe$", $desciptionPattern)
		$return += RemoveGlobFile($userDownloadFolder, "ZHPFix (?).exe", "(?i)^ZHPFix \([0-9]\)\.exe$", $desciptionPattern)
		$return += RemoveGlobFile($userDownloadFolder, "ZHPFix2 (?).exe", "(?i)^ZHPFix2 \([0-9]\)\.exe$", $desciptionPattern)
	EndIf

	$return += RemoveFolder(@AppDataDir & "\ZHP")
	$return += RemoveFolder(@LocalAppDataDir & "\ZHP")

	If $return > 0 Then
		If Not $KPDebug Then logMessage(@CRLF & "- Search ZHPFix Files -" & @CRLF)
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
			logMessage("  [OK] ZHPFix has been successfully removed")
		EndIf

	EndIf

	ProgressBarUpdate()
EndFunc   ;==>RemoveZHPFix
