
Func RemoveMBAM()
	Dim $KPDebug

	If $KPDebug Then logMessage(@CRLF & "- Search MBAM Files -" & @CRLF)

	Local $return = 0

	If FileExists(@HomeDrive & "\Program Files(x86)" & "\Malwarebytes\Anti-Malware\unins000.exe") Then
		$return = 1

		RunWait(@HomeDrive & "\Program Files(x86)" & "\Malwarebytes\Anti-Malware\unins000.exe /verysilent /suppressmsgboxes /norestart")
	EndIf

	If FileExists(@HomeDrive & "\Program Files" & "\Malwarebytes\Anti-Malware\unins000.exe") Then
		$return = 1

		RunWait(@HomeDrive & "\Program Files" & "\Malwarebytes\Anti-Malware\unins000.exe /verysilent /suppressmsgboxes /norestart")
	EndIf

	Local Const $descriptionPattern = "(?i)^Malwarebytes"

	$return += RemoveService("MBAMService")
	$return += RemoveService("ESProtectionDriver")
	$return += RemoveService("MBAMChameleon")
	$return += RemoveService("MBAMFarflt")
	$return += RemoveService("MBAMSwissArmy")
	$return += RemoveService("MBAMProtection")
	$return += RemoveService("MBAMWebProtection")

	$return += CloseProcessAndWait("mbam.exe")
	$return += CloseProcessAndWait("MBAMService.exe")
	$return += CloseProcessAndWait("mbamtray.exe")

	$return += RemoveFolder(@HomeDrive & "\Program Files(x86)" & "\Malwarebytes")
	$return += RemoveFolder(@HomeDrive & "\Program Files" & "\Malwarebytes")

	$return += RemoveFile(@WindowsDir & "\System32" & "\drivers\mbae.sys", $descriptionPattern)
	$return += RemoveFile(@WindowsDir & "\System32" & "\drivers\MbamChameleon.sys", $descriptionPattern)
	$return += RemoveFile(@WindowsDir & "\System32" & "\drivers\farflt.sys", $descriptionPattern)
	$return += RemoveFile(@WindowsDir & "\System32" & "\drivers\mbamswissarmy.sys", $descriptionPattern)
	$return += RemoveFile(@WindowsDir & "\System32" & "\drivers\mwac.sys", $descriptionPattern)

	$return += RemoveFile(@WindowsDir & "\SYSWOW64" & "\drivers\mbae.sys", $descriptionPattern)
	$return += RemoveFile(@WindowsDir & "\SYSWOW64" & "\drivers\MbamChameleon.sys", $descriptionPattern)
	$return += RemoveFile(@WindowsDir & "\SYSWOW64" & "\drivers\farflt.sys", $descriptionPattern)
	$return += RemoveFile(@WindowsDir & "\SYSWOW64" & "\drivers\mbamswissarmy.sys", $descriptionPattern)
	$return += RemoveFile(@WindowsDir & "\SYSWOW64" & "\drivers\mwac.sys", $descriptionPattern)

	$return += RemoveFile(@DesktopDir & "\Malwarebytes.lnk")
	$return += RemoveFile(@DesktopCommonDir & "\Malwarebytes.lnk")

	$return += RemoveGlobFile(@DesktopDir, "mb3-setup-consumer-*.exe", "^mb3-setup-consumer-[0-9.-]+.exe$", $descriptionPattern)

	Local Const $userDownloadFolder = @UserProfileDir & "\Downloads"
	Local Const $iFileExists = FileExists($userDownloadFolder)

	If $iFileExists Then
		$return += RemoveGlobFile(@UserProfileDir & "\Downloads", "mb3-setup-consumer-*.exe", "^mb3-setup-consumer-[0-9.-]+.exe$", $descriptionPattern)
	EndIf

	$return += RemoveFolder(@LocalAppDataDir & "\mbamtray")
	$return += RemoveFolder(@LocalAppDataDir & "\mbam")

	$return += RemoveFolder(@AppDataCommonDir & "\Malwarebytes")
	$return += RemoveFolder(@AppDataCommonDir & "\Microsoft\Windows\Start Menu\Programs\Malwarebytes")

	$return += RemoveSoftwareKey("Malwarebytes")
	$return += RemoveContextMenu("MBAMShlExt")

	If $return > 0 Then
		If Not $KPDebug Then logMessage(@CRLF & "- Search MBAM Files -" & @CRLF)
		Local $errors = ""

		If FileExists(@HomeDrive & "\Program Files(x86)" & "\Malwarebytes") Then
			$errors += " [X] The folder " & @HomeDrive & "\Program Files(x86)" & "\Malwarebytes still exists" & @CRLF
		EndIf

		If FileExists(@HomeDrive & "\Program Files" & "\Malwarebytes") Then
			$errors += " [X] The folder " & @HomeDrive & "\Program Files" & "\Malwarebytes still exists" & @CRLF
		EndIf

		If FileExists(@LocalAppDataDir & "\mbamtray") Then
			$errors += " [X] The folder " & @LocalAppDataDir & "\mbamtray still exists" & @CRLF
		EndIf

		If FileExists(@LocalAppDataDir & "\mbam") Then
			$errors += " [X] The folder " & @LocalAppDataDir & "\mbam still exists" & @CRLF
		EndIf

		If FileExists(@AppDataCommonDir & "\Malwarebytes") Then
			$errors += " [X] The folder " & @AppDataCommonDir & "\Malwarebytes still exists" & @CRLF
		EndIf

		If $errors <> "" Then
			logMessage($errors)
		Else
			logMessage("  [OK] MBAM has been successfully removed")
		EndIf

	EndIf

	ProgressBarUpdate()
EndFunc   ;==>RemoveMBAM
