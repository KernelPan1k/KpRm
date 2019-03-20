
Func LoadRogueKiller()
	Local Const $ToolExistCpt = "roguekiller"
	Dim $KPRemoveProcessList
	Dim $KPRemoveScheduleTasksList
	Dim $KPRemoveSearchRegistryKeyStringsList
	Dim $KPRemoveProgramFilesList
	Dim $KPRemoveAppDataCommonList
	Dim $KPRemoveDesktopList
	Dim $KPRemoveDesktopCommonList
	Dim $KPRemoveAppDataCommonStartMenuFolderList
	Dim $KPRemoveDownloadList

	Local $s64Bit = ""
	If @OSArch = "X64" Then $s64Bit = "64"

	Local Const $patternDescription  = "(?i)^(RogueKiller.*|Anti-Malware Scan and Removal)$"
	Local Const $reg1 = "(?i)^RogueKiller"
	Local Const $reg2 = "(?i)^RogueKiller.*\.(exe|lnk|txt)$"
	Local Const $reg3 = "(?i)^RogueKiller.*\.exe$"

	Local Const $arr1[1][2] = [[$ToolExistCpt, $reg3]]
	Local Const $arr2[1][2] = [[$ToolExistCpt, "RogueKiller Anti-Malware"]]
	Local Const $arr3[1][4] = [[$ToolExistCpt, "HKLM" & $s64Bit & "\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall", $reg1, "DisplayName"]]
	Local Const $arr4[1][5] = [[$ToolExistCpt, 'file', $patternDescription, $reg2, False]]
	Local Const $arr5[1][5] = [[$ToolExistCpt, 'folder', Null, $reg1, True]]

	_ArrayAdd($KPRemoveProcessList,$arr1)
	_ArrayAdd($KPRemoveScheduleTasksList, $arr2)
	_ArrayAdd($KPRemoveSearchRegistryKeyStringsList, $arr3)
	_ArrayAdd($KPRemoveProgramFilesList, $arr5)
	_ArrayAdd($KPRemoveAppDataCommonList, $arr5)
	_ArrayAdd($KPRemoveDesktopList, $arr4)
	_ArrayAdd($KPRemoveDownloadList, $arr4)
	_ArrayAdd($KPRemoveDownloadList, $arr5)
	_ArrayAdd($KPRemoveDesktopCommonList, $arr4)
	_ArrayAdd($KPRemoveAppDataCommonStartMenuFolderList, $arr5)

EndFunc   ;==>RemoveRogueKiller

LoadRogueKiller()

