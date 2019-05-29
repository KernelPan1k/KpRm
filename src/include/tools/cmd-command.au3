
Func LoadCMDCommand()
	Local Const $sToolName = "CMD_Command"
	Dim $aKPRemoveProcessList
	Dim $aKPRemoveDesktopList
	Dim $aKPRemoveDownloadList

	Local Const $sCompanyName = "(?i)^g3n-h@ckm@n$"
	Local Const $sReg1 = "(?i)^cmd-command.*\.exe$"

	Local Const $aArr1[1][3] = [[$sToolName, $sReg1, False]]
	Local Const $aArr2[1][5] = [[$sToolName, 'file', $sCompanyName, $sReg1, False]]

	_ArrayAdd($aKPRemoveProcessList, $aArr1)
	_ArrayAdd($aKPRemoveDesktopList, $aArr2)
	_ArrayAdd($aKPRemoveDownloadList, $aArr2)

EndFunc   ;==>LoadCMDCommand

LoadCMDCommand()
