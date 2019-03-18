
Func LoadGrantPerms()
	Local Const $ToolExistCpt = "grantperms"
	Dim $KPRemoveProcessList
	Dim $KPRemoveDesktopList
	Dim $KPRemoveDownloadList
	Dim $KPRemoveHomeDriveList

	Local Const $descriptionPattern = Null
	Local Const $reg1 = "(?i)^GrantPerms.*\.exe$"
	Local Const $reg2 = "(?i)^GrantPerms.*\.(exe|zip)$"
	Local Const $reg3 = "(?i)^Perms\.txt$"
	Local Const $reg4 = "(?i)^GrantPerms"

	Local Const $arr1[1][2] = [[$ToolExistCpt, $reg1]]
	Local Const $arr2[1][4] = [[$ToolExistCpt, 'file', $descriptionPattern, $reg2]]
	Local Const $arr3[1][4] = [[$ToolExistCpt, 'file', $descriptionPattern, $reg3]]
	Local Const $arr4[1][4] = [[$ToolExistCpt, 'folder', $descriptionPattern, $reg4]]

	_ArrayAdd($KPRemoveProcessList, $arr1)
	_ArrayAdd($KPRemoveDesktopList, $arr2)
	_ArrayAdd($KPRemoveDesktopList, $arr3)
	_ArrayAdd($KPRemoveDesktopList, $arr4)
	_ArrayAdd($KPRemoveDownloadList, $arr2)
	_ArrayAdd($KPRemoveDownloadList, $arr3)
	_ArrayAdd($KPRemoveDownloadList, $arr4)
EndFunc

LoadGrantPerms()