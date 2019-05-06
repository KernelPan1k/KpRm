
Func LoadMiniRegTool()
	Local Const $ToolExistCpt = "MiniregTool"
	Dim $KPRemoveProcessList
	Dim $KPRemoveDesktopList
	Dim $KPRemoveDownloadList
	Dim $KPRemoveHomeDriveList

	Local Const $descriptionPattern = Null
	Local Const $reg1 = "(?i)^MiniRegTool.*\.exe$"
	Local Const $reg2 = "(?i)^MiniRegTool.*\.(exe|zip)$"
	Local Const $reg3 = "(?i)^Result\.txt$"
	Local Const $reg4 = "(?i)^MiniRegTool"

	Local Const $arr1[1][3] = [[$ToolExistCpt, $reg1, False]]
	Local Const $arr2[1][5] = [[$ToolExistCpt, 'file', $descriptionPattern, $reg2, False]]
	Local Const $arr3[1][5] = [[$ToolExistCpt, 'file', $descriptionPattern, $reg3, False]]
	Local Const $arr4[1][5] = [[$ToolExistCpt, 'folder', $descriptionPattern, $reg4, False]]

	_ArrayAdd($KPRemoveProcessList, $arr1)
	_ArrayAdd($KPRemoveDesktopList, $arr2)
	_ArrayAdd($KPRemoveDesktopList, $arr3)
	_ArrayAdd($KPRemoveDesktopList, $arr4)
	_ArrayAdd($KPRemoveDownloadList, $arr2)
	_ArrayAdd($KPRemoveDownloadList, $arr3)
	_ArrayAdd($KPRemoveDownloadList, $arr4)

EndFunc   ;==>LoadMiniRegTool

LoadMiniRegTool()
