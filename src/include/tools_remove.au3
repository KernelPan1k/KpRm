
Func prepareRemove($path, $recursive = 0)
	FileSetAttrib($path, "-R", $recursive)
	FileSetAttrib($path, "-A", $recursive)
	FileSetAttrib($path, "-S", $recursive)
	FileSetAttrib($path, "-H", $recursive)
EndFunc   ;==>prepareRemove

Func RemoveFile($file, $descriptionPattern = Null)
	Dim $KPDebug
	Local Const $iFileExists = FileExists($file)

	If $iFileExists Then
		If $descriptionPattern Then
			Local Const $fileDescription = FileGetVersion($file, "FileDescription")

			If @error Then
				Return 0
			ElseIf Not StringRegExp($fileDescription, $descriptionPattern) Then
				Return 0
			EndIf
		EndIf

		Local $iDelete = FileDelete($file)

		If $iDelete Then
			If $KPDebug Then
				logMessage("  [OK] File " & $file & " deleted successfully")
			EndIf

			Return 1
		EndIf

	EndIf

	Return 0

EndFunc   ;==>RemoveFile

Func RemoveFolder($path)
	Dim $KPDebug
	Local $iFileExists = FileExists($path)

	If $iFileExists Then

		prepareRemove($path, 1)

		Local Const $iDelete = DirRemove($path, $DIR_REMOVE)

		If $iDelete Then
			If $KPDebug Then
				logMessage("  [OK] Directory " & $path & " deleted successfully")
			EndIf

			Return 1
		EndIf

	EndIf

	Return 0

EndFunc   ;==>RemoveFolder

