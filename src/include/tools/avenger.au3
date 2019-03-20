

Func LoadAvenger()

	Local Const $ToolExistCpt = "avenger"
	Dim $KPRemoveProcessList
	Dim $KPRemoveDesktopList
	Dim $KPRemoveDownloadList
	Dim $KPRemoveHomeDriveList

	Local Const $descriptionPattern = Null
	Local Const $reg1 = "(?i)^avenger.*\.(exe|zip)$"
	Local Const $reg2 = "(?i)^avenger"
	Local Const $reg3 = "(?i)^avenger.*\.txt$"
	Local Const $reg4 = "(?i)^avenger.*\.exe$"

	Local Const $arr1[1][2] = [[$ToolExistCpt, $reg4]]
	Local Const $arr2[1][5] = [[$ToolExistCpt, 'file', $descriptionPattern, $reg1, False]]
	Local Const $arr3[1][5] = [[$ToolExistCpt, 'folder', $descriptionPattern, $reg2, False]]
	Local Const $arr4[1][5] = [[$ToolExistCpt, 'file', $descriptionPattern, $reg3, False]]

	_ArrayAdd($KPRemoveProcessList, $arr1)
	_ArrayAdd($KPRemoveDesktopList, $arr2)
	_ArrayAdd($KPRemoveDesktopList, $arr3)
	_ArrayAdd($KPRemoveDownloadList, $arr2)
	_ArrayAdd($KPRemoveDownloadList, $arr3)
	_ArrayAdd($KPRemoveHomeDriveList, $arr3)
	_ArrayAdd($KPRemoveHomeDriveList, $arr4)

EndFunc

LoadAvenger()