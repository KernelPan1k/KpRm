

Func LoadJRT()
	Dim $aKPRemoveProcessList
	Dim $aKPRemoveDesktopList
	Dim $aKPRemoveDownloadList

	Local Const $sToolName = "Junkware Removal Tool"
	Local Const $sCompanyName = "(?i)^Malwarebytes"

	Local Const $sReg1 = "(?i)^JRT.*\.exe"
	Local Const $sReg2 = "(?i)^JRT.*\.(exe|txt)"

	Local Const $aArr1[1][3] = [[$sToolName, $sReg1, False]]
	Local Const $aArr2[1][5] = [[$sToolName, 'file', $sCompanyName, $sReg2, False]]

	_ArrayAdd($aKPRemoveProcessList, $aArr1)
	_ArrayAdd($aKPRemoveDesktopList, $aArr2)
	_ArrayAdd($aKPRemoveDownloadList, $aArr2)
EndFunc   ;==>LoadJRT

LoadJRT()
