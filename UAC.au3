#include-once
;~ #AutoIt3Wrapper_AU3Check_Parameters= -d -w 1 -w 2 -w 3 -w 4 -w 5 -w 6
;~ #AutoIt3Wrapper_AU3Check_Stop_OnWarning=Y
;~ #Tidy_Parameters=/sf
; #INDEX# =======================================================================================================================
; Title .........: User Account Control (UAC) UDF for Windows Vista and higher.
; AutoIt Version : 3.3.6++
; UDF Version ...: 1.0
; Language ......: English
; Description ...: Get or Set UAC registry settings in Windows Vista or higher.
; Dll ...........:
; Author(s) .....: Adam Lawrence (AdamUL)
; Email .........:
; Modified ......:
; Contributors ..:
; Resources .....: http://technet.microsoft.com/en-us/library/dd835564(v=ws.10).aspx#BKMK_RegistryKeys
;                  http://www.autoitscript.com/forum/topic/122050-useful-snippets-collection-thread/page__p__847186#entry847186 (Post #1, item 8.)
; Remarks .......: #RequireAdmin and/or #AutoIt3Wrapper_Res_requestedExecutionLevel=requireAdministrator is needed for "Set" functions to work in this UDF.
; ===============================================================================================================================

; #CURRENT# =====================================================================================================================
;_UAC_GetConsentPromptBehaviorAdmin
;_UAC_GetConsentPromptBehaviorUser
;_UAC_GetEnableInstallerDetection
;_UAC_GetEnableLUA
;_UAC_GetEnableSecureUIAPaths
;_UAC_GetEnableUIADesktopToggle
;_UAC_GetEnableVirtualization
;_UAC_GetFilterAdministratorToken
;_UAC_GetPromptOnSecureDesktop
;_UAC_GetValidateAdminCodeSignatures
;_UAC_SetConsentPromptBehaviorAdmin
;_UAC_SetConsentPromptBehaviorUser
;_UAC_SetEnableInstallerDetection
;_UAC_SetEnableLUA
;_UAC_SetEnableSecureUIAPaths
;_UAC_SetEnableUIADesktopToggle
;_UAC_SetEnableVirtualization
;_UAC_SetFilterAdministratorToken
;_UAC_SetPromptOnSecureDesktop
;_UAC_SetValidateAdminCodeSignatures
; ===============================================================================================================================

; #CONSTANTS# ===================================================================================================================
Global Const $UAC_ELEVATE_WITHOUT_PROMPTING = 0
Global Const $UAC_PROMPT_FOR_CREDENTIALS_SECURE_DESKTOP = 1
Global Const $UAC_PROMPT_FOR_CONSENT_SECURE_DESKTOP = 2
Global Const $UAC_PROMPT_FOR_CREDENTIALS = 3
Global Const $UAC_PROMPT_FOR_CONSENT = 4
Global Const $UAC_PROMPT_FOR_CONSENT_NONWINDOWS_BINARIES = 5
Global Const $UAC_AUTOMATICALLY_DENY_ELEVATION_REQUESTS = 0
Global Const $UAC_DISABLED = 0
Global Const $UAC_ENABLED = 1
; ===============================================================================================================================

; #FUNCTION# ====================================================================================================================
; Name ..........: _UAC_GetConsentPromptBehaviorAdmin
; Description ...: Gets UAC Registry Key for ConsentPromptBehaviorAdmin.  Behavior of the elevation prompt for administrators in Admin Approval Mode.
; Syntax ........: _UAC_GetConsentPromptBehaviorAdmin()
; Parameters ....: None.
; Return values .: Success - Registry Value
;                  |$UAC_ELEVATE_WITHOUT_PROMPTING (0) - Elevate without prompting (Use this option only in the most constrained environments).
;                  |$UAC_PROMPT_FOR_CREDENTIALS_SECURE_DESKTOP (1) - Prompt for credentials on the secure desktop.
;                  |$UAC_PROMPT_FOR_CONSENT_SECURE_DESKTOP (2) - Prompt for consent on the secure desktop.
;                  |$UAC_PROMPT_FOR_CREDENTIALS (3) - Prompt for credentials.
;                  |$UAC_PROMPT_FOR_CONSENT (4) - Prompt for consent.
;                  |$UAC_PROMPT_FOR_CONSENT_NONWINDOWS_BINARIES (5) - Prompt for consent for non-Windows binaries (default).
;                  Failure - -1, sets @error to:
;                  |1 - if unable to open requested key
;                  |2 - if unable to open requested main key
;                  |3 - if unable to remote connect to the registry
;                  |-1 - if unable to open requested value
;                  |-2 - if value type not supported
;                  |-3 - Invalid key on OS.
; Author ........: Adam Lawrence (AdamUL)
; Modified ......: TheXman
; Remarks .......: Admin rights not required to read the value.
; Related .......:
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func _UAC_GetConsentPromptBehaviorAdmin()
	If StringRegExp(@OSVersion, "_(XP|200(0|3))") Then Return SetError(-3, 0, -1)
	Local $s64Bit = ""
	If @OSArch = "X64" Then $s64Bit = "64"
	Local $iReturn = RegRead("HKEY_LOCAL_MACHINE" & $s64Bit & "\Software\Microsoft\Windows\CurrentVersion\Policies\System", "ConsentPromptBehaviorAdmin")
	If $iReturn == "" Then $iReturn = -1
	Return SetError(@error, 0, $iReturn)
