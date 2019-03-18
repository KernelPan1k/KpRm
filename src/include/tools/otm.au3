
Func LoadOTM()
	Local Const $ToolExistCpt = "otm"
	Dim $KPRemoveProcessList
	Dim $KPRemoveDesktopList
	Dim $KPRemoveDownloadList
	Dim $KPRemoveHomeDriveList

	Local Const $reg1 = "(?i)^OTM.*\.exe$"
	Local Const $reg2 = "(?i)^_OTM$"

	Local Const $arr1[1][2] = [[$ToolExistCpt, $reg1]]
	Local Const $arr2[1][4] = [[$ToolExistCpt, 'file', Null, $reg1]]
	Local Const $arr3[1][4] = [[$ToolExistCpt, 'folder', Null, $reg2]]

	_ArrayAdd($KPRemoveProcessList, $arr1)
	_ArrayAdd($KPRemoveDesktopList, $arr2)
	_ArrayAdd($KPRemoveDownloadList, $arr2)
	_ArrayAdd($KPRemoveHomeDriveList, $arr3)
EndFunc   ;==>LoadOTM

LoadOTM()