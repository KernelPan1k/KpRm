

Func LoadCombofix()
	Local Const $ToolExistCpt = "combofix"
	Dim $KPRemoveDesktopList
	Dim $KPRemoveDownloadList
	Dim $KPRemoveHomeDriveList

	Local Const $descriptionPattern = "(?i)^Combofix"
	Local Const $reg1 = "(?i)^Combofix.*\.exe$"
	Local Const $reg2 = "(?i)^CFScript\.txt$"
	Local Const $reg3 = "(?i)^Qoobox$"
	Local Const $reg4 = "(?i)^Combofix.*\.txt$"

	Local Const $arr1[1][5] = [[$ToolExistCpt, 'file', $descriptionPattern, $reg1, False]]
	Local Const $arr2[1][5] = [[$ToolExistCpt, 'file', Null, $reg2, False]]
	Local Const $arr3[1][5] = [[$ToolExistCpt, 'folder', Null, $reg3, True]]
	Local Const $arr4[1][5] = [[$ToolExistCpt, 'file', Null, $reg4, False]]

	_ArrayAdd($KPRemoveDesktopList, $arr1)
	_ArrayAdd($KPRemoveDesktopList, $arr2)
	_ArrayAdd($KPRemoveDownloadList, $arr1)
	_ArrayAdd($KPRemoveDownloadList, $arr2)
	_ArrayAdd($KPRemoveHomeDriveList, $arr3)
	_ArrayAdd($KPRemoveHomeDriveList, $arr4)
EndFunc

LoadCombofix()
