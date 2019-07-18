
Func RestaureUACByDefault()
	LogMessage(@CRLF & "- Restore UAC Default Value -" & @CRLF)

	Local $iStatus = _UAC_SetConsentPromptBehaviorAdmin()

	If $iStatus = 1 Then
		LogMessage("  [OK] Set ConsentPromptBehaviorAdmin with default (5) value")
	Else
		LogMessage("  [X] Set ConsentPromptBehaviorAdmin with default value")
	EndIf

;~ #################

	Local $iStatus = _UAC_SetConsentPromptBehaviorUser(3)

	If $iStatus = 1 Then
		LogMessage("  [OK] Set ConsentPromptBehaviorUser with default (3) value")
	Else
		LogMessage("  [X] Set ConsentPromptBehaviorUser with default value")
	EndIf

;~ #################

	Local $iStatus = _UAC_SetEnableInstallerDetection()

	If $iStatus = 1 Then
		LogMessage("  [OK] Set EnableInstallerDetection with default (0) value")
	Else
		LogMessage("  [X] Set EnableInstallerDetection with default value")
	EndIf

;~ #################

	Local $iStatus = _UAC_SetEnableLUA()

	If $iStatus = 1 Then
		LogMessage("  [OK] Set EnableLUA with default (1) value")
	Else
		LogMessage("  [X] Set EnableLUA with default value")
	EndIf

;~ #################

	Local $iStatus = _UAC_SetEnableSecureUIAPaths()

	If $iStatus = 1 Then
		LogMessage("  [OK] Set EnableSecureUIAPaths with default (1) value")
	Else
		LogMessage("  [X] Set EnableSecureUIAPaths with default value")
	EndIf

;~ #################

	Local $iStatus = _UAC_SetEnableUIADesktopToggle()

	If $iStatus = 1 Then
		LogMessage("  [OK] Set EnableUIADesktopToggle with default (0) value")
	Else
		LogMessage("  [X] Set EnableUIADesktopToggle with default value")
	EndIf

;~ #################

	Local $iStatus = _UAC_SetEnableVirtualization()

	If $iStatus = 1 Then
		LogMessage("  [OK] Set EnableVirtualization with default (1) value")
	Else
		LogMessage("  [X] Set EnableVirtualization with default value")
	EndIf

;~ #################

	Local $iStatus = _UAC_SetFilterAdministratorToken()

	If $iStatus = 1 Then
		LogMessage("  [OK] Set FilterAdministratorToken with default (0) value")
	Else
		LogMessage("  [X] Set FilterAdministratorToken with default value")
	EndIf

;~ #################

	Local $iStatus = _UAC_SetPromptOnSecureDesktop()

	If $iStatus = 1 Then
		LogMessage("  [OK] Set PromptOnSecureDesktop with default (1) value")
	Else
		LogMessage("  [X] Set PromptOnSecureDesktop with default value")
	EndIf

;~ #################

	Local $iStatus = _UAC_SetValidateAdminCodeSignatures()

	If $iStatus = 1 Then
		LogMessage("  [OK] Set ValidateAdminCodeSignatures with default (0) value")
	Else
		LogMessage("  [X] Set ValidateAdminCodeSignatures with default value")
	EndIf

EndFunc   ;==>RestaureUACByDefault
