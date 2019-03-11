
Func ClearRestorePoint()
	logMessage(@CRLF & "- Clear All System Restore Points -" & @CRLF)

	Local Const $aRP = _SR_EnumRestorePoints()
	Local $ret = 0

	If $aRP[0][0] = 0 Then
		logMessage("  [I] No system recovery points were found")
		Return Null
	EndIf

	For $i = 1 To $aRP[0][0]
		Local $status = _SR_RemoveRestorePoint($aRP[$i][0])
		$ret += $status

		If $status = 1 Then
			logMessage("    => [OK] RP named " & $aRP[$i][1] & " has been successfully deleted")
		Else
			logMessage("    => [X] RP named " & $aRP[$i][1] & " has not been successfully deleted")
		EndIf
	Next

	If $aRP[0][0] = $ret Then
		logMessage("  [OK] All system restore points have been successfully deleted")
	Else
		logMessage("  [X] Failure when deleting all restore points")
	EndIf

EndFunc   ;==>ClearRestorePoint


Func CreateRestorePoint()
	logMessage(@CRLF & "- Create New System Restore Point -" & @CRLF)

	Local Const $iSR_Enabled = _SR_Enable()

	If $iSR_Enabled = 0 Then
		logMessage("  [X] Failed to enable System Restore")
	ElseIf $iSR_Enabled = 1 Then
		logMessage("  [OK] System Restore enabled successfully")
	EndIf

	Sleep(1000)

	Local Const $createdPointStatus = _SR_CreateRestorePoint($ProgramName)

	Do
		Sleep(3000)
	Until $createdPointStatus = 0 Or $createdPointStatus = 1

	If $createdPointStatus = 0 Then
		logMessage("  [X] Failed to create System Restore Point!")
	ElseIf $createdPointStatus = 1 Then
		logMessage("  [OK] System Restore Point successfully created")
	EndIf

EndFunc   ;==>CreateRestorePoint