#cs ----------------------------------------------------------------------------

 AutoIt Version: 3.3.14.5
 Author:         myName

 Script Function:
	Template AutoIt script.

#ce ----------------------------------------------------------------------------

; Script Start - Add your code below here
#include <WinAPIShellEx.au3>
#include <SendMessage.au3>

Func logMessage($message)
	FileWrite(@DesktopDir & "\kp-remover.txt", $message & @CRLF)
EndFunc   ;==>logMessage

Func _Restart_Windows_Explorer()
	; By KaFu

	; Believed to save icon positions just before Shutting down explorer, which comes next
	_WinAPI_ShellChangeNotify($SHCNE_ASSOCCHANGED, 0, 0, 0)

	;Shutting down explorer gracefully
	Local $hSysTray_Handle = DllCall("user32.dll", "HWND", "FindWindow", "str", "Shell_TrayWnd", "str", "")
	If Not IsHWnd($hSysTray_Handle[0]) Then Return SetError(1)

	Local $iPID_Old = WinGetProcess($hSysTray_Handle[0])

	_SendMessage($hSysTray_Handle[0], 0x5B4, 0, 0)

	#cs
	    Local $i_Timer = TimerInit()
	    While IsHWnd($hSysTray_Handle[0])
	        Sleep(10)
	        If TimerDiff($i_Timer) > 5000 Then Return SetError(2)
	    WEnd
	#ce

	Local $i_Timer = TimerInit()
	While ProcessExists($iPID_Old)
		Sleep(10)
		If TimerDiff($i_Timer) > 5000 Then Return SetError(3)
	WEnd

	Sleep(500)

	Return ShellExecute(@WindowsDir & "\Explorer.exe")

EndFunc   ;==>_Restart_Windows_Explorer
