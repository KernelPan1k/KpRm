
Func LoadJavara()
	Dim $aKPRemoveProcessList
	Dim $aKPRemoveDesktopList
	Dim $aKPRemoveDownloadList
	Dim $aKPRemoveHomeDriveList

	Local Const $sToolName = "JavaRa"
	Local Const $sCompanyName = "(?i)^The RaProducts Team"

	Local Const $sReg1 = "(?i)^Javara"
	Local Const $sReg2 = "(?i)^Javara.*\.exe$"
	Local Const $sReg3 = "(?i)^Javara.*\.(zip|exe)$"
	Local Const $sReg4 = "(?i)^Javara.*\.log$"

	Local Const $aArr1[1][3] = [[$sToolName, $sReg2, False]]
	Local Const $aArr2[1][5] = [[$sToolName, 'file', $sCompanyName, $sReg3, False]]
	Local Const $aArr3[1][5] = [[$sToolName, 'file', Null, $sReg4, False]]
	Local Const $aArr4[1][5] = [[$sToolName, 'folder', Null, $sReg1, False]]

	_ArrayAdd($aKPRemoveProcessList, $aArr1)
	_ArrayAdd($aKPRemoveDesktopList, $aArr2)
	_ArrayAdd($aKPRemoveDesktopList, $aArr4)
	_ArrayAdd($aKPRemoveDownloadList, $aArr2)
	_ArrayAdd($aKPRemoveDownloadList, $aArr4)
	_ArrayAdd($aKPRemoveHomeDriveList, $aArr3)

EndFunc   ;==>LoadJavara

LoadJavara()
