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

Func LogMessage($message)
	Dim $sKPLogFile

	FileWrite(@HomeDrive & "\KPRM" & "\" & $sKPLogFile, $message & @CRLF)
EndFunc   ;==>LogMessage

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

Func SearchRegistryKeyStrings($sPath, $sPattern, $sKey)
	Local $i = 0
	While True
		$i += 1
		Local $sEntry = RegEnumKey($sPath, $i)
		If @error <> 0 Then ExitLoop
		Local $sRegPath = $sPath & "\" & $sEntry
		Local $sName = RegRead($sRegPath, $sKey)

		If StringRegExp($sName, $sPattern) Then
			Return $sRegPath
		EndIf
	WEnd

	Return Null
EndFunc   ;==>SearchRegistryKeyStrings

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
	Local $aProgramFilesList = []

	If FileExists(@HomeDrive & "\Program Files") Then
		_ArrayAdd($aProgramFilesList, @HomeDrive & "\Program Files")
	EndIf

	If FileExists(@HomeDrive & "\Program Files (x86)") Then
		_ArrayAdd($aProgramFilesList, @HomeDrive & "\Program Files (x86)")
	EndIf

	If FileExists(@HomeDrive & "\Program Files(x86)") Then
		_ArrayAdd($aProgramFilesList, @HomeDrive & "\Program Files(x86)")
	EndIf

	Return $aProgramFilesList
EndFunc   ;==>GetProgramFilesList

Func IsFile($sFilePath)
	Return Int(FileExists($sFilePath) And StringInStr(FileGetAttrib($sFilePath), 'D', Default, 1) = 0)
EndFunc   ;==>IsFile

Func IsDir($sFilePath)
	Return Int(FileExists($sFilePath) And StringInStr(FileGetAttrib($sFilePath), 'D', Default, 1) > 0)
EndFunc   ;==>IsDir

Func FileExistsAndGetType($sFilePath)
	Local $sFileType = Null

	If FileExists($sFilePath) Then
		Local $sVal = StringInStr(FileGetAttrib($sFilePath), 'D', Default, 1)

		If $sVal = 0 Then
			$sFileType = 'file'
		ElseIf $sVal > 0 Then
			$sFileType = 'folder'
		EndIf
	EndIf

	Return $sFileType
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

Func FormatForDisplayRegistryKey($sPkey)
	If StringRegExp($sPkey, "^(HKLM|HKCU|HKU|HKCR|HKCC)64") Then
		Local $sKey = StringReplace($sPkey, "64", "", 1)
		Return $sKey
	EndIf

	Return $sPkey
EndFunc   ;==>FormatForDisplayRegistryKey

Func AddInDictionaryIfNotExistAndIncrement($oDict, $sKey)
	If $oDict.Exists($sKey) Then
		Local $sVal = $oDict.Item($sKey) + 1
		$oDict.Item($sKey) = $sVal
	Else
		$oDict.add($sKey, 1)
	EndIf

	Return $oDict
EndFunc   ;==>AddInDictionaryIfNotExistAndIncrement

Func UpdateToolCpt($sToolKey, $sElementkey, $sElementValue)
	Dim $oToolsCpt

	Local $oToolsData = $oToolsCpt.Item($sToolKey)
	Local $oToolsDict = AddInDictionaryIfNotExistAndIncrement($oToolsData.Item($sElementkey), $sElementValue)
	$oToolsData.Item($sElementkey) = $oToolsDict
	$oToolsCpt.Item($sToolKey) = $oToolsData
EndFunc   ;==>UpdateToolCpt


Func UCheckIfProcessExist($sProcess, $sToolVal)
	If $sProcess = Null Or $sProcess = "" Then Return

	Local $iStatus = ProcessExists($sProcess)

	If $iStatus <> 0 Then
		LogMessage("     [X] Process " & $sProcess & " not killed, it is possible that the deletion is not complete (" & $sToolVal & ")")
	Else
		LogMessage("     [OK] Process " & $sProcess & " killed (" & $sToolVal & ")")
	EndIf
EndFunc   ;==>UCheckIfProcessExist

Func UCheckIfRegistyKeyExist($sToolElement, $sToolVal)
	If $sToolElement = Null Or $sToolElement = "" Then Return

	Local $sSymbol = "[X]"
	RegEnumVal($sToolElement, "1")

	If @error >= 0 Then
		$sSymbol = "[OK]"
	EndIf

	LogMessage("     " & $sSymbol & " " & FormatForDisplayRegistryKey($sToolElement) & " deleted (" & $sToolVal & ")")
EndFunc   ;==>UCheckIfRegistyKeyExist

Func UCheckIfUninstallOk($sToolElement, $sToolVal)
	If $sToolElement = Null Or $sToolElement = "" Then Return

	Local $sDrive = "", $sDir = "", $sFileName = "", $sExtension = ""
	Local $aPathSplit = _PathSplit($sToolElement, $sDrive, $sDir, $sFileName, $sExtension)

	If $sExtension = ".exe" Then
		Local $sFolderPath = $aPathSplit[1] & $aPathSplit[2]
		Local $sSymbol = "[OK]"

		If FileExists($sFolderPath) Then
			$sSymbol = "[X]"
		EndIf

		LogMessage("     " & $sSymbol & " Uninstaller run correctly (" & $sToolVal & ")")
	EndIf
EndFunc   ;==>UCheckIfUninstallOk

Func UCheckIfElementExist($sToolElement, $sToolVal)
	If $sToolElement = Null Or $sToolElement = "" Then Return

	Local $sSymbol = "[OK]"

	If FileExists($sToolElement) Then
		$sSymbol = "[X]"
	EndIf

	LogMessage("     " & $sSymbol & " " & $sToolElement & " deleted (" & $sToolVal & ")")
EndFunc   ;==>UCheckIfElementExist

Func CheckIfExist($sType, $sToolElement, $sToolVal)
	Switch $sType
		Case "process"
			UCheckIfProcessExist($sToolElement, $sToolVal)
		Case "key"
			UCheckIfRegistyKeyExist($sToolElement, $sToolVal)
		Case "uninstall"
			UCheckIfUninstallOk($sToolElement, $sToolVal)
		Case "element"
			UCheckIfElementExist($sToolElement, $sToolVal)
		Case Else
			LogMessage("     [?] Unknown type " & $sType)
	EndSwitch
EndFunc   ;==>CheckIfExist
