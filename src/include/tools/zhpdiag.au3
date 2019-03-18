Func LoadCommonZHP()
	Dim $KPRemoveAppDataList
	Dim $KPRemoveAppDataLocalList
	Dim $KPRemoveSoftwareKeyList

	Local $fake = "fake"
	Local Const $val[1][2] = [[$fake, "(?i)^ZHP$"]]
	Local Const $val2[1][4] = [[$fake, 'folder', Null, "(?i)^ZHP$"]]

	_ArrayAdd($KPRemoveAppDataList, $val2)
	_ArrayAdd($KPRemoveAppDataLocalList, $val2)
	_ArrayAdd($KPRemoveSoftwareKeyList, $val)
EndFunc   ;==>CommonZHP

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
