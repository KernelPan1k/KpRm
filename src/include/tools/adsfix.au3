
Func LoadADSFix()
	Local Const $ToolExistCpt = "adsfix"
	Dim $KPRemoveProcessList
	Dim $KPRemoveDesktopList
	Dim $KPRemoveDownloadList
	Dim $KPRemoveHomeDriveList
	Dim $KPRemoveDesktopCommonList
	Dim $KPRemoveSoftwareKeyList

	Local Const $descriptionPattern = "(?i)^AdsFix"
	Local Const $reg1 = "(?i)^AdsFix.*\.exe$"
	Local Const $reg2 = "(?i)^AdsFix.*\.(exe|txt|lnk)$"
	Local Const $reg3 = "(?i)^AdsFix.*\.txt$"

	Local Const $arr1[1][2] = [[$ToolExistCpt, $reg1]]
	Local Const $arr2[1][4] = [[$ToolExistCpt, 'file', $descriptionPattern, $reg2]]
	Local Const $arr3[1][4] = [[$ToolExistCpt, 'file', Null, $reg3]]
	Local Const $arr4[1][4] = [[$ToolExistCpt, 'folder', Null, $descriptionPattern]]
	Local Const $arr5[1][2] = [[$ToolExistCpt, $descriptionPattern]]

	_ArrayAdd($KPRemoveProcessList, $arr1)
	_ArrayAdd($KPRemoveDesktopList, $arr2)
	_ArrayAdd($KPRemoveDesktopCommonList, $arr2)
	_ArrayAdd($KPRemoveDownloadList, $arr2)
	_ArrayAdd($KPRemoveHomeDriveList, $arr3)
	_ArrayAdd($KPRemoveHomeDriveList, $arr4)
	_ArrayAdd($KPRemoveSoftwareKeyList, $arr5)

EndFunc   ;==>LoadADSFix

LoadADSFix()