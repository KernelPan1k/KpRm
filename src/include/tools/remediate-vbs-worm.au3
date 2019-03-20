

Func LoadRemediateVbsWorm()
	Local Const $ToolExistCpt = "remediate-vbs-worm"
	Dim $KPRemoveProcessList
	Dim $KPRemoveDesktopList
	Dim $KPRemoveDownloadList
	Dim $KPRemoveHomeDriveList
	Dim $KPRemoveDesktopCommonList
	Dim $KPRemoveSoftwareKeyList

	Local Const $descriptionPattern = "(?i).*VBS autorun worms.*"
	Local Const $reg1 = "(?i)^remediate.?vbs.?worm.*\.exe$"
	Local Const $reg2 = "(?i)^Rem-VBS.*\.log$"
	Local Const $reg3 = "(?i)^Rem-VBSqt"

	Local Const $arr1[1][2] = [[$ToolExistCpt, $reg1]]
	Local Const $arr2[1][5] = [[$ToolExistCpt, 'file', $descriptionPattern, $reg1, False]]
	Local Const $arr3[1][5] = [[$ToolExistCpt, 'file', $descriptionPattern, $reg2, False]]
	Local Const $arr4[1][5] = [[$ToolExistCpt, 'folder', $descriptionPattern, $reg3, True]]

	_ArrayAdd($KPRemoveProcessList, $arr1)
	_ArrayAdd($KPRemoveDesktopList, $arr2)
	_ArrayAdd($KPRemoveDownloadList, $arr2)
	_ArrayAdd($KPRemoveHomeDriveList, $arr3)
	_ArrayAdd($KPRemoveHomeDriveList, $arr4)

EndFunc

LoadRemediateVbsWorm()
