
Func LoadRstHosts()
	Local Const $sToolName = "RstHosts"
	Dim $aKPRemoveProcessList
	Dim $aKPRemoveDesktopList
	Dim $aKPRemoveDownloadList
	Dim $aKPRemoveHomeDriveList

	Local Const $sCompanyName = Null
	Local Const $sReg1 = "(?i)^rsthosts.*\.exe$"
	Local Const $sReg2 = "(?i)^RstHosts.*\.txt$"

	Local Const $aArr1[1][3] = [[$sToolName, $sReg1, False]]
	Local Const $aArr2[1][5] = [[$sToolName, 'file', $sCompanyName, $sReg1, Null]]
	Local Const $aArr3[1][5] = [[$sToolName, 'file', $sCompanyName, $sReg2, Null]]

	_ArrayAdd($aKPRemoveProcessList, $aArr1)
	_ArrayAdd($aKPRemoveDesktopList, $aArr2)
	_ArrayAdd($aKPRemoveDownloadList, $aArr2)
	_ArrayAdd($aKPRemoveHomeDriveList, $aArr3)

EndFunc   ;==>LoadRstHosts

LoadRstHosts()
