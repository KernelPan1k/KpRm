#cs ----------------------------------------------------------------------------

 AutoIt Version: 3.3.14.5
 Author:         myName

 Script Function:
	Template AutoIt script.

#ce ----------------------------------------------------------------------------

; Script Start - Add your code below here

Local Const $files = [_
	@DesktopDir & "\FRST.exe", _
	@DesktopDir & "\FRST(?).exe", _
	@DesktopDir & "\FRST32-??.??.exe", _
	@DesktopDir & "\FRST64-??.??.exe", _
	@DesktopDir & "\fixlist.txt", _
	@DesktopDir & "\FRST.txt", _
	@DesktopDir & "\Addition.txt", _
	@DesktopDir & "\Shortcut.txt" _
]

Local Const $donwnLoadDir = [_
	@UserProfileDir & "\Downloads" & "\FRST.exe", _
	@UserProfileDir & "\Downloads" & "\FRST(?).exe", _
	@UserProfileDir & "\Downloads" & "\FRST32-??.??.exe", _
	@UserProfileDir & "\Downloads" & "\FRST64-??.??.exe" _
]

Local Const $folders = [_
	@HomeDrive & "\FRST" _
]

