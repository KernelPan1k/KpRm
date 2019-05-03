Func quitKprm($autoDelete = False)
	Dim $KpRmDev
	Dim $KPLogFile

	FileDelete(@TempDir & "\kprm-logo.gif")

	If $autoDelete = True Then
		Run("notepad.exe " & @DesktopDir & "\" & $KPLogFile)

		If $KpRmDev = False Then
			Run(@ComSpec & ' /c timeout 3 && del /F /Q "' & @ScriptFullPath & '"', @TempDir, @SW_HIDE)
			FileDelete(@ScriptFullPath)
		EndIf
	EndIf
	Exit
EndFunc   ;==>quitKprm

Func checkVersionOfKpRm()
	Dim $kprmVersion

	Local Const $sGet = HttpGet("https://kernel-panik.me/_api/v1/kprm/version")

	If $sGet <> Null And $sGet <> "" And $sGet <> $kprmVersion Then
		MsgBox(6, $lgetLastVersionTitle, $lgetLastVersion)


ShellExecute("http://www.google.com")

	EndIf
EndFunc

If Not IsAdmin() Then
	MsgBox(16, $lFail, $lAdminRequired)
	quitKprm()
EndIf

Local $processList = ProcessList("mbar.exe")

If $processList[0][0] > 0 Then
	MsgBox(16, $lFail, $lKillMbar)
	quitKprm()
EndIf
