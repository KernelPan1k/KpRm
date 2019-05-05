

Func LoadSystemLookup()
	Local Const $ToolExistCpt = "systemlook"
	Dim $KPRemoveProcessList
	Dim $KPRemoveDesktopList
	Dim $KPRemoveDownloadList

	Local Const $descriptionPattern = Null
	Local Const $reg1 = "(?i)^SystemLook.*\.exe$"
		Local Const $reg1 = "(?i)^FSS.*\.(exe|txt|lnk)$"


	Local Const $arr1[1][2] = [[$ToolExistCpt, $reg2]]
	Local Const $arr2[1][5] = [[$ToolExistCpt, 'file', $descriptionPattern, $reg1, False]]

	_ArrayAdd($KPRemoveProcessList, $arr1)
	_ArrayAdd($KPRemoveDesktopList, $arr2)
	_ArrayAdd($KPRemoveDownloadList, $arr2)


EndFunc   ;==>LoadSystemLookup

LoadSystemLookup()
