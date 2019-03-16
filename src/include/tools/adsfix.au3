
Func LoadADSFix()
	Local Const $ToolExistCpt = "adsfix"
	Dim $KPRemoveProcessList
	Dim $KPRemoveDesktopList
	Dim $KPRemoveDownloadList
	Dim $KPRemoveHomeDriveList
	Dim $KPRemoveDesktopCommonList
	Dim $KPRemoveSoftwareKeyList
	Dim $KPRemoveHomeDriveFileList

	Local Const $descriptionPattern = "(?i)^AdsFix"

	Local Const $arr1[1][2] = [[$ToolExistCpt, $descriptionPattern]]
	Local Const $arr2[1][3] = [[$ToolExistCpt, $descriptionPattern, "(?i)^AdsFix.*\.(exe|txt|lnk)$"]]
	Local Const $arr3[1][3] = [[$ToolExistCpt, Null, "(?i)^AdsFix.*\.txt$"]]

	_ArrayAdd($KPRemoveProcessList, $arr1)
	_ArrayAdd($KPRemoveDesktopList, $arr2)
	_ArrayAdd($KPRemoveDesktopCommonList, $arr2)
	_ArrayAdd($KPRemoveDownloadList, $arr2)
	_ArrayAdd($KPRemoveHomeDriveList, $arr1)
	_ArrayAdd($KPRemoveSoftwareKeyList, $arr1)
	_ArrayAdd($KPRemoveHomeDriveFileList, $arr3)

EndFunc   ;==>LoadADSFix
