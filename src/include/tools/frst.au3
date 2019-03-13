Dim $nbrTask

$nbrTask += 1

Func RemoveFRST()
	Dim $KPDebug

	If $KPDebug Then logMessage(@CRLF & "- Search FRST Files -" & @CRLF)

	Local $return = 0
	Local Const $descriptionPattern = "(?i)^Farbar"

	Local Const $files[6] = [ _
			@DesktopDir & "\FRST.exe", _
			@DesktopDir & "\fixlist.txt", _
			@DesktopDir & "\FRST.txt", _
			@DesktopDir & "\Fixlog.txt", _
			@DesktopDir & "\Addition.txt", _
			@DesktopDir & "\Shortcut.txt" _
			]

	For $i = 0 To UBound($files) - 1
		$return += RemoveFile($files[$i])
	Next

	$return += RemoveGlobFile(@DesktopDir, "FRST(*).exe", "^FRST\([0-9]{1,2}\)\.exe$", $descriptionPattern)
	$return += RemoveGlobFile(@DesktopDir, "FRST32-*.exe", "^FRST32-[0-9]+\.?[0-9]*\.exe$", $descriptionPattern)
	$return += RemoveGlobFile(@DesktopDir, "FRST64-*.exe", "^FRST64-[0-9]+\.?[0-9]*\.exe$", $descriptionPattern)

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

		For $i = 0 To UBound($downloadFiles) - 1
			$return += RemoveFile($downloadFiles[$i])
		Next

		$return += RemoveFolder($userDownloadFolder & "\FRST-OlderVersion")

		$return += RemoveGlobFile($userDownloadFolder, "FRST(*).exe", "^FRST\([0-9]{1,2}\)\.exe$", $descriptionPattern)
		$return += RemoveGlobFile($userDownloadFolder, "FRST32-*.exe", "^FRST32-[0-9]+\.?[0-9]*\.exe$", $descriptionPattern)
		$return += RemoveGlobFile($userDownloadFolder, "FRST64-*.exe", "^FRST64-[0-9]+\.?[0-9]*\.exe$", $descriptionPattern)
	EndIf

	$return += RemoveFolder(@HomeDrive & "\FRST")
	$return += RemoveFolder(@DesktopDir & "\FRST-OlderVersion")

	If $return > 0 Then
		If Not $KPDebug Then logMessage(@CRLF & "- Search FRST Files -" & @CRLF)

		If FileExists(@HomeDrive & "\FRST") Then
			logMessage("  [X] Directory " & @HomeDrive & "\FRST" & " delete failure")
		Else
			logMessage("  [OK] FRST has been successfully removed")
		EndIf

	EndIf

	ProgressBarUpdate()

EndFunc   ;==>RemoveFRST
