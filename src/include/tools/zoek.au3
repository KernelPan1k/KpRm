

Func LoadZoek()

	Local Const $sToolName = "Zoek"
	Dim $aKPRemoveProcessList
	Dim $aKPRemoveDesktopList
	Dim $aKPRemoveDownloadList
	Dim $aKPRemoveHomeDriveList
	Dim $aKPRemoveDesktopCommonList
	Dim $aKPRemoveSoftwareKeyList

	Local Const $sCompanyName = Null
	Local Const $sReg1 = "(?i)^zoek.*\.exe$"
	Local Const $sReg2 = "(?i)^zoek.*\.log$"
	Local Const $sReg3 = "(?i)^zoek"
	Local Const $sReg4 = "(?i)^runcheck.*\.txt$"

	Local Const $aArr1[1][3] = [[$sToolName, $sReg1, False]]
	Local Const $aArr2[1][5] = [[$sToolName, 'file', $sCompanyName, $sReg1, False]]
	Local Const $aArr3[1][5] = [[$sToolName, 'file', $sCompanyName, $sReg2, False]]
	Local Const $aArr4[1][5] = [[$sToolName, 'folder', $sCompanyName, $sReg3, True]]
	Local Const $aArr5[1][5] = [[$sToolName, 'file', $sCompanyName, $sReg4, False]]

	_ArrayAdd($aKPRemoveProcessList, $aArr1)
	_ArrayAdd($aKPRemoveDesktopList, $aArr2)
	_ArrayAdd($aKPRemoveDownloadList, $aArr2)
	_ArrayAdd($aKPRemoveHomeDriveList, $aArr3)
	_ArrayAdd($aKPRemoveHomeDriveList, $aArr4)
	_ArrayAdd($aKPRemoveHomeDriveList, $aArr5)

EndFunc   ;==>LoadZoek

LoadZoek()
