
Func LoadScanRapide()
	Local Const $sToolExistCpt = "ScanRapide"

	Dim $aKPRemoveHomeDriveList
	Dim $aKPRemoveDesktopList
	Dim $aKPRemoveDownloadList

	Local Const $sDescriptionPattern = Null
	Local Const $sReg1 = "(?i)^ScanRapide.*\.exe$"
	Local Const $sReg2 = "(?i)^ScanRapide\[R[0-9]+\]\.txt$"

	Local Const $aArr1[1][5] = [[$sToolExistCpt, 'file', $sDescriptionPattern, $sReg1, False]]
	Local Const $aArr2[1][5] = [[$sToolExistCpt, 'file', Null, $sReg2, False]]

	_ArrayAdd($aKPRemoveDesktopList, $aArr1)
	_ArrayAdd($aKPRemoveDownloadList, $aArr1)
	_ArrayAdd($aKPRemoveHomeDriveList, $aArr2)
EndFunc

LoadScanRapide()
