
Func LoadEsetOnlineScanner()
	Dim $aKPRemoveProcessList
	Dim $aKPRemoveDesktopList
	Dim $aKPRemoveDownloadList
	Dim $aKPRemoveAppDataLocalList
	Dim $aKPRemoveRegistryKeysList

	Local Const $sToolName = "ESET Online Scanner"
	Local Const $sCompanyName = "(?i)^ESET"

	Local Const $sReg1 = "(?i)^esetonlinescanner.*\.exe$"
	Local Const $sReg2 = "(?i)^log.*\.txt$"

	Local $s64Bit = GetSuffixKey()

	Local Const $aArr1[1][3] = [[$sToolName, $sReg1, False]]
	Local Const $aArr2[1][5] = [[$sToolName, 'file', $sCompanyName, $sReg1, False]]
	Local Const $aArr3[1][5] = [[$sToolName, 'file', Null, $sReg2, False]]
	Local Const $aArr4[1][5] = [[$sToolName, 'folder', Null, "(?i)^ESET$", True]]
	Local Const $aArr5[1][3] = [[$sToolName, "HKLM" & $s64Bit & "\SOFTWARE\ESET\ESET Online Scanner", False]]

	_ArrayAdd($aKPRemoveProcessList, $aArr1)
	_ArrayAdd($aKPRemoveDesktopList, $aArr2)
	_ArrayAdd($aKPRemoveDesktopList, $aArr3)
	_ArrayAdd($aKPRemoveDownloadList, $aArr2)
	_ArrayAdd($aKPRemoveDownloadList, $aArr3)
	_ArrayAdd($aKPRemoveAppDataLocalList, $aArr4)
	_ArrayAdd($aKPRemoveRegistryKeysList, $aArr5)

EndFunc   ;==>LoadEsetOnlineScanner

LoadEsetOnlineScanner()
