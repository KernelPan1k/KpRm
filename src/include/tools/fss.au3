
Func LoadFSS()
	Local Const $ToolExistCpt = "FSS"
	Dim $KPRemoveProcessList
	Dim $KPRemoveDesktopList
	Dim $KPRemoveDownloadList

	Local Const $descriptionPattern = "(?i)^Farbar"
	Local Const $reg1 = "(?i)^FSS.*\.(exe|txt|lnk)$"
	Local Const $reg2 = "(?i)^FSS.*\.exe$"

	Local Const $arr1[1][3] = [[$ToolExistCpt, $reg2, False]]
	Local Const $arr2[1][5] = [[$ToolExistCpt, 'file', $descriptionPattern, $reg1, False]]

	_ArrayAdd($KPRemoveProcessList, $arr1)
	_ArrayAdd($KPRemoveDesktopList, $arr2)
	_ArrayAdd($KPRemoveDownloadList, $arr2)

EndFunc   ;==>LoadFSS

LoadFSS()
