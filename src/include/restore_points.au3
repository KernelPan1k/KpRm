
Func ClearRestorePoint()
	logMessage(@CRLF & "- Clear All System Restore Points -" & @CRLF)

	Local Const $aRP = _SR_EnumRestorePoints()
	Local $ret = 0

	If $aRP[0][0] = 0 Then
		logMessage("  [I] No system recovery points were found")
		Return Null
	EndIf

	Local $errors[1][3] = [[Null, Null, Null]]

	For $i = 1 To $aRP[0][0]
		Local $status = _SR_RemoveRestorePoint($aRP[$i][0])
		$ret += $status

		If $status = 1 Then
			logMessage("    => [OK] RP named " & $aRP[$i][1] & " created at " & $aRP[$i][2] & " has been successfully deleted")
		ElseIf UBound($aRP[$i]) = 3 Then
			Local $error[1][3] = [[$aRP[$i][0], $aRP[$i][1], $aRP[$i][2]]]
			_ArrayAdd($errors, $error)
		Else
			logMessage("    => [X] RP named " & $aRP[$i][1] & " created at " & $aRP[$i][2] & " has not been successfully deleted")
		EndIf
	Next

	If 1 < UBound($errors) Then
		Sleep(3000)

		For $i = 1 To UBound($errors) - 1
			Local $status = _SR_RemoveRestorePoint($errors[$i][0])
			$ret += $status

			If $status = 1 Then
				logMessage("    => [OK] RP named " & $errors[$i][1] & " created at " & $aRP[$i][2] & " has been successfully deleted")
			Else
				logMessage("    => [X] RP named " & $errors[$i][1] & " created at " & $aRP[$i][2] & " has not been successfully deleted")
			EndIf
		Next

	EndIf

	If $aRP[0][0] = $ret Then
		logMessage(@CRLF & "  [OK] All system restore points have been successfully deleted")
	Else
		logMessage(@CRLF & "  [X] Failure when deleting all restore points")
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

	Local Const $timeBefore = convertDate(_DateAdd('n', -1470, _NowCalc()))
	Local $relaunch = False
	Local $pointExist = False
	Local $DisplayMessage = False

	For $i = 1 To $aRP[0][0]
		Local $dateCreated = $aRP[$i][2]

		If $dateCreated > $timeBefore Then
			If $DisplayMessage = False Then
				$DisplayMessage = True
				$pointExist = True
				logMessage(@CRLF & "  [I] Recent System Restore Point Deletion before create new:" & @CRLF)
			EndIf

			Local $status = _SR_RemoveRestorePoint($aRP[$i][0])

			If $status = 1 Then
				logMessage("    => [OK] RP named " & $aRP[$i][1] & " created at " & $dateCreated & " has been successfully deleted")
			ElseIf $retry = False Then
				$relaunch = True
			Else
				logMessage("  [X] Failure when deleting restore point " & $aRP[$i][1] & " created at " & $dateCreated)
			EndIf
		EndIf
	Next

	If $relaunch = True Then
		Sleep(3000)
		logMessage("  [I] Retry deleting restore point")
		ClearDayRestorePoint(True)
	EndIf

	If $pointExist = True Then
		logMessage(@CRLF)
	EndIf

	Sleep(3000)

EndFunc   ;==>ClearDayRestorePoint

Func ShowCurrentRestorePoint()
	Sleep(3000)

	logMessage(@CRLF & "- Display All System Restore Point -" & @CRLF)

	Local Const $aRP = _SR_EnumRestorePoints()

	If $aRP[0][0] = 0 Then
		logMessage("  [X] No System Restore point found")
		Return
	EndIf

	For $i = 1 To $aRP[0][0]
		logMessage("    => [I] RP named " & $aRP[$i][1] & " created at " & $aRP[$i][2] & " was found")
	Next

EndFunc   ;==>ShowCurrentRestorePoint

Func CreateSystemRestorePoint()
	#RequireAdmin
	RunWait(@ComSpec & ' /c ' & 'wmic.exe /Namespace:\\root\default Path SystemRestore Call CreateRestorePoint "KpRm", 100, 7', "", @SW_HIDE)

	Return @error
EndFunc   ;==>CreateSystemRestorePoint


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
			logMessage("  [I] Retry to create System Restore Point!")
			CreateRestorePoint(True)
			Return
		Else
			ShowCurrentRestorePoint()
			Return
		EndIf

	ElseIf $createdPointStatus = 0 Then
		logMessage("  [OK] System Restore Point successfully created")
		ShowCurrentRestorePoint()
	EndIf

EndFunc   ;==>CreateRestorePoint
