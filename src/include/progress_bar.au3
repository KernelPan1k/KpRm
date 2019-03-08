#cs ----------------------------------------------------------------------------

 AutoIt Version: 3.3.14.5
 Author:         myName

 Script Function:
	Template AutoIt script.

#ce ----------------------------------------------------------------------------

; Script Start - Add your code below here

Local Const $nbrTask = 4
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
	ProgressOn($ProgramName, $ProgramName & " progress", "Working...")
EndFunc