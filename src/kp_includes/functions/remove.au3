Func PrepareRemove($sPath, $bRecursive = 0)
	_ClearObjectDacl($sPath, $SE_FILE_OBJECT)
	_GrantAllAccess($sPath, $SE_FILE_OBJECT, @UserName)
	ClearAttributes($sPath)
EndFunc   ;==>PrepareRemove

Func ClearAttributes($sPath)
	Local $sAttrib = FileGetAttrib($sPath)
	Local $sAttribFound, $iTimer = 1
	Local $aAttribFound[8]
	$aAttribFound[0] = "R"
	$aAttribFound[1] = "A"
	$aAttribFound[2] = "S"
	$aAttribFound[3] = "H"
	$aAttribFound[4] = "N"
	$aAttribFound[5] = "O"
	$aAttribFound[6] = "T"
	$aAttribFound[7] = "I"

	For $sAttribFound In $aAttribFound
		If StringInStr($sAttrib, $sAttribFound) Then
			If $iTimer = 1 Then
				_GrantAllAccess($sPath, $SE_FILE_OBJECT, @UserName)
				$iTimer += 1
			EndIf
			FileSetAttrib($sPath, "-" & $sAttribFound)
		EndIf
	Next
EndFunc   ;==>ClearAttributes

Func SearchRegistryKeyStrings($sPath, $sPattern, $sKey)
	Local $i = 0
	While True
		$i += 1
		Local $sEntry = RegEnumKey($sPath, $i)
		If @error <> 0 Then ExitLoop
		Local $sRegPath = $sPath & "\" & $sEntry
		Local $sName = RegRead($sRegPath, $sKey)

		If StringRegExp($sName, $sPattern) Then
			Return $sRegPath
		EndIf
	WEnd

	Return Null
EndFunc   ;==>SearchRegistryKeyStrings

Func IsFileInWhiteList($sFile)
	Local Const $aWhiteList[8] = [ _
			"(?i)MKVPlayerSetup.*\.exe$", _
			"(?i)MKVExtractGUI.*\.exe$", _
			"(?i)mkvpropedit.*\.exe$", _
			"(?i)mkvinfo.*\.exe$", _
			"(?i)mkvextract.*\.exe$", _
			"(?i)mkvmerge.*\.exe$", _
			"(?i)mkvtoolnix.*\.exe$", _
			"(?i)MkvToMp4.*\.exe$"]

	Local $bInWhiteList = False

	For $i = 0 To UBound($aWhiteList) - 1
		If StringRegExp($sFile, $aWhiteList[$i]) Then
			$bInWhiteList = True
			ExitLoop
		EndIf
	Next

	Return $bInWhiteList
EndFunc   ;==>IsFileInWhiteList

Func IsProcessInWhiteList($sProcess)
	Local Const $aWhiteList[3] = ["(?i)^sftvsa.exe$", "(?i)^sftlist.exe$", "(?i)^SftService.exe$"]
	Local $bInWhiteList = False

	For $i = 0 To UBound($aWhiteList) - 1
		If StringRegExp($sProcess, $aWhiteList[$i]) Then
			$bInWhiteList = True
			ExitLoop
		EndIf
	Next

	Return $bInWhiteList
EndFunc   ;==>IsProcessInWhiteList

Func RemoveTheFile($sFile)
	If FileExists($sFile) Then
		PrepareRemove($sFile, 0)

		If Not FileDelete($sFile) Then
			DllCall('kernel32.dll', 'bool', 'DeleteFileW', 'wstr', $sFile)
		EndIf

		If FileExists($sFile) Then
			DllCall('kernel32.dll', "int", "MoveFileExW", "wstr", $sFile, "ptr", 0, "dword", $MOVE_FILE_DELAY_UNTIL_REBOOT)
		EndIf
	EndIf
EndFunc   ;==>RemoveTheFile