EndFunc   ;==>_UAC_GetConsentPromptBehaviorAdmin

; #FUNCTION# ====================================================================================================================
; Name ..........: _UAC_GetConsentPromptBehaviorUser
; Description ...: Gets UAC Registry Key for ConsentPromptBehaviorUser.  Behavior of the elevation prompt for standard users.
; Syntax ........: _UAC_GetConsentPromptBehaviorUser()
; Parameters ....: None.
; Return values .: Success - Registry Value
;                  |$UAC_AUTOMATICALLY_DENY_ELEVATION_REQUESTS (0) - Automatically deny elevation requests.
;                  |$UAC_PROMPT_FOR_CREDENTIALS_SECURE_DESKTOP (1) - Prompt for credentials on the secure desktop (default).
;                  |$UAC_PROMPT_FOR_CREDENTIALS (3) - Prompt for credentials.
;                  Failure - -1, sets @error to:
;                  |1 - if unable to open requested key
;                  |2 - if unable to open requested main key
;                  |3 - if unable to remote connect to the registry
;                  |-1 - if unable to open requested value
;                  |-2 - if value type not supported
;                  |-3 - Invalid key on OS.
; Author ........: Adam Lawrence (AdamUL)
; Modified ......: TheXman
; Remarks .......: Admin rights not required to read the value.
; Related .......:
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func _UAC_GetConsentPromptBehaviorUser()
	If StringRegExp(@OSVersion, "_(XP|200(0|3))") Then Return SetError(-3, 0, -1)
	Local $s64Bit = ""
	If @OSArch = "X64" Then $s64Bit = "64"
	Local $iReturn = RegRead("HKEY_LOCAL_MACHINE" & $s64Bit & "\Software\Microsoft\Windows\CurrentVersion\Policies\System", "ConsentPromptBehaviorUser")
	If $iReturn == "" Then $iReturn = -1
	Return SetError(@error, 0, $iReturn)
EndFunc   ;==>_UAC_GetConsentPromptBehaviorUser

; #FUNCTION# ====================================================================================================================
; Name ..........: _UAC_GetEnableInstallerDetection
; Description ...: Gets UAC Registry Key for EnableInstallerDetection.  Detect application installations and prompt for elevation.
; Syntax ........: _UAC_GetEnableInstallerDetection()
; Parameters ....: None.
; Return values .: Success - Registry Value
;                  |$UAC_DISABLED (0) - Disabled (default for enterprise).
;                  |$UAC_ENABLED (1) - Enabled (default for home).
;                  Failure - -1, sets @error to:
;                  |1 - if unable to open requested key
;                  |2 - if unable to open requested main key
;                  |3 - if unable to remote connect to the registry
;                  |-1 - if unable to open requested value
;                  |-2 - if value type not supported
;                  |-3 - Invalid key on OS.
; Author ........: Adam Lawrence (AdamUL)
; Modified ......: TheXman
; Remarks .......: Admin rights not required to read the value.
; Related .......:
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func _UAC_GetEnableInstallerDetection()
	If StringRegExp(@OSVersion, "_(XP|200(0|3))") Then Return SetError(-3, 0, -1)
	Local $s64Bit = ""
	If @OSArch = "X64" Then $s64Bit = "64"
	Local $iReturn = RegRead("HKEY_LOCAL_MACHINE" & $s64Bit & "\Software\Microsoft\Windows\CurrentVersion\Policies\System", "EnableInstallerDetection")
	If $iReturn == "" Then $iReturn = -1
	Return SetError(@error, 0, $iReturn)
EndFunc   ;==>_UAC_GetEnableInstallerDetection

; #FUNCTION# ====================================================================================================================
; Name ..........: _UAC_GetEnableLUA
; Description ...: Gets UAC Registry Key for EnableLUA. Run all administrators in Admin Approval Mode.
; Syntax ........: _UAC_GetEnableLUA()
; Parameters ....: None.
; Return values .: Success - Registry Value
;                  |$UAC_DISABLED (0) - UAC (formally known as LUA) is disabled.
;                  |$UAC_ENABLED (1) - UAC (formally known as LUA) is enabled.
;                  Failure - -1, sets @error to:
;                  |1 - if unable to open requested key
;                  |2 - if unable to open requested main key
;                  |3 - if unable to remote connect to the registry
;                  |-1 - if unable to open requested value
;                  |-2 - if value type not supported
;                  |-3 - Invalid key on OS.
; Author ........: Adam Lawrence (AdamUL)
; Modified ......: TheXman
; Remarks .......: Admin rights not required to read the value.
; Related .......:
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func _UAC_GetEnableLUA()
	If StringRegExp(@OSVersion, "_(XP|200(0|3))") Then Return SetError(-3, 0, -1)
	Local $s64Bit = ""
	If @OSArch = "X64" Then $s64Bit = "64"
	Local $iReturn = RegRead("HKEY_LOCAL_MACHINE" & $s64Bit & "\Software\Microsoft\Windows\CurrentVersion\Policies\System", "EnableLUA")
	If $iReturn == "" Then $iReturn = -1
	Return SetError(@error, 0, $iReturn)
