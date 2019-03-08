#cs ----------------------------------------------------------------------------

 AutoIt Version: 3.3.14.5
 Author:         myName

 Script Function:
	Template AutoIt script.

#ce ----------------------------------------------------------------------------

; Script Start - Add your code below here

Func RemoveFile($pattern)
	Local $hSearch = FileFindFirstFile($pattern)

	If $hSearch = -1 Then
		Return False
	EndIf

	Local $sFileName = FileFindNextFile($hSearch)

	While @error = 0
		Local $status = FileDelete($sFileName)

		If $status = 1 Then
			logMessage()
		Else
			logMessage()
		EndIf
		$sFileName = FileFindNextFile($hSearch) ; fichier suivant
	WEnd

	FileClose($hSearch)
EndFunc   ;==>RemoveFile

Func RemoveFolder()

EndFunc   ;==>RemoveFolder
