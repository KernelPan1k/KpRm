
Func ClearRestorePoint()
	LogMessage(@CRLF & "- Clear Restore Points -" & @CRLF)

	Local Const $aRP = _SR_EnumRestorePoints()
	Local $iRet = 0

	If $aRP[0][0] = 0 Then
		LogMessage("  [I] No system recovery points were found")
		Return Null
	EndIf

	For $i = 1 To $aRP[0][0]
		UpdateStatusBar("Remove restore point " & $aRP[$i][1])

		Local $iStatus = _SR_RemoveRestorePoint($aRP[$i][0])

		If $iStatus = 0 And @error <> 0 Then
			LogMessage("    ~ [X] RP named " & $aRP[$i][1] & " created at " & $aRP[$i][2] & " deleted")
		Else
			$iRet += 1
			LogMessage("    ~ [OK] RP named " & $aRP[$i][1] & " created at " & $aRP[$i][2] & " deleted")
		EndIf

		Sleep(200)
	Next

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

Func ClearDailyRestorePoint()
	Local Const $aRP = _SR_EnumRestorePoints()

	If $aRP[0][0] = 0 Then
		Return Null
	EndIf

	Local Const $dTimeBefore = convertDate(_DateAdd('n', -1470, _NowCalc()))
	Local $bPointExist = False

	For $i = 1 To $aRP[0][0]
		Local $iDateCreated = $aRP[$i][2]

		If $iDateCreated > $dTimeBefore Then
			If $bPointExist = False Then
				$bPointExist = True
				LogMessage(@CRLF & "  [I] Recent System Restore Point Deletion before create new:" & @CRLF)
			EndIf

			UpdateStatusBar("Remove restore point " & $aRP[$i][1])

			Local $iStatus = _SR_RemoveRestorePoint($aRP[$i][0])

			If $iStatus = 0 And @error <> 0 Then
				LogMessage("    ~ [X] RP named " & $aRP[$i][1] & " created at " & $iDateCreated & " deleted")
			Else
				LogMessage("    ~ [OK] RP named " & $aRP[$i][1] & " created at " & $iDateCreated & " deleted")
			EndIf

			Sleep(200)
		EndIf
	Next

	If $bPointExist = True Then
		LogMessage(@CRLF)
	EndIf

EndFunc   ;==>ClearDailyRestorePoint

Func ShowCurrentRestorePoint()
	LogMessage(@CRLF & "- Display System Restore Point -" & @CRLF)

	Local Const $aRP = _SR_EnumRestorePoints()

	If $aRP[0][0] = 0 Then
		LogMessage("  [X] No System Restore point found")
		Return
	EndIf

	For $i = 1 To $aRP[0][0]
		LogMessage("    ~ [I] RP named " & $aRP[$i][1] & " created at " & $aRP[$i][2] & " found")
	Next

EndFunc   ;==>ShowCurrentRestorePoint

Func CreateSystemRestorePoint()
	#RequireAdmin

	UpdateStatusBar("Create new restore point")

	RunWait(@ComSpec & ' /c ' & 'wmic.exe /Namespace:\\root\default Path SystemRestore Call CreateRestorePoint "KpRm", 100, 7', "", @SW_HIDE)

	Return @error
EndFunc   ;==>CreateSystemRestorePoint


Func CheckIsRestorePointExist()
	UpdateStatusBar("Verify if restore point exist")

	Sleep(200)

	Local Const $aRP = _SR_EnumRestorePoints()
	Local Const $iNbr = $aRP[0][0]

	If $iNbr = 0 Then
		Return False
	EndIf

	Return $aRP[$iNbr][1] = 'KpRm'
EndFunc   ;==>CheckIsRestorePointExist


Func CreateRestorePoint()
	LogMessage(@CRLF & "- Create Restore Point -" & @CRLF)

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

	CreateSystemRestorePoint()
	Local $bExist = CheckIsRestorePointExist()

	If $bExist = False Then
		ClearDailyRestorePoint()
		CreateSystemRestorePoint()
		$bExist = CheckIsRestorePointExist()
	EndIf

	If $bExist = False Then
		LogMessage("  [X] System Restore Point created")
	Else
		LogMessage("  [OK] System Restore Point created")
	EndIf

	ShowCurrentRestorePoint()

EndFunc   ;==>CreateRestorePoint
