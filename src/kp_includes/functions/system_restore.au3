Func SR_WMIDateStringToDate($dtmDate)
	Return _
			(StringMid($dtmDate, 5, 2) & "/" & _
			StringMid($dtmDate, 7, 2) & "/" & _
			StringLeft($dtmDate, 4) & " " & _
			StringMid($dtmDate, 9, 2) & ":" & _
			StringMid($dtmDate, 11, 2) & ":" & _
			StringMid($dtmDate, 13, 2))
EndFunc   ;==>SR_WMIDateStringToDate

Func _SR_CreateRestorePoint($strDescription)
	Local Const $MAX_DESC = 64
	Local Const $MAX_DESC_W = 256
	Local Const $BEGIN_SYSTEM_CHANGE = 100
	Local Const $MODIFY_SETTINGS = 12
	Local $_RESTOREPTINFO = DllStructCreate('DWORD dwEventType;DWORD dwRestorePtType;INT64 llSequenceNumber;WCHAR szDescription[' & $MAX_DESC_W & ']')

	DllStructSetData($_RESTOREPTINFO, 'dwEventType', $BEGIN_SYSTEM_CHANGE)
	DllStructSetData($_RESTOREPTINFO, 'dwRestorePtType', $MODIFY_SETTINGS)
	DllStructSetData($_RESTOREPTINFO, 'llSequenceNumber', 0)
	DllStructSetData($_RESTOREPTINFO, 'szDescription', $strDescription)

	Local $pRestorePtSpec = DllStructGetPtr($_RESTOREPTINFO)
	Local $_SMGRSTATUS = DllStructCreate('UINT  nStatus;INT64 llSequenceNumber')
	Local $pSMgrStatus = DllStructGetPtr($_SMGRSTATUS)
	Local $aRet = DllCall('SrClient.dll', 'BOOL', 'SRSetRestorePointW', 'ptr', $pRestorePtSpec, 'ptr', $pSMgrStatus)

	If @error Then Return 0

	Return $aRet[0]

EndFunc   ;==>_SR_CreateRestorePoint

Func SR_EnumRestorePointsPowershell()
	Local $aRestorePoints[1][3], $iCounter = 0
	$aRestorePoints[0][0] = $iCounter
	Local $sOutput
	Local $aRP[0]
	Local $bStart = False

	If PowershellIsAvailable() = False Then
		Return $aRestorePoints
	EndIf

	Local $iPid = Run('Powershell.exe -ep bypass -nop -Command "$date = @{Expression={$_.ConvertToDateTime($_.CreationTime)}}; Get-ComputerRestorePoint | Select-Object -Property SequenceNumber, Description, $date"', @SystemDir, @SW_HIDE, $STDOUT_CHILD)

	While 1
		$sOutput &= StdoutRead($iPid)
		If @error Then ExitLoop
	WEnd

	Local $aTmp = StringSplit($sOutput, @CRLF)

	For $i = 1 To $aTmp[0]
		Local $sRow = StringStripWS($aTmp[$i], $STR_STRIPLEADING + $STR_STRIPTRAILING + $STR_STRIPSPACES)

		If $sRow = "" Then ContinueLoop

		If StringInStr($sRow, "-----") Then
			$bStart = True
		ElseIf $bStart = True Then
			_ArrayAdd($aRP, $sRow)
		EndIf
	Next

	For $i = 0 To UBound($aRP) - 1
		Local $sRow = $aRP[$i]
		Local $aRow = StringSplit($sRow, " ")
		Local $iNbr = $aRow[0]

		If $iNbr >= 4 Then
			Local $sTime = StringStripWS(_ArrayPop($aRow), $STR_STRIPLEADING + $STR_STRIPTRAILING + $STR_STRIPSPACES)
			Local $sDate = StringStripWS(_ArrayPop($aRow), $STR_STRIPLEADING + $STR_STRIPTRAILING + $STR_STRIPSPACES)
			Local $iSequence = Number(StringStripWS($aRow[1], $STR_STRIPLEADING + $STR_STRIPTRAILING + $STR_STRIPSPACES))

			$sDate = StringReplace($sDate, '.', '/')
			$sDate = StringReplace($sDate, '-', '/')

			_ArrayDelete($aRow, 0)
			_ArrayDelete($aRow, 0)
			Local $sDescription = _ArrayToString($aRow, " ")
			$sDescription = StringStripWS($sDescription, $STR_STRIPLEADING + $STR_STRIPTRAILING + $STR_STRIPSPACES)

			$iCounter += 1
			ReDim $aRestorePoints[$iCounter + 1][3]
			$aRestorePoints[$iCounter][0] = $iSequence
			$aRestorePoints[$iCounter][1] = $sDescription
			$aRestorePoints[$iCounter][2] = $sDate & " " & $sTime
		EndIf
	Next

	$aRestorePoints[0][0] = $iCounter

	Return $aRestorePoints
