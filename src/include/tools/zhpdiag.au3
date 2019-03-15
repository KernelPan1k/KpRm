Func LoadCommonZHP()
	Dim $KPRemoveAppDataDirList
	Dim $KPRemoveAppDataLoacalDirList
	Dim $KPRemoveSoftwareKeyList

	Local $fake = "fake"
	Local Const $val[2] = [$fake, "(?i)^ZHP$"]

	_ArrayAdd($KPRemoveAppDataDirList, $val)
	_ArrayAdd($KPRemoveAppDataLoacalDirList, $val)
	_ArrayAdd($KPRemoveSoftwareKeyList, $val)
EndFunc   ;==>CommonZHP

Func LoadZHPDiag()
	LoadCommonZHP()

	Local Const $desciptionPattern = "(?i)^ZHPDiag"

	Local Const  $ZhpDiagExistCpt = "zhpdiag"
	Dim $KPRemoveProcessList
	Dim $KPRemoveDesktopList
	Dim $KPRemoveDesktopCommonList
	Dim $KPRemoveDownloadList

	Local Const $arr1[1][2] = [[$ZhpDiagExistCpt, $desciptionPattern]]
	Local Const $arr2[1][3] = [[$ZhpDiagExistCpt, $desciptionPattern, "(?i)^ZHPDiag.*\.(exe|txt|lnk)$"]]

	_ArrayAdd($KPRemoveProcessList, $arr1)
	_ArrayAdd($KPRemoveDesktopList, $arr2)
	_ArrayAdd($KPRemoveDownloadList, $arr2)
	_ArrayAdd($KPRemoveDesktopCommonList, $arr2)

EndFunc   ;==>RemoveZHPDiag
