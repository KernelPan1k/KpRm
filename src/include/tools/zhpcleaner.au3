
Func LoadZHPCleaner()
	Local Const $desciptionPattern = Null
	Local Const $ToolExistCpt = "ZHPCleaner"

	Dim $KPRemoveProcessList
	Dim $KPRemoveDesktopList
	Dim $KPRemoveDownloadList

	Local Const $reg1 = "(?i)^ZHPCleaner.*\.exe$"
	Local Const $reg2 = "(?i)^ZHPCleaner.*\.(exe|txt|lnk)$"

	Local Const $arr1[1][3] = [[$ToolExistCpt, $reg1, False]]
	Local Const $arr2[1][5] = [[$ToolExistCpt, 'file', $desciptionPattern, $reg2, False]]

	_ArrayAdd($KPRemoveProcessList, $arr1)
	_ArrayAdd($KPRemoveDesktopList, $arr2)
	_ArrayAdd($KPRemoveDownloadList, $arr2)

EndFunc   ;==>LoadZHPCleaner

LoadZHPCleaner()
