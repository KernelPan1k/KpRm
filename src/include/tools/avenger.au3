

Func LoadAvenger()

	Local Const $sToolExistCpt = "Avenger"
	Dim $aKPRemoveProcessList
	Dim $aKPRemoveDesktopList
	Dim $aKPRemoveDownloadList
	Dim $aKPRemoveHomeDriveList

	Local Const $sDescriptionPattern = Null
	Local Const $sReg1 = "(?i)^avenger.*\.(exe|zip)$"
	Local Const $sReg2 = "(?i)^avenger"
	Local Const $sReg3 = "(?i)^avenger.*\.txt$"
	Local Const $sReg4 = "(?i)^avenger.*\.exe$"

	Local Const $aArr1[1][3] = [[$sToolExistCpt, $sReg4, False]]
	Local Const $aArr2[1][5] = [[$sToolExistCpt, 'file', $sDescriptionPattern, $sReg1, False]]
	Local Const $aArr3[1][5] = [[$sToolExistCpt, 'folder', $sDescriptionPattern, $sReg2, False]]
	Local Const $aArr4[1][5] = [[$sToolExistCpt, 'file', $sDescriptionPattern, $sReg3, False]]

	_ArrayAdd($aKPRemoveProcessList, $aArr1)
	_ArrayAdd($aKPRemoveDesktopList, $aArr2)
	_ArrayAdd($aKPRemoveDesktopList, $aArr3)
	_ArrayAdd($aKPRemoveDownloadList, $aArr2)
	_ArrayAdd($aKPRemoveDownloadList, $aArr3)
	_ArrayAdd($aKPRemoveHomeDriveList, $aArr3)
	_ArrayAdd($aKPRemoveHomeDriveList, $aArr4)

EndFunc

LoadAvenger()
