
Func LoadAHK_NavScan()
	Dim $aKPRemoveProcessList
	Dim $aKPRemoveDesktopList
	Dim $aKPRemoveDownloadList

	Local Const $sToolExistCpt = "AHK_NavScan"

	Local Const $sReg1 = "(?i)^AHK_NavScan.*\.exe"
	Local Const $sReg2 = "(?i)^AHK_NavScan.*\.(exe|txt)"

	Local Const $aArr1[1][3] = [[$sToolExistCpt, $sReg1, False]]
	Local Const $aArr2[1][5] = [[$sToolExistCpt, 'file', Null, $sReg2, False]]

	_ArrayAdd($aKPRemoveProcessList, $aArr1)
	_ArrayAdd($aKPRemoveDesktopList, $aArr2)
	_ArrayAdd($aKPRemoveDownloadList, $aArr2)
EndFunc   ;==>LoadAHK_NavScan

LoadAHK_NavScan()
