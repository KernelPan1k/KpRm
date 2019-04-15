
Func prepareRemove($path, $recursive = 0, $force = False)
	Dim $KPDebug

	If $KPDebug Then logMessage("[I] prepareRemove " & $path)

	If $force Then
		_ClearObjectDacl($path)
		_GrantAllAccess($path)
	EndIf

	Local Const $attrib = FileGetAttrib($path)

	If StringInStr($attrib, "R") Then
		FileSetAttrib($path, "-R", $recursive)
	EndIf

	If StringInStr($attrib, "S") Then
		FileSetAttrib($path, "-S", $recursive)
	EndIf

	If StringInStr($attrib, "H") Then
		FileSetAttrib($path, "-H", $recursive)
	EndIf

	If StringInStr($attrib, "A") Then
		FileSetAttrib($path, "-A", $recursive)
	EndIf
EndFunc   ;==>prepareRemove

Func RemoveFile($file, $descriptionPattern = Null, $force = False)
	Dim $KPDebug

	If $KPDebug Then logMessage("[I] RemoveFile " & $file)
	Local Const $iFileExists = isFile($file)

	If $iFileExists Then
		If $descriptionPattern And StringRegExp($file, "(?i)\.exe$") Then
			Local Const $companyName = FileGetVersion($file, "CompanyName")

			If @error Then
				Return 0
			ElseIf Not StringRegExp($companyName, $descriptionPattern) Then
				Return 0
			EndIf
		EndIf

		prepareRemove($file, 0, $force)

		Local $iDelete = FileDelete($file)

		If $iDelete Then
			If $KPDebug Then
				logMessage("  [OK] File " & $file & " deleted successfully")
			EndIf

			Return 1
		EndIf

		Return 2

	EndIf

	Return 0

EndFunc   ;==>RemoveFile

Func RemoveFolder($path, $force = False)
	Dim $KPDebug

	If $KPDebug Then logMessage("[I] RemoveFolder " & $path)
	Local $iFileExists = IsDir($path)

	If $iFileExists Then

		prepareRemove($path, 1, $force)

		Local Const $iDelete = DirRemove($path, $DIR_REMOVE)

		If $iDelete Then
			If $KPDebug Then
				logMessage("  [OK] Directory " & $path & " deleted successfully")
			EndIf

			Return 1
		EndIf

		Return 2

	EndIf

	Return 0

EndFunc   ;==>RemoveFolder

Func FindGlob($path, $file, $reg)
	Dim $KPDebug

	If $KPDebug Then logMessage("[I] FindGlob " & $path & " " & $file)

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

Func RemoveAllFileFrom($path, $elements)
	Dim $KPDebug

	If $KPDebug Then logMessage("[I] RemoveAllFileFrom " & $path)

	Dim $ToolsCpt
	Local Const $filePathGlob = $path & "\*"
	Local Const $hSearch = FileFindFirstFile($filePathGlob)

	If $hSearch = -1 Then
		Return Null
	EndIf

	Local $sFileName = FileFindNextFile($hSearch)

	While @error = 0
		For $e = 1 To UBound($elements) - 1
			Local $pathOfFile = $path & "\" & $sFileName
			Local $typeOfFile = FileExistsAndGetType($pathOfFile)

			If $typeOfFile And $elements[$e][3] And $typeOfFile = $elements[$e][1] And StringRegExp($sFileName, $elements[$e][3]) Then
				Local $toolsData = $ToolsCpt.Item($elements[$e][0])
				Local $status = 0
				Local $force = False

				If $elements[$e][4] = True Then
					$force = True
				EndIf

				If $typeOfFile = 'file' Then
					$status = RemoveFile($pathOfFile, $elements[$e][2], $force)
				ElseIf $typeOfFile = 'folder' Then
					$status = RemoveFolder($pathOfFile, $force)
				EndIf

				If $status = 1 Then
					$toolsData[0] += 1
				ElseIf $status = 2 Then
					$toolsData[1] += "  [X] " & $pathOfFile & " delete failed" & @CRLF
				EndIf

				$ToolsCpt.Item($elements[$e][0]) = $toolsData
			EndIf
		Next

		$sFileName = FileFindNextFile($hSearch)
	WEnd

	FileClose($hSearch)

