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


Func RunRemoveTools()
	RemoveFRST()
	RemoveZHPDiag()
EndFunc   ;==>RunRemoveTools
