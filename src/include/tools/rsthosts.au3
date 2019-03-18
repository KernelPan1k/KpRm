
Func LoadRstHosts()
	Local Const $ToolExistCpt = "rsthosts"
	Dim $KPRemoveProcessList
	Dim $KPRemoveDesktopList
	Dim $KPRemoveDownloadList
	Dim $KPRemoveHomeDriveList

	Local Const $descriptionPattern = Null
	Local Const $reg1 = "(?i)^rsthosts.*\.exe$"
	Local Const $reg2 = "(?i)^RstHosts.*\.txt$"

	Local Const $arr1[1][2] = [[$ToolExistCpt, $reg1]]
	Local Const $arr2[1][4] = [[$ToolExistCpt, 'file', $descriptionPattern, $reg1]]
	Local Const $arr3[1][4] = [[$ToolExistCpt, 'file', $descriptionPattern, $reg2]]

	_ArrayAdd($KPRemoveProcessList, $arr1)
	_ArrayAdd($KPRemoveDesktopList, $arr2)
	_ArrayAdd($KPRemoveDownloadList, $arr2)
	_ArrayAdd($KPRemoveHomeDriveList, $arr3)

EndFunc

LoadRstHosts()