EndFunc   ;==>_UAC_GetEnableLUA

; #FUNCTION# ====================================================================================================================
; Name ..........: _UAC_GetEnableSecureUIAPaths
; Description ...: Gets UAC Registry Key for EnableSecureUIAPaths.  Only elevate UIAccess applications that are installed in secure locations.
; Syntax ........: _UAC_GetEnableSecureUIAPaths()
; Parameters ....: None.
; Return values .: Success - Registry Value
;                  |$UAC_DISABLED (0) - Disabled.
;                  |$UAC_ENABLED (1) - Enabled.
;                  Failure - -1, sets @error to:
;                  |1 - if unable to open requested key
;                  |2 - if unable to open requested main key
;                  |3 - if unable to remote connect to the registry
;                  |-1 - if unable to open requested value
;                  |-2 - if value type not supported
;                  |-3 - Invalid key on OS.
; Author ........: Adam Lawrence (AdamUL)
; Modified ......: TheXman
; Remarks .......: Admin rights not required to read the value.
; Related .......:
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func _UAC_GetEnableSecureUIAPaths()
	If StringRegExp(@OSVersion, "_(XP|200(0|3))") Then Return SetError(-3, 0, -1)
	Local $s64Bit = ""
	If @OSArch = "X64" Then $s64Bit = "64"
	Local $iReturn = RegRead("HKEY_LOCAL_MACHINE" & $s64Bit & "\Software\Microsoft\Windows\CurrentVersion\Policies\System", "EnableSecureUIAPaths")
	If $iReturn == "" Then $iReturn = -1
	Return SetError(@error, 0, $iReturn)
EndFunc   ;==>_UAC_GetEnableSecureUIAPaths

; #FUNCTION# ====================================================================================================================
; Name ..........: _UAC_GetEnableUIADesktopToggle
; Description ...: Gets UAC Registry Key for EnableUIADesktopToggle.  Allow UIAccess applications to prompt for elevation without using the secure desktop.
; Syntax ........: _UAC_GetEnableUIADesktopToggle()
; Parameters ....: None.
; Return values .: Success - Registry Value
;                  |$UAC_DISABLED (0) - Disabled.
;                  |$UAC_ENABLED (1) - Enabled.
;                  Failure - -1, sets @error to:
;                  |1 - if unable to open requested key
;                  |2 - if unable to open requested main key
;                  |3 - if unable to remote connect to the registry
;                  |-1 - if unable to open requested value
;                  |-2 - if value type not supported
;                  |-3 - Invalid key on OS.
; Author ........: Adam Lawrence (AdamUL)
; Modified ......: TheXman
; Remarks .......: Admin rights not required to read the value.
; Related .......:
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func _UAC_GetEnableUIADesktopToggle()
	If StringRegExp(@OSVersion, "_(XP|200(0|3))") Then Return SetError(-3, 0, -1)
	Local $s64Bit = ""
	If @OSArch = "X64" Then $s64Bit = "64"
	Local $iReturn = RegRead("HKEY_LOCAL_MACHINE" & $s64Bit & "\Software\Microsoft\Windows\CurrentVersion\Policies\System", "EnableUIADesktopToggle")
	If $iReturn == "" Then $iReturn = -1
	Return SetError(@error, 0, $iReturn)
EndFunc   ;==>_UAC_GetEnableUIADesktopToggle

; #FUNCTION# ====================================================================================================================
; Name ..........: _UAC_GetEnableVirtualization
; Description ...: Gets UAC Registry Key for EnableVirtualization.  Virtualize file and registry write failures to per-user locations.
; Syntax ........: _UAC_GetEnableVirtualization()
; Parameters ....: None.
; Return values .: Success - Registry Value
;                  |$UAC_DISABLED (0) - Disabled.
;                  |$UAC_ENABLED (1) - Enabled.
;                  Failure - -1, sets @error to:
;                  |1 - if unable to open requested key
;                  |2 - if unable to open requested main key
;                  |3 - if unable to remote connect to the registry
;                  |-1 - if unable to open requested value
;                  |-2 - if value type not supported
;                  |-3 - Invalid key on OS.
; Author ........: Adam Lawrence (AdamUL)
; Modified ......: TheXman
; Remarks .......: Admin rights not required to read the value.
; Related .......:
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func _UAC_GetEnableVirtualization()
	If StringRegExp(@OSVersion, "_(XP|200(0|3))") Then Return SetError(-3, 0, -1)
	Local $s64Bit = ""
	If @OSArch = "X64" Then $s64Bit = "64"
	Local $iReturn = RegRead("HKEY_LOCAL_MACHINE" & $s64Bit & "\Software\Microsoft\Windows\CurrentVersion\Policies\System", "EnableVirtualization")
	If $iReturn == "" Then $iReturn = -1
	Return SetError(@error, 0, $iReturn)
EndFunc   ;==>_UAC_GetEnableVirtualization

