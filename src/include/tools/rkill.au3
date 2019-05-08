
Func LoadRkill()
	Dim $KPRemoveProcessList
	Dim $KPRemoveDesktopList
	Dim $KPRemoveDownloadList

	Local Const $ToolExistCpt = "Rkill"
	Local Const $descriptionPattern = "(?i)^Bleeping Computer"

	Local Const $reg1 = "(?i)^(rkill|iExplore)\.exe$"
	Local Const $reg2 = "(?i)^(rkill|iExplore).*\.(exe|txt|zip)$"
	Local Const $reg3 = "(?i)^rkill$"

	Local Const $arr1[1][3] = [[$ToolExistCpt, $reg1, False]]
	Local Const $arr2[1][5] = [[$ToolExistCpt, 'file', $descriptionPattern, $reg2, True]]
	Local Const $arr3[1][5] = [[$ToolExistCpt, 'folder', Null, $reg3, False]]

	_ArrayAdd($KPRemoveProcessList, $arr1)
	_ArrayAdd($KPRemoveDesktopList, $arr2)
	_ArrayAdd($KPRemoveDesktopList, $arr3)
	_ArrayAdd($KPRemoveDownloadList, $arr2)
	_ArrayAdd($KPRemoveDownloadList, $arr3)

EndFunc

LoadRkill()