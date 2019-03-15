
Func LoadZHPFix()
	Local Const $desciptionPattern = "(?i)^ZHPFix"

	Local Const $ZhpFixExistCpt = "zhpfix"
	Dim $KPRemoveProcessList
	Dim $KPRemoveDesktopList
	Dim $KPRemoveDownloadList

	Local Const $arr1[1][2] = [[$ZhpFixExistCpt, $desciptionPattern]]
	Local Const $arr2[1][3] = [[$ZhpFixExistCpt, $desciptionPattern, "(?i)^ZHPFix.*\.(exe|txt|lnk)$"]]

	_ArrayAdd($KPRemoveProcessList, $arr1)
	_ArrayAdd($KPRemoveDesktopList, $arr2)
	_ArrayAdd($KPRemoveDownloadList, $arr2)
EndFunc   ;==>RemoveZHPFix
