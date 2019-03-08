#cs ----------------------------------------------------------------------------

 AutoIt Version: 3.3.14.5
 Author:         myName

 Script Function:
	Template AutoIt script.

#ce ----------------------------------------------------------------------------

; Script Start - Add your code below here

Local Const $userDownloadFolder = @UserProfileDir & "\Downloads"

Func RemoveFRST()

	Local Const $files[5] = [ _
			@DesktopDir & "\FRST.exe", _
			@DesktopDir & "\fixlist.txt", _
			@DesktopDir & "\FRST.txt", _
			@DesktopDir & "\Addition.txt", _
			@DesktopDir & "\Shortcut.txt" _
			]

	For $i = 0 To 4
		RemoveFile($files[$i])
	Next

	RemoveGlobFile(@DesktopDir,  "FRST(*).exe", "FRST\([0-9]{1,2}\)\.exe$")
	RemoveGlobFile(@DesktopDir, "FRST32-*.exe", "FRST32-[0-9]+\.?[0-9]*\.exe$")
	RemoveGlobFile(@DesktopDir, "FRST64-*.exe", "FRST64-[0-9]+\.?[0-9]*\.exe$")

	Local Const $iFileExists = FileExists($userDownloadFolder)

	If $iFileExists Then
		Local Const $downloadFiles[5] = [ _
			$userDownloadFolder & "\FRST.exe", _
			$userDownloadFolder & "\fixlist.txt", _
			$userDownloadFolder & "\FRST.txt", _
			$userDownloadFolder & "\Addition.txt", _
			$userDownloadFolder & "\Shortcut.txt" _
			]

		For $i = 0 To 4
			RemoveFile($downloadFiles[$i])
		Next

		RemoveGlobFile($userDownloadFolder, "FRST(*).exe", "FRST\([0-9]{1,2}\)\.exe$")
		RemoveGlobFile($userDownloadFolder, "FRST32-*.exe", "FRST32-[0-9]+\.?[0-9]*\.exe$")
		RemoveGlobFile($userDownloadFolder, "FRST64-*.exe", "FRST64-[0-9]+\.?[0-9]*\.exe$")
	EndIf

	RemoveFolder(@HomeDrive & "\FRST")

EndFunc   ;==>RemoveFRST
