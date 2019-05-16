
Func LoadOTM()
	Local Const $sToolExistCpt = "OTM"
	Dim $aKPRemoveProcessList
	Dim $aKPRemoveDesktopList
	Dim $aKPRemoveDownloadList
	Dim $aKPRemoveHomeDriveList

	Local Const $sDescriptionPattern = "(?i)^OldTimer"

	Local Const $sReg1 = "(?i)^OTM.*\.exe$"
	Local Const $sReg2 = "(?i)^_OTM$"

	Local Const $aArr1[1][3] = [[$sToolExistCpt, $sReg1, False]]
	Local Const $aArr2[1][5] = [[$sToolExistCpt, 'file', $sDescriptionPattern, $sReg1, False]]
	Local Const $aArr3[1][5] = [[$sToolExistCpt, 'folder', Null, $sReg2, True]]

	_ArrayAdd($aKPRemoveProcessList, $aArr1)
	_ArrayAdd($aKPRemoveDesktopList, $aArr2)
	_ArrayAdd($aKPRemoveDownloadList, $aArr2)
	_ArrayAdd($aKPRemoveHomeDriveList, $aArr3)
EndFunc   ;==>LoadOTM

LoadOTM()
