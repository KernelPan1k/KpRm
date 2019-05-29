
Func LoadUnZacMe()

	Local Const $sToolName = "UnZacMe"
	Dim $aKPRemoveProcessList
	Dim $aKPRemoveDesktopList
	Dim $aKPRemoveDownloadList
	Dim $aKPRemoveHomeDriveList

	Local Const $sCompanyName = "(?i)^SosVirus"
	Local Const $sReg1 = "(?i)^UnZacMe.*\.exe$"
	Local Const $sReg2 = "(?i)^UnZacMe.*\.(exe|txt|lnk)$"
	Local Const $sReg3 = "(?i)^UnZacMe.*\.txt$"
	Local Const $sReg4 = "(?i)^UnZacMe$"

	Local Const $aArr1[1][3] = [[$sToolName, $sReg1, False]]
	Local Const $aArr2[1][5] = [[$sToolName, 'file', $sCompanyName, $sReg2, False]]
	Local Const $aArr3[1][5] = [[$sToolName, 'file', Null, $sReg3, False]]
	Local Const $aArr4[1][5] = [[$sToolName, 'folder', Null, $sReg4, True]]

	_ArrayAdd($aKPRemoveProcessList, $aArr1)
	_ArrayAdd($aKPRemoveDesktopList, $aArr2)
	_ArrayAdd($aKPRemoveDownloadList, $aArr2)
	_ArrayAdd($aKPRemoveHomeDriveList, $aArr3)
	_ArrayAdd($aKPRemoveHomeDriveList, $aArr4)

EndFunc   ;==>LoadUnZacMe

LoadUnZacMe()
