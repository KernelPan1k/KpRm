
Func LoadZHPFix()
	Local Const $sCompanyName = Null
	Local Const $sToolName = "ZHPFix"

	Dim $aKPRemoveProcessList
	Dim $aKPRemoveDesktopList
	Dim $aKPRemoveDownloadList

	Local Const $sReg1 = "(?i)^ZHPFix.*\.exe$"
	Local Const $sReg2 = "(?i)^ZHPFix.*\.(exe|txt|lnk)$"

	Local Const $aArr1[1][3] = [[$sToolName, $sReg1, False]]
	Local Const $aArr2[1][5] = [[$sToolName, 'file', $sCompanyName, $sReg2, False]]

	_ArrayAdd($aKPRemoveProcessList, $aArr1)
	_ArrayAdd($aKPRemoveDesktopList, $aArr2)
	_ArrayAdd($aKPRemoveDownloadList, $aArr2)
EndFunc   ;==>LoadZHPFix

LoadZHPFix()
