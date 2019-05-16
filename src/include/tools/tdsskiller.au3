

Func LoadTDSSKiller()
	Local Const $sToolExistCpt = "TDSSKiller"
	Dim $aKPRemoveProcessList
	Dim $aKPRemoveDesktopList
	Dim $aKPRemoveDownloadList
	Dim $aKPRemoveHomeDriveList

	Local Const $sDescriptionPattern = "(?i)^.*Kaspersky"
	Local Const $sReg1 = "(?i)^tdsskiller.*\.exe$"
	Local Const $sReg2 = "(?i)^tdsskiller.*\.(exe|zip)$"
	Local Const $sReg3 = "(?i)^TDSSKiller.*_log\.txt$"
	Local Const $sReg4 = "(?i)^TDSSKiller"

	Local Const $aArr1[1][3] = [[$sToolExistCpt, $sReg1, True]]
	Local Const $aArr2[1][5] = [[$sToolExistCpt, 'file', $sDescriptionPattern, $sReg2, False]]
	Local Const $aArr3[1][5] = [[$sToolExistCpt, 'file', Null, $sReg3, False]]
	Local Const $aArr4[1][5] = [[$sToolExistCpt, 'folder', Null, $sReg4, False]]

	_ArrayAdd($aKPRemoveProcessList, $aArr1)
	_ArrayAdd($aKPRemoveDesktopList, $aArr2)
	_ArrayAdd($aKPRemoveDesktopList, $aArr4)
	_ArrayAdd($aKPRemoveDownloadList, $aArr2)
	_ArrayAdd($aKPRemoveDownloadList, $aArr4)
	_ArrayAdd($aKPRemoveHomeDriveList, $aArr3)
	_ArrayAdd($aKPRemoveHomeDriveList, $aArr4)

EndFunc

LoadTDSSKiller()
