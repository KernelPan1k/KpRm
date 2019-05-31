
Func LoadFixPurge()
	Local Const $sToolName = "FixPurge"
	Dim $aKPRemoveProcessList
	Dim $aKPRemoveDesktopList
	Dim $aKPRemoveDownloadList
	Dim $aKPRemoveHomeDriveList
	Dim $aKPRemoveDesktopCommonList
	Dim $aKPRemoveSearchRegistryKeyStringsList
	Dim $aKPRemoveAppDataCommonStartMenuFolderList

	Local Const $sToolReg = "(?i)^Fix\-Purge"
	Local Const $sCompanyName = "(?i)^Hacker Tool"
	Local Const $sReg1 = "(?i)^Fix\-Purge.*\.exe$"
	Local Const $sReg2 = "(?i)^Fix\-Purge.*\.(exe|lnk)$"
	Local Const $sReg3 = "(?i)^Fix\-Purge$"

	Local $s64Bit = GetSuffixKey()

	Local Const $aArr1[1][3] = [[$sToolName, $sReg1, False]]
	Local Const $aArr2[1][5] = [[$sToolName, 'file', $sCompanyName, $sReg2, False]]
	Local Const $aArr3[1][5] = [[$sToolName, 'folder', Null, $sReg3, False]]
	Local Const $aArr4[1][4] = [[$sToolName, "HKLM" & $s64Bit & "\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall", $sToolReg, "DisplayName"]]
	Local Const $aArr5[1][5] = [[$sToolName, 'folder', Null, $sReg3, True]]

	_ArrayAdd($aKPRemoveProcessList, $aArr1)
	_ArrayAdd($aKPRemoveDesktopList, $aArr2)
	_ArrayAdd($aKPRemoveDesktopCommonList, $aArr2)
	_ArrayAdd($aKPRemoveDownloadList, $aArr2)
	_ArrayAdd($aKPRemoveHomeDriveList, $aArr3)
	_ArrayAdd($aKPRemoveSearchRegistryKeyStringsList, $aArr4)
	_ArrayAdd($aKPRemoveAppDataCommonStartMenuFolderList, $aArr5)

EndFunc   ;==>LoadFixPurge

LoadFixPurge()
