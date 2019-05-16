
Func LoadCommonZHP()
	Dim $aKPRemoveAppDataLocalList
	Dim $aKPRemoveSoftwareKeyList

	Local $sToolExistCpt = "ZHP Tools"
	Local Const $val[1][2] = [[$sToolExistCpt, "(?i)^ZHP$"]]
	Local Const $val2[1][5] = [[$sToolExistCpt, 'folder', Null, "(?i)^ZHP$", True]]

	_ArrayAdd($aKPRemoveSoftwareKeyList, $val)
	_ArrayAdd($aKPRemoveAppDataLocalList, $val2)
EndFunc   ;==>LoadCommonZHP

LoadCommonZHP()
