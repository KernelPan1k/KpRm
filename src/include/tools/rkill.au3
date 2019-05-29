
Func LoadRkill()
	Dim $aKPRemoveProcessList
	Dim $aKPRemoveDesktopList
	Dim $aKPRemoveDownloadList

	Local Const $sToolName = "Rkill"
	Local Const $sCompanyName = "(?i)^Bleeping Computer"

	Local Const $sReg1 = "(?i)^(rkill|iExplore)\.exe$"
	Local Const $sReg2 = "(?i)^(rkill|iExplore).*\.(exe|txt|zip)$"
	Local Const $sReg3 = "(?i)^rkill$"

	Local Const $aArr1[1][3] = [[$sToolName, $sReg1, False]]
	Local Const $aArr2[1][5] = [[$sToolName, 'file', $sCompanyName, $sReg2, True]]
	Local Const $aArr3[1][5] = [[$sToolName, 'folder', Null, $sReg3, False]]

	_ArrayAdd($aKPRemoveProcessList, $aArr1)
	_ArrayAdd($aKPRemoveDesktopList, $aArr2)
	_ArrayAdd($aKPRemoveDesktopList, $aArr3)
	_ArrayAdd($aKPRemoveDownloadList, $aArr2)
	_ArrayAdd($aKPRemoveDownloadList, $aArr3)

EndFunc

LoadRkill()
