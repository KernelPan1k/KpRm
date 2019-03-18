
Func LoadScanRapide()
	Local Const $ToolExistCpt = "scanrapide"

	Dim $KPRemoveHomeDriveList
	Dim $KPRemoveDesktopList
	Dim $KPRemoveDownloadList

	Local Const $descriptionPattern = "(?i)^ScanRapide"
	Local Const $reg1 = "(?i)^ScanRapide.*\.exe$"
	Local Const $reg2 = "(?i)^ScanRapide\[R[0-9]+\]\.txt$"

	Local Const $arr1[1][4] = [[$ToolExistCpt, 'file', $descriptionPattern, $reg1]]
	Local Const $arr2[1][4] = [[$ToolExistCpt, 'file', Null, $reg2]]

	_ArrayAdd($KPRemoveDesktopList, $arr1)
	_ArrayAdd($KPRemoveDownloadList, $arr1)
	_ArrayAdd($KPRemoveHomeDriveList, $arr2)
EndFunc