Local Const $TOOL_NAME = "KpRm"
Local Const $ERROR_ALREADY_EXISTS = 183
Local Const $ERROR_ACCESS_DENIED = 5

If (IsInstanceRunning()) Then
	If @OSLang = "040C" Then
		MsgBox("", "", $TOOL_NAME & " déjà lancé")
		Exit
	Else
		MsgBox("", "", $TOOL_NAME & " Already Running !")
		Exit
	EndIf
EndIf

Func IsInstanceRunning()
	Local $iErrorCode = 0;
	_WinAPI_CreateMutex($TOOL_NAME & "_MUTEX", True, 0)
	$iErrorCode = _WinAPI_GetLastError()
	return $iErrorCode==$ERROR_ALREADY_EXISTS Or $iErrorCode==$ERROR_ACCESS_DENIED
EndFunc

; #FUNCTION# ====================================================================================================================
; Author.........: Yashied
; Modified.......: Jpm
; ===============================================================================================================================
;~ Func _WinAPI_CreateMutex($sMutex, $bInitial = True, $tSecurity = 0)
;~ 	Local $aRet = DllCall('kernel32.dll', 'handle', 'CreateMutexW', 'struct*', $tSecurity, 'bool', $bInitial, 'wstr', $sMutex)
;~ 	If @error Then Return SetError(@error, @extended, 0)
;~ 	 If Not $aRet[0] Then Return SetError(1000, 0, 0)
;~ 	Return $aRet[0]
;~ EndFunc   ;==>_WinAPI_CreateMutex

; #FUNCTION# ====================================================================================================================
; Author ........: Paul Campbell (PaulIA)
; Modified.......:
; ===============================================================================================================================
;~ Func _WinAPI_GetLastError(Const $_iCurrentError = @error, Const $_iCurrentExtended = @extended)
;~ 	Local $aResult = DllCall("kernel32.dll", "dword", "GetLastError")
;~ 	Return SetError($_iCurrentError, $_iCurrentExtended, $aResult[0])
;~ EndFunc   ;==>_WinAPI_GetLastError
