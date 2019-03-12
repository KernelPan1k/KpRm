
Func prepareRemove($path)
	FileSetAttrib($path, "-R", $FT_RECURSIVE)
	FileSetAttrib($path, "-A", $FT_RECURSIVE)
	FileSetAttrib($path, "-S", $FT_RECURSIVE)
	FileSetAttrib($path, "-H", $FT_RECURSIVE)
	FileSetAttrib($path, "+N", $FT_RECURSIVE)
EndFunc   ;==>prepareRemove

Func RemoveFile($file, $descriptionPattern = Null)
	Local Const $iFileExists = FileExists($file)

	If $iFileExists Then
		If $descriptionPattern Then
			Local Const $fileDescription = FileGetVersion($file, "FileDescription")

			If @error Then
				Return Null
			ElseIf Not StringRegExp($fileDescription, $descriptionPattern) Then
				Return Null
			EndIf
		EndIf

		prepareRemove($file)

		Local $iDelete = FileDelete($file)

		If $iDelete Then
			logMessage("  [OK] File " & $file & " deleted successfully")
		EndIf
	EndIf
EndFunc   ;==>RemoveFile

Func RemoveFolder($path)
	Local $iFileExists = FileExists($path)

	If $iFileExists Then
		prepareRemove($path)
		Local Const $iDelete = DirRemove($path, $DIR_REMOVE)

		If $iDelete Then
			logMessage("  [OK] Directory " & $path & " deleted successfully")
		EndIf
	EndIf
EndFunc   ;==>RemoveFolder

Func RemoveGlobFile($path, $file, $reg, $descriptionPattern = Null)
	Local Const $filePathGlob = $path & "\" & $file
	Local Const $hSearch = FileFindFirstFile($filePathGlob)

	If $hSearch = -1 Then
		Return False
	EndIf

	Local $sFileName = FileFindNextFile($hSearch)

	While @error = 0
		If StringRegExp($sFileName, $reg) Then
			RemoveFile($path & "\" & $sFileName, $descriptionPattern)
		EndIf

		$sFileName = FileFindNextFile($hSearch)
	WEnd

	FileClose($hSearch)
EndFunc   ;==>RemoveGlobFile

Func RemoveRegistryKey($key)
	Local Const $status = RegDelete($key)

	If $status = 1 Then
		logMessage("  [OK] " & $key & " deleted successfully")
	ElseIf $status = 2 Then
		logMessage("  [X] " & $key & " deleted failed")
	EndIf
EndFunc   ;==>RemoveRegistryKey

Func RemoveService($name)
	Local Const $status = RunWait(@ComSpec & " /c " & "sc query " & $name, @TempDir, @SW_HIDE)

	If $status = 1060 Then
		Return Null
	EndIf

	RunWait(@ComSpec & " /c " & "sc stop " & $name, @TempDir, @SW_HIDE)

	If @error = 0 Then
		logMessage("  [OK] Stop service " & $name & " successfully")
	EndIf

	RunWait(@ComSpec & " /c " & "sc config " & $name & " start= disabled", @TempDir, @SW_HIDE)

	If @error = 0 Then
		logMessage("  [OK] Disable service " & $name & " successfully")
	EndIf

	Local $s64Bit = ""
	If @OSArch = "X64" Then $s64Bit = "64"

	Local $key = "HKLM" & $s64Bit & "\SYSTEM\CurrentControlSet\Services\" & $name
	RemoveRegistryKey($key)

	Local $key = "HKLM" & $s64Bit & "\SYSTEM\ControlSet002\Services\" & $name
	RemoveRegistryKey($key)
EndFunc   ;==>RemoveService

Func RemoveSoftwareKey($name)
	Local $s64Bit = ""
	If @OSArch = "X64" Then $s64Bit = "64"

	RemoveRegistryKey("HKCU" & $s64Bit & "\SOFTWARE\" & $name)
	RemoveRegistryKey("HKLM" & $s64Bit & "\SOFTWARE\" & $name)
EndFunc   ;==>RemoveSoftwareKey

Func RemoveContextMenu($name)
	Local $s64Bit = ""
	If @OSArch = "X64" Then $s64Bit = "64"

	RemoveRegistryKey("HKLM" & $s64Bit & "\SOFTWARE\Classes\*\shellex\ContextMenuHandlers\" & $name)
	RemoveRegistryKey("HKLM" & $s64Bit & "\SOFTWARE\Classes\lnkfile\shellex\ContextMenuHandlers\" & $name)
	RemoveRegistryKey("HKLM" & $s64Bit & "\SOFTWARE\Classes\AllFilesystemObjects\shellex\ContextMenuHandlers\" & $name)
	RemoveRegistryKey("HKLM" & $s64Bit & "\Software\Classes\Directory\ShellEx\ContextMenuHandlers\" & $name)
	RemoveRegistryKey("HKLM" & $s64Bit & "\Software\Classes\Directory\Background\ShellEx\ContextMenuHandlers\" & $name)
	RemoveRegistryKey("HKLM" & $s64Bit & "\SOFTWARE\Classes\Drive\shellex\ContextMenuHandlers\" & $name)
EndFunc   ;==>RemoveContextMenu

Func CloseProcessAndWait($process)
	Local $cpt = 50

	If 0 = ProcessExists($process) Then Return 0

	ProcessClose($process)

	Do
		$cpt -= 1
		Sleep(250)
	Until ($cpt = 0 Or 0 = ProcessExists($process))

	Local Const $status = ProcessExists($process)

	If 0 = $status Then
		logMessage("  [OK] Porccess " & $process & " stopped successfully")
	EndIf

	Return $status
EndFunc   ;==>CloseProcessAndWait
