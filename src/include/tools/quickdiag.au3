
Func LoadQuickDiag()

	Local Const $sToolName = "QuickDiag"
	Dim $aKPRemoveProcessList
	Dim $aKPRemoveDesktopList
	Dim $aKPRemoveDownloadList
	Dim $aKPRemoveHomeDriveList

	Local Const $sCompanyName = "(?i)^SosVirus"
	Local Const $sReg1 = "(?i)^QuickDiag.*\.exe$"
	Local Const $sReg2 = "(?i)^QuickDiag.*\.(exe|txt)$"
	Local Const $sReg3 = "(?i)^QuickScript.*\.txt$"
	Local Const $sReg4 = "(?i)^QuickDiag.*\.txt$"
	Local Const $sReg5 = "(?i)^QuickDiag"

	Local Const $aArr1[1][3] = [[$sToolName, $sReg1, False]]
	Local Const $aArr2[1][5] = [[$sToolName, 'file', $sCompanyName, $sReg2, True]]
	Local Const $aArr3[1][5] = [[$sToolName, 'file', Null, $sReg3, True]]
	Local Const $aArr4[1][5] = [[$sToolName, 'file', Null, $sReg4, True]]
	Local Const $aArr5[1][5] = [[$sToolName, 'folder', Null, $sReg5, True]]

	_ArrayAdd($aKPRemoveProcessList, $aArr1)
	_ArrayAdd($aKPRemoveDesktopList, $aArr2)
	_ArrayAdd($aKPRemoveDownloadList, $aArr2)
	_ArrayAdd($aKPRemoveDesktopList, $aArr3)
	_ArrayAdd($aKPRemoveDownloadList, $aArr3)
	_ArrayAdd($aKPRemoveHomeDriveList, $aArr4)
	_ArrayAdd($aKPRemoveHomeDriveList, $aArr5)

EndFunc   ;==>LoadQuickDiag

LoadQuickDiag()
