
Func LoadAswMbr()
	Local Const $ToolExistCpt = "aswmbr"
	Dim $KPRemoveProcessList
	Dim $KPRemoveDesktopList
	Dim $KPRemoveDownloadList

	Local Const $descriptionPattern = "(?i)^avast"
	Local Const $reg1 = "(?i)^aswmbr.*\.(exe|txt|lnk)$"
	Local Const $reg2 = "(?i)^MBR\.dat$"
	Local Const $reg3 = "(?i)^aswmbr.*\.exe$"

		Local $s64Bit = ""
	If @OSArch = "X64" Then $s64Bit = "64"

	Local Const $arr1[1][2] = [[$ToolExistCpt, $reg3]]
	Local Const $arr2[1][5] = [[$ToolExistCpt, 'file', $descriptionPattern, $reg1, False]]
	Local Const $arr3[1][5] = [[$ToolExistCpt, 'file', Null, $reg2, False]]

	_ArrayAdd($KPRemoveProcessList, $arr1)
	_ArrayAdd($KPRemoveDesktopList, $arr2)
	_ArrayAdd($KPRemoveDesktopList, $arr3)
	_ArrayAdd($KPRemoveDownloadList, $arr2)

EndFunc   ;==>LoadAswMbr

LoadAswMbr()