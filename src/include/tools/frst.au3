
Func LoadFRST()
	Local Const $FrstExistCpt = "frst"
	Dim $KPRemoveProcessList
	Dim $KPRemoveDesktopList
	Dim $KPRemoveDesktopFolderList
	Dim $KPRemoveDownloadList
	Dim $KPRemoveDownloadFolderList
	Dim $KPRemoveHomeDriveList

	Local Const $descriptionPattern = "(?i)^Farbar"
	Local Const $regexFRST = "(?i)^FRST"

	Local Const $arr1[1][2] = [[$FrstExistCpt, $regexFRST]]
	Local Const $arr2[1][3] = [[$FrstExistCpt, $descriptionPattern, "(?i)^(FRST|fixlist|fixlog|Addition|Shortcut).*\.(exe|txt)$"]]
	Local Const $arr4[1][2] = [[$FrstExistCpt, "(?i)^FRST-OlderVersion$"]]

	_ArrayAdd($KPRemoveProcessList, $arr1)
	_ArrayAdd($KPRemoveDesktopList, $arr2)
	_ArrayAdd($KPRemoveDownloadList, $arr2)
	_ArrayAdd($KPRemoveDesktopFolderList, $arr4)
	_ArrayAdd($KPRemoveDownloadFolderList, $arr4)
	_ArrayAdd($KPRemoveHomeDriveList, $arr1)

;~ 	If $KPDebug Then logMessage(@CRLF & "- Search FRST Files -" & @CRLF)

EndFunc   ;==>RemoveFRST
