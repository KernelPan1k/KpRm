
Func LoadAdwcleaner()
	Dim $KPRemoveProcessList
	Dim $KPRemoveDesktopList
	Dim $KPRemoveDownloadList
	Dim $KPRemoveHomeDriveList
	Local Const  $AdwcleanerFixExistCpt = "adwcleaner"
	Local Const $descriptionPattern = "(?i)^AdwCleaner"

	Local Const $arr1[1][2] = [[$AdwcleanerFixExistCpt, $descriptionPattern]]
	Local Const $arr2[1][3] = [[$AdwcleanerFixExistCpt, $descriptionPattern, "(?i)^AdwCleaner.*\.exe$"]]

	_ArrayAdd($KPRemoveProcessList, $arr1)
	_ArrayAdd($KPRemoveDesktopList, $arr2)
	_ArrayAdd($KPRemoveDownloadList, $arr2)
	_ArrayAdd($KPRemoveHomeDriveList, $arr1)

;~ 	If $KPDebug Then logMessage(@CRLF & "- Search AdwCleaner Files -" & @CRLF)


EndFunc   ;==>RemoveAdwcleaner
