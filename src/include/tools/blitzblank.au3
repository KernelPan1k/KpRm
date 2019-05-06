

Func LoadBlitzBlank()
	Local Const $ToolExistCpt = "BlitzBlank"
	Dim $KPRemoveProcessList
	Dim $KPRemoveDesktopList
	Dim $KPRemoveDownloadList
	Dim $KPRemoveHomeDriveList
	Dim $KPRemoveDesktopCommonList
	Dim $KPRemoveSoftwareKeyList

	Local Const $descriptionPattern = "(?i)^Emsi"
	Local Const $reg1 = "(?i)^BlitzBlank.*\.exe$"
	Local Const $reg2 = "(?i)^BlitzBlank.*\.log$"

	Local Const $arr1[1][3] = [[$ToolExistCpt, $reg1, False]]
	Local Const $arr2[1][5] = [[$ToolExistCpt, 'file', $descriptionPattern, $reg1, False]]
	Local Const $arr3[1][5] = [[$ToolExistCpt, 'file', Null, $reg2, False]]

	_ArrayAdd($KPRemoveProcessList, $arr1)
	_ArrayAdd($KPRemoveDesktopList, $arr2)
	_ArrayAdd($KPRemoveDownloadList, $arr2)
	_ArrayAdd($KPRemoveHomeDriveList, $arr3)

EndFunc   ;==>LoadBlitzBlank

LoadBlitzBlank()
