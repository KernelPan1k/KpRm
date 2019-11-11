Func GetLanguage()
	Switch StringRight(@MUILang, 2)
		Case "07"
			Return "de"
		Case "09"
			Return "en"
		Case "0a"
			Return "es"
		Case "0c"
			Return "fr"
		Case "10"
			Return "it"
		Case "16"
			Return "pt"
		Case Else
			Return "en"
	EndSwitch
EndFunc   ;==>GetLanguage

Func ClearAttributes($sPath)
	Local $sAttrib = FileGetAttrib($sPath)

	If StringInStr($sAttrib, "R") Then
		FileSetAttrib($sPath, "-R")
	EndIf

	If StringInStr($sAttrib, "S") Then
		FileSetAttrib($sPath, "-S")
	EndIf

	If StringInStr($sAttrib, "H") Then
		FileSetAttrib($sPath, "-H")
	EndIf

	If StringInStr($sAttrib, "A") Then
		FileSetAttrib($sPath, "-A")
	EndIf
EndFunc   ;==>ClearAttributes

Func QuitKprm($bAutoDelete = False, $open = True)
	Dim $bKpRmDev
	Dim $sKPLogFile
	Dim $sTmpDir

	DirRemove($sTmpDir, $DIR_REMOVE)

	If $bAutoDelete = True Then
		If $open = True Then
			Run("notepad.exe " & @HomeDrive & "\KPRM" & "\" & $sKPLogFile)
		EndIf

		If $bKpRmDev = False And @Compiled Then
			Run(@ComSpec & ' /c timeout 3 && del /F /Q "' & @ScriptFullPath & '"', @TempDir, @SW_HIDE)
			FileDelete(@ScriptFullPath)
		EndIf
	EndIf
	Exit
EndFunc   ;==>QuitKprm

Func IsInternetConnected()
	Local $aReturn = DllCall('connect.dll', 'long', 'IsInternetConnected')

	If @error <> 0 Then
		Return False
	EndIf

	Return $aReturn[0] = 0
EndFunc   ;==>_IsInternetConnected

Func PowershellIsAvailable()
	Dim $bPowerShellAvailable

	If IsBool($bPowerShellAvailable) Then Return $bPowerShellAvailable

	Local $iPid = Run("powershell.exe", @TempDir, @SW_HIDE)

	If @error <> 0 Or Not $iPid Then
		$bPowerShellAvailable = False

		Return $bPowerShellAvailable
	EndIf

	ProcessClose($iPid)

	$bPowerShellAvailable = True

	Return $bPowerShellAvailable
EndFunc   ;==>PowershellIsAvailable

Func HTTP_Get($url)
	Local $oHTTP = ObjCreate("winhttp.winhttprequest.5.1")
	Local $res = $oHTTP.Open("GET", $url, False)
	If (@error) Then Return SetError(1, 0, 0)
	$oHTTP.Send()
	If (@error) Then Return SetError(2, 0, 0)
	Local $sReceived = $oHTTP.ResponseText
	Local $iStatus = $oHTTP.Status
	If $iStatus = 200 Then
		Return $sReceived
	Else
		Return SetError(3, $iStatus, $sReceived)
	EndIf
EndFunc   ;==>HTTP_Get

Func CheckVersionOfKpRm()
	Dim $sKprmVersion
	Dim $sTmpDir

	If IsInternetConnected() = False Then Return

	Local $sVersion = HTTP_Get("https://toolslib.net/api/softwares/951/version")

	If @error <> 0 Or StringInStr($sVersion, "Not found") Then
		Return
	EndIf

	Local $bNeedsUpdate = $sKprmVersion And $sVersion And $sKprmVersion <> $sVersion

	If $bNeedsUpdate Then
		; https://github.com/KernelPan1k/KPAutoUpdater
		FileInstall(".\binaries\KPAutoUpdater\KPAutoUpdater.exe", $sTmpDir & "\KPAutoUpdater.exe")

		Local $iAutoUpdaterPid = Run($sTmpDir & '\KPAutoUpdater.exe "KpRm" "' & @AutoItPID & '" "https://download.toolslib.net/download/direct/951/latest"')

		If 0 = $iAutoUpdaterPid Then Return

		Local $iCpt = 50

		Do
			$iCpt -= 1
			Sleep(500)
		Until ($iCpt = 0 Or 0 = ProcessExists($iAutoUpdaterPid))

		Sleep(5000)
	EndIf
EndFunc   ;==>CheckVersionOfKpRm

Func GetSuffixKey()
	Local $s64Bit = ""
	If @OSArch = "X64" Then $s64Bit = "64"

	Return $s64Bit
EndFunc   ;==>GetSuffixKey

Func LogMessage($message)
	Dim $sKPLogFile

	FileWrite(@HomeDrive & "\KPRM" & "\" & $sKPLogFile, $message & @CRLF)
	FileWrite(@DesktopDir & "\" & $sKPLogFile, $message & @CRLF)
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
	Local $aProgramFilesList[0]

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
	If StringRegExp($sPkey, "(?i)^(HKLM|HKCU|HKU|HKCR|HKCC)64") Then
		Local $sKey = StringReplace($sPkey, "64", "", 1)
		Return $sKey
	EndIf

	Return $sPkey
EndFunc   ;==>FormatForDisplayRegistryKey

Func FormatForUseRegistryKey($sPkey)
	If StringRegExp($sPkey, "(?i)^(HKLM|HKCU|HKU|HKCR|HKCC)") And @OSArch = "X64" Then
		Local $aSplit = StringSplit($sPkey, "\", $STR_NOCOUNT)
		$aSplit[0] = $aSplit[0] & "64"
		$sPkey = _ArrayToString($aSplit, "\")
	EndIf

	Return $sPkey
EndFunc   ;==>FormatForUseRegistryKey

Func FormatPathWithMacro($sPath)
	If StringRegExp($sPath, "^@AppDataCommonDir") Then
		$sPath = @AppDataCommonDir & StringReplace($sPath, "@AppDataCommonDir", "")
	ElseIf StringRegExp($sPath, "^@DesktopDir") Then
		$sPath = @DesktopDir & StringReplace($sPath, "@DesktopDir", "")
	ElseIf StringRegExp($sPath, "^@LocalAppDataDir") Then
		$sPath = @LocalAppDataDir & StringReplace($sPath, "@LocalAppDataDir", "")
	ElseIf StringRegExp($sPath, "^@HomeDrive") Then
		$sPath = @HomeDrive & StringReplace($sPath, "@HomeDrive", "")
	ElseIf StringRegExp($sPath, "^@TempDir") Then
		$sPath = @TempDir & StringReplace($sPath, "@TempDir", "")
	EndIf

	Return $sPath
EndFunc   ;==>FormatPathWithMacro

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
	Local $bExist = FileExists($sToolElement)

	If $bExist = True Then
		$sSymbol = "[X]"
		AddRemoveAtRestart($sToolElement)
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

Func TimerWriteReport($hTimer, $sSection)
	Local $sDiff = StringFormat("%.2f", TimerDiff($hTimer) / 1000)
	LogMessage(@CRLF & "-- " & $sSection & " finished in " & $sDiff & "s --" & @CRLF)
EndFunc   ;==>TimerWriteReport
