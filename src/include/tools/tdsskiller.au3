

Func LoadTDSSKiller()
	Local Const $ToolExistCpt = "tdsskiller"
	Dim $KPRemoveProcessList
	Dim $KPRemoveDesktopList
	Dim $KPRemoveDownloadList
	Dim $KPRemoveHomeDriveList

	Local Const $descriptionPattern = Null
	Local Const $reg1 = "(?i)^tdsskiller.*\.exe$"
	Local Const $reg2 = "(?i)^tdsskiller.*\.(exe|zip)$"
	Local Const $reg3 = "(?i)^TDSSKiller.*_log\.txt$"
	Local Const $reg4 = "(?i)^TDSSKiller"

	Local Const $arr1[1][2] = [[$ToolExistCpt, $reg1]]
	Local Const $arr2[1][4] = [[$ToolExistCpt, 'file', $descriptionPattern, $reg2]]
	Local Const $arr3[1][4] = [[$ToolExistCpt, 'file', Null, $reg3]]
	Local Const $arr4[1][4] = [[$ToolExistCpt, 'folder', Null, $reg4]]

	_ArrayAdd($KPRemoveProcessList, $arr1)
	_ArrayAdd($KPRemoveDesktopList, $arr2)
	_ArrayAdd($KPRemoveDesktopList, $arr4)
	_ArrayAdd($KPRemoveDownloadList, $arr2)
	_ArrayAdd($KPRemoveDownloadList, $arr4)
	_ArrayAdd($KPRemoveHomeDriveList, $arr3)
	_ArrayAdd($KPRemoveHomeDriveList, $arr4)

EndFunc

LoadTDSSKiller()
