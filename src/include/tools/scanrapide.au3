
Func LoadScanRapide()
	Local Const $sToolName = "ScanRapide"

	Dim $aKPRemoveHomeDriveList
	Dim $aKPRemoveDesktopList
	Dim $aKPRemoveDownloadList

	Local Const $sCompanyName = Null
	Local Const $sReg1 = "(?i)^ScanRapide.*\.exe$"
	Local Const $sReg2 = "(?i)^ScanRapide\[R[0-9]+\]\.txt$"

	Local Const $aArr1[1][5] = [[$sToolName, 'file', $sCompanyName, $sReg1, False]]
	Local Const $aArr2[1][5] = [[$sToolName, 'file', Null, $sReg2, False]]

	_ArrayAdd($aKPRemoveDesktopList, $aArr1)
	_ArrayAdd($aKPRemoveDownloadList, $aArr1)
	_ArrayAdd($aKPRemoveHomeDriveList, $aArr2)
EndFunc

LoadScanRapide()
