
Func prepareRemove($path)
	FileSetAttrib($path, "-RAS", $FT_RECURSIVE)
EndFunc   ;==>prepareRemove

Func RemoveFile($file)
	Local Const $iFileExists = FileExists($file)

	If $iFileExists Then
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

Func RemoveGlobFile($path, $file, $reg)
	Local Const $filePathGlob = $path & "\" & $file
	Local Const $hSearch = FileFindFirstFile($filePathGlob)

	If $hSearch = -1 Then
		Return False
	EndIf

	Local $sFileName = FileFindNextFile($hSearch)

	While @error = 0
		If StringRegExp($sFileName, $reg) Then
			RemoveFile($path & "\" & $sFileName)
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
	RunWait(@ComSpec & " /c " & "sc stop " & $name)

	If @error = 0 Then
		logMessage("  [OK] Stop service " & $name & " successfully")
	EndIf

	RunWait(@ComSpec & " /c " & "sc config " & $name " start= disabled")

	If @error = 0 Then
		logMessage("  [OK] Disable service " & $name & " successfully")
	EndIf
EndFunc