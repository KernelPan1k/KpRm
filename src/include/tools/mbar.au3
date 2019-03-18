
Func LoadMBAR($retry = False)
	Local Const $descriptionPattern = "(?i)^Malwarebytes Anti-Rootkit$"
	Local Const $ToolExistCpt = "mbar"

	Dim $KPRemoveProcessList
	Dim $KPRemoveDesktopList
	Dim $KPRemoveDownloadList
	Dim $KPRemoveSoftwareKeyList

	Local Const $reg1 = "(?i)^mbar.*\.exe$"
	Local Const $reg2 = "(?i)^mbar"

	Local Const $arr1[1][2] = [[$ToolExistCpt, $reg1]]
	Local Const $arr2[1][2] = [[$ToolExistCpt, $descriptionPattern]]
	Local Const $arr3[1][4] = [[$ToolExistCpt, 'file', $descriptionPattern,  $reg1]]
	Local Const $arr4[1][4] = [[$ToolExistCpt, 'folder', $descriptionPattern,  $reg2]]

	_ArrayAdd($KPRemoveProcessList, $arr1)
	_ArrayAdd($KPRemoveDesktopList, $arr3)
	_ArrayAdd($KPRemoveDownloadList, $arr3)
	_ArrayAdd($KPRemoveDesktopList, $arr4)
	_ArrayAdd($KPRemoveDownloadList, $arr4)
	_ArrayAdd($KPRemoveSoftwareKeyList, $arr2)

EndFunc   ;==>RemoveMBAR
