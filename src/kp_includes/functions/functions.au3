
Func CreateKPRMDir()
	Local Const $sDir = @HomeDrive & "\KPRM"

	If Not FileExists($sDir) Then
		DirCreate($sDir)
	EndIf

	If Not FileExists($sDir) Then
		CustomMsgBox(16, $lFail, $lRegistryBackupError)
		Exit
	EndIf
EndFunc   ;==>CreateKPRMDir

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
	Dim $bPowerShellAvailable = Null
	Dim $bDeleteQuarantines = Null
	Dim $bSearchOnly = False
	Dim $bSearchOnlyHasFoundElement = False
	Dim $bNeedRestart = False
	Dim $aElementsToKeep[1][2] = [[]]
	Dim $aElementsFound[1][2] = [[]]
	Dim $aRemoveRestart = []

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
		CustomMsgBox($MB_ICONINFORMATION, $lFinishTitle, $lNoTool)
		SetButtonSearchMode()
	EndIf

EndFunc   ;==>KpSearch

Func KpRemover()
	Local $bHasCheckedOption = False

	If GUICtrlRead($oBackupRegistry) = $GUI_CHECKED Then $bHasCheckedOption = True
	If GUICtrlRead($oRemoveTools) = $GUI_CHECKED Then $bHasCheckedOption = True
	If GUICtrlRead($oRestoreSystemSettings) = $GUI_CHECKED Then $bHasCheckedOption = True
	If GUICtrlRead($oRestoreUAC) = $GUI_CHECKED Then $bHasCheckedOption = True
	If GUICtrlRead($oRemoveRP) = $GUI_CHECKED Then $bHasCheckedOption = True
	If GUICtrlRead($oCreateRP) = $GUI_CHECKED Then $bHasCheckedOption = True
	If GUICtrlRead($oDeleteQuarantine) = $GUI_CHECKED Then $bHasCheckedOption = True
	If GUICtrlRead($oDeleteQuarantineAfter7Days) = $GUI_CHECKED Then $bHasCheckedOption = True

	If $bHasCheckedOption = False Then
		CustomMsgBox($MB_ICONWARNING, "Warning", $lNoOptionSelected)
		Return
	EndIf

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

	_InitiatePermissionResources()

	If GUICtrlRead($oBackupRegistry) = $GUI_CHECKED Then
		CreateBackupRegistry()
	EndIf

	ProgressBarUpdate()

	If GUICtrlRead($oRemoveTools) = $GUI_CHECKED Then
		RunRemoveTools()
	Else
		ProgressBarUpdate(16)
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

	_ClosePermissionResources()

	SetDeleteQuarantinesIn7DaysIfNeeded()
	RestartIfNeeded()
	UpdateStatusBar("Finish")
	CustomMsgBox(64, "OK", $lFinish)

	QuitKprm(True)
EndFunc   ;==>KpRemover

Func GetSwapOrder(ByRef $sT)
	If _ArraySearch($aActionsFile, $sT) <> -1 Then
		Local $aOrder[4][2] = [["type", "file"], ["companyName", ""], ["pattern", "__REQUIRED__"], ["quarantine", "0"]]
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
		Local $aOrder[1][2] = [["key", "__REQUIRED__"]]
		Return $aOrder
	ElseIf $sT = "searchRegistryKey" Then
		Local $aOrder[3][2] = [["key", "__REQUIRED__"], ["pattern", "__REQUIRED__"], ["value", "__REQUIRED__"]]
		Return $aOrder
	ElseIf $sT = "cleanDirectory" Then
		Local $aOrder[3][2] = [["path", "__REQUIRED__"], ["companyName", ""], ["quarantine", "0"]]
		Return $aOrder
	ElseIf $sT = "file" Then
		Local $aOrder[2][2] = [["path", "__REQUIRED__"], ["companyName", ""]]
		Return $aOrder
	ElseIf $sT = "folder" Then
		Local $aOrder[2][2] = [["path", "__REQUIRED__"], ["quarantine", "0"]]
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
				CustomMsgBox(16, "Fail", "Attribute " & $aOrder[$i][0] & " for tool " & $sTn & " is required")
				Exit
			EndIf

			$sData &= $sDefaultValue & "~~"
			$iLength += 1
		EndIf
	Next

	If $iLength <> $iCountOrder Then
		CustomMsgBox(16, "Fail", "Values for tool " & $sTn & " are invalid ! Number of expected values " & $iLength & " and number of values received " & $iCountOrder)
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
	Dim $aElementsToKeep

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
EndFunc   ;==>GenerateDeleteReport


