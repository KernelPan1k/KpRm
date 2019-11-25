Local $iNbrTask = 47
Local $iCurrentNbrTask
Local Const $iTaskStep = Floor(100 / $iNbrTask)

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
