
Func LoadFRST()
	Local Const $sToolName = "FRST"
	Dim $aKPRemoveProcessList
	Dim $aKPRemoveDesktopList
	Dim $KPRemoveDesktopFolderList
	Dim $aKPRemoveDownloadList
	Dim $KPRemoveDownloadFolderList
	Dim $aKPRemoveHomeDriveList

	Local Const $sCompanyName = "(?i)^Farbar"
	Local Const $sReg1 = "(?i)^FRST.*\.exe$"
	Local Const $sReg2 = "(?i)^FRST-OlderVersion$"
	Local Const $sReg3 = "(?i)^(FRST|fixlist|fixlog|Addition|Shortcut).*\.(exe|txt)$"
	Local Const $sReg4 = "(?i)^FRST"

	Local Const $aArr1[1][3] = [[$sToolName, $sReg1, False]]
	Local Const $aArr2[1][5] = [[$sToolName, 'file', $sCompanyName, $sReg3, False]]
	Local Const $aArr3[1][5] = [[$sToolName, 'folder', Null, $sReg2, False]]
	Local Const $aArr4[1][5] = [[$sToolName, 'folder', Null, $sReg4, True]]

	_ArrayAdd($aKPRemoveProcessList, $aArr1)
	_ArrayAdd($aKPRemoveDesktopList, $aArr2)
	_ArrayAdd($aKPRemoveDownloadList, $aArr2)
	_ArrayAdd($aKPRemoveDesktopList, $aArr3)
	_ArrayAdd($aKPRemoveDownloadList, $aArr3)
	_ArrayAdd($aKPRemoveHomeDriveList, $aArr4)

EndFunc   ;==>LoadFRST

LoadFRST()
