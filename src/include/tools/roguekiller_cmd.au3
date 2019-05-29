
Func LoadRogueKillerCMD()
	Local Const $sToolName = "RogueKiller"

	Dim $aKPRemoveProcessList
	Dim $aKPRemoveDesktopList
	Dim $aKPRemoveDownloadList

	Local Const $sReg1 = "(?i)^RogueKillerCMD.*\.exe$"

	Local Const $aArr1[1][3] = [[$sToolName, $sReg1, False]]
	Local Const $aArr2[1][5] = [[$sToolName, 'file', Null, $sReg1, False]]

	_ArrayAdd($aKPRemoveProcessList, $aArr1)
	_ArrayAdd($aKPRemoveDesktopList, $aArr2)
	_ArrayAdd($aKPRemoveDownloadList, $aArr2)

EndFunc   ;==>LoadRogueKillerCMD

LoadRogueKillerCMD()
