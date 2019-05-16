
Func LoadZHPLite()
	Local Const $sDescriptionPattern = Null
	Local Const $sZhpFixExistCpt = "ZHPLite"

	Dim $aKPRemoveProcessList
	Dim $aKPRemoveDesktopList
	Dim $aKPRemoveDownloadList

	Local Const $sReg1 = "(?i)^ZHPLite.*\.exe$"
	Local Const $sReg2 = "(?i)^ZHPLite.*\.(exe|txt|lnk)$"

	Local Const $aArr1[1][3] = [[$sZhpFixExistCpt, $sReg1, False]]
	Local Const $aArr2[1][5] = [[$sZhpFixExistCpt, 'file', $sDescriptionPattern, $sReg2, False]]

	_ArrayAdd($aKPRemoveProcessList, $aArr1)
	_ArrayAdd($aKPRemoveDesktopList, $aArr2)
	_ArrayAdd($aKPRemoveDownloadList, $aArr2)
EndFunc   ;==>LoadZHPLite

LoadZHPLite()
