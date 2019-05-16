
Func LoadSecurityCheck()
	Local Const $sToolExistCpt = "SecurityCheck"
	Dim $aKPRemoveProcessList
	Dim $aKPRemoveDesktopList
	Dim $KPRemoveDesktopFolderList
	Dim $aKPRemoveDownloadList
	Dim $KPRemoveDownloadFolderList
	Dim $aKPRemoveHomeDriveList

	Local Const $sReg1 = "(?i)^SecurityCheck.*\.exe$"

	Local Const $aArr1[1][3] = [[$sToolExistCpt, $sReg1, False]]
	Local Const $aArr2[1][5] = [[$sToolExistCpt, 'file', Null, $sReg1, False]]

	_ArrayAdd($aKPRemoveProcessList, $aArr1)
	_ArrayAdd($aKPRemoveDesktopList, $aArr2)
	_ArrayAdd($aKPRemoveDownloadList, $aArr2)
EndFunc

LoadSecurityCheck()