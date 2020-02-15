Func ProgressBarUpdate($nbr = 1)
	Dim $oProgressBar
	Dim $iCurrentNbrTask

	$iCurrentNbrTask += $nbr
	GUICtrlSetData($oProgressBar, $iCurrentNbrTask * $iTaskStep)

	If $iCurrentNbrTask = $iNbrTask Then
		GUICtrlSetData($oProgressBar, 100)
	EndIf
EndFunc   ;==>ProgressBarUpdate

Func ProgressBarInit()
	Dim $oProgressBar
	Dim $iCurrentNbrTask

	$iCurrentNbrTask = 0
	GUICtrlSetData($oProgressBar, 0)
EndFunc   ;==>ProgressBarInit
