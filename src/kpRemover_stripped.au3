#RequireAdmin
Global Const $0 = -3
Global Const $1 = 1
Global Const $2 = 0x00040000
Global Const $3 = 1
Global Const $4 = 2
Global Enum $5 = 0, $6, $7, $8, $9, $a, $b
Global Const $c = 2
Global Const $d = 1
Global Const $e = 2
Global Const $f = 1
Global Const $g = 2
Global Const $h = 1
Global Const $i = "struct;word Year;word Month;word Dow;word Day;word Hour;word Minute;word Second;word MSeconds;endstruct"
Global Const $j = 0
Global Const $k = 1
Global Const $l = 2
Global Const $m= 1
Global Const $n = 0x10000000
Global Const $o = 0
Global Const $p = 0
Global Const $q = 4
Global Const $r = 8
Global Const $s = 16
Global Const $t = 0
Global Const $u = 0
Global Const $v = 1
Global Const $w = 2
Global Const $x = 0
Global Const $y = 1
Global Const $0z = 2
Global Const $10 = 3
Global Const $11 = 4
Global Const $12 = 'struct;dword OSVersionInfoSize;dword MajorVersion;dword MinorVersion;dword BuildNumber;dword PlatformId;wchar CSDVersion[128];endstruct'
Global Const $13 = _1v()
Func _1v()
Local $14 = DllStructCreate($12)
DllStructSetData($14, 1, DllStructGetSize($14))
Local $15 = DllCall('kernel32.dll', 'bool', 'GetVersionExW', 'struct*', $14)
If @error Or Not $15[0] Then Return SetError(@error, @extended, 0)
Return BitOR(BitShift(DllStructGetData($14, 2), -8), DllStructGetData($14, 3))
EndFunc
Global Const $16 = 0x001D
Global Const $17 = 0x001E
Global Const $18 = 0x001F
Global Const $19 = 0x0020
Global Const $1a = 0x1003
Global Const $1b = 0x0028
Global Const $1c = 0x0029
Global Const $1d = 0x007F
Global Const $1e = 0x0400
Func _2e($1f = 0, $1g = 0, $1h = 0, $1i = '')
If Not $1f Then $1f = 0x0400
Local $1j = 'wstr'
If Not StringStripWS($1i, $d + $e) Then
$1j = 'ptr'
$1i = 0
EndIf
Local $15 = DllCall('kernel32.dll', 'int', 'GetDateFormatW', 'dword', $1f, 'dword', $1h, 'struct*', $1g, $1j, $1i, 'wstr', '', 'int', 2048)
If @error Or Not $15[0] Then Return SetError(@error, @extended, '')
Return $15[5]
EndFunc
Func _2h($1f, $1k)
Local $15 = DllCall('kernel32.dll', 'int', 'GetLocaleInfoW', 'dword', $1f, 'dword', $1k, 'wstr', '', 'int', 2048)
If @error Or Not $15[0] Then Return SetError(@error + 10, @extended, '')
Return $15[3]
EndFunc
Func _31($1l, $1m, $1n)
Local $1o[4]
Local $1p[4]
Local $1q
$1l = StringLeft($1l, 1)
If StringInStr("D,M,Y,w,h,n,s", $1l) = 0 Or $1l = "" Then
Return SetError(1, 0, 0)
EndIf
If Not StringIsInt($1m) Then
Return SetError(2, 0, 0)
EndIf
If Not _37($1n) Then
Return SetError(3, 0, 0)
EndIf
_3g($1n, $1p, $1o)
If $1l = "d" Or $1l = "w" Then
If $1l = "w" Then $1m = $1m * 7
$1q = _3j($1p[1], $1p[2], $1p[3]) + $1m
_3l($1q, $1p[1], $1p[2], $1p[3])
EndIf
If $1l = "m" Then
$1p[2] = $1p[2] + $1m
While $1p[2] > 12
$1p[2] = $1p[2] - 12
$1p[1] = $1p[1] + 1
WEnd
While $1p[2] < 1
$1p[2] = $1p[2] + 12
$1p[1] = $1p[1] - 1
WEnd
EndIf
If $1l = "y" Then
$1p[1] = $1p[1] + $1m
EndIf
If $1l = "h" Or $1l = "n" Or $1l = "s" Then
Local $1r = _3w($1o[1], $1o[2], $1o[3]) / 1000
If $1l = "h" Then $1r = $1r + $1m * 3600
If $1l = "n" Then $1r = $1r + $1m * 60
If $1l = "s" Then $1r = $1r + $1m
Local $1s = Int($1r /(24 * 60 * 60))
$1r = $1r - $1s * 24 * 60 * 60
If $1r < 0 Then
$1s = $1s - 1
$1r = $1r + 24 * 60 * 60
EndIf
$1q = _3j($1p[1], $1p[2], $1p[3]) + $1s
_3l($1q, $1p[1], $1p[2], $1p[3])
_3v($1r * 1000, $1o[1], $1o[2], $1o[3])
EndIf
Local $1t = _3z($1p[1])
If $1t[$1p[2]] < $1p[3] Then $1p[3] = $1t[$1p[2]]
$1n = $1p[1] & '/' & StringRight("0" & $1p[2], 2) & '/' & StringRight("0" & $1p[3], 2)
If $1o[0] > 0 Then
If $1o[0] > 2 Then
$1n = $1n & " " & StringRight("0" & $1o[1], 2) & ':' & StringRight("0" & $1o[2], 2) & ':' & StringRight("0" & $1o[3], 2)
Else
$1n = $1n & " " & StringRight("0" & $1o[1], 2) & ':' & StringRight("0" & $1o[2], 2)
EndIf
EndIf
Return $1n
EndFunc
Func _32($1u, $1v = Default)
Local Const $1w = 128
If $1v = Default Then $1v = 0
$1u = Int($1u)
If $1u < 1 Or $1u > 7 Then Return SetError(1, 0, "")
Local $1g = DllStructCreate($i)
DllStructSetData($1g, "Year", BitAND($1v, $1w) ? 2007 : 2006)
DllStructSetData($1g, "Month", 1)
DllStructSetData($1g, "Day", $1u)
Return _2e(BitAND($1v, $4) ? $1e : $1d, $1g, 0, BitAND($1v, $3) ? "ddd" : "dddd")
EndFunc
Func _35($1x)
If StringIsInt($1x) Then
Select
Case Mod($1x, 4) = 0 And Mod($1x, 100) <> 0
Return 1
Case Mod($1x, 400) = 0
Return 1
Case Else
Return 0
EndSelect
EndIf
Return SetError(1, 0, 0)
EndFunc
Func _36($1m)
$1m = Int($1m)
Return $1m >= 1 And $1m <= 12
EndFunc
Func _37($1n)
Local $1p[4], $1o[4]
_3g($1n, $1p, $1o)
If Not StringIsInt($1p[1]) Then Return 0
If Not StringIsInt($1p[2]) Then Return 0
If Not StringIsInt($1p[3]) Then Return 0
$1p[1] = Int($1p[1])
$1p[2] = Int($1p[2])
$1p[3] = Int($1p[3])
Local $1t = _3z($1p[1])
If $1p[1] < 1000 Or $1p[1] > 2999 Then Return 0
If $1p[2] < 1 Or $1p[2] > 12 Then Return 0
If $1p[3] < 1 Or $1p[3] > $1t[$1p[2]] Then Return 0
If $1o[0] < 1 Then Return 1
If $1o[0] < 2 Then Return 0
If $1o[0] = 2 Then $1o[3] = "00"
If Not StringIsInt($1o[1]) Then Return 0
If Not StringIsInt($1o[2]) Then Return 0
If Not StringIsInt($1o[3]) Then Return 0
$1o[1] = Int($1o[1])
$1o[2] = Int($1o[2])
$1o[3] = Int($1o[3])
If $1o[1] < 0 Or $1o[1] > 23 Then Return 0
If $1o[2] < 0 Or $1o[2] > 59 Then Return 0
If $1o[3] < 0 Or $1o[3] > 59 Then Return 0
Return 1
EndFunc
Func _3f($1n, $1l)
Local $1p[4], $1o[4]
Local $1y = "", $1z = ""
Local $20, $21, $22 = ""
If Not _37($1n) Then
Return SetError(1, 0, "")
EndIf
If $1l < 0 Or $1l > 5 Or Not IsInt($1l) Then
Return SetError(2, 0, "")
EndIf
_3g($1n, $1p, $1o)
Switch $1l
Case 0
$22 = _2h($1e, $18)
If Not @error And Not($22 = '') Then
$1y = $22
Else
$1y = "M/d/yyyy"
EndIf
If $1o[0] > 1 Then
$22 = _2h($1e, $1a)
If Not @error And Not($22 = '') Then
$1z = $22
Else
$1z = "h:mm:ss tt"
EndIf
EndIf
Case 1
$22 = _2h($1e, $19)
If Not @error And Not($22 = '') Then
$1y = $22
Else
$1y = "dddd, MMMM dd, yyyy"
EndIf
Case 2
$22 = _2h($1e, $18)
If Not @error And Not($22 = '') Then
$1y = $22
Else
$1y = "M/d/yyyy"
EndIf
Case 3
If $1o[0] > 1 Then
$22 = _2h($1e, $1a)
If Not @error And Not($22 = '') Then
$1z = $22
Else
$1z = "h:mm:ss tt"
EndIf
EndIf
Case 4
If $1o[0] > 1 Then
$1z = "hh:mm"
EndIf
Case 5
If $1o[0] > 1 Then
$1z = "hh:mm:ss"
EndIf
EndSwitch
If $1y <> "" Then
$22 = _2h($1e, $16)
If Not @error And Not($22 = '') Then
$1y = StringReplace($1y, "/", $22)
EndIf
Local $23 = _3h($1p[1], $1p[2], $1p[3])
$1p[3] = StringRight("0" & $1p[3], 2)
$1p[2] = StringRight("0" & $1p[2], 2)
$1y = StringReplace($1y, "d", "@")
$1y = StringReplace($1y, "m", "#")
$1y = StringReplace($1y, "y", "&")
$1y = StringReplace($1y, "@@@@", _32($23, 0))
$1y = StringReplace($1y, "@@@", _32($23, 1))
$1y = StringReplace($1y, "@@", $1p[3])
$1y = StringReplace($1y, "@", StringReplace(StringLeft($1p[3], 1), "0", "") & StringRight($1p[3], 1))
$1y = StringReplace($1y, "####", _3k($1p[2], 0))
$1y = StringReplace($1y, "###", _3k($1p[2], 1))
$1y = StringReplace($1y, "##", $1p[2])
$1y = StringReplace($1y, "#", StringReplace(StringLeft($1p[2], 1), "0", "") & StringRight($1p[2], 1))
$1y = StringReplace($1y, "&&&&", $1p[1])
$1y = StringReplace($1y, "&&", StringRight($1p[1], 2))
EndIf
If $1z <> "" Then
$22 = _2h($1e, $1b)
If Not @error And Not($22 = '') Then
$20 = $22
Else
$20 = "AM"
EndIf
$22 = _2h($1e, $1c)
If Not @error And Not($22 = '') Then
$21 = $22
Else
$21 = "PM"
EndIf
$22 = _2h($1e, $17)
If Not @error And Not($22 = '') Then
$1z = StringReplace($1z, ":", $22)
EndIf
If StringInStr($1z, "tt") Then
If $1o[1] < 12 Then
$1z = StringReplace($1z, "tt", $20)
If $1o[1] = 0 Then $1o[1] = 12
Else
$1z = StringReplace($1z, "tt", $21)
If $1o[1] > 12 Then $1o[1] = $1o[1] - 12
EndIf
EndIf
$1o[1] = StringRight("0" & $1o[1], 2)
$1o[2] = StringRight("0" & $1o[2], 2)
$1o[3] = StringRight("0" & $1o[3], 2)
$1z = StringReplace($1z, "hh", StringFormat("%02d", $1o[1]))
$1z = StringReplace($1z, "h", StringReplace(StringLeft($1o[1], 1), "0", "") & StringRight($1o[1], 1))
$1z = StringReplace($1z, "mm", StringFormat("%02d", $1o[2]))
$1z = StringReplace($1z, "ss", StringFormat("%02d", $1o[3]))
$1y = StringStripWS($1y & " " & $1z, $d + $e)
EndIf
Return $1y
EndFunc
Func _3g($1n, ByRef $24, ByRef $25)
Local $26 = StringSplit($1n, " T")
If $26[0] > 0 Then $24 = StringSplit($26[1], "/-.")
If $26[0] > 1 Then
$25 = StringSplit($26[2], ":")
If UBound($25) < 4 Then ReDim $25[4]
Else
Dim $25[4]
EndIf
If UBound($24) < 4 Then ReDim $24[4]
For $27 = 1 To 3
If StringIsInt($24[$27]) Then
$24[$27] = Int($24[$27])
Else
$24[$27] = -1
EndIf
If StringIsInt($25[$27]) Then
$25[$27] = Int($25[$27])
Else
$25[$27] = 0
EndIf
Next
Return 1
EndFunc
Func _3h($1x, $28, $29)
If Not _37($1x & "/" & $28 & "/" & $29) Then
Return SetError(1, 0, "")
EndIf
Local $2a = Int((14 - $28) / 12)
Local $2b = $1x - $2a
Local $2c = $28 +(12 * $2a) - 2
Local $2d = Mod($29 + $2b + Int($2b / 4) - Int($2b / 100) + Int($2b / 400) + Int((31 * $2c) / 12), 7)
Return $2d + 1
EndFunc
Func _3j($1x, $28, $29)
If Not _37(StringFormat("%04d/%02d/%02d", $1x, $28, $29)) Then
Return SetError(1, 0, "")
EndIf
If $28 < 3 Then
$28 = $28 + 12
$1x = $1x - 1
EndIf
Local $2a = Int($1x / 100)
Local $2e = Int($2a / 4)
Local $2f = 2 - $2a + $2e
Local $2g = Int(1461 *($1x + 4716) / 4)
Local $2h = Int(153 *($28 + 1) / 5)
Local $1q = $2f + $29 + $2g + $2h - 1524.5
Return $1q
EndFunc
Func _3k($2i, $1v = Default)
If $1v = Default Then $1v = 0
$2i = Int($2i)
If Not _36($2i) Then Return SetError(1, 0, "")
Local $1g = DllStructCreate($i)
DllStructSetData($1g, "Year", @YEAR)
DllStructSetData($1g, "Month", $2i)
DllStructSetData($1g, "Day", 1)
Return _2e(BitAND($1v, $4) ? $1e : $1d, $1g, 0, BitAND($1v, $3) ? "MMM" : "MMMM")
EndFunc
Func _3l($1q, ByRef $1x, ByRef $28, ByRef $29)
If $1q < 0 Or Not IsNumber($1q) Then
Return SetError(1, 0, 0)
EndIf
Local $2j = Int($1q + 0.5)
Local $2k = Int(($2j - 1867216.25) / 36524.25)
Local $2l = Int($2k / 4)
Local $2a = $2j + 1 + $2k - $2l
Local $2e = $2a + 1524
Local $2f = Int(($2e - 122.1) / 365.25)
Local $2d = Int(365.25 * $2f)
Local $2g = Int(($2e - $2d) / 30.6001)
Local $2h = Int(30.6001 * $2g)
$29 = $2e - $2d - $2h
If $2g - 1 < 13 Then
$28 = $2g - 1
Else
$28 = $2g - 13
EndIf
If $28 < 3 Then
$1x = $2f - 4715
Else
$1x = $2f - 4716
EndIf
$1x = StringFormat("%04d", $1x)
$28 = StringFormat("%02d", $28)
$29 = StringFormat("%02d", $29)
Return $1x & "/" & $28 & "/" & $29
EndFunc
Func _3o()
Return _3f(@YEAR & "/" & @MON & "/" & @MDAY & " " & @HOUR & ":" & @MIN & ":" & @SEC, 0)
EndFunc
Func _3p()
Return @YEAR & "/" & @MON & "/" & @MDAY & " " & @HOUR & ":" & @MIN & ":" & @SEC
EndFunc
Func _3v($2m, ByRef $2n, ByRef $2o, ByRef $2p)
If Number($2m) > 0 Then
$2m = Int($2m / 1000)
$2n = Int($2m / 3600)
$2m = Mod($2m, 3600)
$2o = Int($2m / 60)
$2p = Mod($2m, 60)
Return 1
ElseIf Number($2m) = 0 Then
$2n = 0
$2m = 0
$2o = 0
$2p = 0
Return 1
Else
Return SetError(1, 0, 0)
EndIf
EndFunc
Func _3w($2n = @HOUR, $2o = @MIN, $2p = @SEC)
If StringIsInt($2n) And StringIsInt($2o) And StringIsInt($2p) Then
Local $2m = 1000 *((3600 * $2n) +(60 * $2o) + $2p)
Return $2m
Else
Return SetError(1, 0, 0)
EndIf
EndFunc
Func _3z($1x)
Local $2q = [12, 31,(_35($1x) ? 29 : 28), 31, 30, 31, 30, 31, 31, 30, 31, 30, 31]
Return $2q
EndFunc
Func _51($2r, $2s, $2t = 0, $2u = 0, $2v = 0, $2w = "wparam", $2x = "lparam", $2y = "lresult")
Local $2z = DllCall("user32.dll", $2y, "SendMessageW", "hwnd", $2r, "uint", $2s, $2w, $2t, $2x, $2u)
If @error Then Return SetError(@error, @extended, "")
If $2v >= 0 And $2v <= 4 Then Return $2z[$2v]
Return $2z
EndFunc
Global Const $30 = Ptr(-1)
Global Const $31 = Ptr(-1)
Global Const $32 = 0x0100
Global Const $33 = 0x2000
Global Const $34 = 0x8000
Global Const $35 = BitShift($32, 8)
Global Const $36 = BitShift($33, 8)
Global Const $37 = BitShift($34, 8)
Global Const $38 = 0x8000000
Func _d0($39, $3a)
Local $2z = DllCall("user32.dll", "hwnd", "FindWindowW", "wstr", $39, "wstr", $3a)
If @error Then Return SetError(@error, @extended, 0)
Return $2z[0]
EndFunc
Func _hf($3b, $1h, $3c = 0, $3d = 0)
Local $3e = 'dword_ptr', $3f = 'dword_ptr'
If IsString($3c) Then
$3e = 'wstr'
EndIf
If IsString($3d) Then
$3f = 'wstr'
EndIf
DllCall('shell32.dll', 'none', 'SHChangeNotify', 'long', $3b, 'uint', $1h, $3e, $3c, $3f, $3d)
If @error Then Return SetError(@error, @extended, 0)
Return 1
EndFunc
Global Const $3g = 11
Global $3h[$3g]
Global Const $3i = "struct;uint Mask;int Item;int SubItem;uint State;uint StateMask;ptr Text;int TextMax;int Image;lparam Param;" & "int Indent;int GroupID;uint Columns;ptr pColumns;ptr piColFmt;int iGroup;endstruct"
#Au3Stripper_Ignore_Funcs=__ArrayDisplay_SortCallBack
Func __ArrayDisplay_SortCallBack($3j, $3k, $2r)
If $3h[3] = $3h[4] Then
If Not $3h[7] Then
$3h[5] *= -1
$3h[7] = 1
EndIf
Else
$3h[7] = 1
EndIf
$3h[6] = $3h[3]
Local $3l = _vr($2r, $3j, $3h[3])
Local $3m = _vr($2r, $3k, $3h[3])
If $3h[8] = 1 Then
If(StringIsFloat($3l) Or StringIsInt($3l)) Then $3l = Number($3l)
If(StringIsFloat($3m) Or StringIsInt($3m)) Then $3m = Number($3m)
EndIf
Local $3n
If $3h[8] < 2 Then
$3n = 0
If $3l < $3m Then
$3n = -1
ElseIf $3l > $3m Then
$3n = 1
EndIf
Else
$3n = DllCall('shlwapi.dll', 'int', 'StrCmpLogicalW', 'wstr', $3l, 'wstr', $3m)[0]
EndIf
$3n = $3n * $3h[5]
Return $3n
EndFunc
Func _vr($2r, $3o, $3p = 0)
Local $3q = DllStructCreate("wchar Text[4096]")
Local $3r = DllStructGetPtr($3q)
Local $3s = DllStructCreate($3i)
DllStructSetData($3s, "SubItem", $3p)
DllStructSetData($3s, "TextMax", 4096)
DllStructSetData($3s, "Text", $3r)
If IsHWnd($2r) Then
DllCall("user32.dll", "lresult", "SendMessageW", "hwnd", $2r, "uint", 0x1073, "wparam", $3o, "struct*", $3s)
Else
Local $3t = DllStructGetPtr($3s)
GUICtrlSendMsg($2r, 0x1073, $3o, $3t)
EndIf
Return DllStructGetData($3q, "Text")
EndFunc
Global Enum $3u, $3v, $3w, $3x, $3y, $3z, $40, $41
Func _vv(ByRef $42, $43, $44 = 0, $45 = "|", $46 = @CRLF, $47 = $3u)
If $44 = Default Then $44 = 0
If $45 = Default Then $45 = "|"
If $46 = Default Then $46 = @CRLF
If $47 = Default Then $47 = $3u
If Not IsArray($42) Then Return SetError(1, 0, -1)
Local $48 = UBound($42, $k)
Local $49 = 0
Switch $47
Case $3w
$49 = Int
Case $3x
$49 = Number
Case $3y
$49 = Ptr
Case $3z
$49 = Hwnd
Case $40
$49 = String
Case $41
$49 = "Boolean"
EndSwitch
Switch UBound($42, $j)
Case 1
If $47 = $3v Then
ReDim $42[$48 + 1]
$42[$48] = $43
Return $48
EndIf
If IsArray($43) Then
If UBound($43, $j) <> 1 Then Return SetError(5, 0, -1)
$49 = 0
Else
Local $4a = StringSplit($43, $45, $g + $f)
If UBound($4a, $k) = 1 Then
$4a[0] = $43
EndIf
$43 = $4a
EndIf
Local $4b = UBound($43, $k)
ReDim $42[$48 + $4b]
For $4c = 0 To $4b - 1
If String($49) = "Boolean" Then
Switch $43[$4c]
Case "True", "1"
$42[$48 + $4c] = True
Case "False", "0", ""
$42[$48 + $4c] = False
EndSwitch
ElseIf IsFunc($49) Then
$42[$48 + $4c] = $49($43[$4c])
Else
$42[$48 + $4c] = $43[$4c]
EndIf
Next
Return $48 + $4b - 1
Case 2
Local $4d = UBound($42, $l)
If $44 < 0 Or $44 > $4d - 1 Then Return SetError(4, 0, -1)
Local $4e, $4f = 0, $4g
If IsArray($43) Then
If UBound($43, $j) <> 2 Then Return SetError(5, 0, -1)
$4e = UBound($43, $k)
$4f = UBound($43, $l)
$49 = 0
Else
Local $4h = StringSplit($43, $46, $g + $f)
$4e = UBound($4h, $k)
Local $4a[$4e][0], $4i
For $4c = 0 To $4e - 1
$4i = StringSplit($4h[$4c], $45, $g + $f)
$4g = UBound($4i)
If $4g > $4f Then
$4f = $4g
ReDim $4a[$4e][$4f]
EndIf
For $4j = 0 To $4g - 1
$4a[$4c][$4j] = $4i[$4j]
Next
Next
$43 = $4a
EndIf
If UBound($43, $l) + $44 > UBound($42, $l) Then Return SetError(3, 0, -1)
ReDim $42[$48 + $4e][$4d]
For $4k = 0 To $4e - 1
For $4j = 0 To $4d - 1
If $4j < $44 Then
$42[$4k + $48][$4j] = ""
ElseIf $4j - $44 > $4f - 1 Then
$42[$4k + $48][$4j] = ""
Else
If String($49) = "Boolean" Then
Switch $43[$4k][$4j - $44]
Case "True", "1"
$42[$4k + $48][$4j] = True
Case "False", "0", ""
$42[$4k + $48][$4j] = False
EndSwitch
ElseIf IsFunc($49) Then
$42[$4k + $48][$4j] = $49($43[$4k][$4j - $44])
Else
$42[$4k + $48][$4j] = $43[$4k][$4j - $44]
EndIf
EndIf
Next
Next
Case Else
Return SetError(2, 0, -1)
EndSwitch
Return UBound($42, $k) - 1
EndFunc
Func _w0(ByRef $4l, Const ByRef $4m, $44 = 0)
If $44 = Default Then $44 = 0
If Not IsArray($4l) Then Return SetError(1, 0, -1)
If Not IsArray($4m) Then Return SetError(2, 0, -1)
Local $4n = UBound($4l, $j)
Local $4o = UBound($4m, $j)
Local $4p = UBound($4l, $k)
Local $4q = UBound($4m, $k)
If $44 < 0 Or $44 > $4q - 1 Then Return SetError(6, 0, -1)
Switch $4n
Case 1
If $4o <> 1 Then Return SetError(4, 0, -1)
ReDim $4l[$4p + $4q - $44]
For $4c = $44 To $4q - 1
$4l[$4p + $4c - $44] = $4m[$4c]
Next
Case 2
If $4o <> 2 Then Return SetError(4, 0, -1)
Local $4r = UBound($4l, $l)
If UBound($4m, $l) <> $4r Then Return SetError(5, 0, -1)
ReDim $4l[$4p + $4q - $44][$4r]
For $4c = $44 To $4q - 1
For $4j = 0 To $4r - 1
$4l[$4p + $4c - $44][$4j] = $4m[$4c][$4j]
Next
Next
Case Else
Return SetError(3, 0, -1)
EndSwitch
Return UBound($4l, $k)
EndFunc
Func _we(Const ByRef $42, $43, $44 = 0, $4s = 0, $4t = 0, $4u = 0, $4v = 1, $3p = -1, $4w = False)
If $44 = Default Then $44 = 0
If $4s = Default Then $4s = 0
If $4t = Default Then $4t = 0
If $4u = Default Then $4u = 0
If $4v = Default Then $4v = 1
If $3p = Default Then $3p = -1
If $4w = Default Then $4w = False
If Not IsArray($42) Then Return SetError(1, 0, -1)
Local $48 = UBound($42) - 1
If $48 = -1 Then Return SetError(3, 0, -1)
Local $4d = UBound($42, $l) - 1
Local $4x = False
If $4u = 2 Then
$4u = 0
$4x = True
EndIf
If $4w Then
If UBound($42, $j) = 1 Then Return SetError(5, 0, -1)
If $4s < 1 Or $4s > $4d Then $4s = $4d
If $44 < 0 Then $44 = 0
If $44 > $4s Then Return SetError(4, 0, -1)
Else
If $4s < 1 Or $4s > $48 Then $4s = $48
If $44 < 0 Then $44 = 0
If $44 > $4s Then Return SetError(4, 0, -1)
EndIf
Local $4y = 1
If Not $4v Then
Local $4z = $44
$44 = $4s
$4s = $4z
$4y = -1
EndIf
Switch UBound($42, $j)
Case 1
If Not $4u Then
If Not $4t Then
For $4c = $44 To $4s Step $4y
If $4x And VarGetType($42[$4c]) <> VarGetType($43) Then ContinueLoop
If $42[$4c] = $43 Then Return $4c
Next
Else
For $4c = $44 To $4s Step $4y
If $4x And VarGetType($42[$4c]) <> VarGetType($43) Then ContinueLoop
If $42[$4c] == $43 Then Return $4c
Next
EndIf
Else
For $4c = $44 To $4s Step $4y
If $4u = 3 Then
If StringRegExp($42[$4c], $43) Then Return $4c
Else
If StringInStr($42[$4c], $43, $4t) > 0 Then Return $4c
EndIf
Next
EndIf
Case 2
Local $50
If $4w Then
$50 = $48
If $3p > $50 Then $3p = $50
If $3p < 0 Then
$3p = 0
Else
$50 = $3p
EndIf
Else
$50 = $4d
If $3p > $50 Then $3p = $50
If $3p < 0 Then
$3p = 0
Else
$50 = $3p
EndIf
EndIf
For $4j = $3p To $50
If Not $4u Then
If Not $4t Then
For $4c = $44 To $4s Step $4y
If $4w Then
If $4x And VarGetType($42[$4j][$4c]) <> VarGetType($43) Then ContinueLoop
If $42[$4j][$4c] = $43 Then Return $4c
Else
If $4x And VarGetType($42[$4c][$4j]) <> VarGetType($43) Then ContinueLoop
If $42[$4c][$4j] = $43 Then Return $4c
EndIf
Next
Else
For $4c = $44 To $4s Step $4y
If $4w Then
If $4x And VarGetType($42[$4j][$4c]) <> VarGetType($43) Then ContinueLoop
If $42[$4j][$4c] == $43 Then Return $4c
Else
If $4x And VarGetType($42[$4c][$4j]) <> VarGetType($43) Then ContinueLoop
If $42[$4c][$4j] == $43 Then Return $4c
EndIf
Next
EndIf
Else
For $4c = $44 To $4s Step $4y
If $4u = 3 Then
If $4w Then
If StringRegExp($42[$4j][$4c], $43) Then Return $4c
Else
If StringRegExp($42[$4c][$4j], $43) Then Return $4c
EndIf
Else
If $4w Then
If StringInStr($42[$4j][$4c], $43, $4t) > 0 Then Return $4c
Else
If StringInStr($42[$4c][$4j], $43, $4t) > 0 Then Return $4c
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
Func _wj(ByRef $42, $51, $52, $53 = True)
If $51 > $52 Then Return
Local $54 = $52 - $51 + 1
Local $4c, $4j, $55, $56, $57, $58, $59, $5a
If $54 < 45 Then
If $53 Then
$4c = $51
While $4c < $52
$4j = $4c
$56 = $42[$4c + 1]
While $56 < $42[$4j]
$42[$4j + 1] = $42[$4j]
$4j -= 1
If $4j + 1 = $51 Then ExitLoop
WEnd
$42[$4j + 1] = $56
$4c += 1
WEnd
Else
While 1
If $51 >= $52 Then Return 1
$51 += 1
If $42[$51] < $42[$51 - 1] Then ExitLoop
WEnd
While 1
$55 = $51
$51 += 1
If $51 > $52 Then ExitLoop
$58 = $42[$55]
$59 = $42[$51]
If $58 < $59 Then
$59 = $58
$58 = $42[$51]
EndIf
$55 -= 1
While $58 < $42[$55]
$42[$55 + 2] = $42[$55]
$55 -= 1
WEnd
$42[$55 + 2] = $58
While $59 < $42[$55]
$42[$55 + 1] = $42[$55]
$55 -= 1
WEnd
$42[$55 + 1] = $59
$51 += 1
WEnd
$5a = $42[$52]
$52 -= 1
While $5a < $42[$52]
$42[$52 + 1] = $42[$52]
$52 -= 1
WEnd
$42[$52 + 1] = $5a
EndIf
Return 1
EndIf
Local $5b = BitShift($54, 3) + BitShift($54, 6) + 1
Local $5c, $5d, $5e, $5f, $5g, $5h
$5e = Ceiling(($51 + $52) / 2)
$5d = $5e - $5b
$5c = $5d - $5b
$5f = $5e + $5b
$5g = $5f + $5b
If $42[$5d] < $42[$5c] Then
$5h = $42[$5d]
$42[$5d] = $42[$5c]
$42[$5c] = $5h
EndIf
If $42[$5e] < $42[$5d] Then
$5h = $42[$5e]
$42[$5e] = $42[$5d]
$42[$5d] = $5h
If $5h < $42[$5c] Then
$42[$5d] = $42[$5c]
$42[$5c] = $5h
EndIf
EndIf
If $42[$5f] < $42[$5e] Then
$5h = $42[$5f]
$42[$5f] = $42[$5e]
$42[$5e] = $5h
If $5h < $42[$5d] Then
$42[$5e] = $42[$5d]
$42[$5d] = $5h
If $5h < $42[$5c] Then
$42[$5d] = $42[$5c]
$42[$5c] = $5h
EndIf
EndIf
EndIf
If $42[$5g] < $42[$5f] Then
$5h = $42[$5g]
$42[$5g] = $42[$5f]
$42[$5f] = $5h
If $5h < $42[$5e] Then
$42[$5f] = $42[$5e]
$42[$5e] = $5h
If $5h < $42[$5d] Then
$42[$5e] = $42[$5d]
$42[$5d] = $5h
If $5h < $42[$5c] Then
$42[$5d] = $42[$5c]
$42[$5c] = $5h
EndIf
EndIf
EndIf
EndIf
Local $5i = $51
Local $5j = $52
If(($42[$5c] <> $42[$5d]) And($42[$5d] <> $42[$5e]) And($42[$5e] <> $42[$5f]) And($42[$5f] <> $42[$5g])) Then
Local $5k = $42[$5d]
Local $5l = $42[$5f]
$42[$5d] = $42[$51]
$42[$5f] = $42[$52]
Do
$5i += 1
Until $42[$5i] >= $5k
Do
$5j -= 1
Until $42[$5j] <= $5l
$55 = $5i
While $55 <= $5j
$57 = $42[$55]
If $57 < $5k Then
$42[$55] = $42[$5i]
$42[$5i] = $57
$5i += 1
ElseIf $57 > $5l Then
While $42[$5j] > $5l
$5j -= 1
If $5j + 1 = $55 Then ExitLoop 2
WEnd
If $42[$5j] < $5k Then
$42[$55] = $42[$5i]
$42[$5i] = $42[$5j]
$5i += 1
Else
$42[$55] = $42[$5j]
EndIf
$42[$5j] = $57
$5j -= 1
EndIf
$55 += 1
WEnd
$42[$51] = $42[$5i - 1]
$42[$5i - 1] = $5k
$42[$52] = $42[$5j + 1]
$42[$5j + 1] = $5l
_wj($42, $51, $5i - 2, True)
_wj($42, $5j + 2, $52, False)
If($5i < $5c) And($5g < $5j) Then
While $42[$5i] = $5k
$5i += 1
WEnd
While $42[$5j] = $5l
$5j -= 1
WEnd
$55 = $5i
While $55 <= $5j
$57 = $42[$55]
If $57 = $5k Then
$42[$55] = $42[$5i]
$42[$5i] = $57
$5i += 1
ElseIf $57 = $5l Then
While $42[$5j] = $5l
$5j -= 1
If $5j + 1 = $55 Then ExitLoop 2
WEnd
If $42[$5j] = $5k Then
$42[$55] = $42[$5i]
$42[$5i] = $5k
$5i += 1
Else
$42[$55] = $42[$5j]
EndIf
$42[$5j] = $57
$5j -= 1
EndIf
$55 += 1
WEnd
EndIf
_wj($42, $5i, $5j, False)
Else
Local $5m = $42[$5e]
$55 = $5i
While $55 <= $5j
If $42[$55] = $5m Then
$55 += 1
ContinueLoop
EndIf
$57 = $42[$55]
If $57 < $5m Then
$42[$55] = $42[$5i]
$42[$5i] = $57
$5i += 1
Else
While $42[$5j] > $5m
$5j -= 1
WEnd
If $42[$5j] < $5m Then
$42[$55] = $42[$5i]
$42[$5i] = $42[$5j]
$5i += 1
Else
$42[$55] = $5m
EndIf
$42[$5j] = $57
$5j -= 1
EndIf
$55 += 1
WEnd
_wj($42, $51, $5i - 1, True)
_wj($42, $5j + 1, $52, False)
EndIf
EndFunc
Func _x1($5n, $5o = "*", $5p = $o, $5q = False)
Local $5r = "|", $5s = "", $5t = "", $5u = ""
$5n = StringRegExpReplace($5n, "[\\/]+$", "") & "\"
If $5p = Default Then $5p = $o
If $5q Then $5u = $5n
If $5o = Default Then $5o = "*"
If Not FileExists($5n) Then Return SetError(1, 0, 0)
If StringRegExp($5o, "[\\/:><\|]|(?s)^\s*$") Then Return SetError(2, 0, 0)
If Not($5p = 0 Or $5p = 1 Or $5p = 2) Then Return SetError(3, 0, 0)
Local $5v = FileFindFirstFile($5n & $5o)
If @error Then Return SetError(4, 0, 0)
While 1
$5t = FileFindNextFile($5v)
If @error Then ExitLoop
If($5p + @extended = 2) Then ContinueLoop
$5s &= $5r & $5u & $5t
WEnd
FileClose($5v)
If $5s = "" Then Return SetError(4, 0, 0)
Return StringSplit(StringTrimLeft($5s, 1), $5r)
EndFunc
Func _x2($5n, $5w = "*", $2v = $p, $5x = $t, $5y = $u, $5z = $v)
If Not FileExists($5n) Then Return SetError(1, 1, "")
If $5w = Default Then $5w = "*"
If $2v = Default Then $2v = $p
If $5x = Default Then $5x = $t
If $5y = Default Then $5y = $u
If $5z = Default Then $5z = $v
If $5x > 1 Or Not IsInt($5x) Then Return SetError(1, 6, "")
Local $60 = False
If StringLeft($5n, 4) == "\\?\" Then
$60 = True
EndIf
Local $61 = ""
If StringRight($5n, 1) = "\" Then
$61 = "\"
Else
$5n = $5n & "\"
EndIf
Local $62[100] = [1]
$62[1] = $5n
Local $63 = 0, $64 = ""
If BitAND($2v, $q) Then
$63 += 2
$64 &= "H"
$2v -= $q
EndIf
If BitAND($2v, $r) Then
$63 += 4
$64 &= "S"
$2v -= $r
EndIf
Local $65 = 0
If BitAND($2v, $s) Then
$65 = 0x400
$2v -= $s
EndIf
Local $66 = 0
If $5x < 0 Then
StringReplace($5n, "\", "", 0, $c)
$66 = @extended - $5x
EndIf
Local $67 = "", $68 = "", $69 = "*"
Local $6a = StringSplit($5w, "|")
Switch $6a[0]
Case 3
$68 = $6a[3]
ContinueCase
Case 2
$67 = $6a[2]
ContinueCase
Case 1
$69 = $6a[1]
EndSwitch
Local $6b = ".+"
If $69 <> "*" Then
If Not _x5($6b, $69) Then Return SetError(1, 2, "")
EndIf
Local $6c = ".+"
Switch $2v
Case 0
Switch $5x
Case 0
$6c = $6b
EndSwitch
Case 2
$6c = $6b
EndSwitch
Local $6d = ":"
If $67 <> "" Then
If Not _x5($6d, $67) Then Return SetError(1, 3, "")
EndIf
Local $6e = ":"
If $5x Then
If $68 Then
If Not _x5($6e, $68) Then Return SetError(1, 4, "")
EndIf
If $2v = 2 Then
$6e = $6d
EndIf
Else
$6e = $6d
EndIf
If Not($2v = 0 Or $2v = 1 Or $2v = 2) Then Return SetError(1, 5, "")
If Not($5y = 0 Or $5y = 1 Or $5y = 2) Then Return SetError(1, 7, "")
If Not($5z = 0 Or $5z = 1 Or $5z = 2) Then Return SetError(1, 8, "")
If $65 Then
Local $6f = DllStructCreate("struct;align 4;dword FileAttributes;uint64 CreationTime;uint64 LastAccessTime;uint64 LastWriteTime;" & "dword FileSizeHigh;dword FileSizeLow;dword Reserved0;dword Reserved1;wchar FileName[260];wchar AlternateFileName[14];endstruct")
Local $6g = DllOpen('kernel32.dll'), $6h
EndIf
Local $6i[100] = [0]
Local $6j = $6i, $6k = $6i, $6l = $6i
Local $6m = False, $5v = 0, $6n = "", $6o = "", $6p = ""
Local $6q = 0, $6r = ''
Local $6s[100][2] = [[0, 0]]
While $62[0] > 0
$6n = $62[$62[0]]
$62[0] -= 1
Switch $5z
Case 1
$6p = StringReplace($6n, $5n, "")
Case 2
If $60 Then
$6p = StringTrimLeft($6n, 4)
Else
$6p = $6n
EndIf
EndSwitch
If $65 Then
$6h = DllCall($6g, 'handle', 'FindFirstFileW', 'wstr', $6n & "*", 'struct*', $6f)
If @error Or Not $6h[0] Then
ContinueLoop
EndIf
$5v = $6h[0]
Else
$5v = FileFindFirstFile($6n & "*")
If $5v = -1 Then
ContinueLoop
EndIf
EndIf
If $2v = 0 And $5y And $5z Then
_x4($6s, $6p, $6j[0] + 1)
EndIf
$6r = ''
While 1
If $65 Then
$6h = DllCall($6g, 'int', 'FindNextFileW', 'handle', $5v, 'struct*', $6f)
If @error Or Not $6h[0] Then
ExitLoop
EndIf
$6o = DllStructGetData($6f, "FileName")
If $6o = ".." Then
ContinueLoop
EndIf
$6q = DllStructGetData($6f, "FileAttributes")
If $63 And BitAND($6q, $63) Then
ContinueLoop
EndIf
If BitAND($6q, $65) Then
ContinueLoop
EndIf
$6m = False
If BitAND($6q, 16) Then
$6m = True
EndIf
Else
$6m = False
$6o = FileFindNextFile($5v, 1)
If @error Then
ExitLoop
EndIf
$6r = @extended
If StringInStr($6r, "D") Then
$6m = True
EndIf
If StringRegExp($6r, "[" & $64 & "]") Then
ContinueLoop
EndIf
EndIf
If $6m Then
Select
Case $5x < 0
StringReplace($6n, "\", "", 0, $c)
If @extended < $66 Then
ContinueCase
EndIf
Case $5x = 1
If Not StringRegExp($6o, $6e) Then
_x4($62, $6n & $6o & "\")
EndIf
EndSelect
EndIf
If $5y Then
If $6m Then
If StringRegExp($6o, $6c) And Not StringRegExp($6o, $6e) Then
_x4($6l, $6p & $6o & $61)
EndIf
Else
If StringRegExp($6o, $6b) And Not StringRegExp($6o, $6d) Then
If $6n = $5n Then
_x4($6k, $6p & $6o)
Else
_x4($6j, $6p & $6o)
EndIf
EndIf
EndIf
Else
If $6m Then
If $2v <> 1 And StringRegExp($6o, $6c) And Not StringRegExp($6o, $6e) Then
_x4($6i, $6p & $6o & $61)
EndIf
Else
If $2v <> 2 And StringRegExp($6o, $6b) And Not StringRegExp($6o, $6d) Then
_x4($6i, $6p & $6o)
EndIf
EndIf
EndIf
WEnd
If $65 Then
DllCall($6g, 'int', 'FindClose', 'ptr', $5v)
Else
FileClose($5v)
EndIf
WEnd
If $65 Then
DllClose($6g)
EndIf
If $5y Then
Switch $2v
Case 2
If $6l[0] = 0 Then Return SetError(1, 9, "")
ReDim $6l[$6l[0] + 1]
$6i = $6l
_wj($6i, 1, $6i[0])
Case 1
If $6k[0] = 0 And $6j[0] = 0 Then Return SetError(1, 9, "")
If $5z = 0 Then
_x3($6i, $6k, $6j)
_wj($6i, 1, $6i[0])
Else
_x3($6i, $6k, $6j, 1)
EndIf
Case 0
If $6k[0] = 0 And $6l[0] = 0 Then Return SetError(1, 9, "")
If $5z = 0 Then
_x3($6i, $6k, $6j)
$6i[0] += $6l[0]
ReDim $6l[$6l[0] + 1]
_w0($6i, $6l, 1)
_wj($6i, 1, $6i[0])
Else
Local $6i[$6j[0] + $6k[0] + $6l[0] + 1]
$6i[0] = $6j[0] + $6k[0] + $6l[0]
_wj($6k, 1, $6k[0])
For $4c = 1 To $6k[0]
$6i[$4c] = $6k[$4c]
Next
Local $6t = $6k[0] + 1
_wj($6l, 1, $6l[0])
Local $6u = ""
For $4c = 1 To $6l[0]
$6i[$6t] = $6l[$4c]
$6t += 1
If $61 Then
$6u = $6l[$4c]
Else
$6u = $6l[$4c] & "\"
EndIf
Local $6v = 0, $6w = 0
For $4j = 1 To $6s[0][0]
If $6u = $6s[$4j][0] Then
$6w = $6s[$4j][1]
If $4j = $6s[0][0] Then
$6v = $6j[0]
Else
$6v = $6s[$4j + 1][1] - 1
EndIf
If $5y = 1 Then
_wj($6j, $6w, $6v)
EndIf
For $55 = $6w To $6v
$6i[$6t] = $6j[$55]
$6t += 1
Next
ExitLoop
EndIf
Next
Next
EndIf
EndSwitch
Else
If $6i[0] = 0 Then Return SetError(1, 9, "")
ReDim $6i[$6i[0] + 1]
EndIf
Return $6i
EndFunc
Func _x3(ByRef $6x, $6y, $6z, $5y = 0)
ReDim $6y[$6y[0] + 1]
If $5y = 1 Then _wj($6y, 1, $6y[0])
$6x = $6y
$6x[0] += $6z[0]
ReDim $6z[$6z[0] + 1]
If $5y = 1 Then _wj($6z, 1, $6z[0])
_w0($6x, $6z, 1)
EndFunc
Func _x4(ByRef $70, $71, $72 = -1)
If $72 = -1 Then
$70[0] += 1
If UBound($70) <= $70[0] Then ReDim $70[UBound($70) * 2]
$70[$70[0]] = $71
Else
$70[0][0] += 1
If UBound($70) <= $70[0][0] Then ReDim $70[UBound($70) * 2][2]
$70[$70[0][0]][0] = $71
$70[$70[0][0]][1] = $72
EndIf
EndFunc
Func _x5(ByRef $5w, $73)
If StringRegExp($73, "\\|/|:|\<|\>|\|") Then Return 0
$73 = StringReplace(StringStripWS(StringRegExpReplace($73, "\s*;\s*", ";"), BitOR($d, $e)), ";", "|")
$73 = StringReplace(StringReplace(StringRegExpReplace($73, "[][$^.{}()+\-]", "\\$0"), "?", "."), "*", ".*?")
$5w = "(?i)^(" & $73 & ")\z"
Return 1
EndFunc
Func _xe($5n, ByRef $74, ByRef $75, ByRef $5t, ByRef $76)
Local $42 = StringRegExp($5n, "^\h*((?:\\\\\?\\)*(\\\\[^\?\/\\]+|[A-Za-z]:)?(.*[\/\\]\h*)?((?:[^\.\/\\]|(?(?=\.[^\/\\]*\.)\.))*)?([^\/\\]*))$", $h)
If @error Then
ReDim $42[5]
$42[$x] = $5n
EndIf
$74 = $42[$y]
If StringLeft($42[$0z], 1) == "/" Then
$75 = StringRegExpReplace($42[$0z], "\h*[\/\\]+\h*", "\/")
Else
$75 = StringRegExpReplace($42[$0z], "\h*[\/\\]+\h*", "\\")
EndIf
$42[$0z] = $75
$5t = $42[$10]
$76 = $42[$11]
Return $42
EndFunc
Global $77 = False
Local $78 = "0.0.15"
Local Const $79[6] = ["040C", "080C", "0C0C", "100C", "140C", "180C"]
If _we($79, @MUILang) <> 1 Then
Global $7a = "Supprimer les outils"
Global $7b = "Supprimer les points de restaurations"
Global $7c = "Créer un point de restauration"
Global $7d = "Sauvegarder le registre"
Global $7e = "Restaurer UAC"
Global $7f = "Restaurer les paramètres système"
Global $7g = "Exécuter"
Global $7h = "Toutes les opérations sont terminées"
Global $7i = "Echec"
Global $7j = "Impossible de créer une sauvegarde du registre"
Global $7k = "Vous devez exécuter le programme avec les droits administrateurs"
Global $7l = "Vous devez fermer MalwareBytes Anti-Rootkit avant de continuer"
Global $7m = "Mise à jour"
Global $7n = "Une version plus récente de KpRm existe, merci de la télécharger."
Else
Global $7a = "Delete Tools"
Global $7b = "Delete Restore Points"
Global $7c = "Create Restore Point"
Global $7d = "Registry Backup"
Global $7e = "UAC Restore"
Global $7f = "Restore System Settings"
Global $7g = "Run"
Global $7h = "All operations are completed"
Global $7i = "Fail"
Global $7j = "Unable to create a registry backup"
Global $7k = "You must run the program with administrator rights"
Global $7l = "You must close MalwareBytes Anti-Rootkit before continuing"
Global $7m = "Update"
Global $7n = "A more recent version of KpRm exists, please download it!"
EndIf
Global Const $7o = 1
Global Const $7p = 5
Global Const $7q = 0
Global Const $7r = 1
Func _xr($7s = $7p)
If Not IsAdmin() Then Return SetError(-3, 0, -1)
If StringRegExp(@OSVersion, "_(XP|200(0|3))") Then Return SetError(-4, 0, -1)
Local $7t = ""
If @OSArch = "X64" Then $7t = "64"
If $7s < 0 Or $7s > 5 Then Return SetError(-5, 0, -1)
Local $2v = RegWrite("HKEY_LOCAL_MACHINE" & $7t & "\Software\Microsoft\Windows\CurrentVersion\Policies\System", "ConsentPromptBehaviorAdmin", "REG_DWORD", $7s)
If $2v = 0 Then $2v = -1
Return SetError(@error, 0, $2v)
EndFunc
Func _xs($7s = $7o)
If Not IsAdmin() Then Return SetError(-3, 0, -1)
If StringRegExp(@OSVersion, "_(XP|200(0|3))") Then Return SetError(-4, 0, -1)
If $7s < 0 Or $7s = 2 Or $7s > 3 Then Return SetError(-5, 0, -1)
Local $7t = ""
If @OSArch = "X64" Then $7t = "64"
Local $2v = RegWrite("HKEY_LOCAL_MACHINE" & $7t & "\Software\Microsoft\Windows\CurrentVersion\Policies\System", "ConsentPromptBehaviorUser", "REG_DWORD", $7s)
If $2v = 0 Then $2v = -1
Return SetError(@error, 0, $2v)
EndFunc
Func _xt($7s = $7q)
If Not IsAdmin() Then Return SetError(-3, 0, -1)
If StringRegExp(@OSVersion, "_(XP|200(0|3))") Then Return SetError(-4, 0, -1)
If $7s < 0 Or $7s > 1 Then Return SetError(-5, 0, -1)
Local $7t = ""
If @OSArch = "X64" Then $7t = "64"
Local $2v = RegWrite("HKEY_LOCAL_MACHINE" & $7t & "\Software\Microsoft\Windows\CurrentVersion\Policies\System", "EnableInstallerDetection", "REG_DWORD", $7s)
If $2v = 0 Then $2v = -1
Return SetError(@error, 0, $2v)
EndFunc
Func _xu($7s = $7r)
If Not IsAdmin() Then Return SetError(-3, 0, -1)
If StringRegExp(@OSVersion, "_(XP|200(0|3))") Then Return SetError(-4, 0, -1)
If $7s < 0 Or $7s > 1 Then Return SetError(-5, 0, -1)
Local $7t = ""
If @OSArch = "X64" Then $7t = "64"
Local $2v = RegWrite("HKEY_LOCAL_MACHINE" & $7t & "\Software\Microsoft\Windows\CurrentVersion\Policies\System", "EnableLUA", "REG_DWORD", $7s)
If $2v = 0 Then $2v = -1
Return SetError(@error, 0, $2v)
EndFunc
Func _xv($7s = $7r)
If Not IsAdmin() Then Return SetError(-3, 0, -1)
If StringRegExp(@OSVersion, "_(XP|200(0|3))") Then Return SetError(-4, 0, -1)
If $7s < 0 Or $7s > 1 Then Return SetError(-5, 0, -1)
Local $7t = ""
If @OSArch = "X64" Then $7t = "64"
Local $2v = RegWrite("HKEY_LOCAL_MACHINE" & $7t & "\Software\Microsoft\Windows\CurrentVersion\Policies\System", "EnableSecureUIAPaths", "REG_DWORD", $7s)
If $2v = 0 Then $2v = -1
Return SetError(@error, 0, $2v)
EndFunc
Func _xw($7s = $7q)
If Not IsAdmin() Then Return SetError(-3, 0, -1)
If StringRegExp(@OSVersion, "_(XP|200(0|3))") Then Return SetError(-4, 0, -1)
If $7s < 0 Or $7s > 1 Then Return SetError(-5, 0, -1)
Local $7t = ""
If @OSArch = "X64" Then $7t = "64"
Local $2v = RegWrite("HKEY_LOCAL_MACHINE" & $7t & "\Software\Microsoft\Windows\CurrentVersion\Policies\System", "EnableUIADesktopToggle", "REG_DWORD", $7s)
If $2v = 0 Then $2v = -1
Return SetError(@error, 0, $2v)
EndFunc
Func _xx($7s = $7r)
If Not IsAdmin() Then Return SetError(-3, 0, -1)
If StringRegExp(@OSVersion, "_(XP|200(0|3))") Then Return SetError(-4, 0, -1)
If $7s < 0 Or $7s > 1 Then Return SetError(-5, 0, -1)
Local $7t = ""
If @OSArch = "X64" Then $7t = "64"
Local $2v = RegWrite("HKEY_LOCAL_MACHINE" & $7t & "\Software\Microsoft\Windows\CurrentVersion\Policies\System", "EnableVirtualization", "REG_DWORD", $7s)
If $2v = 0 Then $2v = -1
Return SetError(@error, 0, $2v)
EndFunc
Func _xy($7s = $7q)
If Not IsAdmin() Then Return SetError(-3, 0, -1)
If StringRegExp(@OSVersion, "_(XP|200(0|3))") Then Return SetError(-4, 0, -1)
If $7s < 0 Or $7s > 1 Then Return SetError(-5, 0, -1)
Local $7t = ""
If @OSArch = "X64" Then $7t = "64"
Local $2v = RegWrite("HKEY_LOCAL_MACHINE" & $7t & "\Software\Microsoft\Windows\CurrentVersion\Policies\System", "FilterAdministratorToken", "REG_DWORD", $7s)
If $2v = 0 Then $2v = -1
Return SetError(@error, 0, $2v)
EndFunc
Func _xz($7s = $7r)
If Not IsAdmin() Then Return SetError(-3, 0, -1)
If StringRegExp(@OSVersion, "_(XP|200(0|3))") Then Return SetError(-4, 0, -1)
If $7s < 0 Or $7s > 1 Then Return SetError(-5, 0, -1)
Local $7t = ""
If @OSArch = "X64" Then $7t = "64"
Local $2v = RegWrite("HKEY_LOCAL_MACHINE" & $7t & "\Software\Microsoft\Windows\CurrentVersion\Policies\System", "PromptOnSecureDesktop", "REG_DWORD", $7s)
If $2v = 0 Then $2v = -1
Return SetError(@error, 0, $2v)
EndFunc
Func _y0($7s = $7q)
If Not IsAdmin() Then Return SetError(-3, 0, -1)
If StringRegExp(@OSVersion, "_(XP|200(0|3))") Then Return SetError(-4, 0, -1)
If $7s < 0 Or $7s > 1 Then Return SetError(-5, 0, -1)
Local $7t = ""
If @OSArch = "X64" Then $7t = "64"
Local $2v = RegWrite("HKEY_LOCAL_MACHINE" & $7t & "\Software\Microsoft\Windows\CurrentVersion\Policies\System", "ValidateAdminCodeSignatures", "REG_DWORD", $7s)
If $2v = 0 Then $2v = -1
Return SetError(@error, 0, $2v)
EndFunc
Global $7u = Null, $7v = Null
Global $7w = EnvGet('SystemDrive') & '\'
Func _y2()
Local $7x[1][3], $7y = 0
$7x[0][0] = $7y
If Not IsObj($7v) Then $7v = ObjGet("winmgmts:root/default")
If Not IsObj($7v) Then Return $7x
Local $7z = $7v.InstancesOf("SystemRestore")
If Not IsObj($7z) Then Return $7x
For $80 In $7z
$7y += 1
ReDim $7x[$7y + 1][3]
$7x[$7y][0] = $80.SequenceNumber
$7x[$7y][1] = $80.Description
$7x[$7y][2] = _y3($80.CreationTime)
Next
$7x[0][0] = $7y
Return $7x
EndFunc
Func _y3($81)
Return(StringMid($81, 5, 2) & "/" & StringMid($81, 7, 2) & "/" & StringLeft($81, 4) & " " & StringMid($81, 9, 2) & ":" & StringMid($81, 11, 2) & ":" & StringMid($81, 13, 2))
EndFunc
Func _y4($82)
Local $15 = DllCall('SrClient.dll', 'DWORD', 'SRRemoveRestorePoint', 'DWORD', $82)
If @error Then Return SetError(1, 0, 0)
If $15[0] = 0 Then Return 1
Return SetError(1, 0, 0)
EndFunc
Func _y6($83 = $7w)
If Not IsObj($7u) Then $7u = ObjGet("winmgmts:{impersonationLevel=impersonate}!root/default:SystemRestore")
If Not IsObj($7u) Then Return 0
If $7u.Enable($83) = 0 Then Return 1
Return 0
EndFunc
Global Enum $84 = 0, $85, $86, $87, $88, $89, $8a, $8b, $8c, $8d, $8e, $8f, $8g
Global Const $8h = 2
Global $8i = @SystemDir&'\Advapi32.dll'
Global $8j = @SystemDir&'\Kernel32.dll'
Global $8k[4][2], $8l[4][2]
Global $8m = 0
Func _y9()
$8i = DllOpen(@SystemDir&'\Advapi32.dll')
$8j = DllOpen(@SystemDir&'\Kernel32.dll')
$8k[0][0] = "SeRestorePrivilege"
$8k[0][1] = 2
$8k[1][0] = "SeTakeOwnershipPrivilege"
$8k[1][1] = 2
$8k[2][0] = "SeDebugPrivilege"
$8k[2][1] = 2
$8k[3][0] = "SeSecurityPrivilege"
$8k[3][1] = 2
$8l = _zh($8k)
$8m = 1
EndFunc
Func _yf($8n, $8o = $85, $8p = 'Administrators', $8q = 1)
Local $8r[1][3]
$8r[0][0] = 'Everyone'
$8r[0][1] = 1
$8r[0][2] = $n
Return _yi($8n, $8r, $8o, $8p, 1, $8q)
EndFunc
Func _yi($8n, $8s, $8o = $85, $8p = '', $8t = 0, $8q = 0, $8u = 3)
If $8m = 0 Then _y9()
If Not IsArray($8s) Or UBound($8s,2) < 3 Then Return SetError(1,0,0)
Local $8v = _yn($8s,$8u)
Local $8w = @extended
Local $8x = 4, $8y = 0
If $8p <> '' Then
If Not IsDllStruct($8p) Then $8p = _za($8p)
$8y = DllStructGetPtr($8p)
If $8y And _zg($8y) Then
$8x = 5
Else
$8y = 0
EndIf
EndIf
If Not IsPtr($8n) And $8o = $85 Then
Return _yv($8n, $8v, $8y, $8t, $8q, $8w, $8x)
ElseIf Not IsPtr($8n) And $8o = $88 Then
Return _yw($8n, $8v, $8y, $8t, $8q, $8w, $8x)
Else
If $8t Then _yx($8n,$8o)
Return _yo($8n, $8o, $8x, $8y, 0, $8v,0)
EndIf
EndFunc
Func _yn(ByRef $8s, ByRef $8u)
Local $8z = UBound($8s,2)
If Not IsArray($8s) Or $8z < 3 Then Return SetError(1,0,0)
Local $90 = UBound($8s), $91[$90], $92 = 0, $93 = 1
Local $94, $8w = 0, $95
Local $96, $97 = 'DWORD;DWORD;DWORD;ptr;DWORD;DWORD;DWORD;ptr'
For $4c = 1 To $90 - 1
$97 &= ';DWORD;DWORD;DWORD;ptr;DWORD;DWORD;DWORD;ptr'
Next
$96 = DllStructCreate($97)
For $4c = 0 To $90 -1
If Not IsDllStruct($8s[$4c][0]) Then $8s[$4c][0] = _za($8s[$4c][0])
$91[$4c] = DllStructGetPtr($8s[$4c][0])
If Not _zg($91[$4c]) Then ContinueLoop
DllStructSetData($96,$92+1,$8s[$4c][2])
If $8s[$4c][1] = 0 Then
$8w = 1
$94 = $8
Else
$94 = $7
EndIf
If $8z > 3 Then $8u = $8s[$4c][3]
DllStructSetData($96,$92+2,$94)
DllStructSetData($96,$92+3,$8u)
DllStructSetData($96,$92+6,0)
$95 = DllCall($8i,'BOOL','LookupAccountSid','ptr',0,'ptr',$91[$4c],'ptr*',0,'dword*',32,'ptr*',0,'dword*',32,'dword*',0)
If Not @error Then $93 = $95[7]
DllStructSetData($96,$92+7,$93)
DllStructSetData($96,$92+8,$91[$4c])
$92 += 8
Next
Local $98 = DllStructGetPtr($96)
$95 = DllCall($8i,'DWORD','SetEntriesInAcl','ULONG',$90,'ptr',$98 ,'ptr',0,'ptr*',0)
If @error Or $95[0] Then Return SetError(1,0,0)
Return SetExtended($8w, $95[4])
EndFunc
Func _yo($8n, $8o, $8x, $8y = 0, $99 = 0, $8v = 0, $9a = 0)
Local $95
If $8m = 0 Then _y9()
If $8v And Not _yp($8v) Then Return 0
If $9a And Not _yp($9a) Then Return 0
If IsPtr($8n) Then
$95 = DllCall($8i,'dword','SetSecurityInfo','handle',$8n,'dword',$8o, 'dword',$8x,'ptr',$8y,'ptr',$99,'ptr',$8v,'ptr',$9a)
Else
If $8o = $88 Then $8n = _zb($8n)
$95 = DllCall($8i,'dword','SetNamedSecurityInfo','str',$8n,'dword',$8o, 'dword',$8x,'ptr',$8y,'ptr',$99,'ptr',$8v,'ptr',$9a)
EndIf
If @error Then Return SetError(1,0,0)
If $95[0] And $8y Then
If _z0($8n, $8o,_zf($8y)) Then Return _yo($8n, $8o, $8x - 1, 0, $99, $8v, $9a)
EndIf
Return SetError($95[0] , 0, Number($95[0] = 0))
EndFunc
Func _yp($9b)
If $9b = 0 Then Return SetError(1,0,0)
Local $95 = DllCall($8i,'bool','IsValidAcl','ptr',$9b)
If @error Or Not $95[0] Then Return 0
Return 1
EndFunc
Func _yv($8n, ByRef $8v, ByRef $8y, ByRef $8t, ByRef $8q, ByRef $8w, ByRef $8x)
Local $9c, $9d
If Not $8w Then
If $8t Then _yx($8n,$85)
$9c = _yo($8n, $85, $8x, $8y, 0, $8v,0)
EndIf
If $8q Then
Local $9e = FileFindFirstFile($8n&'\*')
While 1
$9d = FileFindNextFile($9e)
If $8q = 1 Or $8q = 2 And @extended = 1 Then
_yv($8n&'\'&$9d, $8v, $8y, $8t, $8q, $8w,$8x)
ElseIf @error Then
ExitLoop
ElseIf $8q = 1 Or $8q = 3 Then
If $8t Then _yx($8n&'\'&$9d,$85)
_yo($8n&'\'&$9d, $85, $8x, $8y, 0, $8v,0)
EndIf
WEnd
FileClose($9e)
EndIf
If $8w Then
If $8t Then _yx($8n,$85)
$9c = _yo($8n, $85, $8x, $8y, 0, $8v,0)
EndIf
Return $9c
EndFunc
Func _yw($8n, ByRef $8v, ByRef $8y, ByRef $8t, ByRef $8q, ByRef $8w, ByRef $8x)
If $8m = 0 Then _y9()
Local $9c, $4c = 0, $9d
If Not $8w Then
If $8t Then _yx($8n,$88)
$9c = _yo($8n, $88, $8x, $8y, 0, $8v,0)
EndIf
If $8q Then
While 1
$4c += 1
$9d = RegEnumKey($8n,$4c)
If @error Then ExitLoop
_yw($8n&'\'&$9d, $8v, $8y, $8t, $8q, $8w, $8x)
WEnd
EndIf
If $8w Then
If $8t Then _yx($8n,$88)
$9c = _yo($8n, $88, $8x, $8y, 0, $8v,0)
EndIf
Return $9c
EndFunc
Func _yx($8n, $8o = $85)
If $8m = 0 Then _y9()
Local $9f = DllStructCreate('byte[32]'), $15
Local $8v = DllStructGetPtr($9f,1)
DllCall($8i,'bool','InitializeAcl','Ptr',$8v,'dword',DllStructGetSize($9f),'dword',$8h)
If IsPtr($8n) Then
$15 = DllCall($8i,"dword","SetSecurityInfo",'handle',$8n,'dword',$8o,'dword',4,'ptr',0,'ptr',0,'ptr',$8v,'ptr',0)
Else
If $8o = $88 Then $8n = _zb($8n)
DllCall($8i,'DWORD','SetNamedSecurityInfo','str',$8n,'dword',$8o,'DWORD',4,'ptr',0,'ptr',0,'ptr',0,'ptr',0)
$15 = DllCall($8i,'DWORD','SetNamedSecurityInfo','str',$8n,'dword',$8o,'DWORD',4,'ptr',0,'ptr',0,'ptr',$8v,'ptr',0)
EndIf
If @error Then Return SetError(@error,0,0)
Return SetError($15[0],0,Number($15[0] = 0))
EndFunc
Func _z0($8n, $8o = $85, $9g = 'Administrators')
If $8m = 0 Then _y9()
Local $9h = _za($9g), $15
Local $91 = DllStructGetPtr($9h)
If IsPtr($8n) Then
$15 = DllCall($8i,"dword","SetSecurityInfo",'handle',$8n,'dword',$8o,'dword',1,'ptr',$91,'ptr',0,'ptr',0,'ptr',0)
Else
If $8o = $88 Then $8n = _zb($8n)
$15 = DllCall($8i,'DWORD','SetNamedSecurityInfo','str',$8n,'dword',$8o,'DWORD',1,'ptr',$91,'ptr',0,'ptr',0,'ptr',0)
EndIf
If @error Then Return SetError(@error,0,False)
Return SetError($15[0],0,Number($15[0] = 0))
EndFunc
Func _za($9g)
If $9g = 'TrustedInstaller' Then $9g = 'NT SERVICE\TrustedInstaller'
If $9g = 'Everyone' Then
Return _zd('S-1-1-0')
ElseIf $9g = 'Authenticated Users' Then
Return _zd('S-1-5-11')
ElseIf $9g = 'System' Then
Return _zd('S-1-5-18')
ElseIf $9g = 'Administrators' Then
Return _zd('S-1-5-32-544')
ElseIf $9g = 'Users' Then
Return _zd('S-1-5-32-545')
ElseIf $9g = 'Guests' Then
Return _zd('S-1-5-32-546')
ElseIf $9g = 'Power Users' Then
Return _zd('S-1-5-32-547')
ElseIf $9g = 'Local Authority' Then
Return _zd('S-1-2')
ElseIf $9g = 'Creator Owner' Then
Return _zd('S-1-3-0')
ElseIf $9g = 'NT Authority' Then
Return _zd('S-1-5-1')
ElseIf $9g = 'Restricted' Then
Return _zd('S-1-5-12')
ElseIf StringRegExp($9g,'\A(S-1-\d+(-\d+){0,5})\z') Then
Return _zd($9g)
Else
Local $9h = _zc($9g)
Return _zd($9h)
EndIf
EndFunc
Func _zb($9i)
If StringInStr($9i,'\\') = 1 Then
$9i = StringRegExpReplace($9i,'(?i)\\(HKEY_CLASSES_ROOT|HKCR)','\CLASSES_ROOT')
$9i = StringRegExpReplace($9i,'(?i)\\(HKEY_CURRENT_USER|HKCU)','\CURRENT_USER')
$9i = StringRegExpReplace($9i,'(?i)\\(HKEY_LOCAL_MACHINE|HKLM)','\MACHINE')
$9i = StringRegExpReplace($9i,'(?i)\\(HKEY_USERS|HKU)','\USERS')
Else
$9i = StringRegExpReplace($9i,'(?i)\A(HKEY_CLASSES_ROOT|HKCR)','CLASSES_ROOT')
$9i = StringRegExpReplace($9i,'(?i)\A(HKEY_CURRENT_USER|HKCU)','CURRENT_USER')
$9i = StringRegExpReplace($9i,'(?i)\A(HKEY_LOCAL_MACHINE|HKLM)','MACHINE')
$9i = StringRegExpReplace($9i,'(?i)\A(HKEY_USERS|HKU)','USERS')
EndIf
Return $9i
EndFunc
Func _zc($9j, $9k = "")
Local $9l = DllStructCreate("byte SID[256]")
Local $91 = DllStructGetPtr($9l, "SID")
Local $2z = DllCall($8i, "bool", "LookupAccountNameW", "wstr", $9k, "wstr", $9j, "ptr", $91, "dword*", 256, "wstr", "", "dword*", 256, "int*", 0)
If @error Then Return SetError(@error, @extended, 0)
If Not $2z[0] Then Return 0
Return _zf($91)
EndFunc
Func _zd($9m)
Local $2z = DllCall($8i, "bool", "ConvertStringSidToSidW", "wstr", $9m, "ptr*", 0)
If @error Then Return SetError(@error, @extended, 0)
If Not $2z[0] Then Return 0
Local $9n = _ze($2z[2])
Local $3q = DllStructCreate("byte Data[" & $9n & "]", $2z[2])
Local $9o = DllStructCreate("byte Data[" & $9n & "]")
DllStructSetData($9o, "Data", DllStructGetData($3q, "Data"))
DllCall($8j, "ptr", "LocalFree", "ptr", $2z[2])
Return $9o
EndFunc
Func _ze($91)
If Not _zg($91) Then Return SetError(-1, 0, "")
Local $2z = DllCall($8i, "dword", "GetLengthSid", "ptr", $91)
If @error Then Return SetError(@error, @extended, 0)
Return $2z[0]
EndFunc
Func _zf($91)
If Not _zg($91) Then Return SetError(-1, 0, "")
Local $2z = DllCall($8i, "int", "ConvertSidToStringSidW", "ptr", $91, "ptr*", 0)
If @error Then Return SetError(@error, @extended, "")
If Not $2z[0] Then Return ""
Local $3q = DllStructCreate("wchar Text[256]", $2z[2])
Local $9m = DllStructGetData($3q, "Text")
DllCall($8j, "ptr", "LocalFree", "ptr", $2z[2])
Return $9m
EndFunc
Func _zg($91)
Local $2z = DllCall($8i, "bool", "IsValidSid", "ptr", $91)
If @error Then Return SetError(@error, @extended, False)
Return $2z[0]
EndFunc
Func _zh($9p)
Local $9q = UBound($9p, 0), $9r[1][2]
If Not($9q <= 2 And UBound($9p, $9q) = 2 ) Then Return SetError(1300, 0, $9r)
If $9q = 1 Then
Local $9s[1][2]
$9s[0][0] = $9p[0]
$9s[0][1] = $9p[1]
$9p = $9s
$9s = 0
EndIf
Local $55, $9t = "dword", $9u = UBound($9p, 1)
Do
$55 += 1
$9t &= ";dword;long;dword"
Until $55 = $9u
Local $9v, $9w, $9x, $9y, $9z, $a0, $a1
$9v = DLLStructCreate($9t)
$9w = DllStructCreate($9t)
$9x = DllStructGetPtr($9w)
$9y = DllStructCreate("dword;long")
DLLStructSetData($9v, 1, $9u)
For $4c = 0 To $9u - 1
DllCall($8i, "int", "LookupPrivilegeValue", "str", "", "str", $9p[$4c][0], "ptr", DllStructGetPtr($9y) )
DLLStructSetData( $9v, 3 * $4c + 2, DllStructGetData($9y, 1) )
DLLStructSetData( $9v, 3 * $4c + 3, DllStructGetData($9y, 2) )
DLLStructSetData( $9v, 3 * $4c + 4, $9p[$4c][1] )
Next
$9z = DllCall($8j, "hwnd", "GetCurrentProcess")
$a0 = DllCall($8i, "int", "OpenProcessToken", "hwnd", $9z[0], "dword", BitOR(0x00000020, 0x00000008), "hwnd*", 0 )
DllCall( $8i, "int", "AdjustTokenPrivileges", "hwnd", $a0[3], "int", False, "ptr", DllStructGetPtr($9v), "dword", DllStructGetSize($9v), "ptr", $9x, "dword*", 0 )
$a1 = DllCall($8j, "dword", "GetLastError")
DllCall($8j, "int", "CloseHandle", "hwnd", $a0[3])
Local $a2 = DllStructGetData($9w, 1)
If $a2 > 0 Then
Local $a3, $a4, $a5, $9r[$a2][2]
For $4c = 0 To $a2 - 1
$a3 = $9x + 12 * $4c + 4
$a4 = DllCall($8i, "int", "LookupPrivilegeName", "str", "", "ptr", $a3, "ptr", 0, "dword*", 0 )
$a5 = DllStructCreate("char[" & $a4[4] & "]")
DllCall($8i, "int", "LookupPrivilegeName", "str", "", "ptr", $a3, "ptr", DllStructGetPtr($a5), "dword*", DllStructGetSize($a5) )
$9r[$4c][0] = DllStructGetData($a5, 1)
$9r[$4c][1] = DllStructGetData($9w, 3 * $4c + 4)
Next
EndIf
Return SetError($a1[0], 0, $9r)
EndFunc
Func _zi($a6 = False, $a7 = True)
Dim $77
Dim $a8
FileDelete(@TempDir & "\kprm-logo.gif")
If $a6 = True Then
If $a7 = True Then
Run("notepad.exe " & @HomeDrive & "\KPRM" & "\" & $a8)
EndIf
If $77 = False Then
Run(@ComSpec & ' /c timeout 3 && del /F /Q "' & @ScriptFullPath & '"', @TempDir, @SW_HIDE)
FileDelete(@ScriptFullPath)
EndIf
EndIf
Exit
EndFunc
Func _zj()
Local $a9 = DllCall('connect.dll', 'long', 'IsInternetConnected')
If @error Then
Return SetError(1, 0, False)
EndIf
Return $a9[0] = 0
EndFunc
Func _zk()
Dim $78
Local Const $aa = _zj()
If $aa = False Then
Return Null
EndIf
Local Const $ab = _zl("https://kernel-panik.me/_api/v1/kprm/version")
If $ab <> Null And $ab <> "" And $ab <> $78 Then
MsgBox(64, $7m, $7n)
ShellExecute("https://kernel-panik.me/tool/kprm/")
_zi(True, False)
EndIf
EndFunc
_zk()
If Not IsAdmin() Then
MsgBox(16, $7i, $7k)
_zi()
EndIf
Local $ac = ProcessList("mbar.exe")
If $ac[0][0] > 0 Then
MsgBox(16, $7i, $7l)
_zi()
EndIf
Func _zl($ad, $ae = "")
Local $af = ObjCreate("WinHttp.WinHttpRequest.5.1")
$af.Open("GET", $ad & "?" & $ae, False)
$af.SetTimeouts(50, 50, 50, 50)
If(@error) Then Return SetError(1, 0, 0)
$af.Send()
If(@error) Then Return SetError(2, 0, 0)
If($af.Status <> 200) Then Return SetError(3, 0, 0)
Return SetError(0, 0, $af.ResponseText)
EndFunc
Func _zm($ag)
Dim $a8
FileWrite(@HomeDrive & "\KPRM" & "\" & $a8, $ag & @CRLF)
EndFunc
Func _zn()
Local $ah = 100, $ai = 100, $aj = 0, $ak = @WindowsDir & "\Explorer.exe"
_hf($38, 0, 0, 0)
Local $al = _d0("Shell_TrayWnd", "")
_51($al, 1460, 0, 0)
While ProcessExists("Explorer.exe")
Sleep(10)
$ah -= ProcessClose("Explorer.exe") ? 0 : 1
If $ah < 1 Then Return SetError(1, 0, 0)
WEnd
While(Not ProcessExists("Explorer.exe"))
If Not FileExists($ak) Then Return SetError(-1, 0, 0)
Sleep(500)
$aj = ShellExecute($ak)
$ai -= $aj ? 0 : 1
If $ai < 1 Then Return SetError(2, 0, 0)
WEnd
Return $aj
EndFunc
Func _zq($am, $an, $ao)
Local $4c = 0
While True
$4c += 1
Local $ap = RegEnumKey($am, $4c)
If @error <> 0 Then ExitLoop
Local $aq = $am & "\" & $ap
Local $9d = RegRead($aq, $ao)
If StringRegExp($9d, $an) Then
Return $aq
EndIf
WEnd
Return Null
EndFunc
Func _zs()
Local $ar = []
If FileExists(@HomeDrive & "\Program Files") Then
_vv($ar, @HomeDrive & "\Program Files")
EndIf
If FileExists(@HomeDrive & "\Program Files (x86)") Then
_vv($ar, @HomeDrive & "\Program Files (x86)")
EndIf
If FileExists(@HomeDrive & "\Program Files(x86)") Then
_vv($ar, @HomeDrive & "\Program Files(x86)")
EndIf
Return $ar
EndFunc
Func _zt($5n)
Return Int(FileExists($5n) And StringInStr(FileGetAttrib($5n), 'D', Default, 1) = 0)
EndFunc
Func _zu($5n)
Return Int(FileExists($5n) And StringInStr(FileGetAttrib($5n), 'D', Default, 1) > 0)
EndFunc
Func _zv($5n)
Local $as = Null
If FileExists($5n) Then
Local $at = StringInStr(FileGetAttrib($5n), 'D', Default, 1)
If $at = 0 Then
$as = 'file'
ElseIf $at > 0 Then
$as = 'folder'
EndIf
EndIf
Return $as
EndFunc
Func _zw()
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
Func _zx($ao)
If StringRegExp($ao, "^(HKLM|HKCU|HKU|HKCR|HKCC)64") Then
Local $au = StringReplace($ao, "64", "", 1)
Return $au
EndIf
Return $ao
EndFunc
Func _zy($av, $ao)
If $av.Exists($ao) Then
Local $at = $av.Item($ao) + 1
$av.Item($ao) = $at
Else
$av.add($ao, 1)
EndIf
Return $av
EndFunc
Func _0zz($aw, $ax, $ay)
Dim $az
Local $b0 = $az.Item($aw)
Local $b1 = _zy($b0.Item($ax), $ay)
$b0.Item($ax) = $b1
$az.Item($aw) = $b0
EndFunc
Func _100($b2, $b3)
If $b2 = Null Or $b2 = "" Then Return
Local $b4 = ProcessExists($b2)
If $b4 <> 0 Then
_zm("     [X] Process " & $b2 & " not killed, it is possible that the deletion is not complete (" & $b3 & ")")
Else
_zm("     [OK] Process " & $b2 & " killed (" & $b3 & ")")
EndIf
EndFunc
Func _101($b5, $b3)
If $b5 = Null Or $b5 = "" Then Return
Local $b6 = "[X]"
RegEnumVal($b5, "1")
If @error >= 0 Then
$b6 = "[OK]"
EndIf
_zm("     " & $b6 & " " & _zx($b5) & " deleted (" & $b3 & ")")
EndFunc
Func _102($b5, $b3)
If $b5 = Null Or $b5 = "" Then Return
Local $74 = "", $75 = "", $5t = "", $76 = ""
Local $b7 = _xe($b5, $74, $75, $5t, $76)
If $76 = ".exe" Then
Local $b8 = $b7[1] & $b7[2]
Local $b6 = "[OK]"
If FileExists($b8) Then
$b6 = "[X]"
EndIf
_zm("     " & $b6 & " Uninstaller run correctly (" & $b3 & ")")
EndIf
EndFunc
Func _103($b5, $b3)
If $b5 = Null Or $b5 = "" Then Return
Local $b6 = "[OK]"
If FileExists($b5) Then
$b6 = "[X]"
EndIf
_zm("     " & $b6 & " " & $b5 & " deleted (" & $b3 & ")")
EndFunc
Func _104($b9, $b5, $b3)
Switch $b9
Case "process"
_100($b5, $b3)
Case "key"
_101($b5, $b3)
Case "uninstall"
_102($b5, $b3)
Case "element"
_103($b5, $b3)
Case Else
_zm("     [?] Unknown type " & $b9)
EndSwitch
EndFunc
Local $ba = 43
Local $bb
Local Const $bc = Floor(100 / $ba)
Func _105($bd = 1)
$bb += $bd
Dim $be
GUICtrlSetData($be, $bb * $bc)
If $bb = $ba Then
GUICtrlSetData($be, 100)
EndIf
EndFunc
Func _106()
$bb = 0
Dim $be
GUICtrlSetData($be, 0)
EndFunc
Func _107()
_zm(@CRLF & "- Clear All System Restore Points -" & @CRLF)
Local Const $bf = _y2()
Local $9c = 0
If $bf[0][0] = 0 Then
_zm("  [I] No system recovery points were found")
Return Null
EndIf
Local $bg[1][3] = [[Null, Null, Null]]
For $4c = 1 To $bf[0][0]
Local $b4 = _y4($bf[$4c][0])
$9c += $b4
If $b4 = 1 Then
_zm("    => [OK] RP named " & $bf[$4c][1] & " created at " & $bf[$4c][2] & " deleted")
Else
Local $bh[1][3] = [[$bf[$4c][0], $bf[$4c][1], $bf[$4c][2]]]
_vv($bg, $bh)
EndIf
Next
If 1 < UBound($bg) Then
Sleep(3000)
For $4c = 1 To UBound($bg) - 1
Local $b4 = _y4($bg[$4c][0])
$9c += $b4
If $b4 = 1 Then
_zm("    => [OK] RP named " & $bg[$4c][1] & " created at " & $bf[$4c][2] & " deleted")
Else
_zm("    => [X] RP named " & $bg[$4c][1] & " created at " & $bf[$4c][2] & " deleted")
EndIf
Next
EndIf
If $bf[0][0] = $9c Then
_zm(@CRLF & "  [OK] All system restore points have been successfully deleted")
Else
_zm(@CRLF & "  [X] Failure when deleting all restore points")
EndIf
EndFunc
Func _108($81)
Local $bi = StringLeft($81, 4)
Local $bj = StringMid($81, 6, 2)
Local $bk = StringMid($81, 9, 2)
Local $5h = StringRight($81, 8)
Return $bj & "/" & $bk & "/" & $bi & " " & $5h
EndFunc
Func _109($bl = False)
Local Const $bf = _y2()
If $bf[0][0] = 0 Then
Return Null
EndIf
Local Const $bm = _108(_31('n', -1470, _3p()))
Local $bn = False
Local $bo = False
Local $bp = False
For $4c = 1 To $bf[0][0]
Local $bq = $bf[$4c][2]
If $bq > $bm Then
If $bp = False Then
$bp = True
$bo = True
_zm(@CRLF & "  [I] Recent System Restore Point Deletion before create new:" & @CRLF)
EndIf
Local $b4 = _y4($bf[$4c][0])
If $b4 = 1 Then
_zm("    => [OK] RP named " & $bf[$4c][1] & " created at " & $bq & " deleted")
ElseIf $bl = False Then
$bn = True
Else
_zm("    => [X] RP named " & $bf[$4c][1] & " created at " & $bq & " deleted")
EndIf
EndIf
Next
If $bn = True Then
Sleep(3000)
_zm("  [I] Retry deleting restore point")
_109(True)
EndIf
If $bo = True Then
_zm(@CRLF)
EndIf
Sleep(3000)
EndFunc
Func _10a()
Sleep(3000)
_zm(@CRLF & "- Display All System Restore Point -" & @CRLF)
Local Const $bf = _y2()
If $bf[0][0] = 0 Then
_zm("  [X] No System Restore point found")
Return
EndIf
For $4c = 1 To $bf[0][0]
_zm("    => [I] RP named " & $bf[$4c][1] & " created at " & $bf[$4c][2] & " found")
Next
EndFunc
Func _10b()
RunWait(@ComSpec & ' /c ' & 'wmic.exe /Namespace:\\root\default Path SystemRestore Call CreateRestorePoint "KpRm", 100, 7', "", @SW_HIDE)
Return @error
EndFunc
Func _10c($bl = False)
If $bl = False Then
_zm(@CRLF & "- Create New System Restore Point -" & @CRLF)
Else
_zm("  [I] Retry Create New System Restore Point")
EndIf
Dim $br
Local $bs = _y6()
If $bs = 0 Then
Sleep(3000)
$bs = _y6()
If $bs = 0 Then
_zm("  [X] Enable System Restore")
EndIf
ElseIf $bs = 1 Then
_zm("  [OK] Enable System Restore")
EndIf
_109()
Local Const $bt = _10b()
If $bt <> 0 Then
_zm("  [X] System Restore Point created")
If $bl = False Then
_zm("  [I] Retry to create System Restore Point!")
_10c(True)
Return
Else
_10a()
Return
EndIf
ElseIf $bt = 0 Then
_zm("  [OK] System Restore Point created")
_10a()
EndIf
EndFunc
Func _10d()
_zm(@CRLF & "- Create Registry Backup -" & @CRLF)
Local Const $bu = @HomeDrive & "\KPRM"
Local Const $bv = $bu & "\regedit-backup-" & @YEAR & @MON & @MDAY & @HOUR & @MIN & ".reg"
If FileExists($bv) Then
FileMove($bv, $bv & ".old")
EndIf
Local Const $b4 = RunWait("Regedit /e " & $bv)
If Not FileExists($bv) Or @error <> 0 Then
_zm("  [X] Failed to create registry backup")
MsgBox(16, $7i, $7j)
_zi()
Else
_zm("  [OK] Registry Backup: " & $bv)
EndIf
EndFunc
Func _10e()
_zm(@CRLF & "- Restore UAC Default Value -" & @CRLF)
Local $b4 = _xr()
If $b4 = 1 Then
_zm("  [OK] Set ConsentPromptBehaviorAdmin with default (5) value")
Else
_zm("  [X] Set ConsentPromptBehaviorAdmin with default value")
EndIf
Local $b4 = _xs(3)
If $b4 = 1 Then
_zm("  [OK] Set ConsentPromptBehaviorUser with default (3) value")
Else
_zm("  [X] Set ConsentPromptBehaviorUser with default value")
EndIf
Local $b4 = _xt()
If $b4 = 1 Then
_zm("  [OK] Set EnableInstallerDetection with default (0) value")
Else
_zm("  [X] Set EnableInstallerDetection with default value")
EndIf
Local $b4 = _xu()
If $b4 = 1 Then
_zm("  [OK] Set EnableLUA with default (1) value")
Else
_zm("  [X] Set EnableLUA with default value")
EndIf
Local $b4 = _xv()
If $b4 = 1 Then
_zm("  [OK] Set EnableSecureUIAPaths with default (1) value")
Else
_zm("  [X] Set EnableSecureUIAPaths with default value")
EndIf
Local $b4 = _xw()
If $b4 = 1 Then
_zm("  [OK] Set EnableUIADesktopToggle with default (0) value")
Else
_zm("  [X] Set EnableUIADesktopToggle with default value")
EndIf
Local $b4 = _xx()
If $b4 = 1 Then
_zm("  [OK] Set EnableVirtualization with default (1) value")
Else
_zm("  [X] Set EnableVirtualization with default value")
EndIf
Local $b4 = _xy()
If $b4 = 1 Then
_zm("  [OK] Set FilterAdministratorToken with default (0) value")
Else
_zm("  [X] Set FilterAdministratorToken with default value")
EndIf
Local $b4 = _xz()
If $b4 = 1 Then
_zm("  [OK] Set PromptOnSecureDesktop with default (1) value")
Else
_zm("  [X] Set PromptOnSecureDesktop with default value")
EndIf
Local $b4 = _y0()
If $b4 = 1 Then
_zm("  [OK] Set ValidateAdminCodeSignatures with default (0) value")
Else
_zm("  [X] Set ValidateAdminCodeSignatures with default value")
EndIf
EndFunc
Func _10f()
_zm(@CRLF & "- Restore Default System Settings -" & @CRLF)
Local $b4 = RunWait(@ComSpec & " /c " & "ipconfig /flushdns", @TempDir, @SW_HIDE)
If @error <> 0 Then
_zm("  [X] Flush DNS")
Else
_zm("  [OK] Flush DNS")
EndIf
Local Const $bw[7] = [ "netsh winsock reset", "netsh winhttp reset proxy", "netsh winhttp reset tracing", "netsh winsock reset catalog", "netsh int ip reset all", "netsh int ipv4 reset catalog", "netsh int ipv6 reset catalog" ]
$b4 = 0
For $4c = 0 To UBound($bw) -1
RunWait(@ComSpec & " /c " & $bw[$4c], @TempDir, @SW_HIDE)
If @error <> 0 Then
$b4 += 1
EndIf
Next
If $b4 = 0 Then
_zm("  [OK] Reset WinSock")
Else
_zm("  [X] Reset WinSock")
EndIf
Local $bx = "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced"
$b4 = RegWrite($bx, "Hidden", "REG_DWORD", "2")
If $b4 = 1 Then
_zm("  [OK] Hide Hidden file.")
Else
_zm("  [X] Hide Hidden File")
EndIf
$b4 = RegWrite($bx, "HideFileExt", "REG_DWORD", "0")
If $b4 = 1 Then
_zm("  [OK] Hide Extensions for known file types")
Else
_zm("  [X] Hide Extensions for known file types")
EndIf
$b4 = RegWrite($bx, "ShowSuperHidden", "REG_DWORD", "0")
If $b4 = 1 Then
_zm("  [OK] Hide protected operating system files")
Else
_zm("  [X] Hide protected operating system files")
EndIf
_zn()
EndFunc
Global $az = ObjCreate("Scripting.Dictionary")
Local Const $by[46] = [ "adlicediag", "adsfix", "adwcleaner", "aswmbr", "avenger", "blitzblank", "ckscanner", "cmd-command", "combofix", "dds", "defogger", "frst", "fss", "g3n-h@ckm@n_tools", "grantperms", "javara", "listparts", "logonfix", "malwarebytes_tools", "mbar", "miniregtool", "minitoolbox", "otl", "otm", "quickdiag", "regtoolexport", "remediate-vbs-worm", "report_chkdsk", "roguekiller", "rstassociations", "rsthosts", "scanrapide", "seaf", "sft", "systemlook", "tdsskiller", "toolsdiag", "usbfix", "winchk", "winupdatefix", "zhp", "zhpcleaner", "zhpdiag", "zhpfix", "zhplite", "zoek"]
For $bz = 0 To UBound($by) - 1
Local $c0 = ObjCreate("Scripting.Dictionary")
Local $c1 = ObjCreate("Scripting.Dictionary")
Local $c2 = ObjCreate("Scripting.Dictionary")
Local $c3 = ObjCreate("Scripting.Dictionary")
Local $c4 = ObjCreate("Scripting.Dictionary")
$c0.add("key", $c1)
$c0.add("element", $c2)
$c0.add("uninstall", $c3)
$c0.add("process", $c4)
$az.add($by[$bz], $c0)
Next
Global $c5[1][2] = [[Null, Null]]
Global $c6[1][5] = [[Null, Null, Null, Null, Null]]
Global $c7[1][5] = [[Null, Null, Null, Null, Null]]
Global $c8[1][5] = [[Null, Null, Null, Null, Null]]
Global $c9[1][5] = [[Null, Null, Null, Null, Null]]
Global $ca[1][5] = [[Null, Null, Null, Null, Null]]
Global $cb[1][2] = [[Null, Null]]
Global $cc[1][2] = [[Null, Null]]
Global $cd[1][4] = [[Null, Null, Null, Null]]
Global $ce[1][5] = [[Null, Null, Null, Null, Null]]
Global $cf[1][5] = [[Null, Null, Null, Null, Null]]
Global $cg[1][5] = [[Null, Null, Null, Null, Null]]
Global $ch[1][5] = [[Null, Null, Null, Null, Null]]
Global $ci[1][5] = [[Null, Null, Null, Null, Null]]
Global $cj[1][3] = [[Null, Null, Null]]
Global $ck[1][3] = [[Null, Null, Null]]
Global $cl[1][4] = [[Null, Null, Null, Null]]
Func _10g($am, $cm = 0, $cn = False)
Dim $co
If $co Then _zm("[I] prepareRemove " & $am)
If $cn Then
_yx($am)
_yf($am)
EndIf
Local Const $cp = FileGetAttrib($am)
If StringInStr($cp, "R") Then
FileSetAttrib($am, "-R", $cm)
EndIf
If StringInStr($cp, "S") Then
FileSetAttrib($am, "-S", $cm)
EndIf
If StringInStr($cp, "H") Then
FileSetAttrib($am, "-H", $cm)
EndIf
If StringInStr($cp, "A") Then
FileSetAttrib($am, "-A", $cm)
EndIf
EndFunc
Func _10h($cq, $aw, $cr = Null, $cn = False)
Dim $co
If $co Then _zm("[I] RemoveFile " & $cq)
Local Const $cs = _zt($cq)
If $cs Then
If $cr And StringRegExp($cq, "(?i)\.(exe|com)$") Then
Local Const $ct = FileGetVersion($cq, "CompanyName")
If @error Then
Return 0
ElseIf Not StringRegExp($ct, $cr) Then
Return 0
EndIf
EndIf
_0zz($aw, 'element', $cq)
_10g($cq, 0, $cn)
Local $cu = FileDelete($cq)
If $cu Then
If $co Then
_zm("  [OK] File " & $cq & " deleted successfully")
EndIf
Return 1
EndIf
Return 2
EndIf
Return 0
EndFunc
Func _10i($am, $aw, $cn = False)
Dim $co
If $co Then _zm("[I] RemoveFolder " & $am)
Local $cs = _zu($am)
If $cs Then
_0zz($aw, 'element', $am)
_10g($am, 1, $cn)
Local Const $cu = DirRemove($am, $m)
If $cu Then
If $co Then
_zm("  [OK] Directory " & $am & " deleted successfully")
EndIf
Return 1
EndIf
Return 2
EndIf
Return 0
EndFunc
Func _10j($am, $cq, $cv)
Dim $co
If $co Then _zm("[I] FindGlob " & $am & " " & $cq)
Local Const $cw = $am & "\" & $cq
Local Const $5v = FileFindFirstFile($cw)
Local $cx = []
If $5v = -1 Then
Return $cx
EndIf
Local $5t = FileFindNextFile($5v)
While @error = 0
If StringRegExp($5t, $cv) Then
_vv($cx, $am & "\" & $5t)
EndIf
$5t = FileFindNextFile($5v)
WEnd
FileClose($5v)
Return $cx
EndFunc
Func _10k($cy, $cz)
Local $d0 = _zv($cy)
If $d0 = Null Then
Return Null
EndIf
Local $74 = "", $75 = "", $5t = "", $76 = ""
Local $b7 = _xe($cy, $74, $75, $5t, $76)
Local $d1 = $5t & $76
For $d2 = 1 To UBound($cz) - 1
If $cz[$d2][3] And $d0 = $cz[$d2][1] And StringRegExp($d1, $cz[$d2][3]) Then
Local $b4 = 0
Local $cn = False
If $cz[$d2][4] = True Then
$cn = True
EndIf
If $d0 = 'file' Then
$b4 = _10h($cy, $cz[$d2][0], $cz[$d2][2], $cn)
ElseIf $d0 = 'folder' Then
$b4 = _10i($cy, $cz[$d2][0], $cn)
EndIf
EndIf
Next
EndFunc
Func _10l($am, $cz, $d3 = -2)
Dim $co
If $co Then _zm("[I] RemoveAllFileFromWithMaxDepth " & $am)
Local $42 = _x2($am, "*.exe;*.txt;*.lnk;*.log;*.reg;*.zip;*.dat;*.scr;*.com", $p, $d3, $u, $w)
If @error <> 0 Then
Return Null
EndIf
For $4c = 1 To $42[0]
_10k($42[$4c], $cz)
Next
EndFunc
Func _10m($am, $cz)
Dim $co
If $co Then _zm("[I] RemoveAllFileFrom " & $am)
Local Const $cw = $am & "\*"
Local Const $5v = FileFindFirstFile($cw)
If $5v = -1 Then
Return Null
EndIf
Local $5t = FileFindNextFile($5v)
While @error = 0
Local $cy = $am & "\" & $5t
_10k($cy, $cz)
$5t = FileFindNextFile($5v)
WEnd
FileClose($5v)
EndFunc
Func _10n($ao, $aw, $cn = False)
Dim $co
If $co Then _zm("[I] RemoveRegistryKey " & $ao)
If $cn = True Then
_yx($ao)
_yf($ao, $88)
EndIf
Local Const $b4 = RegDelete($ao)
If $b4 <> 0 Then
_0zz($aw, "key", $ao)
If $co Then
If $b4 = 1 Then
_zm("  [OK] " & $ao & " deleted successfully")
ElseIf $b4 = 2 Then
_zm("  [X] " & $ao & " deleted failed")
EndIf
EndIf
EndIf
Return $b4
EndFunc
Func _10o($b2)
Local $d4 = 50
Dim $co
If $co Then _zm("[I] CloseProcessAndWait " & $b2)
If 0 = ProcessExists($b2) Then Return 0
ProcessClose($b2)
Do
$d4 -= 1
Sleep(250)
Until($d4 = 0 Or 0 = ProcessExists($b2))
Local Const $b4 = ProcessExists($b2)
If 0 = $b4 Then
If $co Then _zm("  [OK] Proccess " & $b2 & " stopped successfully")
Return 1
EndIf
Return 0
EndFunc
Func _10p($ac)
Dim $d4
Dim $co
If $co Then _zm("[I] RemoveAllProcess")
Local $d5 = ProcessList()
For $4c = 1 To $d5[0][0]
Local $d6 = $d5[$4c][0]
Local $d7 = $d5[$4c][1]
For $d4 = 1 To UBound($ac) - 1
If StringRegExp($d6, $ac[$d4][1]) Then
_10o($d7)
_0zz($ac[$d4][0], "process", $d6)
EndIf
Next
Next
EndFunc
Func _10q($d8)
Dim $co
If $co Then _zm("[I] RemoveScheduleTask")
For $4c = 1 To UBound($d8) - 1
RunWait('schtasks.exe /delete /tn "' & $d8[$4c][1] & '" /f', @TempDir, @SW_HIDE)
Next
EndFunc
Func _10r($d8)
Dim $co
If $co Then _zm("[I] UninstallNormaly")
Local Const $ar = _zs()
For $4c = 1 To UBound($ar) - 1
For $d9 = 1 To UBound($d8) - 1
Local $da = $d8[$d9][1]
Local $db = $d8[$d9][2]
Local $dc = _10j($ar[$4c], "*", $da)
For $dd = 1 To UBound($dc) - 1
Local $de = _10j($dc[$dd], "*", $db)
For $df = 1 To UBound($de) - 1
If _zt($de[$df]) Then
RunWait($de[$df])
_0zz($d8[$d9][0], "uninstall", $de[$df])
EndIf
Next
Next
Next
Next
EndFunc
Func _10s($d8)
Dim $co
If $co Then _zm("[I] RemoveAllProgramFilesDir")
Local Const $ar = _zs()
For $4c = 1 To UBound($ar) - 1
_10m($ar[$4c], $d8)
Next
EndFunc
Func _10t($d8)
Dim $co
If $co Then _zm("[I] RemoveAllSoftwareKeyList")
Local $7t = ""
If @OSArch = "X64" Then $7t = "64"
Local $dg[2] = ["HKCU" & $7t & "\SOFTWARE", "HKLM" & $7t & "\SOFTWARE"]
For $55 = 0 To UBound($dg) - 1
Local $4c = 0
While True
$4c += 1
Local $ap = RegEnumKey($dg[$55], $4c)
If @error <> 0 Then ExitLoop
For $d9 = 1 To UBound($d8) - 1
If $ap And $d8[$d9][1] Then
If StringRegExp($ap, $d8[$d9][1]) Then
Local $dh = $dg[$55] & "\" & $ap
_10n($dh, $d8[$d9][0])
EndIf
EndIf
Next
WEnd
Next
EndFunc
Func _10u($d8)
Dim $co
If $co Then _zm("[I] RemoveUninstallStringWithSearch")
For $4c = 1 To UBound($d8) - 1
Local $dh = _zq($d8[$4c][1], $d8[$4c][2], $d8[$4c][3])
If $dh And $dh <> "" Then
_10n($dh, $d8[$4c][0])
EndIf
Next
EndFunc
Func _10v($d8)
Dim $co
If $co Then _zm("[I] RemoveAllRegistryKeys")
For $4c = 1 To UBound($d8) - 1
_10n($d8[$4c][1], $d8[$4c][0], $d8[$4c][2])
Next
EndFunc
Func _10w($d8)
For $4c = 1 To UBound($d8) - 1
If FileExists($d8[$4c][1]) Then
Local $di = _x1($d8[$4c][1])
If @error = 0 Then
For $dd = 1 To $di[0]
_10h($d8[$4c][1] & '\' & $di[$dd], $d8[$4c][0], $d8[$4c][2], $d8[$4c][3])
Next
EndIf
EndIf
Next
EndFunc
Func _10x()
Local Const $dj = "frst"
Dim $c5
Dim $c6
Dim $dk
Dim $c8
Dim $dl
Dim $ca
Local Const $cr = "(?i)^Farbar"
Local Const $dm = "(?i)^FRST.*\.exe$"
Local Const $dn = "(?i)^FRST-OlderVersion$"
Local Const $do = "(?i)^(FRST|fixlist|fixlog|Addition|Shortcut).*\.(exe|txt)$"
Local Const $dp = "(?i)^FRST"
Local Const $dq[1][2] = [[$dj, $dm]]
Local Const $dr[1][5] = [[$dj, 'file', $cr, $do, False]]
Local Const $ds[1][5] = [[$dj, 'folder', Null, $dn, False]]
Local Const $dt[1][5] = [[$dj, 'folder', Null, $dp, True]]
_vv($c5, $dq)
_vv($c6, $dr)
_vv($c8, $dr)
_vv($c6, $ds)
_vv($c8, $ds)
_vv($ca, $dt)
EndFunc
_10x()
Func _10y()
Dim $cg
Dim $cb
Local $dj = "zhp"
Local Const $at[1][2] = [[$dj, "(?i)^ZHP$"]]
Local Const $du[1][5] = [[$dj, 'folder', Null, "(?i)^ZHP$", True]]
_vv($cb, $at)
_vv($cg, $du)
EndFunc
_10y()
Func _10z()
Local Const $dv = Null
Local Const $dj = "zhpdiag"
Dim $c5
Dim $c6
Dim $c7
Dim $c8
Dim $ca
Local Const $dm = "(?i)^ZHPDiag.*\.exe$"
Local Const $dn = "(?i)^ZHPDiag.*\.(exe|txt|lnk)$"
Local Const $do = "(?i)^PhysicalDisk[0-9]_MBR\.bin$"
Local Const $dq[1][2] = [[$dj, $dm]]
Local Const $dr[1][5] = [[$dj, 'file', $dv, $dn, False]]
Local Const $ds[1][5] = [[$dj, 'file', Null, $do, True]]
_vv($c5, $dq)
_vv($c6, $dr)
_vv($c8, $dr)
_vv($c7, $dr)
_vv($ca, $ds)
EndFunc
_10z()
Func _110()
Local Const $dv = Null
Local Const $dw = "zhpfix"
Dim $c5
Dim $c6
Dim $c8
Local Const $dm = "(?i)^ZHPFix.*\.exe$"
Local Const $dn = "(?i)^ZHPFix.*\.(exe|txt|lnk)$"
Local Const $dq[1][2] = [[$dw, $dm]]
Local Const $dr[1][5] = [[$dw, 'file', $dv, $dn, False]]
_vv($c5, $dq)
_vv($c6, $dr)
_vv($c8, $dr)
EndFunc
_110()
Func _111()
Local Const $dv = Null
Local Const $dw = "zhplite"
Dim $c5
Dim $c6
Dim $c8
Local Const $dm = "(?i)^ZHPLite.*\.exe$"
Local Const $dn = "(?i)^ZHPLite.*\.(exe|txt|lnk)$"
Local Const $dq[1][2] = [[$dw, $dm]]
Local Const $dr[1][5] = [[$dw, 'file', $dv, $dn, False]]
_vv($c5, $dq)
_vv($c6, $dr)
_vv($c8, $dr)
EndFunc
_111()
Func _112($bl = False)
Local Const $cr = "(?i)^Malwarebytes Anti-Rootkit$"
Local Const $dx = "(?i)^Malwarebytes"
Local Const $dj = "mbar"
Dim $c5
Dim $c6
Dim $c8
Dim $cb
Local Const $dm = "(?i)^mbar.*\.exe$"
Local Const $dn = "(?i)^mbar"
Local Const $dq[1][2] = [[$dj, $dm]]
Local Const $dr[1][2] = [[$dj, $cr]]
Local Const $ds[1][5] = [[$dj, 'file', $dx, $dm, False]]
Local Const $dt[1][5] = [[$dj, 'folder', $cr, $dn, False]]
_vv($c5, $dq)
_vv($c6, $ds)
_vv($c8, $ds)
_vv($c6, $dt)
_vv($c8, $dt)
_vv($cb, $dr)
EndFunc
_112()
Func _113()
Dim $cl
Local Const $dj = "malwarebytes_tools"
Local Const $dq[1][4] = [[$dj, @AppDataCommonDir & "\Malwarebytes\Malwarebytes' Anti-Malware\Quarantine", Null, True]]
_vv($cl, $dq)
EndFunc
_113()
Func _114()
Local Const $dj = "roguekiller"
Dim $c5
Dim $cc
Dim $cd
Dim $c9
Dim $ce
Dim $c6
Dim $c7
Dim $ch
Dim $c8
Local $7t = ""
If @OSArch = "X64" Then $7t = "64"
Local Const $dy = "(?i)^Adlice"
Local Const $dm = "(?i)^RogueKiller"
Local Const $dn = "(?i)^RogueKiller.*\.(exe|lnk|txt)$"
Local Const $do = "(?i)^RogueKiller.*\.exe$"
Local Const $dp = "(?i)^RogueKiller_portable(32|64)\.exe$"
Local Const $dq[1][2] = [[$dj, $do]]
Local Const $dr[1][2] = [[$dj, "RogueKiller Anti-Malware"]]
Local Const $ds[1][4] = [[$dj, "HKLM" & $7t & "\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall", $dm, "DisplayName"]]
Local Const $dt[1][5] = [[$dj, 'file', $dy, $dn, False]]
Local Const $dz[1][5] = [[$dj, 'folder', Null, $dm, True]]
Local Const $e0[1][5] = [[$dj, 'file', Null, $dp, False]]
_vv($c5, $dq)
_vv($cc, $dr)
_vv($cd, $ds)
_vv($c9, $dz)
_vv($ce, $dz)
_vv($c6, $e0)
_vv($c6, $dt)
_vv($c6, $dz)
_vv($c8, $e0)
_vv($c8, $dt)
_vv($c8, $dz)
_vv($c7, $dt)
_vv($ch, $dz)
EndFunc
_114()
Func _115()
Local Const $dj = "adwcleaner"
Local Const $cr = "(?i)^AdwCleaner"
Local Const $dx = "(?i)^Malwarebytes"
Local Const $dm = "(?i)^AdwCleaner.*\.exe$"
Dim $c5
Dim $c6
Dim $c8
Dim $ca
Local Const $dq[1][2] = [[$dj, $dm]]
Local Const $dr[1][5] = [[$dj, 'file', $dx, $dm, False]]
Local Const $ds[1][5] = [[$dj, 'folder', Null, $cr, True]]
_vv($c5, $dq)
_vv($c6, $dr)
_vv($c8, $dr)
_vv($ca, $ds)
EndFunc
_115()
Func _116()
Local Const $dv = Null
Local Const $dj = "zhpcleaner"
Dim $c5
Dim $c6
Dim $c8
Local Const $dm = "(?i)^ZHPCleaner.*\.exe$"
Local Const $dn = "(?i)^ZHPCleaner.*\.(exe|txt|lnk)$"
Local Const $dq[1][2] = [[$dj, $dm]]
Local Const $dr[1][5] = [[$dj, 'file', $dv, $dn, False]]
_vv($c5, $dq)
_vv($c6, $dr)
_vv($c8, $dr)
EndFunc
_116()
Func _117()
Local Const $dj = "usbfix"
Dim $c5
Dim $cj
Dim $c6
Dim $c7
Dim $c8
Dim $cb
Dim $ca
Dim $c9
Local Const $cr = "(?i)^UsbFix"
Local Const $dx = "(?i)^SosVirus"
Local Const $dm = "(?i)^UsbFix.*\.(exe|lnk|txt)$"
Local Const $dn = "(?i)^Un-UsbFix\.exe$"
Local Const $do = "(?i)^UsbFixQuarantine$"
Local Const $dp = "(?i)^UsbFix.*\.exe$"
Local Const $e1[1][2] = [[$dj, $dp]]
Local Const $dq[1][2] = [[$dj, $cr]]
Local Const $dr[1][3] = [[$dj, $cr, $dn]]
Local Const $ds[1][5] = [[$dj, 'file', $dx, $dm, False]]
Local Const $dt[1][5] = [[$dj, 'folder', Null, $do, True]]
Local Const $dz[1][5] = [[$dj, 'folder', Null, $cr, False]]
_vv($c5, $e1)
_vv($cj, $dr)
_vv($c6, $ds)
_vv($c7, $ds)
_vv($c8, $ds)
_vv($cb, $dq)
_vv($ca, $dt)
_vv($ca, $dz)
_vv($c9, $dz)
EndFunc
_117()
Func _118()
Local Const $dj = "adsfix"
Dim $c5
Dim $c6
Dim $c8
Dim $ca
Dim $c7
Dim $cb
Local Const $cr = "(?i)^AdsFix"
Local Const $dx = "(?i)^SosVirus"
Local Const $dm = "(?i)^AdsFix.*\.exe$"
Local Const $dn = "(?i)^AdsFix.*\.(exe|txt|lnk)$"
Local Const $do = "(?i)^AdsFix.*\.txt$"
Local Const $dq[1][2] = [[$dj, $dm]]
Local Const $dr[1][5] = [[$dj, 'file', $dx, $dn, False]]
Local Const $ds[1][5] = [[$dj, 'file', Null, $do, False]]
Local Const $dt[1][5] = [[$dj, 'folder', Null, $cr, True]]
Local Const $dz[1][2] = [[$dj, $cr]]
_vv($c5, $dq)
_vv($c6, $dr)
_vv($c7, $dr)
_vv($c8, $dr)
_vv($ca, $ds)
_vv($ca, $dt)
_vv($cb, $dz)
EndFunc
_118()
Func _119()
Local Const $dj = "aswmbr"
Dim $c5
Dim $c6
Dim $c8
Dim $ck
Local Const $cr = "(?i)^avast"
Local Const $dm = "(?i)^aswmbr.*\.(exe|txt|lnk)$"
Local Const $dn = "(?i)^MBR\.dat$"
Local Const $do = "(?i)^aswmbr.*\.exe$"
Local $7t = ""
If @OSArch = "X64" Then $7t = "64"
Local Const $dq[1][2] = [[$dj, $do]]
Local Const $dr[1][5] = [[$dj, 'file', $cr, $dm, False]]
Local Const $ds[1][5] = [[$dj, 'file', Null, $dn, False]]
Local Const $dt[1][3] = [[$dj, "HKLM" & $7t & "\SYSTEM\CurrentControlSet\Enum\Root\LEGACY_ASWMBR", True]]
_vv($c5, $dq)
_vv($c6, $dr)
_vv($c6, $ds)
_vv($c8, $dr)
_vv($c8, $ds)
_vv($ck, $dt)
EndFunc
_119()
Func _11a()
Local Const $dj = "fss"
Dim $c5
Dim $c6
Dim $c8
Local Const $cr = "(?i)^Farbar"
Local Const $dm = "(?i)^FSS.*\.(exe|txt|lnk)$"
Local Const $dn = "(?i)^FSS.*\.exe$"
Local Const $dq[1][2] = [[$dj, $dn]]
Local Const $dr[1][5] = [[$dj, 'file', $cr, $dm, False]]
_vv($c5, $dq)
_vv($c6, $dr)
_vv($c8, $dr)
EndFunc
_11a()
Func _11b()
Local Const $dj = "toolsdiag"
Dim $c5
Dim $c6
Dim $c8
Dim $ca
Local Const $dm = "(?i)^toolsdiag.*\.exe$"
Local Const $dn = "(?i)^ToolsDiag$"
Local Const $dq[1][5] = [[$dj, 'folder', Null, $dn, False]]
Local Const $dr[1][5] = [[$dj, 'file', Null, $dm, False]]
Local Const $ds[1][2] = [[$dj, $dm]]
_vv($c5, $ds)
_vv($c6, $dr)
_vv($c8, $dr)
_vv($ca, $dq)
EndFunc
_11b()
Func _11c()
Local Const $dj = "scanrapide"
Dim $ca
Dim $c6
Dim $c8
Local Const $cr = Null
Local Const $dm = "(?i)^ScanRapide.*\.exe$"
Local Const $dn = "(?i)^ScanRapide\[R[0-9]+\]\.txt$"
Local Const $dq[1][5] = [[$dj, 'file', $cr, $dm, False]]
Local Const $dr[1][5] = [[$dj, 'file', Null, $dn, False]]
_vv($c6, $dq)
_vv($c8, $dq)
_vv($ca, $dr)
EndFunc
_11c()
Func _11d()
Local Const $dj = "otl"
Dim $c5
Dim $c6
Dim $c8
Dim $ca
Dim $cb
Local Const $cr = "(?i)^OldTimer"
Local Const $dm = "(?i)^OTL.*\.exe$"
Local Const $dn = "(?i)^OTL.*\.(exe|txt)$"
Local Const $do = "(?i)^Extras\.txt$"
Local Const $dp = "(?i)^_OTL$"
Local Const $e2 = "(?i)^OldTimer Tools$"
Local Const $dq[1][2] = [[$dj, $dm]]
Local Const $dr[1][5] = [[$dj, 'file', $cr, $dn, False]]
Local Const $ds[1][5] = [[$dj, 'file', Null, $do, False]]
Local Const $dt[1][5] = [[$dj, 'folder', Null, $dp, True]]
Local Const $dz[1][2] = [[$dj, $e2]]
_vv($c5, $dq)
_vv($c6, $dr)
_vv($c6, $ds)
_vv($c8, $dr)
_vv($ca, $dt)
_vv($cb, $dz)
EndFunc
_11d()
Func _11e()
Local Const $dj = "otm"
Dim $c5
Dim $c6
Dim $c8
Dim $ca
Local Const $cr = "(?i)^OldTimer"
Local Const $dm = "(?i)^OTM.*\.exe$"
Local Const $dn = "(?i)^_OTM$"
Local Const $dq[1][2] = [[$dj, $dm]]
Local Const $dr[1][5] = [[$dj, 'file', $cr, $dm, False]]
Local Const $ds[1][5] = [[$dj, 'folder', Null, $dn, True]]
_vv($c5, $dq)
_vv($c6, $dr)
_vv($c8, $dr)
_vv($ca, $ds)
EndFunc
_11e()
Func _11f()
Local Const $dj = "listparts"
Dim $c5
Dim $c6
Dim $c8
Dim $ca
Local Const $cr = "(?i)^Farbar"
Local Const $dm = "(?i)^listParts.*\.exe$"
Local Const $dn = "(?i)^Results\.txt$"
Local Const $dq[1][2] = [[$dj, $dm]]
Local Const $dr[1][5] = [[$dj, 'file', $cr, $dm, False]]
Local Const $ds[1][5] = [[$dj, 'file', Null, $dn, False]]
_vv($c5, $dq)
_vv($c6, $dr)
_vv($c6, $ds)
_vv($c8, $dr)
_vv($c8, $ds)
EndFunc
_11f()
Func _11g()
Local Const $dj = "minitoolbox"
Dim $c5
Dim $c6
Dim $c8
Dim $ca
Local Const $cr = "(?i)^Farbar"
Local Const $dm = "(?i)^MiniToolBox.*\.exe$"
Local Const $dn = "(?i)^MTB\.txt$"
Local Const $dq[1][2] = [[$dj, $dm]]
Local Const $dr[1][5] = [[$dj, 'file', $cr, $dm, False]]
Local Const $ds[1][5] = [[$dj, 'file', Null, $dn, False]]
_vv($c5, $dq)
_vv($c6, $dr)
_vv($c6, $ds)
_vv($c8, $dr)
_vv($c8, $ds)
EndFunc
_11g()
Func _11h()
Local Const $dj = "miniregtool"
Dim $c5
Dim $c6
Dim $c8
Dim $ca
Local Const $cr = Null
Local Const $dm = "(?i)^MiniRegTool.*\.exe$"
Local Const $dn = "(?i)^MiniRegTool.*\.(exe|zip)$"
Local Const $do = "(?i)^Result\.txt$"
Local Const $dp = "(?i)^MiniRegTool"
Local Const $dq[1][2] = [[$dj, $dm]]
Local Const $dr[1][5] = [[$dj, 'file', $cr, $dn, False]]
Local Const $ds[1][5] = [[$dj, 'file', $cr, $do, False]]
Local Const $dt[1][5] = [[$dj, 'folder', $cr, $dp, False]]
_vv($c5, $dq)
_vv($c6, $dr)
_vv($c6, $ds)
_vv($c6, $dt)
_vv($c8, $dr)
_vv($c8, $ds)
_vv($c8, $dt)
EndFunc
_11h()
Func _11i()
Local Const $dj = "grantperms"
Dim $c5
Dim $c6
Dim $c8
Dim $ca
Local Const $cr = Null
Local Const $dm = "(?i)^GrantPerms.*\.exe$"
Local Const $dn = "(?i)^GrantPerms.*\.(exe|zip)$"
Local Const $do = "(?i)^Perms\.txt$"
Local Const $dp = "(?i)^GrantPerms"
Local Const $dq[1][2] = [[$dj, $dm]]
Local Const $dr[1][5] = [[$dj, 'file', $cr, $dn, False]]
Local Const $ds[1][5] = [[$dj, 'file', $cr, $do, False]]
Local Const $dt[1][5] = [[$dj, 'folder', $cr, $dp, False]]
_vv($c5, $dq)
_vv($c6, $dr)
_vv($c6, $ds)
_vv($c6, $dt)
_vv($c8, $dr)
_vv($c8, $ds)
_vv($c8, $dt)
EndFunc
_11i()
Func _11j()
Local Const $dj = "combofix"
Dim $c6
Dim $c8
Dim $ca
Dim $ci
Dim $cb
Dim $c5
Dim $ck
Local Const $cr = "(?i)^Swearware"
Local Const $dm = "(?i)^Combofix.*\.exe$"
Local Const $dn = "(?i)^CFScript\.txt$"
Local Const $do = "(?i)^Qoobox$"
Local Const $dp = "(?i)^Combofix.*\.txt$"
Local Const $e2 = "(?i)^(grep|PEV|NIRCMD|MBR|SED|SWREG|SWSC|SWXCACLS|Zip)\.exe$"
Local Const $e3 = "(?i)^Swearware$"
Local $7t = ""
If @OSArch = "X64" Then $7t = "64"
Local Const $dq[1][5] = [[$dj, 'file', $cr, $dm, False]]
Local Const $dr[1][5] = [[$dj, 'file', Null, $dn, False]]
Local Const $ds[1][5] = [[$dj, 'folder', Null, $do, True]]
Local Const $dt[1][5] = [[$dj, 'file', Null, $dp, False]]
Local Const $dz[1][5] = [[$dj, 'file', Null, $e2, True]]
Local Const $e0[1][2] = [[$dj, $e3]]
Local Const $e4[1][2] = [[$dj, $dm]]
Local Const $e5[1][3] = [[$dj, "HKLM" & $7t & "\SOFTWARE\Microsoft\Windows\CurrentVersion\App Paths\combofix.exe", False]]
_vv($c6, $dq)
_vv($c6, $dr)
_vv($c8, $dq)
_vv($c8, $dr)
_vv($ca, $ds)
_vv($ca, $dt)
_vv($ci, $dz)
_vv($cb, $e0)
_vv($c5, $e4)
_vv($ck, $e5)
EndFunc
_11j()
Func _11k()
Local Const $dj = "regtoolexport"
Dim $c5
Dim $c6
Dim $c8
Local Const $cr = Null
Local Const $dm = "(?i)^regtoolexport.*\.exe$"
Local Const $dn = "(?i)^Export.*\.reg$"
Local Const $dq[1][2] = [[$dj, $dm]]
Local Const $dr[1][5] = [[$dj, 'file', $cr, $dm, False]]
Local Const $ds[1][5] = [[$dj, 'file', $cr, $dn, False]]
_vv($c5, $dq)
_vv($c6, $dr)
_vv($c6, $ds)
_vv($c8, $dr)
_vv($c8, $ds)
EndFunc
_11k()
Func _11l()
Local Const $dj = "tdsskiller"
Dim $c5
Dim $c6
Dim $c8
Dim $ca
Local Const $cr = "(?i)^.*Kaspersky"
Local Const $dm = "(?i)^tdsskiller.*\.exe$"
Local Const $dn = "(?i)^tdsskiller.*\.(exe|zip)$"
Local Const $do = "(?i)^TDSSKiller.*_log\.txt$"
Local Const $dp = "(?i)^TDSSKiller"
Local Const $dq[1][2] = [[$dj, $dm]]
Local Const $dr[1][5] = [[$dj, 'file', $cr, $dn, False]]
Local Const $ds[1][5] = [[$dj, 'file', Null, $do, False]]
Local Const $dt[1][5] = [[$dj, 'folder', Null, $dp, False]]
_vv($c5, $dq)
_vv($c6, $dr)
_vv($c6, $dt)
_vv($c8, $dr)
_vv($c8, $dt)
_vv($ca, $ds)
_vv($ca, $dt)
EndFunc
_11l()
Func _11m()
Local Const $dj = "winupdatefix"
Dim $c5
Dim $c6
Dim $c8
Dim $ca
Local Const $cr = Null
Local Const $dm = "(?i)^winupdatefix.*\.exe$"
Local Const $dn = "(?i)^winupdatefix.*\.txt$"
Local Const $dq[1][2] = [[$dj, $dm]]
Local Const $dr[1][5] = [[$dj, 'file', $cr, $dm, False]]
Local Const $ds[1][5] = [[$dj, 'file', $cr, $dn, False]]
_vv($c5, $dq)
_vv($c6, $dr)
_vv($c8, $dr)
_vv($ca, $ds)
EndFunc
_11m()
Func _11n()
Local Const $dj = "rsthosts"
Dim $c5
Dim $c6
Dim $c8
Dim $ca
Local Const $cr = Null
Local Const $dm = "(?i)^rsthosts.*\.exe$"
Local Const $dn = "(?i)^RstHosts.*\.txt$"
Local Const $dq[1][2] = [[$dj, $dm]]
Local Const $dr[1][5] = [[$dj, 'file', $cr, $dm, Null]]
Local Const $ds[1][5] = [[$dj, 'file', $cr, $dn, Null]]
_vv($c5, $dq)
_vv($c6, $dr)
_vv($c8, $dr)
_vv($ca, $ds)
EndFunc
_11n()
Func _11o()
Local Const $dj = "winchk"
Dim $c5
Dim $c6
Dim $c8
Dim $ca
Local Const $cr = Null
Local Const $dm = "(?i)^winchk.*\.exe$"
Local Const $dn = "(?i)^WinChk.*\.txt$"
Local Const $dq[1][2] = [[$dj, $dm]]
Local Const $dr[1][5] = [[$dj, 'file', $cr, $dm, False]]
Local Const $ds[1][5] = [[$dj, 'file', $cr, $dn, False]]
_vv($c5, $dq)
_vv($c6, $dr)
_vv($c8, $dr)
_vv($ca, $ds)
EndFunc
_11o()
Func _11p()
Local Const $dj = "avenger"
Dim $c5
Dim $c6
Dim $c8
Dim $ca
Local Const $cr = Null
Local Const $dm = "(?i)^avenger.*\.(exe|zip)$"
Local Const $dn = "(?i)^avenger"
Local Const $do = "(?i)^avenger.*\.txt$"
Local Const $dp = "(?i)^avenger.*\.exe$"
Local Const $dq[1][2] = [[$dj, $dp]]
Local Const $dr[1][5] = [[$dj, 'file', $cr, $dm, False]]
Local Const $ds[1][5] = [[$dj, 'folder', $cr, $dn, False]]
Local Const $dt[1][5] = [[$dj, 'file', $cr, $do, False]]
_vv($c5, $dq)
_vv($c6, $dr)
_vv($c6, $ds)
_vv($c8, $dr)
_vv($c8, $ds)
_vv($ca, $ds)
_vv($ca, $dt)
EndFunc
_11p()
Func _11q()
Local Const $dj = "blitzblank"
Dim $c5
Dim $c6
Dim $c8
Dim $ca
Dim $c7
Dim $cb
Local Const $cr = "(?i)^Emsi"
Local Const $dm = "(?i)^BlitzBlank.*\.exe$"
Local Const $dn = "(?i)^BlitzBlank.*\.log$"
Local Const $dq[1][2] = [[$dj, $dm]]
Local Const $dr[1][5] = [[$dj, 'file', $cr, $dm, False]]
Local Const $ds[1][5] = [[$dj, 'file', Null, $dn, False]]
_vv($c5, $dq)
_vv($c6, $dr)
_vv($c8, $dr)
_vv($ca, $ds)
EndFunc
_11q()
Func _11r()
Local Const $dj = "zoek"
Dim $c5
Dim $c6
Dim $c8
Dim $ca
Dim $c7
Dim $cb
Local Const $cr = Null
Local Const $dm = "(?i)^zoek.*\.exe$"
Local Const $dn = "(?i)^zoek.*\.log$"
Local Const $do = "(?i)^zoek"
Local Const $dp = "(?i)^runcheck.*\.txt$"
Local Const $dq[1][2] = [[$dj, $dm]]
Local Const $dr[1][5] = [[$dj, 'file', $cr, $dm, False]]
Local Const $ds[1][5] = [[$dj, 'file', $cr, $dn, False]]
Local Const $dt[1][5] = [[$dj, 'folder', $cr, $do, True]]
Local Const $dz[1][5] = [[$dj, 'file', $cr, $dp, False]]
_vv($c5, $dq)
_vv($c6, $dr)
_vv($c8, $dr)
_vv($ca, $ds)
_vv($ca, $dt)
_vv($ca, $dz)
EndFunc
_11r()
Func _11s()
Local Const $dj = "remediate-vbs-worm"
Dim $c5
Dim $c6
Dim $c8
Dim $ca
Dim $c7
Dim $cb
Local Const $cr = "(?i).*VBS autorun worms.*"
Local Const $dx = Null
Local Const $dm = "(?i)^remediate.?vbs.?worm.*\.exe$"
Local Const $dn = "(?i)^Rem-VBS.*\.log$"
Local Const $do = "(?i)^Rem-VBS"
Local Const $dp = "(?i)^Rem-VBSworm.*\.exe$"
Local Const $dq[1][2] = [[$dj, $dm]]
Local Const $dr[1][5] = [[$dj, 'file', $dx, $dm, False]]
Local Const $ds[1][5] = [[$dj, 'file', $dx, $dn, False]]
Local Const $dt[1][5] = [[$dj, 'folder', $cr, $do, True]]
Local Const $dz[1][2] = [[$dj, $dp]]
Local Const $e0[1][5] = [[$dj, 'file', $dx, $dp, False]]
_vv($c5, $dq)
_vv($c5, $dz)
_vv($c6, $dr)
_vv($c6, $e0)
_vv($c8, $dr)
_vv($c8, $e0)
_vv($ca, $ds)
_vv($ca, $dt)
EndFunc
_11s()
Func _11t()
Local Const $dj = "ckscanner"
Dim $c5
Dim $c6
Dim $c8
Local Const $cr = Null
Local Const $dm = "(?i)^CKScanner.*\.exe$"
Local Const $dn = "(?i)^CKfiles.*\.txt$"
Local Const $dq[1][2] = [[$dj, $dm]]
Local Const $dr[1][5] = [[$dj, 'file', $cr, $dm, False]]
Local Const $ds[1][5] = [[$dj, 'file', $cr, $dn, False]]
_vv($c5, $dq)
_vv($c6, $dr)
_vv($c8, $dr)
_vv($c6, $ds)
_vv($c8, $ds)
EndFunc
_11t()
Func _11u()
Local Const $dj = "quickdiag"
Dim $c5
Dim $c6
Dim $c8
Dim $ca
Local Const $cr = "(?i)^SosVirus"
Local Const $dm = "(?i)^QuickDiag.*\.exe$"
Local Const $dn = "(?i)^QuickDiag.*\.(exe|txt)$"
Local Const $do = "(?i)^QuickScript.*\.txt$"
Local Const $dp = "(?i)^QuickDiag.*\.txt$"
Local Const $e2 = "(?i)^QuickDiag"
Local Const $dq[1][2] = [[$dj, $dm]]
Local Const $dr[1][5] = [[$dj, 'file', $cr, $dn, True]]
Local Const $ds[1][5] = [[$dj, 'file', Null, $do, True]]
Local Const $dt[1][5] = [[$dj, 'file', Null, $dp, True]]
Local Const $dz[1][5] = [[$dj, 'folder', Null, $e2, True]]
_vv($c5, $dq)
_vv($c6, $dr)
_vv($c8, $dr)
_vv($c6, $ds)
_vv($c8, $ds)
_vv($ca, $dt)
_vv($ca, $dz)
EndFunc
_11u()
Func _11v()
Local Const $dj = "adlicediag"
Dim $c5
Dim $cd
Dim $c9
Dim $ce
Dim $c6
Dim $c8
Dim $c7
Dim $ch
Local $7t = ""
If @OSArch = "X64" Then $7t = "64"
Local Const $e6 = "(?i)^Adlice Diag"
Local Const $dm = "(?i)^Diag version"
Local Const $dn = "(?i)^Diag$"
Local Const $do = "(?i)^ADiag$"
Local Const $dp = "(?i)^Diag_portable(32|64)\.exe$"
Local Const $e2 = "(?i)^Diag\.lnk$"
Local Const $e3 = "(?i)^Diag_setup\.exe$"
Local Const $e7 = "(?i)^Diag(32|64)?\.exe$"
Local Const $dq[1][2] = [[$dj, $e6]]
Local Const $dr[1][4] = [[$dj, "HKLM" & $7t & "\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall", $dm, "DisplayName"]]
Local Const $ds[1][5] = [[$dj, 'folder', Null, $dn, True]]
Local Const $dt[1][5] = [[$dj, 'folder', Null, $do, True]]
Local Const $dz[1][5] = [[$dj, 'file', Null, $dp, False]]
Local Const $e0[1][5] = [[$dj, 'file', Null, $e2, False]]
Local Const $e4[1][5] = [[$dj, 'file', Null, $e3, False]]
Local Const $e5[1][2] = [[$dj, $e7]]
_vv($c5, $dq)
_vv($c5, $e5)
_vv($cd, $dr)
_vv($c9, $ds)
_vv($ce, $dt)
_vv($c6, $dz)
_vv($c6, $e0)
_vv($c6, $e4)
_vv($c8, $dz)
_vv($c8, $e4)
_vv($c7, $e0)
_vv($ch, $ds)
EndFunc
_11v()
Func _11w()
Local Const $dv = Null
Local Const $dj = "rstassociations"
Dim $c5
Dim $c6
Dim $c8
Dim $ca
Local Const $dm = "(?i)^rstassociations.*\.(exe|scr)$"
Local Const $dn = "(?i)^RstAssociations.*\.txt$"
Local Const $dq[1][2] = [[$dj, $dm]]
Local Const $dr[1][5] = [[$dj, 'file', $dv, $dm, False]]
Local Const $ds[1][5] = [[$dj, 'file', $dv, $dn, False]]
_vv($c5, $dq)
_vv($c6, $dr)
_vv($c8, $dr)
_vv($ca, $ds)
EndFunc
_11w()
Func _11x()
Local Const $dv = Null
Local Const $dj = "sft"
Dim $c5
Dim $c6
Dim $c8
Local Const $dm = "(?i)^SFT.*\.exe$"
Local Const $dn = "(?i)^SFT.*\.(txt|exe|zip)$"
Local Const $dq[1][2] = [[$dj, $dm]]
Local Const $dr[1][5] = [[$dj, 'file', $dv, $dn, False]]
_vv($c5, $dq)
_vv($c6, $dr)
_vv($c8, $dr)
EndFunc
_11x()
Func _11y()
Local Const $dj = "logonfix"
Dim $c5
Dim $c6
Dim $c8
Dim $ca
Local Const $cr = Null
Local Const $dm = "(?i)^logonfix.*\.exe$"
Local Const $dn = "(?i)^LogonFix.*\.txt$"
Local Const $dq[1][2] = [[$dj, $dm]]
Local Const $dr[1][5] = [[$dj, 'file', $cr, $dm, False]]
Local Const $ds[1][5] = [[$dj, 'file', $cr, $dn, False]]
_vv($c5, $dq)
_vv($c6, $dr)
_vv($c8, $dr)
_vv($ca, $ds)
EndFunc
_11y()
Func _11z()
Local Const $dj = "cmd-command"
Dim $c5
Dim $c6
Dim $c8
Local Const $cr = "(?i)^g3n-h@ckm@n$"
Local Const $dm = "(?i)^cmd-command.*\.exe$"
Local Const $dq[1][2] = [[$dj, $dm]]
Local Const $dr[1][5] = [[$dj, 'file', $cr, $dm, False]]
_vv($c5, $dq)
_vv($c6, $dr)
_vv($c8, $dr)
EndFunc
_11z()
Func _120()
Local Const $dj = "report_chkdsk"
Dim $c5
Dim $c6
Dim $c8
Local Const $cr = Null
Local Const $dm = "(?i)^Report_CHKDSK.*\.exe$"
Local Const $dn = "(?i)^RapportCHK.*\.txt$"
Local Const $dq[1][2] = [[$dj, $dm]]
Local Const $dr[1][5] = [[$dj, 'file', $cr, $dm, False]]
Local Const $ds[1][5] = [[$dj, 'file', $cr, $dn, False]]
_vv($c5, $dq)
_vv($c6, $dr)
_vv($c6, $ds)
_vv($c8, $dr)
_vv($c8, $ds)
EndFunc
_120()
Func _121()
Local Const $dj = "seaf"
Dim $c5
Dim $c6
Dim $c8
Dim $cj
Dim $ck
Dim $ca
Dim $c9
Local Const $cr = "(?i)^C_XX$"
Local Const $e8 = "(?i)^SEAF$"
Local Const $dm = "(?i)^seaf.*\.exe$"
Local Const $dn = "(?i)^Un-SEAF\.exe$"
Local Const $do = "(?i)^SeafLog.*\.txt$"
Local $7t = ""
If @OSArch = "X64" Then $7t = "64"
Local Const $dq[1][2] = [[$dj, $dm]]
Local Const $dr[1][5] = [[$dj, 'file', $cr, $dm, False]]
Local Const $ds[1][3] = [[$dj, $e8, $dn]]
Local Const $dt[1][3] = [[$dj, "HKLM" & $7t & "\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\SEAF", False]]
Local Const $dz[1][5] = [[$dj, 'file', Null, $do, False]]
Local Const $e0[1][5] = [[$dj, 'folder', Null, $e8, True]]
_vv($c5, $dq)
_vv($c6, $dr)
_vv($c8, $dr)
_vv($cj, $ds)
_vv($ck, $dt)
_vv($ca, $dz)
_vv($c9, $e0)
EndFunc
_121()
Func _122()
Dim $c5
Dim $c6
Dim $c8
Local Const $dj = "dds"
Local Const $cr = "(?i)^Swearware"
Local Const $dm = "(?i)dds.*\.com"
Local Const $dn = "(?i)(dds|attach).*\.txt"
Local Const $dq[1][2] = [[$dj, $dm]]
Local Const $dr[1][5] = [[$dj, 'file', $cr, $dm, False]]
Local Const $ds[1][5] = [[$dj, 'file', Null, $dn, False]]
_vv($c5, $dq)
_vv($c6, $dr)
_vv($c6, $ds)
_vv($c8, $dr)
_vv($c8, $ds)
EndFunc
_122()
Func _123()
Dim $c5
Dim $c6
Dim $c8
Local Const $dj = "defogger"
Local Const $cr = Null
Local Const $dm = "(?i)defogger.*\.exe"
Local Const $dn = "(?i)defogger.*\.(log|exe)"
Local Const $dq[1][2] = [[$dj, $dm]]
Local Const $dr[1][5] = [[$dj, 'file', $cr, $dn, False]]
_vv($c5, $dq)
_vv($c6, $dr)
_vv($c8, $dr)
EndFunc
_123()
Func _124()
Dim $c5
Dim $c6
Dim $c8
Dim $ca
Local Const $dj = "javara"
Local Const $cr = "(?i)^The RaProducts Team"
Local Const $dm = "(?i)Javara"
Local Const $dn = "(?i)Javara.*\.exe"
Local Const $do = "(?i)Javara.*\.(zip|exe)"
Local Const $dp = "(?i)Javara.*\.log"
Local Const $dq[1][2] = [[$dj, $dn]]
Local Const $dr[1][5] = [[$dj, 'file', $cr, $do, False]]
Local Const $ds[1][5] = [[$dj, 'file', Null, $dp, False]]
Local Const $dt[1][5] = [[$dj, 'folder', Null, $dm, False]]
_vv($c5, $dq)
_vv($c6, $dr)
_vv($c6, $dt)
_vv($c8, $dr)
_vv($c8, $dt)
_vv($ca, $ds)
EndFunc
_124()
Func _125()
Local Const $dj = "g3n-h@ckm@n_tools"
Dim $cb
Local Const $e3 = "(?i)^g3n-h@ckm@n$"
Local Const $e0[1][2] = [[$dj, $e3]]
_vv($cb, $e0)
EndFunc
_125()
Func _126()
Local Const $dj = "systemlook"
Dim $c5
Dim $c6
Dim $c8
Local Const $cr = Null
Local Const $dm = "(?i)^SystemLook.*\.exe$"
Local Const $dn = "(?i)^SystemLook.*\.(exe|txt)$"
Local Const $dq[1][2] = [[$dj, $dm]]
Local Const $dr[1][5] = [[$dj, 'file', $cr, $dn, False]]
_vv($c5, $dq)
_vv($c6, $dr)
_vv($c8, $dr)
EndFunc
_126()
Func _127($bl = False)
If $bl = True Then
_zm(@CRLF & "- Search Tools -" & @CRLF)
EndIf
_10p($c5)
_105()
_10r($cj)
_105()
_10q($cc)
_105()
_10l(@DesktopDir, $c6)
_105()
_10m(@DesktopCommonDir, $c7)
_105()
If FileExists(@UserProfileDir & "\Downloads") Then
_10l(@UserProfileDir & "\Downloads", $c8)
_105()
Else
_105()
EndIf
_10s($c9)
_105()
_10m(@HomeDrive, $ca)
_105()
_10m(@AppDataDir, $cf)
_105()
_10m(@AppDataCommonDir, $ce)
_105()
_10m(@LocalAppDataDir, $cg)
_105()
_10m(@WindowsDir, $ci)
_105()
_10t($cb)
_105()
_10v($ck)
_105()
_10u($cd)
_105()
_10m(@AppDataCommonDir & "\Microsoft\Windows\Start Menu\Programs", $ch)
_105()
_10w($cl)
_105()
If $bl = True Then
Local $e9 = False
Local Const $ea[4] = ["process", "uninstall", "element", "key"]
Local Const $eb = "Warning, folder " & @AppDataDir & "\ZHP exists and contains the quarantines of the ZHP tools. At the request of the publisher (Nicolas Coolman) this folder is not deleted. "
Local $ec = False
Local Const $ed = _zu(@AppDataDir & "\ZHP")
For $ee In $az
Local $ef = $az.Item($ee)
Local $eg = False
For $eh = 0 To UBound($ea) - 1
Local $ei = $ea[$eh]
Local $ej = $ef.Item($ei)
Local $ek = $ej.Keys
If UBound($ek) > 0 Then
If $eg = False Then
$eg = True
$e9 = True
_zm(@CRLF & "  ## " & StringUpper($ee) & " found")
EndIf
For $el = 0 To UBound($ek) - 1
Local $em = $ek[$el]
Local $en = $ej.Item($em)
_104($ei, $em, $en)
Next
If $ee = "zhp" And $ed = True Then
_zm("     [!] " & $eb)
$ec = True
EndIf
EndIf
Next
Next
If $ec = False And $ed = True Then
_zm(@CRLF & "  ## " & StringUpper("zhp") & " found")
_zm("     [!] " & $eb)
ElseIf $e9 = False Then
_zm("  [I] No tools found")
EndIf
EndIf
_105()
EndFunc
FileInstall("C:\Users\IEUser\Desktop\kpRemover\src\assets\bug.gif", @TempDir & "\kprm-logo.gif")
Global $br = "KpRm"
Global $co = False
Global $a8 = "kprm-" & @YEAR & @MON & @MDAY & @HOUR & @MIN & ".txt"
Local Const $eo = GUICreate($br, 500, 195, 202, 112)
Local Const $ep = GUICtrlCreateGroup("Actions", 8, 8, 400, 153)
Local Const $eq = GUICtrlCreateCheckbox($7a, 16, 40, 129, 17)
Local Const $er = GUICtrlCreateCheckbox($7b, 16, 80, 190, 17)
Local Const $es = GUICtrlCreateCheckbox($7c, 16, 120, 190, 17)
Local Const $et = GUICtrlCreateCheckbox($7d, 220, 40, 137, 17)
Local Const $eu = GUICtrlCreateCheckbox($7e, 220, 80, 137, 17)
Local Const $ev = GUICtrlCreateCheckbox($7f, 220, 120, 180, 17)
Global $be = GUICtrlCreateProgress(8, 170, 480, 17)
GUICtrlCreateGroup("", -99, -99, 1, 1)
GUICtrlSetState($eq, 1)
Local Const $ew = GUICtrlCreatePic(@TempDir & "\kprm-logo.gif", 415, 16, 76, 76)
Local Const $ex = GUICtrlCreateButton($7g, 415, 120, 75, 40)
GUISetState(@SW_SHOW)
While 1
Local $ey = GUIGetMsg()
Switch $ey
Case $0
Exit
Case $ex
_12a()
EndSwitch
WEnd
Func _128()
Local Const $ez = @HomeDrive & "\KPRM"
If Not FileExists($ez) Then
DirCreate($ez)
EndIf
If Not FileExists($ez) Then
MsgBox(16, $7i, $7j)
Exit
EndIf
EndFunc
Func _129()
_128()
_zm("#################################################################################################################" & @CRLF)
_zm("# Run at " & _3o())
_zm("# KpRm (Kernel-panik) version " & $78)
_zm("# Website https://kernel-panik.me/tool/kprm/")
_zm("# Run by " & @UserName & " from " & @WorkingDir)
_zm("# Computer Name: " & @ComputerName)
_zm("# OS: " & _zw() & " " & @OSArch & " (" & @OSBuild & ") " & @OSServicePack)
_106()
EndFunc
Func _12a()
_129()
_105()
If GUICtrlRead($et) = $1 Then
_10d()
EndIf
_105()
If GUICtrlRead($eq) = $1 Then
_127()
_127(True)
Else
_105(32)
EndIf
_105()
If GUICtrlRead($ev) = $1 Then
_10f()
EndIf
_105()
If GUICtrlRead($eu) = $1 Then
_10e()
EndIf
_105()
If GUICtrlRead($er) = $1 Then
_107()
EndIf
_105()
If GUICtrlRead($es) = $1 Then
_10c()
EndIf
GUICtrlSetData($be, 100)
MsgBox(64, "OK", $7h)
_zi(True)
EndFunc