Func RunRemoveTools()
	Dim $bSearchOnly

	LogMessage(@CRLF & "- Delete Tools -" & @CRLF)

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
		LogMessage("     [X] Process " & $sProcess & " not killed, it is possible that the deletion is not complete")
	Else
		LogMessage("     [OK] Process " & $sProcess & " killed")
	EndIf
EndFunc   ;==>UCheckIfProcessExist

Func UCheckIfRegistyKeyExist($sToolElement, $sToolVal)
	If $sToolElement = Null Or $sToolElement = "" Then Return

	Local $sSymbol = "[X]"
	RegEnumVal($sToolElement, "1")

	If @error >= 0 Then
		$sSymbol = "[OK]"
	EndIf

	LogMessage("     " & $sSymbol & " " & FormatForDisplayRegistryKey($sToolElement) & " deleted")
EndFunc   ;==>UCheckIfRegistyKeyExist

Func UCheckIfUninstallOk($sToolElement, $sToolVal)
	If $sToolElement = Null Or $sToolElement = "" Then Return

	Local $sDrive = "", $sDir = "", $sFileName = "", $sExtension = ""
	Local $aPathSplit = _PathSplit($sToolElement, $sDrive, $sDir, $sFileName, $sExtension)

	If $sExtension = ".exe" Then
		Local $sFolderPath = $aPathSplit[1] & $aPathSplit[2]
		Local $sSymbol = "[OK]"

		If FileExists($sFolderPath) Then
			$sSymbol = "[R]"
			AddRemoveAtRestart($sFolderPath)
		EndIf

		LogMessage("     " & $sSymbol & " Uninstaller run correctly")
	EndIf
EndFunc   ;==>UCheckIfUninstallOk

Func UCheckIfElementExist($sToolElement, $sToolVal)
	If $sToolElement = Null Or $sToolElement = "" Then Return

	Local $sSymbol = "[OK]"

	If FileExists($sToolElement) Then
		$sSymbol = "[R]"
		AddRemoveAtRestart($sToolElement)
	EndIf

	LogMessage("     " & $sSymbol & " " & $sToolElement & " deleted")
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


Func RestartIfNeeded()
	Dim $bNeedRestart
	Dim $aRemoveRestart
	Dim $sKPLogFile

	If $bNeedRestart = True Then
		Local Const $sSuffixKey = GetSuffixKey()

		Local $sCmd = StringReplace(@ComSpec, "\", "\\")

		For $i = 1 To UBound($aRemoveRestart) - 1
			Local $sType = FileExistsAndGetType($aRemoveRestart[$i])
			Local $sElement = StringReplace($aRemoveRestart[$i], "\", "\\")
			Local $sCommand = Null

			If $sType = 'file' Then
				$sCommand = $sCmd & " /c IF EXIST " & '"' & $sElement & '"' & " DEL /F /Q " & '"' & $sElement & '"'
			ElseIf $sType = 'folder' Then
				$sCommand = $sCmd & " /c IF EXIST " & '"' & $sElement & '"' & " RMDIR /S /Q " & '"' & $sElement & '"'
			EndIf

			If $sCommand <> Null Then
				RegWrite("HKLM" & $sSuffixKey & "\Software\Microsoft\Windows\CurrentVersion\RunOnce", "kprm_remove__" & $i, "REG_SZ", $sCommand)
			EndIf
		Next

		Local $reportPath = StringReplace(@DesktopDir & "\" & $sKPLogFile, "\", "\\")
		RegWrite("HKLM" & $sSuffixKey & "\Software\Microsoft\Windows\CurrentVersion\RunOnce", "kprm_report", "REG_SZ", "notepad.exe " & '"' & $reportPath & '"')

		If @Compiled Then
			Local $sExe = StringReplace(@AutoItExe, "\", "\\")
			Local $sCommand = $sCmd & " /c IF EXIST " & '"' & $sExe & '"' & " DEL /F /Q " & '"' & $sExe & '"'
			RegWrite("HKLM" & $sSuffixKey & "\Software\Microsoft\Windows\CurrentVersion\RunOnce", "kprm_remove_exe", "REG_SZ", $sCommand)
		EndIf

		LogMessage(@CRLF & "- Need to Restart -" & @CRLF)
		UpdateStatusBar("Need Restart")
		CustomMsgBox(64, "Restart Now", $lRestart)

		If Shutdown(6) <> 1 Then
			Shutdown(2)
		EndIf

	EndIf
EndFunc   ;==>RestartIfNeeded
