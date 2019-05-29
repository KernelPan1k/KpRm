
Func LoadMBAR($retry = False)
	Local Const $sToolReg = "(?i)^Malwarebytes Anti-Rootkit$"
	Local Const $sCompanyName = "(?i)^Malwarebytes"
	Local Const $sToolName = "Malwarebytes Anti-Rootkit"

	Dim $aKPRemoveProcessList
	Dim $aKPRemoveDesktopList
	Dim $aKPRemoveDownloadList
	Dim $aKPRemoveSoftwareKeyList
	Dim $aKPCleanDirectoryContentList


	Local Const $sReg1 = "(?i)^mbar.*\.exe$"
	Local Const $sReg2 = "(?i)^mbar"

	Local Const $aArr1[1][3] = [[$sToolName, $sReg1, True]]
	Local Const $aArr2[1][2] = [[$sToolName, $sToolReg]]
	Local Const $aArr3[1][5] = [[$sToolName, 'file', $sCompanyName, $sReg1, False]]
	Local Const $aArr4[1][5] = [[$sToolName, 'folder', $sToolReg, $sReg2, False]]
	Local Const $aArr5[1][4] = [[$sToolName, @AppDataCommonDir & "\Malwarebytes\Malwarebytes' Anti-Malware\Quarantine", Null, True]]

	_ArrayAdd($aKPRemoveProcessList, $aArr1)
	_ArrayAdd($aKPRemoveDesktopList, $aArr3)
	_ArrayAdd($aKPRemoveDownloadList, $aArr3)
	_ArrayAdd($aKPRemoveDesktopList, $aArr4)
	_ArrayAdd($aKPRemoveDownloadList, $aArr4)
	_ArrayAdd($aKPRemoveSoftwareKeyList, $aArr2)
	_ArrayAdd($aKPCleanDirectoryContentList, $aArr5)


EndFunc   ;==>LoadMBAR

LoadMBAR()
