

Func LoadCombofix()
	Local Const $sToolExistCpt = "Combofix"
	Dim $aKPRemoveDesktopList
	Dim $aKPRemoveDownloadList
	Dim $aKPRemoveHomeDriveList
	Dim $aKPRemoveWindowsFolderList
	Dim $aKPRemoveSoftwareKeyList
	Dim $aKPRemoveProcessList
	Dim $aKPRemoveRegistryKeysList

	Local Const $sDescriptionPattern = "(?i)^Swearware"
	Local Const $sReg1 = "(?i)^Combofix.*\.exe$"
	Local Const $sReg2 = "(?i)^CFScript\.txt$"
	Local Const $sReg3 = "(?i)^Qoobox$"
	Local Const $sReg4 = "(?i)^Combofix.*\.txt$"
	Local Const $sReg5 = "(?i)^(grep|PEV|NIRCMD|MBR|SED|SWREG|SWSC|SWXCACLS|Zip)\.exe$"
	Local Const $sReg6 = "(?i)^Swearware$"

	Local $s64Bit = ""
	If @OSArch = "X64" Then $s64Bit = "64"

	Local Const $aArr1[1][5] = [[$sToolExistCpt, 'file', $sDescriptionPattern, $sReg1, False]]
	Local Const $aArr2[1][5] = [[$sToolExistCpt, 'file', Null, $sReg2, False]]
	Local Const $aArr3[1][5] = [[$sToolExistCpt, 'folder', Null, $sReg3, True]]
	Local Const $aArr4[1][5] = [[$sToolExistCpt, 'file', Null, $sReg4, False]]
	Local Const $aArr5[1][5] = [[$sToolExistCpt, 'file', Null, $sReg5, True]]
	Local Const $aArr6[1][2] = [[$sToolExistCpt, $sReg6]]
	Local Const $aArr7[1][3] = [[$sToolExistCpt, $sReg1, True]]
	Local Const $aArr8[1][3] = [[$sToolExistCpt, "HKLM" & $s64Bit & "\SOFTWARE\Microsoft\Windows\CurrentVersion\App Paths\combofix.exe", False]]

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
