
Func LoadZHPDiag()
	Local Const $desciptionPattern = Null
	Local Const $ToolExistCpt = "zhpdiag"

	Dim $KPRemoveProcessList
	Dim $KPRemoveDesktopList
	Dim $KPRemoveDesktopCommonList
	Dim $KPRemoveDownloadList
	Dim $KPRemoveHomeDriveList

	Local Const $reg1 = "(?i)^ZHPDiag.*\.exe$"
	Local Const $reg2 = "(?i)^ZHPDiag.*\.(exe|txt|lnk)$"
	Local Const $reg3 = "(?i)^PhysicalDisk[0-9]_MBR\.bin$"

	Local Const $arr1[1][3] = [[$ToolExistCpt, $reg1, False]]
	Local Const $arr2[1][5] = [[$ToolExistCpt, 'file', $desciptionPattern, $reg2, False]]
	Local Const $arr3[1][5] = [[$ToolExistCpt, 'file', Null, $reg3, True]]

	_ArrayAdd($KPRemoveProcessList, $arr1)
	_ArrayAdd($KPRemoveDesktopList, $arr2)
	_ArrayAdd($KPRemoveDownloadList, $arr2)
	_ArrayAdd($KPRemoveDesktopCommonList, $arr2)
	_ArrayAdd($KPRemoveHomeDriveList, $arr3)

EndFunc   ;==>LoadZHPDiag

LoadZHPDiag()
