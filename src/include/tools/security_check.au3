
Func LoadSecurityCheck()
	Local Const $ToolExistCpt = "SecurityCheck"
	Dim $KPRemoveProcessList
	Dim $KPRemoveDesktopList
	Dim $KPRemoveDesktopFolderList
	Dim $KPRemoveDownloadList
	Dim $KPRemoveDownloadFolderList
	Dim $KPRemoveHomeDriveList

	Local Const $reg1 = "(?i)^SecurityCheck.*\.exe$"

	Local Const $arr1[1][3] = [[$ToolExistCpt, $reg1, False]]
	Local Const $arr2[1][5] = [[$ToolExistCpt, 'file', Null, $reg1, False]]

	_ArrayAdd($KPRemoveProcessList, $arr1)
	_ArrayAdd($KPRemoveDesktopList, $arr2)
	_ArrayAdd($KPRemoveDownloadList, $arr2)
EndFunc

LoadSecurityCheck()