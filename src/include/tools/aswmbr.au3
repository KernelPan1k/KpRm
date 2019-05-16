
Func LoadAswMbr()
	Local Const $sToolExistCpt = "AswMBR"
	Dim $aKPRemoveProcessList
	Dim $aKPRemoveDesktopList
	Dim $aKPRemoveDownloadList
	Dim $aKPRemoveRegistryKeysList

	Local Const $sDescriptionPattern = "(?i)^avast"
	Local Const $sReg1 = "(?i)^aswmbr.*\.(exe|txt|lnk)$"
	Local Const $sReg2 = "(?i)^MBR\.dat$"
	Local Const $sReg3 = "(?i)^aswmbr.*\.exe$"

	Local $s64Bit = ""
	If @OSArch = "X64" Then $s64Bit = "64"

	Local Const $aArr1[1][3] = [[$sToolExistCpt, $sReg3, True]]
	Local Const $aArr2[1][5] = [[$sToolExistCpt, 'file', $sDescriptionPattern, $sReg1, False]]
	Local Const $aArr3[1][5] = [[$sToolExistCpt, 'file', Null, $sReg2, False]]
	Local Const $aArr4[1][3] = [[$sToolExistCpt, "HKLM" & $s64Bit & "\SYSTEM\CurrentControlSet\Enum\Root\LEGACY_ASWMBR", True]]

	_ArrayAdd($aKPRemoveProcessList, $aArr1)
	_ArrayAdd($aKPRemoveDesktopList, $aArr2)
	_ArrayAdd($aKPRemoveDesktopList, $aArr3)
	_ArrayAdd($aKPRemoveDownloadList, $aArr2)
	_ArrayAdd($aKPRemoveDownloadList, $aArr3)
	_ArrayAdd($aKPRemoveRegistryKeysList, $aArr4)

EndFunc   ;==>LoadAswMbr

LoadAswMbr()