Func RemoveTheFolder($sPath)
	Dim $bNeedRestart

	If FileExists($sPath) Then
		PrepareRemove($sPath, 1)

		If Not DirRemove($sPath, $DIR_REMOVE) Then
			Local $aFileList = _FileListToArrayRec($sPath, "*", $FLTA_FILES, $FLTAR_RECUR, $FLTAR_NOSORT, $FLTAR_FULLPATH)
			If @error <> 0 Then _
					Return

			For $i = 1 To UBound($aFileList) - 1
				PrepareRemove($aFileList[$i], 0)
				RemoveTheFile($aFileList[$i])
			Next

			Local $aFolderList = _FileListToArrayRec($sPath, "*", $FLTA_FOLDERS, $FLTAR_RECUR, $FLTAR_NOSORT, $FLTAR_FULLPATH)
			If @error <> 0 Then _
					Return

			_ArrayDelete($aFolderList, 0)
			_ArrayReverse($aFolderList)

			For $i = 0 To UBound($aFolderList) - 1
				PrepareRemove($aFolderList[$i], 1)
				DirRemove($aFolderList[$i], $DIR_REMOVE)
			Next

			DirRemove($sPath, $DIR_REMOVE)

			If FileExists($sPath) Then
				Local $aElementsList = _FileListToArrayRec($sPath, "*", $FLTAR_FILESFOLDERS, $FLTAR_RECUR, $FLTAR_NOSORT, $FLTAR_FULLPATH)
				If @error <> 0 Then _
						Return

				_ArrayDelete($aElementsList, 0)
				_ArrayReverse($aElementsList)

				Local $hDll = DllOpen('kernel32.dll')

				For $i = 0 To UBound($aElementsList) - 1
					DllCall($hDll, "int", "MoveFileExW", "wstr", $aElementsList[$i], "ptr", 0, "dword", $MOVE_FILE_DELAY_UNTIL_REBOOT)
				Next

				DllCall($hDll, "int", "MoveFileExW", "wstr", $sPath, "ptr", 0, "dword", $MOVE_FILE_DELAY_UNTIL_REBOOT)

				DllClose($hDll)
			EndIf
		EndIf
	EndIf
EndFunc   ;==>RemoveTheFolder

Func RemoveFile($sFile, $sToolKey, $sDescriptionPattern = Null)
	Dim $bSearchOnly
	Dim $bNeedRestart

	Local Const $iFileExists = IsFile($sFile)

	If $iFileExists And IsFileInWhiteList($sFile) = False Then
		If $sDescriptionPattern And StringRegExp($sFile, "(?i)\.(exe|com)$") Then
			Local Const $sCompanyName = FileGetVersion($sFile, "CompanyName")

			If @error Or Not StringRegExp($sCompanyName, $sDescriptionPattern) Then
				Return False
			EndIf
		EndIf

		If $bSearchOnly = False Then
			UpdateStatusBar("Remove file " & $sFile)
			UpdateToolCpt($sToolKey, 'element', $sFile)
			RemoveTheFile($sFile)
		Else
			UpdateStatusBar("File " & $sFile & " found")
			AddToSearch($sFile, $sToolKey)
		EndIf
	EndIf
EndFunc   ;==>RemoveFile

Func RemoveFolder($sPath, $sToolKey, $sQuarantine = "0")
	Dim $bDeleteQuarantines
	Dim $bSearchOnly
	Dim $bNeedRestart

	Local $iFileExists = IsDir($sPath)

	If $iFileExists Then
		If $bSearchOnly = True Then
			AddToSearch($sPath, $sToolKey)
			UpdateStatusBar("Folder " & $sPath & " found")
			Return
		EndIf

		Local $bIsQuarantine = False

		If $sQuarantine = "1" Then
			$bIsQuarantine = True

			If $bDeleteQuarantines = Null Then
				AddElementToKeep($sPath, $sToolKey)
				Return
			EndIf
		EndIf

		If $bIsQuarantine = False Or $bDeleteQuarantines = 1 Then
			UpdateToolCpt($sToolKey, 'element', $sPath)
			PrepareRemove($sPath, 1)
			UpdateStatusBar("Remove folder " & $sPath)
			RemoveTheFolder($sPath)
		ElseIf $bDeleteQuarantines = 7 Then
			AddElementToKeep($sPath, $sToolKey)
		EndIf
	EndIf
EndFunc   ;==>RemoveFolder

