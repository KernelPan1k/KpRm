#include-once
#RequireAdmin
#AutoIt3Wrapper_Run_AU3Check=Y
#AutoIt3Wrapper_Au3Check_Parameters=-d -w 1 -w 2 -w 3 -w- 4 -w 5 -w 6 -w 7

; #INDEX# =======================================================================================================================
; Title .........: SystemRestore
; Description ...: Functions to manage the system retore. This includes create, enum and delete restore points.
; Author(s) .....: Fred (FredAI)
; Modified.......: mLipok
; Dll(s) ........: SrClient.dll
; URL ...........: https://www.autoitscript.com/forum/topic/134628-system-restore-udf/
; ===============================================================================================================================

; #CURRENT# =====================================================================================================================
; _SR_CreateRestorePoint
; _SR_EnumRestorePoints
; _SR_RemoveRestorePoint
; _SR_RemoveAllRestorePoints
; _SR_Enable
; _SR_Disable
; _SR_Restore
; ===============================================================================================================================

; #MODIFIED/IMPLEMENTED# =====================================================================================================================
; __SR_WMIDateStringToDate
; ===============================================================================================================================

;Creating the WMI objects with global scope will prevent creating them more than once, to save resources...
Global $__g_oSR = Null, $__g_oSR_WMI = Null
Global $__g_sSR_SystemDrive = EnvGet('SystemDrive') & '\'

; #FUNCTION# ====================================================================================================================
; Name...........: _SR_CreateRestorePoint
; Description ...: Creates a system restore point
; Syntax.........: _SR_CreateRestorePoint($strDescription)
; Parameters ....: $strDescription - The system restore point's description. Can have up to 256 characters.
; Return values .: 	Success - 1
;					Failure - 0 Sets @error to 1 if an error occurs when calling the dll function.
; Author ........: FredAI
; Modified.......:
; Remarks .......: The system restore takes a few seconds to update. According to MSDN, this function doesn't work in safe mode.
; Related .......: _SR_RemoveRestorePoint
; Link ..........:
; Example .......: _SR_CreateRestorePoint('My restore point')
; ===============================================================================================================================
Func _SR_CreateRestorePoint($strDescription)
	Local Const $MAX_DESC = 64
	#forceref $MAX_DESC
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
	If @error Then _
			Return 0
	Return $aRet[0]
EndFunc   ;==>_SR_CreateRestorePoint

; #FUNCTION# ====================================================================================================================
; Name...........: _SR_EnumRestorePoints
; Description ...: Enumerates all existing restore points.
; Syntax.........: _SR_EnumRestorePoints()
; Parameters ....: None
; Return values .: 	Success - An array with info on the restore points:
;							$Array[0][0] => Number of restore points.
;							$Array[n][1] => Restore point's sequence number.
;							$Array[n][2] => Restore point's description.
;							$Array[n][3] => Restore point's creation date.
;					Failure - An empty bi-dimensinal array where $Array[0][0] = 0.
; Author ........: FredAI
; Modified.......: mLipok
; Remarks .......:
; Related .......: _SR_RemoveAllRestorePoints()
; Link ..........:
; Example .......: Local $aRestorePoints = _SR_EnumRestorePoints()
; ===============================================================================================================================
Func _SR_EnumRestorePoints()
	Local $aRestorePoints[1][3], $iCounter = 0
	$aRestorePoints[0][0] = $iCounter
	If Not IsObj($__g_oSR_WMI) Then $__g_oSR_WMI = ObjGet("winmgmts:root/default")
	If Not IsObj($__g_oSR_WMI) Then _
			Return $aRestorePoints
	Local $RPSet = $__g_oSR_WMI.InstancesOf("SystemRestore")
	If Not IsObj($RPSet) Then _
			Return $aRestorePoints
	For $RP In $RPSet
		$iCounter += 1
		ReDim $aRestorePoints[$iCounter + 1][3]
		$aRestorePoints[$iCounter][0] = $RP.SequenceNumber
		$aRestorePoints[$iCounter][1] = $RP.Description
		$aRestorePoints[$iCounter][2] = __SR_WMIDateStringToDate($RP.CreationTime)
	Next
	$aRestorePoints[0][0] = $iCounter
	Return $aRestorePoints
EndFunc   ;==>_SR_EnumRestorePoints

Func __SR_WMIDateStringToDate($dtmDate)
	Return _
			(StringMid($dtmDate, 5, 2) & "/" & _
			StringMid($dtmDate, 7, 2) & "/" & _
			StringLeft($dtmDate, 4) & " " & _
			StringMid($dtmDate, 9, 2) & ":" & _
			StringMid($dtmDate, 11, 2) & ":" & _
			StringMid($dtmDate, 13, 2))
EndFunc   ;==>__SR_WMIDateStringToDate

; #FUNCTION# ====================================================================================================================
; Name...........: _SR_RemoveRestorePoint
; Description ...: Deletes a system restore point.
; Syntax.........: _SR_RemoveRestorePoint($rpSeqNumber)
; Parameters ....: $rpSeqNumber - The system restore point's sequence number. can be obtained with _SR_EnumRestorePoints
; Return values .: 	Success - 1
;					Failure - 0 and sets @error
; Author ........: FredAI
; Modified.......:
; Remarks .......: The system restore takes a few seconds to update. According to MSDN, this function doesn't work in safe mode.
; Related .......: _SR_RemoveAllRestorePoints
; Link ..........:
; Example .......: _SR_RemoveRestorePoint(20)
; ===============================================================================================================================
Func _SR_RemoveRestorePoint($rpSeqNumber)
	Local $aRet = DllCall('SrClient.dll', 'DWORD', 'SRRemoveRestorePoint', 'DWORD', $rpSeqNumber)
	If @error Then _
			Return SetError(1, 0, 0)
	If $aRet[0] = 0 Then _
			Return 1
	Return SetError(1, 0, 0)
