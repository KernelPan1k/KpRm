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
