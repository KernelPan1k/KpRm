

Func LoadGetSystemInfo()
	Local Const $sToolName = "GetSystemInfo"
	Dim $aKPRemoveProcessList
	Dim $aKPRemoveDesktopList
	Dim $aKPRemoveDownloadList

	Local Const $sCompanyName = "(?i)^.*Kaspersky"

	Local Const $sReg1 = "(?i)^GetSystemInfo.*\.exe$"
	Local Const $sReg2 = "(?i)^GetSystemInfo.*\.(exe|zip)$"
	Local Const $sReg3 = "(?i)^GetSystemInfo.*$"

	Local Const $aArr1[1][3] = [[$sToolName, $sReg1, False]]
	Local Const $aArr2[1][5] = [[$sToolName, 'file', $sCompanyName, $sReg2, False]]
	Local Const $aArr3[1][5] = [[$sToolName, 'folder', Null, $sReg3, False]]

	_ArrayAdd($aKPRemoveProcessList, $aArr1)
	_ArrayAdd($aKPRemoveDesktopList, $aArr2)
	_ArrayAdd($aKPRemoveDownloadList, $aArr2)
	_ArrayAdd($aKPRemoveDesktopList, $aArr3)
	_ArrayAdd($aKPRemoveDownloadList, $aArr3)

EndFunc   ;==>LoadGetSystemInfo

LoadGetSystemInfo()
