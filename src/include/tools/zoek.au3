

Func LoadZoek()

	Local Const $ToolExistCpt = "zoek"
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

	Local Const $arr1[1][2] = [[$ToolExistCpt, $reg1]]
	Local Const $arr2[1][4] = [[$ToolExistCpt, 'file', $descriptionPattern, $reg1]]
	Local Const $arr3[1][4] = [[$ToolExistCpt, 'file', $descriptionPattern, $reg2]]
	Local Const $arr4[1][4] = [[$ToolExistCpt, 'folder', $descriptionPattern, $reg3]]

	_ArrayAdd($KPRemoveProcessList, $arr1)
	_ArrayAdd($KPRemoveDesktopList, $arr2)
	_ArrayAdd($KPRemoveDownloadList, $arr2)
	_ArrayAdd($KPRemoveHomeDriveList, $arr3)
	_ArrayAdd($KPRemoveHomeDriveList, $arr4)

EndFunc

LoadZoek()
