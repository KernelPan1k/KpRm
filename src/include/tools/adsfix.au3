
Func LoadADSFix()
	Local Const $sToolExistCpt = "AdsFix"
	Dim $aKPRemoveProcessList
	Dim $aKPRemoveDesktopList
	Dim $aKPRemoveDownloadList
	Dim $aKPRemoveHomeDriveList
	Dim $aKPRemoveDesktopCommonList
	Dim $aKPRemoveSoftwareKeyList

	Local Const $sDescriptionPattern = "(?i)^AdsFix"
	Local Const $companyPattern = "(?i)^SosVirus"
	Local Const $sReg1 = "(?i)^AdsFix.*\.exe$"
	Local Const $sReg2 = "(?i)^AdsFix.*\.(exe|txt|lnk)$"
	Local Const $sReg3 = "(?i)^AdsFix.*\.txt$"

	Local Const $aArr1[1][3] = [[$sToolExistCpt, $sReg1, False]]
	Local Const $aArr2[1][5] = [[$sToolExistCpt, 'file', $companyPattern, $sReg2, False]]
	Local Const $aArr3[1][5] = [[$sToolExistCpt, 'file', Null, $sReg3, False]]
	Local Const $aArr4[1][5] = [[$sToolExistCpt, 'folder', Null, $sDescriptionPattern, True]]
	Local Const $aArr5[1][2] = [[$sToolExistCpt, $sDescriptionPattern]]

	_ArrayAdd($aKPRemoveProcessList, $aArr1)
	_ArrayAdd($aKPRemoveDesktopList, $aArr2)
	_ArrayAdd($aKPRemoveDesktopCommonList, $aArr2)
	_ArrayAdd($aKPRemoveDownloadList, $aArr2)
	_ArrayAdd($aKPRemoveHomeDriveList, $aArr3)
	_ArrayAdd($aKPRemoveHomeDriveList, $aArr4)
	_ArrayAdd($aKPRemoveSoftwareKeyList, $aArr5)

EndFunc   ;==>LoadADSFix

LoadADSFix()
