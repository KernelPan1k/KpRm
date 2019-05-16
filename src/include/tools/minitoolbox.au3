
Func LoadMiniToolBox()
	Local Const $sToolExistCpt = "Minitoolbox"
	Dim $aKPRemoveProcessList
	Dim $aKPRemoveDesktopList
	Dim $aKPRemoveDownloadList
	Dim $aKPRemoveHomeDriveList

	Local Const $sDescriptionPattern = "(?i)^Farbar"
	Local Const $sReg1 = "(?i)^MiniToolBox.*\.exe$"
	Local Const $sReg2 = "(?i)^MTB\.txt$"

	Local Const $aArr1[1][2] = [[$sToolExistCpt, $sReg1]]
	Local Const $aArr2[1][5] = [[$sToolExistCpt, 'file', $sDescriptionPattern, $sReg1, False]]
	Local Const $aArr3[1][5] = [[$sToolExistCpt, 'file', Null, $sReg2, False]]

	_ArrayAdd($aKPRemoveProcessList, $aArr1)
	_ArrayAdd($aKPRemoveDesktopList, $aArr2)
	_ArrayAdd($aKPRemoveDesktopList, $aArr3)
	_ArrayAdd($aKPRemoveDownloadList, $aArr2)
	_ArrayAdd($aKPRemoveDownloadList, $aArr3)
EndFunc   ;==>LoadMiniToolBox

LoadMiniToolBox()
