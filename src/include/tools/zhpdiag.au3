

Func RemoveZHPDiag()

	RemoveFile(@DesktopDir & "\ZHPDiag.txt")
	RemoveFile(@DesktopDir & "\ZHPDiag.lnk")
	RemoveGlobFile(@DesktopDir, "ZHPDiag?.exe", "^ZHPDiag3?.exe$")
	RemoveGlobFile(@DesktopDir, "ZHPDiag (?).exe", "^ZHPDiag \([0-9]\).exe$")
	RemoveGlobFile(@DesktopDir, "ZHPDiag3 (?).exe", "^ZHPDiag3 \([0-9]\).exe$")

	Local Const $userDownloadFolder = @UserProfileDir & "\Downloads"
	Local Const $iFileExists = FileExists($userDownloadFolder)

	If $iFileExists Then
		RemoveFile($userDownloadFolder & "\ZHPDiag.txt")
		RemoveGlobFile($userDownloadFolder, "ZHPDiag?.exe", "^ZHPDiag3?.exe$")
		RemoveGlobFile($userDownloadFolder, "ZHPDiag (?).exe", "^ZHPDiag \([0-9]\).exe$")
		RemoveGlobFile($userDownloadFolder, "ZHPDiag3 (?).exe", "^ZHPDiag3 \([0-9]\).exe$")
	EndIf

	RemoveFolder(@AppDataDir & "\ZHP")

	ProgressBarUpdate()
EndFunc   ;==>RemoveZHPDiag
