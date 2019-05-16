
Func LoadRstHosts()
	Local Const $sToolExistCpt = "RstHosts"
	Dim $aKPRemoveProcessList
	Dim $aKPRemoveDesktopList
	Dim $aKPRemoveDownloadList
	Dim $aKPRemoveHomeDriveList

	Local Const $sDescriptionPattern = Null
	Local Const $sReg1 = "(?i)^rsthosts.*\.exe$"
	Local Const $sReg2 = "(?i)^RstHosts.*\.txt$"

	Local Const $aArr1[1][3] = [[$sToolExistCpt, $sReg1, False]]
	Local Const $aArr2[1][5] = [[$sToolExistCpt, 'file', $sDescriptionPattern, $sReg1, Null]]
	Local Const $aArr3[1][5] = [[$sToolExistCpt, 'file', $sDescriptionPattern, $sReg2, Null]]

	_ArrayAdd($aKPRemoveProcessList, $aArr1)
	_ArrayAdd($aKPRemoveDesktopList, $aArr2)
	_ArrayAdd($aKPRemoveDownloadList, $aArr2)
	_ArrayAdd($aKPRemoveHomeDriveList, $aArr3)

EndFunc   ;==>LoadRstHosts

LoadRstHosts()
