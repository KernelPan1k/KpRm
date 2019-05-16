
Func LoadUnHide()
	Dim $aKPRemoveProcessList
	Dim $aKPRemoveDesktopList
	Dim $aKPRemoveDownloadList

	Local Const $sToolExistCpt = "UnHide"
	Local Const $sDescriptionPattern = "(?i)^Bleeping Computer"

	Local Const $sReg1 = "(?i)^unhide.*\.exe$"
	Local Const $sReg2 = "(?i)^unhide.*\.(exe|txt)$"

	Local Const $aArr1[1][3] = [[$sToolExistCpt, $sReg1, False]]
	Local Const $aArr2[1][5] = [[$sToolExistCpt, 'file', $sDescriptionPattern, $sReg2, False]]

	_ArrayAdd($aKPRemoveProcessList, $aArr1)
	_ArrayAdd($aKPRemoveDesktopList, $aArr2)
	_ArrayAdd($aKPRemoveDownloadList, $aArr2)

EndFunc   ;==>LoadUnHide

LoadUnHide()
