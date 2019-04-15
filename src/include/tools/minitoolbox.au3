
Func LoadMiniToolBox()
	Local Const $ToolExistCpt = "minitoolbox"
	Dim $KPRemoveProcessList
	Dim $KPRemoveDesktopList
	Dim $KPRemoveDownloadList
	Dim $KPRemoveHomeDriveList

	Local Const $descriptionPattern = "(?i)^Farbar"
	Local Const $reg1 = "(?i)^MiniToolBox.*\.exe$"
	Local Const $reg2 = "(?i)^MTB\.txt$"

	Local Const $arr1[1][2] = [[$ToolExistCpt, $reg1]]
	Local Const $arr2[1][5] = [[$ToolExistCpt, 'file', $descriptionPattern, $reg1, False]]
	Local Const $arr3[1][5] = [[$ToolExistCpt, 'file', Null, $reg2, False]]

	_ArrayAdd($KPRemoveProcessList, $arr1)
	_ArrayAdd($KPRemoveDesktopList, $arr2)
	_ArrayAdd($KPRemoveDesktopList, $arr3)
	_ArrayAdd($KPRemoveDownloadList, $arr2)
	_ArrayAdd($KPRemoveDownloadList, $arr3)
EndFunc   ;==>LoadMiniToolBox

LoadMiniToolBox()