
Func LoadUnHide()
	Dim $aKPRemoveProcessList
	Dim $aKPRemoveDesktopList
	Dim $aKPRemoveDownloadList

	Local Const $sToolName = "UnHide"
	Local Const $sCompanyName = "(?i)^Bleeping Computer"

	Local Const $sReg1 = "(?i)^unhide.*\.exe$"
	Local Const $sReg2 = "(?i)^unhide.*\.(exe|txt)$"

	Local Const $aArr1[1][3] = [[$sToolName, $sReg1, False]]
	Local Const $aArr2[1][5] = [[$sToolName, 'file', $sCompanyName, $sReg2, False]]

	_ArrayAdd($aKPRemoveProcessList, $aArr1)
	_ArrayAdd($aKPRemoveDesktopList, $aArr2)
	_ArrayAdd($aKPRemoveDownloadList, $aArr2)

EndFunc   ;==>LoadUnHide

LoadUnHide()
