#cs ----------------------------------------------------------------------------

 AutoIt Version: 3.3.14.5
 Author:         myName

 Script Function:
	Template AutoIt script.

#ce ----------------------------------------------------------------------------

; Script Start - Add your code below here

#include "tools_remove.au3"
#include "tools/frst.au3"
#include "tools/zhpdiag.au3"
#include "tools/zhpfix.au3"
#include "tools/mbam.au3"
#include "tools/roguekiller.au3"
#include "tools/adwcleaner.au3"
#include "tools/zhpcleaner.au3"


Func RunRemoveTools()
	RemoveFRST()
	RemoveZHPDiag()
	RemoveZHPFix()
	RemoveZHPCleaner()
	RemoveMBAM()
	RemoveRogueKiller()
	RemoveAdwcleaner()
EndFunc   ;==>RunRemoveTools
