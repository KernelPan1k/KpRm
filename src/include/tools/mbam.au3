
Func RemoveMBAM()
	logMessage(@CRLF & "=> ************* Search MBAM files ************** <=" & @CRLF)

	If FileExists(@HomeDrive & "\Program Files(x86)" & "\Malwarebytes\Anti-Malware\unins000.exe") Then
		RunWait(@HomeDrive & "\Program Files(x86)" & "\Malwarebytes\Anti-Malware\unins000.exe /verysilent /suppressmsgboxes /norestart")

		If @error <> 0 Then
			logMessage("  [OK] Uninstall MBAM Successfully")
		Else
			logMessage("  [X] Uninstall MBAM failed")
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

	RemoveService("MBAMService")
	RemoveService("ESProtectionDriver")
	RemoveService("MBAMChameleon")
	RemoveService("MBAMFarflt")
	RemoveService("MBAMSwissArmy")
	RemoveService("MBAMProtection")
	RemoveService("MBAMWebProtection")
	Sleep(1000)

	RemoveFolder(@HomeDrive & "\Program Files(x86)" & "\Malwarebytes")
	RemoveFolder(@HomeDrive & "\Program Files" & "\Malwarebytes")

	RemoveFile(@WindowsDir & "\System32" & "\drivers\mbae.sys")
	RemoveFile(@WindowsDir & "\System32" & "\drivers\MbamChameleon.sys")
	RemoveFile(@WindowsDir & "\System32" & "\drivers\farflt.sys")
	RemoveFile(@WindowsDir & "\System32" & "\drivers\mbamswissarmy.sys")
	RemoveFile(@WindowsDir & "\System32" & "\drivers\mwac.sys")

	RemoveFile(@WindowsDir & "\SYSWOW64" & "\drivers\mbae.sys")
	RemoveFile(@WindowsDir & "\SYSWOW64" & "\drivers\MbamChameleon.sys")
	RemoveFile(@WindowsDir & "\SYSWOW64" & "\drivers\farflt.sys")
	RemoveFile(@WindowsDir & "\SYSWOW64" & "\drivers\mbamswissarmy.sys")
	RemoveFile(@WindowsDir & "\SYSWOW64" & "\drivers\mwac.sys")

	RemoveFile(@DesktopDir & "\Malwarebytes.lnk")
	RemoveFile(@DesktopCommonDir & "\Malwarebytes.lnk")

	RemoveFolder(@LocalAppDataDir & "\mbamtray")
	RemoveFolder(@LocalAppDataDir & "\mbam")

	RemoveFolder(@AppDataCommonDir & "\Malwarebytes")
	RemoveFolder(@AppDataCommonDir & "\Microsoft\Windows\Start Menu\Programs\Malwarebytes")

	RemoveSoftwareKey("Malwarebytes")
	RemoveContextMenu("MBAMShlExt")

	ProgressBarUpdate()
EndFunc   ;==>RemoveMBAM
