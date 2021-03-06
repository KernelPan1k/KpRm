Func TimerWriteReport($hTimer, $sSection)
	Local $sDiff = StringFormat("%.2f", TimerDiff($hTimer) / 1000)
	LogMessage(@CRLF & "-- " & $sSection & " finished in " & $sDiff & "s --" & @CRLF)
EndFunc   ;==>TimerWriteReport

Func IsNewLine($arr, $line)
	Return _ArraySearch($arr, $line, 0, 0, 0, 1, 1, 0) = -1
EndFunc   ;==>IsNewLine

Func SendReport($sPathReport)
	If Not @Compiled Then Return
	If $bKpRmDev = True Then Return
	If Not FileExists($sPathReport) Then Return
	If Not IsInternetConnected() Then Return

	UpdateStatusBar("Send report ...")

	Local $hOpen = _WinHttpOpen($sFtpUA)
	Local $hConnect = _WinHttpConnect($hOpen, $sUPDATE_SITE)
	Local $hRequest = _WinHttpOpenRequest($hConnect, "POST", $sUPLOAD_PAGE)
	Local $eReceved = _WinHttpSimpleFormFill($hConnect, $sUPLOAD_PAGE, Default, "name:my_log", $sPathReport)

	_WinHttpCloseHandle($hConnect)
	_WinHttpCloseHandle($hOpen)
EndFunc   ;==>SendReport

Func FormatPathWithMacro($sPath)
	Select
		Case StringRegExp($sPath, "^@AppDataCommonDir")
			$sPath = @AppDataCommonDir & StringReplace($sPath, "@AppDataCommonDir", "")
		Case StringRegExp($sPath, "^@DesktopDir")
			$sPath = @DesktopDir & StringReplace($sPath, "@DesktopDir", "")
		Case StringRegExp($sPath, "^@LocalAppDataDir")
			$sPath = @LocalAppDataDir & StringReplace($sPath, "@LocalAppDataDir", "")
		Case StringRegExp($sPath, "^@HomeDrive")
			$sPath = @HomeDrive & StringReplace($sPath, "@HomeDrive", "")
		Case StringRegExp($sPath, "^@TempDir")
			$sPath = @TempDir & StringReplace($sPath, "@TempDir", "")
	EndSelect

	Return $sPath
EndFunc   ;==>FormatPathWithMacro

Func _Restart_Windows_Explorer()
	Local $ifailure = 100, $zfailure = 100, $rPID = 0, $iExplorerPath = @WindowsDir & "\Explorer.exe"
	_WinAPI_ShellChangeNotify($shcne_AssocChanged, 0, 0, 0)     ; Save icon positions
	Local $hSystray = _WinAPI_FindWindow("Shell_TrayWnd", "")
	_SendMessage($hSystray, 1460, 0, 0)     ; Close the Explorer shell gracefully
	While ProcessExists("Explorer.exe")     ; Try Close the Explorer
		Sleep(10)
		$ifailure -= ProcessClose("Explorer.exe") ? 0 : 1
		If $ifailure < 1 Then Return SetError(1, 0, 0)
	WEnd

	While (Not ProcessExists("Explorer.exe"))     ; Start the Explorer
		If Not FileExists($iExplorerPath) Then Return SetError(-1, 0, 0)
		Sleep(500)
		$rPID = ShellExecute($iExplorerPath)
		$zfailure -= $rPID ? 0 : 1
		If $zfailure < 1 Then Return SetError(2, 0, 0)
	WEnd
	Return $rPID
EndFunc   ;==>_Restart_Windows_Explorer

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

Func HaraKiri()
	Dim $bKpRmDev

	If $bKpRmDev = False And @Compiled Then
		Run(@ComSpec & ' /c timeout 5 && del /F /Q "' & @AutoItExe & '"', "", @SW_HIDE)
		FileDelete(@AutoItExe)
	EndIf
EndFunc   ;==>HaraKiri

Func QuitKprm($bAutoDelete = False, $open = True)
	Dim $bKpRmDev
	Dim $sTmpDir

	DirRemove($sTmpDir, $DIR_REMOVE)

	If $open = True Then
		OpenReport()
	EndIf

	If $bAutoDelete = True Then
		HaraKiri()
	EndIf

	Exit
EndFunc   ;==>QuitKprm

Func IsInternetConnected()
	Local $aReturn = DllCall('connect.dll', 'long', 'IsInternetConnected')

	If @error <> 0 Then
		Return False
	EndIf

	Return $aReturn[0] = 0
EndFunc   ;==>IsInternetConnected

Func PowershellIsAvailable()
	Dim $bPowerShellAvailable

	If IsBool($bPowerShellAvailable) Then Return $bPowerShellAvailable

	Local $iPid = Run("powershell.exe", "", @SW_HIDE)

	If @error <> 0 Or Not $iPid Then
		$bPowerShellAvailable = False

		Return $bPowerShellAvailable
	EndIf

	ProcessClose($iPid)

	$bPowerShellAvailable = True

	Return $bPowerShellAvailable
EndFunc   ;==>PowershellIsAvailable

Func OpenReport($sParamReport = Null)
	Dim $sKPLogFile

	Local $sReport = @HomeDrive & "\KPRM\" & $sKPLogFile

	If $sParamReport <> Null Then
		$sReport = $sParamReport
	EndIf

	If FileExists($sReport) Then
		SendReport($sReport)
		Run("notepad.exe " & $sReport)
	EndIf
EndFunc   ;==>OpenReport

Func CountKpRmPass()
	Local Const $sDir = @HomeDrive & "\KPRM"

	Local $aFileList = _FileListToArray($sDir, "kprm-*.txt", $FLTA_FILES)

	If @error <> 0 Then Return 1

	Return $aFileList[0]
EndFunc   ;==>CountKpRmPass

Func UpdateStatusBar($sText)
	Dim $oHStatus

	GUICtrlSetData($oHStatus, $sText)
EndFunc   ;==>UpdateStatusBar

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

Func IsRegistryKey($sKey)
	Return StringRegExp($sKey, "(?i)^(HKLM|HKCU|HKU|HKCR|HKCC)")
EndFunc   ;==>IsRegistryKey

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
	If IsRegistryKey($sPkey) And @OSArch = "X64" Then
		Local $aSplit = StringSplit($sPkey, "\", $STR_NOCOUNT)
		$aSplit[0] = $aSplit[0] & "64"
		$sPkey = _ArrayToString($aSplit, "\")
	EndIf

	Return $sPkey
EndFunc   ;==>FormatForUseRegistryKey
