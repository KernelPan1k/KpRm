
Func LoadFSS()
	Local Const $sToolName = "FSS"
	Dim $aKPRemoveProcessList
	Dim $aKPRemoveDesktopList
	Dim $aKPRemoveDownloadList

	Local Const $sCompanyName = "(?i)^Farbar"
	Local Const $sReg1 = "(?i)^FSS.*\.(exe|txt|lnk)$"
	Local Const $sReg2 = "(?i)^FSS.*\.exe$"

	Local Const $aArr1[1][3] = [[$sToolName, $sReg2, False]]
	Local Const $aArr2[1][5] = [[$sToolName, 'file', $sCompanyName, $sReg1, False]]

	_ArrayAdd($aKPRemoveProcessList, $aArr1)
	_ArrayAdd($aKPRemoveDesktopList, $aArr2)
	_ArrayAdd($aKPRemoveDownloadList, $aArr2)

EndFunc   ;==>LoadFSS

LoadFSS()
