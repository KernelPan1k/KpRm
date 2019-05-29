

Func LoadSystemLookup()
	Local Const $sToolName = "Systemlook"
	Dim $aKPRemoveProcessList
	Dim $aKPRemoveDesktopList
	Dim $aKPRemoveDownloadList

	Local Const $sCompanyName = Null
	Local Const $sReg1 = "(?i)^SystemLook.*\.exe$"
	Local Const $sReg2 = "(?i)^SystemLook.*\.(exe|txt)$"

	Local Const $aArr1[1][3] = [[$sToolName, $sReg1, False]]
	Local Const $aArr2[1][5] = [[$sToolName, 'file', $sCompanyName, $sReg2, False]]

	_ArrayAdd($aKPRemoveProcessList, $aArr1)
	_ArrayAdd($aKPRemoveDesktopList, $aArr2)
	_ArrayAdd($aKPRemoveDownloadList, $aArr2)


EndFunc   ;==>LoadSystemLookup

LoadSystemLookup()
