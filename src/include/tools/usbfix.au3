
Func LoadUSBFIX()
	Local Const $ToolExistCpt = "usbfix"
	Dim $KPRemoveProcessList
	Dim $KPUninstallNormalyList
	Dim $KPRemoveDesktopList
	Dim $KPRemoveDesktopCommonList
	Dim $KPRemoveDownloadList
	Dim $KPRemoveSoftwareKeyList
	Dim $KPRemoveHomeDriveList
	Dim $KPRemoveProgramFilesList

	Local Const $descriptionPattern = "(?i)^UsbFix"
	Local Const $companyPattern = "(?i)^SosVirus"
	Local Const $reg1 = "(?i)^UsbFix.*\.(exe|lnk|txt)$"
	Local Const $reg2 = "(?i)^Un-UsbFix.exe$"
	Local Const $reg3 = "(?i)^UsbFixQuarantine$"
	Local Const $reg4 = "(?i)^UsbFix.*\.exe$"

	Local Const $arr0[1][2] = [[$ToolExistCpt, $reg4]]
	Local Const $arr1[1][2] = [[$ToolExistCpt, $descriptionPattern]]
	Local Const $arr2[1][3] = [[$ToolExistCpt, $descriptionPattern, $reg2]]
	Local Const $arr3[1][5] = [[$ToolExistCpt, 'file', $companyPattern, $reg1, False]]
	Local Const $arr4[1][5] = [[$ToolExistCpt, 'folder', Null, $reg3, True]]
	Local Const $arr5[1][5] = [[$ToolExistCpt, 'folder', Null, $descriptionPattern, False]]

	_ArrayAdd($KPRemoveProcessList, $arr0)
	_ArrayAdd($KPUninstallNormalyList, $arr2)
	_ArrayAdd($KPRemoveDesktopList, $arr3)
	_ArrayAdd($KPRemoveDesktopCommonList, $arr3)
	_ArrayAdd($KPRemoveDownloadList, $arr3)
	_ArrayAdd($KPRemoveSoftwareKeyList, $arr1)
	_ArrayAdd($KPRemoveHomeDriveList, $arr4)
	_ArrayAdd($KPRemoveHomeDriveList, $arr5)
	_ArrayAdd($KPRemoveProgramFilesList, $arr5)

EndFunc   ;==>RemoveUSBFIX

LoadUSBFIX()