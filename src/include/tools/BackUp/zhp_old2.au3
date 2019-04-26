
Func LoadCommonZHP()
	Dim $KPRemoveAppDataLocalList
	Dim $KPRemoveSoftwareKeyList
	Dim $KPRemoveAppDataList

	Local $ToolExistCpt = "zhp"
	Local Const $val[1][2] = [[$ToolExistCpt, "(?i)^ZHP$"]]
	Local Const $val2[1][5] = [[$ToolExistCpt, 'folder', Null, "(?i)^ZHP$", True]]

	_ArrayAdd($KPRemoveSoftwareKeyList, $val)
		_ArrayAdd($KPRemoveAppDataLocalList, $val2)
	_ArrayAdd($KPRemoveAppDataList, $val2)
EndFunc   ;==>LoadCommonZHP

LoadCommonZHP()
