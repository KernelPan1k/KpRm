
Func prepareRemove($sPath, $bRecursive = 0, $bForce = False)
	If $bForce Then
		_ClearObjectDacl($sPath)
		_GrantAllAccess($sPath)
	EndIf

	Local Const $sAttrib = FileGetAttrib($sPath)

	If StringInStr($sAttrib, "R") Then
		FileSetAttrib($sPath, "-R", $bRecursive)
	EndIf

	If StringInStr($sAttrib, "S") Then
		FileSetAttrib($sPath, "-S", $bRecursive)
	EndIf

	If StringInStr($sAttrib, "H") Then
		FileSetAttrib($sPath, "-H", $bRecursive)
	EndIf

	If StringInStr($sAttrib, "A") Then
		FileSetAttrib($sPath, "-A", $bRecursive)
	EndIf
EndFunc   ;==>prepareRemove

Func RemoveFile($sFile, $sToolKey, $sDescriptionPattern = Null, $bForce = False)
	Local Const $iFileExists = isFile($sFile)

	If $iFileExists Then
		If $sDescriptionPattern And StringRegExp($sFile, "(?i)\.(exe|com)$") Then
			Local Const $sCompanyName = FileGetVersion($sFile, "CompanyName")

			If @error Then
				Return 0
			ElseIf Not StringRegExp($sCompanyName, $sDescriptionPattern) Then
				Return 0
			EndIf
		EndIf

		UpdateToolCpt($sToolKey, 'element', $sFile)
		prepareRemove($sFile, 0, $bForce)

		Local $iDelete = FileDelete($sFile)

		If $iDelete Then
			Return 1
		EndIf

		Return 2

	EndIf

	Return 0

EndFunc   ;==>RemoveFile

Func RemoveFolder($sPath, $sToolKey, $bForce = False)
	Local $iFileExists = IsDir($sPath)

	If $iFileExists Then
		UpdateToolCpt($sToolKey, 'element', $sPath)
		prepareRemove($sPath, 1, $bForce)

		Local Const $iDelete = DirRemove($sPath, $DIR_REMOVE)

		If $iDelete Then

			Return 1
		EndIf

		Return 2

	EndIf

	Return 0

EndFunc   ;==>RemoveFolder

Func FindGlob($sPath, $sFile, $sReg)
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
EndFunc   ;==>FindGlob

Func RemoveFileHandler($sPathOfFile, $aElements)
	Local $sTypeOfFile = FileExistsAndGetType($sPathOfFile)

	If $sTypeOfFile = Null Then
		Return Null
	EndIf

	Local $sDrive = "", $sDir = "", $sFileName = "", $sExtension = ""
	Local $aPathSplit = _PathSplit($sPathOfFile, $sDrive, $sDir, $sFileName, $sExtension)
	Local $sFile = $sFileName & $sExtension

	For $e = 1 To UBound($aElements) - 1
		If $aElements[$e][3] And $sTypeOfFile = $aElements[$e][1] And StringRegExp($sFile, $aElements[$e][3]) Then
			Local $iStatus = 0
			Local $bForce = False

			If $aElements[$e][4] = True Then
				$bForce = True
			EndIf

			If $sTypeOfFile = 'file' Then
				$iStatus = RemoveFile($sPathOfFile, $aElements[$e][0], $aElements[$e][2], $bForce)
			ElseIf $sTypeOfFile = 'folder' Then
				$iStatus = RemoveFolder($sPathOfFile, $aElements[$e][0], $bForce)
			EndIf
		EndIf
	Next
EndFunc   ;==>RemoveFileHandler

Func RemoveAllFileFromWithMaxDepth($sPath, $aElements, $iDetpth = -2)
	Local $aArray = _FileListToArrayRec($sPath, "*.exe;*.txt;*.lnk;*.log;*.reg;*.zip;*.dat;*.scr;*.com;*.bat", $FLTAR_FILESFOLDERS, $iDetpth, $FLTAR_NOSORT, $FLTAR_FULLPATH)

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

Func RemoveRegistryKey($key, $sToolKey, $bForce = False)
	If $bForce = True Then
		_ClearObjectDacl($key)
		_GrantAllAccess($key, $SE_REGISTRY_KEY)
	EndIf

	Local Const $iStatus = RegDelete($key)

	If $iStatus <> 0 Then
		UpdateToolCpt($sToolKey, "key", $key)
	EndIf

	Return $iStatus
EndFunc   ;==>RemoveRegistryKey

