
Func LoadAvastDecryptorCryptomix()
	Dim $aKPRemoveProcessList
	Dim $aKPRemoveDesktopList
	Dim $aKPRemoveDownloadList

	Local Const $sToolExistCpt = "Avast Decryptor Cryptomix"
	Local Const $sDescriptionPattern = "(?i)^Avast"

	Local Const $sReg1 = "(?i)^avast_decryptor_cryptomix.*\.exe"

	Local Const $aArr1[1][3] = [[$sToolExistCpt, $sReg1, False]]
	Local Const $aArr2[1][5] = [[$sToolExistCpt, 'file', $sDescriptionPattern, $sReg1, False]]

	_ArrayAdd($aKPRemoveProcessList, $aArr1)
	_ArrayAdd($aKPRemoveDesktopList, $aArr2)
	_ArrayAdd($aKPRemoveDownloadList, $aArr2)
EndFunc   ;==>LoadAvastDecryptorCryptomix

LoadAvastDecryptorCryptomix()