EndFunc   ;==>SR_EnumRestorePointsPowershell

Func SR_EnumRestorePoints()
	Dim $__g_oSR_WMI

	Local $aRestorePoints[1][3], $iCounter = 0
	$aRestorePoints[0][0] = $iCounter

	If Not IsObj($__g_oSR_WMI) Then
		$__g_oSR_WMI = ObjGet("winmgmts:root/default")
	EndIf

	If Not IsObj($__g_oSR_WMI) Then
		Return SR_EnumRestorePointsPowershell()
	EndIf

	Local $RPSet = $__g_oSR_WMI.InstancesOf("SystemRestore")

	If Not IsObj($RPSet) Then
		Return SR_EnumRestorePointsPowershell()
	EndIf

	For $rP In $RPSet
		$iCounter += 1
		ReDim $aRestorePoints[$iCounter + 1][3]
		$aRestorePoints[$iCounter][0] = $rP.SequenceNumber
		$aRestorePoints[$iCounter][1] = $rP.Description
		$aRestorePoints[$iCounter][2] = SR_WMIDateStringToDate($rP.CreationTime)
	Next

	$aRestorePoints[0][0] = $iCounter

	Return $aRestorePoints
EndFunc   ;==>SR_EnumRestorePoints

Func SR_Enable($DriveL)
	Dim $__g_oSR

	If Not IsObj($__g_oSR) Then
		$__g_oSR = ObjGet("winmgmts:{impersonationLevel=impersonate}!root/default:SystemRestore")
	EndIf

	If Not IsObj($__g_oSR) Then
		Return 0
	EndIf

	If $__g_oSR.Enable($DriveL) = 0 Then
		Return 1
	EndIf

	Return 0
EndFunc   ;==>SR_Enable

