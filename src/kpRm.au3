#RequireAdmin
#include "kp_includes\kprm_is_running.au3"
#Region ;**** Directives created by AutoIt3Wrapper_GUI ****
#AutoIt3Wrapper_Icon=assets\bug.ico
#AutoIt3Wrapper_Outfile=KpRm.exe
#AutoIt3Wrapper_Res_Comment=Delete all removal tools
#AutoIt3Wrapper_Res_Description=KpRm By Kernel-Panik
#AutoIt3Wrapper_Res_Fileversion=2.0.0.19
#AutoIt3Wrapper_Res_ProductName=KpRm
#AutoIt3Wrapper_Res_ProductVersion=2.19.0
#AutoIt3Wrapper_Res_CompanyName=kernel-panik
#AutoIt3Wrapper_Res_LegalCopyright=kernel-panik
#AutoIt3Wrapper_Res_LegalTradeMarks=kernel-panik
#AutoIt3Wrapper_Res_SaveSource=y
#AutoIt3Wrapper_Res_requestedExecutionLevel=requireAdministrator
#AutoIt3Wrapper_Res_LegalCopyright=kernel-panik
#AutoIt3Wrapper_AU3Check_Stop_OnWarning=y
#AutoIt3Wrapper_AU3Check_Parameters=-v 1
#AutoIt3Wrapper_Run_Tidy=y
#Tidy_Parameters=/sci 1
#AutoIt3Wrapper_Run_Au3Stripper=y
#Au3Stripper_Parameters=/rm /sf=1 /sv=1 /mi
#EndRegion ;**** Directives created by AutoIt3Wrapper_GUI ****

#include "kp_includes\includes.au3"

If FileExists($sTmpDir) Then
	DirRemove($sTmpDir, $DIR_REMOVE)
EndIf

DirCreate($sTmpDir)

FileInstall(".\config\tools.xml", $sTmpDir & "\kprm-tools.xml", 1)
FileInstall(".\assets\bug.gif", $sTmpDir & "\kprm-logo.gif", 1)
FileInstall(".\assets\close.gif", $sTmpDir & "\kprm-close.gif", 1)
FileInstall(".\config\tools.xml", $sTmpDir & "\kprm-tools.xml", 1)

_XMLFileOpen($sTmpDir & "\kprm-tools.xml")

If $bKpRmDev = True Then
	AutoItSetOption("MustDeclareVars", 1)
EndIf

If UBound($CmdLine) > 1 Then
	Local $sAction = $CmdLine[1]
	$sAction = StringStripWS($sAction, $STR_STRIPLEADING + $STR_STRIPTRAILING)

	If $sAction = 'quarantines' Then
		RemoveQuarantines($CmdLine[2])
	EndIf

	Exit
EndIf

Local Const $iEULAisOK = CustomMsgBox($MB_ICONINFORMATION, "Disclaimer of warranty!", "Disclaimer of warranty!" & @CRLF & @CRLF _
		 & 'This software is provided "AS IS" without warranty of any kind.' & @CRLF _
		 & 'You may use this software at your own risk.' & @CRLF & @CRLF _
		 & 'This software is not permitted for commercial purposes.' & @CRLF & @CRLF _
		 & 'Are you sure you want to continue?' & @CRLF & @CRLF _
		 & 'Click Yes to continue. Click No to exit.', $MB_YESNO)

If $iEULAisOK <> 1 Then Exit

Local Const $oTabSwitcher[2] = []

Local Const $oMainWindow = GUICreate($sProgramName & " v" & $sKprmVersion & " by kernel-panik", 500, 263, 202, 112, BitOR($WS_POPUP, $WS_BORDER))
GUICtrlSetDefColor($cWhite)

Local Const $oTitleGUI = GUICtrlCreateLabel("KpRm By Kernel-panik v" & $sKprmVersion, $pPadding1, $pPadding1)
GUICtrlSetColor($oTitleGUI, $cBlue)

Global $oHStatus = GUICtrlCreateLabel("Ready...", $pPadding1, 220, 800, $pCtrSize)
GUICtrlSetColor($oHStatus, $cBlue)

Local Const $oCloseButton = GUICtrlCreatePic($sTmpDir & "\kprm-close.gif", 475, 5, 20, 20)

Local Const $oTabSwitcher1 = GUICtrlCreateLabel($lAuto, 158, 5, 120, 20, $SS_SUNKEN + $SS_CENTER + $SS_CENTERIMAGE)
GUICtrlSetBkColor($oTabSwitcher1, $cGreen)
GUICtrlSetColor($oTabSwitcher1, $cBlack)

Local Const $oTabSwitcher2 = GUICtrlCreateLabel($lCustom, 286, 5, 120, 20, $SS_SUNKEN + $SS_CENTER + $SS_CENTERIMAGE)
GUICtrlSetBkColor($oTabSwitcher2, $cDisabled)
GUICtrlSetColor($oTabSwitcher2, $cBlue)

