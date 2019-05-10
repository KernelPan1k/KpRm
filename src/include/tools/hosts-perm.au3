

Func LoadHostsPerm()
	Local Const $ToolExistCpt = "Hosts-perm"
	Dim $KPRemoveDesktopList
	Dim $KPRemoveDownloadList

	Local Const $reg1 = "(?i)^hosts\-perm.*\.bat$"

	Local Const $arr1[1][5] = [[$ToolExistCpt, 'file', Null, $reg1, False]]

	_ArrayAdd($KPRemoveDesktopList, $arr1)
	_ArrayAdd($KPRemoveDownloadList, $arr1)
EndFunc

LoadHostsPerm()