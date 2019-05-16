

Func LoadSymantecKovterRemovalTool()
 
	Local Const $desciptionPattern = "(?i)^Symantec"
	Local Const $toolExistCpt = "Symantec Kovter Removal Tool"

	Dim $KPRemoveProcessList
	Dim $KPRemoveDesktopList
	Dim $KPRemoveDownloadList

	Local Const $reg1 = "(?i)^FixTool.*\.exe$"
	Local Const $reg2 = "(?i)^FixTool.*\.(txt|exe)$"

	Local Const $arr1[1][3] = [[$toolExistCpt, $reg1, False]]
	Local Const $arr2[1][5] = [[$toolExistCpt, 'file', $desciptionPattern, $reg2, False]]

	_ArrayAdd($KPRemoveProcessList, $arr1)
	_ArrayAdd($KPRemoveDesktopList, $arr2)
	_ArrayAdd($KPRemoveDownloadList, $arr2)
EndFunc   ;==>LoadSymantecKovterRemovalTool

LoadSymantecKovterRemovalTool()

