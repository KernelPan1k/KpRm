
Func RemoveZHPFix()

	RemoveFile(@DesktopDir & "\ZHPFix.txt")
	RemoveFile(@DesktopDir & "\ZHPFix.lnk")
	RemoveFile(@DesktopDir & "\ZHPFix2.lnk")
	RemoveGlobFile(@DesktopDir, "ZHPFix?.exe", "^ZHPFix2?.exe$")
	RemoveGlobFile(@DesktopDir, "ZHPFix (?).exe", "^ZHPFix \([0-9]\).exe$")
	RemoveGlobFile(@DesktopDir, "ZHPFix2 (?).exe", "^ZHPFix2 \([0-9]\).exe$")

	Local Const $userDownloadFolder = @UserProfileDir & "\Downloads"
	Local Const $iFileExists = FileExists($userDownloadFolder)

	If $iFileExists Then
		RemoveFile($userDownloadFolder & "\ZHPFix.txt")
		RemoveGlobFile($userDownloadFolder, "ZHPFix?.exe", "^ZHPFix2?.exe$")
		RemoveGlobFile($userDownloadFolder, "ZHPFix (?).exe", "^ZHPFix \([0-9]\).exe$")
		RemoveGlobFile($userDownloadFolder, "ZHPFix2 (?).exe", "^ZHPFix2 \([0-9]\).exe$")
	EndIf

	Local Const $localUsers = _GetLocalUsers()

	If $localUsers <> 0 Then
		For $i = 1 To UBound($localUsers) - 1
			Local $uDesktop = TryResolveUserDesktop($localUsers[$i])
			RemoveFile($uDesktop & "\ZHPFix.lnk")
			RemoveFile($uDesktop & "\ZHPFix2.lnk")
		Next
	EndIf

	ProgressBarUpdate()
EndFunc   ;==>RemoveZHPFix
