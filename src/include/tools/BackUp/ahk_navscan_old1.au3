
Func LoadAHK_NavScan()
	Dim $KPRemoveProcessList
	Dim $KPRemoveDesktopList
	Dim $KPRemoveDownloadList

	Local Const $ToolExistCpt = "AHK_NavScan"

	Local Const $reg1 = "(?i)^AHK_NavScan.*\.exe"
	Local Const $reg2 = "(?i)^AHK_NavScan.*\.(exe|txt)"

	Local Const $arr1[1][3] = [[$ToolExistCpt, $reg1, False]]
	Local Const $arr2[1][5] = [[$ToolExistCpt, 'file', $descriptionPattern, $reg1, False]]

	_ArrayAdd($KPRemoveProcessList, $arr1)
	_ArrayAdd($KPRemoveDesktopList, $arr2)
	_ArrayAdd($KPRemoveDownloadList, $arr2)
EndFunc

LoadAHK_NavScan()