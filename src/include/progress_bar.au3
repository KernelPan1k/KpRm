
Dim $nbrTask = 11 ; 6 fixe + 5 programs
Local $currentNbrTask
Global Const $taskStep = Floor(100 / $nbrTask)

Func ProgressBarUpdate()
	$currentNbrTask += 1
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
