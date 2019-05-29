
Func LoadZHPDiag()
	Local Const $sCompanyName = Null
	Local Const $sToolName = "ZHPDiag"

	Dim $aKPRemoveProcessList
	Dim $aKPRemoveDesktopList
	Dim $aKPRemoveDesktopCommonList
	Dim $aKPRemoveDownloadList
	Dim $aKPRemoveHomeDriveList

	Local Const $sReg1 = "(?i)^ZHPDiag.*\.exe$"
	Local Const $sReg2 = "(?i)^ZHPDiag.*\.(exe|txt|lnk)$"
	Local Const $sReg3 = "(?i)^PhysicalDisk[0-9]_MBR\.bin$"

	Local Const $aArr1[1][3] = [[$sToolName, $sReg1, False]]
	Local Const $aArr2[1][5] = [[$sToolName, 'file', $sCompanyName, $sReg2, False]]
	Local Const $aArr3[1][5] = [[$sToolName, 'file', Null, $sReg3, True]]

	_ArrayAdd($aKPRemoveProcessList, $aArr1)
	_ArrayAdd($aKPRemoveDesktopList, $aArr2)
	_ArrayAdd($aKPRemoveDownloadList, $aArr2)
	_ArrayAdd($aKPRemoveDesktopCommonList, $aArr2)
	_ArrayAdd($aKPRemoveHomeDriveList, $aArr3)

EndFunc   ;==>LoadZHPDiag

LoadZHPDiag()
