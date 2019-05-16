Func QuitKprm($bAutoDelete = False, $open = True)
	Dim $bKpRmDev
	Dim $sKPLogFile

	FileDelete(@TempDir & "\kprm-logo.gif")

	If $bAutoDelete = True Then
		If $open = True Then
			Run("notepad.exe " & @HomeDrive & "\KPRM" & "\" & $sKPLogFile)
		EndIf

		If $bKpRmDev = False Then
			Run(@ComSpec & ' /c timeout 3 && del /F /Q "' & @ScriptFullPath & '"', @TempDir, @SW_HIDE)
			FileDelete(@ScriptFullPath)
		EndIf
	EndIf
	Exit
EndFunc   ;==>QuitKprm

Func _IsInternetConnected()
	Local $aReturn = DllCall('connect.dll', 'long', 'IsInternetConnected')
	If @error Then
		Return SetError(1, 0, False)
	EndIf
	Return $aReturn[0] = 0
EndFunc   ;==>_IsInternetConnected

Func CheckVersionOfKpRm()
	Dim $sKprmVersion
	Dim $bKpRmDev

	If $bKpRmDev = True Then Return

	Local Const $bHasInternet = _IsInternetConnected()

	If $bHasInternet = False Then
		Return Null
	EndIf

	Local Const $sGet = HttpGet("https://kernel-panik.me/_api/v1/kprm/version")

	If $sGet <> Null And $sGet <> "" And $sGet <> $sKprmVersion Then
		MsgBox(64, $lGetLastVersionTitle, $lGetLastVersion)
		ShellExecute("https://kernel-panik.me/tool/kprm/")
		QuitKprm(True, False)
	EndIf
EndFunc   ;==>CheckVersionOfKpRm

CheckVersionOfKpRm()

If Not IsAdmin() Then
	MsgBox(16, $lFail, $lAdminRequired)
	QuitKprm()
EndIf
