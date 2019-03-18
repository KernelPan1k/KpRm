
Func LoadZHPDiag()
	Local Const $desciptionPattern = "(?i)^ZHPDiag"
	Local Const  $ToolExistCpt = "zhpdiag"

	Dim $KPRemoveProcessList
	Dim $KPRemoveDesktopList
	Dim $KPRemoveDesktopCommonList
	Dim $KPRemoveDownloadList

	Local Const $reg1 = "(?i)^ZHPDiag.*\.exe$"
	Local Const $reg2 = "(?i)^ZHPDiag.*\.(exe|txt|lnk)$"

	Local Const $arr1[1][2] = [[$ToolExistCpt, $reg1]]
	Local Const $arr2[1][4] = [[$ToolExistCpt, 'file',  $desciptionPattern, $reg2]]

	_ArrayAdd($KPRemoveProcessList, $arr1)
	_ArrayAdd($KPRemoveDesktopList, $arr2)
	_ArrayAdd($KPRemoveDownloadList, $arr2)
	_ArrayAdd($KPRemoveDesktopCommonList, $arr2)

EndFunc   ;==>RemoveZHPDiag

LoadZHPDiag()