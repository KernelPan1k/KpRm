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
					If Not isFile($sProcessPath) Then ContinueLoop
					If Not isFile($aRemoveSelection[$iCpt][0]) Then ContinueLoop
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

		If isFile($sLine) Then
			RemoveFile($sLine, $sTool, $sCompanyName, $sForce)
		ElseIf isDir($sLine) Then
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
