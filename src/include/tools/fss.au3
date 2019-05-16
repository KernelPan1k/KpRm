
Func LoadFSS()
	Local Const $sToolExistCpt = "FSS"
	Dim $aKPRemoveProcessList
	Dim $aKPRemoveDesktopList
	Dim $aKPRemoveDownloadList

	Local Const $sDescriptionPattern = "(?i)^Farbar"
	Local Const $sReg1 = "(?i)^FSS.*\.(exe|txt|lnk)$"
	Local Const $sReg2 = "(?i)^FSS.*\.exe$"

	Local Const $aArr1[1][3] = [[$sToolExistCpt, $sReg2, False]]
	Local Const $aArr2[1][5] = [[$sToolExistCpt, 'file', $sDescriptionPattern, $sReg1, False]]

	_ArrayAdd($aKPRemoveProcessList, $aArr1)
	_ArrayAdd($aKPRemoveDesktopList, $aArr2)
	_ArrayAdd($aKPRemoveDownloadList, $aArr2)

EndFunc   ;==>LoadFSS

LoadFSS()
