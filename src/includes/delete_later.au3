Func AddElementToKeep($sElement, $sTool)
	Dim $aElementsToKeep

	If IsNewLine($aElementsToKeep, $sElement) Then
		_ArrayAdd($aElementsToKeep, $sElement & '~~~~' & $sTool, 0, '~~~~')
	EndIf
EndFunc   ;==>AddElementToKeep

Func WriteErrorMessage($sMessage)
	LogMessage(@CRLF & "- Errors -" & @CRLF)

	For $i = 1 To UBound($aElementsToKeep) - 1
		LogMessage("    ~ " & $sMessage)
	Next
EndFunc   ;==>WriteErrorMessage

Func SetDeleteQuarantinesIn7DaysIfNeeded()
	Dim $bDeleteQuarantines
	Dim $sCurrentTime
	Dim $aElementsToKeep

	If $bDeleteQuarantines <> 7 Then Return
	If UBound($aElementsToKeep) = 1 Then Return

	Local Const $sTasksFolder = @HomeDrive & "\KPRM\tasks-quarantines"
	Local Const $sTasksPath = $sTasksFolder & "\task-" & $sCurrentTime & ".txt"

	If FileExists($sTasksFolder) = False Then
		DirCreate($sTasksFolder)
	EndIf

	Local $sBinaryPath = @AutoItExe

	If Not @Compiled Then $sBinaryPath = @ScriptFullPath

	If Not FileExists($sTasksFolder & '\kprm-quarantines.exe') Then
		FileCopy($sBinaryPath, $sTasksFolder & '\kprm-quarantines.exe')
	EndIf

	If Not FileExists($sTasksFolder & '\kprm-quarantines.exe') Then
		Return WriteErrorMessage("Unable to copy binary in " & $sTasksFolder & '\kprm-quarantines.exe')
	EndIf

	Local $hFileOpen = FileOpen($sTasksPath, $FO_APPEND)

	If $hFileOpen = -1 Then
		Return WriteErrorMessage("Unable to open tasks file for writing")
	EndIf

	For $i = 1 To UBound($aElementsToKeep) - 1
		FileWriteLine($hFileOpen, $aElementsToKeep[$i][0])
	Next

	FileClose($hFileOpen)

	Local $sStartDateTime = _DateAdd('d', 7, _NowCalc())
	$sStartDateTime = StringReplace($sStartDateTime, "/", "-")
	$sStartDateTime = StringReplace($sStartDateTime, " ", "T")

	Local $sEndDateTime = _DateAdd("M", 4, _NowCalc())
	$sEndDateTime = StringReplace($sEndDateTime, "/", "-")
	$sEndDateTime = StringReplace($sEndDateTime, " ", "T")

	Local Const $sTaskFolderName = "KpRm-quarantines"
	Local Const $sTaskName = "KpRm-quarantines-" & $sCurrentTime
	Local $iTest

	$iTest = _TaskFolderExists($sTaskFolderName)

	If $result <> 1 Then
		$iTest = _TaskFolderCreate($sTaskFolderName)

		If $iTest <> 1 Then
			Return WriteErrorMessage("The folder with the name " & $sTaskFolderName & " was not created successfully")
		EndIf
	EndIf

	$iTest = _TaskCreate($sTaskFolderName & "\" & $sTaskName, _
			"KpRm shedule quarantines deletion", _
			1, _
			$sStartDateTime, _
			$sEndDateTime, _
			Null, _
			Null, _
			Null, _
			Null, _
			Null, _
			"PT5M", _
			False, _
			3, _
			1, _
			"", _
			"", _
			$sTasksFolder & '\kprm-quarantines.exe', _
			$sTasksFolder, _
			"quarantines " & $sCurrentTime, _
			False)

	If $iTest <> 1 Then
		Return WriteErrorMessage("The task with the name " & $sTaskName & " was not created successfully")
	EndIf
EndFunc   ;==>SetDeleteQuarantinesIn7DaysIfNeeded

Func RemoveQuarantines($sTaskTime)
	Local Const $sTasksFolder = @HomeDrive & "\KPRM\tasks-quarantines"
	Local Const $sTasksPath = $sTasksFolder & "\task-" & $sTaskTime & ".txt"
	Local Const $sKPReportFile = "kprm-" & $sTaskTime & ".txt"
	Local Const $sHomeReport = @HomeDrive & "\KPRM" & "\" & $sKPReportFile
	Local Const $sDesktopReport = @DesktopDir & "\" & $sKPReportFile
	Local Const $bHomeReportExist = FileExists($sHomeReport)
	Local Const $bDesktopReportExist = FileExists($sDesktopReport)

	If FileExists($sTasksPath) = 1 Then

		If $bHomeReportExist = True Then
			FileWrite($sHomeReport, @CRLF & "- Deletions scheduled (" & _NowCalcDate() & ") -" & @CRLF)
		EndIf

		If $bDesktopReportExist = True Then
			FileWrite($sDesktopReport, @CRLF & "- Deletions scheduled (" & _NowCalcDate() & ") -" & @CRLF)
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
				Local $bExist = FileExists($sLine)

				If $bExist = True Then
					$sSymbol = "[X]"
				EndIf

				Local $sMessage = "     " & $sSymbol & " " & $sLine & " deleted (after 7 days)"

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

	Local $sBinaryPath = @AutoItExe

	If Not @Compiled Then $sBinaryPath = @ScriptFullPath

	If @Compiled Then
		Run(@ComSpec & ' /c timeout 3 && del /F /Q "' & @AutoItExe & '"', @TempDir, @SW_HIDE)
		FileDelete(@AutoItExe)
	EndIf

	Exit
EndFunc   ;==>RemoveQuarantines

