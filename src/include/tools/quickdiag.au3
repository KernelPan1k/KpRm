
Func LoadQuickDiag()

	Local Const $ToolExistCpt = "quickdiag"
	Dim $KPRemoveProcessList
	Dim $KPRemoveDesktopList
	Dim $KPRemoveDownloadList
	Dim $KPRemoveHomeDriveList

	Local Const $descriptionPattern = "(?i)^QuickDiag"
	Local Const $reg1 = "(?i)^QuickDiag.*\.exe$"
	Local Const $reg2 = "(?i)^QuickDiag.*\.(exe|txt)$"
	Local Const $reg3 = "(?i)^QuickScript.*\.txt$"
	Local Const $reg4 = "(?i)^QuickDiag.*\.txt$"
	Local Const $reg5 = "(?i)^QuickDiag"

	Local Const $arr1[1][2] = [[$ToolExistCpt, $reg1]]
	Local Const $arr2[1][4] = [[$ToolExistCpt, 'file', $descriptionPattern, $reg2]]
	Local Const $arr3[1][4] = [[$ToolExistCpt, 'file', $descriptionPattern, $reg3]]
	Local Const $arr4[1][4] = [[$ToolExistCpt, 'file', Null, $reg4]]
	Local Const $arr5[1][4] = [[$ToolExistCpt, 'folder', Null, $reg5]]

	_ArrayAdd($KPRemoveProcessList, $arr1)
	_ArrayAdd($KPRemoveDesktopList, $arr2)
	_ArrayAdd($KPRemoveDownloadList, $arr2)
	_ArrayAdd($KPRemoveDesktopList, $arr3)
	_ArrayAdd($KPRemoveDownloadList, $arr3)
	_ArrayAdd($KPRemoveHomeDriveList, $arr4)
	_ArrayAdd($KPRemoveHomeDriveList, $arr5)

EndFunc

LoadQuickDiag()
