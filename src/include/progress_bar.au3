
Local Const $nbrTask = 7
Global $currentNbrTask = 0
Global Const $taskStep = Floor(100 / $nbrTask)

Func ProgressBarUpdate()
	$currentNbrTask += 1
	ProgressSet($currentNbrTask * $taskStep)

	If $currentNbrTask = $nbrTask Then
		ProgressSet(100, "Done!")
		Sleep(750)
		ProgressOff()
	EndIf
EndFunc   ;==>ProgressBarUpdate

Func ProgressBarInit()
	$currentNbrTask = 0
;~ 	ProgressOn($ProgramName, $ProgramName & " progress", "Working...")
EndFunc