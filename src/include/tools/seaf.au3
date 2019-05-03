

Func LoadSeaf()
	Local Const $ToolExistCpt = "seaf"
	Dim $KPRemoveProcessList
	Dim $KPRemoveDesktopList
	Dim $KPRemoveDownloadList
	Dim $KPUninstallNormalyList
	Dim $KPRemoveRegistryKeysList
	Dim $KPRemoveHomeDriveList
	Dim $KPRemoveProgramFilesList

	Local Const $descriptionPattern = "(?i)^C_XX$"
	Local Const $folderPattern = "(?i)^SEAF$"
	Local Const $reg1 = "(?i)^seaf.*\.exe$"
	Local Const $reg2 = "(?i)^Un-SEAF\.exe$"
	Local Const $reg3 = "(?i)^SeafLog.*\.txt$"

	Local $s64Bit = ""
	If @OSArch = "X64" Then $s64Bit = "64"

	Local Const $arr1[1][2] = [[$ToolExistCpt, $reg1]]
	Local Const $arr2[1][5] = [[$ToolExistCpt, 'file', $descriptionPattern, $reg1, False]]
	Local Const $arr3[1][3] = [[$ToolExistCpt, $folderPattern, $reg2]]
	Local Const $arr4[1][3] = [[$ToolExistCpt, "HKLM" & $s64Bit & "\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\SEAF", False]]
	Local Const $arr5[1][5] = [[$ToolExistCpt, 'file', Null, $reg3, False]]
	Local Const $arr6[1][5] = [[$ToolExistCpt, 'folder', Null, $folderPattern, True]]

	_ArrayAdd($KPRemoveProcessList, $arr1)
	_ArrayAdd($KPRemoveDesktopList, $arr2)
	_ArrayAdd($KPRemoveDownloadList, $arr2)
	_ArrayAdd($KPUninstallNormalyList, $arr3)
	_ArrayAdd($KPRemoveRegistryKeysList, $arr4)
	_ArrayAdd($KPRemoveHomeDriveList, $arr5)
	_ArrayAdd($KPRemoveProgramFilesList, $arr6)

EndFunc   ;==>LoadSeaf

LoadSeaf()
