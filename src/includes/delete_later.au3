Global $aElementsToKeep[1][2] = [[]]
Local Const $sDelim = '~~~~'

Func AddElementToKeep($sElement)
	Dim $aElementsToKeep

	Local $aSplit = StringSplit($sElement, $sDelim)

	If IsNewLine($aElementsToKeep, $aSplit[0]) Then
		_ArrayAdd($aElementsToKeep, $sElement, 0, $sDelim)
	EndIf
EndFunc   ;==>AddElementToKeep


Func SetDeleteQuarantinesIn7DaysIfNeeded()
	Dim $bDeleteQuarantines
	Dim $sCurrentTime

	Local $aDebug = []

	If $bDeleteQuarantines <> 7 Then Return
	If UBound($aElementsToKeep) = 1 Then Return

	Local Const $sTasksFolder = @HomeDrive & "\KPRM\tasks-quarantines"
	Local Const $sTasksPath = $sTasksFolder & "\task-" & $sCurrentTime & ".txt"

	If FileExists($sTasksFolder) = False Then
		DirCreate($sTasksFolder)
	EndIf

	If Not FileExists($sTasksFolder & '\kprm-quarantines.exe') Then
		FileCopy(@ScriptFullPath, $sTasksFolder & '\kprm-quarantines.exe')
	EndIf

	If Not FileExists($sTasksFolder & '\kprm-quarantines.exe') Then
		_ArrayAdd($aDebug, "Unable to copy binary in " & $sTasksFolder & '\kprm-quarantines.exe')
	EndIf

	Local $hFileOpen = FileOpen($sTasksPath, $FO_APPEND)

	If $hFileOpen = -1 Then
		_ArrayAdd($aDebug, "Unable to open tasks file for writing")
	Else
		For $i = 1 To UBound($aElementsToKeep) - 1
			FileWriteLine($hFileOpen, $aElementsToKeep[$i][0])
		Next

		FileClose($hFileOpen)
	EndIf

	Local $sSuffix = GetSuffixKey()

	If Not RegWrite("HKCU" & $sSuffix & "\Software\KPRM\Quarantines", $sCurrentTime, "REG_SZ", _DateAdd('d', 7, _NowCalcDate())) Then
		_ArrayAdd($aDebug, "Unable to write Software key")
	EndIf

	If Not RegWrite("HKCU" & $sSuffix & "\Software\Microsoft\Windows\CurrentVersion\RunOnce", "kprm_quarantines_" & $sCurrentTime, "REG_SZ", '"' & $sTasksFolder & '\kprm-quarantines.exe' & '" quarantines ' & $sCurrentTime) Then
		_ArrayAdd($aDebug, "Unable to write RunOnce key")
	EndIf

	If UBound($aDebug) > 1 Then
		LogMessage(@CRLF & "- Errors -" & @CRLF)

		For $i = 1 To UBound($aElementsToKeep) - 1
			LogMessage("    ~ " & $aDebug[$i])
		Next
	EndIf
EndFunc   ;==>SetDeleteQuarantinesIn7DaysIfNeeded
