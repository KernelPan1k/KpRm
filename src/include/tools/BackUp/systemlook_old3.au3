

Func LoadSystemLookup()
	Local Const $ToolExistCpt = "systemlook"
	Dim $KPRemoveProcessList
	Dim $KPRemoveDesktopList
	Dim $KPRemoveDownloadList

	Local Const $descriptionPattern = Null
	Local Const $reg1 = "(?i)^SystemLook.*\.exe$"
	Local Const $reg2 = "(?i)^SystemLook.*\.(exe|txt)$"

	Local Const $arr1[1][3] = [[$ToolExistCpt, $reg1, False]]
	Local Const $arr2[1][5] = [[$ToolExistCpt, 'file', $descriptionPattern, $reg2, False]]

	_ArrayAdd($KPRemoveProcessList, $arr1)
	_ArrayAdd($KPRemoveDesktopList, $arr2)
	_ArrayAdd($KPRemoveDownloadList, $arr2)


EndFunc   ;==>LoadSystemLookup

LoadSystemLookup()
