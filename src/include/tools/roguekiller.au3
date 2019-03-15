
Func LoadRogueKiller($retry = False)
	Local Const $RogueKillerFixExistCpt = "roguekiller"
	Dim $KPRemoveProcessList
	Dim $KPRemoveScheduleTasksList
	Dim $KPRemoveSearchRegistryKeyStringsList
	Dim $KPRemoveProgramFilesList
	Dim $KPRemoveAppDataCommonDirList
	Dim $KPRemoveDesktopList
	Dim $KPRemoveDesktopCommonList
	Dim $KPRemoveDownloadFolderList
	Dim $KPRemoveAppDataCommonDirStartMenuFolderList

	Local $s64Bit = ""
	If @OSArch = "X64" Then $s64Bit = "64"

	Local Const $patternDescription  = "(?i)^(RogueKiller.*|Anti-Malware Scan and Removal)$"
	Local Const $reg1 = "(?i)^RogueKiller"
	Local Const $reg2 = "(?i)^RogueKiller.*\.(exe|lnk)"

	Local Const $arr1[1][2] = [[$RogueKillerFixExistCpt, $reg1]]
	Local Const $arr2[1][2] = [[$RogueKillerFixExistCpt, "RogueKiller Anti-Malware"]]
	Local Const $arr3[1][4] = [[$RogueKillerFixExistCpt, "HKLM" & $s64Bit & "\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall", $reg1, "DisplayName"]]
	Local Const $arr4[1][3] = [[$RogueKillerFixExistCpt, $patternDescription, $reg2]]
	Local Const $arr5[1][3] = [[$RogueKillerFixExistCpt, Null, "(?i)^RogueKiller.*\.lnk"]]

	_ArrayAdd($KPRemoveProcessList,$arr1)
	_ArrayAdd($KPRemoveScheduleTasksList, $arr2)
	_ArrayAdd($KPRemoveSearchRegistryKeyStringsList, $arr3)
	_ArrayAdd($KPRemoveProgramFilesList, $arr1)
	_ArrayAdd($KPRemoveAppDataCommonDirList, $arr1)
	_ArrayAdd($KPRemoveDesktopList, $arr4)
	_ArrayAdd($KPRemoveDesktopCommonList, $arr5)
	_ArrayAdd($KPRemoveDownloadFolderList, $arr4)
	_ArrayAdd($KPRemoveAppDataCommonDirStartMenuFolderList, $arr1)

EndFunc   ;==>RemoveRogueKiller

