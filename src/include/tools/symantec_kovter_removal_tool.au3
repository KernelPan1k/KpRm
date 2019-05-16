

Func LoadSymantecKovterRemovalTool()

	Local Const $sDescriptionPattern = "(?i)^Symantec"
	Local Const $sToolExistCpt = "Symantec Kovter Removal Tool"

	Dim $aKPRemoveProcessList
	Dim $aKPRemoveDesktopList
	Dim $aKPRemoveDownloadList

	Local Const $sReg1 = "(?i)^FixTool.*\.exe$"
	Local Const $sReg2 = "(?i)^FixTool.*\.(log|exe)$"

	Local Const $aArr1[1][3] = [[$sToolExistCpt, $sReg1, False]]
	Local Const $aArr2[1][5] = [[$sToolExistCpt, 'file', $sDescriptionPattern, $sReg2, False]]

	_ArrayAdd($aKPRemoveProcessList, $aArr1)
	_ArrayAdd($aKPRemoveDesktopList, $aArr2)
	_ArrayAdd($aKPRemoveDownloadList, $aArr2)
EndFunc   ;==>LoadSymantecKovterRemovalTool

LoadSymantecKovterRemovalTool()

