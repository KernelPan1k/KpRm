
Func RemoveZHPDiag()
	logMessage(@CRLF & "- Search ZHPDiag Files -" & @CRLF)

	CloseProcessAndWait("ZHPDiag.exe")
	CloseProcessAndWait("ZHPDiag3.exe")

	Local Const $desciptionPattern = "(?i)^ZHPDiag"

	RemoveFile(@DesktopDir & "\ZHPDiag.txt")
	RemoveFile(@DesktopDir & "\ZHPDiag.lnk")
	RemoveGlobFile(@DesktopDir, "ZHPDiag?.exe", "^ZHPDiag3?.exe$", $desciptionPattern)
	RemoveGlobFile(@DesktopDir, "ZHPDiag (?).exe", "^ZHPDiag \([0-9]\).exe$", $desciptionPattern)
	RemoveGlobFile(@DesktopDir, "ZHPDiag3 (?).exe", "^ZHPDiag3 \([0-9]\).exe$", $desciptionPattern)

	Local Const $userDownloadFolder = @UserProfileDir & "\Downloads"
	Local Const $iFileExists = FileExists($userDownloadFolder)

	If $iFileExists Then
		RemoveFile($userDownloadFolder & "\ZHPDiag.txt")
		RemoveGlobFile($userDownloadFolder, "ZHPDiag?.exe", "^ZHPDiag3?.exe$", $desciptionPattern)
		RemoveGlobFile($userDownloadFolder, "ZHPDiag (?).exe", "^ZHPDiag \([0-9]\).exe$", $desciptionPattern)
		RemoveGlobFile($userDownloadFolder, "ZHPDiag3 (?).exe", "^ZHPDiag3 \([0-9]\).exe$", $desciptionPattern)
	EndIf

	RemoveFolder(@AppDataDir & "\ZHP")
	RemoveFolder(@LocalAppDataDir & "\ZHP")

	Local Const $localUsers = _GetLocalUsers()

	If $localUsers <> 0 Then
		For $i = 1 To UBound($localUsers) - 1
			Local $uDesktop = TryResolveUserDesktop($localUsers[$i])
			RemoveFile($uDesktop & "\ZHPDiag.lnk")
		Next
	EndIf

	RemoveSoftwareKey("ZHP")

	ProgressBarUpdate()
EndFunc   ;==>RemoveZHPDiag
