
Func prepareRemove($path, $recursive = 0, $force = False)
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

Func RemoveFile($file, $toolKey, $descriptionPattern = Null, $force = False)
	Local Const $iFileExists = isFile($file)

	If $iFileExists Then
		If $descriptionPattern And StringRegExp($file, "(?i)\.(exe|com)$") Then
			Local Const $companyName = FileGetVersion($file, "CompanyName")

			If @error Then
				Return 0
			ElseIf Not StringRegExp($companyName, $descriptionPattern) Then
				Return 0
			EndIf
		EndIf

		UpdateToolCpt($toolKey, 'element', $file)
		prepareRemove($file, 0, $force)

		Local $iDelete = FileDelete($file)

		If $iDelete Then
			Return 1
		EndIf

		Return 2

	EndIf

	Return 0

EndFunc   ;==>RemoveFile

Func RemoveFolder($path, $toolKey, $force = False)
	Local $iFileExists = IsDir($path)

	If $iFileExists Then
		UpdateToolCpt($toolKey, 'element', $path)
		prepareRemove($path, 1, $force)

		Local Const $iDelete = DirRemove($path, $DIR_REMOVE)

		If $iDelete Then

			Return 1
		EndIf

		Return 2

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

Func RemoveFileHandler($pathOfFile, $elements)
	Local $typeOfFile = FileExistsAndGetType($pathOfFile)

	If $typeOfFile = Null Then
		Return Null
	EndIf

	Local $sDrive = "", $sDir = "", $sFileName = "", $sExtension = ""
	Local $aPathSplit = _PathSplit($pathOfFile, $sDrive, $sDir, $sFileName, $sExtension)
	Local $sFile = $sFileName & $sExtension

	For $e = 1 To UBound($elements) - 1
		If $elements[$e][3] And $typeOfFile = $elements[$e][1] And StringRegExp($sFile, $elements[$e][3]) Then
			Local $status = 0
			Local $force = False

			If $elements[$e][4] = True Then
				$force = True
			EndIf

			If $typeOfFile = 'file' Then
				$status = RemoveFile($pathOfFile, $elements[$e][0], $elements[$e][2], $force)
			ElseIf $typeOfFile = 'folder' Then
				$status = RemoveFolder($pathOfFile, $elements[$e][0], $force)
			EndIf
		EndIf
	Next
EndFunc   ;==>RemoveFileHandler

Func RemoveAllFileFromWithMaxDepth($path, $elements, $detpth = -2)
	Local $aArray = _FileListToArrayRec($path, "*.exe;*.txt;*.lnk;*.log;*.reg;*.zip;*.dat;*.scr;*.com", $FLTAR_FILESFOLDERS, $detpth, $FLTAR_NOSORT, $FLTAR_FULLPATH)

	If @error <> 0 Then
		Return Null
	EndIf

	For $i = 1 To $aArray[0]
		RemoveFileHandler($aArray[$i], $elements)
	Next
EndFunc   ;==>RemoveAllFileFromWithMaxDepth

Func RemoveAllFileFrom($path, $elements)
	Local Const $filePathGlob = $path & "\*"
	Local Const $hSearch = FileFindFirstFile($filePathGlob)

	If $hSearch = -1 Then
		Return Null
	EndIf

	Local $sFileName = FileFindNextFile($hSearch)

	While @error = 0
		Local $pathOfFile = $path & "\" & $sFileName
		RemoveFileHandler($pathOfFile, $elements)
		$sFileName = FileFindNextFile($hSearch)
	WEnd

	FileClose($hSearch)

EndFunc   ;==>RemoveAllFileFrom

Func RemoveRegistryKey($key, $toolKey, $force = False)
	If $force = True Then
		_ClearObjectDacl($key)
		_GrantAllAccess($key, $SE_REGISTRY_KEY)
	EndIf

	Local Const $status = RegDelete($key)

	If $status <> 0 Then
		UpdateToolCpt($toolKey, "key", $key)
	EndIf

	Return $status
EndFunc   ;==>RemoveRegistryKey

Func CloseProcessAndWait($process, $force)
	Local $cpt = 50
	Local $status = Null

	If 0 = ProcessExists($process) Then Return 0

	If $force = True Then
		$status = _Permissions_KillProcess($process)

		If 1 = $status Then
			Return 1
		EndIf
	Else
		ProcessClose($process)

		Do
			$cpt -= 1
			Sleep(250)
		Until ($cpt = 0 Or 0 = ProcessExists($process))

		$status = ProcessExists($process)

		If 0 = $status Then
			Return 1
		EndIf
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
				CloseProcessAndWait($pid, $processList[$cpt][2])
				UpdateToolCpt($processList[$cpt][0], "process", $processName)
			EndIf
		Next
	Next
EndFunc   ;==>RemoveAllProcess

