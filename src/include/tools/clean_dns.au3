

Func LoadCleanDNS()
	Local Const $sToolExistCpt = "Clean_DNS"

	Dim $aKPRemoveProcessList
	Dim $aKPRemoveDesktopList
	Dim $aKPRemoveDownloadList

	Local Const $sDescriptionPattern = "(?i)^SosVirus"
	Local Const $sReg1 = "(?i)^clean(-|_)dns.*\.exe$"
	Local Const $sReg2 = "(?i)^clean(-|_)dns.*\.(exe|txt)$"

	Local Const $aArr1[1][3] = [[$sToolExistCpt, $sReg1, False]]
	Local Const $aArr2[1][5] = [[$sToolExistCpt, 'file', $sDescriptionPattern, $sReg2, False]]

	_ArrayAdd($aKPRemoveProcessList, $aArr1)
	_ArrayAdd($aKPRemoveDesktopList, $aArr2)
	_ArrayAdd($aKPRemoveDownloadList, $aArr2)

EndFunc   ;==>LoadCleanDNS

LoadCleanDNS()