EndFunc   ;==>RemoveAllFileFrom

Func RemoveRegistryKey($key)
	Dim $KPDebug

	If $KPDebug Then logMessage("[I] RemoveRegistryKey " & $key)
	Local Const $status = RegDelete($key)

	If $status = 1 Then
		If $KPDebug Then
			logMessage("  [OK] " & $key & " deleted successfully")
		EndIf
	ElseIf $status = 2 Then
		If $KPDebug Then
			logMessage("  [X] " & $key & " deleted failed")
		EndIf

	EndIf

	Return $status
EndFunc   ;==>RemoveRegistryKey

Func RemoveService($name)
	Local Const $status = RunWait(@ComSpec & " /c " & "sc query " & $name, @TempDir, @SW_HIDE)
	Local $return = 0
	Dim $KPDebug

	If $KPDebug Then logMessage("[I] RemoveService " & $name)

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
	Dim $KPDebug

	If $KPDebug Then logMessage("[I] RemoveSoftwareKey " & $name)

	Local $s64Bit = ""
	If @OSArch = "X64" Then $s64Bit = "64"
	Local $return = 0

	$return += RemoveRegistryKey("HKCU" & $s64Bit & "\SOFTWARE\" & $name)
	$return += RemoveRegistryKey("HKLM" & $s64Bit & "\SOFTWARE\" & $name)

	Return $return
EndFunc   ;==>RemoveSoftwareKey

Func RemoveContextMenu($name)
	Dim $KPDebug

	If $KPDebug Then logMessage("[I] RemoveContextMenu " & $name)

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

	If $KPDebug Then logMessage("[I] CloseProcessAndWait " & $process)

	If 0 = ProcessExists($process) Then Return 0

	ProcessClose($process)

	Do
		$cpt -= 1
		Sleep(250)
	Until ($cpt = 0 Or 0 = ProcessExists($process))

	Local Const $status = ProcessExists($process)

	If 0 = $status Then
		If $KPDebug Then logMessage("  [OK] Proccess " & $process & " stopped successfully")
		Return 1
	EndIf

	Return 0
EndFunc   ;==>CloseProcessAndWait

Func RemoveAllProcess($processList)
	Dim $cpt
	Dim $KPDebug

	If $KPDebug Then logMessage("[I] RemoveAllProcess")

	Local $aProcessList = ProcessList()

	For $i = 1 To $aProcessList[0][0]
		Local $processName = $aProcessList[$i][0]
		Local $pid = $aProcessList[$i][1]

		For $cpt = 1 To UBound($processList) - 1
			If StringRegExp($processName, $processList[$cpt][1]) Then
				Local $toolsData = $ToolsCpt.Item($processList[$cpt][0])
				Local $status = CloseProcessAndWait($pid)

				If $status Then
					$toolsData[0] += 1
				Else
					$toolsData[1] += "  [X] The process could not be stopped, the program may not have been deleted correctly" & @CRLF
				EndIf

				$ToolsCpt.Item($processList[$cpt][0]) = $toolsData
			EndIf
		Next
	Next
EndFunc   ;==>RemoveAllProcess

Func RemoveScheduleTask($list)
	Dim $KPDebug
	Dim $ToolsCpt

	If $KPDebug Then logMessage("[I] RemoveScheduleTask")

	For $i = 1 To UBound($list) - 1
		RunWait('schtasks.exe /delete /tn "' & $list[$i][1] & '" /f', @TempDir, @SW_HIDE)
	Next
EndFunc   ;==>RemoveScheduleTask

Func UninstallNormaly($list)
	Dim $ToolsCpt
	Dim $KPDebug

	If $KPDebug Then logMessage("[I] UninstallNormaly")

	Local Const $ProgramFilesList = GetProgramFilesList()

	For $i = 1 To UBound($ProgramFilesList) - 1
		For $c = 1 To UBound($list) - 1
			Local $folderReg = $list[$c][1]
			Local $FileReg = $list[$c][2]

			Local $globFolder = FindGlob($ProgramFilesList[$i], "*", $folderReg)

			For $f = 1 To UBound($globFolder) - 1
				Local $uninstallFiles = FindGlob($globFolder[$f], "*", $FileReg)

				For $u = 1 To UBound($uninstallFiles) - 1
					If isFile($uninstallFiles[$u]) Then
						RunWait($uninstallFiles[$u])
						Local $toolsData = $ToolsCpt.Item($list[$c][0])
						$toolsData[0] += 1
						$ToolsCpt.Item($list[$c][0]) = $toolsData
					EndIf
				Next
			Next
		Next
	Next
EndFunc   ;==>UninstallNormaly

Func RemoveAllProgramFilesDir($list)
	Dim $KPDebug

	If $KPDebug Then logMessage("[I] RemoveAllProgramFilesDir")

	Local Const $ProgramFilesList = GetProgramFilesList()

	For $i = 1 To UBound($ProgramFilesList) - 1
		RemoveAllFileFrom($ProgramFilesList[$i], $list)
	Next
EndFunc   ;==>RemoveAllProgramFilesDir

Func RemoveAllSoftwareKeyList($list)
	Dim $ToolsCpt
	Dim $KPDebug

	If $KPDebug Then logMessage("[I] RemoveAllSoftwareKeyList")

	Local $s64Bit = ""
	If @OSArch = "X64" Then $s64Bit = "64"
	Local $keys[2] = ["HKCU" & $s64Bit & "\SOFTWARE", "HKLM" & $s64Bit & "\SOFTWARE"]

	For $k = 0 To UBound($keys) - 1
		Local $i = 0

		While True
			$i += 1
			Local $entry = RegEnumKey($keys[$k], $i)

			If @error <> 0 Then ExitLoop

			For $c = 1 To UBound($list) - 1
				If $entry And $list[$c][1] Then
					If StringRegExp($entry, $list[$c][1]) Then
						Local $status = RemoveRegistryKey($keys[$k] & "\" & $entry)
						Local $toolsData = $ToolsCpt.Item($list[$c][0])

						If $status = 1 Then
							$toolsData[0] += 1
						ElseIf $status = 2 Then
							$toolsData[1] += "[X] " & $keys[$k] & "\" & $entry & " delete failed" & @CRLF
						EndIf

						$ToolsCpt.Item($list[$c][0]) = $toolsData
					EndIf
				EndIf
			Next
		WEnd
	Next
EndFunc   ;==>RemoveAllSoftwareKeyList

Func RemoveUninstallStringWithSearch($list)
	Dim $ToolsCpt
	Dim $KPDebug

	If $KPDebug Then logMessage("[I] RemoveUninstallStringWithSearch")

	For $i = 1 To UBound($list) - 1
		Local $keyFound = searchRegistryKeyStrings($list[$i][1], $list[$i][2], $list[$i][3])

		If $keyFound And $keyFound <> "" Then
			Local $status = RemoveRegistryKey($keyFound)
			Local $toolsData = $ToolsCpt.Item($list[$i][0])

			If $status = 1 Then
				$toolsData[0] += 1
			ElseIf $status = 2 Then
				$toolsData[1] += "[X] " & $keyFound & " delete failed" & @CRLF
			EndIf

			$ToolsCpt.Item($list[$i][0]) = $toolsData
		EndIf
	Next
EndFunc   ;==>RemoveUninstallStringWithSearch
