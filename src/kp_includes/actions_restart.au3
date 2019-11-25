Func AddRemoveAtRestart($sElement)
	Dim $aRemoveRestart
	Dim $bNeedRestart = True

	If _ArraySearch($aRemoveRestart, $sElement) = -1 Then
		_ArrayAdd($aRemoveRestart, $sElement)
	EndIf
EndFunc   ;==>AddRemoveAtRestart

Func RestartIfNeeded()
	Dim $aRemoveRestart
	Dim $bNeedRestart
	Dim $sCurrentTime

	If $bNeedRestart = True And UBound($aRemoveRestart) > 1 Then
		Local Const $sTasksFolder = @HomeDrive & "\KPRM\tasks"
		Local Const $sTasksPath = $sTasksFolder & "\task-" & $sCurrentTime & ".txt"

		If FileExists($sTasksFolder) = False Then
			DirCreate($sTasksFolder)
		EndIf

		Local $hFileOpen = FileOpen($sTasksPath, $FO_APPEND)

		If $hFileOpen = -1 Then
			Return False
		EndIf

		For $i = 1 To UBound($aRemoveRestart) - 1
			FileWriteLine($hFileOpen, $aRemoveRestart[$i])
		Next

		FileClose($hFileOpen)

		Local $sSuffix = GetSuffixKey()
		Local $sBinaryPath = @AutoItExe

		If Not @Compiled Then $sBinaryPath = @ScriptFullPath

		If Not RegWrite("HKLM" & $sSuffix & "\Software\Microsoft\Windows\CurrentVersion\RunOnce", "kprm_restart", "REG_SZ", '"' & $sBinaryPath & '" "restart" "' & $sCurrentTime & '"') Then
			Return False
		EndIf

		UpdateStatusBar("Need Restart")
		MsgBox(64, "Restart Now", $lRestart)
		Shutdown(6)
	EndIf
EndFunc   ;==>RestartIfNeeded

Func ExecuteScriptFile($sReportTime)
	Dim $bKpRmDev

	Local Const $sKPReportFile = "kprm-" & $sReportTime & ".txt"
	Local Const $sHomeReport = @HomeDrive & "\KPRM" & "\" & $sKPReportFile
	Local Const $sDesktopReport = @DesktopDir & "\" & $sKPReportFile
	Local Const $sTasksFile = @HomeDrive & "\KPRM\tasks\task-" & $sReportTime & ".txt"

	If Not FileExists($sTasksFile) Then Exit
	If Not FileExists($sHomeReport) Then Exit
	If Not FileExists($sDesktopReport) Then Exit

	FileWrite($sHomeReport, @CRLF & @CRLF & "- Remove After Restart -" & @CRLF)
	FileWrite($sDesktopReport, @CRLF & @CRLF & "- Remove After Restart -" & @CRLF)

	FileOpen($sTasksFile, 0)

	For $i = 1 To _FileCountLines($sTasksFile)
		Local $sLine = FileReadLine($sTasksFile, $i)
		$sLine = StringStripWS($sLine, $STR_STRIPLEADING + $STR_STRIPTRAILING)

		If $sLine = "" Then ContinueLoop

		If IsFile($sLine) Then
			PrepareRemove($sLine, 0, "1")
			FileDelete($sLine)
		ElseIf IsDir($sLine) Then
			PrepareRemove($sLine, 1, "1")
			DirRemove($sLine, $DIR_REMOVE)
		ElseIf IsRegistryKey($sLine) Then
			_ClearObjectDacl($sLine)
			_GrantAllAccess($sLine, $SE_REGISTRY_KEY)
			RegDelete($sLine)
		Else
			ContinueLoop
		EndIf

		Local $sSymbol = "[OK]"

		If IsRegistryKey($sLine) Then
			RegEnumVal($sLine, "1")

			If @error >= 0 Then
				$sSymbol = "[X]"
			EndIf
		ElseIf FileExists($sLine) = True Then
			$sSymbol = "[X]"
		EndIf

		Local $sMessage = "     " & $sSymbol & " " & $sLine & " deleted (restart)"

		FileWrite($sHomeReport, $sMessage & @CRLF)
		FileWrite($sDesktopReport, $sMessage & @CRLF)
	Next

	FileClose($sTasksFile)

	OpenReport($sHomeReport)
	HaraKiri()

	Exit
EndFunc   ;==>ExecuteScriptFile

