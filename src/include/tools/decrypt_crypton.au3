
Func LoadDecryptCryptON()
	Dim $aKPRemoveProcessList
	Dim $aKPRemoveDesktopList
	Dim $aKPRemoveDownloadList

	Local Const $sToolName = "Decrypt CryptON"
	Local Const $sCompanyName = "(?i)^Emsisoft"

	Local Const $sReg1 = "(?i)^decrypt_CryptON.*\.exe"

	Local Const $aArr1[1][3] = [[$sToolName, $sReg1, False]]
	Local Const $aArr2[1][5] = [[$sToolName, 'file', $sCompanyName, $sReg1, False]]

	_ArrayAdd($aKPRemoveProcessList, $aArr1)
	_ArrayAdd($aKPRemoveDesktopList, $aArr2)
	_ArrayAdd($aKPRemoveDownloadList, $aArr2)
EndFunc   ;==>LoadAvastDecryptorCryptomix

LoadDecryptCryptON()
