
Func LoadJavara()
	Dim $KPRemoveProcessList
	Dim $KPRemoveDesktopList
	Dim $KPRemoveDownloadList
	Dim $KPRemoveHomeDriveList

	Local Const $ToolExistCpt = "javara"
	Local Const $descriptionPattern = "(?i)^The RaProducts Team"

	Local Const $reg1 = "(?i)Javara"
	Local Const $reg2 = "(?i)Javara.*\.exe"
	Local Const $reg3 = "(?i)Javara.*\.(zip|exe)"
	Local Const $reg4 = "(?i)Javara.*\.log"

	Local Const $arr1[1][3] = [[$ToolExistCpt, $reg2, False]]
	Local Const $arr2[1][5] = [[$ToolExistCpt, 'file', $descriptionPattern, $reg3, False]]
	Local Const $arr3[1][5] = [[$ToolExistCpt, 'file', Null, $reg4, False]]
	Local Const $arr4[1][5] = [[$ToolExistCpt, 'folder', Null, $reg1, False]]

	_ArrayAdd($KPRemoveProcessList, $arr1)
	_ArrayAdd($KPRemoveDesktopList, $arr2)
	_ArrayAdd($KPRemoveDesktopList, $arr4)
	_ArrayAdd($KPRemoveDownloadList, $arr2)
	_ArrayAdd($KPRemoveDownloadList, $arr4)
	_ArrayAdd($KPRemoveHomeDriveList, $arr3)

EndFunc   ;==>LoadJavara

LoadJavara()
