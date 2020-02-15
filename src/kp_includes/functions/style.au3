Func CustomMsgBox($vIcon = 0, $sTitle = "", $sMsg = "", $vButton = 0)
	Dim $cBlack
	Dim $cWhite

	_ExtMsgBoxSet(-1, -1, $cBlack, $cWhite)
	Local Const $iRetValue = _ExtMsgBox($vIcon, $vButton, $sTitle, $sMsg, 0)
	_ExtMsgBoxSet(Default)

	Return $iRetValue
EndFunc   ;==>CustomMsgBox

Func XPStyle($OnOff = 1)
	Local $XS_n
	If $OnOff And StringInStr(@OSType, "WIN32_NT") Then
		$XS_n = DllCall("uxtheme.dll", "int", "GetThemeAppProperties")
		DllCall("uxtheme.dll", "none", "SetThemeAppProperties", "int", 0)
		Return 1
	ElseIf StringInStr(@OSType, "WIN32_NT") And IsArray($XS_n) Then
		DllCall("uxtheme.dll", "none", "SetThemeAppProperties", "int", $XS_n[0])
		$XS_n = ""
		Return 1
	EndIf
	Return 0
EndFunc   ;==>XPStyle
