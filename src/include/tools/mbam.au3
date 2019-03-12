
Func RemoveMBAM()
	logMessage(@CRLF & "- Search MBAM Files -" & @CRLF)

	If FileExists(@HomeDrive & "\Program Files(x86)" & "\Malwarebytes\Anti-Malware\unins000.exe") Then
		RunWait(@HomeDrive & "\Program Files(x86)" & "\Malwarebytes\Anti-Malware\unins000.exe /verysilent /suppressmsgboxes /norestart")

		If @error <> 0 Then
			logMessage("  [OK] Uninstall MBAM Successfully")
		Else
			logMessage("  [X] Uninstall MBAM failure")
		EndIf
	EndIf

	If FileExists(@HomeDrive & "\Program Files" & "\Malwarebytes\Anti-Malware\unins000.exe") Then
		RunWait(@HomeDrive & "\Program Files" & "\Malwarebytes\Anti-Malware\unins000.exe /verysilent /suppressmsgboxes /norestart")

		If @error <> 0 Then
			logMessage("  [OK] Uninstall MBAM Successfully")
		Else
			logMessage("  [X] Uninstall MBAM failed")
		EndIf
	EndIf

	Local Const $descriptionPattern = "(?i)^Malwarebytes"

	RemoveService("MBAMService")
	RemoveService("ESProtectionDriver")
	RemoveService("MBAMChameleon")
	RemoveService("MBAMFarflt")
	RemoveService("MBAMSwissArmy")
	RemoveService("MBAMProtection")
	RemoveService("MBAMWebProtection")
	Sleep(1000)

	CloseProcessAndWait("mbam.exe")
	CloseProcessAndWait("MBAMService.exe")
	CloseProcessAndWait("mbamtray.exe")

	RemoveFolder(@HomeDrive & "\Program Files(x86)" & "\Malwarebytes")
	RemoveFolder(@HomeDrive & "\Program Files" & "\Malwarebytes")

	RemoveFile(@WindowsDir & "\System32" & "\drivers\mbae.sys", $descriptionPattern)
	RemoveFile(@WindowsDir & "\System32" & "\drivers\MbamChameleon.sys", $descriptionPattern)
	RemoveFile(@WindowsDir & "\System32" & "\drivers\farflt.sys", $descriptionPattern)
	RemoveFile(@WindowsDir & "\System32" & "\drivers\mbamswissarmy.sys", $descriptionPattern)
	RemoveFile(@WindowsDir & "\System32" & "\drivers\mwac.sys", $descriptionPattern)

	RemoveFile(@WindowsDir & "\SYSWOW64" & "\drivers\mbae.sys", $descriptionPattern)
	RemoveFile(@WindowsDir & "\SYSWOW64" & "\drivers\MbamChameleon.sys", $descriptionPattern)
	RemoveFile(@WindowsDir & "\SYSWOW64" & "\drivers\farflt.sys", $descriptionPattern)
	RemoveFile(@WindowsDir & "\SYSWOW64" & "\drivers\mbamswissarmy.sys", $descriptionPattern)
	RemoveFile(@WindowsDir & "\SYSWOW64" & "\drivers\mwac.sys", $descriptionPattern)

	RemoveFile(@DesktopDir & "\Malwarebytes.lnk")
	RemoveFile(@DesktopCommonDir & "\Malwarebytes.lnk")

	RemoveGlobFile(@DesktopDir, "mb3-setup-consumer-*.exe", "^mb3-setup-consumer-[0-9.-]+.exe$", $descriptionPattern)

	Local Const $userDownloadFolder = @UserProfileDir & "\Downloads"
	Local Const $iFileExists = FileExists($userDownloadFolder)

	If $iFileExists Then
		RemoveGlobFile(@UserProfileDir & "\Downloads", "mb3-setup-consumer-*.exe", "^mb3-setup-consumer-[0-9.-]+.exe$", $descriptionPattern)
	EndIf

	RemoveFolder(@LocalAppDataDir & "\mbamtray")
	RemoveFolder(@LocalAppDataDir & "\mbam")

	RemoveFolder(@AppDataCommonDir & "\Malwarebytes")
	RemoveFolder(@AppDataCommonDir & "\Microsoft\Windows\Start Menu\Programs\Malwarebytes")

	RemoveSoftwareKey("Malwarebytes")
	RemoveContextMenu("MBAMShlExt")

	ProgressBarUpdate()
EndFunc   ;==>RemoveMBAM
