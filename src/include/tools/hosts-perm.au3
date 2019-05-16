

Func LoadHostsPerm()
	Local Const $sToolExistCpt = "Hosts-perm"
	Dim $aKPRemoveDesktopList
	Dim $aKPRemoveDownloadList

	Local Const $sReg1 = "(?i)^hosts\-perm.*\.bat$"

	Local Const $aArr1[1][5] = [[$sToolExistCpt, 'file', Null, $sReg1, False]]

	_ArrayAdd($aKPRemoveDesktopList, $aArr1)
	_ArrayAdd($aKPRemoveDownloadList, $aArr1)
EndFunc

LoadHostsPerm()