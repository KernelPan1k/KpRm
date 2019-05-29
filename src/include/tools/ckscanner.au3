

Func LoadCKScanner()
	Local Const $sToolName = "CKScanner"
	Dim $aKPRemoveProcessList
	Dim $aKPRemoveDesktopList
	Dim $aKPRemoveDownloadList

	Local Const $sCompanyName = Null
	Local Const $sReg1 = "(?i)^CKScanner.*\.exe$"
	Local Const $sReg2 = "(?i)^CKfiles.*\.txt$"

	Local Const $aArr1[1][3] = [[$sToolName, $sReg1, False]]
	Local Const $aArr2[1][5] = [[$sToolName, 'file', $sCompanyName, $sReg1, False]]
	Local Const $aArr3[1][5] = [[$sToolName, 'file', $sCompanyName, $sReg2, False]]

	_ArrayAdd($aKPRemoveProcessList, $aArr1)
	_ArrayAdd($aKPRemoveDesktopList, $aArr2)
	_ArrayAdd($aKPRemoveDownloadList, $aArr2)
	_ArrayAdd($aKPRemoveDesktopList, $aArr3)
	_ArrayAdd($aKPRemoveDownloadList, $aArr3)

EndFunc   ;==>LoadCKScanner

LoadCKScanner()
