

Func LoadJRT()
	Dim $aKPRemoveProcessList
	Dim $aKPRemoveDesktopList
	Dim $aKPRemoveDownloadList

	Local Const $sToolExistCpt = "Junkware Removal Tool"
	Local Const $sDescriptionPattern = "(?i)^Malwarebytes"

	Local Const $sReg1 = "(?i)^JRT.*\.exe"
	Local Const $sReg2 = "(?i)^JRT.*\.(exe|txt)"

	Local Const $aArr1[1][3] = [[$sToolExistCpt, $sReg1, False]]
	Local Const $aArr2[1][5] = [[$sToolExistCpt, 'file', $sDescriptionPattern, $sReg2, False]]

	_ArrayAdd($aKPRemoveProcessList, $aArr1)
	_ArrayAdd($aKPRemoveDesktopList, $aArr2)
	_ArrayAdd($aKPRemoveDownloadList, $aArr2)
EndFunc   ;==>LoadJRT

LoadJRT()