XPStyle(1)
Global $oProgressBar = GUICtrlCreateProgress(0, 245, 500, $pCtrSize)
GUICtrlSetBkColor($oProgressBar, $cWhite)
GUICtrlSetColor($oProgressBar, $cBlack)
XPStyle(0)

Local Const $oTabs = GUICtrlCreateTab(10, 40, 200, 200)
GUICtrlSetState($oTabs, $GUI_HIDE)

Local Const $oTab1 = GUICtrlCreateTabItem("tab1")
Local Const $oPic1 = GUICtrlCreatePic($sTmpDir & "\kprm-logo.gif", 415, 50, 75, 75)

XPStyle(1)
Local Const $oGroup1 = GUICtrlCreateGroup($lActions, $pPadding1, 25, $pWidth1, 120)
GUICtrlSetColor($oGroup1, $cWhite)

Local Const $oGroup2 = GUICtrlCreateGroup($lRemoveQuarantine, $pPadding1, ($pPadding1 + ($pStep * 4)), $pWidth1, 58)
GUICtrlSetColor($oGroup2, $cWhite)

Global $oRemoveTools = GUICtrlCreateCheckbox($lDeleteTools, $pLeft, $pPadding1 + $pStep, 190, $pCtrSize)
GUICtrlSetColor($oRemoveTools, $cWhite)

Global $oRemoveRP = GUICtrlCreateCheckbox($lDeleteSystemRestorePoints, $pLeft, ($pPadding1 + ($pStep * 2)), 190, $pCtrSize)
GUICtrlSetColor($oRemoveRP, $cWhite)

Global $oCreateRP = GUICtrlCreateCheckbox($lCreateRestorePoint, $pLeft, ($pPadding1 + ($pStep * 3)), 190, $pCtrSize)
GUICtrlSetColor($oCreateRP, $cWhite)

Global $oBackupRegistry = GUICtrlCreateCheckbox($lSaveRegistry, $pRight, $pPadding1 + $pStep, 185, $pCtrSize)
GUICtrlSetColor($oBackupRegistry, $cWhite)

Global $oRestoreUAC = GUICtrlCreateCheckbox($lRestoreUAC, $pRight, ($pPadding1 + ($pStep * 2)), 185, $pCtrSize)
GUICtrlSetColor($oRestoreUAC, $cWhite)

Global $oRestoreSystemSettings = GUICtrlCreateCheckbox($lRestoreSettings, $pRight, ($pPadding1 + ($pStep * 3)), 185, $pCtrSize)
GUICtrlSetColor($oRestoreSystemSettings, $cWhite)

Global $oDeleteQuarantine = GUICtrlCreateCheckbox($lRemoveNow, $pLeft, 176, 137, $pCtrSize)
GUICtrlSetColor($oDeleteQuarantine, $cWhite)

Global $oDeleteQuarantineAfter7Days = GUICtrlCreateCheckbox($lRemoveQuarantineAfterNDays, $pRight, 176, 137, $pCtrSize)
GUICtrlSetColor($oDeleteQuarantineAfter7Days, $cWhite)
XPStyle(0)

Local Const $oRunKp = GUICtrlCreateButton($lRun, 415, 159, 75, 52)
GUICtrlSetBkColor($oRunKp, $cGreen)
GUICtrlSetColor($oRunKp, $cBlack)

Local Const $oTab2 = GUICtrlCreateTabItem("tab2")
Global $oUnSelectAllSearchLines = GUICtrlCreateButton($lNoElement, 415, $pButtonDetectionPT, 75, $pButtonDetectionHeight)
GUICtrlSetColor($oUnSelectAllSearchLines, $cWhite)

Global $oSelectAllSearchLines = GUICtrlCreateButton($lAll, 415, ($pButtonDetectionPT + $pButtonDetectionHeight + $pPadding1), 75, $pButtonDetectionHeight)
GUICtrlSetColor($oSelectAllSearchLines, $cWhite)

Global $oClearSearchLines = GUICtrlCreateButton($lEmpty, 415, ($pButtonDetectionPT + ($pButtonDetectionHeight * 2) + ($pPadding1 * 2)), 75, $pButtonDetectionHeight)
GUICtrlSetColor($oClearSearchLines, $cWhite)

Global $oSearchLines = GUICtrlCreateButton($lSearch, 415, ($pButtonDetectionPT + ($pButtonDetectionHeight * 3) + ($pPadding1 * 3)), 75, $pButtonDetectionHeight)
GUICtrlSetColor($oSearchLines, $cWhite)
GUICtrlSetBkColor($oSearchLines, $cBlue)

Global $oRemoveSearchLines = GUICtrlCreateButton($lRemove, 415, ($pButtonDetectionPT + ($pButtonDetectionHeight * 3) + ($pPadding1 * 3)), 75, $pButtonDetectionHeight)
GUICtrlSetBkColor($oRemoveSearchLines, $cRed)
GUICtrlSetColor($oRemoveSearchLines, $cWhite)

