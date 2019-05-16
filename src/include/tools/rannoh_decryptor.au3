

Func LoadRannohDecryptor()
	Dim $aKPRemoveProcessList
	Dim $aKPRemoveDesktopList
	Dim $aKPRemoveDownloadList
	Dim $aKPRemoveHomeDriveList

	Local Const $sToolExistCpt = "Rannoh Decryptor"
	Local Const $sDescriptionPattern = "(?i)^Kaspersky"

	Local Const $sReg1 = "(?i)^RannohDecryptor.*\.exe"
	Local Const $sReg2 = "(?i)^RannohDecryptor.*\.(exe|txt|zip)"
	Local Const $sReg3 = "(?i)^RannohDecryptor"

	Local Const $aArr1[1][3] = [[$sToolExistCpt, $sReg1, False]]
	Local Const $aArr2[1][5] = [[$sToolExistCpt, 'file', $sDescriptionPattern, $sReg2, False]]
	Local Const $aArr3[1][5] = [[$sToolExistCpt, 'folder', Null, $sReg3, False]]

	_ArrayAdd($aKPRemoveProcessList, $aArr1)
	_ArrayAdd($aKPRemoveDesktopList, $aArr2)
	_ArrayAdd($aKPRemoveDesktopList, $aArr3)
	_ArrayAdd($aKPRemoveDownloadList, $aArr2)
	_ArrayAdd($aKPRemoveDownloadList, $aArr3)
	_ArrayAdd($aKPRemoveHomeDriveList, $aArr2)
	_ArrayAdd($aKPRemoveHomeDriveList, $aArr3)

EndFunc   ;==>LoadRannohDecryptor

LoadRannohDecryptor()
