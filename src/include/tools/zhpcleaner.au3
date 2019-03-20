
Func LoadZHPCleaner()
	Local Const $desciptionPattern = "(?i)^ZHPCleaner"
	Local Const $ToolExistCpt = "zhpcleaner"

	Dim $KPRemoveProcessList
	Dim $KPRemoveDesktopList
	Dim $KPRemoveDownloadList

	Local Const $reg1 = "(?i)^ZHPCleaner.*\.exe$"
	Local Const $reg2 = "(?i)^ZHPCleaner.*\.(exe|txt|lnk)$"

	Local Const $arr1[1][2] = [[$ToolExistCpt, $reg1]]
	Local Const $arr2[1][5] = [[$ToolExistCpt, 'file', $desciptionPattern, $reg2, False]]

	_ArrayAdd($KPRemoveProcessList, $arr1)
	_ArrayAdd($KPRemoveDesktopList, $arr2)
	_ArrayAdd($KPRemoveDownloadList, $arr2)

EndFunc   ;==>RemoveZHPCleaner

LoadZHPCleaner()