Func FindGlob($path, $file, $reg)
	Local Const $filePathGlob = $path & "\" & $file
	Local Const $hSearch = FileFindFirstFile($filePathGlob)
	Local $return = []

	If $hSearch = -1 Then
		Return $return
	EndIf

	Local $sFileName = FileFindNextFile($hSearch)

	While @error = 0
		If StringRegExp($sFileName, $reg) Then
			_ArrayAdd($return, $path & "\" & $sFileName)
		EndIf

		$sFileName = FileFindNextFile($hSearch)
	WEnd

	FileClose($hSearch)

	Return $return
EndFunc   ;==>FindGlob

Func RemoveGlobFile($path, $file, $reg, $descriptionPattern = Null)
	Local $return = 0
	Local Const $fileList = FindGlob($path, $file, $reg)
	For $i = 1 To UBound($fileList) - 1
		If $fileList[$i] And $fileList[$i] <> "" Then
			$return += RemoveFile($fileList[$i], $descriptionPattern)
		EndIf
	Next

	Return $return
EndFunc   ;==>RemoveGlobFile

Func RemoveGlobFolder($path, $file, $reg)
	Local $return = 0
	Local Const $fileList = FindGlob($path, $file, $reg)
	For $i = 1 To UBound($fileList) - 1
		If $fileList[$i] And $fileList[$i] <> "" Then
			$return += RemoveFolder($fileList[$i])
		EndIf
	Next

	Return $return
EndFunc   ;==>RemoveGlobFolder

Func RemoveRegistryKey($key)
	Dim $KPDebug
	Local Const $status = RegDelete($key)

	If $status = 1 Then
		If $KPDebug Then
			logMessage("  [OK] " & $key & " deleted successfully")
		EndIf
		Return 1
	ElseIf $status = 2 Then
		If $KPDebug Then
			logMessage("  [X] " & $key & " deleted failed")
		EndIf
	EndIf

	Return 0
EndFunc   ;==>RemoveRegistryKey

Func RemoveService($name)
	Local Const $status = RunWait(@ComSpec & " /c " & "sc query " & $name, @TempDir, @SW_HIDE)
	Local $return = 0
	Dim $KPDebug

	If $status = 1060 Then
		Return 0
	EndIf

	RunWait(@ComSpec & " /c " & "sc stop " & $name, @TempDir, @SW_HIDE)

	If @error = 0 Then
		If $KPDebug Then logMessage("  [OK] Stop service " & $name & " successfully")
		$return += 1
	EndIf

	RunWait(@ComSpec & " /c " & "sc config " & $name & " start= disabled", @TempDir, @SW_HIDE)

	If @error = 0 Then
		If $KPDebug Then logMessage("  [OK] Disable service " & $name & " successfully")
		$return += 1
	EndIf

	Local $s64Bit = ""
	If @OSArch = "X64" Then $s64Bit = "64"

	Local $key = "HKLM" & $s64Bit & "\SYSTEM\CurrentControlSet\Services\" & $name

	$return += RemoveRegistryKey($key)

	Local $key = "HKLM" & $s64Bit & "\SYSTEM\ControlSet002\Services\" & $name
	$return += RemoveRegistryKey($key)

	Return $return
EndFunc   ;==>RemoveService

Func RemoveSoftwareKey($name)
	Local $s64Bit = ""
	If @OSArch = "X64" Then $s64Bit = "64"
	Local $return = 0

	$return += RemoveRegistryKey("HKCU" & $s64Bit & "\SOFTWARE\" & $name)
	$return += RemoveRegistryKey("HKLM" & $s64Bit & "\SOFTWARE\" & $name)

	Return $return
EndFunc   ;==>RemoveSoftwareKey

Func RemoveContextMenu($name)
	Local $return = 0
	Local $s64Bit = ""
	If @OSArch = "X64" Then $s64Bit = "64"

	$return += RemoveRegistryKey("HKLM" & $s64Bit & "\SOFTWARE\Classes\*\shellex\ContextMenuHandlers\" & $name)
	$return += RemoveRegistryKey("HKLM" & $s64Bit & "\SOFTWARE\Classes\lnkfile\shellex\ContextMenuHandlers\" & $name)
	$return += RemoveRegistryKey("HKLM" & $s64Bit & "\SOFTWARE\Classes\AllFilesystemObjects\shellex\ContextMenuHandlers\" & $name)
	$return += RemoveRegistryKey("HKLM" & $s64Bit & "\Software\Classes\Directory\ShellEx\ContextMenuHandlers\" & $name)
	$return += RemoveRegistryKey("HKLM" & $s64Bit & "\Software\Classes\Directory\Background\ShellEx\ContextMenuHandlers\" & $name)
	$return += RemoveRegistryKey("HKLM" & $s64Bit & "\SOFTWARE\Classes\Drive\shellex\ContextMenuHandlers\" & $name)

	Return $return
EndFunc   ;==>RemoveContextMenu

Func CloseProcessAndWait($process)
	Local $cpt = 50
	Dim $KPDebug

	If 0 = ProcessExists($process) Then Return 0

	ProcessClose($process)

	Do
		$cpt -= 1
		Sleep(250)
	Until ($cpt = 0 Or 0 = ProcessExists($process))

	Local Const $status = ProcessExists($process)

	If 0 = $status Then
		If $KPDebug Then logMessage("  [OK] Porccess " & $process & " stopped successfully")
		Return 1
	EndIf

	Return 0
EndFunc   ;==>CloseProcessAndWait

Func RemoveAllProcess($processList)
	Dim $cpt

	Local $aProcessList = ProcessList()

	For $i = 1 To $aProcessList[0][0]
		Local $processName = $aProcessList[$i][0]
		Local $pid = $aProcessList[$i][1]

		For $cpt = 1 To UBound($processList) - 1
			If StringRegExp($processName, $processList[$cpt][1]) Then
				$ToolsCpt.Item($processList[$cpt][0]) += CloseProcessAndWait($pid)
			EndIf
		Next
	Next
EndFunc   ;==>RemoveAllProcess

Func RemoveScheduleTask($list)
	Dim $KPDebug
	Dim $ToolsCpt

	For $i = 1 To UBound($list) - 1
		RunWait('schtasks.exe /delete /tn ' & $list[$i][1] & ' /f', @TempDir, @SW_HIDE)

		If @error = 0 Then
			If $KPDebug Then logMessage("  [OK] RogueKiller.exe was deleted from schedule")
			$ToolsCpt.Item($list[$i][0]) += 1
		EndIf

	Next
EndFunc   ;==>RemoveScheduleTask

Func UninstallNormaly($list)
	Dim $ToolsCpt

	Local Const $ProgramFilesList = GetProgramFilesList()

	For $i = 1 To UBound($ProgramFilesList) - 1
		For $c = 1 To UBound($list) - 1
			Local $folderReg = $list[$c][1]
			Local $FileReg = $list[$c][2]

			Local $globFolder = FindGlob($ProgramFilesList[$i], "*", $folderReg)

			For $f = 1 To UBound($globFolder) - 1
				Local $uninstallFiles = FindGlob($globFolder[$f], "*", $FileReg)

				For $u = 1 To UBound($uninstallFiles) - 1
					If FileExists($uninstallFiles[$u]) Then
						RunWait($uninstallFiles[$u])
						$ToolsCpt.Item($list[$c][0]) += 1
					EndIf
				Next
			Next
		Next
	Next
EndFunc   ;==>UninstallNormaly

Func RemoveAllFileFrom($path, $list)
	Dim $ToolsCpt

	For $i = 1 To UBound($list) - 1
		$ToolsCpt.Item($list[$i][0]) += RemoveGlobFile($path, "*", $list[$i][2], $list[$i][1])
	Next
EndFunc   ;==>RemoveAllFileFrom

Func RemoveAllDirFrom($path, $list)
	Dim $ToolsCpt

	For $i = 1 To UBound($list) - 1
		$ToolsCpt.Item($list[$i][0]) += RemoveGlobFolder($path, "*", $list[$i][1])
	Next
EndFunc   ;==>RemoveAllDirFrom

Func RemoveAllProgramFilesDir($list)
	$ProgramFilesList = GetProgramFilesList()

	For $i = 1 To UBound($ProgramFilesList) - 1
		RemoveAllDirFrom($ProgramFilesList[$i], $list)
	Next
EndFunc   ;==>RemoveAllProgramFilesDir

Func RemoveAllSoftwareKeyList($list)
	Dim $ToolsCpt
	Local $s64Bit = ""
	If @OSArch = "X64" Then $s64Bit = "64"
	Local $keys[2] = ["HKCU" & $s64Bit & "\SOFTWARE\", "HKLM" & $s64Bit & "\SOFTWARE\"]

	For $k = 0 To UBound($keys) - 1
		For $c = 1 To UBound($list) - 1
			$i = 0
			While True
				$i += 1
				Local $entry = RegEnumKey($keys[$k], $i)
				If @error <> 0 Then ExitLoop

				If StringRegExp($entry, $list[$c][1]) Then
					$ToolsCpt.Item($list[$c][0]) += RemoveRegistryKey($keys[$k] & $entry)
				EndIf
			WEnd
		Next
	Next
EndFunc   ;==>RemoveAllSoftwareKeyList

Func RemoveUninstallStringWithSearch($list)
	Dim $ToolsCpt

	For $i = 1 To UBound($list) - 1
		Local $keyFound = searchRegistryKeyStrings($list[$i][1], $list[$i][3], $list[$i][2])

		If $keyFound And $keyFound <> "" Then
			$ToolsCpt.Item($list[$i][0]) += RemoveRegistryKey($keyFound)
		EndIf
	Next
EndFunc   ;==>RemoveUninstallStringWithSearch
