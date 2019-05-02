

Func LoadReportCHKDSK()
	Local Const $ToolExistCpt = "report_chkdsk"
	Dim $KPRemoveProcessList
	Dim $KPRemoveDesktopList
	Dim $KPRemoveDownloadList

	Local Const $descriptionPattern = Null
	Local Const $reg1 = "(?i)^Report_CHKDSK.*\.exe$"
	Local Const $reg2 = "(?i)^FSS.*\.(exe|txt|lnk)$"
		Local Const $reg1 = "(?i)^Report_CHKDSK.*\.exe$"


	Local Const $arr1[1][2] = [[$ToolExistCpt, $reg1]]
	Local Const $arr2[1][5] = [[$ToolExistCpt, 'file', $descriptionPattern, $reg1, False]]

	_ArrayAdd($KPRemoveProcessList, $arr1)
	_ArrayAdd($KPRemoveDesktopList, $arr2)

EndFunc   ;==>LoadReportCHKDSK

LoadReportCHKDSK()
