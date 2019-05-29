

Func LoadCombofix()
	Local Const $sToolName = "Combofix"
	Dim $aKPRemoveDesktopList
	Dim $aKPRemoveDownloadList
	Dim $aKPRemoveHomeDriveList
	Dim $aKPRemoveWindowsFolderList
	Dim $aKPRemoveSoftwareKeyList
	Dim $aKPRemoveProcessList
	Dim $aKPRemoveRegistryKeysList

	Local Const $sCompanyName = "(?i)^Swearware"
	Local Const $sReg1 = "(?i)^Combofix.*\.exe$"
	Local Const $sReg2 = "(?i)^CFScript\.txt$"
	Local Const $sReg3 = "(?i)^Qoobox$"
	Local Const $sReg4 = "(?i)^Combofix.*\.txt$"
	Local Const $sReg5 = "(?i)^(grep|PEV|NIRCMD|MBR|SED|SWREG|SWSC|SWXCACLS|Zip)\.exe$"
	Local Const $sReg6 = "(?i)^Swearware$"

	Local $s64Bit = GetSuffixKey()

	Local Const $aArr1[1][5] = [[$sToolName, 'file', $sCompanyName, $sReg1, False]]
	Local Const $aArr2[1][5] = [[$sToolName, 'file', Null, $sReg2, False]]
	Local Const $aArr3[1][5] = [[$sToolName, 'folder', Null, $sReg3, True]]
	Local Const $aArr4[1][5] = [[$sToolName, 'file', Null, $sReg4, False]]
	Local Const $aArr5[1][5] = [[$sToolName, 'file', Null, $sReg5, True]]
	Local Const $aArr6[1][2] = [[$sToolName, $sReg6]]
	Local Const $aArr7[1][3] = [[$sToolName, $sReg1, True]]
	Local Const $aArr8[1][3] = [[$sToolName, "HKLM" & $s64Bit & "\SOFTWARE\Microsoft\Windows\CurrentVersion\App Paths\combofix.exe", False]]

	_ArrayAdd($aKPRemoveDesktopList, $aArr1)
	_ArrayAdd($aKPRemoveDesktopList, $aArr2)
	_ArrayAdd($aKPRemoveDownloadList, $aArr1)
	_ArrayAdd($aKPRemoveDownloadList, $aArr2)
	_ArrayAdd($aKPRemoveHomeDriveList, $aArr3)
	_ArrayAdd($aKPRemoveHomeDriveList, $aArr4)
	_ArrayAdd($aKPRemoveWindowsFolderList, $aArr5)
	_ArrayAdd($aKPRemoveSoftwareKeyList, $aArr6)
	_ArrayAdd($aKPRemoveProcessList, $aArr7)
	_ArrayAdd($aKPRemoveRegistryKeysList, $aArr8)

EndFunc   ;==>LoadCombofix

LoadCombofix()
