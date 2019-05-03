Func quitKprm($autoDelete = False)
	Dim $KpRmDev
	Dim $KPLogFile

	FileDelete(@TempDir & "\kprm-logo.gif")

	If $autoDelete = True Then
		If FileExists(@HomeDrive & "\KPRM" & "\" & $KPLogFile) Then
		Run("notepad.exe " & @HomeDrive & "\KPRM" & "\" & $KPLogFile)
		EndIf

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
		MsgBox(16, $lgetLastVersionTitle, $lgetLastVersion)
		ShellExecute("https://kernel-panik.me/tool/kprm/")
		quitKprm(True)
	EndIf
EndFunc   ;==>checkVersionOfKpRm

checkVersionOfKpRm()

If Not IsAdmin() Then
	MsgBox(16, $lFail, $lAdminRequired)
	quitKprm()
EndIf

Local $processList = ProcessList("mbar.exe")

If $processList[0][0] > 0 Then
	MsgBox(16, $lFail, $lKillMbar)
	quitKprm()
EndIf
