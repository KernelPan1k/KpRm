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
Func _y1($5a)
Local Const $5b = 64
#forceref $5b
Local Const $5c = 256
Local Const $5d = 100
Local Const $5e = 12
Local $5f = DllStructCreate('DWORD dwEventType;DWORD dwRestorePtType;INT64 llSequenceNumber;WCHAR szDescription[' & $5c & ']')
DllStructSetData($5f, 'dwEventType', $5d)
DllStructSetData($5f, 'dwRestorePtType', $5e)
DllStructSetData($5f, 'llSequenceNumber', 0)
DllStructSetData($5f, 'szDescription', $5a)
Local $5g = DllStructGetPtr($5f)
Local $5h = DllStructCreate('UINT  nStatus;INT64 llSequenceNumber')
Local $5i = DllStructGetPtr($5h)
Local $q = DllCall('SrClient.dll', 'BOOL', 'SRSetRestorePointW', 'ptr', $5g, 'ptr', $5i)
If @error Then Return 0
Return $q[0]
EndFunc
Func _y2()
Local $5j[1][3], $5k = 0
$5j[0][0] = $5k
If Not IsObj($58) Then $58 = ObjGet("winmgmts:root/default")
If Not IsObj($58) Then Return $5j
Local $5l = $58.InstancesOf("SystemRestore")
If Not IsObj($5l) Then Return $5j
For $5m In $5l
$5k += 1
ReDim $5j[$5k + 1][3]
$5j[$5k][0] = $5m.SequenceNumber
$5j[$5k][1] = $5m.Description
$5j[$5k][2] = _y3($5m.CreationTime)
Next
$5j[0][0] = $5k
Return $5j
EndFunc
Func _y3($5n)
Return(StringMid($5n, 5, 2) & "/" & StringMid($5n, 7, 2) & "/" & StringLeft($5n, 4) & " " & StringMid($5n, 9, 2) & ":" & StringMid($5n, 11, 2) & ":" & StringMid($5n, 13, 2))
EndFunc
Func _y4($5o)
Local $q = DllCall('SrClient.dll', 'DWORD', 'SRRemoveRestorePoint', 'DWORD', $5o)
If @error Then Return SetError(1, 0, 0)
If $q[0] = 0 Then Return 1
Return SetError(1, 0, 0)
EndFunc
Func _y6($5p = $59)
If Not IsObj($57) Then $57 = ObjGet("winmgmts:{impersonationLevel=impersonate}!root/default:SystemRestore")
If Not IsObj($57) Then Return 0
If $57.Enable($5p) = 0 Then Return 1
Return 0
EndFunc
Global Enum $5q = 0, $5r, $5s, $5t, $5u, $5v, $5w, $5x, $5y, $5z, $60, $61, $62
Global Const $63 = 2
Global $64 = @SystemDir&'\Advapi32.dll'
Global $65 = @SystemDir&'\Kernel32.dll'
Global $66[4][2], $67[4][2]
Global $68 = 0
Func _y9()
$64 = DllOpen(@SystemDir&'\Advapi32.dll')
$65 = DllOpen(@SystemDir&'\Kernel32.dll')
$66[0][0] = "SeRestorePrivilege"
$66[0][1] = 2
$66[1][0] = "SeTakeOwnershipPrivilege"
$66[1][1] = 2
$66[2][0] = "SeDebugPrivilege"
$66[2][1] = 2
$66[3][0] = "SeSecurityPrivilege"
$66[3][1] = 2
$67 = _zh($66)
$68 = 1
EndFunc
Func _yf($69, $6a = $5r, $6b = 'Administrators', $6c = 1)
Local $6d[1][3]
$6d[0][0] = 'Everyone'
$6d[0][1] = 1
$6d[0][2] = $l
Return _yi($69, $6d, $6a, $6b, 1, $6c)
EndFunc
Func _yi($69, $6e, $6a = $5r, $6b = '', $6f = 0, $6c = 0, $6g = 3)
If $68 = 0 Then _y9()
If Not IsArray($6e) Or UBound($6e,2) < 3 Then Return SetError(1,0,0)
Local $6h = _yn($6e,$6g)
Local $6i = @extended
Local $6j = 4, $6k = 0
If $6b <> '' Then
If Not IsDllStruct($6b) Then $6b = _za($6b)
$6k = DllStructGetPtr($6b)
If $6k And _zg($6k) Then
$6j = 5
Else
$6k = 0
EndIf
EndIf
If Not IsPtr($69) And $6a = $5r Then
Return _yv($69, $6h, $6k, $6f, $6c, $6i, $6j)
ElseIf Not IsPtr($69) And $6a = $5u Then
Return _yw($69, $6h, $6k, $6f, $6c, $6i, $6j)
Else
If $6f Then _yx($69,$6a)
Return _yo($69, $6a, $6j, $6k, 0, $6h,0)
EndIf
EndFunc
Func _yn(ByRef $6e, ByRef $6g)
Local $6l = UBound($6e,2)
If Not IsArray($6e) Or $6l < 3 Then Return SetError(1,0,0)
Local $6m = UBound($6e), $6n[$6m], $6o = 0, $6p = 1
Local $6q, $6i = 0, $6r
Local $6s, $6t = 'DWORD;DWORD;DWORD;ptr;DWORD;DWORD;DWORD;ptr'
For $3x = 1 To $6m - 1
$6t &= ';DWORD;DWORD;DWORD;ptr;DWORD;DWORD;DWORD;ptr'
Next
$6s = DllStructCreate($6t)
For $3x = 0 To $6m -1
If Not IsDllStruct($6e[$3x][0]) Then $6e[$3x][0] = _za($6e[$3x][0])
$6n[$3x] = DllStructGetPtr($6e[$3x][0])
If Not _zg($6n[$3x]) Then ContinueLoop
DllStructSetData($6s,$6o+1,$6e[$3x][2])
If $6e[$3x][1] = 0 Then
$6i = 1
$6q = $8
Else
$6q = $7
EndIf
If $6l > 3 Then $6g = $6e[$3x][3]
DllStructSetData($6s,$6o+2,$6q)
DllStructSetData($6s,$6o+3,$6g)
DllStructSetData($6s,$6o+6,0)
$6r = DllCall($64,'BOOL','LookupAccountSid','ptr',0,'ptr',$6n[$3x],'ptr*',0,'dword*',32,'ptr*',0,'dword*',32,'dword*',0)
If Not @error Then $6p = $6r[7]
DllStructSetData($6s,$6o+7,$6p)
DllStructSetData($6s,$6o+8,$6n[$3x])
$6o += 8
Next
Local $6u = DllStructGetPtr($6s)
$6r = DllCall($64,'DWORD','SetEntriesInAcl','ULONG',$6m,'ptr',$6u ,'ptr',0,'ptr*',0)
If @error Or $6r[0] Then Return SetError(1,0,0)
Return SetExtended($6i, $6r[4])
EndFunc
Func _yo($69, $6a, $6j, $6k = 0, $6v = 0, $6h = 0, $6w = 0)
Local $6r
If $68 = 0 Then _y9()
If $6h And Not _yp($6h) Then Return 0
If $6w And Not _yp($6w) Then Return 0
If IsPtr($69) Then
$6r = DllCall($64,'dword','SetSecurityInfo','handle',$69,'dword',$6a, 'dword',$6j,'ptr',$6k,'ptr',$6v,'ptr',$6h,'ptr',$6w)
Else
If $6a = $5u Then $69 = _zb($69)
$6r = DllCall($64,'dword','SetNamedSecurityInfo','str',$69,'dword',$6a, 'dword',$6j,'ptr',$6k,'ptr',$6v,'ptr',$6h,'ptr',$6w)
EndIf
If @error Then Return SetError(1,0,0)
If $6r[0] And $6k Then
If _z0($69, $6a,_zf($6k)) Then Return _yo($69, $6a, $6j - 1, 0, $6v, $6h, $6w)
EndIf
Return SetError($6r[0] , 0, Number($6r[0] = 0))
EndFunc
Func _yp($6x)
If $6x = 0 Then Return SetError(1,0,0)
Local $6r = DllCall($64,'bool','IsValidAcl','ptr',$6x)
If @error Or Not $6r[0] Then Return 0
Return 1
EndFunc
Func _yv($69, ByRef $6h, ByRef $6k, ByRef $6f, ByRef $6c, ByRef $6i, ByRef $6j)
Local $6y, $6z
If Not $6i Then
If $6f Then _yx($69,$5r)
$6y = _yo($69, $5r, $6j, $6k, 0, $6h,0)
EndIf
If $6c Then
Local $70 = FileFindFirstFile($69&'\*')
While 1
$6z = FileFindNextFile($70)
If $6c = 1 Or $6c = 2 And @extended = 1 Then
_yv($69&'\'&$6z, $6h, $6k, $6f, $6c, $6i,$6j)
ElseIf @error Then
ExitLoop
ElseIf $6c = 1 Or $6c = 3 Then
If $6f Then _yx($69&'\'&$6z,$5r)
_yo($69&'\'&$6z, $5r, $6j, $6k, 0, $6h,0)
EndIf
WEnd
FileClose($70)
EndIf
If $6i Then
If $6f Then _yx($69,$5r)
$6y = _yo($69, $5r, $6j, $6k, 0, $6h,0)
EndIf
Return $6y
EndFunc
Func _yw($69, ByRef $6h, ByRef $6k, ByRef $6f, ByRef $6c, ByRef $6i, ByRef $6j)
If $68 = 0 Then _y9()
Local $6y, $3x = 0, $6z
If Not $6i Then
If $6f Then _yx($69,$5u)
$6y = _yo($69, $5u, $6j, $6k, 0, $6h,0)
EndIf
If $6c Then
While 1
$3x += 1
$6z = RegEnumKey($69,$3x)
If @error Then ExitLoop
_yw($69&'\'&$6z, $6h, $6k, $6f, $6c, $6i, $6j)
WEnd
EndIf
If $6i Then
If $6f Then _yx($69,$5u)
$6y = _yo($69, $5u, $6j, $6k, 0, $6h,0)
EndIf
Return $6y
EndFunc
Func _yx($69, $6a = $5r)
If $68 = 0 Then _y9()
Local $71 = DllStructCreate('byte[32]'), $q
Local $6h = DllStructGetPtr($71,1)
DllCall($64,'bool','InitializeAcl','Ptr',$6h,'dword',DllStructGetSize($71),'dword',$63)
If IsPtr($69) Then
$q = DllCall($64,"dword","SetSecurityInfo",'handle',$69,'dword',$6a,'dword',4,'ptr',0,'ptr',0,'ptr',$6h,'ptr',0)
Else
If $6a = $5u Then $69 = _zb($69)
DllCall($64,'DWORD','SetNamedSecurityInfo','str',$69,'dword',$6a,'DWORD',4,'ptr',0,'ptr',0,'ptr',0,'ptr',0)
$q = DllCall($64,'DWORD','SetNamedSecurityInfo','str',$69,'dword',$6a,'DWORD',4,'ptr',0,'ptr',0,'ptr',$6h,'ptr',0)
EndIf
If @error Then Return SetError(@error,0,0)
Return SetError($q[0],0,Number($q[0] = 0))
EndFunc
Func _z0($69, $6a = $5r, $72 = 'Administrators')
If $68 = 0 Then _y9()
Local $73 = _za($72), $q
Local $6n = DllStructGetPtr($73)
If IsPtr($69) Then
$q = DllCall($64,"dword","SetSecurityInfo",'handle',$69,'dword',$6a,'dword',1,'ptr',$6n,'ptr',0,'ptr',0,'ptr',0)
Else
If $6a = $5u Then $69 = _zb($69)
$q = DllCall($64,'DWORD','SetNamedSecurityInfo','str',$69,'dword',$6a,'DWORD',1,'ptr',$6n,'ptr',0,'ptr',0,'ptr',0)
EndIf
If @error Then Return SetError(@error,0,False)
Return SetError($q[0],0,Number($q[0] = 0))
EndFunc
Func _za($72)
If $72 = 'TrustedInstaller' Then $72 = 'NT SERVICE\TrustedInstaller'
If $72 = 'Everyone' Then
Return _zd('S-1-1-0')
ElseIf $72 = 'Authenticated Users' Then
Return _zd('S-1-5-11')
ElseIf $72 = 'System' Then
Return _zd('S-1-5-18')
ElseIf $72 = 'Administrators' Then
Return _zd('S-1-5-32-544')
ElseIf $72 = 'Users' Then
Return _zd('S-1-5-32-545')
ElseIf $72 = 'Guests' Then
Return _zd('S-1-5-32-546')
ElseIf $72 = 'Power Users' Then
Return _zd('S-1-5-32-547')
ElseIf $72 = 'Local Authority' Then
Return _zd('S-1-2')
ElseIf $72 = 'Creator Owner' Then
Return _zd('S-1-3-0')
ElseIf $72 = 'NT Authority' Then
Return _zd('S-1-5-1')
ElseIf $72 = 'Restricted' Then
Return _zd('S-1-5-12')
ElseIf StringRegExp($72,'\A(S-1-\d+(-\d+){0,5})\z') Then
Return _zd($72)
Else
Local $73 = _zc($72)
Return _zd($73)
EndIf
EndFunc
Func _zb($74)
If StringInStr($74,'\\') = 1 Then
$74 = StringRegExpReplace($74,'(?i)\\(HKEY_CLASSES_ROOT|HKCR)','\CLASSES_ROOT')
$74 = StringRegExpReplace($74,'(?i)\\(HKEY_CURRENT_USER|HKCU)','\CURRENT_USER')
$74 = StringRegExpReplace($74,'(?i)\\(HKEY_LOCAL_MACHINE|HKLM)','\MACHINE')
$74 = StringRegExpReplace($74,'(?i)\\(HKEY_USERS|HKU)','\USERS')
Else
$74 = StringRegExpReplace($74,'(?i)\A(HKEY_CLASSES_ROOT|HKCR)','CLASSES_ROOT')
$74 = StringRegExpReplace($74,'(?i)\A(HKEY_CURRENT_USER|HKCU)','CURRENT_USER')
$74 = StringRegExpReplace($74,'(?i)\A(HKEY_LOCAL_MACHINE|HKLM)','MACHINE')
$74 = StringRegExpReplace($74,'(?i)\A(HKEY_USERS|HKU)','USERS')
EndIf
Return $74
EndFunc
Func _zc($75, $76 = "")
Local $77 = DllStructCreate("byte SID[256]")
Local $6n = DllStructGetPtr($77, "SID")
Local $2k = DllCall($64, "bool", "LookupAccountNameW", "wstr", $76, "wstr", $75, "ptr", $6n, "dword*", 256, "wstr", "", "dword*", 256, "int*", 0)
If @error Then Return SetError(@error, @extended, 0)
If Not $2k[0] Then Return 0
Return _zf($6n)
EndFunc
Func _zd($78)
Local $2k = DllCall($64, "bool", "ConvertStringSidToSidW", "wstr", $78, "ptr*", 0)
If @error Then Return SetError(@error, @extended, 0)
If Not $2k[0] Then Return 0
Local $79 = _ze($2k[2])
Local $3b = DllStructCreate("byte Data[" & $79 & "]", $2k[2])
Local $7a = DllStructCreate("byte Data[" & $79 & "]")
DllStructSetData($7a, "Data", DllStructGetData($3b, "Data"))
DllCall($65, "ptr", "LocalFree", "ptr", $2k[2])
Return $7a
EndFunc
Func _ze($6n)
If Not _zg($6n) Then Return SetError(-1, 0, "")
Local $2k = DllCall($64, "dword", "GetLengthSid", "ptr", $6n)
If @error Then Return SetError(@error, @extended, 0)
Return $2k[0]
EndFunc
Func _zf($6n)
If Not _zg($6n) Then Return SetError(-1, 0, "")
Local $2k = DllCall($64, "int", "ConvertSidToStringSidW", "ptr", $6n, "ptr*", 0)
If @error Then Return SetError(@error, @extended, "")
If Not $2k[0] Then Return ""
Local $3b = DllStructCreate("wchar Text[256]", $2k[2])
Local $78 = DllStructGetData($3b, "Text")
DllCall($65, "ptr", "LocalFree", "ptr", $2k[2])
Return $78
EndFunc
Func _zg($6n)
Local $2k = DllCall($64, "bool", "IsValidSid", "ptr", $6n)
If @error Then Return SetError(@error, @extended, False)
Return $2k[0]
EndFunc
Func _zh($7b)
Local $7c = UBound($7b, 0), $7d[1][2]
If Not($7c <= 2 And UBound($7b, $7c) = 2 ) Then Return SetError(1300, 0, $7d)
If $7c = 1 Then
Local $7e[1][2]
$7e[0][0] = $7b[0]
$7e[0][1] = $7b[1]
$7b = $7e
$7e = 0
EndIf
Local $7f, $7g = "dword", $7h = UBound($7b, 1)
Do
$7f += 1
$7g &= ";dword;long;dword"
Until $7f = $7h
Local $7i, $7j, $7k, $7l, $7m, $7n, $7o
$7i = DLLStructCreate($7g)
$7j = DllStructCreate($7g)
$7k = DllStructGetPtr($7j)
$7l = DllStructCreate("dword;long")
DLLStructSetData($7i, 1, $7h)
For $3x = 0 To $7h - 1
DllCall($64, "int", "LookupPrivilegeValue", "str", "", "str", $7b[$3x][0], "ptr", DllStructGetPtr($7l) )
DLLStructSetData( $7i, 3 * $3x + 2, DllStructGetData($7l, 1) )
DLLStructSetData( $7i, 3 * $3x + 3, DllStructGetData($7l, 2) )
DLLStructSetData( $7i, 3 * $3x + 4, $7b[$3x][1] )
Next
$7m = DllCall($65, "hwnd", "GetCurrentProcess")
$7n = DllCall($64, "int", "OpenProcessToken", "hwnd", $7m[0], "dword", BitOR(0x00000020, 0x00000008), "hwnd*", 0 )
DllCall( $64, "int", "AdjustTokenPrivileges", "hwnd", $7n[3], "int", False, "ptr", DllStructGetPtr($7i), "dword", DllStructGetSize($7i), "ptr", $7k, "dword*", 0 )
$7o = DllCall($65, "dword", "GetLastError")
DllCall($65, "int", "CloseHandle", "hwnd", $7n[3])
Local $7p = DllStructGetData($7j, 1)
If $7p > 0 Then
Local $7q, $7r, $7s, $7d[$7p][2]
For $3x = 0 To $7p - 1
$7q = $7k + 12 * $3x + 4
$7r = DllCall($64, "int", "LookupPrivilegeName", "str", "", "ptr", $7q, "ptr", 0, "dword*", 0 )
$7s = DllStructCreate("char[" & $7r[4] & "]")
DllCall($64, "int", "LookupPrivilegeName", "str", "", "ptr", $7q, "ptr", DllStructGetPtr($7s), "dword*", DllStructGetSize($7s) )
$7d[$3x][0] = DllStructGetData($7s, 1)
$7d[$3x][1] = DllStructGetData($7j, 3 * $3x + 4)
Next
EndIf
Return SetError($7o[0], 0, $7d)
EndFunc
If Not IsAdmin() Then
MsgBox(16, $4x, $4z)
Exit
EndIf
Local $7t = ProcessList("mbar.exe")
If $7t[0][0] > 0 Then
MsgBox(16, $4x, $50)
Exit
EndIf
Func _zi($7u)
Dim $7v
FileWrite(@DesktopDir & "\" & $7v, $7u & @CRLF)
FileWrite(@HomeDrive & "\KPRM" & "\" & $7v, $7u & @CRLF)
EndFunc
Func _zj()
Local $7w = 100, $7x = 100, $7y = 0, $7z = @WindowsDir & "\Explorer.exe"
_hf($2t, 0, 0, 0)
Local $80 = _d0("Shell_TrayWnd", "")
_51($80, 1460, 0, 0)
While ProcessExists("Explorer.exe")
Sleep(10)
$7w -= ProcessClose("Explorer.exe") ? 0 : 1
If $7w < 1 Then Return SetError(1, 0, 0)
WEnd
While(Not ProcessExists("Explorer.exe"))
If Not FileExists($7z) Then Return SetError(-1, 0, 0)
Sleep(500)
$7y = ShellExecute($7z)
$7x -= $7y ? 0 : 1
If $7x < 1 Then Return SetError(2, 0, 0)
WEnd
Return $7y
EndFunc
Func _zm($81, $82, $83)
Local $3x = 0
While True
$3x += 1
Local $84 = RegEnumKey($81, $3x)
If @error <> 0 Then ExitLoop
Local $85 = $81 & "\" & $84
Local $6z = RegRead($85, $83)
If StringRegExp($6z, $82) Then
Return $85
EndIf
WEnd
Return Null
EndFunc
Func _zo()
Local $86 = []
If FileExists(@HomeDrive & "\Program Files") Then
_vv($86, @HomeDrive & "\Program Files")
EndIf
If FileExists(@HomeDrive & "\Program Files (x86)") Then
_vv($86, @HomeDrive & "\Program Files (x86)")
EndIf
If FileExists(@HomeDrive & "\Program Files(x86)") Then
_vv($86, @HomeDrive & "\Program Files(x86)")
EndIf
Return $86
EndFunc
Func _zp($4f)
Return Int(FileExists($4f) And StringInStr(FileGetAttrib($4f), 'D', Default, 1) = 0)
EndFunc
Func _zq($4f)
Return Int(FileExists($4f) And StringInStr(FileGetAttrib($4f), 'D', Default, 1) > 0)
EndFunc
Func _zr($4f)
Local $87 = Null
If FileExists($4f) Then
Local $88 = StringInStr(FileGetAttrib($4f), 'D', Default, 1)
If $88 = 0 Then
$87 = 'file'
ElseIf $88 > 0 Then
$87 = 'folder'
EndIf
EndIf
Return $87
EndFunc
Local $89 = 39
Local $8a
Local Const $8b = Floor(100 / $89)
Func _zs($8c = 1)
$8a += $8c
Dim $8d
GUICtrlSetData($8d, $8a * $8b)
If $8a = $89 Then
GUICtrlSetData($8d, 100)
EndIf
EndFunc
Func _zt()
$8a = 0
Dim $8d
GUICtrlSetData($8d, 0)
EndFunc
Func _zu()
_zi(@CRLF & "- Clear All System Restore Points -" & @CRLF)
Local Const $8e = _y2()
Local $6y = 0
If $8e[0][0] = 0 Then
_zi("  [I] No system recovery points were found")
Return Null
EndIf
Local $8f[1][2] = [[Null, Null]]
For $3x = 1 To $8e[0][0]
Local $8g = _y4($8e[$3x][0])
$6y += $8g
If $8g = 1 Then
_zi("    => [OK] RP named " & $8e[$3x][1] & " has been successfully deleted")
ElseIf UBound($8e[$3x]) = 3 Then
Local $8h[1][2] = [[$8e[$3x][0], $8e[$3x][1]]]
_vv($8f, $8h)
Else
_zi("    => [X] RP named " & $8e[$3x][1] & " has not been successfully deleted")
EndIf
Next
If 1 < UBound($8f) Then
Sleep(3000)
For $3x = 1 To UBound($8f) - 1
Local $8g = _y4($8f[$3x][0])
$6y += $8g
If $8g = 1 Then
_zi("    => [OK] RP named " & $8f[$3x][1] & " has been successfully deleted")
Else
_zi("    => [X] RP named " & $8f[$3x][1] & " has not been successfully deleted")
EndIf
Next
EndIf
If $8e[0][0] = $6y Then
_zi("  [OK] All system restore points have been successfully deleted")
Else
_zi("  [X] Failure when deleting all restore points")
EndIf
EndFunc
Func _zv($5n)
Local $8i = StringLeft($5n, 4)
Local $8j = StringMid($5n, 6, 2)
Local $8k = StringMid($5n, 9, 2)
Local $8l = StringRight($5n, 8)
Return $8j & "/" & $8k & "/" & $8i & " " & $8l
EndFunc
Func _zw($8m = False)
Local Const $8e = _y2()
If $8e[0][0] = 0 Then
Return Null
EndIf
Local Const $8n = _zv(_31('h', -25, _3p()))
For $3x = 1 To $8e[0][0]
Local $8o = $8e[$3x][2]
If $8o > $8n Then
Local $8g = _y4($8e[$3x][0])
If $8g = 1 Then
_zi("    => [OK] RP named " & $8e[$3x][1] & " has been successfully deleted")
Return True
ElseIf $8m = False Then
Sleep(3000)
_zw(True)
Else
_zi("  [X] Failure when deleting restore point " & $8e[$3x][1])
Return False
EndIf
EndIf
Next
EndFunc
Func _zx($8m = False)
If $8m = False Then
_zi(@CRLF & "- Create New System Restore Point -" & @CRLF)
Else
_zi("  [I] Retry Create New System Restore Point")
EndIf
Dim $8p
Local $8q = _y6()
If $8q = 0 Then
Sleep(3000)
$8q = _y6()
If $8q = 0 Then
_zi("  [X] Failed to enable System Restore")
EndIf
ElseIf $8q = 1 Then
_zi("  [OK] System Restore enabled successfully")
EndIf
_zw()
Sleep(1000)
Local Const $8r = _y1($8p)
If $8r <> 1 Then
_zi("  [X] Failed to create System Restore Point!")
If $8m = False Then
_zx(True)
Return
EndIf
ElseIf $8r = 1 Then
_zi("  [OK] System Restore Point successfully created")
EndIf
EndFunc
Func _zy()
_zi(@CRLF & "- Create Registry Backup -" & @CRLF)
Local Const $8s = @HomeDrive & "\KPRM"
Local Const $8t = $8s & "\regedit-backup-" & @YEAR & @MON & @MDAY & @HOUR & @MIN & ".reg"
If FileExists($8t) Then
FileMove($8t, $8t & ".old")
EndIf
Local Const $8g = RunWait("Regedit /e " & $8t)
If Not FileExists($8t) Or @error <> 0 Then
_zi("  [X] Failed to create registry backup")
MsgBox(16, $4x, $4y)
Exit
Else
_zi("  [OK] Registry Backup created successfully at " & $8t)
EndIf
EndFunc
Func _0zz()
_zi(@CRLF & "- Restore UAC Default Value -" & @CRLF)
Local $8g = _xr()
If $8g = 1 Then
_zi("  [OK] Set ConsentPromptBehaviorAdmin with default value successfully.")
Else
_zi("  [X] Set ConsentPromptBehaviorAdmin with default value failed")
EndIf
Local $8g = _xs()
If $8g = 1 Then
_zi("  [OK] Set ConsentPromptBehaviorUser with default value successfully.")
Else
_zi("  [X] Set ConsentPromptBehaviorUser with default value failed")
EndIf
Local $8g = _xt()
If $8g = 1 Then
_zi("  [OK] Set EnableInstallerDetection with default value successfully.")
Else
_zi("  [X] Set EnableInstallerDetection with default value failed")
EndIf
Local $8g = _xu()
If $8g = 1 Then
_zi("  [OK] Set EnableLUA with default value successfully.")
Else
_zi("  [X] Set EnableLUA with default value failed")
EndIf
Local $8g = _xv()
If $8g = 1 Then
_zi("  [OK] Set EnableSecureUIAPaths with default value successfully.")
Else
_zi("  [X] Set EnableSecureUIAPaths with default value failed")
EndIf
Local $8g = _xw()
If $8g = 1 Then
_zi("  [OK] Set EnableUIADesktopToggle with default value successfully.")
Else
_zi("  [X] Set EnableUIADesktopToggle with default value failed")
EndIf
Local $8g = _xx()
If $8g = 1 Then
_zi("  [OK] Set EnableVirtualization with default value successfully.")
Else
_zi("  [X] Set EnableVirtualization with default value failed")
EndIf
Local $8g = _xy()
If $8g = 1 Then
_zi("  [OK] Set FilterAdministratorToken with default value successfully.")
Else
_zi("  [X] Set FilterAdministratorToken with default value failed")
EndIf
Local $8g = _xz()
If $8g = 1 Then
_zi("  [OK] Set PromptOnSecureDesktop with default value successfully.")
Else
_zi("  [X] Set PromptOnSecureDesktop with default value failed")
EndIf
Local $8g = _y0()
If $8g = 1 Then
_zi("  [OK] Set ValidateAdminCodeSignatures with default value successfully.")
Else
_zi("  [X] Set ValidateAdminCodeSignatures with default value failed")
EndIf
EndFunc
Func _100()
_zi(@CRLF & "- Restore Default System Settings -" & @CRLF)
Local $8g = RunWait(@ComSpec & " /c " & "ipconfig /flushdns", @TempDir, @SW_HIDE)
If @error <> 0 Then
_zi("  [X] Flush DNS failure")
Else
_zi("  [OK] Flush DNS successfully completed")
EndIf
Local Const $8u[7] = [ "netsh winsock reset", "netsh winhttp reset proxy", "netsh winhttp reset tracing", "netsh winsock reset catalog", "netsh int ip reset all", "netsh int ipv4 reset catalog", "netsh int ipv6 reset catalog" ]
$8g = 0
For $3x = 0 To UBound($8u) -1
RunWait(@ComSpec & " /c " & $8u[$3x], @TempDir, @SW_HIDE)
If @error <> 0 Then
$8g += 1
EndIf
Next
If $8g = 0 Then
_zi("  [OK] Reset WinSock successfully completed")
Else
_zi("  [X] Reset WinSock failure")
EndIf
Local $8v = "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced"
$8g = RegWrite($8v, "Hidden", "REG_DWORD", "2")
If $8g = 1 Then
_zi("  [OK] Hide Hidden file successfully.")
Else
_zi("  [X] Hide Hidden File failure")
EndIf
$8g = RegWrite($8v, "HideFileExt", "REG_DWORD", "1")
If $8g = 1 Then
_zi("  [OK] Hide Extensions for known file types successfully.")
Else
_zi("  [X] Hide Extensions for known file types failure")
EndIf
$8g = RegWrite($8v, "ShowSuperHidden", "REG_DWORD", "0")
If $8g = 1 Then
_zi("  [OK] Hide protected operating system files successfully.")
Else
_zi("  [X] Hide protected operating system files failure")
EndIf
_zj()
EndFunc
Global $8w = ObjCreate("Scripting.Dictionary")
Local Const $8x[32] = [ "frst", "zhpdiag", "zhpcleaner", "zhpfix", "mbar", "roguekiller", "usbfix", "adwcleaner", "adsfix", "aswmbr", "fss", "toolsdiag", "scanrapide", "otl", "otm", "listparts", "minitoolbox", "miniregtool", "zhp", "combofix", "regtoolexport", "tdsskiller", "winupdatefix", "rsthosts", "winchk", "avenger", "blitzblank", "zoek", "remediate-vbs-worm", "ckscanner", "quickdiag", "grantperms"]
For $8y = 0 To UBound($8x) - 1
Local $8z[2] = [0, ""]
$8w.add($8x[$8y], $8z)
Next
Global $90[1][2] = [[Null, Null]]
Global $91[1][5] = [[Null, Null, Null, Null, Null]]
Global $92[1][5] = [[Null, Null, Null, Null, Null]]
Global $93[1][5] = [[Null, Null, Null, Null, Null]]
Global $94[1][5] = [[Null, Null, Null, Null, Null]]
Global $95[1][5] = [[Null, Null, Null, Null, Null]]
Global $96[1][2] = [[Null, Null]]
Global $97[1][2] = [[Null, Null]]
Global $98[1][4] = [[Null, Null, Null, Null]]
Global $99[1][5] = [[Null, Null, Null, Null, Null]]
Global $9a[1][5] = [[Null, Null, Null, Null, Null]]
Global $9b[1][5] = [[Null, Null, Null, Null, Null]]
Global $9c[1][5] = [[Null, Null, Null, Null, Null]]
Global $9d[1][3] = [[Null, Null, Null]]
Func _101($81, $9e = 0, $9f = False)
Dim $9g
If $9g Then _zi("[I] prepareRemove " & $81)
If $9f Then
_yx($81)
_yf($81)
EndIf
Local Const $9h = FileGetAttrib($81)
If StringInStr($9h, "R") Then
FileSetAttrib($81, "-R", $9e)
EndIf
If StringInStr($9h, "S") Then
FileSetAttrib($81, "-S", $9e)
EndIf
If StringInStr($9h, "H") Then
FileSetAttrib($81, "-H", $9e)
EndIf
If StringInStr($9h, "A") Then
FileSetAttrib($81, "-A", $9e)
EndIf
EndFunc
Func _102($9i, $9j = Null, $9f = False)
Dim $9g
If $9g Then _zi("[I] RemoveFile " & $9i)
Local Const $9k = _zp($9i)
If $9k Then
If $9j And StringRegExp($9i, "(?i)\.exe$") Then
Local Const $9l = FileGetVersion($9i, "CompanyName")
If @error Then
Return 0
ElseIf Not StringRegExp($9l, $9j) Then
Return 0
EndIf
EndIf
_101($9i, 0, $9f)
Local $9m = FileDelete($9i)
If $9m Then
If $9g Then
_zi("  [OK] File " & $9i & " deleted successfully")
EndIf
Return 1
EndIf
Return 2
EndIf
Return 0
EndFunc
Func _103($81, $9f = False)
Dim $9g
If $9g Then _zi("[I] RemoveFolder " & $81)
Local $9k = _zq($81)
If $9k Then
_101($81, 1, $9f)
Local Const $9m = DirRemove($81, $k)
If $9m Then
If $9g Then
_zi("  [OK] Directory " & $81 & " deleted successfully")
EndIf
Return 1
EndIf
Return 2
EndIf
Return 0
EndFunc
Func _104($81, $9i, $9n)
Dim $9g
If $9g Then _zi("[I] FindGlob " & $81 & " " & $9i)
Local Const $9o = $81 & "\" & $9i
Local Const $4n = FileFindFirstFile($9o)
Local $9p = []
If $4n = -1 Then
Return $9p
EndIf
Local $4l = FileFindNextFile($4n)
While @error = 0
If StringRegExp($4l, $9n) Then
_vv($9p, $81 & "\" & $4l)
EndIf
$4l = FileFindNextFile($4n)
WEnd
FileClose($4n)
Return $9p
EndFunc
Func _105($81, $9q)
Dim $9g
If $9g Then _zi("[I] RemoveAllFileFrom " & $81)
Dim $8w
Local Const $9o = $81 & "\*"
Local Const $4n = FileFindFirstFile($9o)
If $4n = -1 Then
Return Null
EndIf
Local $4l = FileFindNextFile($4n)
While @error = 0
For $9r = 1 To UBound($9q) - 1
Local $9s = $81 & "\" & $4l
Local $9t = _zr($9s)
If $9t And $9q[$9r][3] And $9t = $9q[$9r][1] And StringRegExp($4l, $9q[$9r][3]) Then
Local $9u = $8w.Item($9q[$9r][0])
Local $8g = 0
Local $9f = False
If $9q[$9r][4] = True Then
$9f = True
EndIf
If $9t = 'file' Then
$8g = _102($9s, $9q[$9r][2], $9f)
ElseIf $9t = 'folder' Then
$8g = _103($9s, $9f)
EndIf
If $8g = 1 Then
$9u[0] += 1
ElseIf $8g = 2 Then
$9u[1] += "  [X] " & $9s & " delete failed" & @CRLF
EndIf
$8w.Item($9q[$9r][0]) = $9u
EndIf
Next
$4l = FileFindNextFile($4n)
WEnd
FileClose($4n)
EndFunc
Func _106($83)
Dim $9g
If $9g Then _zi("[I] RemoveRegistryKey " & $83)
Local Const $8g = RegDelete($83)
If $8g = 1 Then
If $9g Then
_zi("  [OK] " & $83 & " deleted successfully")
EndIf
ElseIf $8g = 2 Then
If $9g Then
_zi("  [X] " & $83 & " deleted failed")
EndIf
EndIf
Return $8g
EndFunc
Func _10a($9v)
Local $9w = 50
Dim $9g
If $9g Then _zi("[I] CloseProcessAndWait " & $9v)
If 0 = ProcessExists($9v) Then Return 0
ProcessClose($9v)
Do
$9w -= 1
Sleep(250)
Until($9w = 0 Or 0 = ProcessExists($9v))
Local Const $8g = ProcessExists($9v)
If 0 = $8g Then
If $9g Then _zi("  [OK] Proccess " & $9v & " stopped successfully")
Return 1
EndIf
Return 0
EndFunc
Func _10b($7t)
Dim $9w
Dim $9g
If $9g Then _zi("[I] RemoveAllProcess")
Local $9x = ProcessList()
For $3x = 1 To $9x[0][0]
Local $9y = $9x[$3x][0]
Local $9z = $9x[$3x][1]
For $9w = 1 To UBound($7t) - 1
If StringRegExp($9y, $7t[$9w][1]) Then
Local $9u = $8w.Item($7t[$9w][0])
Local $8g = _10a($9z)
If $8g Then
$9u[0] += 1
Else
$9u[1] += "  [X] The process could not be stopped, the program may not have been deleted correctly" & @CRLF
EndIf
$8w.Item($7t[$9w][0]) = $9u
EndIf
Next
Next
EndFunc
Func _10c($a0)
Dim $9g
Dim $8w
If $9g Then _zi("[I] RemoveScheduleTask")
For $3x = 1 To UBound($a0) - 1
RunWait('schtasks.exe /delete /tn "' & $a0[$3x][1] & '" /f', @TempDir, @SW_HIDE)
Next
EndFunc
Func _10d($a0)
Dim $8w
Dim $9g
If $9g Then _zi("[I] UninstallNormaly")
Local Const $86 = _zo()
For $3x = 1 To UBound($86) - 1
For $a1 = 1 To UBound($a0) - 1
Local $a2 = $a0[$a1][1]
Local $a3 = $a0[$a1][2]
Local $a4 = _104($86[$3x], "*", $a2)
For $a5 = 1 To UBound($a4) - 1
Local $a6 = _104($a4[$a5], "*", $a3)
For $a7 = 1 To UBound($a6) - 1
If _zp($a6[$a7]) Then
RunWait($a6[$a7])
Local $9u = $8w.Item($a0[$a1][0])
$9u[0] += 1
$8w.Item($a0[$a1][0]) = $9u
EndIf
Next
Next
Next
Next
EndFunc
Func _10e($a0)
Dim $9g
If $9g Then _zi("[I] RemoveAllProgramFilesDir")
Local Const $86 = _zo()
For $3x = 1 To UBound($86) - 1
_105($86[$3x], $a0)
Next
EndFunc
Func _10f($a0)
Dim $8w
Dim $9g
If $9g Then _zi("[I] RemoveAllSoftwareKeyList")
Local $56 = ""
If @OSArch = "X64" Then $56 = "64"
Local $a8[2] = ["HKCU" & $56 & "\SOFTWARE", "HKLM" & $56 & "\SOFTWARE"]
For $7f = 0 To UBound($a8) - 1
Local $3x = 0
While True
$3x += 1
Local $84 = RegEnumKey($a8[$7f], $3x)
If @error <> 0 Then ExitLoop
For $a1 = 1 To UBound($a0) - 1
If $84 And $a0[$a1][1] Then
If StringRegExp($84, $a0[$a1][1]) Then
Local $8g = _106($a8[$7f] & "\" & $84)
Local $9u = $8w.Item($a0[$a1][0])
If $8g = 1 Then
$9u[0] += 1
ElseIf $8g = 2 Then
$9u[1] += "[X] " & $a8[$7f] & "\" & $84 & " delete failed" & @CRLF
EndIf
$8w.Item($a0[$a1][0]) = $9u
EndIf
EndIf
Next
WEnd
Next
EndFunc
Func _10g($a0)
Dim $8w
Dim $9g
If $9g Then _zi("[I] RemoveUninstallStringWithSearch")
For $3x = 1 To UBound($a0) - 1
Local $a9 = _zm($a0[$3x][1], $a0[$3x][2], $a0[$3x][3])
If $a9 And $a9 <> "" Then
Local $8g = _106($a9)
Local $9u = $8w.Item($a0[$3x][0])
If $8g = 1 Then
$9u[0] += 1
ElseIf $8g = 2 Then
$9u[1] += "[X] " & $a9 & " delete failed" & @CRLF
EndIf
$8w.Item($a0[$3x][0]) = $9u
EndIf
Next
EndFunc
Func _10h()
Local Const $aa = "frst"
Dim $90
Dim $91
Dim $ab
Dim $93
Dim $ac
Dim $95
Local Const $9j = "(?i)^Farbar"
Local Const $ad = "(?i)^FRST.*\.exe$"
Local Const $ae = "(?i)^FRST-OlderVersion$"
Local Const $af = "(?i)^(FRST|fixlist|fixlog|Addition|Shortcut).*\.(exe|txt)$"
Local Const $ag = "(?i)^FRST"
Local Const $ah[1][2] = [[$aa, $ad]]
Local Const $ai[1][5] = [[$aa, 'file', $9j, $af, False]]
Local Const $aj[1][5] = [[$aa, 'folder', Null, $ae, False]]
Local Const $ak[1][5] = [[$aa, 'folder', Null, $ag, True]]
_vv($90, $ah)
_vv($91, $ai)
_vv($93, $ai)
_vv($91, $aj)
_vv($93, $aj)
_vv($95, $ak)
EndFunc
_10h()
Func _10i()
Dim $9b
Dim $96
Local $aa = "zhp"
Local Const $88[1][2] = [[$aa, "(?i)^ZHP$"]]
Local Const $al[1][5] = [[$aa, 'folder', Null, "(?i)^ZHP$", True]]
_vv($9b, $al)
_vv($96, $88)
EndFunc
_10i()
Func _10j()
Local Const $am = Null
Local Const $aa = "zhpdiag"
Dim $90
Dim $91
Dim $92
Dim $93
Dim $95
Local Const $ad = "(?i)^ZHPDiag.*\.exe$"
Local Const $ae = "(?i)^ZHPDiag.*\.(exe|txt|lnk)$"
Local Const $af = "(?i)^PhysicalDisk[0-9]_MBR\.bin$"
Local Const $ah[1][2] = [[$aa, $ad]]
Local Const $ai[1][5] = [[$aa, 'file', $am, $ae, False]]
Local Const $aj[1][5] = [[$aa, 'file', Null, $af, True]]
_vv($90, $ah)
_vv($91, $ai)
_vv($93, $ai)
_vv($92, $ai)
_vv($95, $aj)
EndFunc
_10j()
Func _10k()
Local Const $am = Null
Local Const $an = "zhpfix"
Dim $90
Dim $91
Dim $93
Local Const $ad = "(?i)^ZHPFix.*\.exe$"
Local Const $ae = "(?i)^ZHPFix.*\.(exe|txt|lnk)$"
Local Const $ah[1][2] = [[$an, $ad]]
Local Const $ai[1][5] = [[$an, 'file', $am, $ae, False]]
_vv($90, $ah)
_vv($91, $ai)
_vv($93, $ai)
EndFunc
_10k()
Func _10l($8m = False)
Local Const $9j = "(?i)^Malwarebytes Anti-Rootkit$"
Local Const $ao = "(?i)^Malwarebytes"
Local Const $aa = "mbar"
Dim $90
Dim $91
Dim $93
Dim $96
Local Const $ad = "(?i)^mbar.*\.exe$"
Local Const $ae = "(?i)^mbar"
Local Const $ah[1][2] = [[$aa, $ad]]
Local Const $ai[1][2] = [[$aa, $9j]]
Local Const $aj[1][5] = [[$aa, 'file', $ao, $ad, False]]
Local Const $ak[1][5] = [[$aa, 'folder', $9j, $ae, False]]
_vv($90, $ah)
_vv($91, $aj)
_vv($93, $aj)
_vv($91, $ak)
_vv($93, $ak)
_vv($96, $ai)
EndFunc
_10l()
Func _10m()
Local Const $aa = "roguekiller"
Dim $90
Dim $97
Dim $98
Dim $94
Dim $99
Dim $91
Dim $92
Dim $9c
Dim $93
Local $56 = ""
If @OSArch = "X64" Then $56 = "64"
Local Const $ap = "(?i)^Adlice"
Local Const $ad = "(?i)^RogueKiller"
Local Const $ae = "(?i)^RogueKiller.*\.(exe|lnk|txt)$"
Local Const $af = "(?i)^RogueKiller.*\.exe$"
Local Const $ag = "(?i)^RogueKiller_portable(32|64)\.exe$"
Local Const $ah[1][2] = [[$aa, $af]]
Local Const $ai[1][2] = [[$aa, "RogueKiller Anti-Malware"]]
Local Const $aj[1][4] = [[$aa, "HKLM" & $56 & "\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall", $ad, "DisplayName"]]
Local Const $ak[1][5] = [[$aa, 'file', $ap, $ae, False]]
Local Const $aq[1][5] = [[$aa, 'folder', Null, $ad, True]]
Local Const $ar[1][5] = [[$aa, 'file', Null, $ag, False]]
_vv($90, $ah)
_vv($97, $ai)
_vv($98, $aj)
_vv($94, $aq)
_vv($99, $aq)
_vv($91, $ar)
_vv($91, $ak)
_vv($91, $aq)
_vv($93, $ar)
_vv($93, $ak)
_vv($93, $aq)
_vv($92, $ak)
_vv($9c, $aq)
EndFunc
_10m()
Func _10n()
Local Const $aa = "adwcleaner"
Local Const $9j = "(?i)^AdwCleaner"
Local Const $ao = "(?i)^Malwarebytes"
Local Const $ad = "(?i)^AdwCleaner.*\.exe$"
Dim $90
Dim $91
Dim $93
Dim $95
Local Const $ah[1][2] = [[$aa, $ad]]
Local Const $ai[1][5] = [[$aa, 'file', $ao, $ad, False]]
Local Const $aj[1][5] = [[$aa, 'folder', Null, $9j, True]]
_vv($90, $ah)
_vv($91, $ai)
_vv($93, $ai)
_vv($95, $aj)
EndFunc
_10n()
Func _10o()
Local Const $am = Null
Local Const $aa = "zhpcleaner"
Dim $90
Dim $91
Dim $93
Local Const $ad = "(?i)^ZHPCleaner.*\.exe$"
Local Const $ae = "(?i)^ZHPCleaner.*\.(exe|txt|lnk)$"
Local Const $ah[1][2] = [[$aa, $ad]]
Local Const $ai[1][5] = [[$aa, 'file', $am, $ae, False]]
_vv($90, $ah)
_vv($91, $ai)
_vv($93, $ai)
EndFunc
_10o()
Func _10p()
Local Const $aa = "usbfix"
Dim $90
Dim $9d
Dim $91
Dim $92
Dim $93
Dim $96
Dim $95
Dim $94
Local Const $9j = "(?i)^UsbFix"
Local Const $ao = "(?i)^SosVirus"
Local Const $ad = "(?i)^UsbFix.*\.(exe|lnk|txt)$"
Local Const $ae = "(?i)^Un-UsbFix.exe$"
Local Const $af = "(?i)^UsbFixQuarantine$"
Local Const $ag = "(?i)^UsbFix.*\.exe$"
Local Const $as[1][2] = [[$aa, $ag]]
Local Const $ah[1][2] = [[$aa, $9j]]
Local Const $ai[1][3] = [[$aa, $9j, $ae]]
Local Const $aj[1][5] = [[$aa, 'file', $ao, $ad, False]]
Local Const $ak[1][5] = [[$aa, 'folder', Null, $af, True]]
Local Const $aq[1][5] = [[$aa, 'folder', Null, $9j, False]]
_vv($90, $as)
_vv($9d, $ai)
_vv($91, $aj)
_vv($92, $aj)
_vv($93, $aj)
_vv($96, $ah)
_vv($95, $ak)
_vv($95, $aq)
_vv($94, $aq)
EndFunc
_10p()
Func _10q()
Local Const $aa = "adsfix"
Dim $90
Dim $91
Dim $93
Dim $95
Dim $92
Dim $96
Local Const $9j = "(?i)^AdsFix"
Local Const $ao = "(?i)^SosVirus"
Local Const $ad = "(?i)^AdsFix.*\.exe$"
Local Const $ae = "(?i)^AdsFix.*\.(exe|txt|lnk)$"
Local Const $af = "(?i)^AdsFix.*\.txt$"
Local Const $ah[1][2] = [[$aa, $ad]]
Local Const $ai[1][5] = [[$aa, 'file', $ao, $ae, False]]
Local Const $aj[1][5] = [[$aa, 'file', Null, $af, False]]
Local Const $ak[1][5] = [[$aa, 'folder', Null, $9j, True]]
Local Const $aq[1][2] = [[$aa, $9j]]
_vv($90, $ah)
_vv($91, $ai)
_vv($92, $ai)
_vv($93, $ai)
_vv($95, $aj)
_vv($95, $ak)
_vv($96, $aq)
EndFunc
_10q()
Func _10r()
Local Const $aa = "aswmbr"
Dim $90
Dim $91
Dim $93
Local Const $9j = "(?i)^avast"
Local Const $ad = "(?i)^aswmbr.*\.(exe|txt|lnk)$"
Local Const $ae = "(?i)^MBR\.dat$"
Local Const $af = "(?i)^aswmbr.*\.exe$"
Local Const $ah[1][2] = [[$aa, $af]]
Local Const $ai[1][5] = [[$aa, 'file', $9j, $ad, False]]
Local Const $aj[1][5] = [[$aa, 'file', Null, $ae, False]]
_vv($90, $ah)
_vv($91, $ai)
_vv($91, $aj)
_vv($93, $ai)
EndFunc
_10r()
Func _10s()
Local Const $aa = "fss"
Dim $90
Dim $91
Dim $93
Local Const $9j = "(?i)^Farbar"
Local Const $ad = "(?i)^FSS.*\.(exe|txt|lnk)$"
Local Const $ae = "(?i)^FSS.*\.exe$"
Local Const $ah[1][2] = [[$aa, $ae]]
Local Const $ai[1][5] = [[$aa, 'file', $9j, $ad, False]]
_vv($90, $ah)
_vv($91, $ai)
_vv($93, $ai)
EndFunc
_10s()
Func _10t()
Local Const $aa = "toolsdiag"
Dim $90
Dim $91
Dim $93
Dim $95
Local Const $ad = "(?i)^toolsdiag.*\.exe$"
Local Const $ae = "(?i)^ToolsDiag$"
Local Const $ah[1][5] = [[$aa, 'folder', Null, $ae, False]]
Local Const $ai[1][5] = [[$aa, 'file', Null, $ad, False]]
Local Const $aj[1][2] = [[$aa, $ad]]
_vv($90, $aj)
_vv($91, $ai)
_vv($93, $ai)
_vv($95, $ah)
EndFunc
_10t()
Func _10u()
Local Const $aa = "scanrapide"
Dim $95
Dim $91
Dim $93
Local Const $9j = Null
Local Const $ad = "(?i)^ScanRapide.*\.exe$"
Local Const $ae = "(?i)^ScanRapide\[R[0-9]+\]\.txt$"
Local Const $ah[1][5] = [[$aa, 'file', $9j, $ad, False]]
Local Const $ai[1][5] = [[$aa, 'file', Null, $ae, False]]
_vv($91, $ah)
_vv($93, $ah)
_vv($95, $ai)
EndFunc
_10u()
Func _10v()
Local Const $aa = "otl"
Dim $90
Dim $91
Dim $93
Dim $95
Local Const $9j = "(?i)^OldTimer"
Local Const $ad = "(?i)^OTL.*\.exe$"
Local Const $ae = "(?i)^OTL.*\.(exe|txt)$"
Local Const $af = "(?i)^Extras\.txt$"
Local Const $ag = "(?i)^_OTL$"
Local Const $ah[1][2] = [[$aa, $ad]]
Local Const $ai[1][5] = [[$aa, 'file', $9j, $ae, False]]
Local Const $aj[1][5] = [[$aa, 'file', Null, $af, False]]
Local Const $ak[1][5] = [[$aa, 'folder', Null, $ag, True]]
_vv($90, $ah)
_vv($91, $ai)
_vv($91, $aj)
_vv($93, $ai)
_vv($95, $ak)
EndFunc
_10v()
Func _10w()
Local Const $aa = "otm"
Dim $90
Dim $91
Dim $93
Dim $95
Local Const $9j = "(?i)^OldTimer"
Local Const $ad = "(?i)^OTM.*\.exe$"
Local Const $ae = "(?i)^_OTM$"
Local Const $ah[1][2] = [[$aa, $ad]]
Local Const $ai[1][5] = [[$aa, 'file', $9j, $ad, False]]
Local Const $aj[1][5] = [[$aa, 'folder', Null, $ae, True]]
_vv($90, $ah)
_vv($91, $ai)
_vv($93, $ai)
_vv($95, $aj)
EndFunc
_10w()
Func _10x()
Local Const $aa = "listparts"
Dim $90
Dim $91
Dim $93
Dim $95
Local Const $9j = "(?i)^Farbar"
Local Const $ad = "(?i)^listParts.*\.exe$"
Local Const $ae = "(?i)^Results\.txt$"
Local Const $ah[1][2] = [[$aa, $ad]]
Local Const $ai[1][5] = [[$aa, 'file', $9j, $ad, False]]
Local Const $aj[1][5] = [[$aa, 'file', Null, $ae, False]]
_vv($90, $ah)
_vv($91, $ai)
_vv($91, $aj)
_vv($93, $ai)
_vv($93, $aj)
EndFunc
_10x()
Func _10y()
Local Const $aa = "minitoolbox"
Dim $90
Dim $91
Dim $93
Dim $95
Local Const $9j = "(?i)^Farbar"
Local Const $ad = "(?i)^MiniToolBox.*\.exe$"
Local Const $ae = "(?i)^MTB\.txt$"
Local Const $ah[1][2] = [[$aa, $ad]]
Local Const $ai[1][5] = [[$aa, 'file', $9j, $ad, False]]
Local Const $aj[1][5] = [[$aa, 'file', Null, $ae, False]]
_vv($90, $ah)
_vv($91, $ai)
_vv($91, $aj)
_vv($93, $ai)
_vv($93, $aj)
EndFunc
_10y()
Func _10z()
Local Const $aa = "miniregtool"
Dim $90
Dim $91
Dim $93
Dim $95
Local Const $9j = Null
Local Const $ad = "(?i)^MiniRegTool.*\.exe$"
Local Const $ae = "(?i)^MiniRegTool.*\.(exe|zip)$"
Local Const $af = "(?i)^Result\.txt$"
Local Const $ag = "(?i)^MiniRegTool"
Local Const $ah[1][2] = [[$aa, $ad]]
Local Const $ai[1][5] = [[$aa, 'file', $9j, $ae, False]]
Local Const $aj[1][5] = [[$aa, 'file', $9j, $af, False]]
Local Const $ak[1][5] = [[$aa, 'folder', $9j, $ag, False]]
_vv($90, $ah)
_vv($91, $ai)
_vv($91, $aj)
_vv($91, $ak)
_vv($93, $ai)
_vv($93, $aj)
_vv($93, $ak)
EndFunc
_10z()
Func _110()
Local Const $aa = "grantperms"
Dim $90
Dim $91
Dim $93
Dim $95
Local Const $9j = Null
Local Const $ad = "(?i)^GrantPerms.*\.exe$"
Local Const $ae = "(?i)^GrantPerms.*\.(exe|zip)$"
Local Const $af = "(?i)^Perms\.txt$"
Local Const $ag = "(?i)^GrantPerms"
Local Const $ah[1][2] = [[$aa, $ad]]
Local Const $ai[1][5] = [[$aa, 'file', $9j, $ae, False]]
Local Const $aj[1][5] = [[$aa, 'file', $9j, $af, False]]
Local Const $ak[1][5] = [[$aa, 'folder', $9j, $ag, False]]
_vv($90, $ah)
_vv($91, $ai)
_vv($91, $aj)
_vv($91, $ak)
_vv($93, $ai)
_vv($93, $aj)
_vv($93, $ak)
EndFunc
_110()
Func _111()
Local Const $aa = "combofix"
Dim $91
Dim $93
Dim $95
Local Const $9j = "(?i)^Swearware"
Local Const $ad = "(?i)^Combofix.*\.exe$"
Local Const $ae = "(?i)^CFScript\.txt$"
Local Const $af = "(?i)^Qoobox$"
Local Const $ag = "(?i)^Combofix.*\.txt$"
Local Const $ah[1][5] = [[$aa, 'file', $9j, $ad, False]]
Local Const $ai[1][5] = [[$aa, 'file', Null, $ae, False]]
Local Const $aj[1][5] = [[$aa, 'folder', Null, $af, True]]
Local Const $ak[1][5] = [[$aa, 'file', Null, $ag, False]]
_vv($91, $ah)
_vv($91, $ai)
_vv($93, $ah)
_vv($93, $ai)
_vv($95, $aj)
_vv($95, $ak)
EndFunc
_111()
Func _112()
Local Const $aa = "regtoolexport"
Dim $90
Dim $91
Dim $93
Local Const $9j = Null
Local Const $ad = "(?i)^regtoolexport.*\.exe$"
Local Const $ae = "(?i)^Export.*\.reg$"
Local Const $ah[1][2] = [[$aa, $ad]]
Local Const $ai[1][5] = [[$aa, 'file', $9j, $ad, False]]
Local Const $aj[1][5] = [[$aa, 'file', $9j, $ae, False]]
_vv($90, $ah)
_vv($91, $ai)
_vv($91, $aj)
_vv($93, $ai)
_vv($93, $aj)
EndFunc
_112()
Func _113()
Local Const $aa = "tdsskiller"
Dim $90
Dim $91
Dim $93
Dim $95
Local Const $9j = "(?i)^.*Kaspersky"
Local Const $ad = "(?i)^tdsskiller.*\.exe$"
Local Const $ae = "(?i)^tdsskiller.*\.(exe|zip)$"
Local Const $af = "(?i)^TDSSKiller.*_log\.txt$"
Local Const $ag = "(?i)^TDSSKiller"
Local Const $ah[1][2] = [[$aa, $ad]]
Local Const $ai[1][5] = [[$aa, 'file', $9j, $ae, False]]
Local Const $aj[1][5] = [[$aa, 'file', Null, $af, False]]
Local Const $ak[1][5] = [[$aa, 'folder', Null, $ag, False]]
_vv($90, $ah)
_vv($91, $ai)
_vv($91, $ak)
_vv($93, $ai)
_vv($93, $ak)
_vv($95, $aj)
_vv($95, $ak)
EndFunc
_113()
Func _114()
Local Const $aa = "winupdatefix"
Dim $90
Dim $91
Dim $93
Dim $95
Local Const $9j = Null
Local Const $ad = "(?i)^winupdatefix.*\.exe$"
Local Const $ae = "(?i)^winupdatefix.*\.txt$"
Local Const $ah[1][2] = [[$aa, $ad]]
Local Const $ai[1][5] = [[$aa, 'file', $9j, $ad, False]]
Local Const $aj[1][5] = [[$aa, 'file', $9j, $ae, False]]
_vv($90, $ah)
_vv($91, $ai)
_vv($93, $ai)
_vv($95, $aj)
EndFunc
_114()
Func _115()
Local Const $aa = "rsthosts"
Dim $90
Dim $91
Dim $93
Dim $95
Local Const $9j = Null
Local Const $ad = "(?i)^rsthosts.*\.exe$"
Local Const $ae = "(?i)^RstHosts.*\.txt$"
Local Const $ah[1][2] = [[$aa, $ad]]
Local Const $ai[1][5] = [[$aa, 'file', $9j, $ad, Null]]
Local Const $aj[1][5] = [[$aa, 'file', $9j, $ae, Null]]
_vv($90, $ah)
_vv($91, $ai)
_vv($93, $ai)
_vv($95, $aj)
EndFunc
_115()
Func _116()
Local Const $aa = "winchk"
Dim $90
Dim $91
Dim $93
Dim $95
Local Const $9j = Null
Local Const $ad = "(?i)^winchk.*\.exe$"
Local Const $ae = "(?i)^WinChk.*\.txt$"
Local Const $ah[1][2] = [[$aa, $ad]]
Local Const $ai[1][5] = [[$aa, 'file', $9j, $ad, False]]
Local Const $aj[1][5] = [[$aa, 'file', $9j, $ae, False]]
_vv($90, $ah)
_vv($91, $ai)
_vv($93, $ai)
_vv($95, $aj)
EndFunc
_116()
Func _117()
Local Const $aa = "avenger"
Dim $90
Dim $91
Dim $93
Dim $95
Local Const $9j = Null
Local Const $ad = "(?i)^avenger.*\.(exe|zip)$"
Local Const $ae = "(?i)^avenger"
Local Const $af = "(?i)^avenger.*\.txt$"
Local Const $ag = "(?i)^avenger.*\.exe$"
Local Const $ah[1][2] = [[$aa, $ag]]
Local Const $ai[1][5] = [[$aa, 'file', $9j, $ad, False]]
Local Const $aj[1][5] = [[$aa, 'folder', $9j, $ae, False]]
Local Const $ak[1][5] = [[$aa, 'file', $9j, $af, False]]
_vv($90, $ah)
_vv($91, $ai)
_vv($91, $aj)
_vv($93, $ai)
_vv($93, $aj)
_vv($95, $aj)
_vv($95, $ak)
EndFunc
_117()
Func _118()
Local Const $aa = "blitzblank"
Dim $90
Dim $91
Dim $93
Dim $95
Dim $92
Dim $96
Local Const $9j = "(?i)^Emsi"
Local Const $ad = "(?i)^BlitzBlank.*\.exe$"
Local Const $ae = "(?i)^BlitzBlank.*\.log$"
Local Const $ah[1][2] = [[$aa, $ad]]
Local Const $ai[1][5] = [[$aa, 'file', $9j, $ad, False]]
Local Const $aj[1][5] = [[$aa, 'file', Null, $ae, False]]
_vv($90, $ah)
_vv($91, $ai)
_vv($93, $ai)
_vv($95, $aj)
EndFunc
_118()
Func _119()
Local Const $aa = "zoek"
Dim $90
Dim $91
Dim $93
Dim $95
Dim $92
Dim $96
Local Const $9j = Null
Local Const $ad = "(?i)^zoek.*\.exe$"
Local Const $ae = "(?i)^zoek.*\.log$"
Local Const $af = "(?i)^zoek"
Local Const $ag = "(?i)^runcheck.*\.txt$"
Local Const $ah[1][2] = [[$aa, $ad]]
Local Const $ai[1][5] = [[$aa, 'file', $9j, $ad, False]]
Local Const $aj[1][5] = [[$aa, 'file', $9j, $ae, False]]
Local Const $ak[1][5] = [[$aa, 'folder', $9j, $af, True]]
Local Const $aq[1][5] = [[$aa, 'file', $9j, $ag, False]]
_vv($90, $ah)
_vv($91, $ai)
_vv($93, $ai)
_vv($95, $aj)
_vv($95, $ak)
_vv($95, $aq)
EndFunc
_119()
Func _11a()
Local Const $aa = "remediate-vbs-worm"
Dim $90
Dim $91
Dim $93
Dim $95
Dim $92
Dim $96
Local Const $9j = "(?i).*VBS autorun worms.*"
Local Const $ao = Null
Local Const $ad = "(?i)^remediate.?vbs.?worm.*\.exe$"
Local Const $ae = "(?i)^Rem-VBS.*\.log$"
Local Const $af = "(?i)^Rem-VBS"
Local Const $ah[1][2] = [[$aa, $ad]]
Local Const $ai[1][5] = [[$aa, 'file', $ao, $ad, False]]
Local Const $aj[1][5] = [[$aa, 'file', $ao, $ae, False]]
Local Const $ak[1][5] = [[$aa, 'folder', $9j, $af, True]]
_vv($90, $ah)
_vv($91, $ai)
_vv($93, $ai)
_vv($95, $aj)
_vv($95, $ak)
EndFunc
_11a()
Func _11b()
Local Const $aa = "ckscanner"
Dim $90
Dim $91
Dim $93
Local Const $9j = Null
Local Const $ad = "(?i)^CKScanner.*\.exe$"
Local Const $ae = "(?i)^CKfiles.*\.txt$"
Local Const $ah[1][2] = [[$aa, $ad]]
Local Const $ai[1][5] = [[$aa, 'file', $9j, $ad, False]]
Local Const $aj[1][5] = [[$aa, 'file', $9j, $ae, False]]
_vv($90, $ah)
_vv($91, $ai)
_vv($93, $ai)
_vv($91, $aj)
_vv($93, $aj)
EndFunc
_11b()
Func _11c()
Local Const $aa = "quickdiag"
Dim $90
Dim $91
Dim $93
Dim $95
Local Const $9j = "(?i)^SosVirus"
Local Const $ad = "(?i)^QuickDiag.*\.exe$"
Local Const $ae = "(?i)^QuickDiag.*\.(exe|txt)$"
Local Const $af = "(?i)^QuickScript.*\.txt$"
Local Const $ag = "(?i)^QuickDiag.*\.txt$"
Local Const $at = "(?i)^QuickDiag"
Local Const $ah[1][2] = [[$aa, $ad]]
Local Const $ai[1][5] = [[$aa, 'file', $9j, $ae, True]]
Local Const $aj[1][5] = [[$aa, 'file', Null, $af, True]]
Local Const $ak[1][5] = [[$aa, 'file', Null, $ag, True]]
Local Const $aq[1][5] = [[$aa, 'folder', Null, $at, True]]
_vv($90, $ah)
_vv($91, $ai)
_vv($93, $ai)
_vv($91, $aj)
_vv($93, $aj)
_vv($95, $ak)
_vv($95, $aq)
EndFunc
_11c()
Func _11d()
Local $56 = ""
If @OSArch = "X64" Then $56 = "64"
If FileExists(@AppDataDir & "\ZHP") Then
Local Const $au = "kprm-zhp-appdata"
If FileExists(@HomeDrive & "\KPRM\kprm-zhp-appdata.bat") Then
FileDelete(@HomeDrive & "\KPRM\kprm-zhp-appdata.bat")
EndIf
FileWrite(@HomeDrive & "\KPRM\kprm-zhp-appdata.bat", 'schtasks /delete /f /tn "' & $au & '" ' & @CRLF)
FileWrite(@HomeDrive & "\KPRM\kprm-zhp-appdata.bat", "RMDIR /S /Q " & @AppDataDir & "\ZHP " & @CRLF)
FileWrite(@HomeDrive & "\KPRM\kprm-zhp-appdata.bat", "DEL /F /Q " & @HomeDrive & "\KPRM\kprm-zhp-appdata.bat " & @CRLF)
Local $av = _3f(_31('d', 3, _3q()), 2)
$av = StringReplace($av, ".", "/")
$av = StringReplace($av, "-", "/")
Local $aw = _3f(_31('y', 1, _3q()), 2)
$aw = StringReplace($aw, ".", "/")
$aw = StringReplace($aw, "-", "/")
Local $ax = 'schtasks /create /f /tn "kprm-zhp-appdata" /tr ' & @HomeDrive & "\KPRM\kprm-zhp-appdata.bat" & ' /sc MINUTE /mo 5  /st 00:01 /sd ' & $av & ' /ed ' & $aw & ' /RU SYSTEM'
Run($ax, @TempDir, @SW_HIDE)
EndIf
If FileExists(@AppDataCommonDir & "\Malwarebytes\Malwarebytes' Anti-Malware\Quarantine") Then
Local $ay = _x1(@AppDataCommonDir & "\Malwarebytes\Malwarebytes' Anti-Malware\Quarantine")
If @error = 0 Then
For $3x = 1 To $ay[0]
FileDelete(@AppDataCommonDir & "\Malwarebytes\Malwarebytes' Anti-Malware\Quarantine" & '\' & $ay[$3x])
Next
EndIf
EndIf
Local Const $9n[2] = [ "HKLM" & $56 & "\SOFTWARE\Microsoft\Windows\Windows Error Reporting\LocalDumps\RogueKiller.exe", "HKLM" & $56 & "\SOFTWARE\Microsoft\Windows\CurrentVersion\App Paths\combofix.exe"]
For $az = 0 To UBound($9n) - 1
_106($9n[$az])
Next
EndFunc
Func _11e($8m = False)
_zi(@CRLF & "- Search Tools -" & @CRLF)
_10b($90)
_zs()
_10d($9d)
_zs()
_10c($97)
_zs()
_105(@DesktopDir, $91)
_zs()
_105(@DesktopCommonDir, $92)
_zs()
If FileExists(@UserProfileDir & "\Downloads") Then
_105(@UserProfileDir & "\Downloads", $93)
_zs()
Else
_zs()
EndIf
_10e($94)
_zs()
_105(@HomeDrive, $95)
_zs()
_105(@AppDataDir, $9a)
_zs()
_105(@AppDataCommonDir, $99)
_zs()
_105(@LocalAppDataDir, $9b)
_zs()
_10f($96)
_zs()
_10g($98)
_zs()
_105(@AppDataCommonDir & "\Microsoft\Windows\Start Menu\Programs", $9c)
_zs()
If $8m = True Then
_11d()
EndIf
_zs()
For $8y = 0 To UBound($8x) - 1
Local $8z = $8w.Item($8x[$8y])
If $8z[0] > 0 Then
If $8z[1] = "" Then
_zi(@CRLF & "  [OK] " & StringUpper($8x[$8y]) & " has been successfully deleted")
Else
_zi(@CRLF & "  [X] " & StringUpper($8x[$8y]) & " was found but there were errors :")
_zi($8z[1])
EndIf
EndIf
Next
_zs()
EndFunc
FileInstall("C:\Users\IEUser\Desktop\kpRemover\src\assets\bug.gif", @TempDir & "\kprm-logo.gif")
Global $8p = "KpRm"
Global $9g = False
Global $7v = "kprm-" & @YEAR & @MON & @MDAY & @HOUR & @MIN & ".txt"
Local Const $b0 = GUICreate($8p, 500, 195, 202, 112)
Local Const $b1 = GUICtrlCreateGroup("Actions", 8, 8, 400, 153)
Local Const $b2 = GUICtrlCreateCheckbox($4p, 16, 40, 129, 17)
Local Const $b3 = GUICtrlCreateCheckbox($4q, 16, 80, 190, 17)
Local Const $b4 = GUICtrlCreateCheckbox($4r, 16, 120, 190, 17)
Local Const $b5 = GUICtrlCreateCheckbox($4s, 220, 40, 137, 17)
Local Const $b6 = GUICtrlCreateCheckbox($4t, 220, 80, 137, 17)
Local Const $b7 = GUICtrlCreateCheckbox($4u, 220, 120, 180, 17)
Global $8d = GUICtrlCreateProgress(8, 170, 480, 17)
GUICtrlCreateGroup("", -99, -99, 1, 1)
guictrlsetstate($b2, 1)
Local Const $b8 = GUICtrlCreatePic(@TempDir & "\kprm-logo.gif", 415, 16, 76, 76)
Local Const $b9 = GUICtrlCreateButton($4v, 415, 120, 75, 40)
GUISetState(@SW_SHOW)
While 1
Local $ba = GUIGetMsg()
Switch $ba
Case $0
Exit
Case $b9
_11h()
EndSwitch
WEnd
Func _11f()
Local Const $bb = @HomeDrive & "\KPRM"
If Not FileExists($bb) Then
DirCreate($bb)
EndIf
If Not FileExists($bb) Then
MsgBox(16, $4x, $4y)
Exit
EndIf
EndFunc
Func _11g()
_11f()
_zi("#################################################################################################################" & @CRLF)
_zi("# Run at " & _3o())
_zi("# Run by " & @UserName & " in " & @ComputerName)
_zi("# Launch from " & @WorkingDir)
_zt()
EndFunc
Func _11h()
_11g()
_zs()
If GUICtrlRead($b5) = $1 Then
_zy()
EndIf
_zs()
If GUICtrlRead($b2) = $1 Then
_11e()
_11e(True)
Else
_zs(32)
EndIf
_zs()
If GUICtrlRead($b7) = $1 Then
_100()
EndIf
_zs()
If GUICtrlRead($b6) = $1 Then
_0zz()
EndIf
_zs()
If GUICtrlRead($b3) = $1 Then
_zu()
EndIf
_zs()
If GUICtrlRead($b4) = $1 Then
_zx()
EndIf
GUICtrlSetData($8d, 100)
MsgBox(64, "OK", $4w)
Exit
EndFunc
