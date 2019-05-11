

Func LoadRannohDecryptor()
	Dim $KPRemoveProcessList
	Dim $KPRemoveDesktopList
	Dim $KPRemoveDownloadList
	Dim $KPRemoveHomeDriveList

	Local Const $ToolExistCpt = "Rannoh Decryptor"
	Local Const $descriptionPattern = "(?i)^Kaspersky"

	Local Const $reg1 = "(?i)^RannohDecryptor.*\.exe"
	Local Const $reg2 = "(?i)^RannohDecryptor.*\.(exe|txt|zip)"
	Local Const $reg3 = "(?i)^RannohDecryptor"

	Local Const $arr1[1][3] = [[$ToolExistCpt, $reg1, False]]
	Local Const $arr2[1][5] = [[$ToolExistCpt, 'file', $descriptionPattern, $reg2, False]]
	Local Const $arr3[1][5] = [[$ToolExistCpt, 'folder', Null, $reg3, False]]

	_ArrayAdd($KPRemoveProcessList, $arr1)
	_ArrayAdd($KPRemoveDesktopList, $arr2)
	_ArrayAdd($KPRemoveDesktopList, $arr3)
	_ArrayAdd($KPRemoveDownloadList, $arr2)
	_ArrayAdd($KPRemoveDownloadList, $arr3)
	_ArrayAdd($KPRemoveHomeDriveList, $arr2)
	_ArrayAdd($KPRemoveHomeDriveList, $arr3)

EndFunc   ;==>LoadRakhniDecryptor

LoadRannohDecryptor()
