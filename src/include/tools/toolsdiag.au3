
Func LoadToolsDiag()
	Local Const $ToolExistCpt = "toolsdiag"
	Dim $KPRemoveProcessList
	Dim $KPRemoveDesktopList
	Dim $KPRemoveDownloadList
	Dim $KPRemoveHomeDriveList

	Local Const $reg1 = "(?i)^toolsdiag.*\.exe$"
	Local Const $reg2 = "(?i)^ToolsDiag$"

	Local Const $arr1[1][4] = [[$ToolExistCpt, 'folder', Null, $reg2]]
	Local Const $arr2[1][4] = [[$ToolExistCpt, 'file', Null, $reg1]]
	Local Const $arr3[1][2] = [[$ToolExistCpt, $reg1]]

	_ArrayAdd($KPRemoveProcessList, $arr3)
	_ArrayAdd($KPRemoveDesktopList, $arr2)
	_ArrayAdd($KPRemoveDownloadList, $arr2)
	_ArrayAdd($KPRemoveHomeDriveList, $arr1)

EndFunc   ;==>LoadAswMbr
