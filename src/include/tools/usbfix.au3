
Func LoadUSBFIX()
	Local Const $UsbFixFixExistCpt = "usbfix"
	Dim $KPRemoveProcessList
	Dim $KPUninstallNormalyList
	Dim $KPRemoveDesktopList
	Dim $KPRemoveDesktopCommonList
	Dim $KPRemoveDownloadList
	Dim $KPRemoveSoftwareKeyList
	Dim $KPRemoveHomeDriveList
	Local Const $descriptionPattern = "(?i)^UsbFix"

	Local Const $arr1[1][2] = [[$UsbFixFixExistCpt, $descriptionPattern]]
	Local Const $arr2[1][3] = [[$UsbFixFixExistCpt, $descriptionPattern, "(?i)^Un-UsbFix.exe$"]]
	Local Const $arr3[1][3] = [[$UsbFixFixExistCpt, $descriptionPattern, "(?i)^UsbFix.*\.(exe|lnk)$"]]
	Local Const $arr4[1][2] = [[$UsbFixFixExistCpt, "(?i)^UsbFixQuarantine$"]]

	_ArrayAdd($KPRemoveProcessList, $arr1)
	_ArrayAdd($KPUninstallNormalyList, $arr2)
	_ArrayAdd($KPRemoveDesktopList, $arr3)
	_ArrayAdd($KPRemoveDesktopCommonList, $arr3)
	_ArrayAdd($KPRemoveDownloadList, $arr3)
	_ArrayAdd($KPRemoveSoftwareKeyList, $arr1)
	_ArrayAdd($KPRemoveHomeDriveList, $arr4)

EndFunc   ;==>RemoveUSBFIX
