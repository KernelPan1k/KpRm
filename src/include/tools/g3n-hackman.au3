
Func LoadGenHackman()
	Local Const $sToolName = "g3n-h@ckm@n tools"

	Dim $aKPRemoveSoftwareKeyList

	Local Const $sReg6 = "(?i)^g3n-h@ckm@n$"

	Local Const $aArr6[1][2] = [[$sToolName, $sReg6]]

	_ArrayAdd($aKPRemoveSoftwareKeyList, $aArr6)

EndFunc   ;==>LoadGenHackman

LoadGenHackman()
