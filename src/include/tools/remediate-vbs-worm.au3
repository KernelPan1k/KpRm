

Func LoadRemediateVbsWorm()
	Local Const $sToolExistCpt = "Remediate VBS Worm"
	Dim $aKPRemoveProcessList
	Dim $aKPRemoveDesktopList
	Dim $aKPRemoveDownloadList
	Dim $aKPRemoveHomeDriveList
	Dim $aKPRemoveDesktopCommonList
	Dim $aKPRemoveSoftwareKeyList

	Local Const $sDescriptionPattern = "(?i).*VBS autorun worms.*"
	Local Const $companyPattern = Null
	Local Const $sReg1 = "(?i)^remediate.?vbs.?worm.*\.exe$"
	Local Const $sReg2 = "(?i)^Rem-VBS.*\.log$"
	Local Const $sReg3 = "(?i)^Rem-VBS"
	Local Const $sReg4 = "(?i)^Rem-VBSworm.*\.exe$"


	Local Const $aArr1[1][3] = [[$sToolExistCpt, $sReg1, False]]
	Local Const $aArr2[1][5] = [[$sToolExistCpt, 'file', $companyPattern, $sReg1, False]]
	Local Const $aArr3[1][5] = [[$sToolExistCpt, 'file', $companyPattern, $sReg2, False]]
	Local Const $aArr4[1][5] = [[$sToolExistCpt, 'folder', $sDescriptionPattern, $sReg3, True]]
	Local Const $aArr5[1][2] = [[$sToolExistCpt, $sReg4]]
	Local Const $aArr6[1][5] = [[$sToolExistCpt, 'file', $companyPattern, $sReg4, False]]



	_ArrayAdd($aKPRemoveProcessList, $aArr1)
	_ArrayAdd($aKPRemoveProcessList, $aArr5)
	_ArrayAdd($aKPRemoveDesktopList, $aArr2)
	_ArrayAdd($aKPRemoveDesktopList, $aArr6)
	_ArrayAdd($aKPRemoveDownloadList, $aArr2)
	_ArrayAdd($aKPRemoveDownloadList, $aArr6)
	_ArrayAdd($aKPRemoveHomeDriveList, $aArr3)
	_ArrayAdd($aKPRemoveHomeDriveList, $aArr4)

EndFunc   ;==>LoadRemediateVbsWorm

LoadRemediateVbsWorm()
