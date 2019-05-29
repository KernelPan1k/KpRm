
Func LoadCommonZHP()
	Dim $aKPRemoveAppDataLocalList
	Dim $aKPRemoveSoftwareKeyList

	Local $sToolName = "ZHP Tools"
	Local Const $val[1][2] = [[$sToolName, "(?i)^ZHP$"]]
	Local Const $val2[1][5] = [[$sToolName, 'folder', Null, "(?i)^ZHP$", True]]

	_ArrayAdd($aKPRemoveSoftwareKeyList, $val)
	_ArrayAdd($aKPRemoveAppDataLocalList, $val2)
EndFunc   ;==>LoadCommonZHP

LoadCommonZHP()
