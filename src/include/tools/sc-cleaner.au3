
Func LoadSCCleaner()
	Dim $aKPRemoveProcessList
	Dim $aKPRemoveDesktopList
	Dim $aKPRemoveDownloadList
	Dim $aKPRemoveHomeDriveList

	Local Const $sToolExistCpt = "Shortcut Cleaner"
	Local Const $sDescriptionPattern = "(?i)^Bleeping Computer"

	Local Const $sReg1 = "(?i)^sc-cleaner.*\.exe$"
	Local Const $sReg2 = "(?i)^sc-cleaner.*\.(exe|txt)$"

	Local Const $aArr1[1][3] = [[$sToolExistCpt, $sReg1, False]]
	Local Const $aArr2[1][5] = [[$sToolExistCpt, 'file', $sDescriptionPattern, $sReg2, False]]

	_ArrayAdd($aKPRemoveProcessList, $aArr1)
	_ArrayAdd($aKPRemoveDesktopList, $aArr2)
	_ArrayAdd($aKPRemoveDownloadList, $aArr2)

EndFunc   ;==>LoadSCCleaner

LoadSCCleaner()