Func FindInPath($sPath, $sFile, $sReg)
	Local Const $sFilePathGlob = $sPath & "\" & $sFile
	Local Const $hSearch = FileFindFirstFile($sFilePathGlob)
	Local $aReturn = []

	If $hSearch = -1 Then
		Return $aReturn
	EndIf

	Local $sFileName = FileFindNextFile($hSearch)

	While @error = 0
		If StringRegExp($sFileName, $sReg) Then
			_ArrayAdd($aReturn, $sPath & "\" & $sFileName)
		EndIf

		$sFileName = FileFindNextFile($hSearch)
	WEnd

	FileClose($hSearch)

	Return $aReturn
EndFunc   ;==>FindInPath

Func RemoveFileHandler($sPathOfFile, Const ByRef $aElements)
	Local $sTypeOfFile = FileExistsAndGetType($sPathOfFile)

	If $sTypeOfFile = Null Then
		Return Null
	EndIf

	Local $sDrive = "", $sDir = "", $sFileName = "", $sExtension = ""
	Local $aPathSplit = _PathSplit($sPathOfFile, $sDrive, $sDir, $sFileName, $sExtension)
	Local $sFile = $sFileName & $sExtension

	For $e = 0 To UBound($aElements) - 1
		If $aElements[$e][3] _
				And $sTypeOfFile = $aElements[$e][1] _
				And StringRegExp($sFile, $aElements[$e][3]) Then
			If $sTypeOfFile = 'file' Then
				RemoveFile($sPathOfFile, $aElements[$e][0], $aElements[$e][2])
			ElseIf $sTypeOfFile = 'folder' Then
				RemoveFolder($sPathOfFile, $aElements[$e][0], $aElements[$e][4])
			EndIf
		EndIf
	Next
EndFunc   ;==>RemoveFileHandler

Func RemoveAllFileFromWithMaxDepth($sPath, Const ByRef $aElements, $iDetpth = -2)
	Local $aArray = _FileListToArrayRec($sPath, "*.exe;*.txt;*.lnk;*.log;*.reg;*.zip;*.dat;*.scr;*.com;*.bat;*.mbr;*.iso;*.pif;*.rtf", $FLTAR_FILESFOLDERS, $iDetpth, $FLTAR_NOSORT, $FLTAR_FULLPATH)

	If @error <> 0 Then
		Return Null
	EndIf

	For $i = 1 To $aArray[0]
		RemoveFileHandler($aArray[$i], $aElements)
	Next
EndFunc   ;==>RemoveAllFileFromWithMaxDepth

Func RemoveAllFileFrom($sPath, $aElements)
	Local Const $sFilePathGlob = $sPath & "\*"
	Local Const $hSearch = FileFindFirstFile($sFilePathGlob)

	If $hSearch = -1 Then
		Return Null
	EndIf

	Local $sFileName = FileFindNextFile($hSearch)

	While @error = 0
		Local $sPathOfFile = $sPath & "\" & $sFileName
		RemoveFileHandler($sPathOfFile, $aElements)
		$sFileName = FileFindNextFile($hSearch)
	WEnd

	FileClose($hSearch)

EndFunc   ;==>RemoveAllFileFrom

Func RemoveRegistryKey($key, $sToolKey)
	Dim $bSearchOnly

	If $bSearchOnly = True Then
		UpdateStatusBar("Registry key " & $key & " found")
		AddToSearch($key, $sToolKey)
		Return
	EndIf

	_ClearObjectDacl($key, $SE_REGISTRY_KEY)
	_GrantAllAccess($key, $SE_REGISTRY_KEY, @UserName)

	UpdateStatusBar("Remove registry key " & $key)

	Local Const $iStatus = RegDelete($key)

	If $iStatus <> 0 Then
		UpdateToolCpt($sToolKey, "key", $key)
	EndIf
EndFunc   ;==>RemoveRegistryKey

Func CloseUnEssentialProcess()
	Local Const $aProcess[1] = ["notepad.exe"]

	For $i = 0 To UBound($aProcess) - 1
		If 0 = ProcessExists($aProcess[$i]) Then ContinueLoop
		ProcessClose($aProcess[$i])
	Next
EndFunc   ;==>CloseUnEssentialProcess

Func CloseProcessAndWait($sProcess, $sProcessName, $sForce = "0")
	Local $iCpt = 50

	If 0 = ProcessExists($sProcess) Then Return False

	If Number($sForce) Then
		_Permissions_KillProcess($sProcess)

		If 0 = ProcessExists($sProcess) Then _
				Return True
	EndIf

	UpdateStatusBar("Close process " & $sProcessName)

	ProcessClose($sProcess)

	Do
		$iCpt -= 1
		Sleep(250)
	Until ($iCpt = 0 Or 0 = ProcessExists($sProcess))
EndFunc   ;==>CloseProcessAndWait

Func RemoveAllProcess(Const ByRef $aList)
	Dim $bSearchOnly
	Local $aProcessList = ProcessList()

	For $i = 1 To $aProcessList[0][0]
		Local $sProcessName = $aProcessList[$i][0]
		Local $iPid = $aProcessList[$i][1]

		For $iCpt = 0 To UBound($aList) - 1
			If IsProcessInWhiteList($sProcessName) = False _
					And StringRegExp($sProcessName, $aList[$iCpt][1]) Then
				Local $sProcessPath = _WinAPI_GetProcessFileName($iPid)
				If @error <> 0 Then ContinueLoop
				If Not IsFile($sProcessPath) Then ContinueLoop

				If $aList[$iCpt][2] <> "" Then
					Local $sCompanyNamePattern = $aList[$iCpt][2]
					Local $sCompanyName = FileGetVersion($sProcessPath, "CompanyName")

					If @error Or Not StringRegExp($sCompanyName, $sCompanyNamePattern) Then
						ContinueLoop
					EndIf
				EndIf

				If $bSearchOnly = True Then
					UpdateStatusBar("Process " & $sProcessName & " found")
					AddToSearch($sProcessPath, $aList[$iCpt][0])
					ContinueLoop
				EndIf

				CloseProcessAndWait($iPid, $sProcessName, $aList[$iCpt][3])
				UpdateToolCpt($aList[$iCpt][0], "process", $sProcessName)
			EndIf
		Next
	Next
EndFunc   ;==>RemoveAllProcess

Func RemoveScheduleTask(Const ByRef $aList)
	For $i = 0 To UBound($aList) - 1
		UpdateStatusBar("Remove schedule task " & $aList[$i][1])
		RunWait('schtasks.exe /delete /tn "' & $aList[$i][1] & '" /f', "", @SW_HIDE)
	Next
EndFunc   ;==>RemoveScheduleTask

Func UninstallNormally(Const ByRef $aList)
	Dim $bSearchOnly
	Local Const $aProgramFilesList = GetProgramFilesList()

	For $i = 0 To UBound($aProgramFilesList) - 1
		For $c = 0 To UBound($aList) - 1
			Local $sFolderReg = $aList[$c][1]
			Local $sFileReg = $aList[$c][2]

			Local $aGlobFolder = FindInPath($aProgramFilesList[$i], "*", $sFolderReg)

			For $f = 1 To UBound($aGlobFolder) - 1
				Local $aUninstallFiles = FindInPath($aGlobFolder[$f], "*", $sFileReg)

				For $u = 1 To UBound($aUninstallFiles) - 1
					If IsFile($aUninstallFiles[$u]) Then
						UpdateStatusBar("Uninstall " & $aUninstallFiles[$u])

						If $bSearchOnly = False Then
							RunWait($aUninstallFiles[$u])
							UpdateToolCpt($aList[$c][0], "uninstall", $aUninstallFiles[$u])
						Else
							AddToSearch($aGlobFolder[$f], $aList[$c][0])
						EndIf
					EndIf
				Next
			Next
		Next
	Next
EndFunc   ;==>UninstallNormally

Func RemoveAllProgramFilesDir(Const ByRef $aList)
	Local Const $aProgramFilesList = GetProgramFilesList()

	For $i = 0 To UBound($aProgramFilesList) - 1
		RemoveAllFileFrom($aProgramFilesList[$i], $aList)
	Next
EndFunc   ;==>RemoveAllProgramFilesDir

Func RemoveAllSoftwareKeyList(Const ByRef $aList)
	Local $s64Bit = GetSuffixKey()
	Local $aKeys[2] = ["HKCU" & $s64Bit & "\SOFTWARE", "HKLM" & $s64Bit & "\SOFTWARE"]

	For $k = 0 To UBound($aKeys) - 1
		Local $i = 0

		While True
			$i += 1
			Local $sEntry = RegEnumKey($aKeys[$k], $i)

			If @error <> 0 Then ExitLoop

			For $c = 0 To UBound($aList) - 1
				If $sEntry And $aList[$c][1] Then
					If StringRegExp($sEntry, $aList[$c][1]) Then
						Local $sKeyFound = $aKeys[$k] & "\" & $sEntry
						RemoveRegistryKey($sKeyFound, $aList[$c][0])
					EndIf
				EndIf
			Next
		WEnd
	Next
EndFunc   ;==>RemoveAllSoftwareKeyList

Func RemoveUninstallStringWithSearch(Const ByRef $aList)
	For $i = 1 To UBound($aList) - 1
		Local $sKey = FormatForUseRegistryKey($aList[$i][1])
		Local $sKeyFound = SearchRegistryKeyStrings($sKey, $aList[$i][2], $aList[$i][3])

		If $sKeyFound And $sKeyFound <> "" Then
			RemoveRegistryKey($sKeyFound, $aList[$i][0])
		EndIf
	Next
EndFunc   ;==>RemoveUninstallStringWithSearch

Func RemoveAllRegistryKeys(Const ByRef $aList)
	For $i = 0 To UBound($aList) - 1
		Local $sKey = FormatForUseRegistryKey($aList[$i][1])

		RegEnumVal($sKey, "1")

		If @error = 0 Then
			RemoveRegistryKey($sKey, $aList[$i][0])
		EndIf
	Next
EndFunc   ;==>RemoveAllRegistryKeys

Func CleanDirectoryContent(Const ByRef $aList)
	Dim $bDeleteQuarantines
	Dim $bSearchOnly

	For $i = 0 To UBound($aList) - 1
		Local $sPath = FormatPathWithMacro($aList[$i][1])

		If FileExists($sPath) Then
			Local $bIsQuarantine = False

			If $aList[$i][3] = "1" Then
				$bIsQuarantine = True

				If $bDeleteQuarantines = Null And $bSearchOnly = False Then
					AddElementToKeep($sPath, $aList[$i][0])
					ContinueLoop
				EndIf
			EndIf

			Local $aFileList = _FileListToArray($sPath)

			If @error = 0 Then
				For $f = 1 To $aFileList[0]
					If $bSearchOnly = False Then
						If $bIsQuarantine = False Or $bDeleteQuarantines = 1 Then
							RemoveFile($sPath & '\' & $aFileList[$f], $aList[$i][0], $aList[$i][2])
						ElseIf $bDeleteQuarantines = 7 Then
							AddElementToKeep($sPath & '\' & $aFileList[$f], $aList[$i][0])
						EndIf
					Else
						AddToSearch($sPath & '\' & $aFileList[$f], $aList[$i][0])
					EndIf
				Next
			EndIf
		EndIf
	Next
EndFunc   ;==>CleanDirectoryContent

Func AddRemoveAtRestart($sElement)
	Dim $aRemoveRestart
	Dim $bNeedRestart = True

	If _ArraySearch($aRemoveRestart, $sElement) = -1 Then
		_ArrayAdd($aRemoveRestart, $sElement)
	EndIf
EndFunc   ;==>AddRemoveAtRestart

Func RemoveFileCustomPath(Const ByRef $aList)
	For $i = 0 To UBound($aList) - 1
		Local $sPath = FormatPathWithMacro($aList[$i][1])
		RemoveFile($sPath, $aList[$i][0], $aList[$i][2])
	Next
EndFunc   ;==>RemoveFileCustomPath

Func RemoveFolderCustomPath(Const ByRef $aList)
	For $i = 0 To UBound($aList) - 1
		Local $sPath = FormatPathWithMacro($aList[$i][1])
		RemoveFolder($sPath, $aList[$i][0], $aList[$i][2])
	Next
EndFunc   ;==>RemoveFolderCustomPath
