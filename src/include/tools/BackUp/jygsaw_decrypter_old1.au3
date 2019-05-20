
Func LoadJigSawDecrypter()
	Local Const $sToolExistCpt = "GhostCryptDecrypter"

	Dim $aKPRemoveProcessList
	Dim $aKPRemoveDesktopList
	Dim $aKPRemoveDownloadList

	Local Const $sReg1 = "(?i)^GhostCryptDecrypter.*\.exe$"
	Local Const $sReg2 = "(?i)^alphadecrypter-log.*\.txt$"
	Local Const $sReg3 = "(?i)^GhostCryptDecrypter$"

	Local Const $aArr1[1][3] = [[$sToolExistCpt, $sReg1, False]]
	Local Const $aArr2[1][5] = [[$sToolExistCpt, 'file', Null, $sReg1, False]]
	Local Const $aArr3[1][5] = [[$sToolExistCpt, 'file', Null, $sReg2, False]]
	Local Const $aArr4[1][5] = [[$sToolExistCpt, 'folder', Null, $sReg3, False]]

	_ArrayAdd($aKPRemoveProcessList, $aArr1)
	_ArrayAdd($aKPRemoveDesktopList, $aArr2)
	_ArrayAdd($aKPRemoveDesktopList, $aArr3)
	_ArrayAdd($aKPRemoveDesktopList, $aArr4)
	_ArrayAdd($aKPRemoveDownloadList, $aArr2)
	_ArrayAdd($aKPRemoveDownloadList, $aArr3)
	_ArrayAdd($aKPRemoveDownloadList, $aArr4)

EndFunc   ;==>LoadGhostCryptDecrypter

LoadJigSawDecrypter()
