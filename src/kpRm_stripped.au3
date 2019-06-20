#RequireAdmin
FileInstall("C:\Users\IEUser\Desktop\KpRm\src\assets\bug.gif", @TempDir & "\kprm-logo.gif")
If FileExists(@TempDir & "\kprm-tools.xml") Then FileDelete(@TempDir & "\kprm-tools.xml")
FileInstall("C:\Users\IEUser\Desktop\KpRm\src\config\tools.xml", @TempDir & "\kprm-tools.xml")
Global Const $0 = -3
Global Const $1 = 1
Global Const $2 = 2
Global Const $3 = 1
Global Const $4 = 2
Global Const $5 = 1
Global Const $6 = 2
Global Const $7 = 1
Global Const $8 = 0x00040000
Global Const $9 = 0
Global Const $a = 1
Global Const $b = 1
Global Const $c = 0
Global Const $d = 2
Global Const $e = 4096
Global Const $f = 0
Global Const $g = 1
Global Const $h = 2
Global Const $i= 1
Global Const $j = 1
Global Const $k = 2
Global Const $l = 0x00020000
Global Const $m = 0x00040000
Global Const $n = 0x00080000
Global Const $o = 0x01000000
Global Enum $p = 0, $q, $r, $s, $t, $u, $v
Global Const $w = "struct;word Year;word Month;word Dow;word Day;word Hour;word Minute;word Second;word MSeconds;endstruct"
Global Const $x = 2
Global Const $y = 0x10000000
Global Const $0z = 0
Global Const $10 = 0
Global Const $11 = 4
Global Const $12 = 8
Global Const $13 = 16
Global Const $14 = 0
Global Const $15 = 0
Global Const $16 = 1
Global Const $17 = 2
Global Const $18 = 0
Global Const $19 = 1
Global Const $1a = 2
Global Const $1b = 3
Global Const $1c = 4
Global Const $1d = 'struct;dword OSVersionInfoSize;dword MajorVersion;dword MinorVersion;dword BuildNumber;dword PlatformId;wchar CSDVersion[128];endstruct'
Global Const $1e = _1v()
Func _1v()
Local $1f = DllStructCreate($1d)
DllStructSetData($1f, 1, DllStructGetSize($1f))
Local $1g = DllCall('kernel32.dll', 'bool', 'GetVersionExW', 'struct*', $1f)
If @error Or Not $1g[0] Then Return SetError(@error, @extended, 0)
Return BitOR(BitShift(DllStructGetData($1f, 2), -8), DllStructGetData($1f, 3))
EndFunc
Global Const $1h = 0x001D
Global Const $1i = 0x001E
Global Const $1j = 0x001F
Global Const $1k = 0x0020
Global Const $1l = 0x1003
Global Const $1m = 0x0028
Global Const $1n = 0x0029
Global Const $1o = 0x007F
Global Const $1p = 0x0400
Func _2e($1q = 0, $1r = 0, $1s = 0, $1t = '')
If Not $1q Then $1q = 0x0400
Local $1u = 'wstr'
If Not StringStripWS($1t, $3 + $4) Then
$1u = 'ptr'
$1t = 0
EndIf
Local $1g = DllCall('kernel32.dll', 'int', 'GetDateFormatW', 'dword', $1q, 'dword', $1s, 'struct*', $1r, $1u, $1t, 'wstr', '', 'int', 2048)
If @error Or Not $1g[0] Then Return SetError(@error, @extended, '')
Return $1g[5]
EndFunc
Func _2h($1q, $1v)
Local $1g = DllCall('kernel32.dll', 'int', 'GetLocaleInfoW', 'dword', $1q, 'dword', $1v, 'wstr', '', 'int', 2048)
If @error Or Not $1g[0] Then Return SetError(@error + 10, @extended, '')
Return $1g[3]
EndFunc
Func _31($1w, $1x, $1y)
Local $1z[4]
Local $20[4]
Local $21
$1w = StringLeft($1w, 1)
If StringInStr("D,M,Y,w,h,n,s", $1w) = 0 Or $1w = "" Then
Return SetError(1, 0, 0)
EndIf
If Not StringIsInt($1x) Then
Return SetError(2, 0, 0)
EndIf
If Not _37($1y) Then
Return SetError(3, 0, 0)
EndIf
_3g($1y, $20, $1z)
If $1w = "d" Or $1w = "w" Then
If $1w = "w" Then $1x = $1x * 7
$21 = _3j($20[1], $20[2], $20[3]) + $1x
_3l($21, $20[1], $20[2], $20[3])
EndIf
If $1w = "m" Then
$20[2] = $20[2] + $1x
While $20[2] > 12
$20[2] = $20[2] - 12
$20[1] = $20[1] + 1
WEnd
While $20[2] < 1
$20[2] = $20[2] + 12
$20[1] = $20[1] - 1
WEnd
EndIf
If $1w = "y" Then
$20[1] = $20[1] + $1x
EndIf
If $1w = "h" Or $1w = "n" Or $1w = "s" Then
Local $22 = _3w($1z[1], $1z[2], $1z[3]) / 1000
If $1w = "h" Then $22 = $22 + $1x * 3600
If $1w = "n" Then $22 = $22 + $1x * 60
If $1w = "s" Then $22 = $22 + $1x
Local $23 = Int($22 /(24 * 60 * 60))
$22 = $22 - $23 * 24 * 60 * 60
If $22 < 0 Then
$23 = $23 - 1
$22 = $22 + 24 * 60 * 60
EndIf
$21 = _3j($20[1], $20[2], $20[3]) + $23
_3l($21, $20[1], $20[2], $20[3])
_3v($22 * 1000, $1z[1], $1z[2], $1z[3])
EndIf
Local $24 = _3z($20[1])
If $24[$20[2]] < $20[3] Then $20[3] = $24[$20[2]]
$1y = $20[1] & '/' & StringRight("0" & $20[2], 2) & '/' & StringRight("0" & $20[3], 2)
If $1z[0] > 0 Then
If $1z[0] > 2 Then
$1y = $1y & " " & StringRight("0" & $1z[1], 2) & ':' & StringRight("0" & $1z[2], 2) & ':' & StringRight("0" & $1z[3], 2)
Else
$1y = $1y & " " & StringRight("0" & $1z[1], 2) & ':' & StringRight("0" & $1z[2], 2)
EndIf
EndIf
Return $1y
EndFunc
Func _32($25, $26 = Default)
Local Const $27 = 128
If $26 = Default Then $26 = 0
$25 = Int($25)
If $25 < 1 Or $25 > 7 Then Return SetError(1, 0, "")
Local $1r = DllStructCreate($w)
DllStructSetData($1r, "Year", BitAND($26, $27) ? 2007 : 2006)
DllStructSetData($1r, "Month", 1)
DllStructSetData($1r, "Day", $25)
Return _2e(BitAND($26, $k) ? $1p : $1o, $1r, 0, BitAND($26, $j) ? "ddd" : "dddd")
EndFunc
Func _35($28)
If StringIsInt($28) Then
Select
Case Mod($28, 4) = 0 And Mod($28, 100) <> 0
Return 1
Case Mod($28, 400) = 0
Return 1
Case Else
Return 0
EndSelect
EndIf
Return SetError(1, 0, 0)
EndFunc
Func _36($1x)
$1x = Int($1x)
Return $1x >= 1 And $1x <= 12
EndFunc
Func _37($1y)
Local $20[4], $1z[4]
_3g($1y, $20, $1z)
If Not StringIsInt($20[1]) Then Return 0
If Not StringIsInt($20[2]) Then Return 0
If Not StringIsInt($20[3]) Then Return 0
$20[1] = Int($20[1])
$20[2] = Int($20[2])
$20[3] = Int($20[3])
Local $24 = _3z($20[1])
If $20[1] < 1000 Or $20[1] > 2999 Then Return 0
If $20[2] < 1 Or $20[2] > 12 Then Return 0
If $20[3] < 1 Or $20[3] > $24[$20[2]] Then Return 0
If $1z[0] < 1 Then Return 1
If $1z[0] < 2 Then Return 0
If $1z[0] = 2 Then $1z[3] = "00"
If Not StringIsInt($1z[1]) Then Return 0
If Not StringIsInt($1z[2]) Then Return 0
If Not StringIsInt($1z[3]) Then Return 0
$1z[1] = Int($1z[1])
$1z[2] = Int($1z[2])
$1z[3] = Int($1z[3])
If $1z[1] < 0 Or $1z[1] > 23 Then Return 0
If $1z[2] < 0 Or $1z[2] > 59 Then Return 0
If $1z[3] < 0 Or $1z[3] > 59 Then Return 0
Return 1
EndFunc
Func _3f($1y, $1w)
Local $20[4], $1z[4]
Local $29 = "", $2a = ""
Local $2b, $2c, $2d = ""
If Not _37($1y) Then
Return SetError(1, 0, "")
EndIf
If $1w < 0 Or $1w > 5 Or Not IsInt($1w) Then
Return SetError(2, 0, "")
EndIf
_3g($1y, $20, $1z)
Switch $1w
Case 0
$2d = _2h($1p, $1j)
If Not @error And Not($2d = '') Then
$29 = $2d
Else
$29 = "M/d/yyyy"
EndIf
If $1z[0] > 1 Then
$2d = _2h($1p, $1l)
If Not @error And Not($2d = '') Then
$2a = $2d
Else
$2a = "h:mm:ss tt"
EndIf
EndIf
Case 1
$2d = _2h($1p, $1k)
If Not @error And Not($2d = '') Then
$29 = $2d
Else
$29 = "dddd, MMMM dd, yyyy"
EndIf
Case 2
$2d = _2h($1p, $1j)
If Not @error And Not($2d = '') Then
$29 = $2d
Else
$29 = "M/d/yyyy"
EndIf
Case 3
If $1z[0] > 1 Then
$2d = _2h($1p, $1l)
If Not @error And Not($2d = '') Then
$2a = $2d
Else
$2a = "h:mm:ss tt"
EndIf
EndIf
Case 4
If $1z[0] > 1 Then
$2a = "hh:mm"
EndIf
Case 5
If $1z[0] > 1 Then
$2a = "hh:mm:ss"
EndIf
EndSwitch
If $29 <> "" Then
$2d = _2h($1p, $1h)
If Not @error And Not($2d = '') Then
$29 = StringReplace($29, "/", $2d)
EndIf
Local $2e = _3h($20[1], $20[2], $20[3])
$20[3] = StringRight("0" & $20[3], 2)
$20[2] = StringRight("0" & $20[2], 2)
$29 = StringReplace($29, "d", "@")
$29 = StringReplace($29, "m", "#")
$29 = StringReplace($29, "y", "&")
$29 = StringReplace($29, "@@@@", _32($2e, 0))
$29 = StringReplace($29, "@@@", _32($2e, 1))
$29 = StringReplace($29, "@@", $20[3])
$29 = StringReplace($29, "@", StringReplace(StringLeft($20[3], 1), "0", "") & StringRight($20[3], 1))
$29 = StringReplace($29, "####", _3k($20[2], 0))
$29 = StringReplace($29, "###", _3k($20[2], 1))
$29 = StringReplace($29, "##", $20[2])
$29 = StringReplace($29, "#", StringReplace(StringLeft($20[2], 1), "0", "") & StringRight($20[2], 1))
$29 = StringReplace($29, "&&&&", $20[1])
$29 = StringReplace($29, "&&", StringRight($20[1], 2))
EndIf
If $2a <> "" Then
$2d = _2h($1p, $1m)
If Not @error And Not($2d = '') Then
$2b = $2d
Else
$2b = "AM"
EndIf
$2d = _2h($1p, $1n)
If Not @error And Not($2d = '') Then
$2c = $2d
Else
$2c = "PM"
EndIf
$2d = _2h($1p, $1i)
If Not @error And Not($2d = '') Then
$2a = StringReplace($2a, ":", $2d)
EndIf
If StringInStr($2a, "tt") Then
If $1z[1] < 12 Then
$2a = StringReplace($2a, "tt", $2b)
If $1z[1] = 0 Then $1z[1] = 12
Else
$2a = StringReplace($2a, "tt", $2c)
If $1z[1] > 12 Then $1z[1] = $1z[1] - 12
EndIf
EndIf
$1z[1] = StringRight("0" & $1z[1], 2)
$1z[2] = StringRight("0" & $1z[2], 2)
$1z[3] = StringRight("0" & $1z[3], 2)
$2a = StringReplace($2a, "hh", StringFormat("%02d", $1z[1]))
$2a = StringReplace($2a, "h", StringReplace(StringLeft($1z[1], 1), "0", "") & StringRight($1z[1], 1))
$2a = StringReplace($2a, "mm", StringFormat("%02d", $1z[2]))
$2a = StringReplace($2a, "ss", StringFormat("%02d", $1z[3]))
$29 = StringStripWS($29 & " " & $2a, $3 + $4)
EndIf
Return $29
EndFunc
Func _3g($1y, ByRef $2f, ByRef $2g)
Local $2h = StringSplit($1y, " T")
If $2h[0] > 0 Then $2f = StringSplit($2h[1], "/-.")
If $2h[0] > 1 Then
$2g = StringSplit($2h[2], ":")
If UBound($2g) < 4 Then ReDim $2g[4]
Else
Dim $2g[4]
EndIf
If UBound($2f) < 4 Then ReDim $2f[4]
For $2i = 1 To 3
If StringIsInt($2f[$2i]) Then
$2f[$2i] = Int($2f[$2i])
Else
$2f[$2i] = -1
EndIf
If StringIsInt($2g[$2i]) Then
$2g[$2i] = Int($2g[$2i])
Else
$2g[$2i] = 0
EndIf
Next
Return 1
EndFunc
Func _3h($28, $2j, $2k)
If Not _37($28 & "/" & $2j & "/" & $2k) Then
Return SetError(1, 0, "")
EndIf
Local $2l = Int((14 - $2j) / 12)
Local $2m = $28 - $2l
Local $2n = $2j +(12 * $2l) - 2
Local $2o = Mod($2k + $2m + Int($2m / 4) - Int($2m / 100) + Int($2m / 400) + Int((31 * $2n) / 12), 7)
Return $2o + 1
EndFunc
Func _3j($28, $2j, $2k)
If Not _37(StringFormat("%04d/%02d/%02d", $28, $2j, $2k)) Then
Return SetError(1, 0, "")
EndIf
If $2j < 3 Then
$2j = $2j + 12
$28 = $28 - 1
EndIf
Local $2l = Int($28 / 100)
Local $2p = Int($2l / 4)
Local $2q = 2 - $2l + $2p
Local $2r = Int(1461 *($28 + 4716) / 4)
Local $2s = Int(153 *($2j + 1) / 5)
Local $21 = $2q + $2k + $2r + $2s - 1524.5
Return $21
EndFunc
Func _3k($2t, $26 = Default)
If $26 = Default Then $26 = 0
$2t = Int($2t)
If Not _36($2t) Then Return SetError(1, 0, "")
Local $1r = DllStructCreate($w)
DllStructSetData($1r, "Year", @YEAR)
DllStructSetData($1r, "Month", $2t)
DllStructSetData($1r, "Day", 1)
Return _2e(BitAND($26, $k) ? $1p : $1o, $1r, 0, BitAND($26, $j) ? "MMM" : "MMMM")
EndFunc
Func _3l($21, ByRef $28, ByRef $2j, ByRef $2k)
If $21 < 0 Or Not IsNumber($21) Then
Return SetError(1, 0, 0)
EndIf
Local $2u = Int($21 + 0.5)
Local $2v = Int(($2u - 1867216.25) / 36524.25)
Local $2w = Int($2v / 4)
Local $2l = $2u + 1 + $2v - $2w
Local $2p = $2l + 1524
Local $2q = Int(($2p - 122.1) / 365.25)
Local $2o = Int(365.25 * $2q)
Local $2r = Int(($2p - $2o) / 30.6001)
Local $2s = Int(30.6001 * $2r)
$2k = $2p - $2o - $2s
If $2r - 1 < 13 Then
$2j = $2r - 1
Else
$2j = $2r - 13
EndIf
If $2j < 3 Then
$28 = $2q - 4715
Else
$28 = $2q - 4716
EndIf
$28 = StringFormat("%04d", $28)
$2j = StringFormat("%02d", $2j)
$2k = StringFormat("%02d", $2k)
Return $28 & "/" & $2j & "/" & $2k
EndFunc
Func _3o()
Return _3f(@YEAR & "/" & @MON & "/" & @MDAY & " " & @HOUR & ":" & @MIN & ":" & @SEC, 0)
EndFunc
Func _3p()
Return @YEAR & "/" & @MON & "/" & @MDAY & " " & @HOUR & ":" & @MIN & ":" & @SEC
EndFunc
Func _3v($2x, ByRef $2y, ByRef $2z, ByRef $30)
If Number($2x) > 0 Then
$2x = Int($2x / 1000)
$2y = Int($2x / 3600)
$2x = Mod($2x, 3600)
$2z = Int($2x / 60)
$30 = Mod($2x, 60)
Return 1
ElseIf Number($2x) = 0 Then
$2y = 0
$2x = 0
$2z = 0
$30 = 0
Return 1
Else
Return SetError(1, 0, 0)
EndIf
EndFunc
Func _3w($2y = @HOUR, $2z = @MIN, $30 = @SEC)
If StringIsInt($2y) And StringIsInt($2z) And StringIsInt($30) Then
Local $2x = 1000 *((3600 * $2y) +(60 * $2z) + $30)
Return $2x
Else
Return SetError(1, 0, 0)
EndIf
EndFunc
Func _3z($28)
Local $31 = [12, 31,(_35($28) ? 29 : 28), 31, 30, 31, 30, 31, 31, 30, 31, 30, 31]
Return $31
EndFunc
Func _51($32, $33, $34 = 0, $35 = 0, $36 = 0, $37 = "wparam", $38 = "lparam", $39 = "lresult")
Local $3a = DllCall("user32.dll", $39, "SendMessageW", "hwnd", $32, "uint", $33, $37, $34, $38, $35)
If @error Then Return SetError(@error, @extended, "")
If $36 >= 0 And $36 <= 4 Then Return $3a[$36]
Return $3a
EndFunc
Global Const $3b = Ptr(-1)
Global Const $3c = Ptr(-1)
Global Const $3d = 0x0100
Global Const $3e = 0x2000
Global Const $3f = 0x8000
Global Const $3g = BitShift($3d, 8)
Global Const $3h = BitShift($3e, 8)
Global Const $3i = BitShift($3f, 8)
Global Const $3j = 0x8000000
Func _d0($3k, $3l)
Local $3a = DllCall("user32.dll", "hwnd", "FindWindowW", "wstr", $3k, "wstr", $3l)
If @error Then Return SetError(@error, @extended, 0)
Return $3a[0]
EndFunc
Func _hf($3m, $1s, $3n = 0, $3o = 0)
Local $3p = 'dword_ptr', $3q = 'dword_ptr'
If IsString($3n) Then
$3p = 'wstr'
EndIf
If IsString($3o) Then
$3q = 'wstr'
EndIf
DllCall('shell32.dll', 'none', 'SHChangeNotify', 'long', $3m, 'uint', $1s, $3p, $3n, $3q, $3o)
If @error Then Return SetError(@error, @extended, 0)
Return 1
EndFunc
Func _l4($3r, $3s = '')
Local $1g = DllCall('kernel32.dll', 'uint', 'GetTempFileNameW', 'wstr', $3r, 'wstr', $3s, 'uint', 0, 'wstr', '')
If @error Or Not $1g[0] Then Return SetError(@error + 10, @extended, '')
Return $1g[4]
EndFunc
Global Const $3t = 11
Global $3u[$3t]
Global Const $3v = "struct;uint Mask;int Item;int SubItem;uint State;uint StateMask;ptr Text;int TextMax;int Image;lparam Param;" & "int Indent;int GroupID;uint Columns;ptr pColumns;ptr piColFmt;int iGroup;endstruct"
#Au3Stripper_Ignore_Funcs=__ArrayDisplay_SortCallBack
Func __ArrayDisplay_SortCallBack($3w, $3x, $32)
If $3u[3] = $3u[4] Then
If Not $3u[7] Then
$3u[5] *= -1
$3u[7] = 1
EndIf
Else
$3u[7] = 1
EndIf
$3u[6] = $3u[3]
Local $3y = _vr($32, $3w, $3u[3])
Local $3z = _vr($32, $3x, $3u[3])
If $3u[8] = 1 Then
If(StringIsFloat($3y) Or StringIsInt($3y)) Then $3y = Number($3y)
If(StringIsFloat($3z) Or StringIsInt($3z)) Then $3z = Number($3z)
EndIf
Local $40
If $3u[8] < 2 Then
$40 = 0
If $3y < $3z Then
$40 = -1
ElseIf $3y > $3z Then
$40 = 1
EndIf
Else
$40 = DllCall('shlwapi.dll', 'int', 'StrCmpLogicalW', 'wstr', $3y, 'wstr', $3z)[0]
EndIf
$40 = $40 * $3u[5]
Return $40
EndFunc
Func _vr($32, $41, $42 = 0)
Local $43 = DllStructCreate("wchar Text[4096]")
Local $44 = DllStructGetPtr($43)
Local $45 = DllStructCreate($3v)
DllStructSetData($45, "SubItem", $42)
DllStructSetData($45, "TextMax", 4096)
DllStructSetData($45, "Text", $44)
If IsHWnd($32) Then
DllCall("user32.dll", "lresult", "SendMessageW", "hwnd", $32, "uint", 0x1073, "wparam", $41, "struct*", $45)
Else
Local $46 = DllStructGetPtr($45)
GUICtrlSendMsg($32, 0x1073, $41, $46)
EndIf
Return DllStructGetData($43, "Text")
EndFunc
Global Enum $47, $48, $49, $4a, $4b, $4c, $4d, $4e
Func _vv(ByRef $4f, $4g, $4h = 0, $4i = "|", $4j = @CRLF, $4k = $47)
If $4h = Default Then $4h = 0
If $4i = Default Then $4i = "|"
If $4j = Default Then $4j = @CRLF
If $4k = Default Then $4k = $47
If Not IsArray($4f) Then Return SetError(1, 0, -1)
Local $4l = UBound($4f, $g)
Local $4m = 0
Switch $4k
Case $49
$4m = Int
Case $4a
$4m = Number
Case $4b
$4m = Ptr
Case $4c
$4m = Hwnd
Case $4d
$4m = String
Case $4e
$4m = "Boolean"
EndSwitch
Switch UBound($4f, $f)
Case 1
If $4k = $48 Then
ReDim $4f[$4l + 1]
$4f[$4l] = $4g
Return $4l
EndIf
If IsArray($4g) Then
If UBound($4g, $f) <> 1 Then Return SetError(5, 0, -1)
$4m = 0
Else
Local $4n = StringSplit($4g, $4i, $6 + $5)
If UBound($4n, $g) = 1 Then
$4n[0] = $4g
EndIf
$4g = $4n
EndIf
Local $4o = UBound($4g, $g)
ReDim $4f[$4l + $4o]
For $4p = 0 To $4o - 1
If String($4m) = "Boolean" Then
Switch $4g[$4p]
Case "True", "1"
$4f[$4l + $4p] = True
Case "False", "0", ""
$4f[$4l + $4p] = False
EndSwitch
ElseIf IsFunc($4m) Then
$4f[$4l + $4p] = $4m($4g[$4p])
Else
$4f[$4l + $4p] = $4g[$4p]
EndIf
Next
Return $4l + $4o - 1
Case 2
Local $4q = UBound($4f, $h)
If $4h < 0 Or $4h > $4q - 1 Then Return SetError(4, 0, -1)
Local $4r, $4s = 0, $4t
If IsArray($4g) Then
If UBound($4g, $f) <> 2 Then Return SetError(5, 0, -1)
$4r = UBound($4g, $g)
$4s = UBound($4g, $h)
$4m = 0
Else
Local $4u = StringSplit($4g, $4j, $6 + $5)
$4r = UBound($4u, $g)
Local $4n[$4r][0], $4v
For $4p = 0 To $4r - 1
$4v = StringSplit($4u[$4p], $4i, $6 + $5)
$4t = UBound($4v)
If $4t > $4s Then
$4s = $4t
ReDim $4n[$4r][$4s]
EndIf
For $4w = 0 To $4t - 1
$4n[$4p][$4w] = $4v[$4w]
Next
Next
$4g = $4n
EndIf
If UBound($4g, $h) + $4h > UBound($4f, $h) Then Return SetError(3, 0, -1)
ReDim $4f[$4l + $4r][$4q]
For $4x = 0 To $4r - 1
For $4w = 0 To $4q - 1
If $4w < $4h Then
$4f[$4x + $4l][$4w] = ""
ElseIf $4w - $4h > $4s - 1 Then
$4f[$4x + $4l][$4w] = ""
Else
If String($4m) = "Boolean" Then
Switch $4g[$4x][$4w - $4h]
Case "True", "1"
$4f[$4x + $4l][$4w] = True
Case "False", "0", ""
$4f[$4x + $4l][$4w] = False
EndSwitch
ElseIf IsFunc($4m) Then
$4f[$4x + $4l][$4w] = $4m($4g[$4x][$4w - $4h])
Else
$4f[$4x + $4l][$4w] = $4g[$4x][$4w - $4h]
EndIf
EndIf
Next
Next
Case Else
Return SetError(2, 0, -1)
EndSwitch
Return UBound($4f, $g) - 1
EndFunc
Func _w0(ByRef $4y, Const ByRef $4z, $4h = 0)
If $4h = Default Then $4h = 0
If Not IsArray($4y) Then Return SetError(1, 0, -1)
If Not IsArray($4z) Then Return SetError(2, 0, -1)
Local $50 = UBound($4y, $f)
Local $51 = UBound($4z, $f)
Local $52 = UBound($4y, $g)
Local $53 = UBound($4z, $g)
If $4h < 0 Or $4h > $53 - 1 Then Return SetError(6, 0, -1)
Switch $50
Case 1
If $51 <> 1 Then Return SetError(4, 0, -1)
ReDim $4y[$52 + $53 - $4h]
For $4p = $4h To $53 - 1
$4y[$52 + $4p - $4h] = $4z[$4p]
Next
Case 2
If $51 <> 2 Then Return SetError(4, 0, -1)
Local $54 = UBound($4y, $h)
If UBound($4z, $h) <> $54 Then Return SetError(5, 0, -1)
ReDim $4y[$52 + $53 - $4h][$54]
For $4p = $4h To $53 - 1
For $4w = 0 To $54 - 1
$4y[$52 + $4p - $4h][$4w] = $4z[$4p][$4w]
Next
Next
Case Else
Return SetError(3, 0, -1)
EndSwitch
Return UBound($4y, $g)
EndFunc
Func _we(Const ByRef $4f, $4g, $4h = 0, $55 = 0, $56 = 0, $57 = 0, $58 = 1, $42 = -1, $59 = False)
If $4h = Default Then $4h = 0
If $55 = Default Then $55 = 0
If $56 = Default Then $56 = 0
If $57 = Default Then $57 = 0
If $58 = Default Then $58 = 1
If $42 = Default Then $42 = -1
If $59 = Default Then $59 = False
If Not IsArray($4f) Then Return SetError(1, 0, -1)
Local $4l = UBound($4f) - 1
If $4l = -1 Then Return SetError(3, 0, -1)
Local $4q = UBound($4f, $h) - 1
Local $5a = False
If $57 = 2 Then
$57 = 0
$5a = True
EndIf
If $59 Then
If UBound($4f, $f) = 1 Then Return SetError(5, 0, -1)
If $55 < 1 Or $55 > $4q Then $55 = $4q
If $4h < 0 Then $4h = 0
If $4h > $55 Then Return SetError(4, 0, -1)
Else
If $55 < 1 Or $55 > $4l Then $55 = $4l
If $4h < 0 Then $4h = 0
If $4h > $55 Then Return SetError(4, 0, -1)
EndIf
Local $5b = 1
If Not $58 Then
Local $5c = $4h
$4h = $55
$55 = $5c
$5b = -1
EndIf
Switch UBound($4f, $f)
Case 1
If Not $57 Then
If Not $56 Then
For $4p = $4h To $55 Step $5b
If $5a And VarGetType($4f[$4p]) <> VarGetType($4g) Then ContinueLoop
If $4f[$4p] = $4g Then Return $4p
Next
Else
For $4p = $4h To $55 Step $5b
If $5a And VarGetType($4f[$4p]) <> VarGetType($4g) Then ContinueLoop
If $4f[$4p] == $4g Then Return $4p
Next
EndIf
Else
For $4p = $4h To $55 Step $5b
If $57 = 3 Then
If StringRegExp($4f[$4p], $4g) Then Return $4p
Else
If StringInStr($4f[$4p], $4g, $56) > 0 Then Return $4p
EndIf
Next
EndIf
Case 2
Local $5d
If $59 Then
$5d = $4l
If $42 > $5d Then $42 = $5d
If $42 < 0 Then
$42 = 0
Else
$5d = $42
EndIf
Else
$5d = $4q
If $42 > $5d Then $42 = $5d
If $42 < 0 Then
$42 = 0
Else
$5d = $42
EndIf
EndIf
For $4w = $42 To $5d
If Not $57 Then
If Not $56 Then
For $4p = $4h To $55 Step $5b
If $59 Then
If $5a And VarGetType($4f[$4w][$4p]) <> VarGetType($4g) Then ContinueLoop
If $4f[$4w][$4p] = $4g Then Return $4p
Else
If $5a And VarGetType($4f[$4p][$4w]) <> VarGetType($4g) Then ContinueLoop
If $4f[$4p][$4w] = $4g Then Return $4p
EndIf
Next
Else
For $4p = $4h To $55 Step $5b
If $59 Then
If $5a And VarGetType($4f[$4w][$4p]) <> VarGetType($4g) Then ContinueLoop
If $4f[$4w][$4p] == $4g Then Return $4p
Else
If $5a And VarGetType($4f[$4p][$4w]) <> VarGetType($4g) Then ContinueLoop
If $4f[$4p][$4w] == $4g Then Return $4p
EndIf
Next
EndIf
Else
For $4p = $4h To $55 Step $5b
If $57 = 3 Then
If $59 Then
If StringRegExp($4f[$4w][$4p], $4g) Then Return $4p
Else
If StringRegExp($4f[$4p][$4w], $4g) Then Return $4p
EndIf
Else
If $59 Then
If StringInStr($4f[$4w][$4p], $4g, $56) > 0 Then Return $4p
Else
If StringInStr($4f[$4p][$4w], $4g, $56) > 0 Then Return $4p
EndIf
EndIf
Next
EndIf
Next
Case Else
Return SetError(2, 0, -1)
EndSwitch
Return SetError(6, 0, -1)
EndFunc
Func _wj(ByRef $4f, $5e, $5f, $5g = True)
If $5e > $5f Then Return
Local $5h = $5f - $5e + 1
Local $4p, $4w, $5i, $5j, $5k, $5l, $5m, $5n
If $5h < 45 Then
If $5g Then
$4p = $5e
While $4p < $5f
$4w = $4p
$5j = $4f[$4p + 1]
While $5j < $4f[$4w]
$4f[$4w + 1] = $4f[$4w]
$4w -= 1
If $4w + 1 = $5e Then ExitLoop
WEnd
$4f[$4w + 1] = $5j
$4p += 1
WEnd
Else
While 1
If $5e >= $5f Then Return 1
$5e += 1
If $4f[$5e] < $4f[$5e - 1] Then ExitLoop
WEnd
While 1
$5i = $5e
$5e += 1
If $5e > $5f Then ExitLoop
$5l = $4f[$5i]
$5m = $4f[$5e]
If $5l < $5m Then
$5m = $5l
$5l = $4f[$5e]
EndIf
$5i -= 1
While $5l < $4f[$5i]
$4f[$5i + 2] = $4f[$5i]
$5i -= 1
WEnd
$4f[$5i + 2] = $5l
While $5m < $4f[$5i]
$4f[$5i + 1] = $4f[$5i]
$5i -= 1
WEnd
$4f[$5i + 1] = $5m
$5e += 1
WEnd
$5n = $4f[$5f]
$5f -= 1
While $5n < $4f[$5f]
$4f[$5f + 1] = $4f[$5f]
$5f -= 1
WEnd
$4f[$5f + 1] = $5n
EndIf
Return 1
EndIf
Local $5o = BitShift($5h, 3) + BitShift($5h, 6) + 1
Local $5p, $5q, $5r, $5s, $5t, $5u
$5r = Ceiling(($5e + $5f) / 2)
$5q = $5r - $5o
$5p = $5q - $5o
$5s = $5r + $5o
$5t = $5s + $5o
If $4f[$5q] < $4f[$5p] Then
$5u = $4f[$5q]
$4f[$5q] = $4f[$5p]
$4f[$5p] = $5u
EndIf
If $4f[$5r] < $4f[$5q] Then
$5u = $4f[$5r]
$4f[$5r] = $4f[$5q]
$4f[$5q] = $5u
If $5u < $4f[$5p] Then
$4f[$5q] = $4f[$5p]
$4f[$5p] = $5u
EndIf
EndIf
If $4f[$5s] < $4f[$5r] Then
$5u = $4f[$5s]
$4f[$5s] = $4f[$5r]
$4f[$5r] = $5u
If $5u < $4f[$5q] Then
$4f[$5r] = $4f[$5q]
$4f[$5q] = $5u
If $5u < $4f[$5p] Then
$4f[$5q] = $4f[$5p]
$4f[$5p] = $5u
EndIf
EndIf
EndIf
If $4f[$5t] < $4f[$5s] Then
$5u = $4f[$5t]
$4f[$5t] = $4f[$5s]
$4f[$5s] = $5u
If $5u < $4f[$5r] Then
$4f[$5s] = $4f[$5r]
$4f[$5r] = $5u
If $5u < $4f[$5q] Then
$4f[$5r] = $4f[$5q]
$4f[$5q] = $5u
If $5u < $4f[$5p] Then
$4f[$5q] = $4f[$5p]
$4f[$5p] = $5u
EndIf
EndIf
EndIf
EndIf
Local $5v = $5e
Local $5w = $5f
If(($4f[$5p] <> $4f[$5q]) And($4f[$5q] <> $4f[$5r]) And($4f[$5r] <> $4f[$5s]) And($4f[$5s] <> $4f[$5t])) Then
Local $5x = $4f[$5q]
Local $5y = $4f[$5s]
$4f[$5q] = $4f[$5e]
$4f[$5s] = $4f[$5f]
Do
$5v += 1
Until $4f[$5v] >= $5x
Do
$5w -= 1
Until $4f[$5w] <= $5y
$5i = $5v
While $5i <= $5w
$5k = $4f[$5i]
If $5k < $5x Then
$4f[$5i] = $4f[$5v]
$4f[$5v] = $5k
$5v += 1
ElseIf $5k > $5y Then
While $4f[$5w] > $5y
$5w -= 1
If $5w + 1 = $5i Then ExitLoop 2
WEnd
If $4f[$5w] < $5x Then
$4f[$5i] = $4f[$5v]
$4f[$5v] = $4f[$5w]
$5v += 1
Else
$4f[$5i] = $4f[$5w]
EndIf
$4f[$5w] = $5k
$5w -= 1
EndIf
$5i += 1
WEnd
$4f[$5e] = $4f[$5v - 1]
$4f[$5v - 1] = $5x
$4f[$5f] = $4f[$5w + 1]
$4f[$5w + 1] = $5y
_wj($4f, $5e, $5v - 2, True)
_wj($4f, $5w + 2, $5f, False)
If($5v < $5p) And($5t < $5w) Then
While $4f[$5v] = $5x
$5v += 1
WEnd
While $4f[$5w] = $5y
$5w -= 1
WEnd
$5i = $5v
While $5i <= $5w
$5k = $4f[$5i]
If $5k = $5x Then
$4f[$5i] = $4f[$5v]
$4f[$5v] = $5k
$5v += 1
ElseIf $5k = $5y Then
While $4f[$5w] = $5y
$5w -= 1
If $5w + 1 = $5i Then ExitLoop 2
WEnd
If $4f[$5w] = $5x Then
$4f[$5i] = $4f[$5v]
$4f[$5v] = $5x
$5v += 1
Else
$4f[$5i] = $4f[$5w]
EndIf
$4f[$5w] = $5k
$5w -= 1
EndIf
$5i += 1
WEnd
EndIf
_wj($4f, $5v, $5w, False)
Else
Local $5z = $4f[$5r]
$5i = $5v
While $5i <= $5w
If $4f[$5i] = $5z Then
$5i += 1
ContinueLoop
EndIf
$5k = $4f[$5i]
If $5k < $5z Then
$4f[$5i] = $4f[$5v]
$4f[$5v] = $5k
$5v += 1
Else
While $4f[$5w] > $5z
$5w -= 1
WEnd
If $4f[$5w] < $5z Then
$4f[$5i] = $4f[$5v]
$4f[$5v] = $4f[$5w]
$5v += 1
Else
$4f[$5i] = $5z
EndIf
$4f[$5w] = $5k
$5w -= 1
EndIf
$5i += 1
WEnd
_wj($4f, $5e, $5v - 1, True)
_wj($4f, $5w + 1, $5f, False)
EndIf
EndFunc
Func _wm(Const ByRef $4f, $60 = "|", $61 = -1, $62 = -1, $4j = @CRLF, $63 = -1, $64 = -1)
If $60 = Default Then $60 = "|"
If $4j = Default Then $4j = @CRLF
If $61 = Default Then $61 = -1
If $62 = Default Then $62 = -1
If $63 = Default Then $63 = -1
If $64 = Default Then $64 = -1
If Not IsArray($4f) Then Return SetError(1, 0, -1)
Local $4l = UBound($4f, $g) - 1
If $61 = -1 Then $61 = 0
If $62 = -1 Then $62 = $4l
If $61 < -1 Or $62 < -1 Then Return SetError(3, 0, -1)
If $61 > $4l Or $62 > $4l Then Return SetError(3, 0, "")
If $61 > $62 Then Return SetError(4, 0, -1)
Local $65 = ""
Switch UBound($4f, $f)
Case 1
For $4p = $61 To $62
$65 &= $4f[$4p] & $60
Next
Return StringTrimRight($65, StringLen($60))
Case 2
Local $4q = UBound($4f, $h) - 1
If $63 = -1 Then $63 = 0
If $64 = -1 Then $64 = $4q
If $63 < -1 Or $64 < -1 Then Return SetError(5, 0, -1)
If $63 > $4q Or $64 > $4q Then Return SetError(5, 0, -1)
If $63 > $64 Then Return SetError(6, 0, -1)
For $4p = $61 To $62
For $4w = $63 To $64
$65 &= $4f[$4p][$4w] & $60
Next
$65 = StringTrimRight($65, StringLen($60)) & $4j
Next
Return StringTrimRight($65, StringLen($4j))
Case Else
Return SetError(2, 0, -1)
EndSwitch
Return 1
EndFunc
Func _x1($3r, $66 = "*", $67 = $0z, $68 = False)
Local $69 = "|", $6a = "", $6b = "", $6c = ""
$3r = StringRegExpReplace($3r, "[\\/]+$", "") & "\"
If $67 = Default Then $67 = $0z
If $68 Then $6c = $3r
If $66 = Default Then $66 = "*"
If Not FileExists($3r) Then Return SetError(1, 0, 0)
If StringRegExp($66, "[\\/:><\|]|(?s)^\s*$") Then Return SetError(2, 0, 0)
If Not($67 = 0 Or $67 = 1 Or $67 = 2) Then Return SetError(3, 0, 0)
Local $6d = FileFindFirstFile($3r & $66)
If @error Then Return SetError(4, 0, 0)
While 1
$6b = FileFindNextFile($6d)
If @error Then ExitLoop
If($67 + @extended = 2) Then ContinueLoop
$6a &= $69 & $6c & $6b
WEnd
FileClose($6d)
If $6a = "" Then Return SetError(4, 0, 0)
Return StringSplit(StringTrimLeft($6a, 1), $69)
EndFunc
Func _x2($3r, $6e = "*", $36 = $10, $6f = $14, $6g = $15, $6h = $16)
If Not FileExists($3r) Then Return SetError(1, 1, "")
If $6e = Default Then $6e = "*"
If $36 = Default Then $36 = $10
If $6f = Default Then $6f = $14
If $6g = Default Then $6g = $15
If $6h = Default Then $6h = $16
If $6f > 1 Or Not IsInt($6f) Then Return SetError(1, 6, "")
Local $6i = False
If StringLeft($3r, 4) == "\\?\" Then
$6i = True
EndIf
Local $6j = ""
If StringRight($3r, 1) = "\" Then
$6j = "\"
Else
$3r = $3r & "\"
EndIf
Local $6k[100] = [1]
$6k[1] = $3r
Local $6l = 0, $6m = ""
If BitAND($36, $11) Then
$6l += 2
$6m &= "H"
$36 -= $11
EndIf
If BitAND($36, $12) Then
$6l += 4
$6m &= "S"
$36 -= $12
EndIf
Local $6n = 0
If BitAND($36, $13) Then
$6n = 0x400
$36 -= $13
EndIf
Local $6o = 0
If $6f < 0 Then
StringReplace($3r, "\", "", 0, $2)
$6o = @extended - $6f
EndIf
Local $6p = "", $6q = "", $6r = "*"
Local $6s = StringSplit($6e, "|")
Switch $6s[0]
Case 3
$6q = $6s[3]
ContinueCase
Case 2
$6p = $6s[2]
ContinueCase
Case 1
$6r = $6s[1]
EndSwitch
Local $6t = ".+"
If $6r <> "*" Then
If Not _x5($6t, $6r) Then Return SetError(1, 2, "")
EndIf
Local $6u = ".+"
Switch $36
Case 0
Switch $6f
Case 0
$6u = $6t
EndSwitch
Case 2
$6u = $6t
EndSwitch
Local $6v = ":"
If $6p <> "" Then
If Not _x5($6v, $6p) Then Return SetError(1, 3, "")
EndIf
Local $6w = ":"
If $6f Then
If $6q Then
If Not _x5($6w, $6q) Then Return SetError(1, 4, "")
EndIf
If $36 = 2 Then
$6w = $6v
EndIf
Else
$6w = $6v
EndIf
If Not($36 = 0 Or $36 = 1 Or $36 = 2) Then Return SetError(1, 5, "")
If Not($6g = 0 Or $6g = 1 Or $6g = 2) Then Return SetError(1, 7, "")
If Not($6h = 0 Or $6h = 1 Or $6h = 2) Then Return SetError(1, 8, "")
If $6n Then
Local $6x = DllStructCreate("struct;align 4;dword FileAttributes;uint64 CreationTime;uint64 LastAccessTime;uint64 LastWriteTime;" & "dword FileSizeHigh;dword FileSizeLow;dword Reserved0;dword Reserved1;wchar FileName[260];wchar AlternateFileName[14];endstruct")
Local $6y = DllOpen('kernel32.dll'), $6z
EndIf
Local $70[100] = [0]
Local $71 = $70, $72 = $70, $73 = $70
Local $74 = False, $6d = 0, $75 = "", $76 = "", $77 = ""
Local $78 = 0, $79 = ''
Local $7a[100][2] = [[0, 0]]
While $6k[0] > 0
$75 = $6k[$6k[0]]
$6k[0] -= 1
Switch $6h
Case 1
$77 = StringReplace($75, $3r, "")
Case 2
If $6i Then
$77 = StringTrimLeft($75, 4)
Else
$77 = $75
EndIf
EndSwitch
If $6n Then
$6z = DllCall($6y, 'handle', 'FindFirstFileW', 'wstr', $75 & "*", 'struct*', $6x)
If @error Or Not $6z[0] Then
ContinueLoop
EndIf
$6d = $6z[0]
Else
$6d = FileFindFirstFile($75 & "*")
If $6d = -1 Then
ContinueLoop
EndIf
EndIf
If $36 = 0 And $6g And $6h Then
_x4($7a, $77, $71[0] + 1)
EndIf
$79 = ''
While 1
If $6n Then
$6z = DllCall($6y, 'int', 'FindNextFileW', 'handle', $6d, 'struct*', $6x)
If @error Or Not $6z[0] Then
ExitLoop
EndIf
$76 = DllStructGetData($6x, "FileName")
If $76 = ".." Then
ContinueLoop
EndIf
$78 = DllStructGetData($6x, "FileAttributes")
If $6l And BitAND($78, $6l) Then
ContinueLoop
EndIf
If BitAND($78, $6n) Then
ContinueLoop
EndIf
$74 = False
If BitAND($78, 16) Then
$74 = True
EndIf
Else
$74 = False
$76 = FileFindNextFile($6d, 1)
If @error Then
ExitLoop
EndIf
$79 = @extended
If StringInStr($79, "D") Then
$74 = True
EndIf
If StringRegExp($79, "[" & $6m & "]") Then
ContinueLoop
EndIf
EndIf
If $74 Then
Select
Case $6f < 0
StringReplace($75, "\", "", 0, $2)
If @extended < $6o Then
ContinueCase
EndIf
Case $6f = 1
If Not StringRegExp($76, $6w) Then
_x4($6k, $75 & $76 & "\")
EndIf
EndSelect
EndIf
If $6g Then
If $74 Then
If StringRegExp($76, $6u) And Not StringRegExp($76, $6w) Then
_x4($73, $77 & $76 & $6j)
EndIf
Else
If StringRegExp($76, $6t) And Not StringRegExp($76, $6v) Then
If $75 = $3r Then
_x4($72, $77 & $76)
Else
_x4($71, $77 & $76)
EndIf
EndIf
EndIf
Else
If $74 Then
If $36 <> 1 And StringRegExp($76, $6u) And Not StringRegExp($76, $6w) Then
_x4($70, $77 & $76 & $6j)
EndIf
Else
If $36 <> 2 And StringRegExp($76, $6t) And Not StringRegExp($76, $6v) Then
_x4($70, $77 & $76)
EndIf
EndIf
EndIf
WEnd
If $6n Then
DllCall($6y, 'int', 'FindClose', 'ptr', $6d)
Else
FileClose($6d)
EndIf
WEnd
If $6n Then
DllClose($6y)
EndIf
If $6g Then
Switch $36
Case 2
If $73[0] = 0 Then Return SetError(1, 9, "")
ReDim $73[$73[0] + 1]
$70 = $73
_wj($70, 1, $70[0])
Case 1
If $72[0] = 0 And $71[0] = 0 Then Return SetError(1, 9, "")
If $6h = 0 Then
_x3($70, $72, $71)
_wj($70, 1, $70[0])
Else
_x3($70, $72, $71, 1)
EndIf
Case 0
If $72[0] = 0 And $73[0] = 0 Then Return SetError(1, 9, "")
If $6h = 0 Then
_x3($70, $72, $71)
$70[0] += $73[0]
ReDim $73[$73[0] + 1]
_w0($70, $73, 1)
_wj($70, 1, $70[0])
Else
Local $70[$71[0] + $72[0] + $73[0] + 1]
$70[0] = $71[0] + $72[0] + $73[0]
_wj($72, 1, $72[0])
For $4p = 1 To $72[0]
$70[$4p] = $72[$4p]
Next
Local $7b = $72[0] + 1
_wj($73, 1, $73[0])
Local $7c = ""
For $4p = 1 To $73[0]
$70[$7b] = $73[$4p]
$7b += 1
If $6j Then
$7c = $73[$4p]
Else
$7c = $73[$4p] & "\"
EndIf
Local $7d = 0, $7e = 0
For $4w = 1 To $7a[0][0]
If $7c = $7a[$4w][0] Then
$7e = $7a[$4w][1]
If $4w = $7a[0][0] Then
$7d = $71[0]
Else
$7d = $7a[$4w + 1][1] - 1
EndIf
If $6g = 1 Then
_wj($71, $7e, $7d)
EndIf
For $5i = $7e To $7d
$70[$7b] = $71[$5i]
$7b += 1
Next
ExitLoop
EndIf
Next
Next
EndIf
EndSwitch
Else
If $70[0] = 0 Then Return SetError(1, 9, "")
ReDim $70[$70[0] + 1]
EndIf
Return $70
EndFunc
Func _x3(ByRef $7f, $7g, $7h, $6g = 0)
ReDim $7g[$7g[0] + 1]
If $6g = 1 Then _wj($7g, 1, $7g[0])
$7f = $7g
$7f[0] += $7h[0]
ReDim $7h[$7h[0] + 1]
If $6g = 1 Then _wj($7h, 1, $7h[0])
_w0($7f, $7h, 1)
EndFunc
Func _x4(ByRef $7i, $7j, $7k = -1)
If $7k = -1 Then
$7i[0] += 1
If UBound($7i) <= $7i[0] Then ReDim $7i[UBound($7i) * 2]
$7i[$7i[0]] = $7j
Else
$7i[0][0] += 1
If UBound($7i) <= $7i[0][0] Then ReDim $7i[UBound($7i) * 2][2]
$7i[$7i[0][0]][0] = $7j
$7i[$7i[0][0]][1] = $7k
EndIf
EndFunc
Func _x5(ByRef $6e, $7l)
If StringRegExp($7l, "\\|/|:|\<|\>|\|") Then Return 0
$7l = StringReplace(StringStripWS(StringRegExpReplace($7l, "\s*;\s*", ";"), BitOR($3, $4)), ";", "|")
$7l = StringReplace(StringReplace(StringRegExpReplace($7l, "[][$^.{}()+\-]", "\\$0"), "?", "."), "*", ".*?")
$6e = "(?i)^(" & $7l & ")\z"
Return 1
EndFunc
Func _xe($3r, ByRef $7m, ByRef $7n, ByRef $6b, ByRef $7o)
Local $4f = StringRegExp($3r, "^\h*((?:\\\\\?\\)*(\\\\[^\?\/\\]+|[A-Za-z]:)?(.*[\/\\]\h*)?((?:[^\.\/\\]|(?(?=\.[^\/\\]*\.)\.))*)?([^\/\\]*))$", $7)
If @error Then
ReDim $4f[5]
$4f[$18] = $3r
EndIf
$7m = $4f[$19]
If StringLeft($4f[$1a], 1) == "/" Then
$7n = StringRegExpReplace($4f[$1a], "\h*[\/\\]+\h*", "\/")
Else
$7n = StringRegExpReplace($4f[$1a], "\h*[\/\\]+\h*", "\\")
EndIf
$4f[$1a] = $7n
$6b = $4f[$1b]
$7o = $4f[$1c]
Return $4f
EndFunc
Global $7p = False
Global $7q = "1.1"
If $7p = True Then
AutoItSetOption("MustDeclareVars", 1)
EndIf
Local Const $7r = _10y()
If $7r = "fr" Then
Global $7s = "Supprimer les outils"
Global $7t = "Supprimer les points de restaurations"
Global $7u = "Créer un point de restauration"
Global $7v = "Sauvegarder le registre"
Global $7w = "Restaurer UAC"
Global $7x = "Restaurer les paramètres système"
Global $7y = "Exécuter"
Global $7z = "Toutes les opérations sont terminées"
Global $80 = "Echec"
Global $81 = "Impossible de créer une sauvegarde du registre"
Global $82 = "Vous devez exécuter le programme avec les droits administrateurs"
Global $83 = "Mise à jour"
Global $84 = "Une version plus récente de KpRm existe, merci de la télécharger."
ElseIf $7r = "de" Then
Global $7s = "Werkzeuge löschen"
Global $7t = "Wiederherstellungspunkte löschen"
Global $7u = "Erstellen eines Wiederherstellungspunktes"
Global $7v = "Speichern der Registrierung"
Global $7w = "UAC wiederherstellen"
Global $7x = "Systemeinstellungen wiederherstellen"
Global $7y = "Ausführen"
Global $7z = "Alle Vorgänge sind abgeschlossen"
Global $80 = "Ausfall"
Global $81 = "Es ist nicht möglich, ein Registrierungs-Backup zu erstellen"
Global $82 = "Sie müssen das Programm mit Administratorrechten ausführen"
Global $83 = "Update"
Global $84 = "Es gibt eine neuere Version von KpRm, bitte laden Sie sie herunter."
ElseIf $7r = "it" Then
Global $7s = "Cancella strumenti"
Global $7t = "Elimina punti di ripristino"
Global $7u = "Crea un punto di ripristino"
Global $7v = "Salva registro"
Global $7w = "Ripristina UAC"
Global $7x = "Ripristina impostazioni di sistema"
Global $7y = "Eseguire"
Global $7z = "Tutte le operazioni sono completate"
Global $80 = "Fallimento"
Global $81 = "Impossibile creare un backup del registro di sistema"
Global $82 = "È necessario eseguire il programma con i diritti di amministratore"
Global $83 = "Aggiorna"
Global $84 = "Esiste una versione più recente di KpRm, scaricatela, per favore"
ElseIf $7r = "es" Then
Global $7s = "Borrar herramientas"
Global $7t = "Eliminar puntos de restauración"
Global $7u = "Crear un punto de restauración"
Global $7v = "Guardar el registro"
Global $7w = "Restaurar UAC"
Global $7x = "Restaurar ajustes del sistema"
Global $7y = "Ejecutar"
Global $7z = "Todas las operaciones están terminadas"
Global $80 = "fallo"
Global $81 = "Incapaz de crear una copia de seguridad del registro"
Global $82 = "Debe ejecutar el programa con derechos de administrador"
Global $83 = "Actualización"
Global $84 = "Existe una nueva versión de KpRm, por favor descárguela."
ElseIf $7r = "pt" Then
Global $7s = "Apagar ferramentas"
Global $7t = "Deletar pontos de restauração"
Global $7u = "Criar um ponto de restauração"
Global $7v = "Salvar registro"
Global $7w = "Restaurar UAC"
Global $7x = "Restaurar configurações do sistema"
Global $7y = "Executar"
Global $7z = "Todas as operações estão concluídas"
Global $80 = "Falha"
Global $81 = "Incapaz de criar um backup do registro"
Global $82 = "Você deve executar o programa com direitos de administrador"
Global $83 = "Atualizar"
Global $84 = "Uma nova versão do KpRm existe, por favor faça o download."
Else
Global $7s = "Delete Tools"
Global $7t = "Delete Restore Points"
Global $7u = "Create Restore Point"
Global $7v = "Registry Backup"
Global $7w = "UAC Restore"
Global $7x = "Restore System Settings"
Global $7y = "Run"
Global $7z = "All operations are completed"
Global $80 = "Fail"
Global $81 = "Unable to create a registry backup"
Global $82 = "You must run the program with administrator rights"
Global $83 = "Update"
Global $84 = "A more recent version of KpRm exists, please download it!"
EndIf
Global Const $85 = 1
Global Const $86 = 5
Global Const $87 = 0
Global Const $88 = 1
Func _xr($89 = $86)
If Not IsAdmin() Then Return SetError(-3, 0, -1)
If StringRegExp(@OSVersion, "_(XP|200(0|3))") Then Return SetError(-4, 0, -1)
Local $8a = ""
If @OSArch = "X64" Then $8a = "64"
If $89 < 0 Or $89 > 5 Then Return SetError(-5, 0, -1)
Local $36 = RegWrite("HKEY_LOCAL_MACHINE" & $8a & "\Software\Microsoft\Windows\CurrentVersion\Policies\System", "ConsentPromptBehaviorAdmin", "REG_DWORD", $89)
If $36 = 0 Then $36 = -1
Return SetError(@error, 0, $36)
EndFunc
Func _xs($89 = $85)
If Not IsAdmin() Then Return SetError(-3, 0, -1)
If StringRegExp(@OSVersion, "_(XP|200(0|3))") Then Return SetError(-4, 0, -1)
If $89 < 0 Or $89 = 2 Or $89 > 3 Then Return SetError(-5, 0, -1)
Local $8a = ""
If @OSArch = "X64" Then $8a = "64"
Local $36 = RegWrite("HKEY_LOCAL_MACHINE" & $8a & "\Software\Microsoft\Windows\CurrentVersion\Policies\System", "ConsentPromptBehaviorUser", "REG_DWORD", $89)
If $36 = 0 Then $36 = -1
Return SetError(@error, 0, $36)
EndFunc
Func _xt($89 = $87)
If Not IsAdmin() Then Return SetError(-3, 0, -1)
If StringRegExp(@OSVersion, "_(XP|200(0|3))") Then Return SetError(-4, 0, -1)
If $89 < 0 Or $89 > 1 Then Return SetError(-5, 0, -1)
Local $8a = ""
If @OSArch = "X64" Then $8a = "64"
Local $36 = RegWrite("HKEY_LOCAL_MACHINE" & $8a & "\Software\Microsoft\Windows\CurrentVersion\Policies\System", "EnableInstallerDetection", "REG_DWORD", $89)
If $36 = 0 Then $36 = -1
Return SetError(@error, 0, $36)
EndFunc
Func _xu($89 = $88)
If Not IsAdmin() Then Return SetError(-3, 0, -1)
If StringRegExp(@OSVersion, "_(XP|200(0|3))") Then Return SetError(-4, 0, -1)
If $89 < 0 Or $89 > 1 Then Return SetError(-5, 0, -1)
Local $8a = ""
If @OSArch = "X64" Then $8a = "64"
Local $36 = RegWrite("HKEY_LOCAL_MACHINE" & $8a & "\Software\Microsoft\Windows\CurrentVersion\Policies\System", "EnableLUA", "REG_DWORD", $89)
If $36 = 0 Then $36 = -1
Return SetError(@error, 0, $36)
EndFunc
Func _xv($89 = $88)
If Not IsAdmin() Then Return SetError(-3, 0, -1)
If StringRegExp(@OSVersion, "_(XP|200(0|3))") Then Return SetError(-4, 0, -1)
If $89 < 0 Or $89 > 1 Then Return SetError(-5, 0, -1)
Local $8a = ""
If @OSArch = "X64" Then $8a = "64"
Local $36 = RegWrite("HKEY_LOCAL_MACHINE" & $8a & "\Software\Microsoft\Windows\CurrentVersion\Policies\System", "EnableSecureUIAPaths", "REG_DWORD", $89)
If $36 = 0 Then $36 = -1
Return SetError(@error, 0, $36)
EndFunc
Func _xw($89 = $87)
If Not IsAdmin() Then Return SetError(-3, 0, -1)
If StringRegExp(@OSVersion, "_(XP|200(0|3))") Then Return SetError(-4, 0, -1)
If $89 < 0 Or $89 > 1 Then Return SetError(-5, 0, -1)
Local $8a = ""
If @OSArch = "X64" Then $8a = "64"
Local $36 = RegWrite("HKEY_LOCAL_MACHINE" & $8a & "\Software\Microsoft\Windows\CurrentVersion\Policies\System", "EnableUIADesktopToggle", "REG_DWORD", $89)
If $36 = 0 Then $36 = -1
Return SetError(@error, 0, $36)
EndFunc
Func _xx($89 = $88)
If Not IsAdmin() Then Return SetError(-3, 0, -1)
If StringRegExp(@OSVersion, "_(XP|200(0|3))") Then Return SetError(-4, 0, -1)
If $89 < 0 Or $89 > 1 Then Return SetError(-5, 0, -1)
Local $8a = ""
If @OSArch = "X64" Then $8a = "64"
Local $36 = RegWrite("HKEY_LOCAL_MACHINE" & $8a & "\Software\Microsoft\Windows\CurrentVersion\Policies\System", "EnableVirtualization", "REG_DWORD", $89)
If $36 = 0 Then $36 = -1
Return SetError(@error, 0, $36)
EndFunc
Func _xy($89 = $87)
If Not IsAdmin() Then Return SetError(-3, 0, -1)
If StringRegExp(@OSVersion, "_(XP|200(0|3))") Then Return SetError(-4, 0, -1)
If $89 < 0 Or $89 > 1 Then Return SetError(-5, 0, -1)
Local $8a = ""
If @OSArch = "X64" Then $8a = "64"
Local $36 = RegWrite("HKEY_LOCAL_MACHINE" & $8a & "\Software\Microsoft\Windows\CurrentVersion\Policies\System", "FilterAdministratorToken", "REG_DWORD", $89)
If $36 = 0 Then $36 = -1
Return SetError(@error, 0, $36)
EndFunc
Func _xz($89 = $88)
If Not IsAdmin() Then Return SetError(-3, 0, -1)
If StringRegExp(@OSVersion, "_(XP|200(0|3))") Then Return SetError(-4, 0, -1)
If $89 < 0 Or $89 > 1 Then Return SetError(-5, 0, -1)
Local $8a = ""
If @OSArch = "X64" Then $8a = "64"
Local $36 = RegWrite("HKEY_LOCAL_MACHINE" & $8a & "\Software\Microsoft\Windows\CurrentVersion\Policies\System", "PromptOnSecureDesktop", "REG_DWORD", $89)
If $36 = 0 Then $36 = -1
Return SetError(@error, 0, $36)
EndFunc
Func _y0($89 = $87)
If Not IsAdmin() Then Return SetError(-3, 0, -1)
If StringRegExp(@OSVersion, "_(XP|200(0|3))") Then Return SetError(-4, 0, -1)
If $89 < 0 Or $89 > 1 Then Return SetError(-5, 0, -1)
Local $8a = ""
If @OSArch = "X64" Then $8a = "64"
Local $36 = RegWrite("HKEY_LOCAL_MACHINE" & $8a & "\Software\Microsoft\Windows\CurrentVersion\Policies\System", "ValidateAdminCodeSignatures", "REG_DWORD", $89)
If $36 = 0 Then $36 = -1
Return SetError(@error, 0, $36)
EndFunc
Global $8b = Null, $8c = Null
Global $8d = EnvGet('SystemDrive') & '\'
Func _y2()
Local $8e[1][3], $8f = 0
$8e[0][0] = $8f
If Not IsObj($8c) Then $8c = ObjGet("winmgmts:root/default")
If Not IsObj($8c) Then Return $8e
Local $8g = $8c.InstancesOf("SystemRestore")
If Not IsObj($8g) Then Return $8e
For $8h In $8g
$8f += 1
ReDim $8e[$8f + 1][3]
$8e[$8f][0] = $8h.SequenceNumber
$8e[$8f][1] = $8h.Description
$8e[$8f][2] = _y3($8h.CreationTime)
Next
$8e[0][0] = $8f
Return $8e
EndFunc
Func _y3($8i)
Return(StringMid($8i, 5, 2) & "/" & StringMid($8i, 7, 2) & "/" & StringLeft($8i, 4) & " " & StringMid($8i, 9, 2) & ":" & StringMid($8i, 11, 2) & ":" & StringMid($8i, 13, 2))
EndFunc
Func _y4($8j)
Local $1g = DllCall('SrClient.dll', 'DWORD', 'SRRemoveRestorePoint', 'DWORD', $8j)
If @error Then Return SetError(1, 0, 0)
If $1g[0] = 0 Then Return 1
Return SetError(1, 0, 0)
EndFunc
Func _y6($8k = $8d)
If Not IsObj($8b) Then $8b = ObjGet("winmgmts:{impersonationLevel=impersonate}!root/default:SystemRestore")
If Not IsObj($8b) Then Return 0
If $8b.Enable($8k) = 0 Then Return 1
Return 0
EndFunc
Global Enum $8l = 0, $8m, $8n, $8o, $8p, $8q, $8r, $8s, $8t, $8u, $8v, $8w, $8x
Global Const $8y = 2
Global $8z = @SystemDir&'\Advapi32.dll'
Global $90 = @SystemDir&'\Kernel32.dll'
Global $91[4][2], $92[4][2]
Global $93 = 0
Func _y9()
$8z = DllOpen(@SystemDir&'\Advapi32.dll')
$90 = DllOpen(@SystemDir&'\Kernel32.dll')
$91[0][0] = "SeRestorePrivilege"
$91[0][1] = 2
$91[1][0] = "SeTakeOwnershipPrivilege"
$91[1][1] = 2
$91[2][0] = "SeDebugPrivilege"
$91[2][1] = 2
$91[3][0] = "SeSecurityPrivilege"
$91[3][1] = 2
$92 = _zh($91)
$93 = 1
EndFunc
Func _yf($94, $95 = $8m, $96 = 'Administrators', $97 = 1)
Local $98[1][3]
$98[0][0] = 'Everyone'
$98[0][1] = 1
$98[0][2] = $y
Return _yi($94, $98, $95, $96, 1, $97)
EndFunc
Func _yi($94, $99, $95 = $8m, $96 = '', $9a = 0, $97 = 0, $9b = 3)
If $93 = 0 Then _y9()
If Not IsArray($99) Or UBound($99,2) < 3 Then Return SetError(1,0,0)
Local $9c = _yn($99,$9b)
Local $9d = @extended
Local $9e = 4, $9f = 0
If $96 <> '' Then
If Not IsDllStruct($96) Then $96 = _za($96)
$9f = DllStructGetPtr($96)
If $9f And _zg($9f) Then
$9e = 5
Else
$9f = 0
EndIf
EndIf
If Not IsPtr($94) And $95 = $8m Then
Return _yv($94, $9c, $9f, $9a, $97, $9d, $9e)
ElseIf Not IsPtr($94) And $95 = $8p Then
Return _yw($94, $9c, $9f, $9a, $97, $9d, $9e)
Else
If $9a Then _yx($94,$95)
Return _yo($94, $95, $9e, $9f, 0, $9c,0)
EndIf
EndFunc
Func _yn(ByRef $99, ByRef $9b)
Local $9g = UBound($99,2)
If Not IsArray($99) Or $9g < 3 Then Return SetError(1,0,0)
Local $9h = UBound($99), $9i[$9h], $9j = 0, $9k = 1
Local $9l, $9d = 0, $9m
Local $9n, $9o = 'DWORD;DWORD;DWORD;ptr;DWORD;DWORD;DWORD;ptr'
For $4p = 1 To $9h - 1
$9o &= ';DWORD;DWORD;DWORD;ptr;DWORD;DWORD;DWORD;ptr'
Next
$9n = DllStructCreate($9o)
For $4p = 0 To $9h -1
If Not IsDllStruct($99[$4p][0]) Then $99[$4p][0] = _za($99[$4p][0])
$9i[$4p] = DllStructGetPtr($99[$4p][0])
If Not _zg($9i[$4p]) Then ContinueLoop
DllStructSetData($9n,$9j+1,$99[$4p][2])
If $99[$4p][1] = 0 Then
$9d = 1
$9l = $s
Else
$9l = $r
EndIf
If $9g > 3 Then $9b = $99[$4p][3]
DllStructSetData($9n,$9j+2,$9l)
DllStructSetData($9n,$9j+3,$9b)
DllStructSetData($9n,$9j+6,0)
$9m = DllCall($8z,'BOOL','LookupAccountSid','ptr',0,'ptr',$9i[$4p],'ptr*',0,'dword*',32,'ptr*',0,'dword*',32,'dword*',0)
If Not @error Then $9k = $9m[7]
DllStructSetData($9n,$9j+7,$9k)
DllStructSetData($9n,$9j+8,$9i[$4p])
$9j += 8
Next
Local $9p = DllStructGetPtr($9n)
$9m = DllCall($8z,'DWORD','SetEntriesInAcl','ULONG',$9h,'ptr',$9p ,'ptr',0,'ptr*',0)
If @error Or $9m[0] Then Return SetError(1,0,0)
Return SetExtended($9d, $9m[4])
EndFunc
Func _yo($94, $95, $9e, $9f = 0, $9q = 0, $9c = 0, $9r = 0)
Local $9m
If $93 = 0 Then _y9()
If $9c And Not _yp($9c) Then Return 0
If $9r And Not _yp($9r) Then Return 0
If IsPtr($94) Then
$9m = DllCall($8z,'dword','SetSecurityInfo','handle',$94,'dword',$95, 'dword',$9e,'ptr',$9f,'ptr',$9q,'ptr',$9c,'ptr',$9r)
Else
If $95 = $8p Then $94 = _zb($94)
$9m = DllCall($8z,'dword','SetNamedSecurityInfo','str',$94,'dword',$95, 'dword',$9e,'ptr',$9f,'ptr',$9q,'ptr',$9c,'ptr',$9r)
EndIf
If @error Then Return SetError(1,0,0)
If $9m[0] And $9f Then
If _z0($94, $95,_zf($9f)) Then Return _yo($94, $95, $9e - 1, 0, $9q, $9c, $9r)
EndIf
Return SetError($9m[0] , 0, Number($9m[0] = 0))
EndFunc
Func _yp($9s)
If $9s = 0 Then Return SetError(1,0,0)
Local $9m = DllCall($8z,'bool','IsValidAcl','ptr',$9s)
If @error Or Not $9m[0] Then Return 0
Return 1
EndFunc
Func _ys($9t, $9u = -1)
If $93 = 0 Then _y9()
If $9u = -1 Then $9u = BitOR($l, $m, $n, $o)
$9t = ProcessExists($9t)
If $9t = 0 Then Return SetError(1,0,0)
Local $9m = DllCall($90,'handle','OpenProcess','dword',$9u,'bool',False,'dword',$9t)
If @error Or $9m[0] = 0 Then Return SetError(2,0,0)
Return $9m[0]
EndFunc
Func _yt($9t)
Local $9v = _ys($9t,BitOR(1,$l, $m, $n, $o))
If $9v = 0 Then Return SetError(1,0,0)
Local $9w = 0
_yf($9v,$8r)
For $4p = 1 To 10
DllCall($90,'bool','TerminateProcess','handle',$9v,'uint',0)
If @error Then $9w = 0
Sleep(30)
If Not ProcessExists($9t) Then
$9w = 1
ExitLoop
EndIf
Next
_yu($9v)
Return $9w
EndFunc
Func _yu($9x)
Local $9m = DllCall($90,'bool','CloseHandle','handle',$9x)
If @error Then Return SetError(@error,0,0)
Return $9m[0]
EndFunc
Func _yv($94, ByRef $9c, ByRef $9f, ByRef $9a, ByRef $97, ByRef $9d, ByRef $9e)
Local $9w, $9y
If Not $9d Then
If $9a Then _yx($94,$8m)
$9w = _yo($94, $8m, $9e, $9f, 0, $9c,0)
EndIf
If $97 Then
Local $9z = FileFindFirstFile($94&'\*')
While 1
$9y = FileFindNextFile($9z)
If $97 = 1 Or $97 = 2 And @extended = 1 Then
_yv($94&'\'&$9y, $9c, $9f, $9a, $97, $9d,$9e)
ElseIf @error Then
ExitLoop
ElseIf $97 = 1 Or $97 = 3 Then
If $9a Then _yx($94&'\'&$9y,$8m)
_yo($94&'\'&$9y, $8m, $9e, $9f, 0, $9c,0)
EndIf
WEnd
FileClose($9z)
EndIf
If $9d Then
If $9a Then _yx($94,$8m)
$9w = _yo($94, $8m, $9e, $9f, 0, $9c,0)
EndIf
Return $9w
EndFunc
Func _yw($94, ByRef $9c, ByRef $9f, ByRef $9a, ByRef $97, ByRef $9d, ByRef $9e)
If $93 = 0 Then _y9()
Local $9w, $4p = 0, $9y
If Not $9d Then
If $9a Then _yx($94,$8p)
$9w = _yo($94, $8p, $9e, $9f, 0, $9c,0)
EndIf
If $97 Then
While 1
$4p += 1
$9y = RegEnumKey($94,$4p)
If @error Then ExitLoop
_yw($94&'\'&$9y, $9c, $9f, $9a, $97, $9d, $9e)
WEnd
EndIf
If $9d Then
If $9a Then _yx($94,$8p)
$9w = _yo($94, $8p, $9e, $9f, 0, $9c,0)
EndIf
Return $9w
EndFunc
Func _yx($94, $95 = $8m)
If $93 = 0 Then _y9()
Local $a0 = DllStructCreate('byte[32]'), $1g
Local $9c = DllStructGetPtr($a0,1)
DllCall($8z,'bool','InitializeAcl','Ptr',$9c,'dword',DllStructGetSize($a0),'dword',$8y)
If IsPtr($94) Then
$1g = DllCall($8z,"dword","SetSecurityInfo",'handle',$94,'dword',$95,'dword',4,'ptr',0,'ptr',0,'ptr',$9c,'ptr',0)
Else
If $95 = $8p Then $94 = _zb($94)
DllCall($8z,'DWORD','SetNamedSecurityInfo','str',$94,'dword',$95,'DWORD',4,'ptr',0,'ptr',0,'ptr',0,'ptr',0)
$1g = DllCall($8z,'DWORD','SetNamedSecurityInfo','str',$94,'dword',$95,'DWORD',4,'ptr',0,'ptr',0,'ptr',$9c,'ptr',0)
EndIf
If @error Then Return SetError(@error,0,0)
Return SetError($1g[0],0,Number($1g[0] = 0))
EndFunc
Func _z0($94, $95 = $8m, $a1 = 'Administrators')
If $93 = 0 Then _y9()
Local $a2 = _za($a1), $1g
Local $9i = DllStructGetPtr($a2)
If IsPtr($94) Then
$1g = DllCall($8z,"dword","SetSecurityInfo",'handle',$94,'dword',$95,'dword',1,'ptr',$9i,'ptr',0,'ptr',0,'ptr',0)
Else
If $95 = $8p Then $94 = _zb($94)
$1g = DllCall($8z,'DWORD','SetNamedSecurityInfo','str',$94,'dword',$95,'DWORD',1,'ptr',$9i,'ptr',0,'ptr',0,'ptr',0)
EndIf
If @error Then Return SetError(@error,0,False)
Return SetError($1g[0],0,Number($1g[0] = 0))
EndFunc
Func _za($a1)
If $a1 = 'TrustedInstaller' Then $a1 = 'NT SERVICE\TrustedInstaller'
If $a1 = 'Everyone' Then
Return _zd('S-1-1-0')
ElseIf $a1 = 'Authenticated Users' Then
Return _zd('S-1-5-11')
ElseIf $a1 = 'System' Then
Return _zd('S-1-5-18')
ElseIf $a1 = 'Administrators' Then
Return _zd('S-1-5-32-544')
ElseIf $a1 = 'Users' Then
Return _zd('S-1-5-32-545')
ElseIf $a1 = 'Guests' Then
Return _zd('S-1-5-32-546')
ElseIf $a1 = 'Power Users' Then
Return _zd('S-1-5-32-547')
ElseIf $a1 = 'Local Authority' Then
Return _zd('S-1-2')
ElseIf $a1 = 'Creator Owner' Then
Return _zd('S-1-3-0')
ElseIf $a1 = 'NT Authority' Then
Return _zd('S-1-5-1')
ElseIf $a1 = 'Restricted' Then
Return _zd('S-1-5-12')
ElseIf StringRegExp($a1,'\A(S-1-\d+(-\d+){0,5})\z') Then
Return _zd($a1)
Else
Local $a2 = _zc($a1)
Return _zd($a2)
EndIf
EndFunc
Func _zb($a3)
If StringInStr($a3,'\\') = 1 Then
$a3 = StringRegExpReplace($a3,'(?i)\\(HKEY_CLASSES_ROOT|HKCR)','\CLASSES_ROOT')
$a3 = StringRegExpReplace($a3,'(?i)\\(HKEY_CURRENT_USER|HKCU)','\CURRENT_USER')
$a3 = StringRegExpReplace($a3,'(?i)\\(HKEY_LOCAL_MACHINE|HKLM)','\MACHINE')
$a3 = StringRegExpReplace($a3,'(?i)\\(HKEY_USERS|HKU)','\USERS')
Else
$a3 = StringRegExpReplace($a3,'(?i)\A(HKEY_CLASSES_ROOT|HKCR)','CLASSES_ROOT')
$a3 = StringRegExpReplace($a3,'(?i)\A(HKEY_CURRENT_USER|HKCU)','CURRENT_USER')
$a3 = StringRegExpReplace($a3,'(?i)\A(HKEY_LOCAL_MACHINE|HKLM)','MACHINE')
$a3 = StringRegExpReplace($a3,'(?i)\A(HKEY_USERS|HKU)','USERS')
EndIf
Return $a3
EndFunc
Func _zc($a4, $a5 = "")
Local $a6 = DllStructCreate("byte SID[256]")
Local $9i = DllStructGetPtr($a6, "SID")
Local $3a = DllCall($8z, "bool", "LookupAccountNameW", "wstr", $a5, "wstr", $a4, "ptr", $9i, "dword*", 256, "wstr", "", "dword*", 256, "int*", 0)
If @error Then Return SetError(@error, @extended, 0)
If Not $3a[0] Then Return 0
Return _zf($9i)
EndFunc
Func _zd($a7)
Local $3a = DllCall($8z, "bool", "ConvertStringSidToSidW", "wstr", $a7, "ptr*", 0)
If @error Then Return SetError(@error, @extended, 0)
If Not $3a[0] Then Return 0
Local $a8 = _ze($3a[2])
Local $43 = DllStructCreate("byte Data[" & $a8 & "]", $3a[2])
Local $a9 = DllStructCreate("byte Data[" & $a8 & "]")
DllStructSetData($a9, "Data", DllStructGetData($43, "Data"))
DllCall($90, "ptr", "LocalFree", "ptr", $3a[2])
Return $a9
EndFunc
Func _ze($9i)
If Not _zg($9i) Then Return SetError(-1, 0, "")
Local $3a = DllCall($8z, "dword", "GetLengthSid", "ptr", $9i)
If @error Then Return SetError(@error, @extended, 0)
Return $3a[0]
EndFunc
Func _zf($9i)
If Not _zg($9i) Then Return SetError(-1, 0, "")
Local $3a = DllCall($8z, "int", "ConvertSidToStringSidW", "ptr", $9i, "ptr*", 0)
If @error Then Return SetError(@error, @extended, "")
If Not $3a[0] Then Return ""
Local $43 = DllStructCreate("wchar Text[256]", $3a[2])
Local $a7 = DllStructGetData($43, "Text")
DllCall($90, "ptr", "LocalFree", "ptr", $3a[2])
Return $a7
EndFunc
Func _zg($9i)
Local $3a = DllCall($8z, "bool", "IsValidSid", "ptr", $9i)
If @error Then Return SetError(@error, @extended, False)
Return $3a[0]
EndFunc
Func _zh($aa)
Local $ab = UBound($aa, 0), $ac[1][2]
If Not($ab <= 2 And UBound($aa, $ab) = 2 ) Then Return SetError(1300, 0, $ac)
If $ab = 1 Then
Local $ad[1][2]
$ad[0][0] = $aa[0]
$ad[0][1] = $aa[1]
$aa = $ad
$ad = 0
EndIf
Local $5i, $ae = "dword", $af = UBound($aa, 1)
Do
$5i += 1
$ae &= ";dword;long;dword"
Until $5i = $af
Local $ag, $ah, $ai, $aj, $ak, $al, $am
$ag = DLLStructCreate($ae)
$ah = DllStructCreate($ae)
$ai = DllStructGetPtr($ah)
$aj = DllStructCreate("dword;long")
DLLStructSetData($ag, 1, $af)
For $4p = 0 To $af - 1
DllCall($8z, "int", "LookupPrivilegeValue", "str", "", "str", $aa[$4p][0], "ptr", DllStructGetPtr($aj) )
DLLStructSetData( $ag, 3 * $4p + 2, DllStructGetData($aj, 1) )
DLLStructSetData( $ag, 3 * $4p + 3, DllStructGetData($aj, 2) )
DLLStructSetData( $ag, 3 * $4p + 4, $aa[$4p][1] )
Next
$ak = DllCall($90, "hwnd", "GetCurrentProcess")
$al = DllCall($8z, "int", "OpenProcessToken", "hwnd", $ak[0], "dword", BitOR(0x00000020, 0x00000008), "hwnd*", 0 )
DllCall( $8z, "int", "AdjustTokenPrivileges", "hwnd", $al[3], "int", False, "ptr", DllStructGetPtr($ag), "dword", DllStructGetSize($ag), "ptr", $ai, "dword*", 0 )
$am = DllCall($90, "dword", "GetLastError")
DllCall($90, "int", "CloseHandle", "hwnd", $al[3])
Local $an = DllStructGetData($ah, 1)
If $an > 0 Then
Local $ao, $ap, $aq, $ac[$an][2]
For $4p = 0 To $an - 1
$ao = $ai + 12 * $4p + 4
$ap = DllCall($8z, "int", "LookupPrivilegeName", "str", "", "ptr", $ao, "ptr", 0, "dword*", 0 )
$aq = DllStructCreate("char[" & $ap[4] & "]")
DllCall($8z, "int", "LookupPrivilegeName", "str", "", "ptr", $ao, "ptr", DllStructGetPtr($aq), "dword*", DllStructGetSize($aq) )
$ac[$4p][0] = DllStructGetData($aq, 1)
$ac[$4p][1] = DllStructGetData($ah, 3 * $4p + 4)
Next
EndIf
Return SetError($am[0], 0, $ac)
EndFunc
Global $ar
Global $as
Global $at
Global $au
Global $av
Global $aw = -1
Func _zi($ax, $ay = "", $az = -1, $b0 = True)
If $az <> -1 Then
If $az > -1 And $az < 7 Then
$as = ObjCreate("Msxml2.DOMDocument." & $az & ".0")
If IsObj($as) Then
$aw = $az
EndIf
Else
MsgBox(266288, "Error:", "Failed to create object with MSXML version " & $az)
SetError(1)
Return 0
EndIf
Else
For $2i = 8 To 0 Step - 1
If FileExists(@SystemDir & "\msxml" & $2i & ".dll") Then
$as = ObjCreate("Msxml2.DOMDocument." & $2i & ".0")
If IsObj($as) Then
$aw = $2i
ExitLoop
EndIf
EndIf
Next
EndIf
If Not IsObj($as) Then
_10d("Error: MSXML not found. This object is required to use this program.")
SetError(2)
Return -1
EndIf
$at = ObjEvent("AutoIt.Error")
If $at = "" Then
$at = ObjEvent("AutoIt.Error", "_10e")
EndIf
$ar = $ax
$as.async = False
$as.preserveWhiteSpace = True
$as.validateOnParse = $b0
if $aw > 4 Then $as.setProperty("ProhibitDTD",false)
$as.Load($ar)
$as.setProperty("SelectionLanguage", "XPath")
$as.setProperty("SelectionNamespaces", $ay)
if $as.parseError.errorCode >0 Then consoleWrite($as.parseError.reason&@LF)
If $as.parseError.errorCode <> 0 Then
_10d("Error opening specified file: " & $ax & @CRLF & $as.parseError.reason)
ConsoleWrite("Error opening specified file: " & $ax & @CRLF & $as.parseError.reason)
SetError(1,$as.parseError.errorCode,-1)
$as = 0
Return -1
EndIf
Return 1
EndFunc
Func _zl($b1)
If not IsObj($as) then
_10d("No object passed to function _XMLSelectNodes")
Return SetError(2,0,-1)
EndIf
Local $b2, $b3, $b4[1], $b5
$b3 = $as.selectNodes($b1)
If Not IsObj($b3) Then
_10d("\nNo matching nodes found")
Return SetError(1,0,-1)
EndIf
If $b3.length < 1 Then
_10d("\nNo matching nodes found")
Return SetError(1,0,-1)
EndIf
For $b2 In $b3
_10q($b4, $b2.nodeName)
_10g($b2.nodeName)
_10g($b2.namespaceURI)
Next
$b4[0] = $b3.length
Return $b4
_10d("Error Selecting Node(s): " & $b1 & $b5)
Return SetError(1,0,-1)
EndFunc
Func _zr($b1, $b6, $b7 = "")
If not IsObj($as) then
_10d("No object passed to function _XMLGetAttrib")
ConsoleWrite("No object passed to function _XMLGetAttrib")
Return SetError(2,0,-1)
EndIf
Local $b3, $b4, $4p, $b5, $b8
$b3 = $as.documentElement.selectNodes($b1 & $b7)
_10g("Get Attrib length= " & $b3.length)
If $b3.length > 0 Then
For $4p = 0 To $b3.length - 1
$b8 = $b3.item($4p).getAttribute($b6)
$b4 = $b8
_10g("RET>>" & $b8)
Next
Return $b4
EndIf
$b5 = "\nNo qualified items found"
_10d("Attribute " & $b6 & " not found for: " & $b1 & $b5)
ConsoleWrite("Attribute " & $b6 & " not found for: " & $b1 & $b5)
Return SetError(1,0,-1)
EndFunc
Func _zt($b1, ByRef $b9, ByRef $ba, $bb = "")
If not IsObj($as) then
_10d("No object passed to function _XMLGetAllAttrib")
Return SetError(1,9,-1)
EndIf
Local $b3, $bc, $b2, $b4[2][1], $4p
$bc = $as.selectNodes($b1 & $bb)
If $bc.length > 0 Then
For $b2 In $bc
$b3 = $b2.attributes
If($b3.length) Then
_10g("Get all attrib " & $b3.length)
ReDim $b4[2][$b3.length + 2]
ReDim $b9[$b3.length]
ReDim $ba[$b3.length]
For $4p = 0 To $b3.length - 1
$b4[0][$4p + 1] = $b3.item($4p).nodeName
$b4[1][$4p + 1] = $b3.item($4p).Value
$b9[$4p] = $b3.item($4p).nodeName
$ba[$4p] = $b3.item($4p).Value
Next
Else
_10d("No Attributes found for node")
Return SetError(1,0, -1)
EndIf
Next
$b4[0][0] = $b3.length
Return $b4
EndIf
_10d("Error retrieving attributes for: " & $b1 & @CRLF)
return SetError(1,0 ,-1)
EndFunc
Func _10d($bd = "")
If $bd = "" Then
$bd = $au
$au = ""
Return $bd
Else
$au = StringFormat($bd)
EndIf
_10g($au)
EndFunc
Func _10e()
_10f()
Return
EndFunc
Func _10f($be = "")
Local $bf, $bg
If $be = True Or $be = False Then
$bf = $be
$be = ""
EndIf
$bg = Hex($at.number, 8)
If @error Then Return
Local $bh = "COM Error with DOM!" & @CRLF & @CRLF & "err.description is: " & @TAB & $at.description & @CRLF & "err.windescription:" & @TAB & $at.windescription & @CRLF & "err.number is: " & @TAB & $bg & @CRLF & "err.lastdllerror is: " & @TAB & $at.lastdllerror & @CRLF & "err.scriptline is: " & @TAB & $at.scriptline & @CRLF & "err.source is: " & @TAB & $at.source & @CRLF & "err.helpfile is: " & @TAB & $at.helpfile & @CRLF & "err.helpcontext is: " & @TAB & $at.helpcontext
If $bf <> True Then
MsgBox(0, @AutoItExe, $bh)
Else
_10d($bh)
EndIf
SetError(1)
EndFunc
Func _10g($bi, $bj = @LF)
If $av Then
ConsoleWrite(StringFormat($bi)&$bj)
EndIf
EndFunc
Func _10q(ByRef $bk, $bl)
If IsArray($bk) Then
ReDim $bk[UBound($bk) + 1]
$bk[UBound($bk) - 1] = $bl
SetError(0)
Return 1
Else
SetError(1)
Return 0
EndIf
EndFunc
Local $bm = ObjEvent("AutoIt.Error", "_10r")
Func _10r()
Local $bg = Hex($bm.number, 8)
ConsoleWrite("We intercepted a COM Error !" & @LF & "Number is: " & $bg & @LF & "Windescription is: " & $bm.windescription & @LF)
Return SetError(5, $bg, 0)
EndFunc
Func _10s($bn)
Local $bo = ObjCreate("winhttp.winhttprequest.5.1")
Local $bp = $bo.Open("GET", $bn, False)
If(@error) Then Return SetError(1, 0, 0)
$bo.Send()
If(@error) Then Return SetError(2, 0, 0)
Local $bq = $bo.ResponseText
Local $br = $bo.Status
If $br = 200 Then
Return $bq
Else
Return SetError(3, $br, $bq)
EndIf
EndFunc
Func _10x($bs, $bt = Default, $bu = 5, $bv = Default, $bw = Default)
If @Compiled = 0 Or FileExists($bs) = 0 Then
Return SetError(1, 0, 0)
EndIf
Local $bx = @ScriptName
$bx = StringLeft($bx, StringInStr($bx, '.', $2, -1) - 1)
Local Const $by = @ScriptFullPath
Local $bz = ''
If $bw Or $bw = Default Then
$bz = 'MOVE /Y ' & '"' & $by & '"' & ' "' & @ScriptDir & '\' & $bx & '_Backup.exe' & '"' & @CRLF
EndIf
While FileExists(@TempDir & '\' & $bx & '.bat')
$bx &= Chr(Random(65, 122, 1))
WEnd
$bx = @TempDir & '\' & $bx & '.bat'
If $bu = Default Then
$bu = 5
EndIf
Local $c0 = ''
$bu = Int($bu)
If $bu > 0 Then
$c0 = 'IF %TIMER% GTR ' & $bu & ' GOTO DELETE'
EndIf
Local $c1 = @ScriptName, $c2 = 'IMAGENAME'
If $bv Then
$c1 = @AutoItPID
$c2 = 'PID'
EndIf
Local $c3 = ''
If $bt Then
$c3 = 'START "" "' & $by & '"'
EndIf
Local Const $c4 = 2
Local Const $c5 = '@ECHO OFF' & @CRLF & 'SET TIMER=0' & @CRLF & ':START' & @CRLF & 'PING -n ' & $c4 & ' 127.0.0.1 > nul' & @CRLF & $c0 & @CRLF & 'SET /A TIMER+=1' & @CRLF & @CRLF & 'TASKLIST /NH /FI "' & $c2 & ' EQ ' & $c1 & '" | FIND /I "' & $c1 & '" >nul && GOTO START' & @CRLF & 'GOTO MOVE' & @CRLF & @CRLF & ':MOVE' & @CRLF & 'TASKKILL /F /FI "' & $c2 & ' EQ ' & $c1 & '"' & @CRLF & $bz & 'GOTO END' & @CRLF & @CRLF & ':END' & @CRLF & 'MOVE /Y ' & '"' & $bs & '"' & ' "' & $by & '"' & @CRLF & $c3 & @CRLF & 'DEL "' & $bx & '"'
Local Const $c6 = FileOpen($bx, $x)
If $c6 = -1 Then
Return SetError(2, 0, 0)
EndIf
FileWrite($c6, $c5)
FileClose($c6)
Run(@ComSpec & ' /c timeout 5 && ' & $bx, @TempDir, @SW_HIDE)
Exit
EndFunc
Func _10y()
Switch StringRight(@MUILang, 2)
Case "07"
Return "de"
Case "09"
Return "en"
Case "0a"
Return "es"
Case "0c"
Return "fr"
Case "10"
Return "it"
Case "16"
Return "pt"
Case Else
Return "en"
EndSwitch
EndFunc
Func _10z($c7 = False, $c8 = True)
Dim $7p
Dim $c9
FileDelete(@TempDir & "\kprm-logo.gif")
FileDelete(@TempDir & "\kprm-tools.xml")
If $c7 = True Then
If $c8 = True Then
Run("notepad.exe " & @HomeDrive & "\KPRM" & "\" & $c9)
EndIf
If $7p = False Then
Run(@ComSpec & ' /c timeout 3 && del /F /Q "' & @ScriptFullPath & '"', @TempDir, @SW_HIDE)
FileDelete(@ScriptFullPath)
EndIf
EndIf
Exit
EndFunc
Func _110()
Local $ca = DllCall('connect.dll', 'long', 'IsInternetConnected')
If @error Then
Return SetError(1, 0, False)
EndIf
Return $ca[0] = 0
EndFunc
Func _111()
Dim $7q
If _110() = False Then Return
Local $cb = StringSplit($7q, ".")
Local $cc = _10s("https://toolslib.net/api/softwares/951/version")
Local $cd = StringSplit($cc, ".")
Local $ce = False
For $4p = 0 To UBound($cb) - 1
If $cb[$4p] < $cd[$4p] Then
$ce = True
ExitLoop
EndIf
Next
If $ce Then
Local $cf = _112()
_10x($cf, True, 5, False, False)
If @error Then
MsgBox($e, "KpRm - Updater", "The script must be a compiled exe to work correctly or the update file must exist.")
_10z(True)
EndIf
EndIf
EndFunc
Func _112()
ProgressOn("KpRm - Updater", "Downloading..", "0%")
Local $cg = "https://download.toolslib.net/download/direct/951/latest"
Local $3r = _l4(@TempDir)
Local $ch = InetGetSize($cg)
Local $ci = InetGet($cg, $3r, $a, $b)
Do
Sleep(250)
Local $cj = InetGetInfo($ci, $9)
Local $ck = Int($cj / $ch * 100)
ProgressSet($ck, $ck & "%")
Until InetGetInfo($ci, $d)
Local $cl = InetGetInfo($ci, $c)
Local $cm = FileGetSize($3r)
InetClose($ci)
ProgressOff()
Return $3r
EndFunc
Func _113()
Local $8a = ""
If @OSArch = "X64" Then $8a = "64"
Return $8a
EndFunc
Func _114($bi)
Dim $c9
FileWrite(@HomeDrive & "\KPRM" & "\" & $c9, $bi & @CRLF)
EndFunc
Func _115()
Local $cn = 100, $co = 100, $cp = 0, $cq = @WindowsDir & "\Explorer.exe"
_hf($3j, 0, 0, 0)
Local $cr = _d0("Shell_TrayWnd", "")
_51($cr, 1460, 0, 0)
While ProcessExists("Explorer.exe")
Sleep(10)
$cn -= ProcessClose("Explorer.exe") ? 0 : 1
If $cn < 1 Then Return SetError(1, 0, 0)
WEnd
While(Not ProcessExists("Explorer.exe"))
If Not FileExists($cq) Then Return SetError(-1, 0, 0)
Sleep(500)
$cp = ShellExecute($cq)
$co -= $cp ? 0 : 1
If $co < 1 Then Return SetError(2, 0, 0)
WEnd
Return $cp
EndFunc
Func _116($cs, $ct, $cu)
Local $4p = 0
While True
$4p += 1
Local $cv = RegEnumKey($cs, $4p)
If @error <> 0 Then ExitLoop
Local $cw = $cs & "\" & $cv
Local $76 = RegRead($cw, $cu)
If StringRegExp($76, $ct) Then
Return $cw
EndIf
WEnd
Return Null
EndFunc
Func _118()
Local $cx[0]
If FileExists(@HomeDrive & "\Program Files") Then
_vv($cx, @HomeDrive & "\Program Files")
EndIf
If FileExists(@HomeDrive & "\Program Files (x86)") Then
_vv($cx, @HomeDrive & "\Program Files (x86)")
EndIf
If FileExists(@HomeDrive & "\Program Files(x86)") Then
_vv($cx, @HomeDrive & "\Program Files(x86)")
EndIf
Return $cx
EndFunc
Func _119($3r)
Return Int(FileExists($3r) And StringInStr(FileGetAttrib($3r), 'D', Default, 1) = 0)
EndFunc
Func _11a($3r)
Return Int(FileExists($3r) And StringInStr(FileGetAttrib($3r), 'D', Default, 1) > 0)
EndFunc
Func _11b($3r)
Local $cy = Null
If FileExists($3r) Then
Local $cz = StringInStr(FileGetAttrib($3r), 'D', Default, 1)
If $cz = 0 Then
$cy = 'file'
ElseIf $cz > 0 Then
$cy = 'folder'
EndIf
EndIf
Return $cy
EndFunc
Func _11c()
Switch @OSVersion
Case "WIN_VISTA"
Return "Windows Vista"
Case "WIN_7"
Return "Windows 7"
Case "WIN_8"
Return "Windows 8"
Case "WIN_81"
Return "Windows 8.1"
Case "WIN_10"
Return "Windows 10"
Case Else
Return "Unsupported OS"
EndSwitch
EndFunc
Func _11d($d0)
If StringRegExp($d0, "(?i)^(HKLM|HKCU|HKU|HKCR|HKCC)64") Then
Local $cu = StringReplace($d0, "64", "", 1)
Return $cu
EndIf
Return $d0
EndFunc
Func _11e($d0)
If StringRegExp($d0, "(?i)^(HKLM|HKCU|HKU|HKCR|HKCC)") And @OSArch = "X64" Then
Local $d1 = StringSplit($d0, "\", $6)
$d1[0] = $d1[0] & "64"
$d0 = _wm($d1, "\")
EndIf
Return $d0
EndFunc
Func _11f($cs)
If StringRegExp($cs, "^@AppDataCommonDir") Then
$cs = @AppDataCommonDir & StringReplace($cs, "@AppDataCommonDir", "")
ElseIf StringRegExp($cs, "^@DesktopDir") Then
$cs = @DesktopDir & StringReplace($cs, "@DesktopDir", "")
EndIf
Return $cs
EndFunc
Func _11g($d2, $cu)
If $d2.Exists($cu) Then
Local $cz = $d2.Item($cu) + 1
$d2.Item($cu) = $cz
Else
$d2.add($cu, 1)
EndIf
Return $d2
EndFunc
Func _11h($d3, $d4, $d5)
Dim $d6
Local $d7 = $d6.Item($d3)
Local $d8 = _11g($d7.Item($d4), $d5)
$d7.Item($d4) = $d8
$d6.Item($d3) = $d7
EndFunc
Func _11i($d9, $da)
If $d9 = Null Or $d9 = "" Then Return
Local $br = ProcessExists($d9)
If $br <> 0 Then
_114("     [X] Process " & $d9 & " not killed, it is possible that the deletion is not complete (" & $da & ")")
Else
_114("     [OK] Process " & $d9 & " killed (" & $da & ")")
EndIf
EndFunc
Func _11j($db, $da)
If $db = Null Or $db = "" Then Return
Local $dc = "[X]"
RegEnumVal($db, "1")
If @error >= 0 Then
$dc = "[OK]"
EndIf
_114("     " & $dc & " " & _11d($db) & " deleted (" & $da & ")")
EndFunc
Func _11k($db, $da)
If $db = Null Or $db = "" Then Return
Local $7m = "", $7n = "", $6b = "", $7o = ""
Local $dd = _xe($db, $7m, $7n, $6b, $7o)
If $7o = ".exe" Then
Local $de = $dd[1] & $dd[2]
Local $dc = "[OK]"
If FileExists($de) Then
$dc = "[X]"
EndIf
_114("     " & $dc & " Uninstaller run correctly (" & $da & ")")
EndIf
EndFunc
Func _11l($db, $da)
If $db = Null Or $db = "" Then Return
Local $dc = "[OK]"
If FileExists($db) Then
$dc = "[X]"
EndIf
_114("     " & $dc & " " & $db & " deleted (" & $da & ")")
EndFunc
Func _11m($1w, $db, $da)
Switch $1w
Case "process"
_11i($db, $da)
Case "key"
_11j($db, $da)
Case "uninstall"
_11k($db, $da)
Case "element"
_11l($db, $da)
Case Else
_114("     [?] Unknown type " & $1w)
EndSwitch
EndFunc
Local $df = 47
Local $dg
Local Const $dh = Floor(100 / $df)
Func _11n($di = 1)
$dg += $di
Dim $dj
GUICtrlSetData($dj, $dg * $dh)
If $dg = $df Then
GUICtrlSetData($dj, 100)
EndIf
EndFunc
Func _11o()
$dg = 0
Dim $dj
GUICtrlSetData($dj, 0)
EndFunc
Func _11p()
_114(@CRLF & "- Clear All System Restore Points -" & @CRLF)
Local Const $dk = _y2()
Local $dl = 0
If $dk[0][0] = 0 Then
_114("  [I] No system recovery points were found")
Return Null
EndIf
Local $dm[1][3] = [[Null, Null, Null]]
For $4p = 1 To $dk[0][0]
Local $br = _y4($dk[$4p][0])
$dl += $br
If $br = 1 Then
_114("    => [OK] RP named " & $dk[$4p][1] & " created at " & $dk[$4p][2] & " deleted")
Else
Local $dn[1][3] = [[$dk[$4p][0], $dk[$4p][1], $dk[$4p][2]]]
_vv($dm, $dn)
EndIf
Next
If 1 < UBound($dm) Then
Sleep(3000)
For $4p = 1 To UBound($dm) - 1
Local $br = _y4($dm[$4p][0])
$dl += $br
If $br = 1 Then
_114("    => [OK] RP named " & $dm[$4p][1] & " created at " & $dk[$4p][2] & " deleted")
Else
_114("    => [X] RP named " & $dm[$4p][1] & " created at " & $dk[$4p][2] & " deleted")
EndIf
Next
EndIf
If $dk[0][0] = $dl Then
_114(@CRLF & "  [OK] All system restore points have been successfully deleted")
Else
_114(@CRLF & "  [X] Failure when deleting all restore points")
EndIf
EndFunc
Func _11q($do)
Local $dp = StringLeft($do, 4)
Local $dq = StringMid($do, 6, 2)
Local $dr = StringMid($do, 9, 2)
Local $ds = StringRight($do, 8)
Return $dq & "/" & $dr & "/" & $dp & " " & $ds
EndFunc
Func _11r($dt = False)
Local Const $dk = _y2()
If $dk[0][0] = 0 Then
Return Null
EndIf
Local Const $du = _11q(_31('n', -1470, _3p()))
Local $dv = False
Local $dw = False
Local $dx = False
For $4p = 1 To $dk[0][0]
Local $dy = $dk[$4p][2]
If $dy > $du Then
If $dx = False Then
$dx = True
$dw = True
_114(@CRLF & "  [I] Recent System Restore Point Deletion before create new:" & @CRLF)
EndIf
Local $br = _y4($dk[$4p][0])
If $br = 1 Then
_114("    => [OK] RP named " & $dk[$4p][1] & " created at " & $dy & " deleted")
ElseIf $dt = False Then
$dv = True
Else
_114("    => [X] RP named " & $dk[$4p][1] & " created at " & $dy & " deleted")
EndIf
EndIf
Next
If $dv = True Then
Sleep(3000)
_114("  [I] Retry deleting restore point")
_11r(True)
EndIf
If $dw = True Then
_114(@CRLF)
EndIf
Sleep(3000)
EndFunc
Func _11s()
Sleep(3000)
_114(@CRLF & "- Display All System Restore Point -" & @CRLF)
Local Const $dk = _y2()
If $dk[0][0] = 0 Then
_114("  [X] No System Restore point found")
Return
EndIf
For $4p = 1 To $dk[0][0]
_114("    => [I] RP named " & $dk[$4p][1] & " created at " & $dk[$4p][2] & " found")
Next
EndFunc
Func _11t()
RunWait(@ComSpec & ' /c ' & 'wmic.exe /Namespace:\\root\default Path SystemRestore Call CreateRestorePoint "KpRm", 100, 7', "", @SW_HIDE)
Return @error
EndFunc
Func _11u($dt = False)
If $dt = False Then
_114(@CRLF & "- Create New System Restore Point -" & @CRLF)
Else
_114("  [I] Retry Create New System Restore Point")
EndIf
Local $dz = _y6()
If $dz = 0 Then
Sleep(3000)
$dz = _y6()
If $dz = 0 Then
_114("  [X] Enable System Restore")
EndIf
ElseIf $dz = 1 Then
_114("  [OK] Enable System Restore")
EndIf
_11r()
Local Const $e0 = _11t()
If $e0 <> 0 Then
_114("  [X] System Restore Point created")
If $dt = False Then
_114("  [I] Retry to create System Restore Point!")
_11u(True)
Return
Else
_11s()
Return
EndIf
ElseIf $e0 = 0 Then
_114("  [OK] System Restore Point created")
_11s()
EndIf
EndFunc
Func _11v()
_114(@CRLF & "- Create Registry Backup -" & @CRLF)
Local Const $bz = @HomeDrive & "\KPRM"
Local Const $e1 = $bz & "\regedit-backup-" & @YEAR & @MON & @MDAY & @HOUR & @MIN & ".reg"
If FileExists($e1) Then
FileMove($e1, $e1 & ".old")
EndIf
Local Const $e2 = RunWait("Regedit /e " & $e1)
If Not FileExists($e1) Or @error <> 0 Then
_114("  [X] Failed to create registry backup")
MsgBox(16, $80, $81)
_10z()
Else
_114("  [OK] Registry Backup: " & $e1)
EndIf
EndFunc
Func _11w()
_114(@CRLF & "- Restore UAC Default Value -" & @CRLF)
Local $br = _xr()
If $br = 1 Then
_114("  [OK] Set ConsentPromptBehaviorAdmin with default (5) value")
Else
_114("  [X] Set ConsentPromptBehaviorAdmin with default value")
EndIf
Local $br = _xs(3)
If $br = 1 Then
_114("  [OK] Set ConsentPromptBehaviorUser with default (3) value")
Else
_114("  [X] Set ConsentPromptBehaviorUser with default value")
EndIf
Local $br = _xt()
If $br = 1 Then
_114("  [OK] Set EnableInstallerDetection with default (0) value")
Else
_114("  [X] Set EnableInstallerDetection with default value")
EndIf
Local $br = _xu()
If $br = 1 Then
_114("  [OK] Set EnableLUA with default (1) value")
Else
_114("  [X] Set EnableLUA with default value")
EndIf
Local $br = _xv()
If $br = 1 Then
_114("  [OK] Set EnableSecureUIAPaths with default (1) value")
Else
_114("  [X] Set EnableSecureUIAPaths with default value")
EndIf
Local $br = _xw()
If $br = 1 Then
_114("  [OK] Set EnableUIADesktopToggle with default (0) value")
Else
_114("  [X] Set EnableUIADesktopToggle with default value")
EndIf
Local $br = _xx()
If $br = 1 Then
_114("  [OK] Set EnableVirtualization with default (1) value")
Else
_114("  [X] Set EnableVirtualization with default value")
EndIf
Local $br = _xy()
If $br = 1 Then
_114("  [OK] Set FilterAdministratorToken with default (0) value")
Else
_114("  [X] Set FilterAdministratorToken with default value")
EndIf
Local $br = _xz()
If $br = 1 Then
_114("  [OK] Set PromptOnSecureDesktop with default (1) value")
Else
_114("  [X] Set PromptOnSecureDesktop with default value")
EndIf
Local $br = _y0()
If $br = 1 Then
_114("  [OK] Set ValidateAdminCodeSignatures with default (0) value")
Else
_114("  [X] Set ValidateAdminCodeSignatures with default value")
EndIf
EndFunc
Func _11x()
_114(@CRLF & "- Restore Default System Settings -" & @CRLF)
Local $br = RunWait(@ComSpec & " /c " & "ipconfig /flushdns", @TempDir, @SW_HIDE)
If @error <> 0 Then
_114("  [X] Flush DNS")
Else
_114("  [OK] Flush DNS")
EndIf
Local Const $e3[7] = [ "netsh winsock reset", "netsh winhttp reset proxy", "netsh winhttp reset tracing", "netsh winsock reset catalog", "netsh int ip reset all", "netsh int ipv4 reset catalog", "netsh int ipv6 reset catalog" ]
$br = 0
For $4p = 0 To UBound($e3) -1
RunWait(@ComSpec & " /c " & $e3[$4p], @TempDir, @SW_HIDE)
If @error <> 0 Then
$br += 1
EndIf
Next
If $br = 0 Then
_114("  [OK] Reset WinSock")
Else
_114("  [X] Reset WinSock")
EndIf
Local $e4 = "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced"
$br = RegWrite($e4, "Hidden", "REG_DWORD", "2")
If $br = 1 Then
_114("  [OK] Hide Hidden file.")
Else
_114("  [X] Hide Hidden File")
EndIf
$br = RegWrite($e4, "HideFileExt", "REG_DWORD", "0")
If $br = 1 Then
_114("  [OK] Show Extensions for known file types")
Else
_114("  [X] Show Extensions for known file types")
EndIf
$br = RegWrite($e4, "ShowSuperHidden", "REG_DWORD", "0")
If $br = 1 Then
_114("  [OK] Hide protected operating system files")
Else
_114("  [X] Hide protected operating system files")
EndIf
_115()
EndFunc
Func _11y($cs, $e5 = 0, $e6 = "0")
If Number($e6) Then
_yx($cs)
_yf($cs)
EndIf
Local Const $e7 = FileGetAttrib($cs)
If StringInStr($e7, "R") Then
FileSetAttrib($cs, "-R", $e5)
EndIf
If StringInStr($e7, "S") Then
FileSetAttrib($cs, "-S", $e5)
EndIf
If StringInStr($e7, "H") Then
FileSetAttrib($cs, "-H", $e5)
EndIf
If StringInStr($e7, "A") Then
FileSetAttrib($cs, "-A", $e5)
EndIf
EndFunc
Func _11z($e8, $d3, $e9 = Null, $e6 = "0")
Local Const $ea = _119($e8)
If $ea Then
If $e9 And StringRegExp($e8, "(?i)\.(exe|com)$") Then
Local Const $eb = FileGetVersion($e8, "CompanyName")
If @error Or Not StringRegExp($eb, $e9) Then
Return False
EndIf
EndIf
_11h($d3, 'element', $e8)
_11y($e8, 0, $e6)
FileDelete($e8)
EndIf
EndFunc
Func _120($cs, $d3, $e6 = "0")
Local $ea = _11a($cs)
If $ea Then
_11h($d3, 'element', $cs)
_11y($cs, 1, $e6)
DirRemove($cs, $i)
EndIf
EndFunc
Func _121($cs, $e8, $ec)
Local Const $ed = $cs & "\" & $e8
Local Const $6d = FileFindFirstFile($ed)
Local $ca = []
If $6d = -1 Then
Return $ca
EndIf
Local $6b = FileFindNextFile($6d)
While @error = 0
If StringRegExp($6b, $ec) Then
_vv($ca, $cs & "\" & $6b)
EndIf
$6b = FileFindNextFile($6d)
WEnd
FileClose($6d)
Return $ca
EndFunc
Func _122($ee, $ef)
Local $eg = _11b($ee)
If $eg = Null Then
Return Null
EndIf
Local $7m = "", $7n = "", $6b = "", $7o = ""
Local $dd = _xe($ee, $7m, $7n, $6b, $7o)
Local $e8 = $6b & $7o
For $eh = 0 To UBound($ef) - 1
If $ef[$eh][3] And $eg = $ef[$eh][1] And StringRegExp($e8, $ef[$eh][3]) Then
If $eg = 'file' Then
_11z($ee, $ef[$eh][0], $ef[$eh][2], $ef[$eh][4])
ElseIf $eg = 'folder' Then
_120($ee, $ef[$eh][0], $ef[$eh][4])
EndIf
EndIf
Next
EndFunc
Func _123($cs, $ef, $ei = -2)
Local $4f = _x2($cs, "*.exe;*.txt;*.lnk;*.log;*.reg;*.zip;*.dat;*.scr;*.com;*.bat", $10, $ei, $15, $17)
If @error <> 0 Then
Return Null
EndIf
For $4p = 1 To $4f[0]
_122($4f[$4p], $ef)
Next
EndFunc
Func _124($cs, $ef)
Local Const $ed = $cs & "\*"
Local Const $6d = FileFindFirstFile($ed)
If $6d = -1 Then
Return Null
EndIf
Local $6b = FileFindNextFile($6d)
While @error = 0
Local $ee = $cs & "\" & $6b
_122($ee, $ef)
$6b = FileFindNextFile($6d)
WEnd
FileClose($6d)
EndFunc
Func _125($ej, $d3, $e6 = "0")
If Number($e6) Then
_yx($ej)
_yf($ej, $8p)
EndIf
Local Const $br = RegDelete($ej)
If $br <> 0 Then
_11h($d3, "key", $ej)
EndIf
EndFunc
Func _126($d9, $e6 = "0")
Local $ek = 50
If 0 = ProcessExists($d9) Then Return False
If Number($e6) Then
_yt($d9)
If 0 = ProcessExists($d9) Then Return True
EndIf
ProcessClose($d9)
Do
$ek -= 1
Sleep(250)
Until($ek = 0 Or 0 = ProcessExists($d9))
EndFunc
Func _127($7i)
Dim $ek
Local $el = ProcessList()
For $4p = 1 To $el[0][0]
Local $em = $el[$4p][0]
Local $en = $el[$4p][1]
For $ek = 0 To UBound($7i) - 1
If StringRegExp($em, $7i[$ek][1]) Then
_126($en, $7i[$ek][2])
_11h($7i[$ek][0], "process", $em)
EndIf
Next
Next
EndFunc
Func _128($7i)
For $4p = 0 To UBound($7i) - 1
RunWait('schtasks.exe /delete /tn "' & $7i[$4p][1] & '" /f', @TempDir, @SW_HIDE)
Next
EndFunc
Func _129($7i)
Local Const $cx = _118()
For $4p = 0 To UBound($cx) - 1
For $eo = 0 To UBound($7i) - 1
Local $ep = $7i[$eo][1]
Local $eq = $7i[$eo][2]
Local $er = _121($cx[$4p], "*", $ep)
For $es = 1 To UBound($er) - 1
Local $et = _121($er[$es], "*", $eq)
For $eu = 1 To UBound($et) - 1
If _119($et[$eu]) Then
RunWait($et[$eu])
_11h($7i[$eo][0], "uninstall", $et[$eu])
EndIf
Next
Next
Next
Next
EndFunc
Func _12a($7i)
Local Const $cx = _118()
For $4p = 0 To UBound($cx) - 1
_124($cx[$4p], $7i)
Next
EndFunc
Func _12b($7i)
Local $8a = _113()
Local $ev[2] = ["HKCU" & $8a & "\SOFTWARE", "HKLM" & $8a & "\SOFTWARE"]
For $5i = 0 To UBound($ev) - 1
Local $4p = 0
While True
$4p += 1
Local $cv = RegEnumKey($ev[$5i], $4p)
If @error <> 0 Then ExitLoop
For $eo = 0 To UBound($7i) - 1
If $cv And $7i[$eo][1] Then
If StringRegExp($cv, $7i[$eo][1]) Then
Local $ew = $ev[$5i] & "\" & $cv
_125($ew, $7i[$eo][0])
EndIf
EndIf
Next
WEnd
Next
EndFunc
Func _12c($7i)
For $4p = 1 To UBound($7i) - 1
Local $cu = _11e($7i[$4p][1])
Local $ew = _116($cu, $7i[$4p][2], $7i[$4p][3])
If $ew And $ew <> "" Then
_125($ew, $7i[$4p][0])
EndIf
Next
EndFunc
Func _12d($7i)
For $4p = 0 To UBound($7i) - 1
Local $cu = _11e($7i[$4p][1])
_125($cu, $7i[$4p][0], $7i[$4p][2])
Next
EndFunc
Func _12e($7i)
For $4p = 0 To UBound($7i) - 1
Local $cs = _11f($7i[$4p][1])
If FileExists($cs) Then
Local $ex = _x1($cs)
If @error = 0 Then
For $es = 1 To $ex[0]
_11z($cs & '\' & $ex[$es], $7i[$4p][0], $7i[$4p][2], $7i[$4p][3])
Next
EndIf
EndIf
Next
EndFunc
Func _12f($7i)
For $4p = 0 To UBound($7i) - 1
Local $cs = _11f($7i[$4p][1])
_11z($cs, $7i[$4p][0], $7i[$4p][2], $7i[$4p][3])
Next
EndFunc
Func _12g($7i)
For $4p = 0 To UBound($7i) - 1
Local $cs = _11f($7i[$4p][1])
_120($cs, $7i[$4p][0], $7i[$4p][2])
Next
EndFunc
Global $d6 = ObjCreate("Scripting.Dictionary")
Local $ey = ["desktop", "desktopCommon", "download", "homeDrive", "programFiles", "appData", "appDataCommon", "appDataLocal", "windowsFolder", "startMenu"]
Local $ez = _zi(@TempDir & "\kprm-tools.xml")
Func _12h($ds)
If _we($ey, $ds) <> -1 Then
Local $f0[4][2] = [["type", "file"], ["companyName", ""], ["pattern", "__REQUIRED__"], ["force", "0"]]
Return $f0
ElseIf $ds = "uninstall" Then
Local $f0[2][2] = [["folder", "__REQUIRED__"], ["uninstaller", "__REQUIRED__"]]
Return $f0
ElseIf $ds = "task" Then
Local $f0[1][2] = [["name", "__REQUIRED__"]]
Return $f0
ElseIf $ds = "softwareKey" Then
Local $f0[1][2] = [["pattern", "__REQUIRED__"]]
Return $f0
ElseIf $ds = "process" Then
Local $f0[2][2] = [["process", "__REQUIRED__"], ["force", "0"]]
Return $f0
ElseIf $ds = "registryKey" Then
Local $f0[2][2] = [["key", "__REQUIRED__"], ["force", "0"]]
Return $f0
ElseIf $ds = "searchRegistryKey" Then
Local $f0[3][2] = [["key", "__REQUIRED__"], ["pattern", "__REQUIRED__"], ["value", "__REQUIRED__"]]
Return $f0
ElseIf $ds = "cleanDirectory" Then
Local $f0[3][2] = [["path", "__REQUIRED__"], ["companyName", ""], ["force", "0"]]
Return $f0
ElseIf $ds = "file" Then
Local $f0[3][2] = [["path", "__REQUIRED__"], ["companyName", ""], ["force", "0"]]
Return $f0
ElseIf $ds = "folder" Then
Local $f0[3][2] = [["path", "__REQUIRED__"], ["force", "0"]]
Return $f0
EndIf
EndFunc
Func _12i($f1, $f2, $f3, $f0)
Local $c5 = $f1 & "~~"
Local $5h = 0
Local $f4 = UBound($f0)
For $4p = 0 To $f4 - 1
Local $f5 = False
For $eo = 0 To UBound($f2) - 1
If $f0[$4p][0] = $f2[$eo] Then
$c5 &= $f3[$eo] & "~~"
$f5 = True
$5h += 1
EndIf
Next
If $f5 = False Then
Local $f6 = $f0[$4p][1]
If $f6 = "__REQUIRED__" Then
MsgBox(16, "Fail", "Attribute " & $f0[$4p][0] & " for tool " & $f1 & " is required")
Exit
EndIf
$c5 &= $f6 & "~~"
$5h += 1
EndIf
Next
If $5h <> $f4 Then
MsgBox(16, "Fail", "Values for tool " & $f1 & " are invalid ! Number of expected values " & $5h & " and number of values received " & $f4)
Exit
EndIf
$c5 = StringTrimRight($c5, 2)
Return $c5
EndFunc
Local $f7 = _zl("/tools/tool")
For $4p = 1 To $f7[0]
Local $f8 = _zr("/tools/tool[" & $4p & "]", "name")
Local $f9 = ObjCreate("Scripting.Dictionary")
Local $fa = ObjCreate("Scripting.Dictionary")
Local $fb = ObjCreate("Scripting.Dictionary")
Local $fc = ObjCreate("Scripting.Dictionary")
Local $fd = ObjCreate("Scripting.Dictionary")
$f9.add("key", $fa)
$f9.add("element", $fb)
$f9.add("uninstall", $fc)
$f9.add("process", $fd)
$d6.add($f8, $f9)
Next
Func _12j($dt = False)
If $dt = True Then
_114(@CRLF & "- Search Tools -" & @CRLF)
EndIf
Local Const $fe = [ "process", "uninstall", "task", "desktop", "desktopCommon", "download", "programFiles", "homeDrive", "appData", "appDataCommon", "appDataLocal", "windowsFolder", "softwareKey", "registryKey", "searchRegistryKey", "startMenu", "cleanDirectory", "file", "folder"]
Local $f7 = _zl("/tools/tool")
For $ff = 0 To UBound($fe) - 1
Local $fg = $fe[$ff]
Local $f0 = _12h($fg)
Local $fh[0][UBound($f0) + 1]
For $4p = 1 To $f7[0]
Local $f8 = _zr("/tools/tool[" & $4p & "]", "name")
Local $fi = _zl("/tools/tool[" & $4p & "]/*")
For $eo = 1 To $fi[0]
Local $1w = $fi[$eo]
If $1w = $fg Then
Local $b9[1], $ba[1]
_zt("/tools/tool[" & $4p & "]/*[" & $eo & "]", $b9, $ba)
Local $fj = _12i($f8, $b9, $ba, $f0)
_vv($fh, $fj, 0, "~~")
EndIf
Next
Next
Switch $fg
Case "process"
_127($fh)
Case "uninstall"
_129($fh)
Case "task"
_128($fh)
Case "desktop"
_123(@DesktopDir, $fh)
Case "desktopCommon"
_124(@DesktopCommonDir, $fh)
Case "download"
_123(@UserProfileDir & "\Downloads", $fh)
Case "programFiles"
_12a($fh)
Case "homeDrive"
_124(@HomeDrive, $fh)
Case "appDataCommon"
_124(@AppDataCommonDir, $fh)
Case "appDataLocal"
_124(@LocalAppDataDir, $fh)
Case "windowsFolder"
_124(@WindowsDir, $fh)
Case "softwareKey"
_12b($fh)
Case "registryKey"
_12d($fh)
Case "searchRegistryKey"
_12c($fh)
Case "startMenu"
_124(@AppDataCommonDir & "\Microsoft\Windows\Start Menu\Programs", $fh)
Case "cleanDirectory"
_12e($fh)
Case "file"
_12f($fh)
Case "folder"
_12g($fh)
EndSwitch
_11n()
Next
If $dt = True Then
Local $fk = False
Local Const $fl[4] = ["process", "uninstall", "element", "key"]
Local Const $fm = "Warning, folder " & @AppDataDir & "\ZHP exists and contains the quarantines of the ZHP tools. At the request of the publisher (Nicolas Coolman) this folder is not deleted. "
Local $fn = False
Local Const $fo = _11a(@AppDataDir & "\ZHP")
For $fp In $d6
Local $fq = $d6.Item($fp)
Local $fr = False
For $fs = 0 To UBound($fl) - 1
Local $ft = $fl[$fs]
Local $fu = $fq.Item($ft)
Local $fv = $fu.Keys
If UBound($fv) > 0 Then
If $fr = False Then
$fr = True
$fk = True
_114(@CRLF & "  ## " & $fp & " found")
EndIf
For $fw = 0 To UBound($fv) - 1
Local $fx = $fv[$fw]
Local $fy = $fu.Item($fx)
_11m($ft, $fx, $fy)
Next
If $fp = "ZHP Tools" And $fo = True And $fn = False Then
_114("     [!] " & $fm)
$fn = True
EndIf
EndIf
Next
Next
If $fn = False And $fo = True Then
_114(@CRLF & "  ## " & "ZHP Tools" & " found")
_114("     [!] " & $fm)
ElseIf $fk = False Then
_114("  [I] No tools found")
EndIf
EndIf
_11n()
EndFunc
If Not IsAdmin() Then
MsgBox(16, $80, $82)
_10z()
EndIf
If $7p = False Then
_111()
EndIf
Global $fz = "KpRm"
Global $c9 = "kprm-" & @YEAR & @MON & @MDAY & @HOUR & @MIN & ".txt"
Local Const $g0 = GUICreate($fz, 500, 195, 202, 112)
Local Const $g1 = GUICtrlCreateGroup("Actions", 8, 8, 400, 153)
Local Const $g2 = GUICtrlCreateCheckbox($7s, 16, 40, 129, 17)
Local Const $g3 = GUICtrlCreateCheckbox($7t, 16, 80, 190, 17)
Local Const $g4 = GUICtrlCreateCheckbox($7u, 16, 120, 190, 17)
Local Const $g5 = GUICtrlCreateCheckbox($7v, 220, 40, 137, 17)
Local Const $g6 = GUICtrlCreateCheckbox($7w, 220, 80, 137, 17)
Local Const $g7 = GUICtrlCreateCheckbox($7x, 220, 120, 180, 17)
Global $dj = GUICtrlCreateProgress(8, 170, 480, 17)
GUICtrlCreateGroup("", -99, -99, 1, 1)
GUICtrlSetState($g2, 1)
Local Const $g8 = GUICtrlCreatePic(@TempDir & "\kprm-logo.gif", 415, 16, 76, 76)
Local Const $g9 = GUICtrlCreateButton($7y, 415, 120, 75, 40)
GUISetState(@SW_SHOW)
While 1
Local $ga = GUIGetMsg()
Switch $ga
Case $0
Exit
Case $g9
_12m()
EndSwitch
WEnd
Func _12k()
Local Const $7n = @HomeDrive & "\KPRM"
If Not FileExists($7n) Then
DirCreate($7n)
EndIf
If Not FileExists($7n) Then
MsgBox(16, $80, $81)
Exit
EndIf
EndFunc
Func _12l()
_12k()
_114("#################################################################################################################" & @CRLF)
_114("# Run at " & _3o())
_114("# KpRm (Kernel-panik) version " & $7q)
_114("# Website https://kernel-panik.me/tool/kprm/")
_114("# Run by " & @UserName & " from " & @WorkingDir)
_114("# Computer Name: " & @ComputerName)
_114("# OS: " & _11c() & " " & @OSArch & " (" & @OSBuild & ") " & @OSServicePack)
_11o()
EndFunc
Func _12m()
_12l()
_11n()
If GUICtrlRead($g5) = $1 Then
_11v()
EndIf
_11n()
If GUICtrlRead($g2) = $1 Then
_12j(False)
_12j(True)
Else
_11n(32)
EndIf
_11n()
If GUICtrlRead($g7) = $1 Then
_11x()
EndIf
_11n()
If GUICtrlRead($g6) = $1 Then
_11w()
EndIf
_11n()
If GUICtrlRead($g3) = $1 Then
_11p()
EndIf
_11n()
If GUICtrlRead($g4) = $1 Then
_11u()
EndIf
GUICtrlSetData($dj, 100)
MsgBox(64, "OK", $7z)
_10z(True)
EndFunc
