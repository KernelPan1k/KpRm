Global $oRemoveRestart = ObjCreate("Scripting.Dictionary")
Global $bNeedRestart = False

Func AddRemoveAtRestart($sElement, $sType)
	Dim $oRemoveRestart
	Dim $bNeedRestart

	If Not $oRemoveRestart.Exists($sElement) Then
		$bNeedRestart = True
		$oRemoveRestart.Add($sElement, $sType)
	EndIf
EndFunc   ;==>AddRemoveAtRestart

Func RestartIfNeeded()
	Dim $sKPLogFile
	Dim $oRemoveRestart
	Dim $bNeedRestart
	Dim $sCurrentTime

	If $bNeedRestart = True And PowershellIsAvailable() = True Then
		Local $aKeys = $oRemoveRestart.Keys
		Local $sHomeLog = @HomeDrive & "\KPRM" & "\" & $sKPLogFile
		Local $sDesktopLog = @DesktopDir & "\" & $sKPLogFile
		Local $sScript = ''

		$sScript &= 'Add-Content "' & $sHomeLog & '" "" -Force' & @CRLF
		$sScript &= 'Add-Content "' & $sDesktopLog & '" "" -Force' & @CRLF
		$sScript &= 'Add-Content "' & $sHomeLog & '" "- Remove After Restart -" -Force' & @CRLF
		$sScript &= 'Add-Content "' & $sDesktopLog & '" "- Remove After Restart -" -Force' & @CRLF
		$sScript &= 'Add-Content "' & $sHomeLog & '" "" -Force' & @CRLF
		$sScript &= 'Add-Content "' & $sDesktopLog & '" "" -Force' & @CRLF

		For $iCpt = 0 To UBound($aKeys) - 1
			Local $sPath = $aKeys[$iCpt]
			Local $sType = $oRemoveRestart.Item($sPath)

			If $sPath And $sType Then
				If $sType = 'file' Then
					$sScript &= 'attrib -h -r -a -s "' & $sPath & '"' & @CRLF
					$sScript &= 'Remove-Item -Path "' & $sPath & '" -Force' & @CRLF
				ElseIf $sType = 'folder' Then
					$sPath = StringRegExpReplace($sPath, "\\$", "")
					$sScript &= 'attrib -h -r -a -s "' & $sPath & '\"' & @CRLF
					$sScript &= 'attrib -h -r -a -s "' & $sPath & '\*.*" /s' & @CRLF
					$sScript &= 'Remove-Item -Path "' & $sPath & '" -Force –Recurse' & @CRLF
				EndIf

				If $sType = 'file' Or $sType = 'folder' Then
					$sScript &= '$PathExists = Test-Path "' & $sPath & '"' & @CRLF
					$sScript &= '$Symbol = "[OK]"' & @CRLF
					$sScript &= 'If ($PathExists -eq $True) {$Symbol = "[X]"}' & @CRLF
					$sScript &= 'Add-Content "' & $sHomeLog & '" "     $Symbol ' & $sPath & ' deleted (restart)" -Force' & @CRLF
					$sScript &= 'Add-Content "' & $sDesktopLog & '" "     $Symbol ' & $sPath & ' deleted (restart)" -Force' & @CRLF
				EndIf
			EndIf
		Next

		$sScript &= 'Remove-Item -Path "' & @ScriptFullPath & '" -Force' & @CRLF
		$sScript &= 'notepad.exe "' & $sDesktopLog & '"' & @CRLF

		Local Const $sTasksFolder = @HomeDrive & "\KPRM\tasks"
		Local Const $sTasksPath = $sTasksFolder & "\task-" & $sCurrentTime & ".ps1"
		Local Const $sTasksLauncher = $sTasksFolder & "\task-" & $sCurrentTime & ".bat"

		If FileExists($sTasksFolder) = False Then
			DirCreate($sTasksFolder)
		EndIf

		If Not FileWrite($sTasksLauncher, "powershell.exe -ExecutionPolicy Bypass -File " & $sTasksPath) Then
			Return False
		EndIf

		Local Const $hFileOpen = FileOpen($sTasksPath, 130)

		If $hFileOpen = -1 Then
			Return False
		EndIf

		FileWrite($hFileOpen, $sScript)
		FileClose($hFileOpen)

		Local $sSuffix = GetSuffixKey()

		If Not RegWrite("HKCU" & $sSuffix & "\Software\Microsoft\Windows\CurrentVersion\RunOnce", "kprm_restart", "REG_SZ", $sTasksLauncher) Then
			Return False
		EndIf

		UpdateStatusBar("Need Restart")
		MsgBox(64, "Restart Now", $lRestart)
		Shutdown(6)
	EndIf
EndFunc   ;==>RestartIfNeeded


