
Func LoadOTL()
	Local Const $ToolExistCpt = "otl"
	Dim $KPRemoveProcessList
	Dim $KPRemoveDesktopList
	Dim $KPRemoveDownloadList
	Dim $KPRemoveHomeDriveList

	Local Const $reg1 = "(?i)^OTL.*\.exe$"
	Local Const $reg2 = "(?i)^OTL.*\.(exe|txt)$"
	Local Const $reg3 = "(?i)^Extras\.txt$"
	Local Const $reg4 = "(?i)^_OTL$"

	Local Const $arr1[1][2] = [[$ToolExistCpt, $reg1]]
	Local Const $arr2[1][4] = [[$ToolExistCpt, 'file', Null, $reg2]]
	Local Const $arr3[1][4] = [[$ToolExistCpt, 'file', Null, $reg3]]
	Local Const $arr4[1][4] = [[$ToolExistCpt, 'folder', Null, $reg4]]

	_ArrayAdd($KPRemoveProcessList, $arr1)
	_ArrayAdd($KPRemoveDesktopList, $arr2)
	_ArrayAdd($KPRemoveDesktopList, $arr3)
	_ArrayAdd($KPRemoveDownloadList, $arr2)
	_ArrayAdd($KPRemoveHomeDriveList, $arr4)
EndFunc   ;==>LoadOTL

LoadOTL()