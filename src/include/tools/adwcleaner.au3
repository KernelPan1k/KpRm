
Func RemoveAdwcleaner()
	Dim $KPDebug

	If $KPDebug Then logMessage(@CRLF & "- Search AdwCleaner Files -" & @CRLF)

	Local $return = 0
	Local Const $descriptionPattern = "(?i)^AdwCleaner"

	$return += RemoveGlobFile(@DesktopDir, "adwcleaner*.exe", "(?i)^adwcleaner(.*)\.exe$", $descriptionPattern)

	Local Const $userDownloadFolder = @UserProfileDir & "\Downloads"
	Local Const $iFileExists = FileExists($userDownloadFolder)

	If $iFileExists Then
		$return += RemoveGlobFile($userDownloadFolder, "adwcleaner*.exe", "(?i)^adwcleaner(.*)\.exe$", $descriptionPattern)
	EndIf

	$return += RemoveFolder(@HomeDrive & "\AdwCleaner")

	If $return > 0 Then
		If Not $KPDebug Then logMessage(@CRLF & "- Search AdwCleaner Files -" & @CRLF)

		If FileExists(@HomeDrive & "\AdwCleaner") Then
			logMessage("  [X] Directory " & @HomeDrive & "\AdwCleaner" & " delete failure")
		Else
			logMessage("  [OK] AdwCleaner has been successfully removed")
		EndIf

	EndIf

	ProgressBarUpdate()

EndFunc