Func RemoveScheduleTask($list)
	For $i = 1 To UBound($list) - 1
		RunWait('schtasks.exe /delete /tn "' & $list[$i][1] & '" /f', @TempDir, @SW_HIDE)
	Next
EndFunc   ;==>RemoveScheduleTask

Func UninstallNormaly($list)
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
						UpdateToolCpt($list[$c][0], "uninstall", $uninstallFiles[$u])
					EndIf
				Next
			Next
		Next
	Next
EndFunc   ;==>UninstallNormaly

Func RemoveAllProgramFilesDir($list)
	Local Const $ProgramFilesList = GetProgramFilesList()

	For $i = 1 To UBound($ProgramFilesList) - 1
		RemoveAllFileFrom($ProgramFilesList[$i], $list)
	Next
EndFunc   ;==>RemoveAllProgramFilesDir

Func RemoveAllSoftwareKeyList($list)
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
						Local $keyFound = $keys[$k] & "\" & $entry
						RemoveRegistryKey($keyFound, $list[$c][0])
					EndIf
				EndIf
			Next
		WEnd
	Next
EndFunc   ;==>RemoveAllSoftwareKeyList

Func RemoveUninstallStringWithSearch($list)
	For $i = 1 To UBound($list) - 1
		Local $keyFound = searchRegistryKeyStrings($list[$i][1], $list[$i][2], $list[$i][3])

		If $keyFound And $keyFound <> "" Then
			RemoveRegistryKey($keyFound, $list[$i][0])
		EndIf
	Next
EndFunc   ;==>RemoveUninstallStringWithSearch

Func RemoveAllRegistryKeys($list)
	For $i = 1 To UBound($list) - 1
		RemoveRegistryKey($list[$i][1], $list[$i][0], $list[$i][2])
	Next
EndFunc   ;==>RemoveAllRegistryKeys

Func CleanDirectoryContent($list)
	For $i = 1 To UBound($list) - 1
		If FileExists($list[$i][1]) Then
			Local $FileList = _FileListToArray($list[$i][1])

			If @error = 0 Then
				For $f = 1 To $FileList[0]
					RemoveFile($list[$i][1] & '\' & $FileList[$f], $list[$i][0], $list[$i][2], $list[$i][3])
				Next
			EndIf
		EndIf
	Next

EndFunc   ;==>CleanDirectoryContent

;~ Func RemoveContextMenu($name)
;~ 	Local $return = 0
;~ 	Local $s64Bit = ""
;~ 	If @OSArch = "X64" Then $s64Bit = "64"

;~ 	$return += RemoveRegistryKey("HKLM" & $s64Bit & "\SOFTWARE\Classes\*\shellex\ContextMenuHandlers\" & $name)
;~ 	$return += RemoveRegistryKey("HKLM" & $s64Bit & "\SOFTWARE\Classes\lnkfile\shellex\ContextMenuHandlers\" & $name)
;~ 	$return += RemoveRegistryKey("HKLM" & $s64Bit & "\SOFTWARE\Classes\AllFilesystemObjects\shellex\ContextMenuHandlers\" & $name)
;~ 	$return += RemoveRegistryKey("HKLM" & $s64Bit & "\Software\Classes\Directory\ShellEx\ContextMenuHandlers\" & $name)
;~ 	$return += RemoveRegistryKey("HKLM" & $s64Bit & "\Software\Classes\Directory\Background\ShellEx\ContextMenuHandlers\" & $name)
;~ 	$return += RemoveRegistryKey("HKLM" & $s64Bit & "\SOFTWARE\Classes\Drive\shellex\ContextMenuHandlers\" & $name)

;~ 	Return $return
;~ EndFunc   ;==>RemoveContextMenu

;~ Func RemoveService($name)
;~ 	Local Const $status = RunWait(@ComSpec & " /c " & "sc query " & $name, @TempDir, @SW_HIDE)
;~ 	Local $return = 0

;~ 	If $status = 1060 Then
;~ 		Return 0
;~ 	EndIf

;~ 	RunWait(@ComSpec & " /c " & "sc stop " & $name, @TempDir, @SW_HIDE)

;~ 	If @error = 0 Then
;~ 		$return += 1
;~ 	EndIf

;~ 	RunWait(@ComSpec & " /c " & "sc config " & $name & " start= disabled", @TempDir, @SW_HIDE)

;~ 	If @error = 0 Then
;~ 		$return += 1
;~ 	EndIf

;~ 	Local $s64Bit = ""
;~ 	If @OSArch = "X64" Then $s64Bit = "64"

;~ 	Local $key = "HKLM" & $s64Bit & "\SYSTEM\CurrentControlSet\Services\" & $name

;~ 	$return += RemoveRegistryKey($key)

;~ 	Local $key = "HKLM" & $s64Bit & "\SYSTEM\ControlSet002\Services\" & $name
;~ 	$return += RemoveRegistryKey($key)

;~ 	Return $return
;~ EndFunc   ;==>RemoveService
