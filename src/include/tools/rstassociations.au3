
Func LoadRstAssociation()
	Local Const $sDescriptionPattern = Null
	Local Const $sToolExistCpt = "RstAssociations"

	Dim $aKPRemoveProcessList
	Dim $aKPRemoveDesktopList
	Dim $aKPRemoveDownloadList
	Dim $aKPRemoveHomeDriveList

	Local Const $sReg1 = "(?i)^rstassociations.*\.(exe|scr)$"
	Local Const $sReg2 = "(?i)^RstAssociations.*\.txt$"

	Local Const $aArr1[1][3] = [[$sToolExistCpt, $sReg1, False]]
	Local Const $aArr2[1][5] = [[$sToolExistCpt, 'file', $sDescriptionPattern, $sReg1, False]]
	Local Const $aArr3[1][5] = [[$sToolExistCpt, 'file', $sDescriptionPattern, $sReg2, False]]

	_ArrayAdd($aKPRemoveProcessList, $aArr1)
	_ArrayAdd($aKPRemoveDesktopList, $aArr2)
	_ArrayAdd($aKPRemoveDownloadList, $aArr2)
	_ArrayAdd($aKPRemoveHomeDriveList, $aArr3)
EndFunc   ;==>LoadRstAssociation

LoadRstAssociation()
