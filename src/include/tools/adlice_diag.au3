
Func LoadAdliceDiag()
	Local Const $ToolExistCpt = "adlicediag"
	Dim $KPRemoveProcessList
	Dim $KPRemoveSearchRegistryKeyStringsList
	Dim $KPRemoveProgramFilesList
	Dim $KPRemoveAppDataCommonList
	Dim $KPRemoveDesktopList
	Dim $KPRemoveDownloadList
	Dim $KPRemoveDesktopCommonList
	Dim $KPRemoveAppDataCommonStartMenuFolderList

	Local $s64Bit = ""
	If @OSArch = "X64" Then $s64Bit = "64"

	Local Const $processDescription = "(?i)^Adlice Diag"
	Local Const $reg1 = "(?i)^Diag version"
	Local Const $reg2 = "(?i)^Diag$"
	Local Const $reg3 = "(?i)^ADiag$"
	Local Const $reg4 = "(?i)^Diag_portable(32|64)\.exe$"
	Local Const $reg5 = "(?i)^Diag\.lnk$"
	Local Const $reg6 = "(?i)^Diag_setup\.exe$"
	Local Const $reg7 = "(?i)^Diag(32|64)?\.exe$"

	Local Const $arr1[1][2] = [[$ToolExistCpt, $processDescription]]
	Local Const $arr2[1][4] = [[$ToolExistCpt, "HKLM" & $s64Bit & "\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall", $reg1, "DisplayName"]]
	Local Const $arr3[1][5] = [[$ToolExistCpt, 'folder', Null, $reg2, True]]
	Local Const $arr4[1][5] = [[$ToolExistCpt, 'folder', Null, $reg3, True]]
	Local Const $arr5[1][5] = [[$ToolExistCpt, 'file', Null, $reg4, False]]
	Local Const $arr6[1][5] = [[$ToolExistCpt, 'file', Null, $reg5, False]]
	Local Const $arr7[1][5] = [[$ToolExistCpt, 'file', Null, $reg6, False]]
	Local Const $arr8[1][2] = [[$ToolExistCpt, $reg7]]

	_ArrayAdd($KPRemoveProcessList, $arr1)
	_ArrayAdd($KPRemoveProcessList, $arr8)
	_ArrayAdd($KPRemoveSearchRegistryKeyStringsList, $arr2)
	_ArrayAdd($KPRemoveProgramFilesList, $arr3)
	_ArrayAdd($KPRemoveAppDataCommonList, $arr4)
	_ArrayAdd($KPRemoveDesktopList, $arr5)
	_ArrayAdd($KPRemoveDesktopList, $arr6)
	_ArrayAdd($KPRemoveDesktopList, $arr7)
	_ArrayAdd($KPRemoveDownloadList, $arr5)
	_ArrayAdd($KPRemoveDownloadList, $arr7)
	_ArrayAdd($KPRemoveDesktopCommonList, $arr6)
	_ArrayAdd($KPRemoveAppDataCommonStartMenuFolderList, $arr3)


EndFunc   ;==>LoadAdliceDiag

LoadAdliceDiag()

