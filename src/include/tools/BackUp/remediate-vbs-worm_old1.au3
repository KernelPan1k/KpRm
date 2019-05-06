

Func LoadRemediateVbsWorm()
	Local Const $ToolExistCpt = "remediate-vbs-worm"
	Dim $KPRemoveProcessList
	Dim $KPRemoveDesktopList
	Dim $KPRemoveDownloadList
	Dim $KPRemoveHomeDriveList
	Dim $KPRemoveDesktopCommonList
	Dim $KPRemoveSoftwareKeyList

	Local Const $descriptionPattern = "(?i).*VBS autorun worms.*"
	Local Const $companyPattern = Null
	Local Const $reg1 = "(?i)^remediate.?vbs.?worm.*\.exe$"
	Local Const $reg2 = "(?i)^Rem-VBS.*\.log$"
	Local Const $reg3 = "(?i)^Rem-VBS"
	Local Const $reg4 = "(?i)^Rem-VBSworm.*\.exe$"


	Local Const $arr1[1][3] = [[$ToolExistCpt, $reg1, False]]
	Local Const $arr2[1][5] = [[$ToolExistCpt, 'file', $companyPattern, $reg1, False]]
	Local Const $arr3[1][5] = [[$ToolExistCpt, 'file', $companyPattern, $reg2, False]]
	Local Const $arr4[1][5] = [[$ToolExistCpt, 'folder', $descriptionPattern, $reg3, True]]
	Local Const $arr5[1][2] = [[$ToolExistCpt, $reg4]]
	Local Const $arr6[1][5] = [[$ToolExistCpt, 'file', $companyPattern, $reg4, False]]



	_ArrayAdd($KPRemoveProcessList, $arr1)
	_ArrayAdd($KPRemoveProcessList, $arr5)
	_ArrayAdd($KPRemoveDesktopList, $arr2)
	_ArrayAdd($KPRemoveDesktopList, $arr6)
	_ArrayAdd($KPRemoveDownloadList, $arr2)
	_ArrayAdd($KPRemoveDownloadList, $arr6)
	_ArrayAdd($KPRemoveHomeDriveList, $arr3)
	_ArrayAdd($KPRemoveHomeDriveList, $arr4)

EndFunc   ;==>LoadRemediateVbsWorm

LoadRemediateVbsWorm()
