
Func LoadAdwcleaner()
	Local Const $sToolName = "AdwCleaner"
	Local Const $sToolReg = "(?i)^AdwCleaner"
	Local Const $sCompanyName = "(?i)^Malwarebytes"
	Local Const $sReg1 = "(?i)^AdwCleaner.*\.exe$"

	Dim $aKPRemoveProcessList
	Dim $aKPRemoveDesktopList
	Dim $aKPRemoveDownloadList
	Dim $aKPRemoveHomeDriveList

	Local Const $aArr1[1][3] = [[$sToolName, $sReg1, False]]
	Local Const $aArr2[1][5] = [[$sToolName, 'file', $sCompanyName, $sReg1, False]]
	Local Const $aArr3[1][5] = [[$sToolName, 'folder', Null, $sToolReg, True]]

	_ArrayAdd($aKPRemoveProcessList, $aArr1)
	_ArrayAdd($aKPRemoveDesktopList, $aArr2)
	_ArrayAdd($aKPRemoveDownloadList, $aArr2)
	_ArrayAdd($aKPRemoveHomeDriveList, $aArr3)

EndFunc   ;==>LoadAdwcleaner

LoadAdwcleaner()