Global $oListView = GUICtrlCreateListView("Line", $pPadding1, 30, $pWidth1, 180, $LVS_NOCOLUMNHEADER, BitOR($WS_EX_CLIENTEDGE, $LVS_EX_CHECKBOXES, $LVS_EX_FULLROWSELECT))
GUICtrlSetBkColor($oListView, $cBlack)
GUICtrlSetColor($oListView, $cWhite)
_GUICtrlListView_SetColumnWidth($oListView, 0, $pWidth1 - 5)
SetButtonSearchMode()
GUICtrlCreateTabItem("")

GUISetBkColor($cBlack)
GUISetState(@SW_SHOW)

While 1
	Sleep(10)

	Local $nMsg = GUIGetMsg()

	Switch $nMsg
		Case $GUI_EVENT_PRIMARYDOWN
			_SendMessage($oMainWindow, $WM_SYSCOMMAND, $SC_DRAGMOVE, 0)
		Case $GUI_EVENT_CLOSE
			Exit
		Case $oCloseButton
			Exit
		Case $oTabSwitcher1
			If GUICtrlRead($oTabs, 1) = $oTab1 Then
				ContinueLoop
			EndIf
			GUICtrlSetState($oTab1, $GUI_SHOW)
			GUICtrlSetBkColor($oTabSwitcher1, $cGreen)
			GUICtrlSetColor($oTabSwitcher1, $cBlack)
			GUICtrlSetBkColor($oTabSwitcher2, $cDisabled)
			GUICtrlSetColor($oTabSwitcher2, $cBlue)
		Case $oTabSwitcher2
			If GUICtrlRead($oTabs, 1) = $oTab2 Then
				ContinueLoop
			EndIf
			GUICtrlSetState($oTab2, $GUI_SHOW)
			GUICtrlSetBkColor($oTabSwitcher1, $cDisabled)
			GUICtrlSetColor($oTabSwitcher1, $cBlue)
			GUICtrlSetBkColor($oTabSwitcher2, $cGreen)
			GUICtrlSetColor($oTabSwitcher2, $cBlack)
		Case $oDeleteQuarantine
			GUICtrlSetState($oDeleteQuarantineAfter7Days, $GUI_UNCHECKED)
			If GUICtrlRead($oDeleteQuarantine) = $GUI_CHECKED Then
				GUICtrlSetState($oRemoveTools, $GUI_CHECKED)
			EndIf
		Case $oDeleteQuarantineAfter7Days
			GUICtrlSetState($oDeleteQuarantine, $GUI_UNCHECKED)
			If GUICtrlRead($oDeleteQuarantineAfter7Days) = $GUI_CHECKED Then
				GUICtrlSetState($oRemoveTools, $GUI_CHECKED)
			EndIf
		Case $oRemoveTools
			If GUICtrlRead($oDeleteQuarantine) = $GUI_CHECKED Or GUICtrlRead($oDeleteQuarantineAfter7Days) = $GUI_CHECKED Then
				GUICtrlSetState($oRemoveTools, $GUI_CHECKED)
			EndIf
		Case $oSearchLines
			InitGlobalVars()
			UpdateStatusBar("Search ...")
			KpSearch()
		Case $oRunKp
			InitGlobalVars()
			UpdateStatusBar("Running ...")
			KpRemover()
		Case $oSelectAllSearchLines
			_GUICtrlListView_SetItemChecked($oListView, -1, True)
		Case $oUnSelectAllSearchLines
			_GUICtrlListView_SetItemChecked($oListView, -1, False)
		Case $oClearSearchLines
			_GUICtrlListView_DeleteAllItems($oListView)
			SetButtonSearchMode()
			InitGlobalVars()
		Case $oRemoveSearchLines
			GUICtrlSetState($oRemoveSearchLines, $GUI_DISABLE)

			Local $aRemoveSelection[1][2] = [[]]

			For $i = 1 To UBound($aElementsFound) - 1
				If _GUICtrlListView_GetItemChecked($oListView, $i - 1) Then
					_ArrayAdd($aRemoveSelection, $aElementsFound[$i][0] & '~~~~' & $aElementsFound[$i][1], 0, '~~~~')
				EndIf
			Next

			If UBound($aRemoveSelection) = 1 Then
				CustomMsgBox($MB_ICONWARNING, "Warning", $lNoSelected)
				GUICtrlSetState($oRemoveSearchLines, $GUI_ENABLE)
			Else
				Local $hGlobalTimer = TimerInit()
				InitGlobalVars()
				Init()
				ProgressBarUpdate()
				LogMessage(@CRLF & "- Checked options -" & @CRLF)
				LogMessage("    ~ Custom deletions")
				RemoveAllSelectedLineSearch($aRemoveSelection)
				UpdateStatusBar("Finish")
				RestartIfNeeded()
				_GUICtrlListView_DeleteAllItems($oListView)
				SetButtonSearchMode()
				CustomMsgBox(64, "OK", $lFinish)
				OpenReport()
			EndIf
	EndSwitch
WEnd