Func CloseProcessAndWait($sProcess, $bForce)
	Local $iCpt = 50
	Local $iStatus = Null

	If 0 = ProcessExists($sProcess) Then Return 0

	If $bForce = True Then
		_Permissions_KillProcess($sProcess)

		If 0 = ProcessExists($sProcess) Then Return 0
	EndIf

	ProcessClose($sProcess)

	Do
		$iCpt -= 1
		Sleep(250)
	Until ($iCpt = 0 Or 0 = ProcessExists($sProcess))

	$iStatus = ProcessExists($sProcess)

	If 0 = $iStatus Then
		Return 1
	EndIf

	Return 0
EndFunc   ;==>CloseProcessAndWait

Func RemoveAllProcess($aList)
	Dim $iCpt

	Local $aProcessList = ProcessList()

	For $i = 1 To $aProcessList[0][0]
		Local $sProcessName = $aProcessList[$i][0]
		Local $iPid = $aProcessList[$i][1]

		For $iCpt = 1 To UBound($aList) - 1
			If StringRegExp($sProcessName, $aList[$iCpt][1]) Then
				CloseProcessAndWait($iPid, $aList[$iCpt][2])
				UpdateToolCpt($aList[$iCpt][0], "process", $sProcessName)
			EndIf
		Next
	Next
EndFunc   ;==>RemoveAllProcess

Func RemoveScheduleTask($aList)
	For $i = 1 To UBound($aList) - 1
		RunWait('schtasks.exe /delete /tn "' & $aList[$i][1] & '" /f', @TempDir, @SW_HIDE)
	Next
EndFunc   ;==>RemoveScheduleTask

Func UninstallNormaly($aList)
	Local Const $aProgramFilesList = GetProgramFilesList()

	For $i = 1 To UBound($aProgramFilesList) - 1
		For $c = 1 To UBound($aList) - 1
			Local $sFolderReg = $aList[$c][1]
			Local $sFileReg = $aList[$c][2]

			Local $aGlobFolder = FindGlob($aProgramFilesList[$i], "*", $sFolderReg)

			For $f = 1 To UBound($aGlobFolder) - 1
				Local $aUninstallFiles = FindGlob($aGlobFolder[$f], "*", $sFileReg)

				For $u = 1 To UBound($aUninstallFiles) - 1
					If isFile($aUninstallFiles[$u]) Then
						RunWait($aUninstallFiles[$u])
						UpdateToolCpt($aList[$c][0], "uninstall", $aUninstallFiles[$u])
					EndIf
				Next
			Next
		Next
	Next
EndFunc   ;==>UninstallNormaly

Func RemoveAllProgramFilesDir($aList)
	Local Const $aProgramFilesList = GetProgramFilesList()

	For $i = 1 To UBound($aProgramFilesList) - 1
		RemoveAllFileFrom($aProgramFilesList[$i], $aList)
	Next
EndFunc   ;==>RemoveAllProgramFilesDir

Func RemoveAllSoftwareKeyList($aList)
	Local $s64Bit = ""
	If @OSArch = "X64" Then $s64Bit = "64"
	Local $aKeys[2] = ["HKCU" & $s64Bit & "\SOFTWARE", "HKLM" & $s64Bit & "\SOFTWARE"]

	For $k = 0 To UBound($aKeys) - 1
		Local $i = 0

		While True
			$i += 1
			Local $sEntry = RegEnumKey($aKeys[$k], $i)

			If @error <> 0 Then ExitLoop

			For $c = 1 To UBound($aList) - 1
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

Func RemoveUninstallStringWithSearch($aList)
	For $i = 1 To UBound($aList) - 1
		Local $sKeyFound = SearchRegistryKeyStrings($aList[$i][1], $aList[$i][2], $aList[$i][3])

		If $sKeyFound And $sKeyFound <> "" Then
			RemoveRegistryKey($sKeyFound, $aList[$i][0])
		EndIf
	Next
EndFunc   ;==>RemoveUninstallStringWithSearch

Func RemoveAllRegistryKeys($aList)
	For $i = 1 To UBound($aList) - 1
		RemoveRegistryKey($aList[$i][1], $aList[$i][0], $aList[$i][2])
	Next
EndFunc   ;==>RemoveAllRegistryKeys

Func CleanDirectoryContent($aList)
	For $i = 1 To UBound($aList) - 1
		If FileExists($aList[$i][1]) Then
			Local $aFileList = _FileListToArray($aList[$i][1])

			If @error = 0 Then
				For $f = 1 To $aFileList[0]
					RemoveFile($aList[$i][1] & '\' & $aFileList[$f], $aList[$i][0], $aList[$i][2], $aList[$i][3])
				Next
			EndIf
		EndIf
	Next
EndFunc   ;==>CleanDirectoryContent

