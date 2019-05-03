

Func LoadSeaf()
	Local Const $ToolExistCpt = "seaf"
	Dim $KPRemoveProcessList
	Dim $KPRemoveDesktopList
	Dim $KPRemoveDownloadList
		Dim $KPUninstallNormalyList


	Local Const $descriptionPattern = "(?i)^C_XX$"
	Local Const $reg1 = "(?i)^seaf.*\.exe$"
	Local Const $reg2 = "(?i)^FSS.*\.(exe|txt|lnk)$"

	Local Const $arr1[1][2] = [[$ToolExistCpt, $reg1]]
	Local Const $arr2[1][5] = [[$ToolExistCpt, 'file', $descriptionPattern, $reg1, False]]

	_ArrayAdd($KPRemoveProcessList, $arr1)
	_ArrayAdd($KPRemoveDesktopList, $arr2)
	_ArrayAdd($KPRemoveDownloadList, $arr2)
EndFunc   ;==>LoadSeaf

LoadSeaf()
