
#include "tools_remove.au3"
#include "tools/frst.au3"
#include "tools/zhpdiag.au3"
#include "tools/zhpfix.au3"
#include "tools/mbar.au3"
#include "tools/roguekiller.au3"
#include "tools/adwcleaner.au3"
#include "tools/zhpcleaner.au3"
#include "tools/usbfix.au3"


Func RunRemoveTools()
	RemoveFRST()
	RemoveZHPDiag()
	RemoveZHPFix()
	RemoveZHPCleaner()
	RemoveMBAR()
	RemoveRogueKiller()
	RemoveAdwcleaner()
	RemoveUSBFIX()
EndFunc   ;==>RunRemoveTools
