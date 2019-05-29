
Func LoadCryptoSearch()
	Local Const $sToolName = "CryptoSearch"

	Dim $aKPRemoveProcessList
	Dim $aKPRemoveDesktopList
	Dim $aKPRemoveDownloadList

	Local Const $sReg1 = "(?i)^CryptoSearch.*\.exe$"
	Local Const $sReg2 = "(?i)^CryptoSearch.*\.(exe|zip|txt)$"
	Local Const $sReg3 = "(?i)^CryptoSearch$"

	Local Const $aArr1[1][3] = [[$sToolName, $sReg1, False]]
	Local Const $aArr2[1][5] = [[$sToolName, 'file', Null, $sReg2, False]]
	Local Const $aArr3[1][5] = [[$sToolName, 'folder', Null, $sReg3, False]]

	If FileExists(@DesktopDir & "\cryptosearch-definitions.bin") Then
		RemoveFile(@DesktopDir & "\cryptosearch-definitions.bin", $sToolName, Null, False)
	EndIf

	_ArrayAdd($aKPRemoveProcessList, $aArr1)
	_ArrayAdd($aKPRemoveDesktopList, $aArr2)
	_ArrayAdd($aKPRemoveDesktopList, $aArr3)
	_ArrayAdd($aKPRemoveDownloadList, $aArr2)
	_ArrayAdd($aKPRemoveDownloadList, $aArr3)

EndFunc   ;==>LoadCryptoSearch

LoadCryptoSearch()
