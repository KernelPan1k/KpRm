
Func LoadAvastDecryptorCryptomix()
	Dim $KPRemoveProcessList
	Dim $KPRemoveDesktopList
	Dim $KPRemoveDownloadList

	Local Const $ToolExistCpt = "Avast Decryptor Cryptomix"
	Local Const $descriptionPattern = "(?i)^Avast"

	Local Const $reg1 = "(?i)^avast_decryptor_cryptomix.*\.exe"

	Local Const $arr1[1][3] = [[$ToolExistCpt, $reg1, False]]
	Local Const $arr2[1][5] = [[$ToolExistCpt, 'file', $descriptionPattern, $reg1, False]]

	_ArrayAdd($KPRemoveProcessList, $arr1)
	_ArrayAdd($KPRemoveDesktopList, $arr2)
	_ArrayAdd($KPRemoveDownloadList, $arr2)
EndFunc   ;==>LoadAvastDecryptorCryptomix

LoadAvastDecryptorCryptomix()