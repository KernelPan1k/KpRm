
Func LoadEsetOnlineScanner()
	Dim $KPRemoveProcessList
	Dim $KPRemoveDesktopList
	Dim $KPRemoveDownloadList
	Dim $KPRemoveAppDataLocalList
	Dim $KPRemoveRegistryKeysList

	Local Const $ToolExistCpt = "ESET Online Scanner"
	Local Const $descriptionPattern = "(?i)^ESET"

	Local Const $reg1 = "(?i)esetonlinescanner.*\.exe"
	Local Const $reg2 = "(?i)log.*\.txt"

	Local $s64Bit = ""
	If @OSArch = "X64" Then $s64Bit = "64"

	Local Const $arr1[1][3] = [[$ToolExistCpt, $reg1, False]]
	Local Const $arr2[1][5] = [[$ToolExistCpt, 'file', $descriptionPattern, $reg1, False]]
	Local Const $arr3[1][5] = [[$ToolExistCpt, 'file', Null, $reg2, False]]
	Local Const $arr4[1][5] = [[$ToolExistCpt, 'folder', Null, "(?i)^ESET$", True]]
	Local Const $arr5[1][3] = [[$ToolExistCpt, "HKLM" & $s64Bit & "\SOFTWARE\ESET\ESET Online Scanner", False]]

	_ArrayAdd($KPRemoveProcessList, $arr1)
	_ArrayAdd($KPRemoveDesktopList, $arr2)
	_ArrayAdd($KPRemoveDesktopList, $arr3)
	_ArrayAdd($KPRemoveDownloadList, $arr2)
	_ArrayAdd($KPRemoveDownloadList, $arr3)
	_ArrayAdd($KPRemoveAppDataLocalList, $arr4)
	_ArrayAdd($KPRemoveRegistryKeysList, $arr5)

EndFunc   ;==>LoadEsetOnlineScanner

LoadEsetOnlineScanner()
