
Func LoadEsetOnlineScanner()
	Dim $aKPRemoveProcessList
	Dim $aKPRemoveDesktopList
	Dim $aKPRemoveDownloadList
	Dim $aKPRemoveAppDataLocalList
	Dim $aKPRemoveRegistryKeysList

	Local Const $sToolExistCpt = "ESET Online Scanner"
	Local Const $sDescriptionPattern = "(?i)^ESET"

	Local Const $sReg1 = "(?i)^esetonlinescanner.*\.exe$"
	Local Const $sReg2 = "(?i)^log.*\.txt$"

	Local $s64Bit = ""
	If @OSArch = "X64" Then $s64Bit = "64"

	Local Const $aArr1[1][3] = [[$sToolExistCpt, $sReg1, False]]
	Local Const $aArr2[1][5] = [[$sToolExistCpt, 'file', $sDescriptionPattern, $sReg1, False]]
	Local Const $aArr3[1][5] = [[$sToolExistCpt, 'file', Null, $sReg2, False]]
	Local Const $aArr4[1][5] = [[$sToolExistCpt, 'folder', Null, "(?i)^ESET$", True]]
	Local Const $aArr5[1][3] = [[$sToolExistCpt, "HKLM" & $s64Bit & "\SOFTWARE\ESET\ESET Online Scanner", False]]

	_ArrayAdd($aKPRemoveProcessList, $aArr1)
	_ArrayAdd($aKPRemoveDesktopList, $aArr2)
	_ArrayAdd($aKPRemoveDesktopList, $aArr3)
	_ArrayAdd($aKPRemoveDownloadList, $aArr2)
	_ArrayAdd($aKPRemoveDownloadList, $aArr3)
	_ArrayAdd($aKPRemoveAppDataLocalList, $aArr4)
	_ArrayAdd($aKPRemoveRegistryKeysList, $aArr5)

EndFunc   ;==>LoadEsetOnlineScanner

LoadEsetOnlineScanner()