; #FUNCTION# ====================================================================================================================
; Name ..........: _UAC_GetFilterAdministratorToken
; Description ...: Gets UAC Registry Key for FilterAdministratorToken.  Admin Approval Mode for the Built-in Administrator account.
; Syntax ........: _UAC_GetFilterAdministratorToken()
; Parameters ....: None.
; Return values .: Success - Registry Value
;                  |$UAC_DISABLED (0) - Disabled.
;                  |$UAC_ENABLED (1) - Enabled.
;                  Failure - -1, sets @error to:
;                  |1 - if unable to open requested key
;                  |2 - if unable to open requested main key
;                  |3 - if unable to remote connect to the registry
;                  |-1 - if unable to open requested value
;                  |-2 - if value type not supported
;                  |-3 - Invalid key on OS.
; Author ........: Adam Lawrence (AdamUL)
; Modified ......: TheXman
; Remarks .......: Admin rights not required to read the value.
; Related .......:
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func _UAC_GetFilterAdministratorToken()
	If StringRegExp(@OSVersion, "_(XP|200(0|3))") Then Return SetError(-3, 0, -1)
	Local $s64Bit = ""
	If @OSArch = "X64" Then $s64Bit = "64"
	Local $iReturn = RegRead("HKEY_LOCAL_MACHINE" & $s64Bit & "\Software\Microsoft\Windows\CurrentVersion\Policies\System", "FilterAdministratorToken")
	If $iReturn == "" Then $iReturn = -1
	Return SetError(@error, 0, $iReturn)
EndFunc   ;==>_UAC_GetFilterAdministratorToken

; #FUNCTION# ====================================================================================================================
; Name ..........: _UAC_GetPromptOnSecureDesktop
; Description ...: Gets UAC Registry Key for PromptOnSecureDesktop. Switch to the secure desktop when prompting for elevation.
; Syntax ........: _UAC_GetPromptOnSecureDesktop()
; Parameters ....: None.
; Return values .: Success - Registry Value
;                  |$UAC_DISABLED (0) - Disabled.
;                  |$UAC_ENABLED (1) - Enabled.
;                  Failure - -1, sets @error to:
;                  |1 - if unable to open requested key
;                  |2 - if unable to open requested main key
;                  |3 - if unable to remote connect to the registry
;                  |-1 - if unable to open requested value
;                  |-2 - if value type not supported
;                  |-3 - Invalid key on OS.
; Author ........: Adam Lawrence (AdamUL)
; Modified ......: TheXman
; Remarks .......: Admin rights not required to read the value.
; Related .......:
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func _UAC_GetPromptOnSecureDesktop()
	If StringRegExp(@OSVersion, "_(XP|200(0|3))") Then Return SetError(-3, 0, -1)
	Local $s64Bit = ""
	If @OSArch = "X64" Then $s64Bit = "64"
	Local $iReturn = RegRead("HKEY_LOCAL_MACHINE" & $s64Bit & "\Software\Microsoft\Windows\CurrentVersion\Policies\System", "PromptOnSecureDesktop")
	If $iReturn == "" Then $iReturn = -1
	Return SetError(@error, 0, $iReturn)
EndFunc   ;==>_UAC_GetPromptOnSecureDesktop

; #FUNCTION# ====================================================================================================================
; Name ..........: _UAC_GetValidateAdminCodeSignatures
; Description ...: Gets UAC Registry Key for ValidateAdminCodeSignatures.  Only elevate executables that are signed and validated.
; Syntax ........: _UAC_GetValidateAdminCodeSignatures()
; Parameters ....: None.
; Return values .: Success - Registry Value
;                  |$UAC_DISABLED (0) - Disabled.
;                  |$UAC_ENABLED (1) - Enabled.
;                  Failure - -1, sets @error to:
;                  |1 - if unable to open requested key
;                  |2 - if unable to open requested main key
;                  |3 - if unable to remote connect to the registry
;                  |-1 - if unable to open requested value
;                  |-2 - if value type not supported
;                  |-3 - Invalid key on OS.
; Author ........: Adam Lawrence (AdamUL)
; Modified ......: TheXman
; Remarks .......: Admin rights not required to read the value.
; Related .......:
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func _UAC_GetValidateAdminCodeSignatures()
	If StringRegExp(@OSVersion, "_(XP|200(0|3))") Then Return SetError(-3, 0, -1)
	Local $s64Bit = ""
	If @OSArch = "X64" Then $s64Bit = "64"
	Local $iReturn = RegRead("HKEY_LOCAL_MACHINE" & $s64Bit & "\Software\Microsoft\Windows\CurrentVersion\Policies\System", "ValidateAdminCodeSignatures")
	If $iReturn == "" Then $iReturn = -1
	Return SetError(@error, 0, $iReturn)
EndFunc   ;==>_UAC_GetValidateAdminCodeSignatures

