
Func LoadAdwcleaner()
	Local Const $ToolExistCpt = "adwcleaner"
	Local Const $descriptionPattern = "(?i)^AdwCleaner"
	Local Const $companyPattern = "(?i)^Malwarebytes"
	Local Const $reg1 = "(?i)^AdwCleaner.*\.exe$"

	Dim $KPRemoveProcessList
	Dim $KPRemoveDesktopList
	Dim $KPRemoveDownloadList
	Dim $KPRemoveHomeDriveList

	Local Const $arr1[1][2] = [[$ToolExistCpt, $reg1]]
	Local Const $arr2[1][5] = [[$ToolExistCpt, 'file', $companyPattern, $reg1, False]]
	Local Const $arr3[1][5] = [[$ToolExistCpt, 'folder', Null, $descriptionPattern, True]]

	_ArrayAdd($KPRemoveProcessList, $arr1)
	_ArrayAdd($KPRemoveDesktopList, $arr2)
	_ArrayAdd($KPRemoveDownloadList, $arr2)
	_ArrayAdd($KPRemoveHomeDriveList, $arr3)

EndFunc   ;==>LoadAdwcleaner

LoadAdwcleaner()