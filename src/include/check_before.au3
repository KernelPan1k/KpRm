If Not IsAdmin() Then
	MsgBox(16, $lFail, $lAdminRequired)
	Exit
EndIf

Local $processList = ProcessList("mbar.exe")

If $processList[0][0] > 0 Then
	MsgBox(16, $lFail, $lKillMbar)
	Exit
EndIf