; #FUNCTION# ====================================================================================================================
; Name ..........: _UAC_SetConsentPromptBehaviorAdmin
; Description ...: Sets UAC Registry Key for ConsentPromptBehaviorAdmin.  Behavior of the elevation prompt for administrators in Admin Approval Mode.
; Syntax ........: _UAC_SetConsentPromptBehaviorAdmin([$iValue = $UAC_PROMPT_FOR_CONSENT_NONWINDOWS_BINARIES (5)])
; Parameters ....: $iValue - [optional] An integer value 0 to 5. Default is 5.
;                  |$UAC_ELEVATE_WITHOUT_PROMPTING(0) - Elevate without prompting (Use this option only in the most constrained environments).
;                  |$UAC_PROMPT_FOR_CREDENTIALS_SECURE_DESKTOP (1) - Prompt for credentials on the secure desktop.
;                  |$UAC_PROMPT_FOR_CONSENT_SECURE_DESKTOP (2) - Prompt for consent on the secure desktop.
;                  |$UAC_PROMPT_FOR_CREDENTIALS (3) - Prompt for credentials.
;                  |$UAC_PROMPT_FOR_CONSENT (4) - Prompt for consent.
;                  |$UAC_PROMPT_FOR_CONSENT_NONWINDOWS_BINARIES (5) - Prompt for consent for non-Windows binaries (default).
; Return values .: Success - 1
;                  Failure - -1, sets @error to:
;                  |1 - if unable to open requested key
;                  |2 - if unable to open requested main key
;                  |3 - if unable to remote connect to the registry
;                  |-1 - if unable to open requested value
;                  |-2 - if value type not supported
;                  |-3 - Current user is not Admin.
;                  |-4 - Invalid key on OS.
;                  |-5 - An invaild value.
; Author ........: Adam Lawrence (AdamUL)
; Modified ......:
; Remarks .......: Admin rights required to set the value.
; Related .......:
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func _UAC_SetConsentPromptBehaviorAdmin($iValue = $UAC_PROMPT_FOR_CONSENT_NONWINDOWS_BINARIES)
	If Not IsAdmin() Then Return SetError(-3, 0, -1)
	If StringRegExp(@OSVersion, "_(XP|200(0|3))") Then Return SetError(-4, 0, -1)
	Local $s64Bit = ""
	If @OSArch = "X64" Then $s64Bit = "64"
	If $iValue < 0 Or $iValue > 5 Then Return SetError(-5, 0, -1)
	Local $iReturn = RegWrite("HKEY_LOCAL_MACHINE" & $s64Bit & "\Software\Microsoft\Windows\CurrentVersion\Policies\System", "ConsentPromptBehaviorAdmin", "REG_DWORD", $iValue)
	If $iReturn = 0 Then $iReturn = -1
	Return SetError(@error, 0, $iReturn)
EndFunc   ;==>_UAC_SetConsentPromptBehaviorAdmin

; #FUNCTION# ====================================================================================================================
; Name ..........: _UAC_SetConsentPromptBehaviorUser
; Description ...: Sets UAC Registry Key for ConsentPromptBehaviorUser.  Behavior of the elevation prompt for standard users.
; Syntax ........: _UAC_SetConsentPromptBehaviorUser([$iValue = $UAC_PROMPT_FOR_CREDENTIALS_SECURE_DESKTOP (1)])
; Parameters ....: $iValue - [optional] An integer value. Default is 1.
;                  |$UAC_AUTOMATICALLY_DENY_ELEVATION_REQUESTS (0) - Automatically deny elevation requests.
;                  |$UAC_PROMPT_FOR_CREDENTIALS_SECURE_DESKTOP (1) - Prompt for credentials on the secure desktop (default).
;                  |$UAC_PROMPT_FOR_CREDENTIALS (3) - Prompt for credentials.
; Return values .: Success - 1
;                  Failure - -1, sets @error to:
;                  |1 - if unable to open requested key
;                  |2 - if unable to open requested main key
;                  |3 - if unable to remote connect to the registry
;                  |-1 - if unable to open requested value
;                  |-2 - if value type not supported
;                  |-3 - Current user is not Admin.
;                  |-4 - Invalid key on OS.
;                  |-5 - An invaild value.
; Author ........: Adam Lawrence (AdamUL)
; Modified ......:
; Remarks .......: Admin rights required to set the value.
; Related .......:
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func _UAC_SetConsentPromptBehaviorUser($iValue = $UAC_PROMPT_FOR_CREDENTIALS_SECURE_DESKTOP)
	If Not IsAdmin() Then Return SetError(-3, 0, -1)
	If StringRegExp(@OSVersion, "_(XP|200(0|3))") Then Return SetError(-4, 0, -1)
	If $iValue < 0 Or $iValue = 2 Or $iValue > 3 Then Return SetError(-5, 0, -1)
	Local $s64Bit = ""
	If @OSArch = "X64" Then $s64Bit = "64"
	Local $iReturn = RegWrite("HKEY_LOCAL_MACHINE" & $s64Bit & "\Software\Microsoft\Windows\CurrentVersion\Policies\System", "ConsentPromptBehaviorUser", "REG_DWORD", $iValue)
	If $iReturn = 0 Then $iReturn = -1
	Return SetError(@error, 0, $iReturn)
EndFunc   ;==>_UAC_SetConsentPromptBehaviorUser