Func EnableRestoration()
	UpdateStatusBar("Enable restoration ...")

	Local $iSR_Enabled = SR_Enable(@HomeDrive & '\')

	If $iSR_Enabled = 0 Then
		If PowershellIsAvailable() = True Then
			RunWait("Powershell.exe -ep bypass -nop -Command  Enable-ComputeRrestore -drive '" & @HomeDrive & "\' | Set-Content -Encoding utf8 ", @ScriptDir, @SW_HIDE)
		EndIf
	EndIf
EndFunc   ;==>EnableRestoration

Func SR_RemoveRestorePoint($rpSeqNumber)
	Local $aRet = DllCall('SrClient.dll', 'DWORD', 'SRRemoveRestorePoint', 'DWORD', $rpSeqNumber)
	If @error Then _
			Return SetError(1, 0, 0)
	If $aRet[0] = 0 Then _
			Return 1
	Return SetError(1, 0, 0)
EndFunc   ;==>SR_RemoveRestorePoint

Func ClearRestorePoint()
	LogMessage(@CRLF & "- Clear Restore Points -" & @CRLF)
	UpdateStatusBar("Clear Restore Points ...")

	Local Const $aRP = SR_EnumRestorePoints()
	Local $aFailsSequenceNumber = [] ;

	If $aRP[0][0] = 0 Then
		LogMessage("     [I] No system recovery points were found")
		Return Null
	EndIf

	For $i = 1 To $aRP[0][0]
		UpdateStatusBar("Remove restore point " & $aRP[$i][1])

		Local $iSequenceNumber = $aRP[$i][0]

		SR_RemoveRestorePoint($iSequenceNumber)

		If @error <> 0 Then
			_ArrayAdd($aFailsSequenceNumber, $iSequenceNumber)
		EndIf
	Next

	If UBound($aFailsSequenceNumber) = 1 Then
		For $i = 1 To $aRP[0][0]
			LogMessage("   ~ [OK] RP named " & $aRP[$i][1] & " created at " & $aRP[$i][2] & " deleted")
		Next

		LogMessage("     [OK] All system restore points have been successfully deleted")

		Return True
	EndIf

;~ 	This horrible code exists because sometimes I receive a failure code when the restore point is removed.

	Sleep(5000)

	Local Const $aRPCheck = SR_EnumRestorePoints()

	If $aRPCheck[0][0] = 0 Then
		For $i = 1 To $aRP[0][0]
			LogMessage("   ~ [OK] RP named " & $aRP[$i][1] & " created at " & $aRP[$i][2] & " deleted")
		Next

		LogMessage("     [OK] All system restore points have been successfully deleted")

		Return True
	EndIf

	For $i = 1 To $aRP[0][0]
		Local $iSequenceNumber = $aRP[$i][0]
		Local $bExist = False

		For $z = 0 To $aRPCheck[0][0]
			Local $iSequenceNumberCheck = $aRPCheck[$z][0]

			If $iSequenceNumber = $iSequenceNumberCheck Then
				$bExist = True
				ExitLoop
			EndIf
		Next

		If $bExist = True Then
			LogMessage("   ~ [X] RP named " & $aRP[$i][1] & " created at " & $aRP[$i][2] & " not deleted")
		Else
			LogMessage("   ~ [OK] RP named " & $aRP[$i][1] & " created at " & $aRP[$i][2] & " deleted")
		EndIf
	Next

	LogMessage("     [X] Failure when deleting all restore points")
EndFunc   ;==>ClearRestorePoint

Func convertDate($sDtmDate)
	Local $sY = StringLeft($sDtmDate, 4)
	Local $sM = StringMid($sDtmDate, 6, 2)
	Local $sD = StringMid($sDtmDate, 9, 2)
	Local $sT = StringRight($sDtmDate, 8)

	Return $sM & "/" & $sD & "/" & $sY & " " & $sT
EndFunc   ;==>convertDate

Func ClearDailyRestorePoint()
	Local Const $aRP = SR_EnumRestorePoints()

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
				LogMessage(@CRLF & "     [I] Recent System Restore Point Deletion before create new:" & @CRLF)
			EndIf

			UpdateStatusBar("Remove restore point " & $aRP[$i][1])

			SR_RemoveRestorePoint($aRP[$i][0])

			If @error <> 0 Then
				LogMessage("   ~ [X] RP named " & $aRP[$i][1] & " created at " & $iDateCreated & " not deleted")
			Else
				LogMessage("   ~ [OK] RP named " & $aRP[$i][1] & " created at " & $iDateCreated & " deleted")
			EndIf

			Sleep(250)
		EndIf
	Next

	If $bPointExist = True Then
		LogMessage(@CRLF)
	EndIf

EndFunc   ;==>ClearDailyRestorePoint

Func ShowCurrentRestorePoint()
	LogMessage(@CRLF & "- Display System Restore Point -" & @CRLF)

	Local Const $aRP = SR_EnumRestorePoints()

	If $aRP[0][0] = 0 Then
		LogMessage("     [X] No System Restore point found")
		Return
	EndIf

	For $i = 1 To $aRP[0][0]
		LogMessage("   ~ [I] RP named " & $aRP[$i][1] & " created at " & $aRP[$i][2])
	Next

EndFunc   ;==>ShowCurrentRestorePoint

Func CreateSystemRestorePointWmi()
	#RequireAdmin

	UpdateStatusBar("Create new restore point ...")

	RunWait(@ComSpec & ' /c ' & 'wmic.exe /Namespace:\\root\default Path SystemRestore Call CreateRestorePoint "KpRm", 100, 7', "", @SW_HIDE)

	Sleep(2000)
EndFunc   ;==>CreateSystemRestorePointWmi

Func CreateSystemRestorePointPowershell()
	#RequireAdmin

	UpdateStatusBar("Create new restore point ...")

	If PowershellIsAvailable() = True Then
		RunWait('Powershell.exe -ep bypass -nop -Command Checkpoint-Computer -Description "KpRm"', @ScriptDir, @SW_HIDE)
	EndIf

	Sleep(2000)
EndFunc   ;==>CreateSystemRestorePointPowershell

Func CheckIsRestorePointExist()
	UpdateStatusBar("Verify if restore point exist ...")

	Local Const $aRP = SR_EnumRestorePoints()
	Local Const $iNbr = $aRP[0][0]

	ConsoleWrite($iNbr)
	ConsoleWrite($aRP[$iNbr][1])

	If $iNbr = 0 Then
		Return False
	EndIf

	Return $aRP[$iNbr][1] = 'KpRm'
EndFunc   ;==>CheckIsRestorePointExist

Func CreateSystemRestorePoint()
	CreateSystemRestorePointWmi()

	If Not CheckIsRestorePointExist() Then
		_SR_CreateRestorePoint("KpRm")

		If Not CheckIsRestorePointExist() Then
			ClearDailyRestorePoint()
			CreateSystemRestorePointPowershell()
			$bExist = CheckIsRestorePointExist()
		EndIf
	EndIf

	If Not CheckIsRestorePointExist() Then
		LogMessage("     [X] System Restore Point not created")
	Else
		LogMessage("     [OK] System Restore Point created")
	EndIf
EndFunc   ;==>CreateSystemRestorePoint

Func CreateRestorePoint()
	LogMessage(@CRLF & "- Create Restore Point -" & @CRLF)
	UpdateStatusBar("Create Restore Point ...")

	EnableRestoration()
	CreateSystemRestorePoint()
	ShowCurrentRestorePoint()
EndFunc   ;==>CreateRestorePoint
