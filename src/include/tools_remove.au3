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

