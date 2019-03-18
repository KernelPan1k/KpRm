
Func LoadAswMbr()
	Local Const $ToolExistCpt = "aswmbr"
	Dim $KPRemoveProcessList
	Dim $KPRemoveDesktopList
	Dim $KPRemoveDownloadList

	Local Const $descriptionPattern = "(?i)^avast"
	Local Const $reg1 = "(?i)^aswmbr.*\.(exe|txt|lnk)$"
	Local Const $reg2 = "(?i)^MBR\.dat$"
	Local Const $reg3 = "(?i)^aswmbr.*\.exe$"

	Local Const $arr1[1][2] = [[$ToolExistCpt, $reg3]]
	Local Const $arr2[1][4] = [[$ToolExistCpt, 'file', $descriptionPattern, $reg1]]
	Local Const $arr3[1][4] = [[$ToolExistCpt, 'file', Null, $reg2]]

	_ArrayAdd($KPRemoveProcessList, $arr1)
	_ArrayAdd($KPRemoveDesktopList, $arr2)
	_ArrayAdd($KPRemoveDesktopList, $arr3)
	_ArrayAdd($KPRemoveDownloadList, $arr2)

EndFunc   ;==>LoadAswMbr