; #FUNCTION# ====================================================================================================================
; Name ..........: _UAC_SetEnableInstallerDetection
; Description ...: Sets UAC Registry Key for EnableInstallerDetection.  Detect application installations and prompt for elevation.
; Syntax ........: _UAC_SetEnableInstallerDetection([$iValue = $UAC_DISABLED (0)])
; Parameters ....: $iValue - [optional] An integer value. Default is 0.
;                  |$UAC_DISABLED (0) - Disabled (default for enterprise).
;                  |$UAC_ENABLED (1) - Enabled (default for home).
; Return values .: Success - 1
;                  Failure - -1, sets @error to:
;                  |1 - if unable to open requested key
;                  |2 - if unable to open requested main key
;                  |3 - if unable to remote connect to the registry
;                  |-1 - if unable to open requested value
;                  |-2 - if value type not supported
;                  |-3 - Current user is not Admin.
;                  |-4 - Invalid key on OS.
;                  |-5 - An invaild value.
; Author ........: Adam Lawrence (AdamUL)
; Modified ......:
; Remarks .......: Admin rights required to set the value.
; Related .......:
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func _UAC_SetEnableInstallerDetection($iValue = $UAC_DISABLED)
	If Not IsAdmin() Then Return SetError(-3, 0, -1)
	If StringRegExp(@OSVersion, "_(XP|200(0|3))") Then Return SetError(-4, 0, -1)
	If $iValue < 0 Or $iValue > 1 Then Return SetError(-5, 0, -1)
	Local $s64Bit = ""
	If @OSArch = "X64" Then $s64Bit = "64"
	Local $iReturn = RegWrite("HKEY_LOCAL_MACHINE" & $s64Bit & "\Software\Microsoft\Windows\CurrentVersion\Policies\System", "EnableInstallerDetection", "REG_DWORD", $iValue)
	If $iReturn = 0 Then $iReturn = -1
	Return SetError(@error, 0, $iReturn)
EndFunc   ;==>_UAC_SetEnableInstallerDetection

; #FUNCTION# ====================================================================================================================
; Name ..........: _UAC_SetEnableLUA
; Description ...: Sets UAC Registry Key for EnableLUA. Run all administrators in Admin Approval Mode.
; Syntax ........: _UAC_SetEnableLUA([$iValue = $UAC_ENABLED (1)])
; Parameters ....: $iValue - [optional] An integer value. Default is 1.
;                  |$UAC_DISABLED (0) - UAC (formally known as LUA) is disabled.
;                  |$UAC_ENABLED (1) - UAC (formally known as LUA) is enabled.
; Return values .: Success - 1
;                  Failure - -1, sets @error to:
;                  |1 - if unable to open requested key
;                  |2 - if unable to open requested main key
;                  |3 - if unable to remote connect to the registry
;                  |-1 - if unable to open requested value
;                  |-2 - if value type not supported
;                  |-3 - Current user is not Admin.
;                  |-4 - Invalid key on OS.
;                  |-5 - An invaild value.
; Author ........: Adam Lawrence (AdamUL)
; Modified ......:
; Remarks .......: Admin rights required to set the value.
; Related .......:
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func _UAC_SetEnableLUA($iValue = $UAC_ENABLED)
	If Not IsAdmin() Then Return SetError(-3, 0, -1)
	If StringRegExp(@OSVersion, "_(XP|200(0|3))") Then Return SetError(-4, 0, -1)
	If $iValue < 0 Or $iValue > 1 Then Return SetError(-5, 0, -1)
	Local $s64Bit = ""
	If @OSArch = "X64" Then $s64Bit = "64"
	Local $iReturn = RegWrite("HKEY_LOCAL_MACHINE" & $s64Bit & "\Software\Microsoft\Windows\CurrentVersion\Policies\System", "EnableLUA", "REG_DWORD", $iValue)
	If $iReturn = 0 Then $iReturn = -1
	Return SetError(@error, 0, $iReturn)
EndFunc   ;==>_UAC_SetEnableLUA

; #FUNCTION# ====================================================================================================================
; Name ..........: _UAC_SetEnableSecureUIAPaths
; Description ...: Sets UAC Registry Key for EnableSecureUIAPaths.  Only elevate UIAccess applications that are installed in secure locations.
; Syntax ........: _UAC_SetEnableSecureUIAPaths([$iValue = $UAC_ENABLED (1)])
; Parameters ....: $iValue - [optional] An integer value. Default is 1.
;                  |$UAC_DISABLED (0) - Disabled.
;                  |$UAC_ENABLED (1) - Enabled.
; Return values .: Success - 1
;                  Failure - -1, sets @error to:
;                  |1 - if unable to open requested key
;                  |2 - if unable to open requested main key
;                  |3 - if unable to remote connect to the registry
;                  |-1 - if unable to open requested value
;                  |-2 - if value type not supported
;                  |-3 - Current user is not Admin.
;                  |-4 - Invalid key on OS.
;                  |-5 - An invaild value.
; Author ........: Adam Lawrence (AdamUL)
; Modified ......:
; Remarks .......: Admin rights required to set the value.
; Related .......:
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func _UAC_SetEnableSecureUIAPaths($iValue = $UAC_ENABLED)
	If Not IsAdmin() Then Return SetError(-3, 0, -1)
	If StringRegExp(@OSVersion, "_(XP|200(0|3))") Then Return SetError(-4, 0, -1)
	If $iValue < 0 Or $iValue > 1 Then Return SetError(-5, 0, -1)
	Local $s64Bit = ""
	If @OSArch = "X64" Then $s64Bit = "64"
	Local $iReturn = RegWrite("HKEY_LOCAL_MACHINE" & $s64Bit & "\Software\Microsoft\Windows\CurrentVersion\Policies\System", "EnableSecureUIAPaths", "REG_DWORD", $iValue)
	If $iReturn = 0 Then $iReturn = -1
	Return SetError(@error, 0, $iReturn)
