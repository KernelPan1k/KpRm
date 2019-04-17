
Func ClearRestorePoint()
	logMessage(@CRLF & "- Clear All System Restore Points -" & @CRLF)

	Local Const $aRP = _SR_EnumRestorePoints()
	Local $ret = 0

	If $aRP[0][0] = 0 Then
		logMessage("  [I] No system recovery points were found")
		Return Null
	EndIf

	Local $errors[1][2] = [[Null, Null]]

	For $i = 1 To $aRP[0][0]
		Local $status = _SR_RemoveRestorePoint($aRP[$i][0])
		$ret += $status

		If $status = 1 Then
			logMessage("    => [OK] RP named " & $aRP[$i][1] & " has been successfully deleted")
		ElseIf UBound($aRP[$i]) = 3 Then
			Local $error[1][2] = [[$aRP[$i][0], $aRP[$i][1]]]
			_ArrayAdd($errors, $error)
		Else
			logMessage("    => [X] RP named " & $aRP[$i][1] & " has not been successfully deleted")
		EndIf
	Next

	If 1 < UBound($errors) Then
		Sleep(3000)

		For $i = 1 To UBound($errors) - 1
			Local $status = _SR_RemoveRestorePoint($errors[$i][0])
			$ret += $status

			If $status = 1 Then
				logMessage("    => [OK] RP named " & $errors[$i][1] & " has been successfully deleted")
			Else
				logMessage("    => [X] RP named " & $errors[$i][1] & " has not been successfully deleted")
			EndIf
		Next

	EndIf

	If $aRP[0][0] = $ret Then
		logMessage("  [OK] All system restore points have been successfully deleted")
	Else
		logMessage("  [X] Failure when deleting all restore points")
	EndIf

EndFunc   ;==>ClearRestorePoint

Func convertDate($dtmDate)
	Local $y = StringLeft($dtmDate, 4)
	Local $m = StringMid($dtmDate, 6, 2)
	Local $d = StringMid($dtmDate, 9, 2)
	Local $t = StringRight($dtmDate, 8)

	Return $m & "/" & $d & "/" & $y & " " & $t
EndFunc   ;==>convertDate

Func ClearDayRestorePoint($retry = False)
	Local Const $aRP = _SR_EnumRestorePoints()

	If $aRP[0][0] = 0 Then
		Return Null
	EndIf

	Local Const $in24h = convertDate(_DateAdd('h', -25, _NowCalc()))
	Local $relaunch = False

	For $i = 1 To $aRP[0][0]
		Local $dateCreated = $aRP[$i][2]

		If $dateCreated > $in24h Then
			Local $status = _SR_RemoveRestorePoint($aRP[$i][0])

			If $status = 1 Then
				logMessage("    => [OK] RP named " & $aRP[$i][1] & " has been successfully deleted")
			ElseIf $retry = False Then
				$relaunch = True
			Else
				logMessage("  [X] Failure when deleting restore point " & $aRP[$i][1])
			EndIf
		EndIf
	Next

	If $relaunch = True Then
		Sleep(3000)
		ClearDayRestorePoint(True)
	EndIf

	Sleep(3000)

EndFunc   ;==>ClearDayRestorePoint

Func CreateSystemRestorePoint()
    #RequireAdmin
    RunWait('powershell Checkpoint-Computer -Description "kprm" -RestorePointType MODIFY_SETTINGS')

	Return @error
EndFunc


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

	ClearDayRestorePoint()

	Local Const $createdPointStatus = CreateSystemRestorePoint()

	If $createdPointStatus <> 0 Then
		logMessage("  [X] Failed to create System Restore Point!")

		If $retry = False Then
			CreateRestorePoint(True)
			Return
		EndIf

	ElseIf $createdPointStatus = 0 Then
		logMessage("  [OK] System Restore Point successfully created")
	EndIf

EndFunc   ;==>CreateRestorePoint
