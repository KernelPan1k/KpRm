

Func LoadCleanDNS()
	Local Const $sToolName = "Clean_DNS"

	Dim $aKPRemoveProcessList
	Dim $aKPRemoveDesktopList
	Dim $aKPRemoveDownloadList
	Dim $aKPRemoveSoftwareKeyList

	Local Const $sCompanyName = "(?i)^SosVirus"
	Local Const $sReg1 = "(?i)^clean(-|_)dns.*\.exe$"
	Local Const $sReg2 = "(?i)^clean(-|_)dns.*\.(exe|txt)$"
	Local Const $sReg3 = "(?i)^Clean_Dns$"

	Local Const $aArr1[1][3] = [[$sToolName, $sReg1, False]]
	Local Const $aArr2[1][5] = [[$sToolName, 'file', $sCompanyName, $sReg2, False]]
	Local Const $aArr3[1][2] = [[$sToolName, $sReg3]]

	_ArrayAdd($aKPRemoveProcessList, $aArr1)
	_ArrayAdd($aKPRemoveDesktopList, $aArr2)
	_ArrayAdd($aKPRemoveDownloadList, $aArr2)
	_ArrayAdd($aKPRemoveSoftwareKeyList, $aArr3)

EndFunc   ;==>LoadCleanDNS

LoadCleanDNS()
