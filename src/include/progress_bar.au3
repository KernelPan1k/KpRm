Local $nbrTask = 43
Local $currentNbrTask
Local Const $taskStep = Floor(100 / $nbrTask)

Func ProgressBarUpdate($nbr = 1)
	$currentNbrTask += $nbr
	Dim $ProgressBar
	GUICtrlSetData($ProgressBar, $currentNbrTask * $taskStep)

	If $currentNbrTask = $nbrTask Then
		GUICtrlSetData($ProgressBar, 100)
	EndIf
EndFunc   ;==>ProgressBarUpdate

Func ProgressBarInit()
	$currentNbrTask = 0
	Dim $ProgressBar
	GUICtrlSetData($ProgressBar, 0)
EndFunc   ;==>ProgressBarInit
