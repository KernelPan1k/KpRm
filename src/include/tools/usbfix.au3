
Func LoadUSBFIX()
	Local Const $sToolExistCpt = "USBFix"
	Dim $aKPRemoveProcessList
	Dim $aKPUninstallNormalyList
	Dim $aKPRemoveDesktopList
	Dim $aKPRemoveDesktopCommonList
	Dim $aKPRemoveDownloadList
	Dim $aKPRemoveSoftwareKeyList
	Dim $aKPRemoveHomeDriveList
	Dim $aKPRemoveProgramFilesList

	Local Const $sDescriptionPattern = "(?i)^UsbFix"
	Local Const $companyPattern = "(?i)^SosVirus"
	Local Const $sReg1 = "(?i)^UsbFix.*\.(exe|lnk|txt)$"
	Local Const $sReg2 = "(?i)^Un-UsbFix\.exe$"
	Local Const $sReg3 = "(?i)^UsbFixQuarantine$"
	Local Const $sReg4 = "(?i)^UsbFix.*\.exe$"

	Local Const $aArr0[1][3] = [[$sToolExistCpt, $sReg4, False]]
	Local Const $aArr1[1][2] = [[$sToolExistCpt, $sDescriptionPattern]]
	Local Const $aArr2[1][3] = [[$sToolExistCpt, $sDescriptionPattern, $sReg2]]
	Local Const $aArr3[1][5] = [[$sToolExistCpt, 'file', $companyPattern, $sReg1, False]]
	Local Const $aArr4[1][5] = [[$sToolExistCpt, 'folder', Null, $sReg3, True]]
	Local Const $aArr5[1][5] = [[$sToolExistCpt, 'folder', Null, $sDescriptionPattern, False]]

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
