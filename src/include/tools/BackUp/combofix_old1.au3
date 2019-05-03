

Func LoadCombofix()
	Local Const $ToolExistCpt = "combofix"
	Dim $KPRemoveDesktopList
	Dim $KPRemoveDownloadList
	Dim $KPRemoveHomeDriveList
	Dim $KPRemoveWindowsFolderList
	Dim $KPRemoveSoftwareKeyList
	Dim $KPRemoveProcessList
		Dim $KPRemoveRegistryKeysList

	Local Const $descriptionPattern = "(?i)^Swearware"
	Local Const $reg1 = "(?i)^Combofix.*\.exe$"
	Local Const $reg2 = "(?i)^CFScript\.txt$"
	Local Const $reg3 = "(?i)^Qoobox$"
	Local Const $reg4 = "(?i)^Combofix.*\.txt$"
	Local Const $reg5 = "(?i)^(grep|PEV|NIRCMD|MBR|SED|SWREG|SWSC|SWXCACLS|Zip)\.exe$"
	Local Const $reg6 = "(?i)^Swearware$"

	Local Const $arr1[1][5] = [[$ToolExistCpt, 'file', $descriptionPattern, $reg1, False]]
	Local Const $arr2[1][5] = [[$ToolExistCpt, 'file', Null, $reg2, False]]
	Local Const $arr3[1][5] = [[$ToolExistCpt, 'folder', Null, $reg3, True]]
	Local Const $arr4[1][5] = [[$ToolExistCpt, 'file', Null, $reg4, False]]
	Local Const $arr5[1][5] = [[$ToolExistCpt, 'file', Null, $reg5, True]]
	Local Const $arr6[1][2] = [[$ToolExistCpt, $reg6]]
	Local Const $arr7[1][2] = [[$ToolExistCpt, $reg1]]

	_ArrayAdd($KPRemoveDesktopList, $arr1)
	_ArrayAdd($KPRemoveDesktopList, $arr2)
	_ArrayAdd($KPRemoveDownloadList, $arr1)
	_ArrayAdd($KPRemoveDownloadList, $arr2)
	_ArrayAdd($KPRemoveHomeDriveList, $arr3)
	_ArrayAdd($KPRemoveHomeDriveList, $arr4)
	_ArrayAdd($KPRemoveWindowsFolderList, $arr5)
	_ArrayAdd($KPRemoveSoftwareKeyList, $arr6)
	_ArrayAdd($KPRemoveProcessList, $arr7)

EndFunc   ;==>LoadCombofix

LoadCombofix()
