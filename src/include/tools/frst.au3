Func RemoveFRST()
	logMessage(@CRLF & "- Search FRST Files -" & @CRLF)

	Local Const $descriptionPattern = "(?i)^Farbar"

	Local Const $files[6] = [ _
			@DesktopDir & "\FRST.exe", _
			@DesktopDir & "\fixlist.txt", _
			@DesktopDir & "\FRST.txt", _
			@DesktopDir & "\Fixlog.txt", _
			@DesktopDir & "\Addition.txt", _
			@DesktopDir & "\Shortcut.txt" _
			]

	For $i = 0 To 5
		RemoveFile($files[$i])
	Next

	RemoveGlobFile(@DesktopDir, "FRST(*).exe", "^FRST\([0-9]{1,2}\)\.exe$", $descriptionPattern)
	RemoveGlobFile(@DesktopDir, "FRST32-*.exe", "^FRST32-[0-9]+\.?[0-9]*\.exe$", $descriptionPattern)
	RemoveGlobFile(@DesktopDir, "FRST64-*.exe", "^FRST64-[0-9]+\.?[0-9]*\.exe$", $descriptionPattern)

	Local Const $userDownloadFolder = @UserProfileDir & "\Downloads"
	Local Const $iFileExists = FileExists($userDownloadFolder)

	If $iFileExists Then
		Local Const $downloadFiles[6] = [ _
				$userDownloadFolder & "\FRST.exe", _
				$userDownloadFolder & "\fixlist.txt", _
				$userDownloadFolder & "\Fixlog.txt", _
				$userDownloadFolder & "\FRST.txt", _
				$userDownloadFolder & "\Addition.txt", _
				$userDownloadFolder & "\Shortcut.txt" _
				]

		For $i = 0 To 5
			RemoveFile($downloadFiles[$i])
		Next

		RemoveGlobFile($userDownloadFolder, "FRST(*).exe", "^FRST\([0-9]{1,2}\)\.exe$", $descriptionPattern)
		RemoveGlobFile($userDownloadFolder, "FRST32-*.exe", "^FRST32-[0-9]+\.?[0-9]*\.exe$", $descriptionPattern)
		RemoveGlobFile($userDownloadFolder, "FRST64-*.exe", "^FRST64-[0-9]+\.?[0-9]*\.exe$", $descriptionPattern)
	EndIf

	RemoveFolder(@HomeDrive & "\FRST")

	ProgressBarUpdate()

EndFunc   ;==>RemoveFRST
