;################################################| Functions

Func ProgressBarUpdate($nbr = 1)
	$iCurrentNbrTask += $nbr
	Dim $oProgressBar
	GUICtrlSetData($oProgressBar, $iCurrentNbrTask * $iTaskStep)

	If $iCurrentNbrTask = $iNbrTask Then
		GUICtrlSetData($oProgressBar, 100)
	EndIf
EndFunc   ;==>ProgressBarUpdate

Func ProgressBarInit()
	$iCurrentNbrTask = 0
	Dim $oProgressBar
	GUICtrlSetData($oProgressBar, 0)
EndFunc   ;==>ProgressBarInit

Func CreateKPRMDir()
	Local Const $sDir = @HomeDrive & "\KPRM"

	If Not FileExists($sDir) Then
		DirCreate($sDir)
	EndIf

	If Not FileExists($sDir) Then
		MsgBox(16, $lFail, $lRegistryBackupError)
		Exit
	EndIf
EndFunc   ;==>CreateKPRMDir

Func CountKpRmPass()
	Local Const $sDir = @HomeDrive & "\KPRM"

	Local $aFileList = _FileListToArray($sDir, "kprm-*.txt", $FLTA_FILES)

	If @error <> 0 Then Return 1

	Return $aFileList[0]
EndFunc   ;==>CountKpRmPass

Func Init()
	CreateKPRMDir()
	LogMessage("# Run at " & _Now())
	LogMessage("# KpRm (Kernel-panik) version " & $sKprmVersion)
	LogMessage("# Website https://kernel-panik.me/tool/kprm/")
	LogMessage("# Run by " & @UserName & " from " & @WorkingDir)
	LogMessage("# Computer Name: " & @ComputerName)
	LogMessage("# OS: " & GetHumanVersion() & " " & @OSArch & " (" & @OSBuild & ") " & @OSServicePack)
	LogMessage("# Number of passes: " & CountKpRmPass())

	ProgressBarInit()
EndFunc   ;==>Init

Func UpdateStatusBar($sText)
	Dim $oHStatus

	GUICtrlSetData($oHStatus, $sText)
EndFunc   ;==>UpdateStatusBar

Func SetButtonSearchMode()
	GUICtrlSetState($oRemoveSearchLines, $GUI_HIDE)
	GUICtrlSetState($oSearchLines, $GUI_SHOW)
	GUICtrlSetBkColor($oUnSelectAllSearchLines, $cDisabled)
	GUICtrlSetBkColor($oSelectAllSearchLines, $cDisabled)
	GUICtrlSetBkColor($oClearSearchLines, $cDisabled)
	GUICtrlSetState($oUnSelectAllSearchLines, $GUI_DISABLE)
	GUICtrlSetState($oSelectAllSearchLines, $GUI_DISABLE)
	GUICtrlSetState($oClearSearchLines, $GUI_DISABLE)
	GUICtrlSetState($oSearchLines, $GUI_ENABLE)
EndFunc   ;==>SetButtonSearchMode

Func SetButtonDeleteSearchMode()
	GUICtrlSetState($oRemoveSearchLines, $GUI_SHOW)
	GUICtrlSetState($oRemoveSearchLines, $GUI_ENABLE)
	GUICtrlSetState($oSearchLines, $GUI_HIDE)
	GUICtrlSetBkColor($oUnSelectAllSearchLines, $cBlue)
	GUICtrlSetBkColor($oSelectAllSearchLines, $cBlue)
	GUICtrlSetBkColor($oClearSearchLines, $cBlue)
	GUICtrlSetState($oUnSelectAllSearchLines, $GUI_ENABLE)
	GUICtrlSetState($oSelectAllSearchLines, $GUI_ENABLE)
	GUICtrlSetState($oClearSearchLines, $GUI_ENABLE)
EndFunc   ;==>SetButtonDeleteSearchMode

Func InitGlobalVars()
	Dim $sCurrentTime = @YEAR & @MON & @MDAY & @HOUR & @MIN & @SEC
	Dim $sCurrentHumanTime = @YEAR & '-' & @MON & '-' & @MDAY & '-' & @HOUR & '-' & @MIN & '-' & @SEC
	Dim $sKPLogFile = "kprm-" & $sCurrentTime & ".txt"
	Dim $bRemoveToolLastPass = False
	Dim $bPowerShellAvailable = Null
	Dim $bDeleteQuarantines = Null
	Dim $bSearchOnly = False
	Dim $bSearchOnlyHasFoundElement = False
	Dim $aRemoveRestart = []
	Dim $bNeedRestart = False
	Dim $aElementsToKeep[1][2] = [[]]
	Dim $aElementsFound[1][2] = [[]]

	InitOToolCpt()
	UpdateStatusBar("Ready ...")
	ProgressBarInit()
EndFunc   ;==>InitGlobalVars

Func KpSearch()
	SetButtonSearchMode()

	Dim $bSearchOnly = True
	Dim $bSearchOnlyHasFoundElement = False

	GUICtrlSetState($oSearchLines, $GUI_DISABLE)
	RunRemoveTools()

	If $bSearchOnlyHasFoundElement = True Then
		SetButtonDeleteSearchMode()
	Else
		MsgBox($MB_ICONINFORMATION, $lFinishTitle, $lNoTool)
		SetButtonSearchMode()
	EndIf

EndFunc   ;==>KpSearch

Func KpRemover()
	Local $hGlobalTimer = TimerInit()

	Init()
	ProgressBarUpdate()
	LogMessage(@CRLF & "- Checked options -" & @CRLF)

	If GUICtrlRead($oBackupRegistry) = $GUI_CHECKED Then LogMessage("    ~ Registry Backup")
	If GUICtrlRead($oRemoveTools) = $GUI_CHECKED Then LogMessage("    ~ Delete Tools")
	If GUICtrlRead($oRestoreSystemSettings) = $GUI_CHECKED Then LogMessage("    ~ Restore System Settings")
	If GUICtrlRead($oRestoreUAC) = $GUI_CHECKED Then LogMessage("    ~ UAC Restore")
	If GUICtrlRead($oRemoveRP) = $GUI_CHECKED Then LogMessage("    ~ Delete Restore Points")
	If GUICtrlRead($oCreateRP) = $GUI_CHECKED Then LogMessage("    ~ Create Restore Point")
	If GUICtrlRead($oDeleteQuarantine) = $GUI_CHECKED Then LogMessage("    ~ Delete Quarantines")
	If GUICtrlRead($oDeleteQuarantineAfter7Days) = $GUI_CHECKED Then LogMessage("    ~ Delete Quarantines after 7 days")

	$bDeleteQuarantines = Null

	If GUICtrlRead($oDeleteQuarantine) = $GUI_CHECKED Then
		$bDeleteQuarantines = 1
	ElseIf GUICtrlRead($oDeleteQuarantineAfter7Days) = $GUI_CHECKED Then
		$bDeleteQuarantines = 7
	EndIf

	If GUICtrlRead($oBackupRegistry) = $GUI_CHECKED Then
		CreateBackupRegistry()
	EndIf

	ProgressBarUpdate()

	If GUICtrlRead($oRemoveTools) = $GUI_CHECKED Then
		RunRemoveTools()
		$bRemoveToolLastPass = True
		RunRemoveTools()
	Else
		ProgressBarUpdate(32)
	EndIf

	ProgressBarUpdate()

	If GUICtrlRead($oRestoreSystemSettings) = $GUI_CHECKED Then
		RestoreSystemSettingsByDefault()
	EndIf

	ProgressBarUpdate()

	If GUICtrlRead($oRestoreUAC) = $GUI_CHECKED Then
		RestoreUAC()
	EndIf

	ProgressBarUpdate()

	If GUICtrlRead($oRemoveRP) = $GUI_CHECKED Then
		ClearRestorePoint()
	EndIf

	ProgressBarUpdate()

	If GUICtrlRead($oCreateRP) = $GUI_CHECKED Then
		CreateRestorePoint()
	EndIf

	TimerWriteReport($hGlobalTimer, "KPRM")

	GUICtrlSetData($oProgressBar, 100)

	SetDeleteQuarantinesIn7DaysIfNeeded()
	RestartIfNeeded()
	UpdateStatusBar("Finish")
	MsgBox(64, "OK", $lFinish)

	QuitKprm(True)
EndFunc   ;==>KpRemover

;################################################| Functions end

;################################################| Tools_remove

Func PrepareRemove($sPath, $bRecursive = 0, $sForce = "0")
	Dim $bRemoveToolLastPass

	If $bRemoveToolLastPass = True Or Number($sForce) Then
		_ClearObjectDacl($sPath)
		_GrantAllAccess($sPath)
	EndIf

	ClearAttributes($sPath)
EndFunc   ;==>PrepareRemove

Func IsFileInWhiteList($sFile)
	Local Const $aWhiteList[8] = [ _
			"(?i)MKVPlayerSetup.*\.exe$", _
			"(?i)MKVExtractGUI.*\.exe$", _
			"(?i)mkvpropedit.*\.exe$", _
			"(?i)mkvinfo.*\.exe$", _
			"(?i)mkvextract.*\.exe$", _
			"(?i)mkvmerge.*\.exe$", _
			"(?i)mkvtoolnix.*\.exe$", _
			"(?i)MkvToMp4.*\.exe$"]

	Local $bInWhiteList = False

	For $i = 0 To UBound($aWhiteList) - 1
		If StringRegExp($sFile, $aWhiteList[$i]) Then
			$bInWhiteList = True
			ExitLoop
		EndIf
	Next

	Return $bInWhiteList
EndFunc   ;==>IsFileInWhiteList

Func IsProcessInWhiteList($sProcess)
	Local Const $aWhiteList[3] = ["(?i)^sftvsa.exe$", "(?i)^sftlist.exe$", "(?i)^SftService.exe$"]
	Local $bInWhiteList = False

	For $i = 0 To UBound($aWhiteList) - 1
		If StringRegExp($sProcess, $aWhiteList[$i]) Then
			$bInWhiteList = True
			ExitLoop
		EndIf
	Next

	Return $bInWhiteList
EndFunc   ;==>IsProcessInWhiteList

Func RemoveFile($sFile, $sToolKey, $sDescriptionPattern = Null, $sForce = "0")
	Dim $bSearchOnly

	Local Const $iFileExists = IsFile($sFile)

	If $iFileExists And IsFileInWhiteList($sFile) = False Then
		If $sDescriptionPattern And StringRegExp($sFile, "(?i)\.(exe|com)$") Then
			Local Const $sCompanyName = FileGetVersion($sFile, "CompanyName")

			If @error Or Not StringRegExp($sCompanyName, $sDescriptionPattern) Then
				Return False
			EndIf
		EndIf

		If $bSearchOnly = False Then
			UpdateStatusBar("Remove file " & $sFile)
			UpdateToolCpt($sToolKey, 'element', $sFile)
			PrepareRemove($sFile, 0, $sForce)
			FileDelete($sFile)
		Else
			UpdateStatusBar("File " & $sFile & " found")
			AddToSearch($sFile, $sToolKey)
		EndIf
	EndIf
EndFunc   ;==>RemoveFile

Func RemoveFolder($sPath, $sToolKey, $sForce = "0", $sQuarantine = "0")
	Dim $bDeleteQuarantines
	Dim $bSearchOnly

	Local $iFileExists = IsDir($sPath)

	If $iFileExists Then
		If $bSearchOnly = True Then
			AddToSearch($sPath, $sToolKey)
			UpdateStatusBar("Folder " & $sPath & " found")
			Return
		EndIf

		Local $bIsQuarantine = False

		If $sQuarantine = "1" Then
			$bIsQuarantine = True

			If $bDeleteQuarantines = Null Then
				AddElementToKeep($sPath, $sToolKey)
				Return
			EndIf
		EndIf

		If $bIsQuarantine = False Or $bDeleteQuarantines = 1 Then
			UpdateToolCpt($sToolKey, 'element', $sPath)
			PrepareRemove($sPath, 1, $sForce)
			UpdateStatusBar("Remove folder " & $sPath)
			DirRemove($sPath, $DIR_REMOVE)
		ElseIf $bDeleteQuarantines = 7 Then
			AddElementToKeep($sPath, $sToolKey)
		EndIf
	EndIf
EndFunc   ;==>RemoveFolder

