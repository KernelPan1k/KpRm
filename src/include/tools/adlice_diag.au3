
Func LoadAdliceDiag()
	Local Const $sToolName = "AdliceDiag"
	Dim $aKPRemoveProcessList
	Dim $aKPRemoveSearchRegistryKeyStringsList
	Dim $aKPRemoveProgramFilesList
	Dim $aKPRemoveAppDataCommonList
	Dim $aKPRemoveDesktopList
	Dim $aKPRemoveDownloadList
	Dim $aKPRemoveDesktopCommonList
	Dim $aKPRemoveAppDataCommonStartMenuFolderList

	Local $s64Bit = GetSuffixKey()

	Local Const $sProcessDescription = "(?i)^Adlice Diag"
	Local Const $sReg1 = "(?i)^Diag version"
	Local Const $sReg2 = "(?i)^Diag$"
	Local Const $sReg3 = "(?i)^ADiag$"
	Local Const $sReg4 = "(?i)^Diag_portable(32|64)\.exe$"
	Local Const $sReg5 = "(?i)^Diag\.lnk$"
	Local Const $sReg6 = "(?i)^Diag_setup\.exe$"
	Local Const $sReg7 = "(?i)^Diag(32|64)?\.exe$"

	Local Const $aArr1[1][3] = [[$sToolName, $sProcessDescription, False]]
	Local Const $aArr2[1][4] = [[$sToolName, "HKLM" & $s64Bit & "\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall", $sReg1, "DisplayName"]]
	Local Const $aArr3[1][5] = [[$sToolName, 'folder', Null, $sReg2, True]]
	Local Const $aArr4[1][5] = [[$sToolName, 'folder', Null, $sReg3, True]]
	Local Const $aArr5[1][5] = [[$sToolName, 'file', Null, $sReg4, False]]
	Local Const $aArr6[1][5] = [[$sToolName, 'file', Null, $sReg5, False]]
	Local Const $aArr7[1][5] = [[$sToolName, 'file', Null, $sReg6, False]]
	Local Const $aArr8[1][2] = [[$sToolName, $sReg7]]

	_ArrayAdd($aKPRemoveProcessList, $aArr1)
	_ArrayAdd($aKPRemoveProcessList, $aArr8)
	_ArrayAdd($aKPRemoveSearchRegistryKeyStringsList, $aArr2)
	_ArrayAdd($aKPRemoveProgramFilesList, $aArr3)
	_ArrayAdd($aKPRemoveAppDataCommonList, $aArr4)
	_ArrayAdd($aKPRemoveDesktopList, $aArr5)
	_ArrayAdd($aKPRemoveDesktopList, $aArr6)
	_ArrayAdd($aKPRemoveDesktopList, $aArr7)
	_ArrayAdd($aKPRemoveDownloadList, $aArr5)
	_ArrayAdd($aKPRemoveDownloadList, $aArr7)
	_ArrayAdd($aKPRemoveDesktopCommonList, $aArr6)
	_ArrayAdd($aKPRemoveAppDataCommonStartMenuFolderList, $aArr3)


EndFunc   ;==>LoadAdliceDiag

LoadAdliceDiag()

