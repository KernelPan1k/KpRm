
Func LoadMBAR($retry = False)
	Local Const $descriptionPattern = "(?i)^Malwarebytes Anti-Rootkit$"
	Local Const $MbarFixExistCpt = "mbar"
	Dim $KPRemoveProcessList
	Dim $KPRemoveDesktopFolderList
	Dim $KPRemoveDownloadFolderList
	Dim $KPRemoveDesktopList
	Dim $KPRemoveDownloadList
	Dim $KPRemoveSoftwareKeyList

	Local Const $arr1[1][2] = [[$MbarFixExistCpt, "(?i)^mbar"]]
	Local Const $arr2[1][2] = [[$MbarFixExistCpt, $descriptionPattern]]
	Local Const $arr3[1][3] = [[$MbarFixExistCpt, $descriptionPattern,  "(?i)^mbar.*\.exe$"]]

	_ArrayAdd($KPRemoveProcessList, $arr1)
	_ArrayAdd($KPRemoveDesktopFolderList, $arr1)
	_ArrayAdd($KPRemoveDownloadFolderList, $arr1)
	_ArrayAdd($KPRemoveDesktopList, $arr3)
	_ArrayAdd($KPRemoveDownloadList, $arr3)
	_ArrayAdd($KPRemoveSoftwareKeyList, $arr2)

EndFunc   ;==>RemoveMBAR