EndFunc   ;==>_UAC_SetEnableSecureUIAPaths

; #FUNCTION# ====================================================================================================================
; Name ..........: _UAC_SetEnableUIADesktopToggle
; Description ...: Sets UAC Registry Key for EnableUIADesktopToggle.  Allow UIAccess applications to prompt for elevation without using the secure desktop.
; Syntax ........: _UAC_SetEnableUIADesktopToggle([$iValue = $UAC_DISABLED (0)])
; Parameters ....: $iValue - [optional] An integer value. Default is 1.
;                  |$UAC_DISABLED (0) - Disabled.
;                  |$UAC_ENABLED (1) - Enabled.
; Return values .: Success - 1
;                  Failure - -1, sets @error to:
;                  |1 - if unable to open requested key
;                  |2 - if unable to open requested main key
;                  |3 - if unable to remote connect to the registry
;                  |-1 - if unable to open requested value
;                  |-2 - if value type not supported
;                  |-3 - Current user is not Admin.
;                  |-4 - Invalid key on OS.
;                  |-5 - An invaild value.
; Author ........: Adam Lawrence (AdamUL)
; Modified ......:
; Remarks .......: Admin rights required to set the value.
; Related .......:
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func _UAC_SetEnableUIADesktopToggle($iValue = $UAC_DISABLED)
	If Not IsAdmin() Then Return SetError(-3, 0, -1)
	If StringRegExp(@OSVersion, "_(XP|200(0|3))") Then Return SetError(-4, 0, -1)
	If $iValue < 0 Or $iValue > 1 Then Return SetError(-5, 0, -1)
	Local $s64Bit = ""
	If @OSArch = "X64" Then $s64Bit = "64"
	Local $iReturn = RegWrite("HKEY_LOCAL_MACHINE" & $s64Bit & "\Software\Microsoft\Windows\CurrentVersion\Policies\System", "EnableUIADesktopToggle", "REG_DWORD", $iValue)
	If $iReturn = 0 Then $iReturn = -1
	Return SetError(@error, 0, $iReturn)
EndFunc   ;==>_UAC_SetEnableUIADesktopToggle

; #FUNCTION# ====================================================================================================================
; Name ..........: _UAC_SetEnableVirtualization
; Description ...: Sets UAC Registry Key for EnableVirtualization.  Virtualize file and registry write failures to per-user locations.
; Syntax ........: _UAC_SetEnableVirtualization([$iValue = $UAC_ENABLED (1)])
; Parameters ....: $iValue - [optional] An integer value. Default is 1.
;                  |$UAC_DISABLED (0) - Disabled.
;                  |$UAC_ENABLED (1) - Enabled.
; Return values .: Success - 1
;                  Failure - -1, sets @error to:
;                  |1 - if unable to open requested key
;                  |2 - if unable to open requested main key
;                  |3 - if unable to remote connect to the registry
;                  |-1 - if unable to open requested value
;                  |-2 - if value type not supported
;                  |-3 - Current user is not Admin.
;                  |-4 - Invalid key on OS.
;                  |-5 - An invaild value.
; Author ........: Adam Lawrence (AdamUL)
; Modified ......:
; Remarks .......: Admin rights required to set the value.
; Related .......:
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func _UAC_SetEnableVirtualization($iValue = $UAC_ENABLED)
	If Not IsAdmin() Then Return SetError(-3, 0, -1)
	If StringRegExp(@OSVersion, "_(XP|200(0|3))") Then Return SetError(-4, 0, -1)
	If $iValue < 0 Or $iValue > 1 Then Return SetError(-5, 0, -1)
	Local $s64Bit = ""
	If @OSArch = "X64" Then $s64Bit = "64"
	Local $iReturn = RegWrite("HKEY_LOCAL_MACHINE" & $s64Bit & "\Software\Microsoft\Windows\CurrentVersion\Policies\System", "EnableVirtualization", "REG_DWORD", $iValue)
	If $iReturn = 0 Then $iReturn = -1
	Return SetError(@error, 0, $iReturn)
EndFunc   ;==>_UAC_SetEnableVirtualization

