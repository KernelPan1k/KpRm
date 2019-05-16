
Func LoadSFT()
	Local Const $sDescriptionPattern = Null
	Local Const $sToolExistCpt = "SFT"

	Dim $aKPRemoveProcessList
	Dim $aKPRemoveDesktopList
	Dim $aKPRemoveDownloadList

	Local Const $sReg1 = "(?i)^SFT.*\.exe$"
	Local Const $sReg2 = "(?i)^SFT.*\.(txt|exe|zip)$"

	Local Const $aArr1[1][3] = [[$sToolExistCpt, $sReg1, False]]
	Local Const $aArr2[1][5] = [[$sToolExistCpt, 'file', $sDescriptionPattern, $sReg2, False]]

	_ArrayAdd($aKPRemoveProcessList, $aArr1)
	_ArrayAdd($aKPRemoveDesktopList, $aArr2)
	_ArrayAdd($aKPRemoveDownloadList, $aArr2)
EndFunc   ;==>LoadSFT

LoadSFT()
