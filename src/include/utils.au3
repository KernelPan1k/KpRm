
Func logMessage($message)
	FileWrite(@DesktopDir & "\kp-remover.txt", $message & @CRLF)
EndFunc   ;==>logMessage


Func _start_explorer()
    $strComputer = "localhost"
    $objWMI = ObjGet("winmgmts:\\" & $strComputer & "\root\CIMV2")
    Local $objexplorer = $objWMI.Get("win32_process")
    $objexplorer.create("explorer.exe")
EndFunc   ;==>_start_explorer

Func _Restart_Windows_Explorer()
	;Close the explorer shell gracefully
	$hSysTray_Handle = _WinAPI_FindWindow('Shell_TrayWnd', '')
	_SendMessage($hSysTray_Handle, 0x5B4, 0, 0)

	While WinExists($hSysTray_Handle)
    		Sleep(500)
	WEnd

	_start_explorer()

	While Not _WinAPI_GetShellWindow()
	    Sleep(500)
	WEnd

	EnvUpdate()

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