; #FUNCTION# ====================================================================================================================
; Name ..........: _UAC_SetFilterAdministratorToken
; Description ...: Sets UAC Registry Key for FilterAdministratorToken.  Admin Approval Mode for the Built-in Administrator account.
; Syntax ........: _UAC_SetFilterAdministratorToken([$iValue = $UAC_DISABLED (0)])
; Parameters ....: $iValue - [optional] An integer value. Default is 1.
;                  |$UAC_DISABLED (0) - Disabled.
;                  |$UAC_ENABLED (1) - Enabled.
; Return values .: Success - 1
;                  Failure - -1, sets @error to:
;                  |1 - if unable to open requested key
;                  |2 - if unable to open requested main key
;                  |3 - if unable to remote connect to the registry
;                  |-1 - if unable to open requested value
;                  |-2 - if value type not supported
;                  |-3 - Current user is not Admin.
;                  |-4 - Invalid key on OS.
;                  |-5 - An invaild value.
; Author ........: Adam Lawrence (AdamUL)
; Modified ......:
; Remarks .......: Admin rights required to set the value.
; Related .......:
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func _UAC_SetFilterAdministratorToken($iValue = $UAC_DISABLED)
	If Not IsAdmin() Then Return SetError(-3, 0, -1)
	If StringRegExp(@OSVersion, "_(XP|200(0|3))") Then Return SetError(-4, 0, -1)
	If $iValue < 0 Or $iValue > 1 Then Return SetError(-5, 0, -1)
	Local $s64Bit = ""
	If @OSArch = "X64" Then $s64Bit = "64"
	Local $iReturn = RegWrite("HKEY_LOCAL_MACHINE" & $s64Bit & "\Software\Microsoft\Windows\CurrentVersion\Policies\System", "FilterAdministratorToken", "REG_DWORD", $iValue)
	If $iReturn = 0 Then $iReturn = -1
	Return SetError(@error, 0, $iReturn)
EndFunc   ;==>_UAC_SetFilterAdministratorToken

; #FUNCTION# ====================================================================================================================
; Name ..........: _UAC_SetPromptOnSecureDesktop
; Description ...: Sets UAC Registry Key for PromptOnSecureDesktop. Switch to the secure desktop when prompting for elevation.
; Syntax ........: _UAC_SetPromptOnSecureDesktop([$iValue = $UAC_ENABLED (1)])
; Parameters ....: $iValue - [optional] An integer value. Default is 1.
;                  |$UAC_DISABLED (0) - Disabled.
;                  |$UAC_ENABLED (1) - Enabled.
; Return values .: Success - 1
;                  Failure - -1, sets @error to:
;                  |1 - if unable to open requested key
;                  |2 - if unable to open requested main key
;                  |3 - if unable to remote connect to the registry
;                  |-1 - if unable to open requested value
;                  |-2 - if value type not supported
;                  |-3 - Current user is not Admin.
;                  |-4 - Invalid key on OS.
;                  |-5 - An invaild value.
; Author ........: Adam Lawrence (AdamUL)
; Modified ......:
; Remarks .......: Admin rights required to set the value.
; Related .......:
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func _UAC_SetPromptOnSecureDesktop($iValue = $UAC_ENABLED)
	If Not IsAdmin() Then Return SetError(-3, 0, -1)
	If StringRegExp(@OSVersion, "_(XP|200(0|3))") Then Return SetError(-4, 0, -1)
	If $iValue < 0 Or $iValue > 1 Then Return SetError(-5, 0, -1)
	Local $s64Bit = ""
	If @OSArch = "X64" Then $s64Bit = "64"
	Local $iReturn = RegWrite("HKEY_LOCAL_MACHINE" & $s64Bit & "\Software\Microsoft\Windows\CurrentVersion\Policies\System", "PromptOnSecureDesktop", "REG_DWORD", $iValue)
	If $iReturn = 0 Then $iReturn = -1
	Return SetError(@error, 0, $iReturn)
EndFunc   ;==>_UAC_SetPromptOnSecureDesktop

; #FUNCTION# ====================================================================================================================
; Name ..........: _UAC_SetValidateAdminCodeSignatures
; Description ...: Sets UAC Registry Key for ValidateAdminCodeSignatures.  Only elevate executables that are signed and validated.
; Syntax ........: _UAC_SetValidateAdminCodeSignatures([$iValue = $UAC_DISABLED (0)])
; Parameters ....: $iValue - [optional] An integer value. Default is 1.
;                  |$UAC_DISABLED (0) - Disabled.
;                  |$UAC_ENABLED (1) - Enabled.
; Return values .: Success - 1
;                  Failure - -1, sets @error to:
;                  |1 - if unable to open requested key
;                  |2 - if unable to open requested main key
;                  |3 - if unable to remote connect to the registry
;                  |-1 - if unable to open requested value
;                  |-2 - if value type not supported
;                  |-3 - Current user is not Admin.
;                  |-4 - Invalid key on OS.
;                  |-5 - An invaild value.
; Author ........: Adam Lawrence (AdamUL)
; Modified ......:
; Remarks .......: Admin rights required to set the value.
; Related .......:
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func _UAC_SetValidateAdminCodeSignatures($iValue = $UAC_DISABLED)
	If Not IsAdmin() Then Return SetError(-3, 0, -1)
	If StringRegExp(@OSVersion, "_(XP|200(0|3))") Then Return SetError(-4, 0, -1)
	If $iValue < 0 Or $iValue > 1 Then Return SetError(-5, 0, -1)
	Local $s64Bit = ""
	If @OSArch = "X64" Then $s64Bit = "64"
	Local $iReturn = RegWrite("HKEY_LOCAL_MACHINE" & $s64Bit & "\Software\Microsoft\Windows\CurrentVersion\Policies\System", "ValidateAdminCodeSignatures", "REG_DWORD", $iValue)
	If $iReturn = 0 Then $iReturn = -1
	Return SetError(@error, 0, $iReturn)
EndFunc   ;==>_UAC_SetValidateAdminCodeSignatures
