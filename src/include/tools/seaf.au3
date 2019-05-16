

Func LoadSeaf()
	Local Const $sToolExistCpt = "SEAF"
	Dim $aKPRemoveProcessList
	Dim $aKPRemoveDesktopList
	Dim $aKPRemoveDownloadList
	Dim $aKPUninstallNormalyList
	Dim $aKPRemoveRegistryKeysList
	Dim $aKPRemoveHomeDriveList
	Dim $aKPRemoveProgramFilesList

	Local Const $sDescriptionPattern = "(?i)^C_XX$"
	Local Const $folderPattern = "(?i)^SEAF$"
	Local Const $sReg1 = "(?i)^seaf.*\.exe$"
	Local Const $sReg2 = "(?i)^Un-SEAF\.exe$"
	Local Const $sReg3 = "(?i)^SeafLog.*\.txt$"

	Local $s64Bit = ""
	If @OSArch = "X64" Then $s64Bit = "64"

	Local Const $aArr1[1][3] = [[$sToolExistCpt, $sReg1, False]]
	Local Const $aArr2[1][5] = [[$sToolExistCpt, 'file', $sDescriptionPattern, $sReg1, False]]
	Local Const $aArr3[1][3] = [[$sToolExistCpt, $folderPattern, $sReg2]]
	Local Const $aArr4[1][3] = [[$sToolExistCpt, "HKLM" & $s64Bit & "\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\SEAF", False]]
	Local Const $aArr5[1][5] = [[$sToolExistCpt, 'file', Null, $sReg3, False]]
	Local Const $aArr6[1][5] = [[$sToolExistCpt, 'folder', Null, $folderPattern, True]]

	_ArrayAdd($aKPRemoveProcessList, $aArr1)
	_ArrayAdd($aKPRemoveDesktopList, $aArr2)
	_ArrayAdd($aKPRemoveDownloadList, $aArr2)
	_ArrayAdd($aKPUninstallNormalyList, $aArr3)
	_ArrayAdd($aKPRemoveRegistryKeysList, $aArr4)
	_ArrayAdd($aKPRemoveHomeDriveList, $aArr5)
	_ArrayAdd($aKPRemoveProgramFilesList, $aArr6)

EndFunc   ;==>LoadSeaf

LoadSeaf()
