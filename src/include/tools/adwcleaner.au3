
Func LoadAdwcleaner()
	Local Const $sToolExistCpt = "AdwCleaner"
	Local Const $sDescriptionPattern = "(?i)^AdwCleaner"
	Local Const $companyPattern = "(?i)^Malwarebytes"
	Local Const $sReg1 = "(?i)^AdwCleaner.*\.exe$"

	Dim $aKPRemoveProcessList
	Dim $aKPRemoveDesktopList
	Dim $aKPRemoveDownloadList
	Dim $aKPRemoveHomeDriveList

	Local Const $aArr1[1][3] = [[$sToolExistCpt, $sReg1, False]]
	Local Const $aArr2[1][5] = [[$sToolExistCpt, 'file', $companyPattern, $sReg1, False]]
	Local Const $aArr3[1][5] = [[$sToolExistCpt, 'folder', Null, $sDescriptionPattern, True]]

	_ArrayAdd($aKPRemoveProcessList, $aArr1)
	_ArrayAdd($aKPRemoveDesktopList, $aArr2)
	_ArrayAdd($aKPRemoveDownloadList, $aArr2)
	_ArrayAdd($aKPRemoveHomeDriveList, $aArr3)

EndFunc   ;==>LoadAdwcleaner

LoadAdwcleaner()
