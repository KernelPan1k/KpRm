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
	Local Const $sSuffixKey = GetSuffixKey()

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

	For $i = 1 To UBound($aElementsToKeep) - 1
		Local $sPath = StringReplace($aElementsToKeep[$i][0], "\", "\\")
		RegWrite("HKLM" & $sSuffixKey & "\Software\KPRM\quarantines\" & $sCurrentTime, $i, "REG_SZ", $sPath)
	Next

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
	Local Const $sKPReportFile = "kprm-" & $sTaskTime & ".txt"
	Local Const $sHomeReport = @HomeDrive & "\KPRM" & "\" & $sKPReportFile
	Local Const $sDesktopReport = @DesktopDir & "\" & $sKPReportFile
	Local Const $bHomeReportExist = FileExists($sHomeReport)
	Local Const $bDesktopReportExist = FileExists($sDesktopReport)
	Local Const $sSuffixKey = GetSuffixKey()
	Local Const $sKey = "HKLM" & $sSuffixKey & "\Software\KPRM\quarantines"
	Local Const $sKeyTime = $sKey & "\" & $sTaskTime

	If $bHomeReportExist = True Then
		FileWrite($sHomeReport, @CRLF & "- Deletions scheduled (" & _NowCalcDate() & ") -" & @CRLF)
	EndIf

	If $bDesktopReportExist = True Then
		FileWrite($sDesktopReport, @CRLF & "- Deletions scheduled (" & _NowCalcDate() & ") -" & @CRLF)
	EndIf

	For $i = 1 To 10000
		Local $sVal = RegEnumVal($sKeyTime, $i)
		If @error <> 0 Then ExitLoop

		Local $sElementPath = RegRead($sKeyTime, $sVal)
		If @error <> 0 Then ExitLoop

		Local $sPath = StringReplace($sElementPath, "\\", "\")
		If $sPath = "" Then ContinueLoop

		If IsFile($sPath) Then
			RemoveTheFile($sPath)
		ElseIf IsDir($sPath) Then
			RemoveTheFolder($sPath)
		Else
			ContinueLoop
		EndIf

		If $bHomeReportExist = True Or $bDesktopReportExist = True Then
			Local $sSymbol = "[OK]"
			Local $bExist = FileExists($sPath)

			If $bExist = True Then
				$sSymbol = "[R]"
			EndIf

			Local $sMessage = "     " & $sSymbol & " " & $sPath & " deleted (after 7 days)"

			If $bHomeReportExist = True Then
				FileWrite($sHomeReport, $sMessage & @CRLF)
			EndIf

			If $bDesktopReportExist = True Then
				FileWrite($sDesktopReport, $sMessage & @CRLF)
			EndIf
		EndIf
	Next

	Local $hasRemainingTasks = True

	RegDelete($sKeyTime)
	RegEnumVal($sKey, "1")

	If @error <> 0 Then
		Local $hasRemainingTasks = False
		RegDelete($sKey)
	EndIf

	RegEnumVal("HKLM" & $sSuffixKey & "\Software\KPRM", "1")

	If @error <> 0 Then
		Local $hasRemainingTasks = False
		RegDelete("HKLM" & $sSuffixKey & "\Software\KPRM")
	EndIf

	Local Const $sSheduleTaskFolderName = "KpRm-quarantines"
	Local Const $sScheduleTaskName = "KpRm-quarantines-" & $sTaskTime
	Local $iTest

	$iTest = _TaskDelete($sScheduleTaskName, $sSheduleTaskFolderName)

	If $iTest <> 1 Then
		Exit
	EndIf

	$iTest = _TaskListAll($sSheduleTaskFolderName)

	If @error <> 0 Then
		Exit
	EndIf

	Local Const $aTaskListSplitted = StringSplit($iTest, "|")
	Local Const $bHasEmptyTaskFolder = $aTaskListSplitted[0] = 1 And $aTaskListSplitted[1] = ""

	If $bHasEmptyTaskFolder = True Then
		_TaskFolderDelete($sSheduleTaskFolderName)

		If $hasRemainingTasks Then
			RegDelete($sKey)
		EndIf

		HaraKiri()
	ElseIf $hasRemainingTasks = False Then
		For $i = 1 To UBound($aTaskListSplitted) - 1
			_TaskDelete($aTaskListSplitted[$i], $sSheduleTaskFolderName)
		Next

		_TaskFolderDelete($sSheduleTaskFolderName)

		HaraKiri()
	EndIf

	Exit
EndFunc   ;==>RemoveQuarantines
