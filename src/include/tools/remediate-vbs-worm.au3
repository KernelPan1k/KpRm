

Func LoadRemediateVbsWorm()
	Local Const $sToolName = "Remediate VBS Worm"
	Dim $aKPRemoveProcessList
	Dim $aKPRemoveDesktopList
	Dim $aKPRemoveDownloadList
	Dim $aKPRemoveHomeDriveList
	Dim $aKPRemoveDesktopCommonList
	Dim $aKPRemoveSoftwareKeyList

	Local Const $sToolReg = "(?i).*VBS autorun worms.*"
	Local Const $sCompanyName = Null
	Local Const $sReg1 = "(?i)^remediate.?vbs.?worm.*\.exe$"
	Local Const $sReg2 = "(?i)^Rem-VBS.*\.log$"
	Local Const $sReg3 = "(?i)^Rem-VBS"
	Local Const $sReg4 = "(?i)^Rem-VBSworm.*\.exe$"


	Local Const $aArr1[1][3] = [[$sToolName, $sReg1, False]]
	Local Const $aArr2[1][5] = [[$sToolName, 'file', $sCompanyName, $sReg1, False]]
	Local Const $aArr3[1][5] = [[$sToolName, 'file', $sCompanyName, $sReg2, False]]
	Local Const $aArr4[1][5] = [[$sToolName, 'folder', $sToolReg, $sReg3, True]]
	Local Const $aArr5[1][2] = [[$sToolName, $sReg4]]
	Local Const $aArr6[1][5] = [[$sToolName, 'file', $sCompanyName, $sReg4, False]]



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
