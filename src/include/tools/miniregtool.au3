
Func LoadMiniRegTool()
	Local Const $ToolExistCpt = "miniregtool"
	Dim $KPRemoveProcessList
	Dim $KPRemoveDesktopList
	Dim $KPRemoveDownloadList
	Dim $KPRemoveHomeDriveList

	Local Const $descriptionPattern = Null
	Local Const $reg1 = "(?i)^MiniRegTool.*\.exe$"
	Local Const $reg2 = "(?i)^MiniRegTool.*\.(exe|zip)$"
	Local Const $reg3 = "(?i)^Result\.txt$"
	Local Const $reg4 = "(?i)^MiniRegTool"

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

EndFunc   ;==>LoadMiniToolBox

LoadMiniRegTool()