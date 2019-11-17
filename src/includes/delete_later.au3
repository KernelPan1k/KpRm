Global $aElementsToKeep[1][2] = [[]]
Local Const $sDelim = '~~~~'
Local $aValToRemove = []

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

	Local Const $sKey = "HKCU" & $sSuffix & "\Software\Microsoft\Windows\CurrentVersion\RunOnce"
	Local Const $sVal = "kprm_quarantines"

	RegRead($sKey, $sVal)

	If @error <> 0 Then
		If Not RegWrite($sKey, $sVal, "REG_SZ", '"' & $sTasksFolder & '\kprm-quarantines.exe" quarantines') Then
			_ArrayAdd($aDebug, "Unable to write RunOnce key")
		EndIf
	EndIf

	If UBound($aDebug) > 1 Then
		LogMessage(@CRLF & "- Errors -" & @CRLF)

		For $i = 1 To UBound($aElementsToKeep) - 1
			LogMessage("    ~ " & $aDebug[$i])
		Next
	EndIf
EndFunc   ;==>SetDeleteQuarantinesIn7DaysIfNeeded

Func CurrentQuarantineTask($sVal, $sDate)
	Local Const $sNow = _NowCalcDate()
	Local Const $sTasksFolder = @HomeDrive & "\KPRM\tasks-quarantines"
	Local Const $sTasksPath = $sTasksFolder & "\task-" & $sVal & ".txt"
	Local Const $sKPReportFile = "kprm-" & $sVal & ".txt"
	Local Const $sHomeReport = @HomeDrive & "\KPRM" & "\" & $sKPReportFile
	Local Const $sDesktopReport = @DesktopDir & "\" & $sKPReportFile
	Local Const $bHomeReportExist = FileExists($sHomeReport)
	Local Const $bDesktopReportExist = FileExists($sDesktopReport)

	If FileExists($sTasksPath) Then
		If $sDate <= $sNow Then
			_ArrayAdd($aValToRemove, $sVal)

			If $bHomeReportExist = True Then
				FileWrite($sHomeReport, @CRLF & "- Deletions (" & $sDate & ") -" & @CRLF)
			EndIf

			If $bDesktopReportExist = True Then
				FileWrite($sDesktopReport, @CRLF & "- Deletions (" & $sDate & ") -" & @CRLF)
			EndIf

			FileOpen($sTasksPath, 0)

			For $i = 1 To _FileCountLines($sTasksPath)
				Local $sLine = FileReadLine($sTasksPath, $i)
				$sLine = StringStripWS($sLine, $STR_STRIPLEADING + $STR_STRIPTRAILING)

				If $sLine = "" Then ContinueLoop

				If IsFile($sLine) Then
					PrepareRemove($sLine, 0, "1")
					FileDelete($sLine)
				ElseIf IsDir($sLine) Then
					PrepareRemove($sLine, 1, "1")
					DirRemove($sLine, $DIR_REMOVE)
				EndIf

				If $bHomeReportExist = True Or $bDesktopReportExist = True Then
					Local $sSymbol = "[OK]"
					Local $sMessage = "     " & $sSymbol & " " & $sLine & " deleted (after 7 days)"
					Local $bExist = FileExists($sLine)

					If $bExist = True Then
						$sSymbol = "[X]"
					EndIf

					If $bHomeReportExist = True Then
						FileWrite($sHomeReport, $sMessage & @CRLF)
					EndIf

					If $bDesktopReportExist = True Then
						FileWrite($sDesktopReport, $sMessage & @CRLF)
					EndIf
				EndIf
			Next

			FileClose($sTasksPath)
		EndIf
	Else
		_ArrayAdd($aValToRemove, $sVal)
	EndIf
EndFunc   ;==>CurrentQuarantineTask

Func RemoveQuarantines()
	Local $sSuffix = GetSuffixKey()
	Local Const $sKey = "HKCU" & $sSuffix & "\Software\KPRM\Quarantines"

	Local $i = 1
	Local $sValue = RegEnumVal($sKey, $i)

	While @error = 0 And $i <= 100
		$i += 1
		$sDate = RegRead($sKey, $sValue)
		CurrentQuarantineTask($sValue, $sDate)
		$sValue = RegEnumVal($sKey, $i)
	WEnd

;~ 	TODO
EndFunc   ;==>RemoveQuarantines
