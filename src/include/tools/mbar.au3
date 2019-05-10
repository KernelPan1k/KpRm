
Func LoadMBAR($retry = False)
	Local Const $descriptionPattern = "(?i)^Malwarebytes Anti-Rootkit$"
	Local Const $companyPattern = "(?i)^Malwarebytes"
	Local Const $ToolExistCpt = "Malwarebytes Anti-Rootkit"

	Dim $KPRemoveProcessList
	Dim $KPRemoveDesktopList
	Dim $KPRemoveDownloadList
	Dim $KPRemoveSoftwareKeyList
	Dim $KPCleanDirectoryContentList


	Local Const $reg1 = "(?i)^mbar.*\.exe$"
	Local Const $reg2 = "(?i)^mbar"

	Local Const $arr1[1][3] = [[$ToolExistCpt, $reg1, True]]
	Local Const $arr2[1][2] = [[$ToolExistCpt, $descriptionPattern]]
	Local Const $arr3[1][5] = [[$ToolExistCpt, 'file', $companyPattern, $reg1, False]]
	Local Const $arr4[1][5] = [[$ToolExistCpt, 'folder', $descriptionPattern, $reg2, False]]
	Local Const $arr5[1][4] = [[$ToolExistCpt, @AppDataCommonDir & "\Malwarebytes\Malwarebytes' Anti-Malware\Quarantine", Null, True]]

	_ArrayAdd($KPRemoveProcessList, $arr1)
	_ArrayAdd($KPRemoveDesktopList, $arr3)
	_ArrayAdd($KPRemoveDownloadList, $arr3)
	_ArrayAdd($KPRemoveDesktopList, $arr4)
	_ArrayAdd($KPRemoveDownloadList, $arr4)
	_ArrayAdd($KPRemoveSoftwareKeyList, $arr2)
	_ArrayAdd($KPCleanDirectoryContentList, $arr5)


EndFunc   ;==>LoadMBAR

LoadMBAR()
