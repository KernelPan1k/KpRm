

Func LoadCheckBrowserLnk()
 
	Local Const $desciptionPattern = "(?i)^Alex Dragokas"
	Local Const $toolExistCpt = "Check Browsers LNK"

	Dim $KPRemoveProcessList
	Dim $KPRemoveDesktopList
	Dim $KPRemoveDownloadList

	Local Const $reg1 = "(?i)^Check_Browsers_LNK.*\.exe$"
	Local Const $reg2 = "(?i)^Check_Browsers_LNK.*\.(log|exe)$"

	Local Const $arr1[1][3] = [[$toolExistCpt, $reg1, False]]
	Local Const $arr2[1][5] = [[$toolExistCpt, 'file', $desciptionPattern, $reg2, False]]

	_ArrayAdd($KPRemoveProcessList, $arr1)
	_ArrayAdd($KPRemoveDesktopList, $arr2)
	_ArrayAdd($KPRemoveDownloadList, $arr2)
EndFunc   ;==>LoadCheckBrowserLnk

LoadCheckBrowserLnk()

