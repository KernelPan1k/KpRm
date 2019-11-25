Func AddElementToKeep($sElement, $sTool)
	Dim $aElementsToKeep

	If IsNewLine($aElementsToKeep, $sElement) Then
		_ArrayAdd($aElementsToKeep, $sElement & '~~~~' & $sTool, 0, '~~~~')
	EndIf
EndFunc   ;==>AddElementToKeep

Func WriteErrorMessage($sMessage)
	LogMessage(@CRLF & "- Errors -" & @CRLF)
	LogMessage("    ~ " & $sMessage)
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

	If $iTest <> 1 Then
		$iTest = _TaskFolderCreate($sTaskFolderName)

		If $iTest <> 1 Then
			Return WriteErrorMessage("The folder with the name " & $sTaskFolderName & " was not created successfully")
		EndIf
	EndIf

	$iTest = _TaskCreate($sTaskFolderName & "\" & $sTaskName, _ ;task Folder \ Name
			"KpRm shedule quarantines deletion", _ ; Description
			1, _ ; TASK_TRIGGER_TIME
			$sStartDateTime, _ ; Start time
			$sEndDateTime, _ ; End time
			Null, _ ; Unused
			Null, _ ; Unused
			Null, _ ; Unused
			Null, _ ; Unused
			Null, _ ; Unused
			"PT5M", _ ; Start 5 minutes after logon
			False, _ ; Disable interval
			3, _ ; User must already be logged in
			1, _ ; Runlevel highest
			"", _ ; Username
			"", _ ; Password
			$sTasksFolder & '\kprm-quarantines.exe', _ ; Full Path and Programname to run
			$sTasksFolder, _ ; Execution directory
			"quarantines " & $sCurrentTime, _ ; Arguments
			False) ; RunOnly If Network Available

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
			Else
				ContinueLoop
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

	Local Const $sSheduleTaskFolderName = "KpRm-quarantines"
	Local Const $sScheduleTaskName = "KpRm-quarantines-" & $sTaskTime
	Local $iTest

	$iTest = _TaskDelete($sScheduleTaskName, $sSheduleTaskFolderName)

	If $iTest <> 1 Then
		WriteErrorMessage("Error durring deletetion " & $sScheduleTaskName)
		Exit
	EndIf

	$iTest = _TaskListAll($sSheduleTaskFolderName)

	If @error <> 0 Then
		WriteErrorMessage("Tasks could not be listed in " & $sScheduleTaskName)
		Exit
	EndIf

	Local Const $aTaskListSplitted = StringSplit($iTest, "|")
	Local Const $bHasEmptyTaskFolder = $aTaskListSplitted[0] = 1 And $aTaskListSplitted[1] = ""

	If $bHasEmptyTaskFolder = True Then
		_TaskFolderDelete($sSheduleTaskFolderName)
		HaraKiri()
	EndIf

	Exit
EndFunc   ;==>RemoveQuarantines

