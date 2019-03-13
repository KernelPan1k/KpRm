Dim $nbrTask

$nbrTask += 1

Func RemoveMBAM($retry = False)
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

	Local $s64Bit = ""
	If @OSArch = "X64" Then $s64Bit = "64"

	Local $installReg = searchRegistryKeyStrings("HKLM" & $s64Bit & "\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall", "(?i)^Malwarebytes", "DisplayName")

	If $installReg Then
		$return += RemoveRegistryKey($installReg)
	EndIf

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
		If Not $KPDebug And $retry = False Then
			logMessage(@CRLF & "- Search MBAM Files -" & @CRLF)
		EndIf

		Local $errors = ""

		If FileExists(@HomeDrive & "\Program Files(x86)" & "\Malwarebytes") Then
			$errors += " [X] The folder " & @HomeDrive & "\Program Files(x86)" & "\Malwarebytes still exists" & @CRLF
		EndIf

		If FileExists(@HomeDrive & "\Program Files" & "\Malwarebytes") Then
			$errors += " [X] The folder " & @HomeDrive & "\Program Files" & "\Malwarebytes still exists" & @CRLF
		EndIf

		Local $checkExists[13] = [ _
				@WindowsDir & "\System32" & "\drivers\mbae.sys", _
				@WindowsDir & "\System32" & "\drivers\MbamChameleon.sys", _
				@WindowsDir & "\System32" & "\drivers\farflt.sys", _
				@WindowsDir & "\System32" & "\drivers\mbamswissarmy.sys", _
				@WindowsDir & "\System32" & "\drivers\mwac.sys", _
				@WindowsDir & "\SYSWOW64" & "\drivers\mbae.sys", _
				@WindowsDir & "\SYSWOW64" & "\drivers\MbamChameleon.sys", _
				@WindowsDir & "\SYSWOW64" & "\drivers\farflt.sys", _
				@WindowsDir & "\SYSWOW64" & "\drivers\mbamswissarmy.sys", _
				@WindowsDir & "\SYSWOW64" & "\drivers\mwac.sys", _
				@LocalAppDataDir & "\mbamtray", _
				@LocalAppDataDir & "\mbam", _
				@AppDataCommonDir & "\Malwarebytes"]

		For $i = 0 To UBound($checkExists) - 1
			If FileExists($checkExists[$i]) Then
				$errors += " [X] " & $checkExists[$i] & " still exists" & @CRLF
			EndIf
		Next

		$installReg = searchRegistryKeyStrings("HKLM" & $s64Bit & "\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall", "(?i)^Malwarebytes", "DisplayName")

		If $installReg Then
			$errors += " [X] SOFTWARE KEY stell exists" & @CRLF
		EndIf

		If $errors <> "" Then
			If $retry = False Then
				RemoveMBAM(True)
			Else
				logMessage($errors)
			EndIf
		Else
			logMessage("  [OK] MBAM has been successfully removed")
		EndIf

	EndIf

	ProgressBarUpdate()
EndFunc   ;==>RemoveMBAM
