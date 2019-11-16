Global $aElementsAtDeleteLater = []
Global $aElementsToKeep = []

Func AddRemoveLater($sElement)
	Dim $aElementsAtDeleteLater
	_ArrayAdd($aElementsAtDeleteLater, $sElement)
EndFunc   ;==>AddRemoveAtRestart

Func AddElementToKeep($sElement)
	Dim $aElementsToKeep
	_ArrayAdd($aElementsToKeep, $sElement)
EndFunc   ;==>AddRemoveAtRestart
