
Func LoadOTL()
	Local Const $sToolExistCpt = "OTL"
	Dim $aKPRemoveProcessList
	Dim $aKPRemoveDesktopList
	Dim $aKPRemoveDownloadList
	Dim $aKPRemoveHomeDriveList
	Dim $aKPRemoveSoftwareKeyList

	Local Const $sDescriptionPattern = "(?i)^OldTimer"

	Local Const $sReg1 = "(?i)^OTL.*\.exe$"
	Local Const $sReg2 = "(?i)^OTL.*\.(exe|txt)$"
	Local Const $sReg3 = "(?i)^Extras\.txt$"
	Local Const $sReg4 = "(?i)^_OTL$"
	Local Const $sReg5 = "(?i)^OldTimer Tools$"

	Local Const $aArr1[1][3] = [[$sToolExistCpt, $sReg1, False]]
	Local Const $aArr2[1][5] = [[$sToolExistCpt, 'file', $sDescriptionPattern, $sReg2, False]]
	Local Const $aArr3[1][5] = [[$sToolExistCpt, 'file', Null, $sReg3, False]]
	Local Const $aArr4[1][5] = [[$sToolExistCpt, 'folder', Null, $sReg4, True]]
	Local Const $aArr5[1][2] = [[$sToolExistCpt, $sReg5]]

	_ArrayAdd($aKPRemoveProcessList, $aArr1)
	_ArrayAdd($aKPRemoveDesktopList, $aArr2)
	_ArrayAdd($aKPRemoveDesktopList, $aArr3)
	_ArrayAdd($aKPRemoveDownloadList, $aArr2)
	_ArrayAdd($aKPRemoveHomeDriveList, $aArr4)
	_ArrayAdd($aKPRemoveSoftwareKeyList, $aArr5)

EndFunc   ;==>LoadOTL

LoadOTL()
