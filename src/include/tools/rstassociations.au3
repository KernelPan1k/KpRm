
Func LoadRstAssociation()
	Local Const $desciptionPattern = Null
	Local Const $toolExistCpt = "RstAssociations"

	Dim $KPRemoveProcessList
	Dim $KPRemoveDesktopList
	Dim $KPRemoveDownloadList
	Dim $KPRemoveHomeDriveList

	Local Const $reg1 = "(?i)^rstassociations.*\.(exe|scr)$"
	Local Const $reg2 = "(?i)^RstAssociations.*\.txt$"

	Local Const $arr1[1][3] = [[$toolExistCpt, $reg1, False]]
	Local Const $arr2[1][5] = [[$toolExistCpt, 'file', $desciptionPattern, $reg1, False]]
	Local Const $arr3[1][5] = [[$toolExistCpt, 'file', $desciptionPattern, $reg2, False]]

	_ArrayAdd($KPRemoveProcessList, $arr1)
	_ArrayAdd($KPRemoveDesktopList, $arr2)
	_ArrayAdd($KPRemoveDownloadList, $arr2)
	_ArrayAdd($KPRemoveHomeDriveList, $arr3)
EndFunc   ;==>LoadRstAssociation

LoadRstAssociation()
