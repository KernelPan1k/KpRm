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

Func _IsInternetConnected()
	Local $aReturn = DllCall('connect.dll', 'long', 'IsInternetConnected')

	If @error <> 0 Then
		Return False
	EndIf

	Return $aReturn[0] = 0
EndFunc   ;==>_IsInternetConnected

Func CheckVersionOfKpRm()
	Dim $sKprmVersion

	If _IsInternetConnected() = False Then Return

	Local $sVersion = _HTTP_Get("https://toolslib.net/api/softwares/951/version")

	If @error <> 0 Or StringInStr($sVersion, "Not found") Then
		Return
	EndIf

	Local $bNeedsUpdate = $sKprmVersion And $sVersion And $sKprmVersion <> $sVersion

	If $bNeedsUpdate Then

		;~ Check if powershell is available
		Local $iPid = Run("powershell.exe",  @TempDir, @SW_HIDE)

		If @error <> 0 Or Not $iPid Then
			Return
		EndIf

		ProcessClose($iPid)

		Local $sDownloadedFilePath = DownloadLatest()

		If @error <> 0 Or FileExists($sDownloadedFilePath) = False Then
			Return
		EndIf

		SelfUpdate($sDownloadedFilePath)

		If @error <> 0 Then
			MsgBox($MB_SYSTEMMODAL, "KpRm - Updater", "The script must be a compiled exe to work correctly or the update file must exist.")
			QuitKprm(True, False)
		EndIf
	EndIf
EndFunc   ;==>CheckVersionOfKpRm

Func DownloadLatest()
	ProgressOn("KpRm - Updater", "Downloading..", "0%")
	Local $sURL = "https://download.toolslib.net/download/direct/951/latest"
	Local $sFilePath = _WinAPI_GetTempFileName(@TempDir)
	Local $iRemoteFileSize = InetGetSize($sURL)
	Local $hDownload = InetGet($sURL, $sFilePath, $INET_FORCERELOAD, $INET_DOWNLOADBACKGROUND)

	Do
		Sleep(250)
		Local $iBytesReceived = InetGetInfo($hDownload, $INET_LOCALCACHE)
		Local $iPercentage = Int($iBytesReceived / $iRemoteFileSize * 100)
		ProgressSet($iPercentage, $iPercentage & "%")
	Until InetGetInfo($hDownload, $INET_DOWNLOADCOMPLETE)

	Local $iBytesSize = InetGetInfo($hDownload, $INET_DOWNLOADREAD)
	Local $iFileSize = FileGetSize($sFilePath)

	InetClose($hDownload)

	ProgressOff()

	Return $sFilePath

EndFunc   ;==>DownloadLatest

Func SelfUpdate($sUpdatePath)
	If @Compiled = 0 Or FileExists($sUpdatePath) = 0 Then
		Return SetError(1, 0, 0)
	EndIf

	Local $sTempFileName = @ScriptName
	Local $sProcessName = @ScriptName

	$sTempFileName = StringLeft($sTempFileName, StringInStr($sTempFileName, '.', $STR_NOCASESENSEBASIC, -1) - 1)
	$sProcessName = StringLeft($sProcessName, StringInStr($sProcessName, '.', $STR_NOCASESENSEBASIC, -1) - 1)

	Local Const $sScriptPath = @ScriptFullPath

	While FileExists(@TempDir & '\' & $sTempFileName & '.ps1')
		$sTempFileName &= Chr(Random(65, 122, 1))
	WEnd

	$sTempFileName = @TempDir & '\' & $sTempFileName & '.ps1'

	Local Const $sData = '$process = Get-Process "' & $sProcessName & '" -ErrorAction SilentlyContinue' & @CRLF _
			 & 'if ($process) {' & @CRLF _
			 & '$process | Stop-Process -Force' & @CRLF _
			 & '}' & @CRLF _
			 & 'sleep 2' & @CRLF _
			 & 'Move-Item -Path "' & $sUpdatePath & '" -Destination "' & $sScriptPath & '" -Force' & @CRLF _
			 & 'sleep 2' & @CRLF _
			 & '& "' & $sScriptPath & '"' & @CRLF _
			 & 'Remove-Item -Path "' & $sTempFileName & '" -Force'

	Local Const $hFileOpen = FileOpen($sTempFileName, 130)

	If $hFileOpen = -1 Then
		Return False
	EndIf

	FileWrite($hFileOpen, $sData)
	FileClose($hFileOpen)

	If Not FileExists($sTempFileName) Then
		Return False
	EndIf

	Run(@ComSpec & ' /c timeout 10 && powershell.exe -File ' & $sTempFileName, @TempDir, @SW_HIDE)

	Exit
EndFunc   ;==>SelfUpdate

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
