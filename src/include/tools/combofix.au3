

Func LoadCombofix()
	Local Const $ToolExistCpt = "combofix"
	Dim $KPRemoveDesktopList
	Dim $KPRemoveDownloadList
	Dim $KPRemoveHomeDriveList

	Local Const $descriptionPattern = "(?i)^Combofix"
	Local Const $reg1 = "(?i)^Combofix.*\.exe$"
	Local Const $reg2 = "(?i)^CFScript\.txt$"
	Local Const $reg3 = "(?i)^Qoobox$"

	Local Const $arr1[1][4] = [[$ToolExistCpt, 'file', $descriptionPattern, $reg1]]
	Local Const $arr2[1][4] = [[$ToolExistCpt, 'file', Null, $reg2]]
	Local Const $arr3[1][4] = [[$ToolExistCpt, 'folder', Null, $reg3]]

	_ArrayAdd($KPRemoveDesktopList, $arr1)
	_ArrayAdd($KPRemoveDesktopList, $arr2)
	_ArrayAdd($KPRemoveDownloadList, $arr1)
	_ArrayAdd($KPRemoveDownloadList, $arr2)
	_ArrayAdd($KPRemoveHomeDriveList, $arr3)
EndFunc

LoadCombofix()
