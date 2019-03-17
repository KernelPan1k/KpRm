
Func LoadScanRapide()
	Local Const $ToolExistCpt = "scanrapide"

	Dim $KPRemoveHomeDriveFileList
	Dim $KPRemoveDesktopList
	Dim $KPRemoveDownloadList

	Local Const $descriptionPattern = "(?i)^ScanRapide"
	Local Const $reg1 = "(?i)^ScanRapide.*\.exe$"
	Local Const $reg2 = "(?i)^ScanRapide\[R[0-9]+\]\.txt$"

	Local Const $arr2[1][3] = [[$ToolExistCpt, $descriptionPattern, $reg1]]
	Local Const $arr3[1][3] = [[$ToolExistCpt, Null, $reg2]]

	_ArrayAdd($KPRemoveDesktopList, $arr2)
	_ArrayAdd($KPRemoveDownloadList, $arr2)
	_ArrayAdd($KPRemoveHomeDriveFileList, $arr3)
EndFunc