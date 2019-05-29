
Func LoadMiniRegTool()
	Local Const $sToolName = "MiniregTool"
	Dim $aKPRemoveProcessList
	Dim $aKPRemoveDesktopList
	Dim $aKPRemoveDownloadList
	Dim $aKPRemoveHomeDriveList

	Local Const $sCompanyName = Null
	Local Const $sReg1 = "(?i)^MiniRegTool.*\.exe$"
	Local Const $sReg2 = "(?i)^MiniRegTool.*\.(exe|zip)$"
	Local Const $sReg3 = "(?i)^Result\.txt$"
	Local Const $sReg4 = "(?i)^MiniRegTool"

	Local Const $aArr1[1][3] = [[$sToolName, $sReg1, False]]
	Local Const $aArr2[1][5] = [[$sToolName, 'file', $sCompanyName, $sReg2, False]]
	Local Const $aArr3[1][5] = [[$sToolName, 'file', $sCompanyName, $sReg3, False]]
	Local Const $aArr4[1][5] = [[$sToolName, 'folder', $sCompanyName, $sReg4, False]]

	_ArrayAdd($aKPRemoveProcessList, $aArr1)
	_ArrayAdd($aKPRemoveDesktopList, $aArr2)
	_ArrayAdd($aKPRemoveDesktopList, $aArr3)
	_ArrayAdd($aKPRemoveDesktopList, $aArr4)
	_ArrayAdd($aKPRemoveDownloadList, $aArr2)
	_ArrayAdd($aKPRemoveDownloadList, $aArr3)
	_ArrayAdd($aKPRemoveDownloadList, $aArr4)

EndFunc   ;==>LoadMiniRegTool

LoadMiniRegTool()