EndFunc   ;==>_SR_RemoveRestorePoint

; #FUNCTION# ====================================================================================================================
; Name...........: _SR_RemoveAllRestorePoints
; Description ...: Deletes all existing system restore points.
; Syntax.........: _SR_RemoveAllRestorePoints()
; Parameters ....: None
; Return values .: 	Success - The number of deleted restore points.
;					Failure - Returns 0 if no restore points existed or an error occurred.
; Author ........: FredAI
; Modified.......:
; Remarks .......: The system restore takes a few seconds to update. According to MSDN, this function doesn't work in safe mode.
; Related .......: _SR_RemoveRestorePoint
; Link ..........:
; Example .......: Local $iSR_Deleted = _SR_RemoveAllRestorePoints()
; ===============================================================================================================================
Func _SR_RemoveAllRestorePoints()
	Local $aRP = _SR_EnumRestorePoints(), $ret = 0
	For $i = 1 To $aRP[0][0]
		$ret += _SR_RemoveRestorePoint($aRP[$i][0])
	Next
	Return $ret
EndFunc   ;==>_SR_RemoveAllRestorePoints

; #FUNCTION# ====================================================================================================================
; Name...........: _SR_Enable
; Description ...: Enables the system restore.
; Syntax.........: _SR_Enable($DriveL = $__g_sSR_SystemDrive)
; Parameters ....: $DriveL: The letter of the hard drive to monitor. Defaults to the system drive (Usually C:). See remarks.
; Return values .: 	Success - 1.
;					Failure - 0
; Author ........: FredAI
; Modified.......:
; Remarks .......: Acording to MSDN, setting a blank string as the drive letter, will enable the system restore for all drives,
;					+but some tests revealed that, on Windows 7, only the system drive is enabled.
;					+This parameter must end with a backslash. e.g. C:\
; Related .......: _SR_Disable
; Link ..........:
; Example .......: Local $iSR_Enabled = _SR_Enable()
; ===============================================================================================================================
Func _SR_Enable($DriveL = $__g_sSR_SystemDrive)
	If Not IsObj($__g_oSR) Then $__g_oSR = ObjGet("winmgmts:{impersonationLevel=impersonate}!root/default:SystemRestore")
	If Not IsObj($__g_oSR) Then _
			Return 0
	If $__g_oSR.Enable($DriveL) = 0 Then _
			Return 1
	Return 0
EndFunc   ;==>_SR_Enable

; #FUNCTION# ====================================================================================================================
; Name...........: _SR_Disable
; Description ...: Disables the system restore.
; Syntax.........: _SR_Disable($DriveL = $__g_sSR_SystemDrive)
; Parameters ....: $DriveL: The letter of the hard drive to disable monitoring. Defaults to the system drive (Usually C:). See remarks.
; Return values .: 	Success - 1.
;					Failure - 0
; Author ........: FredAI
; Modified.......:
; Remarks .......: Acording to MSDN, setting a blank string as the drive letter, will enable the system restore for all drives,
;					+but some tests revealed that, on Windows 7, only the system drive is enabled.
;					+This parameter must end with a backslash. e.g. C:\
; Related .......: _SR_Enable()
; Link ..........:
; Example .......: Local $iSR_disabled = _SR_Disable()
; ===============================================================================================================================
Func _SR_Disable($DriveL = $__g_sSR_SystemDrive)
	If Not IsObj($__g_oSR) Then $__g_oSR = ObjGet("winmgmts:{impersonationLevel=impersonate}!root/default:SystemRestore")
	If Not IsObj($__g_oSR) Then _
			Return 0
	If $__g_oSR.Disable($DriveL) = 0 Then _
			Return 1
	Return 0
EndFunc   ;==>_SR_Disable

; #FUNCTION# ====================================================================================================================
; Name...........: _SR_Restore
; Description ...: Initiates a system restore. The caller must force a system reboot. The actual restoration occurs during the reboot.
; Syntax.........: _SR_Restore($rpSeqNumber)
; Parameters ....: $rpSeqNumber - The system restore point's sequence number. Can be obtained with _SR_EnumRestorePoints
; Return values .: 	Success - 1.
;					Failure - 0
; Author ........: FredAI
; Modified.......:
; Remarks .......: After calling this function, call Shutdown(2) to reboot.
; Related .......: _SR_EnumRestorePoints
; Link ..........:
; Example .......: If _SR_Restore(20) Then Shutdown(2)
; ===============================================================================================================================
Func _SR_Restore($rpSeqNumber)
	If Not IsObj($__g_oSR) Then $__g_oSR = ObjGet("winmgmts:{impersonationLevel=impersonate}!root/default:SystemRestore")
	If Not IsObj($__g_oSR) Then _
			Return 0
	If $__g_oSR.Restore($rpSeqNumber) = 0 Then _
			Return 1
	Return 0
EndFunc   ;==>_SR_Restore
