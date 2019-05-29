

Func LoadSymantecKovterRemovalTool()

	Local Const $sCompanyName = "(?i)^Symantec"
	Local Const $sToolName = "Symantec Kovter Removal Tool"

	Dim $aKPRemoveProcessList
	Dim $aKPRemoveDesktopList
	Dim $aKPRemoveDownloadList

	Local Const $sReg1 = "(?i)^FixTool.*\.exe$"
	Local Const $sReg2 = "(?i)^FixTool.*\.(log|exe)$"

	Local Const $aArr1[1][3] = [[$sToolName, $sReg1, False]]
	Local Const $aArr2[1][5] = [[$sToolName, 'file', $sCompanyName, $sReg2, False]]

	_ArrayAdd($aKPRemoveProcessList, $aArr1)
	_ArrayAdd($aKPRemoveDesktopList, $aArr2)
	_ArrayAdd($aKPRemoveDownloadList, $aArr2)
EndFunc   ;==>LoadSymantecKovterRemovalTool

LoadSymantecKovterRemovalTool()

