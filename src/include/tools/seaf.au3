

Func LoadSeaf()
	Local Const $sToolName = "SEAF"
	Dim $aKPRemoveProcessList
	Dim $aKPRemoveDesktopList
	Dim $aKPRemoveDownloadList
	Dim $aKPUninstallNormallyList
	Dim $aKPRemoveRegistryKeysList
	Dim $aKPRemoveHomeDriveList
	Dim $aKPRemoveProgramFilesList

	Local Const $sCompanyName = "(?i)^C_XX$"
	Local Const $folderPattern = "(?i)^SEAF$"
	Local Const $sReg1 = "(?i)^seaf.*\.exe$"
	Local Const $sReg2 = "(?i)^Un-SEAF\.exe$"
	Local Const $sReg3 = "(?i)^SeafLog.*\.txt$"

	Local $s64Bit = GetSuffixKey()

	Local Const $aArr1[1][3] = [[$sToolName, $sReg1, False]]
	Local Const $aArr2[1][5] = [[$sToolName, 'file', $sCompanyName, $sReg1, False]]
	Local Const $aArr3[1][3] = [[$sToolName, $folderPattern, $sReg2]]
	Local Const $aArr4[1][3] = [[$sToolName, "HKLM" & $s64Bit & "\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\SEAF", False]]
	Local Const $aArr5[1][5] = [[$sToolName, 'file', Null, $sReg3, False]]
	Local Const $aArr6[1][5] = [[$sToolName, 'folder', Null, $folderPattern, True]]

	_ArrayAdd($aKPRemoveProcessList, $aArr1)
	_ArrayAdd($aKPRemoveDesktopList, $aArr2)
	_ArrayAdd($aKPRemoveDownloadList, $aArr2)
	_ArrayAdd($aKPUninstallNormallyList, $aArr3)
	_ArrayAdd($aKPRemoveRegistryKeysList, $aArr4)
	_ArrayAdd($aKPRemoveHomeDriveList, $aArr5)
	_ArrayAdd($aKPRemoveProgramFilesList, $aArr6)

EndFunc   ;==>LoadSeaf

LoadSeaf()
