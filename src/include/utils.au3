
Func logMessage($message)
	FileWrite(@DesktopDir & "\kp-remover.txt", $message & @CRLF)
EndFunc   ;==>logMessage

Func _Restart_Windows_Explorer()
	; By KaFu

	; Believed to save icon positions just before Shutting down explorer, which comes next
	_WinAPI_ShellChangeNotify($SHCNE_ASSOCCHANGED, 0, 0, 0)

	;Shutting down explorer gracefully
	Local $hSysTray_Handle = DllCall("user32.dll", "HWND", "FindWindow", "str", "Shell_TrayWnd", "str", "")
	If Not IsHWnd($hSysTray_Handle[0]) Then Return SetError(1)

	Local $iPID_Old = WinGetProcess($hSysTray_Handle[0])

	_SendMessage($hSysTray_Handle[0], 0x5B4, 0, 0)

	#cs
	    Local $i_Timer = TimerInit()
	    While IsHWnd($hSysTray_Handle[0])
	        Sleep(10)
	        If TimerDiff($i_Timer) > 5000 Then Return SetError(2)
	    WEnd
	#ce

	Local $i_Timer = TimerInit()
	While ProcessExists($iPID_Old)
		Sleep(10)
		If TimerDiff($i_Timer) > 5000 Then Return SetError(3)
	WEnd

	Sleep(500)

	Return ShellExecute(@WindowsDir & "\Explorer.exe")

EndFunc   ;==>_Restart_Windows_Explorer

;Retrieve Local Machine Users
Func _GetLocalUsers($sHost = @ComputerName)
	Local $sUsers = []
	Local $oColUsers = ObjGet("WinNT://" & $sHost & "")
	If Not IsObj($oColUsers) Then
		Return 0
	EndIf
	Dim $aFilter[1] = ["user"]
	$oColUsers.Filter = $aFilter

	For $oUser In $oColUsers
		_ArrayAdd($sUsers, $oUser.name)
	Next

	$oColUsers = 0
	$aFilter = 0

	Return $sUsers
EndFunc   ;==>_GetLocalUsers

Func TryResolveUserDesktop($User)
	Return @HomeDrive & "\Users\" & $User & "\Desktop"
EndFunc   ;==>TryResolveUserDesktop

Func searchRegistryKeyStrings($path, $pattern, $key)
	$i = 0
	While True
		$i += 1
		Local $entry = RegEnumKey($path, $i)
		If @error <> 0 Then ExitLoop
		$regPath = $path & "\" & $entry
		$name = RegRead($regPath, $key)

		If StringRegExp($name, $pattern) Then
			Return $regPath
		EndIf
	WEnd

	Return Null
EndFunc   ;==>searchRegistryKeyStrings

Func TasksExist($task)
	Local $out, $sresult
	; $rslt = Run(@ComSpec & ' /c schtasks', "", @SW_HIDE, 0x2 + 0x4)
	$rslt = Run(@ComSpec & ' /c schtasks /query /FO list', "", @SW_HIDE, 0x2 + 0x4)
	While 1
		$sresult = StdoutRead($rslt)
		If @error Then ExitLoop
		If $sresult Then $out &= $sresult
	WEnd

	Return StringRegExp($out, "(?i)\Q" & $task & "\E\R") ? True : False
EndFunc   ;==>TasksExist
