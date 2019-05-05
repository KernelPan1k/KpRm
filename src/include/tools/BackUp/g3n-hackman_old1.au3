
Func LoadGenHackman()

	Local Const $ToolExistCpt = "g3n-h@ckm@n_tools"

	Dim $KPRemoveSoftwareKeyList

	Local Const $reg6 = "(?i)^g3n-h@ckm@n$"

	Local Const $arr6[1][2] = [[$ToolExistCpt, $reg6]]

	_ArrayAdd($KPRemoveSoftwareKeyList, $arr6)

EndFunc

LoadGenHackman()
