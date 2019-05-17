

Func LoadMcAfeeStinger()
	Local Const $sToolExistCpt = "McAfee Stinger"

	Dim $aKPRemoveProcessList
	Dim $aKPRemoveDesktopList
	Dim $aKPRemoveDownloadList
	Dim $aKPRemoveHomeDriveList
	Dim $aKPRemoveProgramFilesList


	Local Const $sDescriptionPattern = "(?i)^MCAfee"
	Local Const $sReg1 = "(?i)^stinger.*\.exe$"
	Local Const $sReg2 = "(?i)^stinger.*\.(exe|html)$"
	Local Const $sReg3 = "(?i)^Quarantine$"
	Local Const $sReg4 = "(?i)^stinger$"

	Local Const $aArr1[1][3] = [[$sToolExistCpt, $sReg1, False]]
	Local Const $aArr2[1][5] = [[$sToolExistCpt, 'file', $sDescriptionPattern, $sReg2, False]]
	Local Const $aArr3[1][5] = [[$sToolExistCpt, 'folder', Null, $sReg3, True]]
	Local Const $aArr4[1][5] = [[$sToolExistCpt, 'folder', Null, $sReg4, False]]

	_ArrayAdd($aKPRemoveProcessList, $aArr1)
	_ArrayAdd($aKPRemoveDesktopList, $aArr2)
	_ArrayAdd($aKPRemoveDownloadList, $aArr2)
	_ArrayAdd($aKPRemoveProgramFilesList, $aArr4)

	If FileExists(@HomeDrive & "\Quarantine\Stinger") Then
		_ArrayAdd($aKPRemoveHomeDriveList, $aArr3)
	EndIf


EndFunc   ;==>LoadMcAfeeStinger

LoadMcAfeeStinger()
