Func quitKprm()
	FileDelete(@TempDir & "\kprm-logo.gif")
	Exit
EndFunc   ;==>quitKprm

If Not IsAdmin() Then
	MsgBox(16, $lFail, $lAdminRequired)
	quitKprm()
EndIf

Local $processList = ProcessList("mbar.exe")

If $processList[0][0] > 0 Then
	MsgBox(16, $lFail, $lKillMbar)
	quitKprm()
EndIf
