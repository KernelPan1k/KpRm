Func RestoreUAC()
	LogMessage(@CRLF & "- Restore UAC -" & @CRLF)

	UpdateStatusBar("Restore UAC ...")

	Local $s64Bit = ""
	If @OSArch = "X64" Then $s64Bit = "64"

	If RegWrite("HKEY_LOCAL_MACHINE" & $s64Bit & "\Software\Microsoft\Windows\CurrentVersion\Policies\System", "EnableLUA", "REG_DWORD", 1) = 1 Then
		LogMessage("     [OK] Set EnableLUA with default (1) value")
	Else
		LogMessage("     [X] Set EnableLUA with default value")
	EndIf

	If RegWrite("HKEY_LOCAL_MACHINE" & $s64Bit & "\Software\Microsoft\Windows\CurrentVersion\Policies\System", "ConsentPromptBehaviorAdmin", "REG_DWORD", 5) = 1 Then
		LogMessage("     [OK] Set ConsentPromptBehaviorAdmin with default (5) value")
	Else
		LogMessage("     [X] Set ConsentPromptBehaviorAdmin with default value")
	EndIf

	If RegWrite("HKEY_LOCAL_MACHINE" & $s64Bit & "\Software\Microsoft\Windows\CurrentVersion\Policies\System", "ConsentPromptBehaviorUser", "REG_DWORD", 3) = 1 Then
		LogMessage("     [OK] Set ConsentPromptBehaviorUser with default (3) value")
	Else
		LogMessage("     [X] Set ConsentPromptBehaviorUser with default value")
	EndIf

	If RegWrite("HKEY_LOCAL_MACHINE" & $s64Bit & "\Software\Microsoft\Windows\CurrentVersion\Policies\System", "EnableInstallerDetection", "REG_DWORD", 0) = 1 Then
		LogMessage("     [OK] Set EnableInstallerDetection with default (0) value")
	Else
		LogMessage("     [X] Set EnableInstallerDetection with default value")
	EndIf

	If RegWrite("HKEY_LOCAL_MACHINE" & $s64Bit & "\Software\Microsoft\Windows\CurrentVersion\Policies\System", "EnableSecureUIAPaths", "REG_DWORD", 1) = 1 Then
		LogMessage("     [OK] Set EnableSecureUIAPaths with default (1) value")
	Else
		LogMessage("     [X] Set EnableSecureUIAPaths with default value")
	EndIf

	If RegWrite("HKEY_LOCAL_MACHINE" & $s64Bit & "\Software\Microsoft\Windows\CurrentVersion\Policies\System", "EnableUIADesktopToggle", "REG_DWORD", 0) = 1 Then
		LogMessage("     [OK] Set EnableUIADesktopToggle with default (0) value")
	Else
		LogMessage("     [X] Set EnableUIADesktopToggle with default value")
	EndIf

	If RegWrite("HKEY_LOCAL_MACHINE" & $s64Bit & "\Software\Microsoft\Windows\CurrentVersion\Policies\System", "EnableVirtualization", "REG_DWORD", 1) = 1 Then
		LogMessage("     [OK] Set EnableVirtualization with default (1) value")
	Else
		LogMessage("     [X] Set EnableVirtualization with default value")
	EndIf

	If RegWrite("HKEY_LOCAL_MACHINE" & $s64Bit & "\Software\Microsoft\Windows\CurrentVersion\Policies\System", "FilterAdministratorToken", "REG_DWORD", 0) = 1 Then
		LogMessage("     [OK] Set FilterAdministratorToken with default (0) value")
	Else
		LogMessage("     [X] Set FilterAdministratorToken with default value")
	EndIf

	If RegWrite("HKEY_LOCAL_MACHINE" & $s64Bit & "\Software\Microsoft\Windows\CurrentVersion\Policies\System", "PromptOnSecureDesktop", "REG_DWORD", 1) = 1 Then
		LogMessage("     [OK] Set PromptOnSecureDesktop with default (1) value")
	Else
		LogMessage("     [X] Set PromptOnSecureDesktop with default value")
	EndIf

	If RegWrite("HKEY_LOCAL_MACHINE" & $s64Bit & "\Software\Microsoft\Windows\CurrentVersion\Policies\System", "ValidateAdminCodeSignatures", "REG_DWORD", 0) = 1 Then
		LogMessage("     [OK] Set ValidateAdminCodeSignatures with default (0) value")
	Else
		LogMessage("     [X] Set ValidateAdminCodeSignatures with default value")
	EndIf
EndFunc   ;==>RestoreUAC
