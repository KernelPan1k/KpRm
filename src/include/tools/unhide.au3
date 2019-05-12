
Func LoadUnHide()
	Dim $KPRemoveProcessList
	Dim $KPRemoveDesktopList
	Dim $KPRemoveDownloadList

	Local Const $ToolExistCpt = "UnHide"
	Local Const $descriptionPattern = "(?i)^Bleeping Computer"

	Local Const $reg1 = "(?i)^unhide.*\.exe$"
	Local Const $reg2 = "(?i)^unhide.*\.(exe|txt)$"

	Local Const $arr1[1][3] = [[$ToolExistCpt, $reg1, False]]
	Local Const $arr2[1][5] = [[$ToolExistCpt, 'file', $descriptionPattern, $reg2, False]]

	_ArrayAdd($KPRemoveProcessList, $arr1)
	_ArrayAdd($KPRemoveDesktopList, $arr2)
	_ArrayAdd($KPRemoveDownloadList, $arr2)

EndFunc   ;==>LoadUnHide

LoadUnHide()
