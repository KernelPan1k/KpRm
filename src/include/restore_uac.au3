
Func RestaureUACByDefault()
	logMessage(@CRLF & "- Restore UAC Default Value -" & @CRLF)

	Local $status = _UAC_SetConsentPromptBehaviorAdmin()

	If $status = 1 Then
		logMessage("  [OK] Set ConsentPromptBehaviorAdmin with default value successfully.")
	Else
		logMessage("  [X] Set ConsentPromptBehaviorAdmin with default value failed")
	EndIf

;~ #################

	Local $status = _UAC_SetConsentPromptBehaviorUser()

	If $status = 1 Then
		logMessage("  [OK] Set ConsentPromptBehaviorUser with default value successfully.")
	Else
		logMessage("  [X] Set ConsentPromptBehaviorUser with default value failed")
	EndIf

;~ #################

	Local $status = _UAC_SetEnableInstallerDetection()

	If $status = 1 Then
		logMessage("  [OK] Set EnableInstallerDetection with default value successfully.")
	Else
		logMessage("  [X] Set EnableInstallerDetection with default value failed")
	EndIf

;~ #################

	Local $status = _UAC_SetEnableLUA()

	If $status = 1 Then
		logMessage("  [OK] Set EnableLUA with default value successfully.")
	Else
		logMessage("  [X] Set EnableLUA with default value failed")
	EndIf

;~ #################

	Local $status = _UAC_SetEnableSecureUIAPaths()

	If $status = 1 Then
		logMessage("  [OK] Set EnableSecureUIAPaths with default value successfully.")
	Else
		logMessage("  [X] Set EnableSecureUIAPaths with default value failed")
	EndIf

;~ #################

	Local $status = _UAC_SetEnableUIADesktopToggle()

	If $status = 1 Then
		logMessage("  [OK] Set EnableUIADesktopToggle with default value successfully.")
	Else
		logMessage("  [X] Set EnableUIADesktopToggle with default value failed")
	EndIf

;~ #################

	Local $status = _UAC_SetEnableVirtualization()

	If $status = 1 Then
		logMessage("  [OK] Set EnableVirtualization with default value successfully.")
	Else
		logMessage("  [X] Set EnableVirtualization with default value failed")
	EndIf

;~ #################

	Local $status = _UAC_SetFilterAdministratorToken()

	If $status = 1 Then
		logMessage("  [OK] Set FilterAdministratorToken with default value successfully.")
	Else
		logMessage("  [X] Set FilterAdministratorToken with default value failed")
	EndIf

;~ #################

	Local $status = _UAC_SetPromptOnSecureDesktop()

	If $status = 1 Then
		logMessage("  [OK] Set PromptOnSecureDesktop with default value successfully.")
	Else
		logMessage("  [X] Set PromptOnSecureDesktop with default value failed")
	EndIf

;~ #################

	Local $status = _UAC_SetValidateAdminCodeSignatures()

	If $status = 1 Then
		logMessage("  [OK] Set ValidateAdminCodeSignatures with default value successfully.")
	Else
		logMessage("  [X] Set ValidateAdminCodeSignatures with default value failed")
	EndIf

EndFunc   ;==>RestaureUACByDefault
