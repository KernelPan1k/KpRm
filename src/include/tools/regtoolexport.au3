
Func LoadRegToolExport()
	Local Const $ToolExistCpt = "RegtoolExport"
	Dim $KPRemoveProcessList
	Dim $KPRemoveDesktopList
	Dim $KPRemoveDownloadList

	Local Const $descriptionPattern = Null
	Local Const $reg1 = "(?i)^regtoolexport.*\.exe$"
	Local Const $reg2 = "(?i)^Export.*\.reg$"

	Local Const $arr1[1][3] = [[$ToolExistCpt, $reg1, False]]
	Local Const $arr2[1][5] = [[$ToolExistCpt, 'file', $descriptionPattern, $reg1, False]]
	Local Const $arr3[1][5] = [[$ToolExistCpt, 'file', $descriptionPattern, $reg2, False]]

	_ArrayAdd($KPRemoveProcessList, $arr1)
	_ArrayAdd($KPRemoveDesktopList, $arr2)
	_ArrayAdd($KPRemoveDesktopList, $arr3)
	_ArrayAdd($KPRemoveDownloadList, $arr2)
	_ArrayAdd($KPRemoveDownloadList, $arr3)

EndFunc   ;==>LoadRegToolExport


LoadRegToolExport()
