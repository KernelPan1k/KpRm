
Func ClearRestorePoint()
	LogMessage(@CRLF & "- Clear All System Restore Points -" & @CRLF)

	Local Const $aRP = _SR_EnumRestorePoints()
	Local $iRet = 0

	If $aRP[0][0] = 0 Then
		LogMessage("  [I] No system recovery points were found")
		Return Null
	EndIf

	Local $aErrors[1][3] = [[Null, Null, Null]]

	For $i = 1 To $aRP[0][0]
		Local $iStatus = _SR_RemoveRestorePoint($aRP[$i][0])
		$iRet += $iStatus

		If $iStatus = 1 Then
			LogMessage("    => [OK] RP named " & $aRP[$i][1] & " created at " & $aRP[$i][2] & " deleted")			
		Else
			Local $aError[1][3] = [[$aRP[$i][0], $aRP[$i][1], $aRP[$i][2]]]
			_ArrayAdd($aErrors, $aError)
		EndIf
	Next

	If 1 < UBound($aErrors) Then
		Sleep(3000)

		For $i = 1 To UBound($aErrors) - 1
			Local $iStatus = _SR_RemoveRestorePoint($aErrors[$i][0])
			$iRet += $iStatus

			If $iStatus = 1 Then
				LogMessage("    => [OK] RP named " & $aErrors[$i][1] & " created at " & $aRP[$i][2] & " deleted")
			Else
				LogMessage("    => [X] RP named " & $aErrors[$i][1] & " created at " & $aRP[$i][2] & " deleted")
			EndIf
		Next

	EndIf

	If $aRP[0][0] = $iRet Then
		LogMessage(@CRLF & "  [OK] All system restore points have been successfully deleted")
	Else
		LogMessage(@CRLF & "  [X] Failure when deleting all restore points")
	EndIf

EndFunc   ;==>ClearRestorePoint

Func convertDate($sDtmDate)
	Local $sY = StringLeft($sDtmDate, 4)
	Local $sM = StringMid($sDtmDate, 6, 2)
	Local $sD = StringMid($sDtmDate, 9, 2)
	Local $sT = StringRight($sDtmDate, 8)

	Return $sM & "/" & $sD & "/" & $sY & " " & $sT
EndFunc   ;==>convertDate

Func ClearDayRestorePoint($bRetry = False)
	Local Const $aRP = _SR_EnumRestorePoints()

	If $aRP[0][0] = 0 Then
		Return Null
	EndIf

	Local Const $dTimeBefore = convertDate(_DateAdd('n', -1470, _NowCalc()))
	Local $bRelaunch = False
	Local $bPointExist = False
	Local $bDisplayMessage = False

	For $i = 1 To $aRP[0][0]
		Local $iDateCreated = $aRP[$i][2]

		If $iDateCreated > $dTimeBefore Then
			If $bDisplayMessage = False Then
				$bDisplayMessage = True
				$bPointExist = True
				LogMessage(@CRLF & "  [I] Recent System Restore Point Deletion before create new:" & @CRLF)
			EndIf

			Local $iStatus = _SR_RemoveRestorePoint($aRP[$i][0])

			If $iStatus = 1 Then
				LogMessage("    => [OK] RP named " & $aRP[$i][1] & " created at " & $iDateCreated & " deleted")
			ElseIf $bRetry = False Then
				$bRelaunch = True
			Else
				LogMessage("    => [X] RP named " & $aRP[$i][1] & " created at " & $iDateCreated & " deleted")
			EndIf
		EndIf
	Next

	If $bRelaunch = True Then
		Sleep(3000)
		LogMessage("  [I] Retry deleting restore point")
		ClearDayRestorePoint(True)
	EndIf

	If $bPointExist = True Then
		LogMessage(@CRLF)
	EndIf

	Sleep(3000)

EndFunc   ;==>ClearDayRestorePoint

Func ShowCurrentRestorePoint()
	Sleep(3000)

	LogMessage(@CRLF & "- Display All System Restore Point -" & @CRLF)

	Local Const $aRP = _SR_EnumRestorePoints()

	If $aRP[0][0] = 0 Then
		LogMessage("  [X] No System Restore point found")
		Return
	EndIf

	For $i = 1 To $aRP[0][0]
		LogMessage("    => [I] RP named " & $aRP[$i][1] & " created at " & $aRP[$i][2] & " found")
	Next

EndFunc   ;==>ShowCurrentRestorePoint

Func CreateSystemRestorePoint()
	#RequireAdmin
	RunWait(@ComSpec & ' /c ' & 'wmic.exe /Namespace:\\root\default Path SystemRestore Call CreateRestorePoint "KpRm", 100, 7', "", @SW_HIDE)

	Return @error
EndFunc   ;==>CreateSystemRestorePoint


Func CreateRestorePoint($bRetry = False)
	If $bRetry = False Then
		LogMessage(@CRLF & "- Create New System Restore Point -" & @CRLF)
	Else
		LogMessage("  [I] Retry Create New System Restore Point")
	EndIf

	Local $iSR_Enabled = _SR_Enable()

	If $iSR_Enabled = 0 Then

		Sleep(3000)
		$iSR_Enabled = _SR_Enable()

		If $iSR_Enabled = 0 Then
			LogMessage("  [X] Enable System Restore")
		EndIf

	ElseIf $iSR_Enabled = 1 Then
		LogMessage("  [OK] Enable System Restore")
	EndIf

	ClearDayRestorePoint()

	Local Const $iCreatedPointStatus = CreateSystemRestorePoint()

	If $iCreatedPointStatus <> 0 Then
		LogMessage("  [X] System Restore Point created")

		If $bRetry = False Then
			LogMessage("  [I] Retry to create System Restore Point!")
			CreateRestorePoint(True)
			Return
		Else
			ShowCurrentRestorePoint()
			Return
		EndIf

	ElseIf $iCreatedPointStatus = 0 Then
		LogMessage("  [OK] System Restore Point created")
		ShowCurrentRestorePoint()
	EndIf

EndFunc   ;==>CreateRestorePoint
