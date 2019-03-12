
Func ClearRestorePoint()
	logMessage(@CRLF & "- Clear All System Restore Points -" & @CRLF)

	Local Const $aRP = _SR_EnumRestorePoints()
	Local $ret = 0

	If $aRP[0][0] = 0 Then
		logMessage("  [I] No system recovery points were found")
		Return Null
	EndIf

	Local $errors = []

	For $i = 1 To $aRP[0][0]
		Local $status = _SR_RemoveRestorePoint($aRP[$i][0])
		$ret += $status

		If $status = 1 Then
			logMessage("    => [OK] RP named " & $aRP[$i][1] & " has been successfully deleted")
		Else
			_ArrayAdd($errors, $aRP[$i])
		EndIf
	Next

	If 1 < UBound($errors) Then Sleep(3000)

	For $i = 1 To UBound($errors)
		Local $status = _SR_RemoveRestorePoint($errors[$i][0])
		$ret += $status

		If $status = 1 Then
			logMessage("    => [OK] RP named " & $errors[$i][1] & " has been successfully deleted")
		Else
			logMessage("    => [X] RP named " & $errors[$i][1] & " has not been successfully deleted")
		EndIf
	Next

	If $aRP[0][0] = $ret Then
		logMessage("  [OK] All system restore points have been successfully deleted")
	Else
		logMessage("  [X] Failure when deleting all restore points")
	EndIf

EndFunc   ;==>ClearRestorePoint


Func CreateRestorePoint($retry = False)
	If $retry = False Then
		logMessage(@CRLF & "- Create New System Restore Point -" & @CRLF)
	Else
		logMessage("  [I] Retry Create New System Restore Point")
	EndIf

	Dim $ProgramName

	Local $iSR_Enabled = _SR_Enable()

	If $iSR_Enabled = 0 Then

		Sleep(3000)
		$iSR_Enabled = _SR_Enable()

		If $iSR_Enabled = 0 Then
			logMessage("  [X] Failed to enable System Restore")
		EndIf

	ElseIf $iSR_Enabled = 1 Then
		logMessage("  [OK] System Restore enabled successfully")
	EndIf

	Local Const $createdPointStatus = _SR_CreateRestorePoint($ProgramName)

	Local $nbr = 50

	Do
		Sleep(250)
		$nbr -= 1
	Until $createdPointStatus = 0 Or $createdPointStatus = 1 Or $nbr = 0

	If $createdPointStatus = 0 Or $nbr = 0 Then
		logMessage("  [X] Failed to create System Restore Point!")

		If $retry = False Then
			CreateRestorePoint(True)
			Return
		EndIf

	ElseIf $createdPointStatus = 1 Then
		logMessage("  [OK] System Restore Point successfully created")
	EndIf

EndFunc   ;==>CreateRestorePoint
