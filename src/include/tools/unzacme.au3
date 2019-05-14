
Func LoadUnZacMe()

	Local Const $ToolExistCpt = "UnZacMe"
	Dim $KPRemoveProcessList
	Dim $KPRemoveDesktopList
	Dim $KPRemoveDownloadList
	Dim $KPRemoveHomeDriveList

	Local Const $descriptionPattern = "(?i)^SosVirus"
	Local Const $reg1 = "(?i)^UnZacMe.*\.exe$"
	Local Const $reg2 = "(?i)^UnZacMe.*\.(exe|txt|lnk)$"
	Local Const $reg3 = "(?i)^UnZacMe.*\.txt$"
	Local Const $reg4 = "(?i)^UnZacMe$"

	Local Const $arr1[1][3] = [[$ToolExistCpt, $reg1, False]]
	Local Const $arr2[1][5] = [[$ToolExistCpt, 'file', $descriptionPattern, $reg2, False]]
	Local Const $arr3[1][5] = [[$ToolExistCpt, 'file', Null, $reg3, False]]
	Local Const $arr4[1][5] = [[$ToolExistCpt, 'folder', Null, $reg4, True]]

	_ArrayAdd($KPRemoveProcessList, $arr1)
	_ArrayAdd($KPRemoveDesktopList, $arr2)
	_ArrayAdd($KPRemoveDownloadList, $arr2)
	_ArrayAdd($KPRemoveHomeDriveList, $arr3)
	_ArrayAdd($KPRemoveHomeDriveList, $arr4)

EndFunc   ;==>LoadUnZacMe

LoadUnZacMe()
