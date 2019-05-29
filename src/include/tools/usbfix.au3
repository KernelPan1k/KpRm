
Func LoadUSBFIX()
	Local Const $sToolName = "USBFix"
	Dim $aKPRemoveProcessList
	Dim $aKPUninstallNormalyList
	Dim $aKPRemoveDesktopList
	Dim $aKPRemoveDesktopCommonList
	Dim $aKPRemoveDownloadList
	Dim $aKPRemoveSoftwareKeyList
	Dim $aKPRemoveHomeDriveList
	Dim $aKPRemoveProgramFilesList

	Local Const $sToolReg = "(?i)^UsbFix"
	Local Const $sCompanyName = "(?i)^SosVirus"
	Local Const $sReg1 = "(?i)^UsbFix.*\.(exe|lnk|txt)$"
	Local Const $sReg2 = "(?i)^Un-UsbFix\.exe$"
	Local Const $sReg3 = "(?i)^UsbFixQuarantine$"
	Local Const $sReg4 = "(?i)^UsbFix.*\.exe$"

	Local Const $aArr0[1][3] = [[$sToolName, $sReg4, False]]
	Local Const $aArr1[1][2] = [[$sToolName, $sToolReg]]
	Local Const $aArr2[1][3] = [[$sToolName, $sToolReg, $sReg2]]
	Local Const $aArr3[1][5] = [[$sToolName, 'file', $sCompanyName, $sReg1, False]]
	Local Const $aArr4[1][5] = [[$sToolName, 'folder', Null, $sReg3, True]]
	Local Const $aArr5[1][5] = [[$sToolName, 'folder', Null, $sToolReg, False]]

	_ArrayAdd($aKPRemoveProcessList, $aArr0)
	_ArrayAdd($aKPUninstallNormalyList, $aArr2)
	_ArrayAdd($aKPRemoveDesktopList, $aArr3)
	_ArrayAdd($aKPRemoveDesktopCommonList, $aArr3)
	_ArrayAdd($aKPRemoveDownloadList, $aArr3)
	_ArrayAdd($aKPRemoveSoftwareKeyList, $aArr1)
	_ArrayAdd($aKPRemoveHomeDriveList, $aArr4)
	_ArrayAdd($aKPRemoveHomeDriveList, $aArr5)
	_ArrayAdd($aKPRemoveProgramFilesList, $aArr5)

EndFunc   ;==>LoadUSBFIX

LoadUSBFIX()
