Func HttpGet($sURL, $sData = "")
    Local $oHTTP = ObjCreate("WinHttp.WinHttpRequest.5.1")
    $oHTTP.Open("GET", $sURL & "?" & $sData, False)
    $oHTTP.SetTimeouts(50, 50, 50, 50)
    If (@error) Then Return SetError(1, 0, 0)
    $oHTTP.Send()
    If (@error) Then Return SetError(2, 0, 0)
    If ($oHTTP.Status <> 200) Then Return SetError(3, 0, 0)
    Return SetError(0, 0, $oHTTP.ResponseText)
EndFunc   ;==>HttpGet

Func logMessage($message)
	Dim $KPLogFile

	FileWrite(@DesktopDir & "\" & $KPLogFile, $message & @CRLF)
	FileWrite(@HomeDrive & "\KPRM" & "\" & $KPLogFile, $message & @CRLF)
EndFunc   ;==>logMessage

Func _Restart_Windows_Explorer()
	Local $ifailure = 100, $zfailure = 100, $rPID = 0, $iExplorerPath = @WindowsDir & "\Explorer.exe"
	_WinAPI_ShellChangeNotify($shcne_AssocChanged, 0, 0, 0) ; Save icon positions
	Local $hSystray = _WinAPI_FindWindow("Shell_TrayWnd", "")
	_SendMessage($hSystray, 1460, 0, 0) ; Close the Explorer shell gracefully
	While ProcessExists("Explorer.exe") ; Try Close the Explorer
		Sleep(10)
		$ifailure -= ProcessClose("Explorer.exe") ? 0 : 1
		If $ifailure < 1 Then Return SetError(1, 0, 0)
	WEnd

	While (Not ProcessExists("Explorer.exe")) ; Start the Explorer
		If Not FileExists($iExplorerPath) Then Return SetError(-1, 0, 0)
		Sleep(500)
		$rPID = ShellExecute($iExplorerPath)
		$zfailure -= $rPID ? 0 : 1
		If $zfailure < 1 Then Return SetError(2, 0, 0)
	WEnd
	Return $rPID
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
	Local $i = 0
	While True
		$i += 1
		Local $entry = RegEnumKey($path, $i)
		If @error <> 0 Then ExitLoop
		Local $regPath = $path & "\" & $entry
		Local $name = RegRead($regPath, $key)

		If StringRegExp($name, $pattern) Then
			Return $regPath
		EndIf
	WEnd

	Return Null
EndFunc   ;==>searchRegistryKeyStrings

Func TasksExist($task)
	Local $out, $sresult
	; $rslt = Run(@ComSpec & ' /c schtasks', "", @SW_HIDE, 0x2 + 0x4)
	Local $rslt = Run(@ComSpec & ' /c schtasks /query /FO list', "", @SW_HIDE, 0x2 + 0x4)
	While 1
		$sresult = StdoutRead($rslt)
		If @error Then ExitLoop
		If $sresult Then $out &= $sresult
	WEnd

	Return StringRegExp($out, "(?i)\Q" & $task & "\E\R") ? True : False
EndFunc   ;==>TasksExist

Func GetProgramFilesList()
	Local $ProgramFilesList = []

	If FileExists(@HomeDrive & "\Program Files") Then
		_ArrayAdd($ProgramFilesList, @HomeDrive & "\Program Files")
	EndIf

	If FileExists(@HomeDrive & "\Program Files (x86)") Then
		_ArrayAdd($ProgramFilesList, @HomeDrive & "\Program Files (x86)")
	EndIf

	If FileExists(@HomeDrive & "\Program Files(x86)") Then
		_ArrayAdd($ProgramFilesList, @HomeDrive & "\Program Files(x86)")
	EndIf

	Return $ProgramFilesList
EndFunc   ;==>GetProgramFilesList

Func IsFile($sFilePath)
	Return Int(FileExists($sFilePath) And StringInStr(FileGetAttrib($sFilePath), 'D', Default, 1) = 0)
EndFunc   ;==>IsFile

Func IsDir($sFilePath)
	Return Int(FileExists($sFilePath) And StringInStr(FileGetAttrib($sFilePath), 'D', Default, 1) > 0)
EndFunc   ;==>IsDir

Func FileExistsAndGetType($sFilePath)
	Local $fileType = Null

	If FileExists($sFilePath) Then
		Local $val = StringInStr(FileGetAttrib($sFilePath), 'D', Default, 1)

		If $val = 0 Then
			$fileType = 'file'
		ElseIf $val > 0 Then
			$fileType = 'folder'
		EndIf
	EndIf

	Return $fileType
EndFunc   ;==>FileExistsAndGetType

Func GetHumanVersion()
	Switch @OSVersion
		Case "WIN_VISTA"
			Return "Windows Vista"
		Case "WIN_7"
			Return "Windows 7"
		Case "WIN_8"
			Return "Windows 8"
		Case "WIN_81"
			Return "Windows 8.1"
		Case "WIN_10"
			Return "Windows 10"
		Case Else
			Return "Unsupported OS"
	EndSwitch
EndFunc   ;==>GetHumanVersion

Func FormatForDisplayRegistryKey($key)
	If StringRegExp($key, "^(HKLM|HKCU|HKU|HKCR|HKCC)64") Then
		Local $sKey = StringReplace($key, "64", "", 1)
		Return $sKey
	EndIf

	Return $key
EndFunc   ;==>FormatForDisplayRegistryKey

Func AddInDictionaryIfNotExistAndIncrement($dict, $key)
	If $dict.Exists($key) Then
		Local $val = $dict.Item($key) + 1
		$dict.Item($key) = $val
	Else
		$dict.add($key, 1)
	EndIf

	Return $dict
EndFunc   ;==>AddInDictionaryIfNotExistAndIncrement

Func UpdateToolCpt($toolKey, $elementkey, $elementValue)
	Dim $ToolsCpt

	Local $toolsData = $ToolsCpt.Item($toolKey)
	Local $toolsDict = AddInDictionaryIfNotExistAndIncrement($toolsData.Item($elementkey), $elementValue)
	$toolsData.Item($elementkey) = $toolsDict
	$ToolsCpt.Item($toolKey) = $toolsData
EndFunc   ;==>UpdateToolCpt


Func UCheckIfProcessExist($process, $toolVal)
	If $process = Null Or $process = "" Then Return

	Local $status = ProcessExists($process)

	If $status <> 0 Then
		logMessage("     [X] Process " & $process & " not killed, it is possible that the deletion is not complete (" & $toolVal & ")")
	Else
		logMessage("     [OK] Process " & $process & " killed (" & $toolVal & ")")
	EndIf
EndFunc   ;==>UCheckIfProcessExist

Func UCheckIfRegistyKeyExist($toolElement, $toolVal)
	If $toolElement = Null Or $toolElement = "" Then Return

	Local $symbol = "[X]"
	RegEnumVal($toolElement, "1")

	If @error >= 0 Then
		$symbol = "[OK]"
	EndIf

	logMessage("     " & $symbol & " " & FormatForDisplayRegistryKey($toolElement) & " deleted (" & $toolVal & ")")
EndFunc   ;==>UCheckIfRegistyKeyExist

Func UCheckIfUninstallOk($toolElement, $toolVal)
	If $toolElement = Null Or $toolElement = "" Then Return

	Local $sDrive = "", $sDir = "", $sFileName = "", $sExtension = ""
	Local $aPathSplit = _PathSplit($toolElement, $sDrive, $sDir, $sFileName, $sExtension)

	If $sExtension = ".exe" Then
		Local $folderPath = $aPathSplit[1] & $aPathSplit[2]
		Local $symbol = "[OK]"

		If FileExists($folderPath) Then
			$symbol = "[X]"
		EndIf

		logMessage("     " & $symbol & " Uninstaller run correctly (" & $toolVal & ")")
	EndIf
EndFunc   ;==>UCheckIfUninstallOk

Func UCheckIfElementExist($toolElement, $toolVal)
	If $toolElement = Null Or $toolElement = "" Then Return

	Local $symbol = "[OK]"

	If FileExists($toolElement) Then
		$symbol = "[X]"
	EndIf

	logMessage("     " & $symbol & " " & $toolElement & " deleted (" & $toolVal & ")")
EndFunc   ;==>UCheckIfElementExist

Func CheckIfExist($type, $toolElement, $toolVal)
	Switch $type
		Case "process"
			UCheckIfProcessExist($toolElement, $toolVal)
		Case "key"
			UCheckIfRegistyKeyExist($toolElement, $toolVal)
		Case "uninstall"
			UCheckIfUninstallOk($toolElement, $toolVal)
		Case "element"
			UCheckIfElementExist($toolElement, $toolVal)
		Case Else
			logMessage("     [?] Unknown type " & $type)
	EndSwitch
EndFunc   ;==>CheckIfExist
