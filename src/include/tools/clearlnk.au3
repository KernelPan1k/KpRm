

Func LoadClearLnk()

	Local Const $sCompanyName = "(?i)^Stanislav Polshyn"
	Local Const $sToolName = "ClearLNK"

	Dim $aKPRemoveProcessList
	Dim $aKPRemoveDesktopList
	Dim $aKPRemoveDownloadList

	Local Const $sReg1 = "(?i)^clearlnk.*\.exe$"
	Local Const $sReg2 = "(?i)^clearlnk.*\.(log|exe)$"

	Local Const $aArr1[1][3] = [[$sToolName, $sReg1, False]]
	Local Const $aArr2[1][5] = [[$sToolName, 'file', Null, $sReg2, False]]

	_ArrayAdd($aKPRemoveProcessList, $aArr1)
	_ArrayAdd($aKPRemoveDesktopList, $aArr2)
	_ArrayAdd($aKPRemoveDownloadList, $aArr2)
EndFunc   ;==>LoadClearLnk

LoadClearLnk()

