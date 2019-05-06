
Func LoadSFT()
	Local Const $desciptionPattern = Null
	Local Const $toolExistCpt = "sft"

	Dim $KPRemoveProcessList
	Dim $KPRemoveDesktopList
	Dim $KPRemoveDownloadList

	Local Const $reg1 = "(?i)^SFT.*\.exe$"
	Local Const $reg2 = "(?i)^SFT.*\.(txt|exe|zip)$"

	Local Const $arr1[1][3] = [[$toolExistCpt, $reg1, False]]
	Local Const $arr2[1][5] = [[$toolExistCpt, 'file', $desciptionPattern, $reg2, False]]

	_ArrayAdd($KPRemoveProcessList, $arr1)
	_ArrayAdd($KPRemoveDesktopList, $arr2)
	_ArrayAdd($KPRemoveDownloadList, $arr2)
EndFunc   ;==>LoadSFT

LoadSFT()
