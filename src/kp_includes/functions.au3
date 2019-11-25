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
