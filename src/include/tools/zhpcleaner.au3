
Func LoadZHPCleaner()
	Local Const $desciptionPattern = "(?i)^ZHPCleaner"

	Local Const $ZhpCleanerExistCpt = "zhpcleaner"
	Dim $KPRemoveProcessList
	Dim $KPRemoveDesktopList
	Dim $KPRemoveDownloadList

	Local Const $arr1[1][2] = [[$ZhpCleanerExistCpt, $desciptionPattern]]
	Local Const $arr2[1][3] = [[$ZhpCleanerExistCpt, $desciptionPattern, "(?i)^ZHPCleaner.*\.(exe|txt|lnk)$"]]

	_ArrayAdd($KPRemoveProcessList, $arr1)
	_ArrayAdd($KPRemoveDesktopList, $arr2)
	_ArrayAdd($KPRemoveDownloadList, $arr2)

EndFunc   ;==>RemoveZHPCleaner
