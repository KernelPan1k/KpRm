Func quitKprm($autoDelete = False, $open = True)
	Dim $KpRmDev
	Dim $KPLogFile

	FileDelete(@TempDir & "\kprm-logo.gif")

	If $autoDelete = True Then
		If $open = True Then
			Run("notepad.exe " & @HomeDrive & "\KPRM" & "\" & $KPLogFile)
		EndIf

		If $KpRmDev = False Then
			Run(@ComSpec & ' /c timeout 3 && del /F /Q "' & @ScriptFullPath & '"', @TempDir, @SW_HIDE)
			FileDelete(@ScriptFullPath)
		EndIf
	EndIf
	Exit
EndFunc   ;==>quitKprm

Func _IsInternetConnected()
	Local $aReturn = DllCall('connect.dll', 'long', 'IsInternetConnected')
	If @error Then
		Return SetError(1, 0, False)
	EndIf
	Return $aReturn[0] = 0
EndFunc   ;==>_IsInternetConnected

Func checkVersionOfKpRm()
	Dim $kprmVersion

	Local Const $hasInternet = _IsInternetConnected()

	If $hasInternet = False Then
		Return Null
	EndIf

	Local Const $sGet = HttpGet("https://kernel-panik.me/_api/v1/kprm/version")

	If $sGet <> Null And $sGet <> "" And $sGet <> $kprmVersion Then
		MsgBox(64, $lgetLastVersionTitle, $lgetLastVersion)
		ShellExecute("https://kernel-panik.me/tool/kprm/")
		quitKprm(True, False)
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
