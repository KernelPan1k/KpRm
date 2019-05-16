

Func LoadCheckBrowserLnk()

	Local Const $sDescriptionPattern = "(?i)^Alex Dragokas"
	Local Const $sToolExistCpt = "Check Browsers LNK"

	Dim $aKPRemoveProcessList
	Dim $aKPRemoveDesktopList
	Dim $aKPRemoveDownloadList

	Local Const $sReg1 = "(?i)^Check(-|_| )Browsers(-|_| )LNK.*\.exe$"
	Local Const $sReg2 = "(?i)^Check(-|_| )Browsers(-|_| )LNK.*\.(log|exe)$"

	Local Const $aArr1[1][3] = [[$sToolExistCpt, $sReg1, False]]
	Local Const $aArr2[1][5] = [[$sToolExistCpt, 'file', Null, $sReg2, False]]

	_ArrayAdd($aKPRemoveProcessList, $aArr1)
	_ArrayAdd($aKPRemoveDesktopList, $aArr2)
	_ArrayAdd($aKPRemoveDownloadList, $aArr2)
EndFunc   ;==>LoadCheckBrowserLnk

LoadCheckBrowserLnk()