Func FindInPath($sPath, $sFile, $sReg)
	Local Const $sFilePathGlob = $sPath & "\" & $sFile
	Local Const $hSearch = FileFindFirstFile($sFilePathGlob)
	Local $aReturn = []

	If $hSearch = -1 Then
		Return $aReturn
	EndIf

	Local $sFileName = FileFindNextFile($hSearch)

	While @error = 0
		If StringRegExp($sFileName, $sReg) Then
			_ArrayAdd($aReturn, $sPath & "\" & $sFileName)
		EndIf

		$sFileName = FileFindNextFile($hSearch)
	WEnd

	FileClose($hSearch)

	Return $aReturn
EndFunc   ;==>FindInPath

Func RemoveFileHandler($sPathOfFile, Const ByRef $aElements)
	Local $sTypeOfFile = FileExistsAndGetType($sPathOfFile)

	If $sTypeOfFile = Null Then
		Return Null
	EndIf

	Local $sDrive = "", $sDir = "", $sFileName = "", $sExtension = ""
	Local $aPathSplit = _PathSplit($sPathOfFile, $sDrive, $sDir, $sFileName, $sExtension)
	Local $sFile = $sFileName & $sExtension

	For $e = 0 To UBound($aElements) - 1
		If $aElements[$e][3] And $sTypeOfFile = $aElements[$e][1] And StringRegExp($sFile, $aElements[$e][3]) Then
			If $sTypeOfFile = 'file' Then
				RemoveFile($sPathOfFile, $aElements[$e][0], $aElements[$e][2], $aElements[$e][4])
			ElseIf $sTypeOfFile = 'folder' Then
				RemoveFolder($sPathOfFile, $aElements[$e][0], $aElements[$e][4], $aElements[$e][5])
			EndIf
		EndIf
	Next
EndFunc   ;==>RemoveFileHandler

Func RemoveAllFileFromWithMaxDepth($sPath, Const ByRef $aElements, $iDetpth = -2)
	Local $aArray = _FileListToArrayRec($sPath, "*.exe;*.txt;*.lnk;*.log;*.reg;*.zip;*.dat;*.scr;*.com;*.bat;*.mbr;*.iso;*.pif", $FLTAR_FILESFOLDERS, $iDetpth, $FLTAR_NOSORT, $FLTAR_FULLPATH)

	If @error <> 0 Then
		Return Null
	EndIf

	For $i = 1 To $aArray[0]
		RemoveFileHandler($aArray[$i], $aElements)
	Next
EndFunc   ;==>RemoveAllFileFromWithMaxDepth

Func RemoveAllFileFrom($sPath, $aElements)
	Local Const $sFilePathGlob = $sPath & "\*"
	Local Const $hSearch = FileFindFirstFile($sFilePathGlob)

	If $hSearch = -1 Then
		Return Null
	EndIf

	Local $sFileName = FileFindNextFile($hSearch)

	While @error = 0
		Local $sPathOfFile = $sPath & "\" & $sFileName
		RemoveFileHandler($sPathOfFile, $aElements)
		$sFileName = FileFindNextFile($hSearch)
	WEnd

	FileClose($hSearch)

EndFunc   ;==>RemoveAllFileFrom

Func RemoveRegistryKey($key, $sToolKey, $sForce = "0")
	Dim $bRemoveToolLastPass
	Dim $bSearchOnly

	If $bSearchOnly = True Then
		UpdateStatusBar("Registry key " & $key & " found")
		AddToSearch($key, $sToolKey)
		Return
	EndIf

	If $bRemoveToolLastPass = True Or Number($sForce) Then
		_ClearObjectDacl($key)
		_GrantAllAccess($key, $SE_REGISTRY_KEY)
	EndIf

	UpdateStatusBar("Remove registry key " & $key)

	Local Const $iStatus = RegDelete($key)

	If $iStatus <> 0 Then
		UpdateToolCpt($sToolKey, "key", $key)
	EndIf
EndFunc   ;==>RemoveRegistryKey

Func CloseUnEssentialProcess()
	Local Const $aProcess[1] = ["notepad.exe"]

	For $i = 0 To UBound($aProcess) - 1
		If 0 = ProcessExists($aProcess[$i]) Then ContinueLoop
		ProcessClose($aProcess[$i])
	Next
EndFunc   ;==>CloseUnEssentialProcess

Func CloseProcessAndWait($sProcess, $sProcessName, $sForce = "0")
	Dim $bRemoveToolLastPass

	Local $iCpt = 50

	If 0 = ProcessExists($sProcess) Then Return False

	If $bRemoveToolLastPass = True Or Number($sForce) Then
		_Permissions_KillProcess($sProcess)

		If 0 = ProcessExists($sProcess) Then Return True
	EndIf

	UpdateStatusBar("Close process " & $sProcessName)

	ProcessClose($sProcess)

	Do
		$iCpt -= 1
		Sleep(250)
	Until ($iCpt = 0 Or 0 = ProcessExists($sProcess))
EndFunc   ;==>CloseProcessAndWait

Func RemoveAllProcess(Const ByRef $aList)
	Dim $bSearchOnly
	Local $aProcessList = ProcessList()

	For $i = 1 To $aProcessList[0][0]
		Local $sProcessName = $aProcessList[$i][0]
		Local $iPid = $aProcessList[$i][1]

		For $iCpt = 0 To UBound($aList) - 1
			If IsProcessInWhiteList($sProcessName) = False And StringRegExp($sProcessName, $aList[$iCpt][1]) Then
				Local $sProcessPath = _WinAPI_GetProcessFileName($iPid)
				If @error <> 0 Then ContinueLoop
				If Not IsFile($sProcessPath) Then ContinueLoop

				If $aList[$iCpt][2] <> "" Then
					Local $sCompanyNamePattern = $aList[$iCpt][2]
					Local $sCompanyName = FileGetVersion($sProcessPath, "CompanyName")

					If @error Or Not StringRegExp($sCompanyName, $sCompanyNamePattern) Then
						ContinueLoop
					EndIf
				EndIf

				If $bSearchOnly = True Then
					UpdateStatusBar("Process " & $sProcessName & " found")
					AddToSearch($sProcessPath, $aList[$iCpt][0])
					ContinueLoop
				EndIf

				CloseProcessAndWait($iPid, $sProcessName, $aList[$iCpt][3])
				UpdateToolCpt($aList[$iCpt][0], "process", $sProcessName)
			EndIf
		Next
	Next
EndFunc   ;==>RemoveAllProcess

Func RemoveScheduleTask(Const ByRef $aList)
	For $i = 0 To UBound($aList) - 1
		UpdateStatusBar("Remove schedule task " & $aList[$i][1])
		RunWait('schtasks.exe /delete /tn "' & $aList[$i][1] & '" /f', "", @SW_HIDE)
	Next
EndFunc   ;==>RemoveScheduleTask

Func UninstallNormally(Const ByRef $aList)
	Dim $bSearchOnly
	Local Const $aProgramFilesList = GetProgramFilesList()

	For $i = 0 To UBound($aProgramFilesList) - 1
		For $c = 0 To UBound($aList) - 1
			Local $sFolderReg = $aList[$c][1]
			Local $sFileReg = $aList[$c][2]

			Local $aGlobFolder = FindInPath($aProgramFilesList[$i], "*", $sFolderReg)

			For $f = 1 To UBound($aGlobFolder) - 1
				Local $aUninstallFiles = FindInPath($aGlobFolder[$f], "*", $sFileReg)

				For $u = 1 To UBound($aUninstallFiles) - 1
					If IsFile($aUninstallFiles[$u]) Then
						UpdateStatusBar("Uninstall " & $aUninstallFiles[$u])

						If $bSearchOnly = False Then
							RunWait($aUninstallFiles[$u])
							UpdateToolCpt($aList[$c][0], "uninstall", $aUninstallFiles[$u])
						Else
							AddToSearch($aGlobFolder[$f], $aList[$c][0])
						EndIf
					EndIf
				Next
			Next
		Next
	Next
EndFunc   ;==>UninstallNormally

Func RemoveAllProgramFilesDir(Const ByRef $aList)
	Local Const $aProgramFilesList = GetProgramFilesList()

	For $i = 0 To UBound($aProgramFilesList) - 1
		RemoveAllFileFrom($aProgramFilesList[$i], $aList)
	Next
EndFunc   ;==>RemoveAllProgramFilesDir

Func RemoveAllSoftwareKeyList(Const ByRef $aList)
	Local $s64Bit = GetSuffixKey()
	Local $aKeys[2] = ["HKCU" & $s64Bit & "\SOFTWARE", "HKLM" & $s64Bit & "\SOFTWARE"]

	For $k = 0 To UBound($aKeys) - 1
		Local $i = 0

		While True
			$i += 1
			Local $sEntry = RegEnumKey($aKeys[$k], $i)

			If @error <> 0 Then ExitLoop

			For $c = 0 To UBound($aList) - 1
				If $sEntry And $aList[$c][1] Then
					If StringRegExp($sEntry, $aList[$c][1]) Then
						Local $sKeyFound = $aKeys[$k] & "\" & $sEntry
						RemoveRegistryKey($sKeyFound, $aList[$c][0])
					EndIf
				EndIf
			Next
		WEnd
	Next
EndFunc   ;==>RemoveAllSoftwareKeyList

Func RemoveUninstallStringWithSearch(Const ByRef $aList)
	For $i = 1 To UBound($aList) - 1
		Local $sKey = FormatForUseRegistryKey($aList[$i][1])
		Local $sKeyFound = SearchRegistryKeyStrings($sKey, $aList[$i][2], $aList[$i][3])

		If $sKeyFound And $sKeyFound <> "" Then
			RemoveRegistryKey($sKeyFound, $aList[$i][0])
		EndIf
	Next
EndFunc   ;==>RemoveUninstallStringWithSearch

Func RemoveAllRegistryKeys(Const ByRef $aList)
	For $i = 0 To UBound($aList) - 1
		Local $sKey = FormatForUseRegistryKey($aList[$i][1])

		RegEnumVal($sKey, "1")

		If @error = 0 Then
			RemoveRegistryKey($sKey, $aList[$i][0], $aList[$i][2])
		EndIf
	Next
EndFunc   ;==>RemoveAllRegistryKeys

Func CleanDirectoryContent(Const ByRef $aList)
	Dim $bDeleteQuarantines
	Dim $bSearchOnly

	For $i = 0 To UBound($aList) - 1
		Local $sPath = FormatPathWithMacro($aList[$i][1])

		If FileExists($sPath) Then
			Local $bIsQuarantine = False

			If $aList[$i][4] = "1" Then
				$bIsQuarantine = True

				If $bDeleteQuarantines = Null And $bSearchOnly = False Then
					AddElementToKeep($sPath, $aList[$i][0])
					ContinueLoop
				EndIf
			EndIf

			Local $aFileList = _FileListToArray($sPath)

			If @error = 0 Then
				For $f = 1 To $aFileList[0]
					If $bSearchOnly = False Then
						If $bIsQuarantine = False Or $bDeleteQuarantines = 1 Then
							RemoveFile($sPath & '\' & $aFileList[$f], $aList[$i][0], $aList[$i][2], $aList[$i][3])
						ElseIf $bDeleteQuarantines = 7 Then
							AddElementToKeep($sPath & '\' & $aFileList[$f], $aList[$i][0])
						EndIf
					Else
						AddToSearch($sPath & '\' & $aFileList[$f], $aList[$i][0])
					EndIf
				Next
			EndIf
		EndIf
	Next
EndFunc   ;==>CleanDirectoryContent

Func RemoveFileCustomPath(Const ByRef $aList)
	For $i = 0 To UBound($aList) - 1
		Local $sPath = FormatPathWithMacro($aList[$i][1])
		RemoveFile($sPath, $aList[$i][0], $aList[$i][2], $aList[$i][3])
	Next
EndFunc   ;==>RemoveFileCustomPath

Func RemoveFolderCustomPath(Const ByRef $aList)
	For $i = 0 To UBound($aList) - 1
		Local $sPath = FormatPathWithMacro($aList[$i][1])
		RemoveFolder($sPath, $aList[$i][0], $aList[$i][2], $aList[$i][3])
	Next
EndFunc   ;==>RemoveFolderCustomPath

;################################################| Tools_remove End

;################################################[ Tools_import


Func GetSwapOrder(ByRef $sT)
	If _ArraySearch($aActionsFile, $sT) <> -1 Then
		Local $aOrder[5][2] = [["type", "file"], ["companyName", ""], ["pattern", "__REQUIRED__"], ["force", "0"], ["quarantine", "0"]]
		Return $aOrder
	ElseIf $sT = "uninstall" Then
		Local $aOrder[2][2] = [["folder", "__REQUIRED__"], ["uninstaller", "__REQUIRED__"]]
		Return $aOrder
	ElseIf $sT = "task" Then
		Local $aOrder[1][2] = [["name", "__REQUIRED__"]]
		Return $aOrder
	ElseIf $sT = "softwareKey" Then
		Local $aOrder[1][2] = [["pattern", "__REQUIRED__"]]
		Return $aOrder
	ElseIf $sT = "process" Then
		Local $aOrder[3][2] = [["process", "__REQUIRED__"], ["companyName", ""], ["force", "0"]]
		Return $aOrder
	ElseIf $sT = "registryKey" Then
		Local $aOrder[2][2] = [["key", "__REQUIRED__"], ["force", "0"]]
		Return $aOrder
	ElseIf $sT = "searchRegistryKey" Then
		Local $aOrder[3][2] = [["key", "__REQUIRED__"], ["pattern", "__REQUIRED__"], ["value", "__REQUIRED__"]]
		Return $aOrder
	ElseIf $sT = "cleanDirectory" Then
		Local $aOrder[4][2] = [["path", "__REQUIRED__"], ["companyName", ""], ["force", "0"], ["quarantine", "0"]]
		Return $aOrder
	ElseIf $sT = "file" Then
		Local $aOrder[3][2] = [["path", "__REQUIRED__"], ["companyName", ""], ["force", "0"]]
		Return $aOrder
	ElseIf $sT = "folder" Then
		Local $aOrder[3][2] = [["path", "__REQUIRED__"], ["force", "0"], ["quarantine", "0"]]
		Return $aOrder
	EndIf
EndFunc   ;==>GetSwapOrder

Func Swap($sTn, $aK, $aV, $aOrder)
	Local $sData = $sTn & "~~"
	Local $iLength = 0
	Local $iCountOrder = UBound($aOrder)

	For $i = 0 To $iCountOrder - 1
		Local $bFound = False

		For $c = 0 To UBound($aK) - 1
			If $aOrder[$i][0] = $aK[$c] Then
				$sData &= $aV[$c] & "~~"
				$bFound = True
				$iLength += 1
			EndIf
		Next

		If $bFound = False Then
			Local $sDefaultValue = $aOrder[$i][1]

			If $sDefaultValue = "__REQUIRED__" Then
				MsgBox(16, "Fail", "Attribute " & $aOrder[$i][0] & " for tool " & $sTn & " is required")
				Exit
			EndIf

			$sData &= $sDefaultValue & "~~"
			$iLength += 1
		EndIf
	Next

	If $iLength <> $iCountOrder Then
		MsgBox(16, "Fail", "Values for tool " & $sTn & " are invalid ! Number of expected values " & $iLength & " and number of values received " & $iCountOrder)
		Exit
	EndIf

	$sData = StringTrimRight($sData, 2)

	Return $sData
EndFunc   ;==>Swap

Func InitOToolCpt()
	Dim $oToolsCpt

	$oToolsCpt = ObjCreate("Scripting.Dictionary")

	Local $aNodes = _XMLSelectNodes("/tools/tool")

	For $i = 1 To $aNodes[0]
		Local $sToolName = _XMLGetAttrib("/tools/tool[" & $i & "]", "name")
		Local $oToolsValue = ObjCreate("Scripting.Dictionary")
		Local $oToolsValueKey = ObjCreate("Scripting.Dictionary")
		Local $oToolsValueFile = ObjCreate("Scripting.Dictionary")
		Local $oToolsValueUninstall = ObjCreate("Scripting.Dictionary")
		Local $oToolsValueProcess = ObjCreate("Scripting.Dictionary")

		$oToolsValue.add("key", $oToolsValueKey)
		$oToolsValue.add("element", $oToolsValueFile)
		$oToolsValue.add("uninstall", $oToolsValueUninstall)
		$oToolsValue.add("process", $oToolsValueProcess)
		$oToolsCpt.add($sToolName, $oToolsValue)
	Next
EndFunc   ;==>InitOToolCpt

Func GenerateDeleteReport()
	Dim $bDeleteQuarantines
	Dim $bRemoveToolLastPass
	Dim $aElementsToKeep
	Dim $bRemoveToolLastPass

	If $bRemoveToolLastPass = True Then
		Local Const $aToolCptSubKeys[4] = ["process", "uninstall", "element", "key"]
		Local $bHasFoundTools = False

		For $sToolsCptKey In $oToolsCpt
			Local $oToolCptTool = $oToolsCpt.Item($sToolsCptKey)
			Local $bToolExistDisplayMessage = False

			For $sToolCptSubKeyI = 0 To UBound($aToolCptSubKeys) - 1
				Local $sToolCptSubKey = $aToolCptSubKeys[$sToolCptSubKeyI]
				Local $oToolCptSubTool = $oToolCptTool.Item($sToolCptSubKey)
				Local $oToolCptSubToolKeys = $oToolCptSubTool.Keys

				If UBound($oToolCptSubToolKeys) > 0 Then
					$bHasFoundTools = True
					If $bToolExistDisplayMessage = False Then
						$bToolExistDisplayMessage = True
						LogMessage(@CRLF & "  ## " & $sToolsCptKey)
					EndIf

					For $oToolCptSubToolKeyI = 0 To UBound($oToolCptSubToolKeys) - 1
						Local $oToolCptSubToolKey = $oToolCptSubToolKeys[$oToolCptSubToolKeyI]
						Local $oToolCptSubToolVal = $oToolCptSubTool.Item($oToolCptSubToolKey)
						CheckIfExist($sToolCptSubKey, $oToolCptSubToolKey, $oToolCptSubToolVal)
					Next
				EndIf
			Next
		Next

		If $bHasFoundTools = False Then
			LogMessage("     [I] No tools found")
		EndIf

		Local Const $bToolZhpQuarantineExist = IsDir(@AppDataDir & "\ZHP")
		Local Const $bHasElementToKeep = UBound($aElementsToKeep) > 1
		Local Const $bUseOtherLinesSection = $bToolZhpQuarantineExist = True Or $bHasElementToKeep = True

		If $bUseOtherLinesSection = True Then
			LogMessage(@CRLF & "- Other Lines -" & @CRLF)
		EndIf

		If $bToolZhpQuarantineExist = True Then
			LogMessage(@CRLF & "  ## Quarantines never deleted")
			LogMessage("    ~ " & @AppDataDir & "\ZHP (ZHP)")
		EndIf

		If $bHasElementToKeep = True Then
			If $bDeleteQuarantines = Null Then
				LogMessage(@CRLF & "  ## Quarantines keeped")

			ElseIf $bDeleteQuarantines = 7 Then
				LogMessage(@CRLF & "  ## Quarantines that will be deleted in 7 days (" & _DateAdd('d', 7, _NowCalcDate()) & ")")
			EndIf

			_ArraySort($aElementsToKeep, 0, 0, 0, 1)

			For $i = 1 To UBound($aElementsToKeep) - 1
				LogMessage("    ~ " & $aElementsToKeep[$i][0] & " (" & $aElementsToKeep[$i][1] & ")")
			Next
		EndIf
	EndIf
EndFunc   ;==>GenerateDeleteReport


Func RunRemoveTools()
	Dim $bRemoveToolLastPass
	Dim $bSearchOnly

	If $bRemoveToolLastPass = True Then
		LogMessage(@CRLF & "- Delete Tools -" & @CRLF)
	EndIf

	Local Const $aListActions = [ _
			"process", _
			"uninstall", _
			"task", _
			"desktop", _
			"desktopCommon", _
			"download", _
			"programFiles", _
			"homeDrive", _
			"appData", _
			"appDataCommon", _
			"appDataLocal", _
			"windowsFolder", _
			"softwareKey", _
			"registryKey", _
			"searchRegistryKey", _
			"startMenu", _
			"cleanDirectory", _
			"file", _
			"folder"]

	Local $aNodes = _XMLSelectNodes("/tools/tool")

	CloseUnEssentialProcess()

	For $n = 0 To UBound($aListActions) - 1
		Local $sAction = $aListActions[$n]
		Local $aOrder = GetSwapOrder($sAction)
		Local $aListTasks[0][UBound($aOrder) + 1]

		For $i = 1 To $aNodes[0]
			Local $sToolName = _XMLGetAttrib("/tools/tool[" & $i & "]", "name")
			Local $aActions = _XMLSelectNodes("/tools/tool[" & $i & "]/*")

			For $c = 1 To $aActions[0]
				Local $sType = $aActions[$c]

				If $sType = $sAction Then
					Local $aName[1], $aValue[1]
					_XMLGetAllAttrib("/tools/tool[" & $i & "]/*[" & $c & "]", $aName, $aValue)
					Local $sCurrentTask = Swap($sToolName, $aName, $aValue, $aOrder)
					_ArrayAdd($aListTasks, $sCurrentTask, 0, "~~")
				EndIf
			Next
		Next

		Switch $sAction
			Case "process"
				UpdateStatusBar("Search process ...")
				RemoveAllProcess($aListTasks)
			Case "uninstall"
				UpdateStatusBar("Search uninstaller ...")
				UninstallNormally($aListTasks)
			Case "task"
				UpdateStatusBar("Search tasks ...")
				RemoveScheduleTask($aListTasks)
			Case "desktop"
				UpdateStatusBar("Search tools in desktop ...")
				RemoveAllFileFromWithMaxDepth(@DesktopDir, $aListTasks)
			Case "desktopCommon"
				UpdateStatusBar("Search tools in common desktop ...")
				RemoveAllFileFrom(@DesktopCommonDir, $aListTasks)
			Case "download"
				UpdateStatusBar("Search tools in download ...")
				RemoveAllFileFromWithMaxDepth(@UserProfileDir & "\Downloads", $aListTasks)
			Case "programFiles"
				UpdateStatusBar("Search tools in Program files ...")
				RemoveAllProgramFilesDir($aListTasks)
			Case "homeDrive"
				UpdateStatusBar("Search tools in home drive ...")
				RemoveAllFileFrom(@HomeDrive, $aListTasks)
			Case "appDataCommon"
				UpdateStatusBar("Search tools in AppData ...")
				RemoveAllFileFrom(@AppDataCommonDir, $aListTasks)
			Case "appDataLocal"
				UpdateStatusBar("Search tools in AppLocalData ...")
				RemoveAllFileFrom(@LocalAppDataDir, $aListTasks)
			Case "windowsFolder"
				UpdateStatusBar("Search tools in Windows ...")
				RemoveAllFileFrom(@WindowsDir, $aListTasks)
			Case "softwareKey"
				UpdateStatusBar("Search software keys ...")
				RemoveAllSoftwareKeyList($aListTasks)
			Case "registryKey"
				UpdateStatusBar("Search tools in registry ...")
				RemoveAllRegistryKeys($aListTasks)
			Case "searchRegistryKey"
				UpdateStatusBar("Specific search in registry ...")
				RemoveUninstallStringWithSearch($aListTasks)
			Case "startMenu"
				UpdateStatusBar("Search tools in start menu ...")
				RemoveAllFileFrom(@AppDataCommonDir & "\Microsoft\Windows\Start Menu\Programs", $aListTasks)
			Case "cleanDirectory"
				UpdateStatusBar("Search tools in specific directory ...")
				CleanDirectoryContent($aListTasks)
			Case "file"
				UpdateStatusBar("Search specific files ...")
				RemoveFileCustomPath($aListTasks)
			Case "folder"
				UpdateStatusBar("Search specific directory ...")
				RemoveFolderCustomPath($aListTasks)
		EndSwitch

		Local $iStepProgress = 1

		If $bSearchOnly = True Then
			$iStepProgress = 2
		EndIf

		ProgressBarUpdate($iStepProgress)
	Next

	If $bSearchOnly = True Then
		ProgressBarUpdate(50)
		UpdateStatusBar("Finish ...")
		SetSearchList()
		Return
	EndIf

	GenerateDeleteReport()
	ProgressBarUpdate()

EndFunc   ;==>RunRemoveTools

;################################################| Tools_import End

;################################################[ Restore_System_Settings

Func RestoreSystemSettingsByDefault()
	LogMessage(@CRLF & "- Restore System Settings -" & @CRLF)

	UpdateStatusBar("Restore system settings ...")

	Local $aCommands[8]

	$aCommands[0] = "netsh winsock reset"
	$aCommands[1] = "netsh winhttp reset proxy"
	$aCommands[2] = "netsh winhttp reset tracing"
	$aCommands[3] = "netsh winsock reset catalog"
	$aCommands[4] = "netsh int ip reset all"
	$aCommands[5] = "netsh int ipv4 reset catalog"
	$aCommands[6] = "netsh int ipv6 reset catalog"
	$aCommands[7] = "ipconfig /flushdns"

	For $sCommands In $aCommands
		RunWait(@ComSpec & " /c" & $sCommands, '', @SW_HIDE)
	Next

	LogMessage("     [OK] Reset WinSock" & @CRLF & "     [OK] FLUSHDNS")

	Local $s64Bit = GetSuffixKey()
	Local $sRegvar = "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced"

	If RegWrite($sRegvar, "Hidden", "REG_DWORD", "2") Then
		LogMessage("     [OK] Hide Hidden file.")
	Else
		LogMessage("     [X] Hide Hidden File")
	EndIf

	If RegWrite($sRegvar, "HideFileExt", "REG_DWORD", "0") Then
		LogMessage("     [OK] Show Extensions for known file types")
	Else
		LogMessage("     [X] Show Extensions for known file types")
	EndIf

	If RegWrite($sRegvar, "ShowSuperHidden", "REG_DWORD", "0") Then
		LogMessage("     [OK] Hide protected operating system files")
	Else
		LogMessage("     [X] Hide protected operating system files")
	EndIf

	_Restart_Windows_Explorer()

EndFunc   ;==>RestoreSystemSettingsByDefault

;################################################| Restore_System_Settings Fin

;################################################| Restore_UAC

Func RestoreUAC()
	LogMessage(@CRLF & "- Restore UAC -" & @CRLF)

	UpdateStatusBar("Restore UAC ...")

	If _UAC_SetConsentPromptBehaviorAdmin() Then
		LogMessage("     [OK] Set ConsentPromptBehaviorAdmin with default (5) value")
	Else
		LogMessage("     [X] Set ConsentPromptBehaviorAdmin with default value")
	EndIf

	If _UAC_SetConsentPromptBehaviorUser(3) Then
		LogMessage("     [OK] Set ConsentPromptBehaviorUser with default (3) value")
	Else
		LogMessage("     [X] Set ConsentPromptBehaviorUser with default value")
	EndIf

	If _UAC_SetEnableInstallerDetection() Then
		LogMessage("     [OK] Set EnableInstallerDetection with default (0) value")
	Else
		LogMessage("     [X] Set EnableInstallerDetection with default value")
	EndIf

	If _UAC_SetEnableLUA() Then
		LogMessage("     [OK] Set EnableLUA with default (1) value")
	Else
		LogMessage("     [X] Set EnableLUA with default value")
	EndIf

	If _UAC_SetEnableSecureUIAPaths() Then
		LogMessage("     [OK] Set EnableSecureUIAPaths with default (1) value")
	Else
		LogMessage("     [X] Set EnableSecureUIAPaths with default value")
	EndIf

	If _UAC_SetEnableUIADesktopToggle() Then
		LogMessage("     [OK] Set EnableUIADesktopToggle with default (0) value")
	Else
		LogMessage("     [X] Set EnableUIADesktopToggle with default value")
	EndIf

	If _UAC_SetEnableVirtualization() Then
		LogMessage("     [OK] Set EnableVirtualization with default (1) value")
	Else
		LogMessage("     [X] Set EnableVirtualization with default value")
	EndIf

	If _UAC_SetFilterAdministratorToken() Then
		LogMessage("     [OK] Set FilterAdministratorToken with default (0) value")
	Else
		LogMessage("     [X] Set FilterAdministratorToken with default value")
	EndIf

	If _UAC_SetPromptOnSecureDesktop() Then
		LogMessage("     [OK] Set PromptOnSecureDesktop with default (1) value")
	Else
		LogMessage("     [X] Set PromptOnSecureDesktop with default value")
	EndIf

	If _UAC_SetValidateAdminCodeSignatures() Then
		LogMessage("     [OK] Set ValidateAdminCodeSignatures with default (0) value")
	Else
		LogMessage("     [X] Set ValidateAdminCodeSignatures with default value")
	EndIf
EndFunc   ;==>RestoreUAC

;################################################| Restore_UAC Fin

;################################################| Registry_Hobocopy

Func CreateBackupRegistryHobocopy($aAllHives)
	Dim $sTmpDir
	Dim $lFail
	Dim $lRegistryBackupError
	Dim $sCurrentHumanTime

	UpdateStatusBar("Create Registry Backup in another way ...")

	Local Const $sRegistryTmp = $sTmpDir & "\registry"
	Local Const $sBackUpPath = @HomeDrive & "\KPRM\backup\" & $sCurrentHumanTime

	If Not FileExists($sRegistryTmp) Then
		DirCreate($sRegistryTmp)
	EndIf

	If Not FileExists($sBackUpPath) Then
		DirCreate($sBackUpPath)
	EndIf

	; https://github.com/candera/hobocopy

	If @OSArch = "X64" Then
		FileInstall(".\binaries\hobocopy64\HoboCopy.exe", $sTmpDir & "\registry\HoboCopy.exe", 1)
		FileInstall(".\binaries\hobocopy64\msvcp100.dll", $sTmpDir & "\registry\msvcp100.dll", 1)
		FileInstall(".\binaries\hobocopy64\msvcr100.dll", $sTmpDir & "\registry\msvcr100.dll", 1)
	Else
		FileInstall(".\binaries\hobocopy32\HoboCopy.exe", $sTmpDir & "\registry\HoboCopy.exe", 1)
		FileInstall(".\binaries\hobocopy32\msvcp100.dll", $sTmpDir & "\registry\msvcp100.dll", 1)
		FileInstall(".\binaries\hobocopy32\msvcr100.dll", $sTmpDir & "\registry\msvcr100.dll", 1)
	EndIf

	If Not FileExists($sBackUpPath) _
			Or Not FileExists($sTmpDir & "\registry\HoboCopy.exe") _
			Or Not FileExists($sTmpDir & "\registry\msvcp100.dll") _
			Or Not FileExists($sTmpDir & "\registry\msvcr100.dll") Then
		MsgBox(16, $lFail, $lRegistryBackupError)
		QuitKprm(False, False)
	EndIf

	If @AutoItX64 = 0 Then _WinAPI_Wow64EnableWow64FsRedirection(False)

	For $i = 0 To UBound($aAllHives) - 1
		Local $sHive = $aAllHives[$i][0]
		Local $sBackupHivePath = $aAllHives[$i][1]

		If Not FileExists($sBackupHivePath) Then
			DirCreate($sBackupHivePath)
		EndIf

		Local $sDrive = "", $sDir = "", $sFileName = "", $sExtension = ""
		Local $aPathSplit = _PathSplit($sHive, $sDrive, $sDir, $sFileName, $sExtension)
		Local $sHiveFile = $sFileName & $sExtension
		$sDir = StringRegExpReplace($sDir, "\\$", "")
		Local $sBackupFile = $sBackUpPath & '\' & $sDir & '\' & $sHiveFile
		Local $sHivePath = $sDrive & $sDir

		If Not FileExists($sBackupFile) Then
			UpdateStatusBar("Backup registry  " & $sHive)

			RunWait(@ComSpec & ' /c HoboCopy.exe "' & $sHivePath & '" "' & $sBackupHivePath & '" ' & $sHiveFile, $sRegistryTmp, @SW_HIDE)

			Sleep(1000)

			If Not FileExists($sBackupFile) Then
				MsgBox(16, $lFail, $lRegistryBackupError & @CRLF & $sHive)
				LogMessage("     [X] Failed Registry Backup: " & $sHive)
				QuitKprm(False)
			Else
				ClearAttributes($sBackupFile)
				LogMessage("   ~ [OK] Hive " & $sHive & " backed up")
			EndIf
		EndIf
	Next
	LogMessage(@CRLF & "     [OK] Registry Backup: " & $sBackUpPath)
EndFunc   ;==>CreateBackupRegistryHobocopy

;################################################| Registry_Hobocopy End

;################################################| Restore_Points

Func SR_WMIDateStringToDate($dtmDate)
	Return _
			(StringMid($dtmDate, 5, 2) & "/" & _
			StringMid($dtmDate, 7, 2) & "/" & _
			StringLeft($dtmDate, 4) & " " & _
			StringMid($dtmDate, 9, 2) & ":" & _
			StringMid($dtmDate, 11, 2) & ":" & _
			StringMid($dtmDate, 13, 2))
EndFunc   ;==>SR_WMIDateStringToDate

Func SR_EnumRestorePointsPowershell()
	Local $aRestorePoints[1][3], $iCounter = 0
	$aRestorePoints[0][0] = $iCounter
	Local $sOutput
	Local $aRP[0]
	Local $bStart = False

	If PowershellIsAvailable() = False Then
		Return $aRestorePoints
	EndIf

	Local $iPid = Run('Powershell.exe -Command "$date = @{Expression={$_.ConvertToDateTime($_.CreationTime)}}; Get-ComputerRestorePoint | Select-Object -Property SequenceNumber, Description, $date"', @SystemDir, @SW_HIDE, $STDOUT_CHILD)

	While 1
		$sOutput &= StdoutRead($iPid)
		If @error Then ExitLoop
	WEnd

	Local $aTmp = StringSplit($sOutput, @CRLF)

	For $i = 1 To $aTmp[0]
		Local $sRow = StringStripWS($aTmp[$i], $STR_STRIPLEADING + $STR_STRIPTRAILING + $STR_STRIPSPACES)

		If $sRow = "" Then ContinueLoop

		If StringInStr($sRow, "-----") Then
			$bStart = True
		ElseIf $bStart = True Then
			_ArrayAdd($aRP, $sRow)
		EndIf
	Next

	For $i = 0 To UBound($aRP) - 1
		Local $sRow = $aRP[$i]
		Local $aRow = StringSplit($sRow, " ")
		Local $iNbr = $aRow[0]

		If $iNbr >= 4 Then
			Local $sTime = StringStripWS(_ArrayPop($aRow), $STR_STRIPLEADING + $STR_STRIPTRAILING + $STR_STRIPSPACES)
			Local $sDate = StringStripWS(_ArrayPop($aRow), $STR_STRIPLEADING + $STR_STRIPTRAILING + $STR_STRIPSPACES)
			Local $iSequence = Number(StringStripWS($aRow[1], $STR_STRIPLEADING + $STR_STRIPTRAILING + $STR_STRIPSPACES))

			$sDate = StringReplace($sDate, '.', '/')
			$sDate = StringReplace($sDate, '-', '/')

			_ArrayDelete($aRow, 0)
			_ArrayDelete($aRow, 0)
			Local $sDescription = _ArrayToString($aRow, " ")
			$sDescription = StringStripWS($sDescription, $STR_STRIPLEADING + $STR_STRIPTRAILING + $STR_STRIPSPACES)

			$iCounter += 1
			ReDim $aRestorePoints[$iCounter + 1][3]
			$aRestorePoints[$iCounter][0] = $iSequence
			$aRestorePoints[$iCounter][1] = $sDescription
			$aRestorePoints[$iCounter][2] = $sDate & " " & $sTime
		EndIf
	Next

	$aRestorePoints[0][0] = $iCounter

	Return $aRestorePoints
EndFunc   ;==>SR_EnumRestorePointsPowershell

Func SR_EnumRestorePoints()
	Dim $__g_oSR_WMI

	Local $aRestorePoints[1][3], $iCounter = 0
	$aRestorePoints[0][0] = $iCounter

	If Not IsObj($__g_oSR_WMI) Then
		$__g_oSR_WMI = ObjGet("winmgmts:root/default")
	EndIf

	If Not IsObj($__g_oSR_WMI) Then
		Return SR_EnumRestorePointsPowershell()
	EndIf

	Local $RPSet = $__g_oSR_WMI.InstancesOf("SystemRestore")

	If Not IsObj($RPSet) Then
		Return SR_EnumRestorePointsPowershell()
	EndIf

	For $rP In $RPSet
		$iCounter += 1
		ReDim $aRestorePoints[$iCounter + 1][3]
		$aRestorePoints[$iCounter][0] = $rP.SequenceNumber
		$aRestorePoints[$iCounter][1] = $rP.Description
		$aRestorePoints[$iCounter][2] = SR_WMIDateStringToDate($rP.CreationTime)
	Next

	$aRestorePoints[0][0] = $iCounter

	Return $aRestorePoints
EndFunc   ;==>SR_EnumRestorePoints

Func SR_Enable($DriveL)
	Dim $__g_oSR

	If Not IsObj($__g_oSR) Then
		$__g_oSR = ObjGet("winmgmts:{impersonationLevel=impersonate}!root/default:SystemRestore")
	EndIf

	If Not IsObj($__g_oSR) Then
		Return 0
	EndIf

	If $__g_oSR.Enable($DriveL) = 0 Then
		Return 1
	EndIf

	Return 0
EndFunc   ;==>SR_Enable

Func EnableRestoration()
	UpdateStatusBar("Enable restoration ...")

	Local $iSR_Enabled = SR_Enable(@HomeDrive & '\')

	If $iSR_Enabled = 0 Then
		If PowershellIsAvailable() = True Then
			RunWait("Powershell.exe -Command  Enable-ComputeRrestore -drive '" & @HomeDrive & "\' | Set-Content -Encoding utf8 ", @ScriptDir, @SW_HIDE)
		EndIf
	EndIf
EndFunc   ;==>EnableRestoration

Func SR_RemoveRestorePoint($rpSeqNumber)
	Local $aRet = DllCall('SrClient.dll', 'DWORD', 'SRRemoveRestorePoint', 'DWORD', $rpSeqNumber)
	If @error Then _
			Return SetError(1, 0, 0)
	If $aRet[0] = 0 Then _
			Return 1
	Return SetError(1, 0, 0)
EndFunc   ;==>SR_RemoveRestorePoint

Func ClearRestorePoint()
	LogMessage(@CRLF & "- Clear Restore Points -" & @CRLF)
	UpdateStatusBar("Clear Restore Points ...")

	Local Const $aRP = SR_EnumRestorePoints()
	Local $iRet = 0

	If $aRP[0][0] = 0 Then
		LogMessage("     [I] No system recovery points were found")
		Return Null
	EndIf

	For $i = 1 To $aRP[0][0]
		UpdateStatusBar("Remove restore point " & $aRP[$i][1])

		SR_RemoveRestorePoint($aRP[$i][0])

		If @error <> 0 Then
			LogMessage("   ~ [X] RP named " & $aRP[$i][1] & " created at " & $aRP[$i][2] & " not deleted")
		Else
			$iRet += 1
			LogMessage("   ~ [OK] RP named " & $aRP[$i][1] & " created at " & $aRP[$i][2] & " deleted")
		EndIf

		Sleep(250)
	Next

	If $aRP[0][0] = $iRet Then
		LogMessage(@CRLF & "     [OK] All system restore points have been successfully deleted")
	Else
		LogMessage(@CRLF & "     [X] Failure when deleting all restore points")
	EndIf

EndFunc   ;==>ClearRestorePoint

Func convertDate($sDtmDate)
	Local $sY = StringLeft($sDtmDate, 4)
	Local $sM = StringMid($sDtmDate, 6, 2)
	Local $sD = StringMid($sDtmDate, 9, 2)
	Local $sT = StringRight($sDtmDate, 8)

	Return $sM & "/" & $sD & "/" & $sY & " " & $sT
EndFunc   ;==>convertDate

Func ClearDailyRestorePoint()
	Local Const $aRP = SR_EnumRestorePoints()

	If $aRP[0][0] = 0 Then
		Return Null
	EndIf

	Local Const $dTimeBefore = convertDate(_DateAdd('n', -1470, _NowCalc()))
	Local $bPointExist = False

	For $i = 1 To $aRP[0][0]
		Local $iDateCreated = $aRP[$i][2]

		If $iDateCreated > $dTimeBefore Then
			If $bPointExist = False Then
				$bPointExist = True
				LogMessage(@CRLF & "     [I] Recent System Restore Point Deletion before create new:" & @CRLF)
			EndIf

			UpdateStatusBar("Remove restore point " & $aRP[$i][1])

			SR_RemoveRestorePoint($aRP[$i][0])

			If @error <> 0 Then
				LogMessage("   ~ [X] RP named " & $aRP[$i][1] & " created at " & $iDateCreated & " not deleted")
			Else
				LogMessage("   ~ [OK] RP named " & $aRP[$i][1] & " created at " & $iDateCreated & " deleted")
			EndIf

			Sleep(250)
		EndIf
	Next

	If $bPointExist = True Then
		LogMessage(@CRLF)
	EndIf

EndFunc   ;==>ClearDailyRestorePoint

Func ShowCurrentRestorePoint()
	LogMessage(@CRLF & "- Display System Restore Point -" & @CRLF)

	Local Const $aRP = SR_EnumRestorePoints()

	If $aRP[0][0] = 0 Then
		LogMessage("     [X] No System Restore point found")
		Return
	EndIf

	For $i = 1 To $aRP[0][0]
		LogMessage("   ~ [I] RP named " & $aRP[$i][1] & " created at " & $aRP[$i][2])
	Next

EndFunc   ;==>ShowCurrentRestorePoint

Func CreateSystemRestorePointWmi()
	#RequireAdmin

	UpdateStatusBar("Create new restore point ...")

	RunWait(@ComSpec & ' /c ' & 'wmic.exe /Namespace:\\root\default Path SystemRestore Call CreateRestorePoint "KpRm", 100, 7', "", @SW_HIDE)

	Sleep(2000)
EndFunc   ;==>CreateSystemRestorePointWmi

Func CreateSystemRestorePointPowershell()
	#RequireAdmin

	UpdateStatusBar("Create new restore point ...")

	If PowershellIsAvailable() = True Then
		RunWait('Powershell.exe -Command Checkpoint-Computer -Description "KpRm"', @ScriptDir, @SW_HIDE)
	EndIf

	Sleep(2000)
EndFunc   ;==>CreateSystemRestorePointPowershell

Func CheckIsRestorePointExist()
	UpdateStatusBar("Verify if restore point exist ...")

	Local Const $aRP = SR_EnumRestorePoints()
	Local Const $iNbr = $aRP[0][0]

	If $iNbr = 0 Then
		Return False
	EndIf

	Return $aRP[$iNbr][1] = 'KpRm'
EndFunc   ;==>CheckIsRestorePointExist

Func CreateSystemRestorePoint()
	CreateSystemRestorePointWmi()

	If Not CheckIsRestorePointExist() Then
		ClearDailyRestorePoint()
		CreateSystemRestorePointPowershell()
		$bExist = CheckIsRestorePointExist()
	EndIf

	If Not CheckIsRestorePointExist() Then
		LogMessage("     [X] System Restore Point not created")
	Else
		LogMessage("     [OK] System Restore Point created")
	EndIf
EndFunc   ;==>CreateSystemRestorePoint

Func CreateRestorePoint()
	LogMessage(@CRLF & "- Create Restore Point -" & @CRLF)
	UpdateStatusBar("Create Restore Point ...")

	EnableRestoration()
	CreateSystemRestorePoint()
	ShowCurrentRestorePoint()
EndFunc   ;==>CreateRestorePoint

;################################################| Restore_Points End

;################################################| Custom_Search

Func SetSearchList()
	Dim $oListView
	Dim $bSearchOnlyHasFoundElement
	Dim $aElementsFound

	_ArraySort($aElementsFound, 0, 0, 0, 1)

	$bSearchOnlyHasFoundElement = UBound($aElementsFound) > 1

	For $i = 1 To UBound($aElementsFound) - 1
		GUICtrlCreateListViewItem($aElementsFound[$i][0], $oListView)
	Next

	_GUICtrlListView_SetItemChecked($oListView, -1, True)
EndFunc   ;==>SetSearchList

Func AddToSearch($sElement, $sTool)
	Dim $aElementsFound

	If $sElement = Null Or $sElement = "" Then Return
	If $sTool = Null Or $sTool = "" Then Return

	If IsNewLine($aElementsFound, $sElement) Then
		_ArrayAdd($aElementsFound, $sElement & '~~~~' & $sTool, 0, '~~~~')
	EndIf
EndFunc   ;==>AddToSearch

Func CloseAllSelectedProcess(ByRef Const $aRemoveSelection, $sForce = "0")
	Local $aProcessList = ProcessList()

	For $i = 1 To $aProcessList[0][0]
		Local $sProcessName = $aProcessList[$i][0]
		Local $iPid = $aProcessList[$i][1]

		For $iCpt = 1 To UBound($aRemoveSelection) - 1
			If IsProcessInWhiteList($sProcessName) = False Then
				If $aRemoveSelection[$iCpt][0] <> "" Then
					Local $sProcessPath = _WinAPI_GetProcessFileName($iPid)

					If @error <> 0 Then ContinueLoop
					If Not IsFile($sProcessPath) Then ContinueLoop
					If Not IsFile($aRemoveSelection[$iCpt][0]) Then ContinueLoop
					If $sProcessPath <> $aRemoveSelection[$iCpt][0] Then ContinueLoop

					CloseProcessAndWait($iPid, $sProcessName, $sForce)
					UpdateToolCpt($aRemoveSelection[$iCpt][1], "process", $sProcessName)
				EndIf
			EndIf
		Next
	Next

	ProgressBarUpdate(10)
EndFunc   ;==>CloseAllSelectedProcess

Func RemoveSelectedLineSearchPass(ByRef Const $aRemoveSelection, $sForce = "0")
	CloseAllSelectedProcess($aRemoveSelection, $sForce)

	Local Const $sCompanyName = Null
	Local Const $sQuarantine = "0"

	For $iCpt = 1 To UBound($aRemoveSelection) - 1
		Local $sLine = $aRemoveSelection[$iCpt][0]
		Local $sTool = $aRemoveSelection[$iCpt][1]

		If IsFile($sLine) Then
			RemoveFile($sLine, $sTool, $sCompanyName, $sForce)
		ElseIf IsDir($sLine) Then
			RemoveFolder($sLine, $sTool, $sForce, $sQuarantine)
		ElseIf IsRegistryKey($sLine) Then
			RemoveRegistryKey($sLine, $sTool, $sForce)
		EndIf
	Next

	ProgressBarUpdate(10)
EndFunc   ;==>RemoveSelectedLineSearchPass

Func RemoveAllSelectedLineSearch(ByRef Const $aRemoveSelection)
	Dim $bRemoveToolLastPass = False

	CloseUnEssentialProcess()
	RemoveSelectedLineSearchPass($aRemoveSelection, "0")
	$bRemoveToolLastPass = True
	RemoveSelectedLineSearchPass($aRemoveSelection, "1")
	GenerateDeleteReport()
	ProgressBarUpdate(50)
EndFunc   ;==>RemoveAllSelectedLineSearch

;################################################| Custom_Search End

;################################################| Registry

Func DosPathNameToPathName($sPath)
	Local $sName, $aDrive = DriveGetDrive('ALL')

	If Not IsArray($aDrive) Then
		Return SetError(1, 0, $sPath)
		Return SetError(1, 0, $sPath)
	EndIf

	For $i = 1 To $aDrive[0]
		$sName = _WinAPI_QueryDosDevice($aDrive[$i])

		If StringInStr($sPath, $sName) = 1 Then
			Return StringReplace($sPath, $sName, StringUpper($aDrive[$i]), 1)
		EndIf
	Next

	Return SetError(2, 0, $sPath)
EndFunc   ;==>DosPathNameToPathName

Func _wmic_CreateShadowCopy($DriveLetter_Func, ByRef $ShadowID_Func)
	Local Const $CommandLine = "wmic shadowcopy call create Volume='" & $DriveLetter_Func & "\'"
	Local Const $iPid = Run(@ComSpec & " /c " & $CommandLine, @ScriptDir, @SW_HIDE, $STDOUT_CHILD)

	ProcessWaitClose($iPid)

	Local $sOutput = StdoutRead($iPid)

	Local $Pos1_Retval = StringInStr($sOutput, "ReturnValue = ")
	$Pos1_Retval = $Pos1_Retval + StringLen("ReturnValue = ")

	Local $Pos2_Retval = StringInStr($sOutput, ";", 1, 1, $Pos1_Retval)
	Local $Val_ReturnValue = StringMid($sOutput, $Pos1_Retval, $Pos2_Retval - $Pos1_Retval)

	$Val_ReturnValue = Number($Val_ReturnValue)

	If $Val_ReturnValue = 0 Then
		Local $Pos1_ShadowID = StringInStr($sOutput, "ShadowID = ")
		$Pos1_ShadowID = $Pos1_ShadowID + StringLen("ShadowID = ") + 1

		Local $Pos2_ShadowID = StringInStr($sOutput, ";", 1, 1, $Pos1_ShadowID) - 1
		Local $Val_ShadowID = StringMid($sOutput, $Pos1_ShadowID, $Pos2_ShadowID - $Pos1_ShadowID)

		If $Val_ShadowID <> "" Then
			$ShadowID_Func = $Val_ShadowID
		EndIf
	EndIf

	Return $Val_ReturnValue
EndFunc   ;==>_wmic_CreateShadowCopy

Func _wmic_Globalroot_to_ShadowID($ShadowID_Func)
	Local Const $CommandLine = "wmic shadowcopy"
	Local Const $iPid = Run(@ComSpec & " /c " & $CommandLine, @ScriptDir, @SW_HIDE, $STDOUT_CHILD)

	ProcessWaitClose($iPid)

	Local $sOutput = StdoutRead($iPid)

	Local Const $Pos_ShadowID = StringInStr($sOutput, $ShadowID_Func)

	If $Pos_ShadowID = 0 Then
		Return ""
	EndIf

	Local Const $Pos_GlobalRoo1 = StringInStr($sOutput, "\\?\GLOBALROOT\Device\", 1, -1, $Pos_ShadowID)

	If $Pos_GlobalRoo1 = 0 Then
		Return ""
	EndIf

	Local Const $Pos_GlobalRoot2 = StringInStr($sOutput, " ", 1, 1, $Pos_GlobalRoo1, 60)

	If $Pos_GlobalRoot2 = 0 Then
		Return ""
	EndIf

	Return StringMid($sOutput, $Pos_GlobalRoo1, $Pos_GlobalRoot2 - $Pos_GlobalRoo1)
EndFunc   ;==>_wmic_Globalroot_to_ShadowID

Func _Return_First_Free_Drive_Letter()
	Local Const $array_lettere = _GetFreeDriveLetters()

	If (UBound($array_lettere) - 1) >= 1 Then
		Return $array_lettere[1]
	Else
		Return -1
	EndIf
EndFunc   ;==>_Return_First_Free_Drive_Letter

Func _GetFreeDriveLetters()
	Local $aArray[1]

	For $x = 67 To 90
		If DriveStatus(Chr($x) & ':\') = 'INVALID' Then
			ReDim $aArray[UBound($aArray) + 1]
			$aArray[UBound($aArray) - 1] = Chr($x) & ':'
		EndIf
	Next

	$aArray[0] = UBound($aArray) - 1

	Return ($aArray)
EndFunc   ;==>_GetFreeDriveLetters

Func _RemoveVSSLetter($Drive_Letter_VSS)
	Local Const $Path_DOSDEV = _TempFile(@TempDir, "kprm-dosdev", ".exe")

	_DosDev_Exe($Path_DOSDEV)

	RunWait(@ComSpec & " /c " & '"' & $Path_DOSDEV & '"' & " -d " & $Drive_Letter_VSS, "", @SW_HIDE)

	FileDelete($Path_DOSDEV)
EndFunc   ;==>_RemoveVSSLetter

Func _AssignVSSLetter($Drive_Letter_VSS, $PathUNC_ShadowCopy)
	Local Const $Path_DOSDEV = _TempFile(@TempDir, "kprm-dosdev", ".exe")

	_DosDev_Exe($Path_DOSDEV)

	RunWait(@ComSpec & " /c " & '"' & $Path_DOSDEV & '"' & " " & $Drive_Letter_VSS & " " & $PathUNC_ShadowCopy, "", @SW_HIDE)

	FileDelete($Path_DOSDEV)

	If DriveStatus($Drive_Letter_VSS & "\") = "READY" Then
		Return 0
	EndIf

	Return -1
EndFunc   ;==>_AssignVSSLetter

Func _DosDev_Exe($Path_FileName)
	Local $sData = '0x'
	$sData &= '4D5A90000300000004000000FFFF0000B800000000000000400000000000000000000000000000000000000000000000000000000000000000000000E00000000E1FBA0E00B409CD21B8014CCD21546869732070726F6772616D2063616E6E6F742062652072756E20696E20444F53206D6F64652E0D0D0A240000000000000056C8818312A9EFD012A9EFD012A9EFD091A1E0D013A9EFD091A1B2D015A9EFD012A9EED03EA9EFD09CA1B0D002A9EFD091A1B1D013A9EFD091A1B5D013A9EFD05269636812A9EFD0000000000000000000000000000000000000000000000000504500004C010300FCA6513E0000000000000000E0000F010B01070A001000000026030000000000FF190000001000000020000000000001001000000002000005000200050002000400000000000000006003000004000076AD0000030000800000040000200000000010000010000000000000100000000000000000000000001C00005000000000500300E8030000000000000000000000000000000000000000000000000000C01000001C0000000000000000000000000000000000000000000000000000004013000040000000000000000000000000100000B40000000000000000000000000000000000000000000000000000002E74657874000000BC0F0000001000000010000000040000000000000000000000000000200000602E6461746100000098200300002000000002000000140000000000000000000000000000400000C02E72737263000000E8030000005003000004000000160000000000000000000000000000400000400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000008A1F00009E1F00007C1F0000000000004C1D00005E1D0000701D0000841D00009E1D00003C1D0000C41D0000DA1D0000F41D0000081E00001C1E00002C1D0000181D0000AE1D0000041D0000000000006C1E0000781E0000801E0000621E0000941E00009E1E0000A81E0000B21E0000BA1E0000C81E0000D21E0000DE1E0000EE1E0000FA1E00000E1F00001E1F00002E1F00003C1F00004E1F00006E1F00005A1E0000501E0000481E00008A1E00000000000000000000000000000000000000000000FCA6513E00000000020000001B000000881300008807000052616D4469736B004344526F6D00000052656D6F74650000466978656400000052656D6F7661626C650000004E6F526F6F74446972000000556E6B6E6F776E000000000075736167653A20444F53444556205B2D615D205B2D735D205B2D685D205B5B2D725D205B2D64205B2D655D5D204465766963654E616D65205B546172676574506174685D5D0A000025730000203B200025732573203D2000526567517565727956616C75654578206661696C656420776974682025640A0053797374656D506172746974696F6E005265674F70656E4B65794578206661696C656420776974682025640A0000000053595354454D5C53657475700000000025732064656C657465642E0A00000000444F534445563A20556E61626C6520746F20257320646576696365206E616D65202573202D2025750A000000646566696E65000064656C657465000043757272656E7420646566696E6974696F6E3A200000000025633A203D202A2A2A204C4F474943414C204452495645204249542053455420425554204E4F204452495645204C4554544552202A2A2A0A00000000202A2A2A204C4F474943414C20445249564520424954204E4F5420534554202A2A2A0000205B25735D0000000A00000025735C002A2A2A20756E61626C6520746F207175657279207461726765742070617468202D202575202A2A2A00000000444F534445563A20556E61626C6520746F20717565727920646576696365206E616D6573202D2025750A0000556E68616E646C6564457863657074696F6E46696C746572000000006B65726E656C33322E646C6C00000000FFFFFFFF4B1B00015F1B00010000000048000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000030200001B0130001010000004E42313000000000FCA6513E01000000646F736465762E7064620000000000000000000000000000F41B0000A1A010000183C040682011000150FF15A410000159596A01FF15A8100001CC558BEC535657FF750C8B3D5C100001FF75086870110001FFD78B751083C40C33DBEB2E395D'
	$sData &= '14742D3B75107608686C110001FFD759566868110001FFD75959EB0B8B451446FF4D1485C07410381E75F146381E75CE5F5E5B5DC21000895D14EBF0558BEC51518D45FC506A016A0068C81100016802000080FF150410000185C074125068A8110001FF155C100001595933C0EB46578D45F850FF7508C745F8040100006A006A006898110001FF75FCFF1500100001FF75FC8BF8FF150810000185FF7412576878110001FF155C100001595933C0EB0333C0405FC9C204008B442408FF308B442408FF30FF15501000015959C381EC1C010000A130200001535533ED33DB43FF8C2428010000568984242401000057896C2418896C2410895C241C896C24140F84C70000008BBC243401000083C7048B378A063C2D746F3C2F746B837C241800750689742418EB65837C2410000F85DD02000089742410EB540FBEC050FF156410000183E83F590F84C302000083E822742F83E803742348741983E8030F84AD02000083E80A740548751B8BEB095C2414EB13834C241404EB0C834C241402EB058364241C00468A0684C075ACFF8C24300100000F8572FFFFFF33F63BEE74188D4424245089442414E88DFEFFFF85C0750653E93F020000397424180F853B020000397424100F85440200006800500000BD80F00201556A00FF151010000185C07520FF152410000150A1A010000183C04068D812000150FF15A410000183C40CEBAF803D80F00201000F84E0000000BF6060010168005000005755FF15101000018BD885DB751BFF15241000015068AC12000157FF156010000183C40CE99C0000008BC58D50018A084084C975F92BC283F8027556807D013A7550A1804003018D34804055A3804003018D44242468A8120001508D34B560200001FF156010000183C40C8D44242050FF153C1000018B04851420000133C98A4D0089460C33C04083E941D3E0894610EB15A160F002018D3480408D34B560B00101A360F002018D430150892E895E04FF15AC100001535750894608FF155810000183C4108A45004584C075F83845000F8525FFFFFF68B11400016A14FF35804003016860200001FF155410000183C410FF15401000018364241000833D80400301008B3D5C1000018BD8BDA4120001764DBE68200001FF76FCFF36FF76F868A2120001E897FCFFFFFF7604689C120001FFD78B460885C35959740433D8EB086878120001FFD75955FFD7FF4424148B44241483C6143B05804003015972B885DB742033F633C0408BCED3E085C3740D8D464150683C120001FFD759594683FE1A72E2837C241C00755155FFD7C70424B11400016A14FF3560F002016860B00101FF155410000133DB83C410391D60F002017627BE68B00101FF76FCFF36FF76F868A2120001E8F5FBFFFF55FFD74383C6143B1D60F002015972DE6A00FF15A81000018B44241483E0028944241C750B397424107505E9A6FBFFFF8B3510100001BB0050000053BF6060010157FF742420FFD685C0BDA412000174185057FF7424206824120001E894FBFFFF55FF155C10000159FF742410FF74241CFF74241CFF154810000185C075353944241CBE1C1200017505BE14120001FF152410000150FF74241CA1A01000015683C04068E811000150FF15A410000183C414EB31538B5C241C5753FFD685C074165057536824120001E827FBFFFF55FF155C100001EB0D5368D8110001FF155C10000159598B8C24280100005F5E5D33C05B81C41C010000E986000000558BEC83EC10A13020000185C074073D4EE640BB756E568D45F850FF152C1000018B75FC3375F8FF152810000133F0FF154410000133F0FF152010000133F08D45F050FF151C1000018B45F43345F033F0893530200001750AC705302000014EE640BB6820130001FF151810000185C05E7411680413000150FF1514100001A388400301C9C33B0D302000017501C3E900000000558DAC2458FDFFFF81EC28030000A1302000018985A4020000A18440030185C07402FFD0833D8840030100743E5733C02145D86A13598D7D84F3ABB9B20000008D7DDCF3AB8D45808945D08D45D86A00C74580090400C08945D4FF15381000018D45D050FF15884003015F6802050000FF153410000150FF15301000018B8DA4020000E86AFFFFFF81C5A8020000C9C36A286830130001E89D01000066813D000000014D5A7528A13C00000181B8000000015045000075170FB7881800000181F90B010000742181F90B02000074068365E400EB2A83B8840000010E76F133C93988F8000001EB1183B8740000010E76DE33C93988E80000010F95C1894DE48365FC006A01FF159410000159830D8C400301FF830D90400301FFFF15901000018B0D4C2000018908FF158C1000018B0D482000018908A1881000018B00A394400301E8EC000000833D3420000100750C68A21B0001FF158410000159E8C00000006810200001680C200001E8AB000000A1442000018945DC8D45DC50FF35402000018D45E0508D45D8508D45D450FF157C1000018945CC68082000016800200001E8750000008B45E08B0D781000018901FF75E0FF75D8FF75D4E898F9FFFF83C4308BF08975C8837DE400750756FF15A8100001FF1574100001EB2D8B45EC8B088B09894DD05051E8280000005959C38B65E88B75D0837DE400750756FF156C100001FF1568100001834DFCFF8BC6E860000000C3FF2570100001FF258010000168000003006800000100E85B0000005959C333C0C3CCCCCC68F41B000164A100000000508B442410896C24108D6C24102BE05356578B45F88965E8508B45FCC745FCFFFFFFFF8945F88D45F064A300000000C38B4DF064890D00000000595F5E'
	$sData &= '5BC951C3FF2598100001FF259C100001601C000000000000000000003A1E000010100000A01C00000000000000000000621F000050100000501C00000000000000000000AE1F00000010000000000000000000000000000000000000000000008A1F00009E1F00007C1F0000000000004C1D00005E1D0000701D0000841D00009E1D00003C1D0000C41D0000DA1D0000F41D0000081E00001C1E00002C1D0000181D0000AE1D0000041D0000000000006C1E0000781E0000801E0000621E0000941E00009E1E0000A81E0000B21E0000BA1E0000C81E0000D21E0000DE1E0000EE1E0000FA1E00000E1F00001E1F00002E1F00003C1F00004E1F00006E1F00005A1E0000501E0000481E00008A1E0000000000007600446566696E65446F7344657669636541000070014765744C6F676963616C44726976657300004B01476574447269766554797065410069014765744C6173744572726F72000095025175657279446F734465766963654100980147657450726F6341646472657373000077014765744D6F64756C6548616E646C6541000099025175657279506572666F726D616E6365436F756E74657200D5014765745469636B436F756E7400003E0147657443757272656E74546872656164496400003B0147657443757272656E7450726F63657373496400C00147657453797374656D54696D65417346696C6554696D650051035465726D696E61746550726F6365737300003A0147657443757272656E7450726F63657373003D03536574556E68616E646C6564457863657074696F6E46696C746572004B45524E454C33322E646C6C00009A02657869740000A902667072696E74660044015F696F620000EF027072696E7466000001025F73747269636D700000F50271736F727400E9026D656D6D6F766500E2026D616C6C6F6300000303737072696E7466002403746F6C6F77657200CA005F635F6578697400FB005F65786974004E005F5863707446696C74657200CD005F6365786974000071005F5F696E6974656E760070005F5F6765746D61696E617267730040015F696E69747465726D009E005F5F736574757365726D6174686572720000BB005F61646A7573745F66646976000083005F5F705F5F636F6D6D6F6465000088005F5F705F5F666D6F646500009C005F5F7365745F6170705F747970650000F2005F6578636570745F68616E646C65723300006D73766372742E646C6C0000DB005F636F6E74726F6C66700000C901526567436C6F73654B657900EC01526567517565727956616C75654578410000E2015265674F70656E4B65794578410041445641504933322E646C6C0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000DB1800010000000000000000000000001411000108110001FC100001F4100001EC100001E4100001DC1000014EE640BB01000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000001001000000018000080000000000000000000000000000001000100000030000080000000000000000000000000000001000904000048000000605003008403000000000000000000000000000000000000840334000000560053005F00560045005200530049004F004E005F0049004E0046004F0000000000BD04EFFE00000100020005000000BC0E020005000000BC0E3F000000000000000400040001000000000000000000000000000000E2020000010053007400720069006E006700460069006C00650049006E0066006F000000BE02000001003000340030003900300034004200300000004C001600010043006F006D00700061006E0079004E0061006D006500000000004D006900630072006F0073006F0066007400200043006F00720070006F0072006100740069006F006E0000005A0019000100460069006C0065004400650073006300720069007000740069006F006E000000000044006900730070006C0061007900200044004F005300200044006500760069006300650020004E0061006D0065007300000000005E001F000100460069006C006500560065007200730069006F006E000000000035002E0032002E0033003700370032002E0030002000280064006E007300720076002E0030003300'
	$sData &= '30003200310037002D00310036003400380029000000000036000B00010049006E007400650072006E0061006C004E0061006D006500000044004F0053004400450056002E004500580045000000000080002E0001004C006500670061006C0043006F0070007900720069006700680074000000A90020004D006900630072006F0073006F0066007400200043006F00720070006F0072006100740069006F006E002E00200041006C006C0020007200690067006800740073002000720065007300650072007600650064002E0000003E000B0001004F0072006900670069006E0061006C00460069006C0065006E0061006D006500000044004F0053004400450056002E00450058004500000000006A0025000100500072006F0064007500630074004E0061006D006500000000004D006900630072006F0073006F0066007400AE002000570069006E0064006F0077007300AE0020004F007000650072006100740069006E0067002000530079007300740065006D00000000003A000B000100500072006F006400750063007400560065007200730069006F006E00000035002E0032002E0033003700370032002E00300000000000440000000100560061007200460069006C00650049006E0066006F00000000002400040000005400720061006E0073006C006100740069006F006E00000000000904B00400000000000000000000000000000000000000000000000000000000'

	$sData = Binary($sData)
	Local $file = FileOpen($Path_FileName, 18)
	FileWrite($file, $sData)
	FileClose($file)
EndFunc   ;==>_DosDev_Exe

Func _CreateVSS_ShadowCopy_Drive($SourceDrive_Func, ByRef $Drive_Letter_VSS_Func, ByRef $ShadowID_Func)
	$Drive_Letter_VSS_Func = ""
	$ShadowID_Func = ""

	If _wmic_CreateShadowCopy($SourceDrive_Func, $ShadowID_Func) <> 0 Then
		Return -1 ; Error create shadow copy
	EndIf

	Local $VolumeGlobalRoot = _wmic_Globalroot_to_ShadowID($ShadowID_Func)

	If $VolumeGlobalRoot = "" Then
		Return -2 ; cannot find GLOBALROOT
	EndIf

	Local $ShadowCopyDrive = _Return_First_Free_Drive_Letter()

	If _AssignVSSLetter($ShadowCopyDrive, $VolumeGlobalRoot) = -1 Then
		Return -3 ; drive not ready
	EndIf

	$Drive_Letter_VSS_Func = $ShadowCopyDrive

	Return 0
EndFunc   ;==>_CreateVSS_ShadowCopy_Drive

Func _DeleteShadowCopy($ShadowID_Func)
	Local Const $CommandLine = "vssadmin Delete Shadows /Shadow=" & $ShadowID_Func & " /Quiet"

	Return RunWait(@ComSpec & " /c " & $CommandLine, @ScriptDir, @SW_HIDE)
EndFunc   ;==>_DeleteShadowCopy

Func RemoveShadow($ShadowCopyDrive, $ShadowID)
	If $ShadowCopyDrive Then
		_RemoveVSSLetter($ShadowCopyDrive)
	EndIf

	If $ShadowID Then
		_DeleteShadowCopy($ShadowID)
	EndIf
EndFunc   ;==>RemoveShadow

Func FileCopyVSS(ByRef Const $aAllHives)
	Local $ShadowCopyDrive = ""
	Local $ShadowID = ""

	If DriveStatus(@HomeDrive & "\") <> "READY" Then
		Return -7     ;Source Drive not ready
	EndIf

	Local $Retval_CreateVSS = _CreateVSS_ShadowCopy_Drive(@HomeDrive, $ShadowCopyDrive, $ShadowID)

	If $Retval_CreateVSS < 0 Then
		RemoveShadow($ShadowCopyDrive, $ShadowID)

		Return $Retval_CreateVSS
	EndIf

	If $ShadowCopyDrive = "" Then
		RemoveShadow($ShadowCopyDrive, $ShadowID)

		Return -4     ; Cannot create shadow copy
	EndIf

	For $i = 0 To UBound($aAllHives) - 1
		Local $sHive = $aAllHives[$i][0]
		Local $sBackUpPath = $aAllHives[$i][1]
		Local $Path_Source_Strip = StringMid($sHive, 3)

		UpdateStatusBar("Backup hive  " & $sHive)

		Local $Retval_Copy = FileCopy($ShadowCopyDrive & $Path_Source_Strip, $sBackUpPath)

		If $Retval_Copy = 0 Then
			RemoveShadow($ShadowCopyDrive, $ShadowID)

			Return -5     ; Autoit Copy Error
		EndIf

		Local $sDrive = "", $sDir = "", $sFileName = "", $sExtension = ""
		Local $aPathSplit = _PathSplit($sHive, $sDrive, $sDir, $sFileName, $sExtension)
		Local $sBackupFile = $sBackUpPath & '\' & $sFileName & $sExtension

		If Not FileExists($sBackupFile) Then
			RemoveShadow($ShadowCopyDrive, $ShadowID)

			Return -9
		Else
			ClearAttributes($sBackupFile)
			LogMessage("   ~ [OK] Hive " & $sHive & " backed up")
		EndIf
	Next

	RemoveShadow($ShadowCopyDrive, $ShadowID)

	Return 0
EndFunc   ;==>FileCopyVSS

Func CreateBackupRegistry()
	LogMessage(@CRLF & "- Create Registry Backup -" & @CRLF)
	UpdateStatusBar("Create Registry Backup ...")

	Dim $lFail
	Dim $lRegistryBackupError
	Dim $sCurrentHumanTime
	Local Const $sBackUpPath = @HomeDrive & "\KPRM\backup\" & $sCurrentHumanTime
	Local $aAllHives[0][2]
	Local $aHives[2]
	$aHives[0] = @WindowsDir & "\System32\config\SOFTWARE"
	$aHives[1] = @UserProfileDir & "\NTUSER.dat"

	If Not FileExists($sBackUpPath) Then
		DirCreate($sBackUpPath)
	EndIf

	For $sHives In $aHives
		Local $sDrive = "", $sDir = "", $sFileName = "", $sExtension = ""
		Local $aPathSplit = _PathSplit($sHives, $sDrive, $sDir, $sFileName, $sExtension)

		$sDir = StringRegExpReplace($sDir, "\\$", "")

		Local $sScriptBackUpPath = $sBackUpPath & $sDir
		Local $sHive = $sHives & '|||' & $sScriptBackUpPath

		If Not FileExists($sScriptBackUpPath) Then
			DirCreate($sScriptBackUpPath)
		EndIf

		_ArrayAdd($aAllHives, $sHive, 0, '|||')
	Next

	If @AutoItX64 = 0 Then _WinAPI_Wow64EnableWow64FsRedirection(False)

	Local Const $iBackupStatus = FileCopyVSS($aAllHives)

	If $iBackupStatus <> 0 Then
		CreateBackupRegistryHobocopy($aAllHives)
		Return
	EndIf

	LogMessage(@CRLF & "     [OK] Registry Backup: " & $sBackUpPath)

EndFunc   ;==>CreateBackupRegistry

;################################################| Registry End

;################################################| Delete_Later

Func AddElementToKeep($sElement, $sTool)
	Dim $aElementsToKeep

	If IsNewLine($aElementsToKeep, $sElement) Then
		_ArrayAdd($aElementsToKeep, $sElement & '~~~~' & $sTool, 0, '~~~~')
	EndIf
EndFunc   ;==>AddElementToKeep

Func WriteErrorMessage($sMessage)
	LogMessage(@CRLF & "- Errors -" & @CRLF)
	LogMessage("    ~ " & $sMessage)
EndFunc   ;==>WriteErrorMessage

Func SetDeleteQuarantinesIn7DaysIfNeeded()
	Dim $bDeleteQuarantines
	Dim $sCurrentTime
	Dim $aElementsToKeep

	If $bDeleteQuarantines <> 7 Then Return
	If UBound($aElementsToKeep) = 1 Then Return

	Local Const $sTasksFolder = @HomeDrive & "\KPRM\tasks-quarantines"
	Local Const $sTasksPath = $sTasksFolder & "\task-" & $sCurrentTime & ".txt"

	If FileExists($sTasksFolder) = False Then
		DirCreate($sTasksFolder)
	EndIf

	Local $sBinaryPath = @AutoItExe

	If Not @Compiled Then $sBinaryPath = @ScriptFullPath

	If Not FileExists($sTasksFolder & '\kprm-quarantines.exe') Then
		FileCopy($sBinaryPath, $sTasksFolder & '\kprm-quarantines.exe')
	EndIf

	If Not FileExists($sTasksFolder & '\kprm-quarantines.exe') Then
		Return WriteErrorMessage("Unable to copy binary in " & $sTasksFolder & '\kprm-quarantines.exe')
	EndIf

	Local $hFileOpen = FileOpen($sTasksPath, $FO_APPEND)

	If $hFileOpen = -1 Then
		Return WriteErrorMessage("Unable to open tasks file for writing")
	EndIf

	For $i = 1 To UBound($aElementsToKeep) - 1
		FileWriteLine($hFileOpen, $aElementsToKeep[$i][0])
	Next

	FileClose($hFileOpen)

	Local $sStartDateTime = _DateAdd('d', 7, _NowCalc())
	$sStartDateTime = StringReplace($sStartDateTime, "/", "-")
	$sStartDateTime = StringReplace($sStartDateTime, " ", "T")

	Local $sEndDateTime = _DateAdd("M", 4, _NowCalc())
	$sEndDateTime = StringReplace($sEndDateTime, "/", "-")
	$sEndDateTime = StringReplace($sEndDateTime, " ", "T")

	Local Const $sTaskFolderName = "KpRm-quarantines"
	Local Const $sTaskName = "KpRm-quarantines-" & $sCurrentTime
	Local $iTest

	$iTest = _TaskFolderExists($sTaskFolderName)

	If $iTest <> 1 Then
		$iTest = _TaskFolderCreate($sTaskFolderName)

		If $iTest <> 1 Then
			Return WriteErrorMessage("The folder with the name " & $sTaskFolderName & " was not created successfully")
		EndIf
	EndIf

	$iTest = _TaskCreate($sTaskFolderName & "\" & $sTaskName, _ ;task Folder \ Name
			"KpRm shedule quarantines deletion", _ ; Description
			1, _ ; TASK_TRIGGER_TIME
			$sStartDateTime, _ ; Start time
			$sEndDateTime, _ ; End time
			Null, _ ; Unused
			Null, _ ; Unused
			Null, _ ; Unused
			Null, _ ; Unused
			Null, _ ; Unused
			"PT5M", _ ; Start 5 minutes after logon
			False, _ ; Disable interval
			3, _ ; User must already be logged in
			1, _ ; Runlevel highest
			"", _ ; Username
			"", _ ; Password
			$sTasksFolder & '\kprm-quarantines.exe', _ ; Full Path and Programname to run
			$sTasksFolder, _ ; Execution directory
			"quarantines " & $sCurrentTime, _ ; Arguments
			False) ; RunOnly If Network Available

	If $iTest <> 1 Then
		Return WriteErrorMessage("The task with the name " & $sTaskName & " was not created successfully")
	EndIf
EndFunc   ;==>SetDeleteQuarantinesIn7DaysIfNeeded

Func RemoveQuarantines($sTaskTime)
	Local Const $sTasksFolder = @HomeDrive & "\KPRM\tasks-quarantines"
	Local Const $sTasksPath = $sTasksFolder & "\task-" & $sTaskTime & ".txt"
	Local Const $sKPReportFile = "kprm-" & $sTaskTime & ".txt"
	Local Const $sHomeReport = @HomeDrive & "\KPRM" & "\" & $sKPReportFile
	Local Const $sDesktopReport = @DesktopDir & "\" & $sKPReportFile
	Local Const $bHomeReportExist = FileExists($sHomeReport)
	Local Const $bDesktopReportExist = FileExists($sDesktopReport)

	If FileExists($sTasksPath) = 1 Then

		If $bHomeReportExist = True Then
			FileWrite($sHomeReport, @CRLF & "- Deletions scheduled (" & _NowCalcDate() & ") -" & @CRLF)
		EndIf

		If $bDesktopReportExist = True Then
			FileWrite($sDesktopReport, @CRLF & "- Deletions scheduled (" & _NowCalcDate() & ") -" & @CRLF)
		EndIf

		FileOpen($sTasksPath, 0)

		For $i = 1 To _FileCountLines($sTasksPath)
			Local $sLine = FileReadLine($sTasksPath, $i)
			$sLine = StringStripWS($sLine, $STR_STRIPLEADING + $STR_STRIPTRAILING)

			If $sLine = "" Then ContinueLoop

			If IsFile($sLine) Then
				PrepareRemove($sLine, 0, "1")
				FileDelete($sLine)
			ElseIf IsDir($sLine) Then
				PrepareRemove($sLine, 1, "1")
				DirRemove($sLine, $DIR_REMOVE)
			Else
				ContinueLoop
			EndIf

			If $bHomeReportExist = True Or $bDesktopReportExist = True Then
				Local $sSymbol = "[OK]"
				Local $bExist = FileExists($sLine)

				If $bExist = True Then
					$sSymbol = "[X]"
				EndIf

				Local $sMessage = "     " & $sSymbol & " " & $sLine & " deleted (after 7 days)"

				If $bHomeReportExist = True Then
					FileWrite($sHomeReport, $sMessage & @CRLF)
				EndIf

				If $bDesktopReportExist = True Then
					FileWrite($sDesktopReport, $sMessage & @CRLF)
				EndIf
			EndIf
		Next

		FileClose($sTasksPath)

	EndIf

	Local Const $sSheduleTaskFolderName = "KpRm-quarantines"
	Local Const $sScheduleTaskName = "KpRm-quarantines-" & $sTaskTime
	Local $iTest

	$iTest = _TaskDelete($sScheduleTaskName, $sSheduleTaskFolderName)

	If $iTest <> 1 Then
		WriteErrorMessage("Error durring deletetion " & $sScheduleTaskName)
		Exit
	EndIf

	$iTest = _TaskListAll($sSheduleTaskFolderName)

	If @error <> 0 Then
		WriteErrorMessage("Tasks could not be listed in " & $sScheduleTaskName)
		Exit
	EndIf

	Local Const $aTaskListSplitted = StringSplit($iTest, "|")
	Local Const $bHasEmptyTaskFolder = $aTaskListSplitted[0] = 1 And $aTaskListSplitted[1] = ""

	If $bHasEmptyTaskFolder = True Then
		_TaskFolderDelete($sSheduleTaskFolderName)
		HaraKiri()
	EndIf

	Exit
EndFunc   ;==>RemoveQuarantines

;################################################| Delete_Later End

;################################################| Utils

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

Func ClearAttributes($sPath)
	Local $sAttrib = FileGetAttrib($sPath)
	Local $sAttribFound, $iTimer = 1
	Local $aAttribFound[8]
	$aAttribFound[0] = "R"
	$aAttribFound[1] = "A"
	$aAttribFound[2] = "S"
	$aAttribFound[3] = "H"
	$aAttribFound[4] = "N"
	$aAttribFound[5] = "O"
	$aAttribFound[6] = "T"
	$aAttribFound[7] = "I"

	For $sAttribFound In $aAttribFound
		If StringInStr($sAttrib, $sAttribFound) Then
			If $iTimer = 1 Then
				_GrantAllAccess($sPath)
				$iTimer += 1
			EndIf
			FileSetAttrib($sPath, "-" & $sAttribFound)
		EndIf
	Next
EndFunc   ;==>ClearAttributes

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

Func HaraKiri()
	Dim $bKpRmDev

	If $bKpRmDev = False And @Compiled Then
		Run(@ComSpec & ' /c timeout 3 && del /F /Q "' & @AutoItExe & '"', "", @SW_HIDE)
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
	Else
		AddRemoveAtRestart($sToolElement)
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

Func IsNewLine($arr, $line)
	Return _ArraySearch($arr, $line, 0, 0, 0, 1, 1, 0) = -1
EndFunc   ;==>IsNewLine

;################################################| Utils End

;################################################| Actions_Restart

Func AddRemoveAtRestart($sElement)
	Dim $aRemoveRestart
	Dim $bNeedRestart = True

	If _ArraySearch($aRemoveRestart, $sElement) = -1 Then
		_ArrayAdd($aRemoveRestart, $sElement)
	EndIf
EndFunc   ;==>AddRemoveAtRestart

Func RestartIfNeeded()
	Dim $aRemoveRestart
	Dim $bNeedRestart
	Dim $sCurrentTime

	If $bNeedRestart = True And UBound($aRemoveRestart) > 1 Then
		Local Const $sTasksPath = @HomeDrive & "\KPRM\tasks\task-" & $sCurrentTime & ".txt"

		If Not FileExists(@HomeDrive & "\KPRM\tasks") Then
			DirCreate(@HomeDrive & "\KPRM\tasks")
		EndIf

		Local $hFileOpen = FileOpen($sTasksPath, $FO_APPEND)

		If $hFileOpen = -1 Then
			Return False
		EndIf

		For $i = 1 To UBound($aRemoveRestart) - 1
			FileWriteLine($hFileOpen, $aRemoveRestart[$i])
		Next

		FileClose($hFileOpen)

		Local $sSuffix = GetSuffixKey()
		Local $sBinaryPath = @AutoItExe

		If Not @Compiled Then $sBinaryPath = @ScriptFullPath

		If Not RegWrite("HKLM" & $sSuffix & "\Software\Microsoft\Windows\CurrentVersion\RunOnce", "kprm_restart", "REG_SZ", '"' & $sBinaryPath & '" "restart" "' & $sCurrentTime & '"') Then
			Return False
		EndIf

		UpdateStatusBar("Need Restart")
		MsgBox(64, "Restart Now", $lRestart)
		Shutdown(6)
	EndIf
EndFunc   ;==>RestartIfNeeded

Func ExecuteScriptFile($sReportTime)
	Dim $bKpRmDev

	Local Const $sKPReportFile = "kprm-" & $sReportTime & ".txt"
	Local Const $sHomeReport = @HomeDrive & "\KPRM" & "\" & $sKPReportFile
	Local Const $sDesktopReport = @DesktopDir & "\" & $sKPReportFile
	Local Const $sTasksFile = @HomeDrive & "\KPRM\tasks\task-" & $sReportTime & ".txt"

	If Not FileExists($sTasksFile) Then Exit
	If Not FileExists($sHomeReport) Then Exit
	If Not FileExists($sDesktopReport) Then Exit

	FileWrite($sHomeReport, @CRLF & @CRLF & "- Remove After Restart -" & @CRLF)
	FileWrite($sDesktopReport, @CRLF & @CRLF & "- Remove After Restart -" & @CRLF)

	FileOpen($sTasksFile, 0)

	For $i = 1 To _FileCountLines($sTasksFile)
		Local $sLine = FileReadLine($sTasksFile, $i)
		$sLine = StringStripWS($sLine, $STR_STRIPLEADING + $STR_STRIPTRAILING)

		Select
			Case $sLine = ""
			Case IsFile($sLine)
				PrepareRemove($sLine, 0, "1")
				FileDelete($sLine)
			Case IsDir($sLine)
				PrepareRemove($sLine, 1, "1")
				DirRemove($sLine, $DIR_REMOVE)
			Case IsRegistryKey($sLine)
				_ClearObjectDacl($sLine)
				_GrantAllAccess($sLine, $SE_REGISTRY_KEY)
				RegDelete($sLine)
			Case Else
		EndSelect

		Local $sSymbol = "[OK]"

		Select
			Case IsRegistryKey($sLine)
				If RegEnumVal($sLine, "1") Then
					$sSymbol = "[X]"
				EndIf
			Case FileExists($sLine)
				$sSymbol = "[X]"
		EndSelect

		Local $sMessage = "     " & $sSymbol & " " & $sLine & " deleted (restart)"

		FileWrite($sHomeReport, $sMessage & @CRLF)
		FileWrite($sDesktopReport, $sMessage & @CRLF)
	Next

	FileClose($sTasksFile)
	OpenReport($sHomeReport)
	HaraKiri()

	Exit
EndFunc   ;==>ExecuteScriptFile

Func SendReport($sPathReport)
	If Not @Compiled Then Return
	If $bKpRmDev = True Then Return
	If Not FileExists($sPathReport) Then Return
	If Not IsInternetConnected() Then Return

	UpdateStatusBar("Send report ...")

	Local $hOpen = _WinHttpOpen($sFtpUA)
	Local $hConnect = _WinHttpConnect($hOpen, $sUPDATE_SITE)
	Local $hRequest = _WinHttpOpenRequest($hConnect, "POST", $sUPLOAD_PAGE)
	Local $eReceved = _WinHttpSimpleFormFill($hConnect, $sUPLOAD_PAGE, Default, "name:fichier", $sPathReport)

	ConsoleWrite("$eReceved " & $eReceved & @CRLF)

	_WinHttpCloseHandle($hConnect)
	_WinHttpCloseHandle($hOpen)
EndFunc   ;==>SendReport
