#RequireAdmin
Global Const $0 = -3
Global Const $1 = 1
Global Const $2 = 0x00040000
Global Const $3 = 1
Global Const $4 = 2
Global Enum $5 = 0, $6, $7, $8, $9, $a, $b
Global Const $c = 1
Global Const $d = 2
Global Const $e = 1
Global Const $f = 2
Global Const $g = "struct;word Year;word Month;word Dow;word Day;word Hour;word Minute;word Second;word MSeconds;endstruct"
Global Const $h = 0
Global Const $i = 1
Global Const $j = 2
Global Const $k= 1
Global Const $l = 0x10000000
Global Const $m = 0
Global Const $n = 'struct;dword OSVersionInfoSize;dword MajorVersion;dword MinorVersion;dword BuildNumber;dword PlatformId;wchar CSDVersion[128];endstruct'
Global Const $o = _1v()
Func _1v()
Local $p = DllStructCreate($n)
DllStructSetData($p, 1, DllStructGetSize($p))
Local $q = DllCall('kernel32.dll', 'bool', 'GetVersionExW', 'struct*', $p)
If @error Or Not $q[0] Then Return SetError(@error, @extended, 0)
Return BitOR(BitShift(DllStructGetData($p, 2), -8), DllStructGetData($p, 3))
EndFunc
Global Const $r = 0x001D
Global Const $s = 0x001E
Global Const $t = 0x001F
Global Const $u = 0x0020
Global Const $v = 0x1003
Global Const $w = 0x0028
Global Const $x = 0x0029
Global Const $y = 0x007F
Global Const $0z = 0x0400
Func _2e($10 = 0, $11 = 0, $12 = 0, $13 = '')
If Not $10 Then $10 = 0x0400
Local $14 = 'wstr'
If Not StringStripWS($13, $c + $d) Then
$14 = 'ptr'
$13 = 0
EndIf
Local $q = DllCall('kernel32.dll', 'int', 'GetDateFormatW', 'dword', $10, 'dword', $12, 'struct*', $11, $14, $13, 'wstr', '', 'int', 2048)
If @error Or Not $q[0] Then Return SetError(@error, @extended, '')
Return $q[5]
EndFunc
Func _2h($10, $15)
Local $q = DllCall('kernel32.dll', 'int', 'GetLocaleInfoW', 'dword', $10, 'dword', $15, 'wstr', '', 'int', 2048)
If @error Or Not $q[0] Then Return SetError(@error + 10, @extended, '')
Return $q[3]
EndFunc
Func _31($16, $17, $18)
Local $19[4]
Local $1a[4]
Local $1b
$16 = StringLeft($16, 1)
If StringInStr("D,M,Y,w,h,n,s", $16) = 0 Or $16 = "" Then
Return SetError(1, 0, 0)
EndIf
If Not StringIsInt($17) Then
Return SetError(2, 0, 0)
EndIf
If Not _37($18) Then
Return SetError(3, 0, 0)
EndIf
_3g($18, $1a, $19)
If $16 = "d" Or $16 = "w" Then
If $16 = "w" Then $17 = $17 * 7
$1b = _3j($1a[1], $1a[2], $1a[3]) + $17
_3l($1b, $1a[1], $1a[2], $1a[3])
EndIf
If $16 = "m" Then
$1a[2] = $1a[2] + $17
While $1a[2] > 12
$1a[2] = $1a[2] - 12
$1a[1] = $1a[1] + 1
WEnd
While $1a[2] < 1
$1a[2] = $1a[2] + 12
$1a[1] = $1a[1] - 1
WEnd
EndIf
If $16 = "y" Then
$1a[1] = $1a[1] + $17
EndIf
If $16 = "h" Or $16 = "n" Or $16 = "s" Then
Local $1c = _3w($19[1], $19[2], $19[3]) / 1000
If $16 = "h" Then $1c = $1c + $17 * 3600
If $16 = "n" Then $1c = $1c + $17 * 60
If $16 = "s" Then $1c = $1c + $17
Local $1d = Int($1c /(24 * 60 * 60))
$1c = $1c - $1d * 24 * 60 * 60
If $1c < 0 Then
$1d = $1d - 1
$1c = $1c + 24 * 60 * 60
EndIf
$1b = _3j($1a[1], $1a[2], $1a[3]) + $1d
_3l($1b, $1a[1], $1a[2], $1a[3])
_3v($1c * 1000, $19[1], $19[2], $19[3])
EndIf
Local $1e = _3z($1a[1])
If $1e[$1a[2]] < $1a[3] Then $1a[3] = $1e[$1a[2]]
$18 = $1a[1] & '/' & StringRight("0" & $1a[2], 2) & '/' & StringRight("0" & $1a[3], 2)
If $19[0] > 0 Then
If $19[0] > 2 Then
$18 = $18 & " " & StringRight("0" & $19[1], 2) & ':' & StringRight("0" & $19[2], 2) & ':' & StringRight("0" & $19[3], 2)
Else
$18 = $18 & " " & StringRight("0" & $19[1], 2) & ':' & StringRight("0" & $19[2], 2)
EndIf
EndIf
Return $18
EndFunc
Func _32($1f, $1g = Default)
Local Const $1h = 128
If $1g = Default Then $1g = 0
$1f = Int($1f)
If $1f < 1 Or $1f > 7 Then Return SetError(1, 0, "")
Local $11 = DllStructCreate($g)
DllStructSetData($11, "Year", BitAND($1g, $1h) ? 2007 : 2006)
DllStructSetData($11, "Month", 1)
DllStructSetData($11, "Day", $1f)
Return _2e(BitAND($1g, $4) ? $0z : $y, $11, 0, BitAND($1g, $3) ? "ddd" : "dddd")
EndFunc
Func _35($1i)
If StringIsInt($1i) Then
Select
Case Mod($1i, 4) = 0 And Mod($1i, 100) <> 0
Return 1
Case Mod($1i, 400) = 0
Return 1
Case Else
Return 0
EndSelect
EndIf
Return SetError(1, 0, 0)
EndFunc
Func _36($17)
$17 = Int($17)
Return $17 >= 1 And $17 <= 12
EndFunc
Func _37($18)
Local $1a[4], $19[4]
_3g($18, $1a, $19)
If Not StringIsInt($1a[1]) Then Return 0
If Not StringIsInt($1a[2]) Then Return 0
If Not StringIsInt($1a[3]) Then Return 0
$1a[1] = Int($1a[1])
$1a[2] = Int($1a[2])
$1a[3] = Int($1a[3])
Local $1e = _3z($1a[1])
If $1a[1] < 1000 Or $1a[1] > 2999 Then Return 0
If $1a[2] < 1 Or $1a[2] > 12 Then Return 0
If $1a[3] < 1 Or $1a[3] > $1e[$1a[2]] Then Return 0
If $19[0] < 1 Then Return 1
If $19[0] < 2 Then Return 0
If $19[0] = 2 Then $19[3] = "00"
If Not StringIsInt($19[1]) Then Return 0
If Not StringIsInt($19[2]) Then Return 0
If Not StringIsInt($19[3]) Then Return 0
$19[1] = Int($19[1])
$19[2] = Int($19[2])
$19[3] = Int($19[3])
If $19[1] < 0 Or $19[1] > 23 Then Return 0
If $19[2] < 0 Or $19[2] > 59 Then Return 0
If $19[3] < 0 Or $19[3] > 59 Then Return 0
Return 1
EndFunc
Func _3f($18, $16)
Local $1a[4], $19[4]
Local $1j = "", $1k = ""
Local $1l, $1m, $1n = ""
If Not _37($18) Then
Return SetError(1, 0, "")
EndIf
If $16 < 0 Or $16 > 5 Or Not IsInt($16) Then
Return SetError(2, 0, "")
EndIf
_3g($18, $1a, $19)
Switch $16
Case 0
$1n = _2h($0z, $t)
If Not @error And Not($1n = '') Then
$1j = $1n
Else
$1j = "M/d/yyyy"
EndIf
If $19[0] > 1 Then
$1n = _2h($0z, $v)
If Not @error And Not($1n = '') Then
$1k = $1n
Else
$1k = "h:mm:ss tt"
EndIf
EndIf
Case 1
$1n = _2h($0z, $u)
If Not @error And Not($1n = '') Then
$1j = $1n
Else
$1j = "dddd, MMMM dd, yyyy"
EndIf
Case 2
$1n = _2h($0z, $t)
If Not @error And Not($1n = '') Then
$1j = $1n
Else
$1j = "M/d/yyyy"
EndIf
Case 3
If $19[0] > 1 Then
$1n = _2h($0z, $v)
If Not @error And Not($1n = '') Then
$1k = $1n
Else
$1k = "h:mm:ss tt"
EndIf
EndIf
Case 4
If $19[0] > 1 Then
$1k = "hh:mm"
EndIf
Case 5
If $19[0] > 1 Then
$1k = "hh:mm:ss"
EndIf
EndSwitch
If $1j <> "" Then
$1n = _2h($0z, $r)
If Not @error And Not($1n = '') Then
$1j = StringReplace($1j, "/", $1n)
EndIf
Local $1o = _3h($1a[1], $1a[2], $1a[3])
$1a[3] = StringRight("0" & $1a[3], 2)
$1a[2] = StringRight("0" & $1a[2], 2)
$1j = StringReplace($1j, "d", "@")
$1j = StringReplace($1j, "m", "#")
$1j = StringReplace($1j, "y", "&")
$1j = StringReplace($1j, "@@@@", _32($1o, 0))
$1j = StringReplace($1j, "@@@", _32($1o, 1))
$1j = StringReplace($1j, "@@", $1a[3])
$1j = StringReplace($1j, "@", StringReplace(StringLeft($1a[3], 1), "0", "") & StringRight($1a[3], 1))
$1j = StringReplace($1j, "####", _3k($1a[2], 0))
$1j = StringReplace($1j, "###", _3k($1a[2], 1))
$1j = StringReplace($1j, "##", $1a[2])
$1j = StringReplace($1j, "#", StringReplace(StringLeft($1a[2], 1), "0", "") & StringRight($1a[2], 1))
$1j = StringReplace($1j, "&&&&", $1a[1])
$1j = StringReplace($1j, "&&", StringRight($1a[1], 2))
EndIf
If $1k <> "" Then
$1n = _2h($0z, $w)
If Not @error And Not($1n = '') Then
$1l = $1n
Else
$1l = "AM"
EndIf
$1n = _2h($0z, $x)
If Not @error And Not($1n = '') Then
$1m = $1n
Else
$1m = "PM"
EndIf
$1n = _2h($0z, $s)
If Not @error And Not($1n = '') Then
$1k = StringReplace($1k, ":", $1n)
EndIf
If StringInStr($1k, "tt") Then
If $19[1] < 12 Then
$1k = StringReplace($1k, "tt", $1l)
If $19[1] = 0 Then $19[1] = 12
Else
$1k = StringReplace($1k, "tt", $1m)
If $19[1] > 12 Then $19[1] = $19[1] - 12
EndIf
EndIf
$19[1] = StringRight("0" & $19[1], 2)
$19[2] = StringRight("0" & $19[2], 2)
$19[3] = StringRight("0" & $19[3], 2)
$1k = StringReplace($1k, "hh", StringFormat("%02d", $19[1]))
$1k = StringReplace($1k, "h", StringReplace(StringLeft($19[1], 1), "0", "") & StringRight($19[1], 1))
$1k = StringReplace($1k, "mm", StringFormat("%02d", $19[2]))
$1k = StringReplace($1k, "ss", StringFormat("%02d", $19[3]))
$1j = StringStripWS($1j & " " & $1k, $c + $d)
EndIf
Return $1j
EndFunc
Func _3g($18, ByRef $1p, ByRef $1q)
Local $1r = StringSplit($18, " T")
If $1r[0] > 0 Then $1p = StringSplit($1r[1], "/-.")
If $1r[0] > 1 Then
$1q = StringSplit($1r[2], ":")
If UBound($1q) < 4 Then ReDim $1q[4]
Else
Dim $1q[4]
EndIf
If UBound($1p) < 4 Then ReDim $1p[4]
For $1s = 1 To 3
If StringIsInt($1p[$1s]) Then
$1p[$1s] = Int($1p[$1s])
Else
$1p[$1s] = -1
EndIf
If StringIsInt($1q[$1s]) Then
$1q[$1s] = Int($1q[$1s])
Else
$1q[$1s] = 0
EndIf
Next
Return 1
EndFunc
Func _3h($1i, $1t, $1u)
If Not _37($1i & "/" & $1t & "/" & $1u) Then
Return SetError(1, 0, "")
EndIf
Local $1v = Int((14 - $1t) / 12)
Local $1w = $1i - $1v
Local $1x = $1t +(12 * $1v) - 2
Local $1y = Mod($1u + $1w + Int($1w / 4) - Int($1w / 100) + Int($1w / 400) + Int((31 * $1x) / 12), 7)
Return $1y + 1
EndFunc
Func _3j($1i, $1t, $1u)
If Not _37(StringFormat("%04d/%02d/%02d", $1i, $1t, $1u)) Then
Return SetError(1, 0, "")
EndIf
If $1t < 3 Then
$1t = $1t + 12
$1i = $1i - 1
EndIf
Local $1v = Int($1i / 100)
Local $1z = Int($1v / 4)
Local $20 = 2 - $1v + $1z
Local $21 = Int(1461 *($1i + 4716) / 4)
Local $22 = Int(153 *($1t + 1) / 5)
Local $1b = $20 + $1u + $21 + $22 - 1524.5
Return $1b
EndFunc
Func _3k($23, $1g = Default)
If $1g = Default Then $1g = 0
$23 = Int($23)
If Not _36($23) Then Return SetError(1, 0, "")
Local $11 = DllStructCreate($g)
DllStructSetData($11, "Year", @YEAR)
DllStructSetData($11, "Month", $23)
DllStructSetData($11, "Day", 1)
Return _2e(BitAND($1g, $4) ? $0z : $y, $11, 0, BitAND($1g, $3) ? "MMM" : "MMMM")
EndFunc
Func _3l($1b, ByRef $1i, ByRef $1t, ByRef $1u)
If $1b < 0 Or Not IsNumber($1b) Then
Return SetError(1, 0, 0)
EndIf
Local $24 = Int($1b + 0.5)
Local $25 = Int(($24 - 1867216.25) / 36524.25)
Local $26 = Int($25 / 4)
Local $1v = $24 + 1 + $25 - $26
Local $1z = $1v + 1524
Local $20 = Int(($1z - 122.1) / 365.25)
Local $1y = Int(365.25 * $20)
Local $21 = Int(($1z - $1y) / 30.6001)
Local $22 = Int(30.6001 * $21)
$1u = $1z - $1y - $22
If $21 - 1 < 13 Then
$1t = $21 - 1
Else
$1t = $21 - 13
EndIf
If $1t < 3 Then
$1i = $20 - 4715
Else
$1i = $20 - 4716
EndIf
$1i = StringFormat("%04d", $1i)
$1t = StringFormat("%02d", $1t)
$1u = StringFormat("%02d", $1u)
Return $1i & "/" & $1t & "/" & $1u
EndFunc
Func _3o()
Return _3f(@YEAR & "/" & @MON & "/" & @MDAY & " " & @HOUR & ":" & @MIN & ":" & @SEC, 0)
EndFunc
Func _3p()
Return @YEAR & "/" & @MON & "/" & @MDAY & " " & @HOUR & ":" & @MIN & ":" & @SEC
EndFunc
Func _3q()
Return @YEAR & "/" & @MON & "/" & @MDAY
EndFunc
Func _3v($27, ByRef $28, ByRef $29, ByRef $2a)
If Number($27) > 0 Then
$27 = Int($27 / 1000)
$28 = Int($27 / 3600)
$27 = Mod($27, 3600)
$29 = Int($27 / 60)
$2a = Mod($27, 60)
Return 1
ElseIf Number($27) = 0 Then
$28 = 0
$27 = 0
$29 = 0
$2a = 0
Return 1
Else
Return SetError(1, 0, 0)
EndIf
EndFunc
Func _3w($28 = @HOUR, $29 = @MIN, $2a = @SEC)
If StringIsInt($28) And StringIsInt($29) And StringIsInt($2a) Then
Local $27 = 1000 *((3600 * $28) +(60 * $29) + $2a)
Return $27
Else
Return SetError(1, 0, 0)
EndIf
EndFunc
Func _3z($1i)
Local $2b = [12, 31,(_35($1i) ? 29 : 28), 31, 30, 31, 30, 31, 31, 30, 31, 30, 31]
Return $2b
EndFunc
Func _51($2c, $2d, $2e = 0, $2f = 0, $2g = 0, $2h = "wparam", $2i = "lparam", $2j = "lresult")
Local $2k = DllCall("user32.dll", $2j, "SendMessageW", "hwnd", $2c, "uint", $2d, $2h, $2e, $2i, $2f)
If @error Then Return SetError(@error, @extended, "")
If $2g >= 0 And $2g <= 4 Then Return $2k[$2g]
Return $2k
EndFunc
Global Const $2l = Ptr(-1)
Global Const $2m = Ptr(-1)
Global Const $2n = 0x0100
Global Const $2o = 0x2000
Global Const $2p = 0x8000
Global Const $2q = BitShift($2n, 8)
Global Const $2r = BitShift($2o, 8)
Global Const $2s = BitShift($2p, 8)
Global Const $2t = 0x8000000
Func _d0($2u, $2v)
Local $2k = DllCall("user32.dll", "hwnd", "FindWindowW", "wstr", $2u, "wstr", $2v)
If @error Then Return SetError(@error, @extended, 0)
Return $2k[0]
EndFunc
Func _hf($2w, $12, $2x = 0, $2y = 0)
Local $2z = 'dword_ptr', $30 = 'dword_ptr'
If IsString($2x) Then
$2z = 'wstr'
EndIf
If IsString($2y) Then
$30 = 'wstr'
EndIf
DllCall('shell32.dll', 'none', 'SHChangeNotify', 'long', $2w, 'uint', $12, $2z, $2x, $30, $2y)
If @error Then Return SetError(@error, @extended, 0)
Return 1
EndFunc
Global Const $31 = 11
Global $32[$31]
Global Const $33 = "struct;uint Mask;int Item;int SubItem;uint State;uint StateMask;ptr Text;int TextMax;int Image;lparam Param;" & "int Indent;int GroupID;uint Columns;ptr pColumns;ptr piColFmt;int iGroup;endstruct"
#Au3Stripper_Ignore_Funcs=__ArrayDisplay_SortCallBack
Func __ArrayDisplay_SortCallBack($34, $35, $2c)
If $32[3] = $32[4] Then
If Not $32[7] Then
$32[5] *= -1
$32[7] = 1
EndIf
Else
$32[7] = 1
EndIf
$32[6] = $32[3]
Local $36 = _vr($2c, $34, $32[3])
Local $37 = _vr($2c, $35, $32[3])
If $32[8] = 1 Then
If(StringIsFloat($36) Or StringIsInt($36)) Then $36 = Number($36)
If(StringIsFloat($37) Or StringIsInt($37)) Then $37 = Number($37)
EndIf
Local $38
If $32[8] < 2 Then
$38 = 0
If $36 < $37 Then
$38 = -1
ElseIf $36 > $37 Then
$38 = 1
EndIf
Else
$38 = DllCall('shlwapi.dll', 'int', 'StrCmpLogicalW', 'wstr', $36, 'wstr', $37)[0]
EndIf
$38 = $38 * $32[5]
Return $38
EndFunc
Func _vr($2c, $39, $3a = 0)
Local $3b = DllStructCreate("wchar Text[4096]")
Local $3c = DllStructGetPtr($3b)
Local $3d = DllStructCreate($33)
DllStructSetData($3d, "SubItem", $3a)
DllStructSetData($3d, "TextMax", 4096)
DllStructSetData($3d, "Text", $3c)
If IsHWnd($2c) Then
DllCall("user32.dll", "lresult", "SendMessageW", "hwnd", $2c, "uint", 0x1073, "wparam", $39, "struct*", $3d)
Else
Local $3e = DllStructGetPtr($3d)
GUICtrlSendMsg($2c, 0x1073, $39, $3e)
EndIf
Return DllStructGetData($3b, "Text")
EndFunc
Global Enum $3f, $3g, $3h, $3i, $3j, $3k, $3l, $3m
Func _vv(ByRef $3n, $3o, $3p = 0, $3q = "|", $3r = @CRLF, $3s = $3f)
If $3p = Default Then $3p = 0
If $3q = Default Then $3q = "|"
If $3r = Default Then $3r = @CRLF
If $3s = Default Then $3s = $3f
If Not IsArray($3n) Then Return SetError(1, 0, -1)
Local $3t = UBound($3n, $i)
Local $3u = 0
Switch $3s
Case $3h
$3u = Int
Case $3i
$3u = Number
Case $3j
$3u = Ptr
Case $3k
$3u = Hwnd
Case $3l
$3u = String
Case $3m
$3u = "Boolean"
EndSwitch
Switch UBound($3n, $h)
Case 1
If $3s = $3g Then
ReDim $3n[$3t + 1]
$3n[$3t] = $3o
Return $3t
EndIf
If IsArray($3o) Then
If UBound($3o, $h) <> 1 Then Return SetError(5, 0, -1)
$3u = 0
Else
Local $3v = StringSplit($3o, $3q, $f + $e)
If UBound($3v, $i) = 1 Then
$3v[0] = $3o
EndIf
$3o = $3v
EndIf
Local $3w = UBound($3o, $i)
ReDim $3n[$3t + $3w]
For $3x = 0 To $3w - 1
If String($3u) = "Boolean" Then
Switch $3o[$3x]
Case "True", "1"
$3n[$3t + $3x] = True
Case "False", "0", ""
$3n[$3t + $3x] = False
EndSwitch
ElseIf IsFunc($3u) Then
$3n[$3t + $3x] = $3u($3o[$3x])
Else
$3n[$3t + $3x] = $3o[$3x]
EndIf
Next
Return $3t + $3w - 1
Case 2
Local $3y = UBound($3n, $j)
If $3p < 0 Or $3p > $3y - 1 Then Return SetError(4, 0, -1)
Local $3z, $40 = 0, $41
If IsArray($3o) Then
If UBound($3o, $h) <> 2 Then Return SetError(5, 0, -1)
$3z = UBound($3o, $i)
$40 = UBound($3o, $j)
$3u = 0
Else
Local $42 = StringSplit($3o, $3r, $f + $e)
$3z = UBound($42, $i)
Local $3v[$3z][0], $43
For $3x = 0 To $3z - 1
$43 = StringSplit($42[$3x], $3q, $f + $e)
$41 = UBound($43)
If $41 > $40 Then
$40 = $41
ReDim $3v[$3z][$40]
EndIf
For $44 = 0 To $41 - 1
$3v[$3x][$44] = $43[$44]
Next
Next
$3o = $3v
EndIf
If UBound($3o, $j) + $3p > UBound($3n, $j) Then Return SetError(3, 0, -1)
ReDim $3n[$3t + $3z][$3y]
For $45 = 0 To $3z - 1
For $44 = 0 To $3y - 1
If $44 < $3p Then
$3n[$45 + $3t][$44] = ""
ElseIf $44 - $3p > $40 - 1 Then
$3n[$45 + $3t][$44] = ""
Else
If String($3u) = "Boolean" Then
Switch $3o[$45][$44 - $3p]
Case "True", "1"
$3n[$45 + $3t][$44] = True
Case "False", "0", ""
$3n[$45 + $3t][$44] = False
EndSwitch
ElseIf IsFunc($3u) Then
$3n[$45 + $3t][$44] = $3u($3o[$45][$44 - $3p])
Else
$3n[$45 + $3t][$44] = $3o[$45][$44 - $3p]
EndIf
EndIf
Next
Next
Case Else
Return SetError(2, 0, -1)
EndSwitch
Return UBound($3n, $i) - 1
EndFunc
Func _we(Const ByRef $3n, $3o, $3p = 0, $46 = 0, $47 = 0, $48 = 0, $49 = 1, $3a = -1, $4a = False)
If $3p = Default Then $3p = 0
If $46 = Default Then $46 = 0
If $47 = Default Then $47 = 0
If $48 = Default Then $48 = 0
If $49 = Default Then $49 = 1
If $3a = Default Then $3a = -1
If $4a = Default Then $4a = False
If Not IsArray($3n) Then Return SetError(1, 0, -1)
Local $3t = UBound($3n) - 1
If $3t = -1 Then Return SetError(3, 0, -1)
Local $3y = UBound($3n, $j) - 1
Local $4b = False
If $48 = 2 Then
$48 = 0
$4b = True
EndIf
If $4a Then
If UBound($3n, $h) = 1 Then Return SetError(5, 0, -1)
If $46 < 1 Or $46 > $3y Then $46 = $3y
If $3p < 0 Then $3p = 0
If $3p > $46 Then Return SetError(4, 0, -1)
Else
If $46 < 1 Or $46 > $3t Then $46 = $3t
If $3p < 0 Then $3p = 0
If $3p > $46 Then Return SetError(4, 0, -1)
EndIf
Local $4c = 1
If Not $49 Then
Local $4d = $3p
$3p = $46
$46 = $4d
$4c = -1
EndIf
Switch UBound($3n, $h)
Case 1
If Not $48 Then
If Not $47 Then
For $3x = $3p To $46 Step $4c
If $4b And VarGetType($3n[$3x]) <> VarGetType($3o) Then ContinueLoop
If $3n[$3x] = $3o Then Return $3x
Next
Else
For $3x = $3p To $46 Step $4c
If $4b And VarGetType($3n[$3x]) <> VarGetType($3o) Then ContinueLoop
If $3n[$3x] == $3o Then Return $3x
Next
EndIf
Else
For $3x = $3p To $46 Step $4c
If $48 = 3 Then
If StringRegExp($3n[$3x], $3o) Then Return $3x
Else
If StringInStr($3n[$3x], $3o, $47) > 0 Then Return $3x
EndIf
Next
EndIf
Case 2
Local $4e
If $4a Then
$4e = $3t
If $3a > $4e Then $3a = $4e
If $3a < 0 Then
$3a = 0
Else
$4e = $3a
EndIf
Else
$4e = $3y
If $3a > $4e Then $3a = $4e
If $3a < 0 Then
$3a = 0
Else
$4e = $3a
EndIf
EndIf
For $44 = $3a To $4e
If Not $48 Then
If Not $47 Then
For $3x = $3p To $46 Step $4c
If $4a Then
If $4b And VarGetType($3n[$44][$3x]) <> VarGetType($3o) Then ContinueLoop
If $3n[$44][$3x] = $3o Then Return $3x
Else
If $4b And VarGetType($3n[$3x][$44]) <> VarGetType($3o) Then ContinueLoop
If $3n[$3x][$44] = $3o Then Return $3x
EndIf
Next
Else
For $3x = $3p To $46 Step $4c
If $4a Then
If $4b And VarGetType($3n[$44][$3x]) <> VarGetType($3o) Then ContinueLoop
If $3n[$44][$3x] == $3o Then Return $3x
Else
If $4b And VarGetType($3n[$3x][$44]) <> VarGetType($3o) Then ContinueLoop
If $3n[$3x][$44] == $3o Then Return $3x
EndIf
Next
EndIf
Else
For $3x = $3p To $46 Step $4c
If $48 = 3 Then
If $4a Then
If StringRegExp($3n[$44][$3x], $3o) Then Return $3x
Else
If StringRegExp($3n[$3x][$44], $3o) Then Return $3x
EndIf
Else
If $4a Then
If StringInStr($3n[$44][$3x], $3o, $47) > 0 Then Return $3x
Else
If StringInStr($3n[$3x][$44], $3o, $47) > 0 Then Return $3x
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
Func _x1($4f, $4g = "*", $4h = $m, $4i = False)
Local $4j = "|", $4k = "", $4l = "", $4m = ""
$4f = StringRegExpReplace($4f, "[\\/]+$", "") & "\"
If $4h = Default Then $4h = $m
If $4i Then $4m = $4f
If $4g = Default Then $4g = "*"
If Not FileExists($4f) Then Return SetError(1, 0, 0)
If StringRegExp($4g, "[\\/:><\|]|(?s)^\s*$") Then Return SetError(2, 0, 0)
If Not($4h = 0 Or $4h = 1 Or $4h = 2) Then Return SetError(3, 0, 0)
Local $4n = FileFindFirstFile($4f & $4g)
If @error Then Return SetError(4, 0, 0)
While 1
$4l = FileFindNextFile($4n)
If @error Then ExitLoop
If($4h + @extended = 2) Then ContinueLoop
$4k &= $4j & $4m & $4l
WEnd
FileClose($4n)
If $4k = "" Then Return SetError(4, 0, 0)
Return StringSplit(StringTrimLeft($4k, 1), $4j)
EndFunc
Local Const $4o[6] = ["040C", "080C", "0C0C", "100C", "140C", "180C"]
If _we($4o, @MUILang) <> 1 Then
Global $4p = "Supprimer des outils"
Global $4q = "Supprimer les points de restaurations"
Global $4r = "Créer un point de restauration"
Global $4s = "Sauvegarder le registre"
Global $4t = "Restaurer UAC"
Global $4u = "Restaurer les paramètres système"
Global $4v = "Exécuter"
Global $4w = "Toutes les opérations sont terminées"
Global $4x = "Echec"
Global $4y = "Impossible de créer une sauvegarde du registre"
Global $4z = "Vous devez exécuter le programme avec les droits administrateurs"
Global $50 = "Vous devez fermer MalwareBytes Anti-Rootkit avant de continuer"
Else
Global $4p = "Delete Tools"
Global $4q = "Delete Restore Points"
Global $4r = "Create Restore Point"
Global $4s = "Registry Backup"
Global $4t = "UAC Restore"
Global $4u = "Restore System Settings"
Global $4v = "Run"
Global $4w = "All operations are completed"
Global $4x = "Fail"
Global $4y = "Unable to create a registry backup"
Global $4z = "You must run the program with administrator rights"
Global $50 = "You must close MalwareBytes Anti-Rootkit before continuing"
EndIf
Global Const $51 = 1
Global Const $52 = 5
Global Const $53 = 0
Global Const $54 = 1
Func _xr($55 = $52)
If Not IsAdmin() Then Return SetError(-3, 0, -1)
If StringRegExp(@OSVersion, "_(XP|200(0|3))") Then Return SetError(-4, 0, -1)
Local $56 = ""
If @OSArch = "X64" Then $56 = "64"
If $55 < 0 Or $55 > 5 Then Return SetError(-5, 0, -1)
Local $2g = RegWrite("HKEY_LOCAL_MACHINE" & $56 & "\Software\Microsoft\Windows\CurrentVersion\Policies\System", "ConsentPromptBehaviorAdmin", "REG_DWORD", $55)
If $2g = 0 Then $2g = -1
Return SetError(@error, 0, $2g)
EndFunc
Func _xs($55 = $51)
If Not IsAdmin() Then Return SetError(-3, 0, -1)
If StringRegExp(@OSVersion, "_(XP|200(0|3))") Then Return SetError(-4, 0, -1)
If $55 < 0 Or $55 = 2 Or $55 > 3 Then Return SetError(-5, 0, -1)
Local $56 = ""
If @OSArch = "X64" Then $56 = "64"
Local $2g = RegWrite("HKEY_LOCAL_MACHINE" & $56 & "\Software\Microsoft\Windows\CurrentVersion\Policies\System", "ConsentPromptBehaviorUser", "REG_DWORD", $55)
If $2g = 0 Then $2g = -1
Return SetError(@error, 0, $2g)
EndFunc
Func _xt($55 = $53)
If Not IsAdmin() Then Return SetError(-3, 0, -1)
If StringRegExp(@OSVersion, "_(XP|200(0|3))") Then Return SetError(-4, 0, -1)
If $55 < 0 Or $55 > 1 Then Return SetError(-5, 0, -1)
Local $56 = ""
If @OSArch = "X64" Then $56 = "64"
Local $2g = RegWrite("HKEY_LOCAL_MACHINE" & $56 & "\Software\Microsoft\Windows\CurrentVersion\Policies\System", "EnableInstallerDetection", "REG_DWORD", $55)
If $2g = 0 Then $2g = -1
Return SetError(@error, 0, $2g)
EndFunc
Func _xu($55 = $54)
If Not IsAdmin() Then Return SetError(-3, 0, -1)
If StringRegExp(@OSVersion, "_(XP|200(0|3))") Then Return SetError(-4, 0, -1)
If $55 < 0 Or $55 > 1 Then Return SetError(-5, 0, -1)
Local $56 = ""
If @OSArch = "X64" Then $56 = "64"
Local $2g = RegWrite("HKEY_LOCAL_MACHINE" & $56 & "\Software\Microsoft\Windows\CurrentVersion\Policies\System", "EnableLUA", "REG_DWORD", $55)
If $2g = 0 Then $2g = -1
Return SetError(@error, 0, $2g)
EndFunc
Func _xv($55 = $54)
If Not IsAdmin() Then Return SetError(-3, 0, -1)
If StringRegExp(@OSVersion, "_(XP|200(0|3))") Then Return SetError(-4, 0, -1)
If $55 < 0 Or $55 > 1 Then Return SetError(-5, 0, -1)
Local $56 = ""
If @OSArch = "X64" Then $56 = "64"
Local $2g = RegWrite("HKEY_LOCAL_MACHINE" & $56 & "\Software\Microsoft\Windows\CurrentVersion\Policies\System", "EnableSecureUIAPaths", "REG_DWORD", $55)
If $2g = 0 Then $2g = -1
Return SetError(@error, 0, $2g)
EndFunc
Func _xw($55 = $53)
If Not IsAdmin() Then Return SetError(-3, 0, -1)
If StringRegExp(@OSVersion, "_(XP|200(0|3))") Then Return SetError(-4, 0, -1)
If $55 < 0 Or $55 > 1 Then Return SetError(-5, 0, -1)
Local $56 = ""
If @OSArch = "X64" Then $56 = "64"
Local $2g = RegWrite("HKEY_LOCAL_MACHINE" & $56 & "\Software\Microsoft\Windows\CurrentVersion\Policies\System", "EnableUIADesktopToggle", "REG_DWORD", $55)
If $2g = 0 Then $2g = -1
Return SetError(@error, 0, $2g)
EndFunc
Func _xx($55 = $54)
If Not IsAdmin() Then Return SetError(-3, 0, -1)
If StringRegExp(@OSVersion, "_(XP|200(0|3))") Then Return SetError(-4, 0, -1)
If $55 < 0 Or $55 > 1 Then Return SetError(-5, 0, -1)
Local $56 = ""
If @OSArch = "X64" Then $56 = "64"
Local $2g = RegWrite("HKEY_LOCAL_MACHINE" & $56 & "\Software\Microsoft\Windows\CurrentVersion\Policies\System", "EnableVirtualization", "REG_DWORD", $55)
If $2g = 0 Then $2g = -1
Return SetError(@error, 0, $2g)
EndFunc
Func _xy($55 = $53)
If Not IsAdmin() Then Return SetError(-3, 0, -1)
If StringRegExp(@OSVersion, "_(XP|200(0|3))") Then Return SetError(-4, 0, -1)
If $55 < 0 Or $55 > 1 Then Return SetError(-5, 0, -1)
Local $56 = ""
If @OSArch = "X64" Then $56 = "64"
Local $2g = RegWrite("HKEY_LOCAL_MACHINE" & $56 & "\Software\Microsoft\Windows\CurrentVersion\Policies\System", "FilterAdministratorToken", "REG_DWORD", $55)
If $2g = 0 Then $2g = -1
Return SetError(@error, 0, $2g)
EndFunc
Func _xz($55 = $54)
If Not IsAdmin() Then Return SetError(-3, 0, -1)
If StringRegExp(@OSVersion, "_(XP|200(0|3))") Then Return SetError(-4, 0, -1)
If $55 < 0 Or $55 > 1 Then Return SetError(-5, 0, -1)
Local $56 = ""
If @OSArch = "X64" Then $56 = "64"
Local $2g = RegWrite("HKEY_LOCAL_MACHINE" & $56 & "\Software\Microsoft\Windows\CurrentVersion\Policies\System", "PromptOnSecureDesktop", "REG_DWORD", $55)
If $2g = 0 Then $2g = -1
Return SetError(@error, 0, $2g)
EndFunc
Func _y0($55 = $53)
If Not IsAdmin() Then Return SetError(-3, 0, -1)
If StringRegExp(@OSVersion, "_(XP|200(0|3))") Then Return SetError(-4, 0, -1)
If $55 < 0 Or $55 > 1 Then Return SetError(-5, 0, -1)
Local $56 = ""
If @OSArch = "X64" Then $56 = "64"
Local $2g = RegWrite("HKEY_LOCAL_MACHINE" & $56 & "\Software\Microsoft\Windows\CurrentVersion\Policies\System", "ValidateAdminCodeSignatures", "REG_DWORD", $55)
If $2g = 0 Then $2g = -1
Return SetError(@error, 0, $2g)
EndFunc
Global $57 = Null, $58 = Null
Global $59 = EnvGet('SystemDrive') & '\'
Func _y2()
Local $5a[1][3], $5b = 0
$5a[0][0] = $5b
If Not IsObj($58) Then $58 = ObjGet("winmgmts:root/default")
If Not IsObj($58) Then Return $5a
Local $5c = $58.InstancesOf("SystemRestore")
If Not IsObj($5c) Then Return $5a
For $5d In $5c
$5b += 1
ReDim $5a[$5b + 1][3]
$5a[$5b][0] = $5d.SequenceNumber
$5a[$5b][1] = $5d.Description
$5a[$5b][2] = _y3($5d.CreationTime)
Next
$5a[0][0] = $5b
Return $5a
EndFunc
Func _y3($5e)
Return(StringMid($5e, 5, 2) & "/" & StringMid($5e, 7, 2) & "/" & StringLeft($5e, 4) & " " & StringMid($5e, 9, 2) & ":" & StringMid($5e, 11, 2) & ":" & StringMid($5e, 13, 2))
EndFunc
Func _y4($5f)
Local $q = DllCall('SrClient.dll', 'DWORD', 'SRRemoveRestorePoint', 'DWORD', $5f)
If @error Then Return SetError(1, 0, 0)
If $q[0] = 0 Then Return 1
Return SetError(1, 0, 0)
EndFunc
Func _y6($5g = $59)
If Not IsObj($57) Then $57 = ObjGet("winmgmts:{impersonationLevel=impersonate}!root/default:SystemRestore")
If Not IsObj($57) Then Return 0
If $57.Enable($5g) = 0 Then Return 1
Return 0
EndFunc
Global Enum $5h = 0, $5i, $5j, $5k, $5l, $5m, $5n, $5o, $5p, $5q, $5r, $5s, $5t
Global Const $5u = 2
Global $5v = @SystemDir&'\Advapi32.dll'
Global $5w = @SystemDir&'\Kernel32.dll'
Global $5x[4][2], $5y[4][2]
Global $5z = 0
Func _y9()
$5v = DllOpen(@SystemDir&'\Advapi32.dll')
$5w = DllOpen(@SystemDir&'\Kernel32.dll')
$5x[0][0] = "SeRestorePrivilege"
$5x[0][1] = 2
$5x[1][0] = "SeTakeOwnershipPrivilege"
$5x[1][1] = 2
$5x[2][0] = "SeDebugPrivilege"
$5x[2][1] = 2
$5x[3][0] = "SeSecurityPrivilege"
$5x[3][1] = 2
$5y = _zh($5x)
$5z = 1
EndFunc
Func _yf($60, $61 = $5i, $62 = 'Administrators', $63 = 1)
Local $64[1][3]
$64[0][0] = 'Everyone'
$64[0][1] = 1
$64[0][2] = $l
Return _yi($60, $64, $61, $62, 1, $63)
EndFunc
Func _yi($60, $65, $61 = $5i, $62 = '', $66 = 0, $63 = 0, $67 = 3)
If $5z = 0 Then _y9()
If Not IsArray($65) Or UBound($65,2) < 3 Then Return SetError(1,0,0)
Local $68 = _yn($65,$67)
Local $69 = @extended
Local $6a = 4, $6b = 0
If $62 <> '' Then
If Not IsDllStruct($62) Then $62 = _za($62)
$6b = DllStructGetPtr($62)
If $6b And _zg($6b) Then
$6a = 5
Else
$6b = 0
EndIf
EndIf
If Not IsPtr($60) And $61 = $5i Then
Return _yv($60, $68, $6b, $66, $63, $69, $6a)
ElseIf Not IsPtr($60) And $61 = $5l Then
Return _yw($60, $68, $6b, $66, $63, $69, $6a)
Else
If $66 Then _yx($60,$61)
Return _yo($60, $61, $6a, $6b, 0, $68,0)
EndIf
EndFunc
Func _yn(ByRef $65, ByRef $67)
Local $6c = UBound($65,2)
If Not IsArray($65) Or $6c < 3 Then Return SetError(1,0,0)
Local $6d = UBound($65), $6e[$6d], $6f = 0, $6g = 1
Local $6h, $69 = 0, $6i
Local $6j, $6k = 'DWORD;DWORD;DWORD;ptr;DWORD;DWORD;DWORD;ptr'
For $3x = 1 To $6d - 1
$6k &= ';DWORD;DWORD;DWORD;ptr;DWORD;DWORD;DWORD;ptr'
Next
$6j = DllStructCreate($6k)
For $3x = 0 To $6d -1
If Not IsDllStruct($65[$3x][0]) Then $65[$3x][0] = _za($65[$3x][0])
$6e[$3x] = DllStructGetPtr($65[$3x][0])
If Not _zg($6e[$3x]) Then ContinueLoop
DllStructSetData($6j,$6f+1,$65[$3x][2])
If $65[$3x][1] = 0 Then
$69 = 1
$6h = $8
Else
$6h = $7
EndIf
If $6c > 3 Then $67 = $65[$3x][3]
DllStructSetData($6j,$6f+2,$6h)
DllStructSetData($6j,$6f+3,$67)
DllStructSetData($6j,$6f+6,0)
$6i = DllCall($5v,'BOOL','LookupAccountSid','ptr',0,'ptr',$6e[$3x],'ptr*',0,'dword*',32,'ptr*',0,'dword*',32,'dword*',0)
If Not @error Then $6g = $6i[7]
DllStructSetData($6j,$6f+7,$6g)
DllStructSetData($6j,$6f+8,$6e[$3x])
$6f += 8
Next
Local $6l = DllStructGetPtr($6j)
$6i = DllCall($5v,'DWORD','SetEntriesInAcl','ULONG',$6d,'ptr',$6l ,'ptr',0,'ptr*',0)
If @error Or $6i[0] Then Return SetError(1,0,0)
Return SetExtended($69, $6i[4])
EndFunc
Func _yo($60, $61, $6a, $6b = 0, $6m = 0, $68 = 0, $6n = 0)
Local $6i
If $5z = 0 Then _y9()
If $68 And Not _yp($68) Then Return 0
If $6n And Not _yp($6n) Then Return 0
If IsPtr($60) Then
$6i = DllCall($5v,'dword','SetSecurityInfo','handle',$60,'dword',$61, 'dword',$6a,'ptr',$6b,'ptr',$6m,'ptr',$68,'ptr',$6n)
Else
If $61 = $5l Then $60 = _zb($60)
$6i = DllCall($5v,'dword','SetNamedSecurityInfo','str',$60,'dword',$61, 'dword',$6a,'ptr',$6b,'ptr',$6m,'ptr',$68,'ptr',$6n)
EndIf
If @error Then Return SetError(1,0,0)
If $6i[0] And $6b Then
If _z0($60, $61,_zf($6b)) Then Return _yo($60, $61, $6a - 1, 0, $6m, $68, $6n)
EndIf
Return SetError($6i[0] , 0, Number($6i[0] = 0))
EndFunc
Func _yp($6o)
If $6o = 0 Then Return SetError(1,0,0)
Local $6i = DllCall($5v,'bool','IsValidAcl','ptr',$6o)
If @error Or Not $6i[0] Then Return 0
Return 1
EndFunc
Func _yv($60, ByRef $68, ByRef $6b, ByRef $66, ByRef $63, ByRef $69, ByRef $6a)
Local $6p, $6q
If Not $69 Then
If $66 Then _yx($60,$5i)
$6p = _yo($60, $5i, $6a, $6b, 0, $68,0)
EndIf
If $63 Then
Local $6r = FileFindFirstFile($60&'\*')
While 1
$6q = FileFindNextFile($6r)
If $63 = 1 Or $63 = 2 And @extended = 1 Then
_yv($60&'\'&$6q, $68, $6b, $66, $63, $69,$6a)
ElseIf @error Then
ExitLoop
ElseIf $63 = 1 Or $63 = 3 Then
If $66 Then _yx($60&'\'&$6q,$5i)
_yo($60&'\'&$6q, $5i, $6a, $6b, 0, $68,0)
EndIf
WEnd
FileClose($6r)
EndIf
If $69 Then
If $66 Then _yx($60,$5i)
$6p = _yo($60, $5i, $6a, $6b, 0, $68,0)
EndIf
Return $6p
EndFunc
Func _yw($60, ByRef $68, ByRef $6b, ByRef $66, ByRef $63, ByRef $69, ByRef $6a)
If $5z = 0 Then _y9()
Local $6p, $3x = 0, $6q
If Not $69 Then
If $66 Then _yx($60,$5l)
$6p = _yo($60, $5l, $6a, $6b, 0, $68,0)
EndIf
If $63 Then
While 1
$3x += 1
$6q = RegEnumKey($60,$3x)
If @error Then ExitLoop
_yw($60&'\'&$6q, $68, $6b, $66, $63, $69, $6a)
WEnd
EndIf
If $69 Then
If $66 Then _yx($60,$5l)
$6p = _yo($60, $5l, $6a, $6b, 0, $68,0)
EndIf
Return $6p
EndFunc
Func _yx($60, $61 = $5i)
If $5z = 0 Then _y9()
Local $6s = DllStructCreate('byte[32]'), $q
Local $68 = DllStructGetPtr($6s,1)
DllCall($5v,'bool','InitializeAcl','Ptr',$68,'dword',DllStructGetSize($6s),'dword',$5u)
If IsPtr($60) Then
$q = DllCall($5v,"dword","SetSecurityInfo",'handle',$60,'dword',$61,'dword',4,'ptr',0,'ptr',0,'ptr',$68,'ptr',0)
Else
If $61 = $5l Then $60 = _zb($60)
DllCall($5v,'DWORD','SetNamedSecurityInfo','str',$60,'dword',$61,'DWORD',4,'ptr',0,'ptr',0,'ptr',0,'ptr',0)
$q = DllCall($5v,'DWORD','SetNamedSecurityInfo','str',$60,'dword',$61,'DWORD',4,'ptr',0,'ptr',0,'ptr',$68,'ptr',0)
EndIf
If @error Then Return SetError(@error,0,0)
Return SetError($q[0],0,Number($q[0] = 0))
EndFunc
Func _z0($60, $61 = $5i, $6t = 'Administrators')
If $5z = 0 Then _y9()
Local $6u = _za($6t), $q
Local $6e = DllStructGetPtr($6u)
If IsPtr($60) Then
$q = DllCall($5v,"dword","SetSecurityInfo",'handle',$60,'dword',$61,'dword',1,'ptr',$6e,'ptr',0,'ptr',0,'ptr',0)
Else
If $61 = $5l Then $60 = _zb($60)
$q = DllCall($5v,'DWORD','SetNamedSecurityInfo','str',$60,'dword',$61,'DWORD',1,'ptr',$6e,'ptr',0,'ptr',0,'ptr',0)
EndIf
If @error Then Return SetError(@error,0,False)
Return SetError($q[0],0,Number($q[0] = 0))
EndFunc
Func _za($6t)
If $6t = 'TrustedInstaller' Then $6t = 'NT SERVICE\TrustedInstaller'
If $6t = 'Everyone' Then
Return _zd('S-1-1-0')
ElseIf $6t = 'Authenticated Users' Then
Return _zd('S-1-5-11')
ElseIf $6t = 'System' Then
Return _zd('S-1-5-18')
ElseIf $6t = 'Administrators' Then
Return _zd('S-1-5-32-544')
ElseIf $6t = 'Users' Then
Return _zd('S-1-5-32-545')
ElseIf $6t = 'Guests' Then
Return _zd('S-1-5-32-546')
ElseIf $6t = 'Power Users' Then
Return _zd('S-1-5-32-547')
ElseIf $6t = 'Local Authority' Then
Return _zd('S-1-2')
ElseIf $6t = 'Creator Owner' Then
Return _zd('S-1-3-0')
ElseIf $6t = 'NT Authority' Then
Return _zd('S-1-5-1')
ElseIf $6t = 'Restricted' Then
Return _zd('S-1-5-12')
ElseIf StringRegExp($6t,'\A(S-1-\d+(-\d+){0,5})\z') Then
Return _zd($6t)
Else
Local $6u = _zc($6t)
Return _zd($6u)
EndIf
EndFunc
Func _zb($6v)
If StringInStr($6v,'\\') = 1 Then
$6v = StringRegExpReplace($6v,'(?i)\\(HKEY_CLASSES_ROOT|HKCR)','\CLASSES_ROOT')
$6v = StringRegExpReplace($6v,'(?i)\\(HKEY_CURRENT_USER|HKCU)','\CURRENT_USER')
$6v = StringRegExpReplace($6v,'(?i)\\(HKEY_LOCAL_MACHINE|HKLM)','\MACHINE')
$6v = StringRegExpReplace($6v,'(?i)\\(HKEY_USERS|HKU)','\USERS')
Else
$6v = StringRegExpReplace($6v,'(?i)\A(HKEY_CLASSES_ROOT|HKCR)','CLASSES_ROOT')
$6v = StringRegExpReplace($6v,'(?i)\A(HKEY_CURRENT_USER|HKCU)','CURRENT_USER')
$6v = StringRegExpReplace($6v,'(?i)\A(HKEY_LOCAL_MACHINE|HKLM)','MACHINE')
$6v = StringRegExpReplace($6v,'(?i)\A(HKEY_USERS|HKU)','USERS')
EndIf
Return $6v
EndFunc
Func _zc($6w, $6x = "")
Local $6y = DllStructCreate("byte SID[256]")
Local $6e = DllStructGetPtr($6y, "SID")
Local $2k = DllCall($5v, "bool", "LookupAccountNameW", "wstr", $6x, "wstr", $6w, "ptr", $6e, "dword*", 256, "wstr", "", "dword*", 256, "int*", 0)
If @error Then Return SetError(@error, @extended, 0)
If Not $2k[0] Then Return 0
Return _zf($6e)
EndFunc
Func _zd($6z)
Local $2k = DllCall($5v, "bool", "ConvertStringSidToSidW", "wstr", $6z, "ptr*", 0)
If @error Then Return SetError(@error, @extended, 0)
If Not $2k[0] Then Return 0
Local $70 = _ze($2k[2])
Local $3b = DllStructCreate("byte Data[" & $70 & "]", $2k[2])
Local $71 = DllStructCreate("byte Data[" & $70 & "]")
DllStructSetData($71, "Data", DllStructGetData($3b, "Data"))
DllCall($5w, "ptr", "LocalFree", "ptr", $2k[2])
Return $71
EndFunc
Func _ze($6e)
If Not _zg($6e) Then Return SetError(-1, 0, "")
Local $2k = DllCall($5v, "dword", "GetLengthSid", "ptr", $6e)
If @error Then Return SetError(@error, @extended, 0)
Return $2k[0]
EndFunc
Func _zf($6e)
If Not _zg($6e) Then Return SetError(-1, 0, "")
Local $2k = DllCall($5v, "int", "ConvertSidToStringSidW", "ptr", $6e, "ptr*", 0)
If @error Then Return SetError(@error, @extended, "")
If Not $2k[0] Then Return ""
Local $3b = DllStructCreate("wchar Text[256]", $2k[2])
Local $6z = DllStructGetData($3b, "Text")
DllCall($5w, "ptr", "LocalFree", "ptr", $2k[2])
Return $6z
EndFunc
Func _zg($6e)
Local $2k = DllCall($5v, "bool", "IsValidSid", "ptr", $6e)
If @error Then Return SetError(@error, @extended, False)
Return $2k[0]
EndFunc
Func _zh($72)
Local $73 = UBound($72, 0), $74[1][2]
If Not($73 <= 2 And UBound($72, $73) = 2 ) Then Return SetError(1300, 0, $74)
If $73 = 1 Then
Local $75[1][2]
$75[0][0] = $72[0]
$75[0][1] = $72[1]
$72 = $75
$75 = 0
EndIf
Local $76, $77 = "dword", $78 = UBound($72, 1)
Do
$76 += 1
$77 &= ";dword;long;dword"
Until $76 = $78
Local $79, $7a, $7b, $7c, $7d, $7e, $7f
$79 = DLLStructCreate($77)
$7a = DllStructCreate($77)
$7b = DllStructGetPtr($7a)
$7c = DllStructCreate("dword;long")
DLLStructSetData($79, 1, $78)
For $3x = 0 To $78 - 1
DllCall($5v, "int", "LookupPrivilegeValue", "str", "", "str", $72[$3x][0], "ptr", DllStructGetPtr($7c) )
DLLStructSetData( $79, 3 * $3x + 2, DllStructGetData($7c, 1) )
DLLStructSetData( $79, 3 * $3x + 3, DllStructGetData($7c, 2) )
DLLStructSetData( $79, 3 * $3x + 4, $72[$3x][1] )
Next
$7d = DllCall($5w, "hwnd", "GetCurrentProcess")
$7e = DllCall($5v, "int", "OpenProcessToken", "hwnd", $7d[0], "dword", BitOR(0x00000020, 0x00000008), "hwnd*", 0 )
DllCall( $5v, "int", "AdjustTokenPrivileges", "hwnd", $7e[3], "int", False, "ptr", DllStructGetPtr($79), "dword", DllStructGetSize($79), "ptr", $7b, "dword*", 0 )
$7f = DllCall($5w, "dword", "GetLastError")
DllCall($5w, "int", "CloseHandle", "hwnd", $7e[3])
Local $7g = DllStructGetData($7a, 1)
If $7g > 0 Then
Local $7h, $7i, $7j, $74[$7g][2]
For $3x = 0 To $7g - 1
$7h = $7b + 12 * $3x + 4
$7i = DllCall($5v, "int", "LookupPrivilegeName", "str", "", "ptr", $7h, "ptr", 0, "dword*", 0 )
$7j = DllStructCreate("char[" & $7i[4] & "]")
DllCall($5v, "int", "LookupPrivilegeName", "str", "", "ptr", $7h, "ptr", DllStructGetPtr($7j), "dword*", DllStructGetSize($7j) )
$74[$3x][0] = DllStructGetData($7j, 1)
$74[$3x][1] = DllStructGetData($7a, 3 * $3x + 4)
Next
EndIf
Return SetError($7f[0], 0, $74)
EndFunc
If Not IsAdmin() Then
MsgBox(16, $4x, $4z)
Exit
EndIf
Local $7k = ProcessList("mbar.exe")
If $7k[0][0] > 0 Then
MsgBox(16, $4x, $50)
Exit
EndIf
Func _zi($7l)
Dim $7m
FileWrite(@DesktopDir & "\" & $7m, $7l & @CRLF)
FileWrite(@HomeDrive & "\KPRM" & "\" & $7m, $7l & @CRLF)
EndFunc
Func _zj()
Local $7n = 100, $7o = 100, $7p = 0, $7q = @WindowsDir & "\Explorer.exe"
_hf($2t, 0, 0, 0)
Local $7r = _d0("Shell_TrayWnd", "")
_51($7r, 1460, 0, 0)
While ProcessExists("Explorer.exe")
Sleep(10)
$7n -= ProcessClose("Explorer.exe") ? 0 : 1
If $7n < 1 Then Return SetError(1, 0, 0)
WEnd
While(Not ProcessExists("Explorer.exe"))
If Not FileExists($7q) Then Return SetError(-1, 0, 0)
Sleep(500)
$7p = ShellExecute($7q)
$7o -= $7p ? 0 : 1
If $7o < 1 Then Return SetError(2, 0, 0)
WEnd
Return $7p
EndFunc
Func _zm($7s, $7t, $7u)
Local $3x = 0
While True
$3x += 1
Local $7v = RegEnumKey($7s, $3x)
If @error <> 0 Then ExitLoop
Local $7w = $7s & "\" & $7v
Local $6q = RegRead($7w, $7u)
If StringRegExp($6q, $7t) Then
Return $7w
EndIf
WEnd
Return Null
EndFunc
Func _zo()
Local $7x = []
If FileExists(@HomeDrive & "\Program Files") Then
_vv($7x, @HomeDrive & "\Program Files")
EndIf
If FileExists(@HomeDrive & "\Program Files (x86)") Then
_vv($7x, @HomeDrive & "\Program Files (x86)")
EndIf
If FileExists(@HomeDrive & "\Program Files(x86)") Then
_vv($7x, @HomeDrive & "\Program Files(x86)")
EndIf
Return $7x
EndFunc
Func _zp($4f)
Return Int(FileExists($4f) And StringInStr(FileGetAttrib($4f), 'D', Default, 1) = 0)
EndFunc
Func _zq($4f)
Return Int(FileExists($4f) And StringInStr(FileGetAttrib($4f), 'D', Default, 1) > 0)
EndFunc
Func _zr($4f)
Local $7y = Null
If FileExists($4f) Then
Local $7z = StringInStr(FileGetAttrib($4f), 'D', Default, 1)
If $7z = 0 Then
$7y = 'file'
ElseIf $7z > 0 Then
$7y = 'folder'
EndIf
EndIf
Return $7y
EndFunc
Local $80 = 39
Local $81
Local Const $82 = Floor(100 / $80)
Func _zs($83 = 1)
$81 += $83
Dim $84
GUICtrlSetData($84, $81 * $82)
If $81 = $80 Then
GUICtrlSetData($84, 100)
EndIf
EndFunc
Func _zt()
$81 = 0
Dim $84
GUICtrlSetData($84, 0)
EndFunc
Func _zu()
_zi(@CRLF & "- Clear All System Restore Points -" & @CRLF)
Local Const $85 = _y2()
Local $6p = 0
If $85[0][0] = 0 Then
_zi("  [I] No system recovery points were found")
Return Null
EndIf
Local $86[1][2] = [[Null, Null]]
For $3x = 1 To $85[0][0]
Local $87 = _y4($85[$3x][0])
$6p += $87
If $87 = 1 Then
_zi("    => [OK] RP named " & $85[$3x][1] & " has been successfully deleted")
ElseIf UBound($85[$3x]) = 3 Then
Local $88[1][2] = [[$85[$3x][0], $85[$3x][1]]]
_vv($86, $88)
Else
_zi("    => [X] RP named " & $85[$3x][1] & " has not been successfully deleted")
EndIf
Next
If 1 < UBound($86) Then
Sleep(3000)
For $3x = 1 To UBound($86) - 1
Local $87 = _y4($86[$3x][0])
$6p += $87
If $87 = 1 Then
_zi("    => [OK] RP named " & $86[$3x][1] & " has been successfully deleted")
Else
_zi("    => [X] RP named " & $86[$3x][1] & " has not been successfully deleted")
EndIf
Next
EndIf
If $85[0][0] = $6p Then
_zi("  [OK] All system restore points have been successfully deleted")
Else
_zi("  [X] Failure when deleting all restore points")
EndIf
EndFunc
Func _zv($5e)
Local $89 = StringLeft($5e, 4)
Local $8a = StringMid($5e, 6, 2)
Local $8b = StringMid($5e, 9, 2)
Local $8c = StringRight($5e, 8)
Return $8a & "/" & $8b & "/" & $89 & " " & $8c
EndFunc
Func _zw($8d = False)
Local Const $85 = _y2()
If $85[0][0] = 0 Then
Return Null
EndIf
Local Const $8e = _zv(_31('h', -25, _3p()))
Local $8f = False
For $3x = 1 To $85[0][0]
Local $8g = $85[$3x][2]
If $8g > $8e Then
Local $87 = _y4($85[$3x][0])
If $87 = 1 Then
_zi("    => [OK] RP named " & $85[$3x][1] & " has been successfully deleted")
ElseIf $8d = False Then
$8f = True
Else
_zi("  [X] Failure when deleting restore point " & $85[$3x][1])
EndIf
EndIf
Next
If $8f = True Then
Sleep(3000)
_zw(True)
EndIf
Sleep(3000)
EndFunc
Func _zx()
RunWait('powershell Checkpoint-Computer -Description "kprm" -RestorePointType MODIFY_SETTINGS')
Return @error
EndFunc
Func _zy($8d = False)
If $8d = False Then
_zi(@CRLF & "- Create New System Restore Point -" & @CRLF)
Else
_zi("  [I] Retry Create New System Restore Point")
EndIf
Dim $8h
Local $8i = _y6()
If $8i = 0 Then
Sleep(3000)
$8i = _y6()
If $8i = 0 Then
_zi("  [X] Failed to enable System Restore")
EndIf
ElseIf $8i = 1 Then
_zi("  [OK] System Restore enabled successfully")
EndIf
_zw()
Local Const $8j = _zx()
If $8j <> 0 Then
_zi("  [X] Failed to create System Restore Point!")
If $8d = False Then
_zy(True)
Return
EndIf
ElseIf $8j = 0 Then
_zi("  [OK] System Restore Point successfully created")
EndIf
EndFunc
Func _0zz()
_zi(@CRLF & "- Create Registry Backup -" & @CRLF)
Local Const $8k = @HomeDrive & "\KPRM"
Local Const $8l = $8k & "\regedit-backup-" & @YEAR & @MON & @MDAY & @HOUR & @MIN & ".reg"
If FileExists($8l) Then
FileMove($8l, $8l & ".old")
EndIf
Local Const $87 = RunWait("Regedit /e " & $8l)
If Not FileExists($8l) Or @error <> 0 Then
_zi("  [X] Failed to create registry backup")
MsgBox(16, $4x, $4y)
Exit
Else
_zi("  [OK] Registry Backup created successfully at " & $8l)
EndIf
EndFunc
Func _100()
_zi(@CRLF & "- Restore UAC Default Value -" & @CRLF)
Local $87 = _xr()
If $87 = 1 Then
_zi("  [OK] Set ConsentPromptBehaviorAdmin with default value successfully.")
Else
_zi("  [X] Set ConsentPromptBehaviorAdmin with default value failed")
EndIf
Local $87 = _xs()
If $87 = 1 Then
_zi("  [OK] Set ConsentPromptBehaviorUser with default value successfully.")
Else
_zi("  [X] Set ConsentPromptBehaviorUser with default value failed")
EndIf
Local $87 = _xt()
If $87 = 1 Then
_zi("  [OK] Set EnableInstallerDetection with default value successfully.")
Else
_zi("  [X] Set EnableInstallerDetection with default value failed")
EndIf
Local $87 = _xu()
If $87 = 1 Then
_zi("  [OK] Set EnableLUA with default value successfully.")
Else
_zi("  [X] Set EnableLUA with default value failed")
EndIf
Local $87 = _xv()
If $87 = 1 Then
_zi("  [OK] Set EnableSecureUIAPaths with default value successfully.")
Else
_zi("  [X] Set EnableSecureUIAPaths with default value failed")
EndIf
Local $87 = _xw()
If $87 = 1 Then
_zi("  [OK] Set EnableUIADesktopToggle with default value successfully.")
Else
_zi("  [X] Set EnableUIADesktopToggle with default value failed")
EndIf
Local $87 = _xx()
If $87 = 1 Then
_zi("  [OK] Set EnableVirtualization with default value successfully.")
Else
_zi("  [X] Set EnableVirtualization with default value failed")
EndIf
Local $87 = _xy()
If $87 = 1 Then
_zi("  [OK] Set FilterAdministratorToken with default value successfully.")
Else
_zi("  [X] Set FilterAdministratorToken with default value failed")
EndIf
Local $87 = _xz()
If $87 = 1 Then
_zi("  [OK] Set PromptOnSecureDesktop with default value successfully.")
Else
_zi("  [X] Set PromptOnSecureDesktop with default value failed")
EndIf
Local $87 = _y0()
If $87 = 1 Then
_zi("  [OK] Set ValidateAdminCodeSignatures with default value successfully.")
Else
_zi("  [X] Set ValidateAdminCodeSignatures with default value failed")
EndIf
EndFunc
Func _101()
_zi(@CRLF & "- Restore Default System Settings -" & @CRLF)
Local $87 = RunWait(@ComSpec & " /c " & "ipconfig /flushdns", @TempDir, @SW_HIDE)
If @error <> 0 Then
_zi("  [X] Flush DNS failure")
Else
_zi("  [OK] Flush DNS successfully completed")
EndIf
Local Const $8m[7] = [ "netsh winsock reset", "netsh winhttp reset proxy", "netsh winhttp reset tracing", "netsh winsock reset catalog", "netsh int ip reset all", "netsh int ipv4 reset catalog", "netsh int ipv6 reset catalog" ]
$87 = 0
For $3x = 0 To UBound($8m) -1
RunWait(@ComSpec & " /c " & $8m[$3x], @TempDir, @SW_HIDE)
If @error <> 0 Then
$87 += 1
EndIf
Next
If $87 = 0 Then
_zi("  [OK] Reset WinSock successfully completed")
Else
_zi("  [X] Reset WinSock failure")
EndIf
Local $8n = "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced"
$87 = RegWrite($8n, "Hidden", "REG_DWORD", "2")
If $87 = 1 Then
_zi("  [OK] Hide Hidden file successfully.")
Else
_zi("  [X] Hide Hidden File failure")
EndIf
$87 = RegWrite($8n, "HideFileExt", "REG_DWORD", "1")
If $87 = 1 Then
_zi("  [OK] Hide Extensions for known file types successfully.")
Else
_zi("  [X] Hide Extensions for known file types failure")
EndIf
$87 = RegWrite($8n, "ShowSuperHidden", "REG_DWORD", "0")
If $87 = 1 Then
_zi("  [OK] Hide protected operating system files successfully.")
Else
_zi("  [X] Hide protected operating system files failure")
EndIf
_zj()
EndFunc
Global $8o = ObjCreate("Scripting.Dictionary")
Local Const $8p[32] = [ "frst", "zhpdiag", "zhpcleaner", "zhpfix", "mbar", "roguekiller", "usbfix", "adwcleaner", "adsfix", "aswmbr", "fss", "toolsdiag", "scanrapide", "otl", "otm", "listparts", "minitoolbox", "miniregtool", "zhp", "combofix", "regtoolexport", "tdsskiller", "winupdatefix", "rsthosts", "winchk", "avenger", "blitzblank", "zoek", "remediate-vbs-worm", "ckscanner", "quickdiag", "grantperms"]
For $8q = 0 To UBound($8p) - 1
Local $8r[2] = [0, ""]
$8o.add($8p[$8q], $8r)
Next
Global $8s[1][2] = [[Null, Null]]
Global $8t[1][5] = [[Null, Null, Null, Null, Null]]
Global $8u[1][5] = [[Null, Null, Null, Null, Null]]
Global $8v[1][5] = [[Null, Null, Null, Null, Null]]
Global $8w[1][5] = [[Null, Null, Null, Null, Null]]
Global $8x[1][5] = [[Null, Null, Null, Null, Null]]
Global $8y[1][2] = [[Null, Null]]
Global $8z[1][2] = [[Null, Null]]
Global $90[1][4] = [[Null, Null, Null, Null]]
Global $91[1][5] = [[Null, Null, Null, Null, Null]]
Global $92[1][5] = [[Null, Null, Null, Null, Null]]
Global $93[1][5] = [[Null, Null, Null, Null, Null]]
Global $94[1][5] = [[Null, Null, Null, Null, Null]]
Global $95[1][3] = [[Null, Null, Null]]
Func _102($7s, $96 = 0, $97 = False)
Dim $98
If $98 Then _zi("[I] prepareRemove " & $7s)
If $97 Then
_yx($7s)
_yf($7s)
EndIf
Local Const $99 = FileGetAttrib($7s)
If StringInStr($99, "R") Then
FileSetAttrib($7s, "-R", $96)
EndIf
If StringInStr($99, "S") Then
FileSetAttrib($7s, "-S", $96)
EndIf
If StringInStr($99, "H") Then
FileSetAttrib($7s, "-H", $96)
EndIf
If StringInStr($99, "A") Then
FileSetAttrib($7s, "-A", $96)
EndIf
EndFunc
Func _103($9a, $9b = Null, $97 = False)
Dim $98
If $98 Then _zi("[I] RemoveFile " & $9a)
Local Const $9c = _zp($9a)
If $9c Then
If $9b And StringRegExp($9a, "(?i)\.exe$") Then
Local Const $9d = FileGetVersion($9a, "CompanyName")
If @error Then
Return 0
ElseIf Not StringRegExp($9d, $9b) Then
Return 0
EndIf
EndIf
_102($9a, 0, $97)
Local $9e = FileDelete($9a)
If $9e Then
If $98 Then
_zi("  [OK] File " & $9a & " deleted successfully")
EndIf
Return 1
EndIf
Return 2
EndIf
Return 0
EndFunc
Func _104($7s, $97 = False)
Dim $98
If $98 Then _zi("[I] RemoveFolder " & $7s)
Local $9c = _zq($7s)
If $9c Then
_102($7s, 1, $97)
Local Const $9e = DirRemove($7s, $k)
If $9e Then
If $98 Then
_zi("  [OK] Directory " & $7s & " deleted successfully")
EndIf
Return 1
EndIf
Return 2
EndIf
Return 0
EndFunc
Func _105($7s, $9a, $9f)
Dim $98
If $98 Then _zi("[I] FindGlob " & $7s & " " & $9a)
Local Const $9g = $7s & "\" & $9a
Local Const $4n = FileFindFirstFile($9g)
Local $9h = []
If $4n = -1 Then
Return $9h
EndIf
Local $4l = FileFindNextFile($4n)
While @error = 0
If StringRegExp($4l, $9f) Then
_vv($9h, $7s & "\" & $4l)
EndIf
$4l = FileFindNextFile($4n)
WEnd
FileClose($4n)
Return $9h
EndFunc
Func _106($7s, $9i)
Dim $98
If $98 Then _zi("[I] RemoveAllFileFrom " & $7s)
Dim $8o
Local Const $9g = $7s & "\*"
Local Const $4n = FileFindFirstFile($9g)
If $4n = -1 Then
Return Null
EndIf
Local $4l = FileFindNextFile($4n)
While @error = 0
For $9j = 1 To UBound($9i) - 1
Local $9k = $7s & "\" & $4l
Local $9l = _zr($9k)
If $9l And $9i[$9j][3] And $9l = $9i[$9j][1] And StringRegExp($4l, $9i[$9j][3]) Then
Local $9m = $8o.Item($9i[$9j][0])
Local $87 = 0
Local $97 = False
If $9i[$9j][4] = True Then
$97 = True
EndIf
If $9l = 'file' Then
$87 = _103($9k, $9i[$9j][2], $97)
ElseIf $9l = 'folder' Then
$87 = _104($9k, $97)
EndIf
If $87 = 1 Then
$9m[0] += 1
ElseIf $87 = 2 Then
$9m[1] += "  [X] " & $9k & " delete failed" & @CRLF
EndIf
$8o.Item($9i[$9j][0]) = $9m
EndIf
Next
$4l = FileFindNextFile($4n)
WEnd
FileClose($4n)
EndFunc
Func _107($7u)
Dim $98
If $98 Then _zi("[I] RemoveRegistryKey " & $7u)
Local Const $87 = RegDelete($7u)
If $87 = 1 Then
If $98 Then
_zi("  [OK] " & $7u & " deleted successfully")
EndIf
ElseIf $87 = 2 Then
If $98 Then
_zi("  [X] " & $7u & " deleted failed")
EndIf
EndIf
Return $87
EndFunc
Func _10b($9n)
Local $9o = 50
Dim $98
If $98 Then _zi("[I] CloseProcessAndWait " & $9n)
If 0 = ProcessExists($9n) Then Return 0
ProcessClose($9n)
Do
$9o -= 1
Sleep(250)
Until($9o = 0 Or 0 = ProcessExists($9n))
Local Const $87 = ProcessExists($9n)
If 0 = $87 Then
If $98 Then _zi("  [OK] Proccess " & $9n & " stopped successfully")
Return 1
EndIf
Return 0
EndFunc
Func _10c($7k)
Dim $9o
Dim $98
If $98 Then _zi("[I] RemoveAllProcess")
Local $9p = ProcessList()
For $3x = 1 To $9p[0][0]
Local $9q = $9p[$3x][0]
Local $9r = $9p[$3x][1]
For $9o = 1 To UBound($7k) - 1
If StringRegExp($9q, $7k[$9o][1]) Then
Local $9m = $8o.Item($7k[$9o][0])
Local $87 = _10b($9r)
If $87 Then
$9m[0] += 1
Else
$9m[1] += "  [X] The process could not be stopped, the program may not have been deleted correctly" & @CRLF
EndIf
$8o.Item($7k[$9o][0]) = $9m
EndIf
Next
Next
EndFunc
Func _10d($9s)
Dim $98
Dim $8o
If $98 Then _zi("[I] RemoveScheduleTask")
For $3x = 1 To UBound($9s) - 1
RunWait('schtasks.exe /delete /tn "' & $9s[$3x][1] & '" /f', @TempDir, @SW_HIDE)
Next
EndFunc
Func _10e($9s)
Dim $8o
Dim $98
If $98 Then _zi("[I] UninstallNormaly")
Local Const $7x = _zo()
For $3x = 1 To UBound($7x) - 1
For $9t = 1 To UBound($9s) - 1
Local $9u = $9s[$9t][1]
Local $9v = $9s[$9t][2]
Local $9w = _105($7x[$3x], "*", $9u)
For $9x = 1 To UBound($9w) - 1
Local $9y = _105($9w[$9x], "*", $9v)
For $9z = 1 To UBound($9y) - 1
If _zp($9y[$9z]) Then
RunWait($9y[$9z])
Local $9m = $8o.Item($9s[$9t][0])
$9m[0] += 1
$8o.Item($9s[$9t][0]) = $9m
EndIf
Next
Next
Next
Next
EndFunc
Func _10f($9s)
Dim $98
If $98 Then _zi("[I] RemoveAllProgramFilesDir")
Local Const $7x = _zo()
For $3x = 1 To UBound($7x) - 1
_106($7x[$3x], $9s)
Next
EndFunc
Func _10g($9s)
Dim $8o
Dim $98
If $98 Then _zi("[I] RemoveAllSoftwareKeyList")
Local $56 = ""
If @OSArch = "X64" Then $56 = "64"
Local $a0[2] = ["HKCU" & $56 & "\SOFTWARE", "HKLM" & $56 & "\SOFTWARE"]
For $76 = 0 To UBound($a0) - 1
Local $3x = 0
While True
$3x += 1
Local $7v = RegEnumKey($a0[$76], $3x)
If @error <> 0 Then ExitLoop
For $9t = 1 To UBound($9s) - 1
If $7v And $9s[$9t][1] Then
If StringRegExp($7v, $9s[$9t][1]) Then
Local $87 = _107($a0[$76] & "\" & $7v)
Local $9m = $8o.Item($9s[$9t][0])
If $87 = 1 Then
$9m[0] += 1
ElseIf $87 = 2 Then
$9m[1] += "[X] " & $a0[$76] & "\" & $7v & " delete failed" & @CRLF
EndIf
$8o.Item($9s[$9t][0]) = $9m
EndIf
EndIf
Next
WEnd
Next
EndFunc
Func _10h($9s)
Dim $8o
Dim $98
If $98 Then _zi("[I] RemoveUninstallStringWithSearch")
For $3x = 1 To UBound($9s) - 1
Local $a1 = _zm($9s[$3x][1], $9s[$3x][2], $9s[$3x][3])
If $a1 And $a1 <> "" Then
Local $87 = _107($a1)
Local $9m = $8o.Item($9s[$3x][0])
If $87 = 1 Then
$9m[0] += 1
ElseIf $87 = 2 Then
$9m[1] += "[X] " & $a1 & " delete failed" & @CRLF
EndIf
$8o.Item($9s[$3x][0]) = $9m
EndIf
Next
EndFunc
Func _10i()
Local Const $a2 = "frst"
Dim $8s
Dim $8t
Dim $a3
Dim $8v
Dim $a4
Dim $8x
Local Const $9b = "(?i)^Farbar"
Local Const $a5 = "(?i)^FRST.*\.exe$"
Local Const $a6 = "(?i)^FRST-OlderVersion$"
Local Const $a7 = "(?i)^(FRST|fixlist|fixlog|Addition|Shortcut).*\.(exe|txt)$"
Local Const $a8 = "(?i)^FRST"
Local Const $a9[1][2] = [[$a2, $a5]]
Local Const $aa[1][5] = [[$a2, 'file', $9b, $a7, False]]
Local Const $ab[1][5] = [[$a2, 'folder', Null, $a6, False]]
Local Const $ac[1][5] = [[$a2, 'folder', Null, $a8, True]]
_vv($8s, $a9)
_vv($8t, $aa)
_vv($8v, $aa)
_vv($8t, $ab)
_vv($8v, $ab)
_vv($8x, $ac)
EndFunc
_10i()
Func _10j()
Dim $93
Dim $8y
Local $a2 = "zhp"
Local Const $7z[1][2] = [[$a2, "(?i)^ZHP$"]]
Local Const $ad[1][5] = [[$a2, 'folder', Null, "(?i)^ZHP$", True]]
_vv($93, $ad)
_vv($8y, $7z)
EndFunc
_10j()
Func _10k()
Local Const $ae = Null
Local Const $a2 = "zhpdiag"
Dim $8s
Dim $8t
Dim $8u
Dim $8v
Dim $8x
Local Const $a5 = "(?i)^ZHPDiag.*\.exe$"
Local Const $a6 = "(?i)^ZHPDiag.*\.(exe|txt|lnk)$"
Local Const $a7 = "(?i)^PhysicalDisk[0-9]_MBR\.bin$"
Local Const $a9[1][2] = [[$a2, $a5]]
Local Const $aa[1][5] = [[$a2, 'file', $ae, $a6, False]]
Local Const $ab[1][5] = [[$a2, 'file', Null, $a7, True]]
_vv($8s, $a9)
_vv($8t, $aa)
_vv($8v, $aa)
_vv($8u, $aa)
_vv($8x, $ab)
EndFunc
_10k()
Func _10l()
Local Const $ae = Null
Local Const $af = "zhpfix"
Dim $8s
Dim $8t
Dim $8v
Local Const $a5 = "(?i)^ZHPFix.*\.exe$"
Local Const $a6 = "(?i)^ZHPFix.*\.(exe|txt|lnk)$"
Local Const $a9[1][2] = [[$af, $a5]]
Local Const $aa[1][5] = [[$af, 'file', $ae, $a6, False]]
_vv($8s, $a9)
_vv($8t, $aa)
_vv($8v, $aa)
EndFunc
_10l()
Func _10m($8d = False)
Local Const $9b = "(?i)^Malwarebytes Anti-Rootkit$"
Local Const $ag = "(?i)^Malwarebytes"
Local Const $a2 = "mbar"
Dim $8s
Dim $8t
Dim $8v
Dim $8y
Local Const $a5 = "(?i)^mbar.*\.exe$"
Local Const $a6 = "(?i)^mbar"
Local Const $a9[1][2] = [[$a2, $a5]]
Local Const $aa[1][2] = [[$a2, $9b]]
Local Const $ab[1][5] = [[$a2, 'file', $ag, $a5, False]]
Local Const $ac[1][5] = [[$a2, 'folder', $9b, $a6, False]]
_vv($8s, $a9)
_vv($8t, $ab)
_vv($8v, $ab)
_vv($8t, $ac)
_vv($8v, $ac)
_vv($8y, $aa)
EndFunc
_10m()
Func _10n()
Local Const $a2 = "roguekiller"
Dim $8s
Dim $8z
Dim $90
Dim $8w
Dim $91
Dim $8t
Dim $8u
Dim $94
Dim $8v
Local $56 = ""
If @OSArch = "X64" Then $56 = "64"
Local Const $ah = "(?i)^Adlice"
Local Const $a5 = "(?i)^RogueKiller"
Local Const $a6 = "(?i)^RogueKiller.*\.(exe|lnk|txt)$"
Local Const $a7 = "(?i)^RogueKiller.*\.exe$"
Local Const $a8 = "(?i)^RogueKiller_portable(32|64)\.exe$"
Local Const $a9[1][2] = [[$a2, $a7]]
Local Const $aa[1][2] = [[$a2, "RogueKiller Anti-Malware"]]
Local Const $ab[1][4] = [[$a2, "HKLM" & $56 & "\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall", $a5, "DisplayName"]]
Local Const $ac[1][5] = [[$a2, 'file', $ah, $a6, False]]
Local Const $ai[1][5] = [[$a2, 'folder', Null, $a5, True]]
Local Const $aj[1][5] = [[$a2, 'file', Null, $a8, False]]
_vv($8s, $a9)
_vv($8z, $aa)
_vv($90, $ab)
_vv($8w, $ai)
_vv($91, $ai)
_vv($8t, $aj)
_vv($8t, $ac)
_vv($8t, $ai)
_vv($8v, $aj)
_vv($8v, $ac)
_vv($8v, $ai)
_vv($8u, $ac)
_vv($94, $ai)
EndFunc
_10n()
Func _10o()
Local Const $a2 = "adwcleaner"
Local Const $9b = "(?i)^AdwCleaner"
Local Const $ag = "(?i)^Malwarebytes"
Local Const $a5 = "(?i)^AdwCleaner.*\.exe$"
Dim $8s
Dim $8t
Dim $8v
Dim $8x
Local Const $a9[1][2] = [[$a2, $a5]]
Local Const $aa[1][5] = [[$a2, 'file', $ag, $a5, False]]
Local Const $ab[1][5] = [[$a2, 'folder', Null, $9b, True]]
_vv($8s, $a9)
_vv($8t, $aa)
_vv($8v, $aa)
_vv($8x, $ab)
EndFunc
_10o()
Func _10p()
Local Const $ae = Null
Local Const $a2 = "zhpcleaner"
Dim $8s
Dim $8t
Dim $8v
Local Const $a5 = "(?i)^ZHPCleaner.*\.exe$"
Local Const $a6 = "(?i)^ZHPCleaner.*\.(exe|txt|lnk)$"
Local Const $a9[1][2] = [[$a2, $a5]]
Local Const $aa[1][5] = [[$a2, 'file', $ae, $a6, False]]
_vv($8s, $a9)
_vv($8t, $aa)
_vv($8v, $aa)
EndFunc
_10p()
Func _10q()
Local Const $a2 = "usbfix"
Dim $8s
Dim $95
Dim $8t
Dim $8u
Dim $8v
Dim $8y
Dim $8x
Dim $8w
Local Const $9b = "(?i)^UsbFix"
Local Const $ag = "(?i)^SosVirus"
Local Const $a5 = "(?i)^UsbFix.*\.(exe|lnk|txt)$"
Local Const $a6 = "(?i)^Un-UsbFix.exe$"
Local Const $a7 = "(?i)^UsbFixQuarantine$"
Local Const $a8 = "(?i)^UsbFix.*\.exe$"
Local Const $ak[1][2] = [[$a2, $a8]]
Local Const $a9[1][2] = [[$a2, $9b]]
Local Const $aa[1][3] = [[$a2, $9b, $a6]]
Local Const $ab[1][5] = [[$a2, 'file', $ag, $a5, False]]
Local Const $ac[1][5] = [[$a2, 'folder', Null, $a7, True]]
Local Const $ai[1][5] = [[$a2, 'folder', Null, $9b, False]]
_vv($8s, $ak)
_vv($95, $aa)
_vv($8t, $ab)
_vv($8u, $ab)
_vv($8v, $ab)
_vv($8y, $a9)
_vv($8x, $ac)
_vv($8x, $ai)
_vv($8w, $ai)
EndFunc
_10q()
Func _10r()
Local Const $a2 = "adsfix"
Dim $8s
Dim $8t
Dim $8v
Dim $8x
Dim $8u
Dim $8y
Local Const $9b = "(?i)^AdsFix"
Local Const $ag = "(?i)^SosVirus"
Local Const $a5 = "(?i)^AdsFix.*\.exe$"
Local Const $a6 = "(?i)^AdsFix.*\.(exe|txt|lnk)$"
Local Const $a7 = "(?i)^AdsFix.*\.txt$"
Local Const $a9[1][2] = [[$a2, $a5]]
Local Const $aa[1][5] = [[$a2, 'file', $ag, $a6, False]]
Local Const $ab[1][5] = [[$a2, 'file', Null, $a7, False]]
Local Const $ac[1][5] = [[$a2, 'folder', Null, $9b, True]]
Local Const $ai[1][2] = [[$a2, $9b]]
_vv($8s, $a9)
_vv($8t, $aa)
_vv($8u, $aa)
_vv($8v, $aa)
_vv($8x, $ab)
_vv($8x, $ac)
_vv($8y, $ai)
EndFunc
_10r()
Func _10s()
Local Const $a2 = "aswmbr"
Dim $8s
Dim $8t
Dim $8v
Local Const $9b = "(?i)^avast"
Local Const $a5 = "(?i)^aswmbr.*\.(exe|txt|lnk)$"
Local Const $a6 = "(?i)^MBR\.dat$"
Local Const $a7 = "(?i)^aswmbr.*\.exe$"
Local Const $a9[1][2] = [[$a2, $a7]]
Local Const $aa[1][5] = [[$a2, 'file', $9b, $a5, False]]
Local Const $ab[1][5] = [[$a2, 'file', Null, $a6, False]]
_vv($8s, $a9)
_vv($8t, $aa)
_vv($8t, $ab)
_vv($8v, $aa)
EndFunc
_10s()
Func _10t()
Local Const $a2 = "fss"
Dim $8s
Dim $8t
Dim $8v
Local Const $9b = "(?i)^Farbar"
Local Const $a5 = "(?i)^FSS.*\.(exe|txt|lnk)$"
Local Const $a6 = "(?i)^FSS.*\.exe$"
Local Const $a9[1][2] = [[$a2, $a6]]
Local Const $aa[1][5] = [[$a2, 'file', $9b, $a5, False]]
_vv($8s, $a9)
_vv($8t, $aa)
_vv($8v, $aa)
EndFunc
_10t()
Func _10u()
Local Const $a2 = "toolsdiag"
Dim $8s
Dim $8t
Dim $8v
Dim $8x
Local Const $a5 = "(?i)^toolsdiag.*\.exe$"
Local Const $a6 = "(?i)^ToolsDiag$"
Local Const $a9[1][5] = [[$a2, 'folder', Null, $a6, False]]
Local Const $aa[1][5] = [[$a2, 'file', Null, $a5, False]]
Local Const $ab[1][2] = [[$a2, $a5]]
_vv($8s, $ab)
_vv($8t, $aa)
_vv($8v, $aa)
_vv($8x, $a9)
EndFunc
_10u()
Func _10v()
Local Const $a2 = "scanrapide"
Dim $8x
Dim $8t
Dim $8v
Local Const $9b = Null
Local Const $a5 = "(?i)^ScanRapide.*\.exe$"
Local Const $a6 = "(?i)^ScanRapide\[R[0-9]+\]\.txt$"
Local Const $a9[1][5] = [[$a2, 'file', $9b, $a5, False]]
Local Const $aa[1][5] = [[$a2, 'file', Null, $a6, False]]
_vv($8t, $a9)
_vv($8v, $a9)
_vv($8x, $aa)
EndFunc
_10v()
Func _10w()
Local Const $a2 = "otl"
Dim $8s
Dim $8t
Dim $8v
Dim $8x
Local Const $9b = "(?i)^OldTimer"
Local Const $a5 = "(?i)^OTL.*\.exe$"
Local Const $a6 = "(?i)^OTL.*\.(exe|txt)$"
Local Const $a7 = "(?i)^Extras\.txt$"
Local Const $a8 = "(?i)^_OTL$"
Local Const $a9[1][2] = [[$a2, $a5]]
Local Const $aa[1][5] = [[$a2, 'file', $9b, $a6, False]]
Local Const $ab[1][5] = [[$a2, 'file', Null, $a7, False]]
Local Const $ac[1][5] = [[$a2, 'folder', Null, $a8, True]]
_vv($8s, $a9)
_vv($8t, $aa)
_vv($8t, $ab)
_vv($8v, $aa)
_vv($8x, $ac)
EndFunc
_10w()
Func _10x()
Local Const $a2 = "otm"
Dim $8s
Dim $8t
Dim $8v
Dim $8x
Local Const $9b = "(?i)^OldTimer"
Local Const $a5 = "(?i)^OTM.*\.exe$"
Local Const $a6 = "(?i)^_OTM$"
Local Const $a9[1][2] = [[$a2, $a5]]
Local Const $aa[1][5] = [[$a2, 'file', $9b, $a5, False]]
Local Const $ab[1][5] = [[$a2, 'folder', Null, $a6, True]]
_vv($8s, $a9)
_vv($8t, $aa)
_vv($8v, $aa)
_vv($8x, $ab)
EndFunc
_10x()
Func _10y()
Local Const $a2 = "listparts"
Dim $8s
Dim $8t
Dim $8v
Dim $8x
Local Const $9b = "(?i)^Farbar"
Local Const $a5 = "(?i)^listParts.*\.exe$"
Local Const $a6 = "(?i)^Results\.txt$"
Local Const $a9[1][2] = [[$a2, $a5]]
Local Const $aa[1][5] = [[$a2, 'file', $9b, $a5, False]]
Local Const $ab[1][5] = [[$a2, 'file', Null, $a6, False]]
_vv($8s, $a9)
_vv($8t, $aa)
_vv($8t, $ab)
_vv($8v, $aa)
_vv($8v, $ab)
EndFunc
_10y()
Func _10z()
Local Const $a2 = "minitoolbox"
Dim $8s
Dim $8t
Dim $8v
Dim $8x
Local Const $9b = "(?i)^Farbar"
Local Const $a5 = "(?i)^MiniToolBox.*\.exe$"
Local Const $a6 = "(?i)^MTB\.txt$"
Local Const $a9[1][2] = [[$a2, $a5]]
Local Const $aa[1][5] = [[$a2, 'file', $9b, $a5, False]]
Local Const $ab[1][5] = [[$a2, 'file', Null, $a6, False]]
_vv($8s, $a9)
_vv($8t, $aa)
_vv($8t, $ab)
_vv($8v, $aa)
_vv($8v, $ab)
EndFunc
_10z()
Func _110()
Local Const $a2 = "miniregtool"
Dim $8s
Dim $8t
Dim $8v
Dim $8x
Local Const $9b = Null
Local Const $a5 = "(?i)^MiniRegTool.*\.exe$"
Local Const $a6 = "(?i)^MiniRegTool.*\.(exe|zip)$"
Local Const $a7 = "(?i)^Result\.txt$"
Local Const $a8 = "(?i)^MiniRegTool"
Local Const $a9[1][2] = [[$a2, $a5]]
Local Const $aa[1][5] = [[$a2, 'file', $9b, $a6, False]]
Local Const $ab[1][5] = [[$a2, 'file', $9b, $a7, False]]
Local Const $ac[1][5] = [[$a2, 'folder', $9b, $a8, False]]
_vv($8s, $a9)
_vv($8t, $aa)
_vv($8t, $ab)
_vv($8t, $ac)
_vv($8v, $aa)
_vv($8v, $ab)
_vv($8v, $ac)
EndFunc
_110()
Func _111()
Local Const $a2 = "grantperms"
Dim $8s
Dim $8t
Dim $8v
Dim $8x
Local Const $9b = Null
Local Const $a5 = "(?i)^GrantPerms.*\.exe$"
Local Const $a6 = "(?i)^GrantPerms.*\.(exe|zip)$"
Local Const $a7 = "(?i)^Perms\.txt$"
Local Const $a8 = "(?i)^GrantPerms"
Local Const $a9[1][2] = [[$a2, $a5]]
Local Const $aa[1][5] = [[$a2, 'file', $9b, $a6, False]]
Local Const $ab[1][5] = [[$a2, 'file', $9b, $a7, False]]
Local Const $ac[1][5] = [[$a2, 'folder', $9b, $a8, False]]
_vv($8s, $a9)
_vv($8t, $aa)
_vv($8t, $ab)
_vv($8t, $ac)
_vv($8v, $aa)
_vv($8v, $ab)
_vv($8v, $ac)
EndFunc
_111()
Func _112()
Local Const $a2 = "combofix"
Dim $8t
Dim $8v
Dim $8x
Local Const $9b = "(?i)^Swearware"
Local Const $a5 = "(?i)^Combofix.*\.exe$"
Local Const $a6 = "(?i)^CFScript\.txt$"
Local Const $a7 = "(?i)^Qoobox$"
Local Const $a8 = "(?i)^Combofix.*\.txt$"
Local Const $a9[1][5] = [[$a2, 'file', $9b, $a5, False]]
Local Const $aa[1][5] = [[$a2, 'file', Null, $a6, False]]
Local Const $ab[1][5] = [[$a2, 'folder', Null, $a7, True]]
Local Const $ac[1][5] = [[$a2, 'file', Null, $a8, False]]
_vv($8t, $a9)
_vv($8t, $aa)
_vv($8v, $a9)
_vv($8v, $aa)
_vv($8x, $ab)
_vv($8x, $ac)
EndFunc
_112()
Func _113()
Local Const $a2 = "regtoolexport"
Dim $8s
Dim $8t
Dim $8v
Local Const $9b = Null
Local Const $a5 = "(?i)^regtoolexport.*\.exe$"
Local Const $a6 = "(?i)^Export.*\.reg$"
Local Const $a9[1][2] = [[$a2, $a5]]
Local Const $aa[1][5] = [[$a2, 'file', $9b, $a5, False]]
Local Const $ab[1][5] = [[$a2, 'file', $9b, $a6, False]]
_vv($8s, $a9)
_vv($8t, $aa)
_vv($8t, $ab)
_vv($8v, $aa)
_vv($8v, $ab)
EndFunc
_113()
Func _114()
Local Const $a2 = "tdsskiller"
Dim $8s
Dim $8t
Dim $8v
Dim $8x
Local Const $9b = "(?i)^.*Kaspersky"
Local Const $a5 = "(?i)^tdsskiller.*\.exe$"
Local Const $a6 = "(?i)^tdsskiller.*\.(exe|zip)$"
Local Const $a7 = "(?i)^TDSSKiller.*_log\.txt$"
Local Const $a8 = "(?i)^TDSSKiller"
Local Const $a9[1][2] = [[$a2, $a5]]
Local Const $aa[1][5] = [[$a2, 'file', $9b, $a6, False]]
Local Const $ab[1][5] = [[$a2, 'file', Null, $a7, False]]
Local Const $ac[1][5] = [[$a2, 'folder', Null, $a8, False]]
_vv($8s, $a9)
_vv($8t, $aa)
_vv($8t, $ac)
_vv($8v, $aa)
_vv($8v, $ac)
_vv($8x, $ab)
_vv($8x, $ac)
EndFunc
_114()
Func _115()
Local Const $a2 = "winupdatefix"
Dim $8s
Dim $8t
Dim $8v
Dim $8x
Local Const $9b = Null
Local Const $a5 = "(?i)^winupdatefix.*\.exe$"
Local Const $a6 = "(?i)^winupdatefix.*\.txt$"
Local Const $a9[1][2] = [[$a2, $a5]]
Local Const $aa[1][5] = [[$a2, 'file', $9b, $a5, False]]
Local Const $ab[1][5] = [[$a2, 'file', $9b, $a6, False]]
_vv($8s, $a9)
_vv($8t, $aa)
_vv($8v, $aa)
_vv($8x, $ab)
EndFunc
_115()
Func _116()
Local Const $a2 = "rsthosts"
Dim $8s
Dim $8t
Dim $8v
Dim $8x
Local Const $9b = Null
Local Const $a5 = "(?i)^rsthosts.*\.exe$"
Local Const $a6 = "(?i)^RstHosts.*\.txt$"
Local Const $a9[1][2] = [[$a2, $a5]]
Local Const $aa[1][5] = [[$a2, 'file', $9b, $a5, Null]]
Local Const $ab[1][5] = [[$a2, 'file', $9b, $a6, Null]]
_vv($8s, $a9)
_vv($8t, $aa)
_vv($8v, $aa)
_vv($8x, $ab)
EndFunc
_116()
Func _117()
Local Const $a2 = "winchk"
Dim $8s
Dim $8t
Dim $8v
Dim $8x
Local Const $9b = Null
Local Const $a5 = "(?i)^winchk.*\.exe$"
Local Const $a6 = "(?i)^WinChk.*\.txt$"
Local Const $a9[1][2] = [[$a2, $a5]]
Local Const $aa[1][5] = [[$a2, 'file', $9b, $a5, False]]
Local Const $ab[1][5] = [[$a2, 'file', $9b, $a6, False]]
_vv($8s, $a9)
_vv($8t, $aa)
_vv($8v, $aa)
_vv($8x, $ab)
EndFunc
_117()
Func _118()
Local Const $a2 = "avenger"
Dim $8s
Dim $8t
Dim $8v
Dim $8x
Local Const $9b = Null
Local Const $a5 = "(?i)^avenger.*\.(exe|zip)$"
Local Const $a6 = "(?i)^avenger"
Local Const $a7 = "(?i)^avenger.*\.txt$"
Local Const $a8 = "(?i)^avenger.*\.exe$"
Local Const $a9[1][2] = [[$a2, $a8]]
Local Const $aa[1][5] = [[$a2, 'file', $9b, $a5, False]]
Local Const $ab[1][5] = [[$a2, 'folder', $9b, $a6, False]]
Local Const $ac[1][5] = [[$a2, 'file', $9b, $a7, False]]
_vv($8s, $a9)
_vv($8t, $aa)
_vv($8t, $ab)
_vv($8v, $aa)
_vv($8v, $ab)
_vv($8x, $ab)
_vv($8x, $ac)
EndFunc
_118()
Func _119()
Local Const $a2 = "blitzblank"
Dim $8s
Dim $8t
Dim $8v
Dim $8x
Dim $8u
Dim $8y
Local Const $9b = "(?i)^Emsi"
Local Const $a5 = "(?i)^BlitzBlank.*\.exe$"
Local Const $a6 = "(?i)^BlitzBlank.*\.log$"
Local Const $a9[1][2] = [[$a2, $a5]]
Local Const $aa[1][5] = [[$a2, 'file', $9b, $a5, False]]
Local Const $ab[1][5] = [[$a2, 'file', Null, $a6, False]]
_vv($8s, $a9)
_vv($8t, $aa)
_vv($8v, $aa)
_vv($8x, $ab)
EndFunc
_119()
Func _11a()
Local Const $a2 = "zoek"
Dim $8s
Dim $8t
Dim $8v
Dim $8x
Dim $8u
Dim $8y
Local Const $9b = Null
Local Const $a5 = "(?i)^zoek.*\.exe$"
Local Const $a6 = "(?i)^zoek.*\.log$"
Local Const $a7 = "(?i)^zoek"
Local Const $a8 = "(?i)^runcheck.*\.txt$"
Local Const $a9[1][2] = [[$a2, $a5]]
Local Const $aa[1][5] = [[$a2, 'file', $9b, $a5, False]]
Local Const $ab[1][5] = [[$a2, 'file', $9b, $a6, False]]
Local Const $ac[1][5] = [[$a2, 'folder', $9b, $a7, True]]
Local Const $ai[1][5] = [[$a2, 'file', $9b, $a8, False]]
_vv($8s, $a9)
_vv($8t, $aa)
_vv($8v, $aa)
_vv($8x, $ab)
_vv($8x, $ac)
_vv($8x, $ai)
EndFunc
_11a()
Func _11b()
Local Const $a2 = "remediate-vbs-worm"
Dim $8s
Dim $8t
Dim $8v
Dim $8x
Dim $8u
Dim $8y
Local Const $9b = "(?i).*VBS autorun worms.*"
Local Const $ag = Null
Local Const $a5 = "(?i)^remediate.?vbs.?worm.*\.exe$"
Local Const $a6 = "(?i)^Rem-VBS.*\.log$"
Local Const $a7 = "(?i)^Rem-VBS"
Local Const $a9[1][2] = [[$a2, $a5]]
Local Const $aa[1][5] = [[$a2, 'file', $ag, $a5, False]]
Local Const $ab[1][5] = [[$a2, 'file', $ag, $a6, False]]
Local Const $ac[1][5] = [[$a2, 'folder', $9b, $a7, True]]
_vv($8s, $a9)
_vv($8t, $aa)
_vv($8v, $aa)
_vv($8x, $ab)
_vv($8x, $ac)
EndFunc
_11b()
Func _11c()
Local Const $a2 = "ckscanner"
Dim $8s
Dim $8t
Dim $8v
Local Const $9b = Null
Local Const $a5 = "(?i)^CKScanner.*\.exe$"
Local Const $a6 = "(?i)^CKfiles.*\.txt$"
Local Const $a9[1][2] = [[$a2, $a5]]
Local Const $aa[1][5] = [[$a2, 'file', $9b, $a5, False]]
Local Const $ab[1][5] = [[$a2, 'file', $9b, $a6, False]]
_vv($8s, $a9)
_vv($8t, $aa)
_vv($8v, $aa)
_vv($8t, $ab)
_vv($8v, $ab)
EndFunc
_11c()
Func _11d()
Local Const $a2 = "quickdiag"
Dim $8s
Dim $8t
Dim $8v
Dim $8x
Local Const $9b = "(?i)^SosVirus"
Local Const $a5 = "(?i)^QuickDiag.*\.exe$"
Local Const $a6 = "(?i)^QuickDiag.*\.(exe|txt)$"
Local Const $a7 = "(?i)^QuickScript.*\.txt$"
Local Const $a8 = "(?i)^QuickDiag.*\.txt$"
Local Const $al = "(?i)^QuickDiag"
Local Const $a9[1][2] = [[$a2, $a5]]
Local Const $aa[1][5] = [[$a2, 'file', $9b, $a6, True]]
Local Const $ab[1][5] = [[$a2, 'file', Null, $a7, True]]
Local Const $ac[1][5] = [[$a2, 'file', Null, $a8, True]]
Local Const $ai[1][5] = [[$a2, 'folder', Null, $al, True]]
_vv($8s, $a9)
_vv($8t, $aa)
_vv($8v, $aa)
_vv($8t, $ab)
_vv($8v, $ab)
_vv($8x, $ac)
_vv($8x, $ai)
EndFunc
_11d()
Func _11e()
Local $56 = ""
If @OSArch = "X64" Then $56 = "64"
If FileExists(@AppDataDir & "\ZHP") Then
Local Const $am = "kprm-zhp-appdata"
If FileExists(@HomeDrive & "\KPRM\kprm-zhp-appdata.bat") Then
FileDelete(@HomeDrive & "\KPRM\kprm-zhp-appdata.bat")
EndIf
FileWrite(@HomeDrive & "\KPRM\kprm-zhp-appdata.bat", 'schtasks /delete /f /tn "' & $am & '" ' & @CRLF)
FileWrite(@HomeDrive & "\KPRM\kprm-zhp-appdata.bat", "RMDIR /S /Q " & @AppDataDir & "\ZHP " & @CRLF)
FileWrite(@HomeDrive & "\KPRM\kprm-zhp-appdata.bat", "DEL /F /Q " & @HomeDrive & "\KPRM\kprm-zhp-appdata.bat " & @CRLF)
Local $an = _3f(_31('d', 3, _3q()), 2)
$an = StringReplace($an, ".", "/")
$an = StringReplace($an, "-", "/")
Local $ao = _3f(_31('y', 1, _3q()), 2)
$ao = StringReplace($ao, ".", "/")
$ao = StringReplace($ao, "-", "/")
Local $ap = 'schtasks /create /f /tn "kprm-zhp-appdata" /tr ' & @HomeDrive & "\KPRM\kprm-zhp-appdata.bat" & ' /sc MINUTE /mo 5  /st 00:01 /sd ' & $an & ' /ed ' & $ao & ' /RU SYSTEM'
Run($ap, @TempDir, @SW_HIDE)
EndIf
If FileExists(@AppDataCommonDir & "\Malwarebytes\Malwarebytes' Anti-Malware\Quarantine") Then
Local $aq = _x1(@AppDataCommonDir & "\Malwarebytes\Malwarebytes' Anti-Malware\Quarantine")
If @error = 0 Then
For $3x = 1 To $aq[0]
FileDelete(@AppDataCommonDir & "\Malwarebytes\Malwarebytes' Anti-Malware\Quarantine" & '\' & $aq[$3x])
Next
EndIf
EndIf
Local Const $9f[2] = [ "HKLM" & $56 & "\SOFTWARE\Microsoft\Windows\Windows Error Reporting\LocalDumps\RogueKiller.exe", "HKLM" & $56 & "\SOFTWARE\Microsoft\Windows\CurrentVersion\App Paths\combofix.exe"]
For $ar = 0 To UBound($9f) - 1
_107($9f[$ar])
Next
EndFunc
Func _11f($8d = False)
If $8d = True Then
_zi(@CRLF & "- Search Tools -" & @CRLF)
EndIf
_10c($8s)
_zs()
_10e($95)
_zs()
_10d($8z)
_zs()
_106(@DesktopDir, $8t)
_zs()
_106(@DesktopCommonDir, $8u)
_zs()
If FileExists(@UserProfileDir & "\Downloads") Then
_106(@UserProfileDir & "\Downloads", $8v)
_zs()
Else
_zs()
EndIf
_10f($8w)
_zs()
_106(@HomeDrive, $8x)
_zs()
_106(@AppDataDir, $92)
_zs()
_106(@AppDataCommonDir, $91)
_zs()
_106(@LocalAppDataDir, $93)
_zs()
_10g($8y)
_zs()
_10h($90)
_zs()
_106(@AppDataCommonDir & "\Microsoft\Windows\Start Menu\Programs", $94)
_zs()
If $8d = True Then
_11e()
_zs()
For $8q = 0 To UBound($8p) - 1
Local $8r = $8o.Item($8p[$8q])
If $8r[0] > 0 Then
If $8r[1] = "" Then
_zi(@CRLF & "  [OK] " & StringUpper($8p[$8q]) & " has been successfully deleted")
Else
_zi(@CRLF & "  [X] " & StringUpper($8p[$8q]) & " was found but there were errors :")
_zi($8r[1])
EndIf
EndIf
Next
Else
_zs()
EndIf
_zs()
EndFunc
FileInstall("C:\Users\IEUser\Desktop\kpRemover\src\assets\bug.gif", @TempDir & "\kprm-logo.gif")
Global $8h = "KpRm"
Global $98 = False
Global $7m = "kprm-" & @YEAR & @MON & @MDAY & @HOUR & @MIN & ".txt"
Local Const $as = GUICreate($8h, 500, 195, 202, 112)
Local Const $at = GUICtrlCreateGroup("Actions", 8, 8, 400, 153)
Local Const $au = GUICtrlCreateCheckbox($4p, 16, 40, 129, 17)
Local Const $av = GUICtrlCreateCheckbox($4q, 16, 80, 190, 17)
Local Const $aw = GUICtrlCreateCheckbox($4r, 16, 120, 190, 17)
Local Const $ax = GUICtrlCreateCheckbox($4s, 220, 40, 137, 17)
Local Const $ay = GUICtrlCreateCheckbox($4t, 220, 80, 137, 17)
Local Const $az = GUICtrlCreateCheckbox($4u, 220, 120, 180, 17)
Global $84 = GUICtrlCreateProgress(8, 170, 480, 17)
GUICtrlCreateGroup("", -99, -99, 1, 1)
guictrlsetstate($au, 1)
Local Const $b0 = GUICtrlCreatePic(@TempDir & "\kprm-logo.gif", 415, 16, 76, 76)
Local Const $b1 = GUICtrlCreateButton($4v, 415, 120, 75, 40)
GUISetState(@SW_SHOW)
While 1
Local $b2 = GUIGetMsg()
Switch $b2
Case $0
Exit
Case $b1
_11i()
EndSwitch
WEnd
Func _11g()
Local Const $b3 = @HomeDrive & "\KPRM"
If Not FileExists($b3) Then
DirCreate($b3)
EndIf
If Not FileExists($b3) Then
MsgBox(16, $4x, $4y)
Exit
EndIf
EndFunc
Func _11h()
_11g()
_zi("#################################################################################################################" & @CRLF)
_zi("# Run at " & _3o())
_zi("# Run by " & @UserName & " in " & @ComputerName)
_zi("# Launch from " & @WorkingDir)
_zt()
EndFunc
Func _11i()
_11h()
_zs()
If GUICtrlRead($ax) = $1 Then
_0zz()
EndIf
_zs()
If GUICtrlRead($au) = $1 Then
_11f()
_11f(True)
Else
_zs(32)
EndIf
_zs()
If GUICtrlRead($az) = $1 Then
_101()
EndIf
_zs()
If GUICtrlRead($ay) = $1 Then
_100()
EndIf
_zs()
If GUICtrlRead($av) = $1 Then
_zu()
EndIf
_zs()
If GUICtrlRead($aw) = $1 Then
_zy()
EndIf
GUICtrlSetData($84, 100)
MsgBox(64, "OK", $4w)
Exit
EndFunc
