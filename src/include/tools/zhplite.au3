
Func LoadZHPLite()
	Local Const $desciptionPattern = Null
	Local Const $ZhpFixExistCpt = "ZHPLite"

	Dim $KPRemoveProcessList
	Dim $KPRemoveDesktopList
	Dim $KPRemoveDownloadList

	Local Const $reg1 = "(?i)^ZHPLite.*\.exe$"
	Local Const $reg2 = "(?i)^ZHPLite.*\.(exe|txt|lnk)$"

	Local Const $arr1[1][3] = [[$ZhpFixExistCpt, $reg1, False]]
	Local Const $arr2[1][5] = [[$ZhpFixExistCpt, 'file', $desciptionPattern, $reg2, False]]

	_ArrayAdd($KPRemoveProcessList, $arr1)
	_ArrayAdd($KPRemoveDesktopList, $arr2)
	_ArrayAdd($KPRemoveDownloadList, $arr2)
EndFunc   ;==>LoadZHPLite

LoadZHPLite()
