

Func LoadZoek()

	Local Const $ToolExistCpt = "Zoek"
	Dim $KPRemoveProcessList
	Dim $KPRemoveDesktopList
	Dim $KPRemoveDownloadList
	Dim $KPRemoveHomeDriveList
	Dim $KPRemoveDesktopCommonList
	Dim $KPRemoveSoftwareKeyList

	Local Const $descriptionPattern = Null
	Local Const $reg1 = "(?i)^zoek.*\.exe$"
	Local Const $reg2 = "(?i)^zoek.*\.log$"
	Local Const $reg3 = "(?i)^zoek"
	Local Const $reg4 = "(?i)^runcheck.*\.txt$"

	Local Const $arr1[1][3] = [[$ToolExistCpt, $reg1, False]]
	Local Const $arr2[1][5] = [[$ToolExistCpt, 'file', $descriptionPattern, $reg1, False]]
	Local Const $arr3[1][5] = [[$ToolExistCpt, 'file', $descriptionPattern, $reg2, False]]
	Local Const $arr4[1][5] = [[$ToolExistCpt, 'folder', $descriptionPattern, $reg3, True]]
	Local Const $arr5[1][5] = [[$ToolExistCpt, 'file', $descriptionPattern, $reg4, False]]

	_ArrayAdd($KPRemoveProcessList, $arr1)
	_ArrayAdd($KPRemoveDesktopList, $arr2)
	_ArrayAdd($KPRemoveDownloadList, $arr2)
	_ArrayAdd($KPRemoveHomeDriveList, $arr3)
	_ArrayAdd($KPRemoveHomeDriveList, $arr4)
	_ArrayAdd($KPRemoveHomeDriveList, $arr5)

EndFunc   ;==>LoadZoek

LoadZoek()
