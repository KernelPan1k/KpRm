

Func LoadSeaf()
	Local Const $ToolExistCpt = "seaf"
	Dim $KPRemoveProcessList
	Dim $KPRemoveDesktopList
	Dim $KPRemoveDownloadList
	Dim $KPUninstallNormalyList


	Local Const $descriptionPattern = "(?i)^C_XX$"
	Local Const $folderPattern = "(?i)^SEAF$"
	Local Const $reg1 = "(?i)^seaf.*\.exe$"
	Local Const $reg2 = "(?i)^Un-SEAF\.exe$"

	Local Const $arr1[1][2] = [[$ToolExistCpt, $reg1]]
	Local Const $arr2[1][5] = [[$ToolExistCpt, 'file', $descriptionPattern, $reg1, False]]
	Local Const $arr3[1][3] = [[$ToolExistCpt, $folderPattern, $reg2]]
		Local Const $arr2[1][4] = [[$ToolExistCpt, "HKLM" & $s64Bit & "\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall", $reg1, "DisplayName"]]


	_ArrayAdd($KPRemoveProcessList, $arr1)
	_ArrayAdd($KPRemoveDesktopList, $arr2)
	_ArrayAdd($KPRemoveDownloadList, $arr2)
	_ArrayAdd($KPUninstallNormalyList, $arr3)
EndFunc   ;==>LoadSeaf

LoadSeaf()
