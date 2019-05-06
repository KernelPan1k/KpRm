
Func LoadScanRapide()
	Local Const $ToolExistCpt = "ScanRapide"

	Dim $KPRemoveHomeDriveList
	Dim $KPRemoveDesktopList
	Dim $KPRemoveDownloadList

	Local Const $descriptionPattern = Null
	Local Const $reg1 = "(?i)^ScanRapide.*\.exe$"
	Local Const $reg2 = "(?i)^ScanRapide\[R[0-9]+\]\.txt$"

	Local Const $arr1[1][5] = [[$ToolExistCpt, 'file', $descriptionPattern, $reg1, False]]
	Local Const $arr2[1][5] = [[$ToolExistCpt, 'file', Null, $reg2, False]]

	_ArrayAdd($KPRemoveDesktopList, $arr1)
	_ArrayAdd($KPRemoveDownloadList, $arr1)
	_ArrayAdd($KPRemoveHomeDriveList, $arr2)
EndFunc

LoadScanRapide()
