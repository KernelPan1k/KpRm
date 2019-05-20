

Func LoadGhostCryptDecrypter()
	Local Const $sToolExistCpt = "GhostCryptDecrypter"

	Dim $aKPRemoveProcessList
	Dim $aKPRemoveDesktopList
	Dim $aKPRemoveDownloadList
	Dim $aKPRemoveSoftwareKeyList

	Local Const $sDescriptionPattern = "(?i)^SosVirus"
	Local Const $sReg1 = "(?i)^clean(-|_)dns.*\.exe$"
	Local Const $sReg2 = "(?i)^clean(-|_)dns.*\.(exe|txt)$"
	Local Const $sReg3 = "(?i)^Clean_Dns$"

	Local Const $aArr1[1][3] = [[$sToolExistCpt, $sReg1, False]]
	Local Const $aArr2[1][5] = [[$sToolExistCpt, 'file', $sDescriptionPattern, $sReg2, False]]
	Local Const $aArr3[1][2] = [[$sToolExistCpt, $sReg3]]

	_ArrayAdd($aKPRemoveProcessList, $aArr1)
	_ArrayAdd($aKPRemoveDesktopList, $aArr2)
	_ArrayAdd($aKPRemoveDownloadList, $aArr2)
	_ArrayAdd($aKPRemoveSoftwareKeyList, $aArr3)

EndFunc   ;==>LoadCleanDNS

LoadGhostCryptDecrypter()
