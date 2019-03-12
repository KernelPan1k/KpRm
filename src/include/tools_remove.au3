
Func prepareRemove($path)
	FileSetAttrib($path, "-R", $FT_RECURSIVE)
	FileSetAttrib($path, "-A", $FT_RECURSIVE)
	FileSetAttrib($path, "-S", $FT_RECURSIVE)
	FileSetAttrib($path, "-H", $FT_RECURSIVE)
	FileSetAttrib($path, "+N", $FT_RECURSIVE)
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

		prepareRemove($file)

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

		prepareRemove($path)

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

Func RemoveGlobFile($path, $file, $reg, $descriptionPattern = Null)
	Local Const $filePathGlob = $path & "\" & $file
	Local Const $hSearch = FileFindFirstFile($filePathGlob)
	Local $return = 0

	If $hSearch = -1 Then
		Return 0
	EndIf

	Local $sFileName = FileFindNextFile($hSearch)

	While @error = 0
		If StringRegExp($sFileName, $reg) Then
			$return += RemoveFile($path & "\" & $sFileName, $descriptionPattern)
		EndIf

		$sFileName = FileFindNextFile($hSearch)
	WEnd

	FileClose($hSearch)

	Return $return
EndFunc   ;==>RemoveGlobFile

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
