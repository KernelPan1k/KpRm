
Func LoadRogueKiller()
	Local Const $sToolName = "RogueKiller"
	Dim $aKPRemoveProcessList
	Dim $aKPRemoveScheduleTasksList
	Dim $aKPRemoveSearchRegistryKeyStringsList
	Dim $aKPRemoveProgramFilesList
	Dim $aKPRemoveAppDataCommonList
	Dim $aKPRemoveDesktopList
	Dim $aKPRemoveDesktopCommonList
	Dim $aKPRemoveAppDataCommonStartMenuFolderList
	Dim $aKPRemoveDownloadList

	Local $s64Bit = GetSuffixKey()

	Local Const $patternDescription = "(?i)^Adlice"
	Local Const $sReg1 = "(?i)^RogueKiller"
	Local Const $sReg2 = "(?i)^RogueKiller.*\.(exe|lnk|txt)$"
	Local Const $sReg3 = "(?i)^RogueKiller.*\.exe$"
	Local Const $sReg4 = "(?i)^RogueKiller_portable(32|64)\.exe$"

	Local Const $aArr1[1][3] = [[$sToolName, $sReg3, False]]
	Local Const $aArr2[1][2] = [[$sToolName, "RogueKiller Anti-Malware"]]
	Local Const $aArr3[1][4] = [[$sToolName, "HKLM" & $s64Bit & "\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall", $sReg1, "DisplayName"]]
	Local Const $aArr4[1][5] = [[$sToolName, 'file', $patternDescription, $sReg2, False]]
	Local Const $aArr5[1][5] = [[$sToolName, 'folder', Null, $sReg1, True]]
	Local Const $aArr6[1][5] = [[$sToolName, 'file', Null, $sReg4, False]]

	_ArrayAdd($aKPRemoveProcessList, $aArr1)
	_ArrayAdd($aKPRemoveScheduleTasksList, $aArr2)
	_ArrayAdd($aKPRemoveSearchRegistryKeyStringsList, $aArr3)
	_ArrayAdd($aKPRemoveProgramFilesList, $aArr5)
	_ArrayAdd($aKPRemoveAppDataCommonList, $aArr5)
	_ArrayAdd($aKPRemoveDesktopList, $aArr6)
	_ArrayAdd($aKPRemoveDesktopList, $aArr4)
	_ArrayAdd($aKPRemoveDesktopList, $aArr5)
	_ArrayAdd($aKPRemoveDownloadList, $aArr6)
	_ArrayAdd($aKPRemoveDownloadList, $aArr4)
	_ArrayAdd($aKPRemoveDownloadList, $aArr5)
	_ArrayAdd($aKPRemoveDesktopCommonList, $aArr4)
	_ArrayAdd($aKPRemoveAppDataCommonStartMenuFolderList, $aArr5)

EndFunc   ;==>LoadRogueKiller

LoadRogueKiller()

