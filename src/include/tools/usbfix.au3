
Func RemoveUSBFIX()
	Dim $KPDebug
	If $KPDebug Then logMessage(@CRLF & "- Search UsbFix Files -" & @CRLF)

	Local $return = 0
	Local Const $descriptionPattern = "(?i)^UsbFix"

	If FileExists(@HomeDrive & "\Program Files (x86)" & "\UsbFix\Un-UsbFix.exe") Then
		$return = 1

		RunWait(@HomeDrive & "\Program Files (x86)" & "\UsbFix\Un-UsbFix.exe")

		$return += RemoveFolder(@HomeDrive & "\Program Files (x86)" & "\UsbFix")
	EndIf

	If FileExists(@HomeDrive & "\Program Files" & "\UsbFix\Un-UsbFix.exe") Then
		$return = 1

		RunWait(@HomeDrive & "\Program Files" & "\UsbFix\Un-UsbFix.exe")

		$return += RemoveFolder(@HomeDrive & "\Program Files" & "\UsbFix")
	EndIf

	$return += RemoveFile(@DesktopDir & "\UsbFix Anti-Malware.lnk")
	$return += RemoveFile(@DesktopCommonDir & "\UsbFix Anti-Malware.lnk")
	$return += RemoveGlobFile(@DesktopDir, "UsbFix*.exe", "^(?i)UsbFix.*\.exe$", $descriptionPattern)

	Local Const $userDownloadFolder = @UserProfileDir & "\Downloads"
	Local Const $iFileExists = FileExists($userDownloadFolder)

	If $iFileExists Then
		$return += RemoveGlobFile($userDownloadFolder, "UsbFix*.exe", "^(?i)UsbFix.*\.exe$", $descriptionPattern)
	EndIf

	$return += RemoveSoftwareKey("UsbFix")
	$return += RemoveFolder(@HomeDrive & "\UsbFixQuarantine")

	If $return > 0 Then
		If Not $KPDebug Then logMessage(@CRLF & "- Search UsbFix Files -" & @CRLF)
		Local $errors = ""

		Local Const $existingFolders[3] = [ _
				@HomeDrive & "\Program Files (x86)" & "\UsbFix", _
				@HomeDrive & "\Program Files" & "\UsbFix", _
				@HomeDrive & "\UsbFixQuarantine"]

		For $i = 0 To UBound($existingFolders) - 1
			If FileExists($existingFolders[$i]) Then
				$errors += "  [X] " & $existingFolders[$i] & " still exists" & @CRLF
			EndIf
		Next

		If $errors <> "" Then
			logMessage($errors)
		Else
			logMessage("  [OK] UsbFix has been successfully removed")
		EndIf

	EndIf

	ProgressBarUpdate()

EndFunc   ;==>RemoveUSBFIX
