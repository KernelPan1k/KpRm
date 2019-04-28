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
Global Const $g = 1
Global Const $h = "struct;word Year;word Month;word Dow;word Day;word Hour;word Minute;word Second;word MSeconds;endstruct"
Global Const $i = 0
Global Const $j = 1
Global Const $k = 2
Global Const $l= 1
Global Const $m = 0x10000000
Global Const $n = 0
Global Const $o = 0
Global Const $p = 1
Global Const $q = 2
Global Const $r = 3
Global Const $s = 4
Global Const $t = 'struct;dword OSVersionInfoSize;dword MajorVersion;dword MinorVersion;dword BuildNumber;dword PlatformId;wchar CSDVersion[128];endstruct'
Global Const $u = _1v()
Func _1v()
Local $v = DllStructCreate($t)
DllStructSetData($v, 1, DllStructGetSize($v))
Local $w = DllCall('kernel32.dll', 'bool', 'GetVersionExW', 'struct*', $v)
If @error Or Not $w[0] Then Return SetError(@error, @extended, 0)
Return BitOR(BitShift(DllStructGetData($v, 2), -8), DllStructGetData($v, 3))
EndFunc
Global Const $x = 0x001D
Global Const $y = 0x001E
Global Const $0z = 0x001F
Global Const $10 = 0x0020
Global Const $11 = 0x1003
Global Const $12 = 0x0028
Global Const $13 = 0x0029
Global Const $14 = 0x007F
Global Const $15 = 0x0400
Func _2e($16 = 0, $17 = 0, $18 = 0, $19 = '')
If Not $16 Then $16 = 0x0400
Local $1a = 'wstr'
If Not StringStripWS($19, $c + $d) Then
$1a = 'ptr'
$19 = 0
EndIf
Local $w = DllCall('kernel32.dll', 'int', 'GetDateFormatW', 'dword', $16, 'dword', $18, 'struct*', $17, $1a, $19, 'wstr', '', 'int', 2048)
If @error Or Not $w[0] Then Return SetError(@error, @extended, '')
Return $w[5]
EndFunc
Func _2h($16, $1b)
Local $w = DllCall('kernel32.dll', 'int', 'GetLocaleInfoW', 'dword', $16, 'dword', $1b, 'wstr', '', 'int', 2048)
If @error Or Not $w[0] Then Return SetError(@error + 10, @extended, '')
Return $w[3]
EndFunc
Func _31($1c, $1d, $1e)
Local $1f[4]
Local $1g[4]
Local $1h
$1c = StringLeft($1c, 1)
If StringInStr("D,M,Y,w,h,n,s", $1c) = 0 Or $1c = "" Then
Return SetError(1, 0, 0)
EndIf
If Not StringIsInt($1d) Then
Return SetError(2, 0, 0)
EndIf
If Not _37($1e) Then
Return SetError(3, 0, 0)
EndIf
_3g($1e, $1g, $1f)
If $1c = "d" Or $1c = "w" Then
If $1c = "w" Then $1d = $1d * 7
$1h = _3j($1g[1], $1g[2], $1g[3]) + $1d
_3l($1h, $1g[1], $1g[2], $1g[3])
EndIf
If $1c = "m" Then
$1g[2] = $1g[2] + $1d
While $1g[2] > 12
$1g[2] = $1g[2] - 12
$1g[1] = $1g[1] + 1
WEnd
While $1g[2] < 1
$1g[2] = $1g[2] + 12
$1g[1] = $1g[1] - 1
WEnd
EndIf
If $1c = "y" Then
$1g[1] = $1g[1] + $1d
EndIf
If $1c = "h" Or $1c = "n" Or $1c = "s" Then
Local $1i = _3w($1f[1], $1f[2], $1f[3]) / 1000
If $1c = "h" Then $1i = $1i + $1d * 3600
If $1c = "n" Then $1i = $1i + $1d * 60
If $1c = "s" Then $1i = $1i + $1d
Local $1j = Int($1i /(24 * 60 * 60))
$1i = $1i - $1j * 24 * 60 * 60
If $1i < 0 Then
$1j = $1j - 1
$1i = $1i + 24 * 60 * 60
EndIf
$1h = _3j($1g[1], $1g[2], $1g[3]) + $1j
_3l($1h, $1g[1], $1g[2], $1g[3])
_3v($1i * 1000, $1f[1], $1f[2], $1f[3])
EndIf
Local $1k = _3z($1g[1])
If $1k[$1g[2]] < $1g[3] Then $1g[3] = $1k[$1g[2]]
$1e = $1g[1] & '/' & StringRight("0" & $1g[2], 2) & '/' & StringRight("0" & $1g[3], 2)
If $1f[0] > 0 Then
If $1f[0] > 2 Then
$1e = $1e & " " & StringRight("0" & $1f[1], 2) & ':' & StringRight("0" & $1f[2], 2) & ':' & StringRight("0" & $1f[3], 2)
Else
$1e = $1e & " " & StringRight("0" & $1f[1], 2) & ':' & StringRight("0" & $1f[2], 2)
EndIf
EndIf
Return $1e
EndFunc
Func _32($1l, $1m = Default)
Local Const $1n = 128
If $1m = Default Then $1m = 0
$1l = Int($1l)
If $1l < 1 Or $1l > 7 Then Return SetError(1, 0, "")
Local $17 = DllStructCreate($h)
DllStructSetData($17, "Year", BitAND($1m, $1n) ? 2007 : 2006)
DllStructSetData($17, "Month", 1)
DllStructSetData($17, "Day", $1l)
Return _2e(BitAND($1m, $4) ? $15 : $14, $17, 0, BitAND($1m, $3) ? "ddd" : "dddd")
EndFunc
Func _35($1o)
If StringIsInt($1o) Then
Select
Case Mod($1o, 4) = 0 And Mod($1o, 100) <> 0
Return 1
Case Mod($1o, 400) = 0
Return 1
Case Else
Return 0
EndSelect
EndIf
Return SetError(1, 0, 0)
EndFunc
Func _36($1d)
$1d = Int($1d)
Return $1d >= 1 And $1d <= 12
EndFunc
Func _37($1e)
Local $1g[4], $1f[4]
_3g($1e, $1g, $1f)
If Not StringIsInt($1g[1]) Then Return 0
If Not StringIsInt($1g[2]) Then Return 0
If Not StringIsInt($1g[3]) Then Return 0
$1g[1] = Int($1g[1])
$1g[2] = Int($1g[2])
$1g[3] = Int($1g[3])
Local $1k = _3z($1g[1])
If $1g[1] < 1000 Or $1g[1] > 2999 Then Return 0
If $1g[2] < 1 Or $1g[2] > 12 Then Return 0
If $1g[3] < 1 Or $1g[3] > $1k[$1g[2]] Then Return 0
If $1f[0] < 1 Then Return 1
If $1f[0] < 2 Then Return 0
If $1f[0] = 2 Then $1f[3] = "00"
If Not StringIsInt($1f[1]) Then Return 0
If Not StringIsInt($1f[2]) Then Return 0
If Not StringIsInt($1f[3]) Then Return 0
$1f[1] = Int($1f[1])
$1f[2] = Int($1f[2])
$1f[3] = Int($1f[3])
If $1f[1] < 0 Or $1f[1] > 23 Then Return 0
If $1f[2] < 0 Or $1f[2] > 59 Then Return 0
If $1f[3] < 0 Or $1f[3] > 59 Then Return 0
Return 1
EndFunc
Func _3f($1e, $1c)
Local $1g[4], $1f[4]
Local $1p = "", $1q = ""
Local $1r, $1s, $1t = ""
If Not _37($1e) Then
Return SetError(1, 0, "")
EndIf
If $1c < 0 Or $1c > 5 Or Not IsInt($1c) Then
Return SetError(2, 0, "")
EndIf
_3g($1e, $1g, $1f)
Switch $1c
Case 0
$1t = _2h($15, $0z)
If Not @error And Not($1t = '') Then
$1p = $1t
Else
$1p = "M/d/yyyy"
EndIf
If $1f[0] > 1 Then
$1t = _2h($15, $11)
If Not @error And Not($1t = '') Then
$1q = $1t
Else
$1q = "h:mm:ss tt"
EndIf
EndIf
Case 1
$1t = _2h($15, $10)
If Not @error And Not($1t = '') Then
$1p = $1t
Else
$1p = "dddd, MMMM dd, yyyy"
EndIf
Case 2
$1t = _2h($15, $0z)
If Not @error And Not($1t = '') Then
$1p = $1t
Else
$1p = "M/d/yyyy"
EndIf
Case 3
If $1f[0] > 1 Then
$1t = _2h($15, $11)
If Not @error And Not($1t = '') Then
$1q = $1t
Else
$1q = "h:mm:ss tt"
EndIf
EndIf
Case 4
If $1f[0] > 1 Then
$1q = "hh:mm"
EndIf
Case 5
If $1f[0] > 1 Then
$1q = "hh:mm:ss"
EndIf
EndSwitch
If $1p <> "" Then
$1t = _2h($15, $x)
If Not @error And Not($1t = '') Then
$1p = StringReplace($1p, "/", $1t)
EndIf
Local $1u = _3h($1g[1], $1g[2], $1g[3])
$1g[3] = StringRight("0" & $1g[3], 2)
$1g[2] = StringRight("0" & $1g[2], 2)
$1p = StringReplace($1p, "d", "@")
$1p = StringReplace($1p, "m", "#")
$1p = StringReplace($1p, "y", "&")
$1p = StringReplace($1p, "@@@@", _32($1u, 0))
$1p = StringReplace($1p, "@@@", _32($1u, 1))
$1p = StringReplace($1p, "@@", $1g[3])
$1p = StringReplace($1p, "@", StringReplace(StringLeft($1g[3], 1), "0", "") & StringRight($1g[3], 1))
$1p = StringReplace($1p, "####", _3k($1g[2], 0))
$1p = StringReplace($1p, "###", _3k($1g[2], 1))
$1p = StringReplace($1p, "##", $1g[2])
$1p = StringReplace($1p, "#", StringReplace(StringLeft($1g[2], 1), "0", "") & StringRight($1g[2], 1))
$1p = StringReplace($1p, "&&&&", $1g[1])
$1p = StringReplace($1p, "&&", StringRight($1g[1], 2))
EndIf
If $1q <> "" Then
$1t = _2h($15, $12)
If Not @error And Not($1t = '') Then
$1r = $1t
Else
$1r = "AM"
EndIf
$1t = _2h($15, $13)
If Not @error And Not($1t = '') Then
$1s = $1t
Else
$1s = "PM"
EndIf
$1t = _2h($15, $y)
If Not @error And Not($1t = '') Then
$1q = StringReplace($1q, ":", $1t)
EndIf
If StringInStr($1q, "tt") Then
If $1f[1] < 12 Then
$1q = StringReplace($1q, "tt", $1r)
If $1f[1] = 0 Then $1f[1] = 12
Else
$1q = StringReplace($1q, "tt", $1s)
If $1f[1] > 12 Then $1f[1] = $1f[1] - 12
EndIf
EndIf
$1f[1] = StringRight("0" & $1f[1], 2)
$1f[2] = StringRight("0" & $1f[2], 2)
$1f[3] = StringRight("0" & $1f[3], 2)
$1q = StringReplace($1q, "hh", StringFormat("%02d", $1f[1]))
$1q = StringReplace($1q, "h", StringReplace(StringLeft($1f[1], 1), "0", "") & StringRight($1f[1], 1))
$1q = StringReplace($1q, "mm", StringFormat("%02d", $1f[2]))
$1q = StringReplace($1q, "ss", StringFormat("%02d", $1f[3]))
$1p = StringStripWS($1p & " " & $1q, $c + $d)
EndIf
Return $1p
EndFunc
Func _3g($1e, ByRef $1v, ByRef $1w)
Local $1x = StringSplit($1e, " T")
If $1x[0] > 0 Then $1v = StringSplit($1x[1], "/-.")
If $1x[0] > 1 Then
$1w = StringSplit($1x[2], ":")
If UBound($1w) < 4 Then ReDim $1w[4]
Else
Dim $1w[4]
EndIf
If UBound($1v) < 4 Then ReDim $1v[4]
For $1y = 1 To 3
If StringIsInt($1v[$1y]) Then
$1v[$1y] = Int($1v[$1y])
Else
$1v[$1y] = -1
EndIf
If StringIsInt($1w[$1y]) Then
$1w[$1y] = Int($1w[$1y])
Else
$1w[$1y] = 0
EndIf
Next
Return 1
EndFunc
Func _3h($1o, $1z, $20)
If Not _37($1o & "/" & $1z & "/" & $20) Then
Return SetError(1, 0, "")
EndIf
Local $21 = Int((14 - $1z) / 12)
Local $22 = $1o - $21
Local $23 = $1z +(12 * $21) - 2
Local $24 = Mod($20 + $22 + Int($22 / 4) - Int($22 / 100) + Int($22 / 400) + Int((31 * $23) / 12), 7)
Return $24 + 1
EndFunc
Func _3j($1o, $1z, $20)
If Not _37(StringFormat("%04d/%02d/%02d", $1o, $1z, $20)) Then
Return SetError(1, 0, "")
EndIf
If $1z < 3 Then
$1z = $1z + 12
$1o = $1o - 1
EndIf
Local $21 = Int($1o / 100)
Local $25 = Int($21 / 4)
Local $26 = 2 - $21 + $25
Local $27 = Int(1461 *($1o + 4716) / 4)
Local $28 = Int(153 *($1z + 1) / 5)
Local $1h = $26 + $20 + $27 + $28 - 1524.5
Return $1h
EndFunc
Func _3k($29, $1m = Default)
If $1m = Default Then $1m = 0
$29 = Int($29)
If Not _36($29) Then Return SetError(1, 0, "")
Local $17 = DllStructCreate($h)
DllStructSetData($17, "Year", @YEAR)
DllStructSetData($17, "Month", $29)
DllStructSetData($17, "Day", 1)
Return _2e(BitAND($1m, $4) ? $15 : $14, $17, 0, BitAND($1m, $3) ? "MMM" : "MMMM")
EndFunc
Func _3l($1h, ByRef $1o, ByRef $1z, ByRef $20)
If $1h < 0 Or Not IsNumber($1h) Then
Return SetError(1, 0, 0)
EndIf
Local $2a = Int($1h + 0.5)
Local $2b = Int(($2a - 1867216.25) / 36524.25)
Local $2c = Int($2b / 4)
Local $21 = $2a + 1 + $2b - $2c
Local $25 = $21 + 1524
Local $26 = Int(($25 - 122.1) / 365.25)
Local $24 = Int(365.25 * $26)
Local $27 = Int(($25 - $24) / 30.6001)
Local $28 = Int(30.6001 * $27)
$20 = $25 - $24 - $28
If $27 - 1 < 13 Then
$1z = $27 - 1
Else
$1z = $27 - 13
EndIf
If $1z < 3 Then
$1o = $26 - 4715
Else
$1o = $26 - 4716
EndIf
$1o = StringFormat("%04d", $1o)
$1z = StringFormat("%02d", $1z)
$20 = StringFormat("%02d", $20)
Return $1o & "/" & $1z & "/" & $20
EndFunc
Func _3o()
Return _3f(@YEAR & "/" & @MON & "/" & @MDAY & " " & @HOUR & ":" & @MIN & ":" & @SEC, 0)
EndFunc
Func _3p()
Return @YEAR & "/" & @MON & "/" & @MDAY & " " & @HOUR & ":" & @MIN & ":" & @SEC
EndFunc
Func _3v($2d, ByRef $2e, ByRef $2f, ByRef $2g)
If Number($2d) > 0 Then
$2d = Int($2d / 1000)
$2e = Int($2d / 3600)
$2d = Mod($2d, 3600)
$2f = Int($2d / 60)
$2g = Mod($2d, 60)
Return 1
ElseIf Number($2d) = 0 Then
$2e = 0
$2d = 0
$2f = 0
$2g = 0
Return 1
Else
Return SetError(1, 0, 0)
EndIf
EndFunc
Func _3w($2e = @HOUR, $2f = @MIN, $2g = @SEC)
If StringIsInt($2e) And StringIsInt($2f) And StringIsInt($2g) Then
Local $2d = 1000 *((3600 * $2e) +(60 * $2f) + $2g)
Return $2d
Else
Return SetError(1, 0, 0)
EndIf
EndFunc
Func _3z($1o)
Local $2h = [12, 31,(_35($1o) ? 29 : 28), 31, 30, 31, 30, 31, 31, 30, 31, 30, 31]
Return $2h
EndFunc
Func _51($2i, $2j, $2k = 0, $2l = 0, $2m = 0, $2n = "wparam", $2o = "lparam", $2p = "lresult")
Local $2q = DllCall("user32.dll", $2p, "SendMessageW", "hwnd", $2i, "uint", $2j, $2n, $2k, $2o, $2l)
If @error Then Return SetError(@error, @extended, "")
If $2m >= 0 And $2m <= 4 Then Return $2q[$2m]
Return $2q
EndFunc
Global Const $2r = Ptr(-1)
Global Const $2s = Ptr(-1)
Global Const $2t = 0x0100
Global Const $2u = 0x2000
Global Const $2v = 0x8000
Global Const $2w = BitShift($2t, 8)
Global Const $2x = BitShift($2u, 8)
Global Const $2y = BitShift($2v, 8)
Global Const $2z = 0x8000000
Func _d0($30, $31)
Local $2q = DllCall("user32.dll", "hwnd", "FindWindowW", "wstr", $30, "wstr", $31)
If @error Then Return SetError(@error, @extended, 0)
Return $2q[0]
EndFunc
Func _hf($32, $18, $33 = 0, $34 = 0)
Local $35 = 'dword_ptr', $36 = 'dword_ptr'
If IsString($33) Then
$35 = 'wstr'
EndIf
If IsString($34) Then
$36 = 'wstr'
EndIf
DllCall('shell32.dll', 'none', 'SHChangeNotify', 'long', $32, 'uint', $18, $35, $33, $36, $34)
If @error Then Return SetError(@error, @extended, 0)
Return 1
EndFunc
Global Const $37 = 11
Global $38[$37]
Global Const $39 = "struct;uint Mask;int Item;int SubItem;uint State;uint StateMask;ptr Text;int TextMax;int Image;lparam Param;" & "int Indent;int GroupID;uint Columns;ptr pColumns;ptr piColFmt;int iGroup;endstruct"
#Au3Stripper_Ignore_Funcs=__ArrayDisplay_SortCallBack
Func __ArrayDisplay_SortCallBack($3a, $3b, $2i)
If $38[3] = $38[4] Then
If Not $38[7] Then
$38[5] *= -1
$38[7] = 1
EndIf
Else
$38[7] = 1
EndIf
$38[6] = $38[3]
Local $3c = _vr($2i, $3a, $38[3])
Local $3d = _vr($2i, $3b, $38[3])
If $38[8] = 1 Then
If(StringIsFloat($3c) Or StringIsInt($3c)) Then $3c = Number($3c)
If(StringIsFloat($3d) Or StringIsInt($3d)) Then $3d = Number($3d)
EndIf
Local $3e
If $38[8] < 2 Then
$3e = 0
If $3c < $3d Then
$3e = -1
ElseIf $3c > $3d Then
$3e = 1
EndIf
Else
$3e = DllCall('shlwapi.dll', 'int', 'StrCmpLogicalW', 'wstr', $3c, 'wstr', $3d)[0]
EndIf
$3e = $3e * $38[5]
Return $3e
EndFunc
Func _vr($2i, $3f, $3g = 0)
Local $3h = DllStructCreate("wchar Text[4096]")
Local $3i = DllStructGetPtr($3h)
Local $3j = DllStructCreate($39)
DllStructSetData($3j, "SubItem", $3g)
DllStructSetData($3j, "TextMax", 4096)
DllStructSetData($3j, "Text", $3i)
If IsHWnd($2i) Then
DllCall("user32.dll", "lresult", "SendMessageW", "hwnd", $2i, "uint", 0x1073, "wparam", $3f, "struct*", $3j)
Else
Local $3k = DllStructGetPtr($3j)
GUICtrlSendMsg($2i, 0x1073, $3f, $3k)
EndIf
Return DllStructGetData($3h, "Text")
EndFunc
Global Enum $3l, $3m, $3n, $3o, $3p, $3q, $3r, $3s
Func _vv(ByRef $3t, $3u, $3v = 0, $3w = "|", $3x = @CRLF, $3y = $3l)
If $3v = Default Then $3v = 0
If $3w = Default Then $3w = "|"
If $3x = Default Then $3x = @CRLF
If $3y = Default Then $3y = $3l
If Not IsArray($3t) Then Return SetError(1, 0, -1)
Local $3z = UBound($3t, $j)
Local $40 = 0
Switch $3y
Case $3n
$40 = Int
Case $3o
$40 = Number
Case $3p
$40 = Ptr
Case $3q
$40 = Hwnd
Case $3r
$40 = String
Case $3s
$40 = "Boolean"
EndSwitch
Switch UBound($3t, $i)
Case 1
If $3y = $3m Then
ReDim $3t[$3z + 1]
$3t[$3z] = $3u
Return $3z
EndIf
If IsArray($3u) Then
If UBound($3u, $i) <> 1 Then Return SetError(5, 0, -1)
$40 = 0
Else
Local $41 = StringSplit($3u, $3w, $f + $e)
If UBound($41, $j) = 1 Then
$41[0] = $3u
EndIf
$3u = $41
EndIf
Local $42 = UBound($3u, $j)
ReDim $3t[$3z + $42]
For $43 = 0 To $42 - 1
If String($40) = "Boolean" Then
Switch $3u[$43]
Case "True", "1"
$3t[$3z + $43] = True
Case "False", "0", ""
$3t[$3z + $43] = False
EndSwitch
ElseIf IsFunc($40) Then
$3t[$3z + $43] = $40($3u[$43])
Else
$3t[$3z + $43] = $3u[$43]
EndIf
Next
Return $3z + $42 - 1
Case 2
Local $44 = UBound($3t, $k)
If $3v < 0 Or $3v > $44 - 1 Then Return SetError(4, 0, -1)
Local $45, $46 = 0, $47
If IsArray($3u) Then
If UBound($3u, $i) <> 2 Then Return SetError(5, 0, -1)
$45 = UBound($3u, $j)
$46 = UBound($3u, $k)
$40 = 0
Else
Local $48 = StringSplit($3u, $3x, $f + $e)
$45 = UBound($48, $j)
Local $41[$45][0], $49
For $43 = 0 To $45 - 1
$49 = StringSplit($48[$43], $3w, $f + $e)
$47 = UBound($49)
If $47 > $46 Then
$46 = $47
ReDim $41[$45][$46]
EndIf
For $4a = 0 To $47 - 1
$41[$43][$4a] = $49[$4a]
Next
Next
$3u = $41
EndIf
If UBound($3u, $k) + $3v > UBound($3t, $k) Then Return SetError(3, 0, -1)
ReDim $3t[$3z + $45][$44]
For $4b = 0 To $45 - 1
For $4a = 0 To $44 - 1
If $4a < $3v Then
$3t[$4b + $3z][$4a] = ""
ElseIf $4a - $3v > $46 - 1 Then
$3t[$4b + $3z][$4a] = ""
Else
If String($40) = "Boolean" Then
Switch $3u[$4b][$4a - $3v]
Case "True", "1"
$3t[$4b + $3z][$4a] = True
Case "False", "0", ""
$3t[$4b + $3z][$4a] = False
EndSwitch
ElseIf IsFunc($40) Then
$3t[$4b + $3z][$4a] = $40($3u[$4b][$4a - $3v])
Else
$3t[$4b + $3z][$4a] = $3u[$4b][$4a - $3v]
EndIf
EndIf
Next
Next
Case Else
Return SetError(2, 0, -1)
EndSwitch
Return UBound($3t, $j) - 1
EndFunc
Func _we(Const ByRef $3t, $3u, $3v = 0, $4c = 0, $4d = 0, $4e = 0, $4f = 1, $3g = -1, $4g = False)
If $3v = Default Then $3v = 0
If $4c = Default Then $4c = 0
If $4d = Default Then $4d = 0
If $4e = Default Then $4e = 0
If $4f = Default Then $4f = 1
If $3g = Default Then $3g = -1
If $4g = Default Then $4g = False
If Not IsArray($3t) Then Return SetError(1, 0, -1)
Local $3z = UBound($3t) - 1
If $3z = -1 Then Return SetError(3, 0, -1)
Local $44 = UBound($3t, $k) - 1
Local $4h = False
If $4e = 2 Then
$4e = 0
$4h = True
EndIf
If $4g Then
If UBound($3t, $i) = 1 Then Return SetError(5, 0, -1)
If $4c < 1 Or $4c > $44 Then $4c = $44
If $3v < 0 Then $3v = 0
If $3v > $4c Then Return SetError(4, 0, -1)
Else
If $4c < 1 Or $4c > $3z Then $4c = $3z
If $3v < 0 Then $3v = 0
If $3v > $4c Then Return SetError(4, 0, -1)
EndIf
Local $4i = 1
If Not $4f Then
Local $4j = $3v
$3v = $4c
$4c = $4j
$4i = -1
EndIf
Switch UBound($3t, $i)
Case 1
If Not $4e Then
If Not $4d Then
For $43 = $3v To $4c Step $4i
If $4h And VarGetType($3t[$43]) <> VarGetType($3u) Then ContinueLoop
If $3t[$43] = $3u Then Return $43
Next
Else
For $43 = $3v To $4c Step $4i
If $4h And VarGetType($3t[$43]) <> VarGetType($3u) Then ContinueLoop
If $3t[$43] == $3u Then Return $43
Next
EndIf
Else
For $43 = $3v To $4c Step $4i
If $4e = 3 Then
If StringRegExp($3t[$43], $3u) Then Return $43
Else
If StringInStr($3t[$43], $3u, $4d) > 0 Then Return $43
EndIf
Next
EndIf
Case 2
Local $4k
If $4g Then
$4k = $3z
If $3g > $4k Then $3g = $4k
If $3g < 0 Then
$3g = 0
Else
$4k = $3g
EndIf
Else
$4k = $44
If $3g > $4k Then $3g = $4k
If $3g < 0 Then
$3g = 0
Else
$4k = $3g
EndIf
EndIf
For $4a = $3g To $4k
If Not $4e Then
If Not $4d Then
For $43 = $3v To $4c Step $4i
If $4g Then
If $4h And VarGetType($3t[$4a][$43]) <> VarGetType($3u) Then ContinueLoop
If $3t[$4a][$43] = $3u Then Return $43
Else
If $4h And VarGetType($3t[$43][$4a]) <> VarGetType($3u) Then ContinueLoop
If $3t[$43][$4a] = $3u Then Return $43
EndIf
Next
Else
For $43 = $3v To $4c Step $4i
If $4g Then
If $4h And VarGetType($3t[$4a][$43]) <> VarGetType($3u) Then ContinueLoop
If $3t[$4a][$43] == $3u Then Return $43
Else
If $4h And VarGetType($3t[$43][$4a]) <> VarGetType($3u) Then ContinueLoop
If $3t[$43][$4a] == $3u Then Return $43
EndIf
Next
EndIf
Else
For $43 = $3v To $4c Step $4i
If $4e = 3 Then
If $4g Then
If StringRegExp($3t[$4a][$43], $3u) Then Return $43
Else
If StringRegExp($3t[$43][$4a], $3u) Then Return $43
EndIf
Else
If $4g Then
If StringInStr($3t[$4a][$43], $3u, $4d) > 0 Then Return $43
Else
If StringInStr($3t[$43][$4a], $3u, $4d) > 0 Then Return $43
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
Func _x1($4l, $4m = "*", $4n = $n, $4o = False)
Local $4p = "|", $4q = "", $4r = "", $4s = ""
$4l = StringRegExpReplace($4l, "[\\/]+$", "") & "\"
If $4n = Default Then $4n = $n
If $4o Then $4s = $4l
If $4m = Default Then $4m = "*"
If Not FileExists($4l) Then Return SetError(1, 0, 0)
If StringRegExp($4m, "[\\/:><\|]|(?s)^\s*$") Then Return SetError(2, 0, 0)
If Not($4n = 0 Or $4n = 1 Or $4n = 2) Then Return SetError(3, 0, 0)
Local $4t = FileFindFirstFile($4l & $4m)
If @error Then Return SetError(4, 0, 0)
While 1
$4r = FileFindNextFile($4t)
If @error Then ExitLoop
If($4n + @extended = 2) Then ContinueLoop
$4q &= $4p & $4s & $4r
WEnd
FileClose($4t)
If $4q = "" Then Return SetError(4, 0, 0)
Return StringSplit(StringTrimLeft($4q, 1), $4p)
EndFunc
Func _xe($4l, ByRef $4u, ByRef $4v, ByRef $4r, ByRef $4w)
Local $3t = StringRegExp($4l, "^\h*((?:\\\\\?\\)*(\\\\[^\?\/\\]+|[A-Za-z]:)?(.*[\/\\]\h*)?((?:[^\.\/\\]|(?(?=\.[^\/\\]*\.)\.))*)?([^\/\\]*))$", $g)
If @error Then
ReDim $3t[5]
$3t[$o] = $4l
EndIf
$4u = $3t[$p]
If StringLeft($3t[$q], 1) == "/" Then
$4v = StringRegExpReplace($3t[$q], "\h*[\/\\]+\h*", "\/")
Else
$4v = StringRegExpReplace($3t[$q], "\h*[\/\\]+\h*", "\\")
EndIf
$3t[$q] = $4v
$4r = $3t[$r]
$4w = $3t[$s]
Return $3t
EndFunc
Local Const $4x = "0.0.9"
Local Const $4y[6] = ["040C", "080C", "0C0C", "100C", "140C", "180C"]
If _we($4y, @MUILang) <> 1 Then
Global $4z = "Supprimer des outils"
Global $50 = "Supprimer les points de restaurations"
Global $51 = "Créer un point de restauration"
Global $52 = "Sauvegarder le registre"
Global $53 = "Restaurer UAC"
Global $54 = "Restaurer les paramètres système"
Global $55 = "Exécuter"
Global $56 = "Toutes les opérations sont terminées"
Global $57 = "Echec"
Global $58 = "Impossible de créer une sauvegarde du registre"
Global $59 = "Vous devez exécuter le programme avec les droits administrateurs"
Global $5a = "Vous devez fermer MalwareBytes Anti-Rootkit avant de continuer"
Else
Global $4z = "Delete Tools"
Global $50 = "Delete Restore Points"
Global $51 = "Create Restore Point"
Global $52 = "Registry Backup"
Global $53 = "UAC Restore"
Global $54 = "Restore System Settings"
Global $55 = "Run"
Global $56 = "All operations are completed"
Global $57 = "Fail"
Global $58 = "Unable to create a registry backup"
Global $59 = "You must run the program with administrator rights"
Global $5a = "You must close MalwareBytes Anti-Rootkit before continuing"
EndIf
Global Const $5b = 1
Global Const $5c = 5
Global Const $5d = 0
Global Const $5e = 1
Func _xr($5f = $5c)
If Not IsAdmin() Then Return SetError(-3, 0, -1)
If StringRegExp(@OSVersion, "_(XP|200(0|3))") Then Return SetError(-4, 0, -1)
Local $5g = ""
If @OSArch = "X64" Then $5g = "64"
If $5f < 0 Or $5f > 5 Then Return SetError(-5, 0, -1)
Local $2m = RegWrite("HKEY_LOCAL_MACHINE" & $5g & "\Software\Microsoft\Windows\CurrentVersion\Policies\System", "ConsentPromptBehaviorAdmin", "REG_DWORD", $5f)
If $2m = 0 Then $2m = -1
Return SetError(@error, 0, $2m)
EndFunc
Func _xs($5f = $5b)
If Not IsAdmin() Then Return SetError(-3, 0, -1)
If StringRegExp(@OSVersion, "_(XP|200(0|3))") Then Return SetError(-4, 0, -1)
If $5f < 0 Or $5f = 2 Or $5f > 3 Then Return SetError(-5, 0, -1)
Local $5g = ""
If @OSArch = "X64" Then $5g = "64"
Local $2m = RegWrite("HKEY_LOCAL_MACHINE" & $5g & "\Software\Microsoft\Windows\CurrentVersion\Policies\System", "ConsentPromptBehaviorUser", "REG_DWORD", $5f)
If $2m = 0 Then $2m = -1
Return SetError(@error, 0, $2m)
EndFunc
Func _xt($5f = $5d)
If Not IsAdmin() Then Return SetError(-3, 0, -1)
If StringRegExp(@OSVersion, "_(XP|200(0|3))") Then Return SetError(-4, 0, -1)
If $5f < 0 Or $5f > 1 Then Return SetError(-5, 0, -1)
Local $5g = ""
If @OSArch = "X64" Then $5g = "64"
Local $2m = RegWrite("HKEY_LOCAL_MACHINE" & $5g & "\Software\Microsoft\Windows\CurrentVersion\Policies\System", "EnableInstallerDetection", "REG_DWORD", $5f)
If $2m = 0 Then $2m = -1
Return SetError(@error, 0, $2m)
EndFunc
Func _xu($5f = $5e)
If Not IsAdmin() Then Return SetError(-3, 0, -1)
If StringRegExp(@OSVersion, "_(XP|200(0|3))") Then Return SetError(-4, 0, -1)
If $5f < 0 Or $5f > 1 Then Return SetError(-5, 0, -1)
Local $5g = ""
If @OSArch = "X64" Then $5g = "64"
Local $2m = RegWrite("HKEY_LOCAL_MACHINE" & $5g & "\Software\Microsoft\Windows\CurrentVersion\Policies\System", "EnableLUA", "REG_DWORD", $5f)
If $2m = 0 Then $2m = -1
Return SetError(@error, 0, $2m)
EndFunc
Func _xv($5f = $5e)
If Not IsAdmin() Then Return SetError(-3, 0, -1)
If StringRegExp(@OSVersion, "_(XP|200(0|3))") Then Return SetError(-4, 0, -1)
If $5f < 0 Or $5f > 1 Then Return SetError(-5, 0, -1)
Local $5g = ""
If @OSArch = "X64" Then $5g = "64"
Local $2m = RegWrite("HKEY_LOCAL_MACHINE" & $5g & "\Software\Microsoft\Windows\CurrentVersion\Policies\System", "EnableSecureUIAPaths", "REG_DWORD", $5f)
If $2m = 0 Then $2m = -1
Return SetError(@error, 0, $2m)
EndFunc
Func _xw($5f = $5d)
If Not IsAdmin() Then Return SetError(-3, 0, -1)
If StringRegExp(@OSVersion, "_(XP|200(0|3))") Then Return SetError(-4, 0, -1)
If $5f < 0 Or $5f > 1 Then Return SetError(-5, 0, -1)
Local $5g = ""
If @OSArch = "X64" Then $5g = "64"
Local $2m = RegWrite("HKEY_LOCAL_MACHINE" & $5g & "\Software\Microsoft\Windows\CurrentVersion\Policies\System", "EnableUIADesktopToggle", "REG_DWORD", $5f)
If $2m = 0 Then $2m = -1
Return SetError(@error, 0, $2m)
EndFunc
Func _xx($5f = $5e)
If Not IsAdmin() Then Return SetError(-3, 0, -1)
If StringRegExp(@OSVersion, "_(XP|200(0|3))") Then Return SetError(-4, 0, -1)
If $5f < 0 Or $5f > 1 Then Return SetError(-5, 0, -1)
Local $5g = ""
If @OSArch = "X64" Then $5g = "64"
Local $2m = RegWrite("HKEY_LOCAL_MACHINE" & $5g & "\Software\Microsoft\Windows\CurrentVersion\Policies\System", "EnableVirtualization", "REG_DWORD", $5f)
If $2m = 0 Then $2m = -1
Return SetError(@error, 0, $2m)
EndFunc
Func _xy($5f = $5d)
If Not IsAdmin() Then Return SetError(-3, 0, -1)
If StringRegExp(@OSVersion, "_(XP|200(0|3))") Then Return SetError(-4, 0, -1)
If $5f < 0 Or $5f > 1 Then Return SetError(-5, 0, -1)
Local $5g = ""
If @OSArch = "X64" Then $5g = "64"
Local $2m = RegWrite("HKEY_LOCAL_MACHINE" & $5g & "\Software\Microsoft\Windows\CurrentVersion\Policies\System", "FilterAdministratorToken", "REG_DWORD", $5f)
If $2m = 0 Then $2m = -1
Return SetError(@error, 0, $2m)
EndFunc
Func _xz($5f = $5e)
If Not IsAdmin() Then Return SetError(-3, 0, -1)
If StringRegExp(@OSVersion, "_(XP|200(0|3))") Then Return SetError(-4, 0, -1)
If $5f < 0 Or $5f > 1 Then Return SetError(-5, 0, -1)
Local $5g = ""
If @OSArch = "X64" Then $5g = "64"
Local $2m = RegWrite("HKEY_LOCAL_MACHINE" & $5g & "\Software\Microsoft\Windows\CurrentVersion\Policies\System", "PromptOnSecureDesktop", "REG_DWORD", $5f)
If $2m = 0 Then $2m = -1
Return SetError(@error, 0, $2m)
EndFunc
Func _y0($5f = $5d)
If Not IsAdmin() Then Return SetError(-3, 0, -1)
If StringRegExp(@OSVersion, "_(XP|200(0|3))") Then Return SetError(-4, 0, -1)
If $5f < 0 Or $5f > 1 Then Return SetError(-5, 0, -1)
Local $5g = ""
If @OSArch = "X64" Then $5g = "64"
Local $2m = RegWrite("HKEY_LOCAL_MACHINE" & $5g & "\Software\Microsoft\Windows\CurrentVersion\Policies\System", "ValidateAdminCodeSignatures", "REG_DWORD", $5f)
If $2m = 0 Then $2m = -1
Return SetError(@error, 0, $2m)
EndFunc
Global $5h = Null, $5i = Null
Global $5j = EnvGet('SystemDrive') & '\'
Func _y2()
Local $5k[1][3], $5l = 0
$5k[0][0] = $5l
If Not IsObj($5i) Then $5i = ObjGet("winmgmts:root/default")
If Not IsObj($5i) Then Return $5k
Local $5m = $5i.InstancesOf("SystemRestore")
If Not IsObj($5m) Then Return $5k
For $5n In $5m
$5l += 1
ReDim $5k[$5l + 1][3]
$5k[$5l][0] = $5n.SequenceNumber
$5k[$5l][1] = $5n.Description
$5k[$5l][2] = _y3($5n.CreationTime)
Next
$5k[0][0] = $5l
Return $5k
EndFunc
Func _y3($5o)
Return(StringMid($5o, 5, 2) & "/" & StringMid($5o, 7, 2) & "/" & StringLeft($5o, 4) & " " & StringMid($5o, 9, 2) & ":" & StringMid($5o, 11, 2) & ":" & StringMid($5o, 13, 2))
EndFunc
Func _y4($5p)
Local $w = DllCall('SrClient.dll', 'DWORD', 'SRRemoveRestorePoint', 'DWORD', $5p)
If @error Then Return SetError(1, 0, 0)
If $w[0] = 0 Then Return 1
Return SetError(1, 0, 0)
EndFunc
Func _y6($5q = $5j)
If Not IsObj($5h) Then $5h = ObjGet("winmgmts:{impersonationLevel=impersonate}!root/default:SystemRestore")
If Not IsObj($5h) Then Return 0
If $5h.Enable($5q) = 0 Then Return 1
Return 0
EndFunc
Global Enum $5r = 0, $5s, $5t, $5u, $5v, $5w, $5x, $5y, $5z, $60, $61, $62, $63
Global Const $64 = 2
Global $65 = @SystemDir&'\Advapi32.dll'
Global $66 = @SystemDir&'\Kernel32.dll'
Global $67[4][2], $68[4][2]
Global $69 = 0
Func _y9()
$65 = DllOpen(@SystemDir&'\Advapi32.dll')
$66 = DllOpen(@SystemDir&'\Kernel32.dll')
$67[0][0] = "SeRestorePrivilege"
$67[0][1] = 2
$67[1][0] = "SeTakeOwnershipPrivilege"
$67[1][1] = 2
$67[2][0] = "SeDebugPrivilege"
$67[2][1] = 2
$67[3][0] = "SeSecurityPrivilege"
$67[3][1] = 2
$68 = _zh($67)
$69 = 1
EndFunc
Func _yf($6a, $6b = $5s, $6c = 'Administrators', $6d = 1)
Local $6e[1][3]
$6e[0][0] = 'Everyone'
$6e[0][1] = 1
$6e[0][2] = $m
Return _yi($6a, $6e, $6b, $6c, 1, $6d)
EndFunc
Func _yi($6a, $6f, $6b = $5s, $6c = '', $6g = 0, $6d = 0, $6h = 3)
If $69 = 0 Then _y9()
If Not IsArray($6f) Or UBound($6f,2) < 3 Then Return SetError(1,0,0)
Local $6i = _yn($6f,$6h)
Local $6j = @extended
Local $6k = 4, $6l = 0
If $6c <> '' Then
If Not IsDllStruct($6c) Then $6c = _za($6c)
$6l = DllStructGetPtr($6c)
If $6l And _zg($6l) Then
$6k = 5
Else
$6l = 0
EndIf
EndIf
If Not IsPtr($6a) And $6b = $5s Then
Return _yv($6a, $6i, $6l, $6g, $6d, $6j, $6k)
ElseIf Not IsPtr($6a) And $6b = $5v Then
Return _yw($6a, $6i, $6l, $6g, $6d, $6j, $6k)
Else
If $6g Then _yx($6a,$6b)
Return _yo($6a, $6b, $6k, $6l, 0, $6i,0)
EndIf
EndFunc
Func _yn(ByRef $6f, ByRef $6h)
Local $6m = UBound($6f,2)
If Not IsArray($6f) Or $6m < 3 Then Return SetError(1,0,0)
Local $6n = UBound($6f), $6o[$6n], $6p = 0, $6q = 1
Local $6r, $6j = 0, $6s
Local $6t, $6u = 'DWORD;DWORD;DWORD;ptr;DWORD;DWORD;DWORD;ptr'
For $43 = 1 To $6n - 1
$6u &= ';DWORD;DWORD;DWORD;ptr;DWORD;DWORD;DWORD;ptr'
Next
$6t = DllStructCreate($6u)
For $43 = 0 To $6n -1
If Not IsDllStruct($6f[$43][0]) Then $6f[$43][0] = _za($6f[$43][0])
$6o[$43] = DllStructGetPtr($6f[$43][0])
If Not _zg($6o[$43]) Then ContinueLoop
DllStructSetData($6t,$6p+1,$6f[$43][2])
If $6f[$43][1] = 0 Then
$6j = 1
$6r = $8
Else
$6r = $7
EndIf
If $6m > 3 Then $6h = $6f[$43][3]
DllStructSetData($6t,$6p+2,$6r)
DllStructSetData($6t,$6p+3,$6h)
DllStructSetData($6t,$6p+6,0)
$6s = DllCall($65,'BOOL','LookupAccountSid','ptr',0,'ptr',$6o[$43],'ptr*',0,'dword*',32,'ptr*',0,'dword*',32,'dword*',0)
If Not @error Then $6q = $6s[7]
DllStructSetData($6t,$6p+7,$6q)
DllStructSetData($6t,$6p+8,$6o[$43])
$6p += 8
Next
Local $6v = DllStructGetPtr($6t)
$6s = DllCall($65,'DWORD','SetEntriesInAcl','ULONG',$6n,'ptr',$6v ,'ptr',0,'ptr*',0)
If @error Or $6s[0] Then Return SetError(1,0,0)
Return SetExtended($6j, $6s[4])
EndFunc
Func _yo($6a, $6b, $6k, $6l = 0, $6w = 0, $6i = 0, $6x = 0)
Local $6s
If $69 = 0 Then _y9()
If $6i And Not _yp($6i) Then Return 0
If $6x And Not _yp($6x) Then Return 0
If IsPtr($6a) Then
$6s = DllCall($65,'dword','SetSecurityInfo','handle',$6a,'dword',$6b, 'dword',$6k,'ptr',$6l,'ptr',$6w,'ptr',$6i,'ptr',$6x)
Else
If $6b = $5v Then $6a = _zb($6a)
$6s = DllCall($65,'dword','SetNamedSecurityInfo','str',$6a,'dword',$6b, 'dword',$6k,'ptr',$6l,'ptr',$6w,'ptr',$6i,'ptr',$6x)
EndIf
If @error Then Return SetError(1,0,0)
If $6s[0] And $6l Then
If _z0($6a, $6b,_zf($6l)) Then Return _yo($6a, $6b, $6k - 1, 0, $6w, $6i, $6x)
EndIf
Return SetError($6s[0] , 0, Number($6s[0] = 0))
EndFunc
Func _yp($6y)
If $6y = 0 Then Return SetError(1,0,0)
Local $6s = DllCall($65,'bool','IsValidAcl','ptr',$6y)
If @error Or Not $6s[0] Then Return 0
Return 1
EndFunc
Func _yv($6a, ByRef $6i, ByRef $6l, ByRef $6g, ByRef $6d, ByRef $6j, ByRef $6k)
Local $6z, $70
If Not $6j Then
If $6g Then _yx($6a,$5s)
$6z = _yo($6a, $5s, $6k, $6l, 0, $6i,0)
EndIf
If $6d Then
Local $71 = FileFindFirstFile($6a&'\*')
While 1
$70 = FileFindNextFile($71)
If $6d = 1 Or $6d = 2 And @extended = 1 Then
_yv($6a&'\'&$70, $6i, $6l, $6g, $6d, $6j,$6k)
ElseIf @error Then
ExitLoop
ElseIf $6d = 1 Or $6d = 3 Then
If $6g Then _yx($6a&'\'&$70,$5s)
_yo($6a&'\'&$70, $5s, $6k, $6l, 0, $6i,0)
EndIf
WEnd
FileClose($71)
EndIf
If $6j Then
If $6g Then _yx($6a,$5s)
$6z = _yo($6a, $5s, $6k, $6l, 0, $6i,0)
EndIf
Return $6z
EndFunc
Func _yw($6a, ByRef $6i, ByRef $6l, ByRef $6g, ByRef $6d, ByRef $6j, ByRef $6k)
If $69 = 0 Then _y9()
Local $6z, $43 = 0, $70
If Not $6j Then
If $6g Then _yx($6a,$5v)
$6z = _yo($6a, $5v, $6k, $6l, 0, $6i,0)
EndIf
If $6d Then
While 1
$43 += 1
$70 = RegEnumKey($6a,$43)
If @error Then ExitLoop
_yw($6a&'\'&$70, $6i, $6l, $6g, $6d, $6j, $6k)
WEnd
EndIf
If $6j Then
If $6g Then _yx($6a,$5v)
$6z = _yo($6a, $5v, $6k, $6l, 0, $6i,0)
EndIf
Return $6z
EndFunc
Func _yx($6a, $6b = $5s)
If $69 = 0 Then _y9()
Local $72 = DllStructCreate('byte[32]'), $w
Local $6i = DllStructGetPtr($72,1)
DllCall($65,'bool','InitializeAcl','Ptr',$6i,'dword',DllStructGetSize($72),'dword',$64)
If IsPtr($6a) Then
$w = DllCall($65,"dword","SetSecurityInfo",'handle',$6a,'dword',$6b,'dword',4,'ptr',0,'ptr',0,'ptr',$6i,'ptr',0)
Else
If $6b = $5v Then $6a = _zb($6a)
DllCall($65,'DWORD','SetNamedSecurityInfo','str',$6a,'dword',$6b,'DWORD',4,'ptr',0,'ptr',0,'ptr',0,'ptr',0)
$w = DllCall($65,'DWORD','SetNamedSecurityInfo','str',$6a,'dword',$6b,'DWORD',4,'ptr',0,'ptr',0,'ptr',$6i,'ptr',0)
EndIf
If @error Then Return SetError(@error,0,0)
Return SetError($w[0],0,Number($w[0] = 0))
EndFunc
Func _z0($6a, $6b = $5s, $73 = 'Administrators')
If $69 = 0 Then _y9()
Local $74 = _za($73), $w
Local $6o = DllStructGetPtr($74)
If IsPtr($6a) Then
$w = DllCall($65,"dword","SetSecurityInfo",'handle',$6a,'dword',$6b,'dword',1,'ptr',$6o,'ptr',0,'ptr',0,'ptr',0)
Else
If $6b = $5v Then $6a = _zb($6a)
$w = DllCall($65,'DWORD','SetNamedSecurityInfo','str',$6a,'dword',$6b,'DWORD',1,'ptr',$6o,'ptr',0,'ptr',0,'ptr',0)
EndIf
If @error Then Return SetError(@error,0,False)
Return SetError($w[0],0,Number($w[0] = 0))
EndFunc
Func _za($73)
If $73 = 'TrustedInstaller' Then $73 = 'NT SERVICE\TrustedInstaller'
If $73 = 'Everyone' Then
Return _zd('S-1-1-0')
ElseIf $73 = 'Authenticated Users' Then
Return _zd('S-1-5-11')
ElseIf $73 = 'System' Then
Return _zd('S-1-5-18')
ElseIf $73 = 'Administrators' Then
Return _zd('S-1-5-32-544')
ElseIf $73 = 'Users' Then
Return _zd('S-1-5-32-545')
ElseIf $73 = 'Guests' Then
Return _zd('S-1-5-32-546')
ElseIf $73 = 'Power Users' Then
Return _zd('S-1-5-32-547')
ElseIf $73 = 'Local Authority' Then
Return _zd('S-1-2')
ElseIf $73 = 'Creator Owner' Then
Return _zd('S-1-3-0')
ElseIf $73 = 'NT Authority' Then
Return _zd('S-1-5-1')
ElseIf $73 = 'Restricted' Then
Return _zd('S-1-5-12')
ElseIf StringRegExp($73,'\A(S-1-\d+(-\d+){0,5})\z') Then
Return _zd($73)
Else
Local $74 = _zc($73)
Return _zd($74)
EndIf
EndFunc
Func _zb($75)
If StringInStr($75,'\\') = 1 Then
$75 = StringRegExpReplace($75,'(?i)\\(HKEY_CLASSES_ROOT|HKCR)','\CLASSES_ROOT')
$75 = StringRegExpReplace($75,'(?i)\\(HKEY_CURRENT_USER|HKCU)','\CURRENT_USER')
$75 = StringRegExpReplace($75,'(?i)\\(HKEY_LOCAL_MACHINE|HKLM)','\MACHINE')
$75 = StringRegExpReplace($75,'(?i)\\(HKEY_USERS|HKU)','\USERS')
Else
$75 = StringRegExpReplace($75,'(?i)\A(HKEY_CLASSES_ROOT|HKCR)','CLASSES_ROOT')
$75 = StringRegExpReplace($75,'(?i)\A(HKEY_CURRENT_USER|HKCU)','CURRENT_USER')
$75 = StringRegExpReplace($75,'(?i)\A(HKEY_LOCAL_MACHINE|HKLM)','MACHINE')
$75 = StringRegExpReplace($75,'(?i)\A(HKEY_USERS|HKU)','USERS')
EndIf
Return $75
EndFunc
Func _zc($76, $77 = "")
Local $78 = DllStructCreate("byte SID[256]")
Local $6o = DllStructGetPtr($78, "SID")
Local $2q = DllCall($65, "bool", "LookupAccountNameW", "wstr", $77, "wstr", $76, "ptr", $6o, "dword*", 256, "wstr", "", "dword*", 256, "int*", 0)
If @error Then Return SetError(@error, @extended, 0)
If Not $2q[0] Then Return 0
Return _zf($6o)
EndFunc
Func _zd($79)
Local $2q = DllCall($65, "bool", "ConvertStringSidToSidW", "wstr", $79, "ptr*", 0)
If @error Then Return SetError(@error, @extended, 0)
If Not $2q[0] Then Return 0
Local $7a = _ze($2q[2])
Local $3h = DllStructCreate("byte Data[" & $7a & "]", $2q[2])
Local $7b = DllStructCreate("byte Data[" & $7a & "]")
DllStructSetData($7b, "Data", DllStructGetData($3h, "Data"))
DllCall($66, "ptr", "LocalFree", "ptr", $2q[2])
Return $7b
EndFunc
Func _ze($6o)
If Not _zg($6o) Then Return SetError(-1, 0, "")
Local $2q = DllCall($65, "dword", "GetLengthSid", "ptr", $6o)
If @error Then Return SetError(@error, @extended, 0)
Return $2q[0]
EndFunc
Func _zf($6o)
If Not _zg($6o) Then Return SetError(-1, 0, "")
Local $2q = DllCall($65, "int", "ConvertSidToStringSidW", "ptr", $6o, "ptr*", 0)
If @error Then Return SetError(@error, @extended, "")
If Not $2q[0] Then Return ""
Local $3h = DllStructCreate("wchar Text[256]", $2q[2])
Local $79 = DllStructGetData($3h, "Text")
DllCall($66, "ptr", "LocalFree", "ptr", $2q[2])
Return $79
EndFunc
Func _zg($6o)
Local $2q = DllCall($65, "bool", "IsValidSid", "ptr", $6o)
If @error Then Return SetError(@error, @extended, False)
Return $2q[0]
EndFunc
Func _zh($7c)
Local $7d = UBound($7c, 0), $7e[1][2]
If Not($7d <= 2 And UBound($7c, $7d) = 2 ) Then Return SetError(1300, 0, $7e)
If $7d = 1 Then
Local $7f[1][2]
$7f[0][0] = $7c[0]
$7f[0][1] = $7c[1]
$7c = $7f
$7f = 0
EndIf
Local $7g, $7h = "dword", $7i = UBound($7c, 1)
Do
$7g += 1
$7h &= ";dword;long;dword"
Until $7g = $7i
Local $7j, $7k, $7l, $7m, $7n, $7o, $7p
$7j = DLLStructCreate($7h)
$7k = DllStructCreate($7h)
$7l = DllStructGetPtr($7k)
$7m = DllStructCreate("dword;long")
DLLStructSetData($7j, 1, $7i)
For $43 = 0 To $7i - 1
DllCall($65, "int", "LookupPrivilegeValue", "str", "", "str", $7c[$43][0], "ptr", DllStructGetPtr($7m) )
DLLStructSetData( $7j, 3 * $43 + 2, DllStructGetData($7m, 1) )
DLLStructSetData( $7j, 3 * $43 + 3, DllStructGetData($7m, 2) )
DLLStructSetData( $7j, 3 * $43 + 4, $7c[$43][1] )
Next
$7n = DllCall($66, "hwnd", "GetCurrentProcess")
$7o = DllCall($65, "int", "OpenProcessToken", "hwnd", $7n[0], "dword", BitOR(0x00000020, 0x00000008), "hwnd*", 0 )
DllCall( $65, "int", "AdjustTokenPrivileges", "hwnd", $7o[3], "int", False, "ptr", DllStructGetPtr($7j), "dword", DllStructGetSize($7j), "ptr", $7l, "dword*", 0 )
$7p = DllCall($66, "dword", "GetLastError")
DllCall($66, "int", "CloseHandle", "hwnd", $7o[3])
Local $7q = DllStructGetData($7k, 1)
If $7q > 0 Then
Local $7r, $7s, $7t, $7e[$7q][2]
For $43 = 0 To $7q - 1
$7r = $7l + 12 * $43 + 4
$7s = DllCall($65, "int", "LookupPrivilegeName", "str", "", "ptr", $7r, "ptr", 0, "dword*", 0 )
$7t = DllStructCreate("char[" & $7s[4] & "]")
DllCall($65, "int", "LookupPrivilegeName", "str", "", "ptr", $7r, "ptr", DllStructGetPtr($7t), "dword*", DllStructGetSize($7t) )
$7e[$43][0] = DllStructGetData($7t, 1)
$7e[$43][1] = DllStructGetData($7k, 3 * $43 + 4)
Next
EndIf
Return SetError($7p[0], 0, $7e)
EndFunc
Func _zi()
FileDelete(@TempDir & "\kprm-logo.gif")
Exit
EndFunc
If Not IsAdmin() Then
MsgBox(16, $57, $59)
_zi()
EndIf
Local $7u = ProcessList("mbar.exe")
If $7u[0][0] > 0 Then
MsgBox(16, $57, $5a)
_zi()
EndIf
Func _zj($7v)
Dim $7w
FileWrite(@DesktopDir & "\" & $7w, $7v & @CRLF)
FileWrite(@HomeDrive & "\KPRM" & "\" & $7w, $7v & @CRLF)
EndFunc
Func _zk()
Local $7x = 100, $7y = 100, $7z = 0, $80 = @WindowsDir & "\Explorer.exe"
_hf($2z, 0, 0, 0)
Local $81 = _d0("Shell_TrayWnd", "")
_51($81, 1460, 0, 0)
While ProcessExists("Explorer.exe")
Sleep(10)
$7x -= ProcessClose("Explorer.exe") ? 0 : 1
If $7x < 1 Then Return SetError(1, 0, 0)
WEnd
While(Not ProcessExists("Explorer.exe"))
If Not FileExists($80) Then Return SetError(-1, 0, 0)
Sleep(500)
$7z = ShellExecute($80)
$7y -= $7z ? 0 : 1
If $7y < 1 Then Return SetError(2, 0, 0)
WEnd
Return $7z
EndFunc
Func _zn($82, $83, $84)
Local $43 = 0
While True
$43 += 1
Local $85 = RegEnumKey($82, $43)
If @error <> 0 Then ExitLoop
Local $86 = $82 & "\" & $85
Local $70 = RegRead($86, $84)
If StringRegExp($70, $83) Then
Return $86
EndIf
WEnd
Return Null
EndFunc
Func _zp()
Local $87 = []
If FileExists(@HomeDrive & "\Program Files") Then
_vv($87, @HomeDrive & "\Program Files")
EndIf
If FileExists(@HomeDrive & "\Program Files (x86)") Then
_vv($87, @HomeDrive & "\Program Files (x86)")
EndIf
If FileExists(@HomeDrive & "\Program Files(x86)") Then
_vv($87, @HomeDrive & "\Program Files(x86)")
EndIf
Return $87
EndFunc
Func _zq($4l)
Return Int(FileExists($4l) And StringInStr(FileGetAttrib($4l), 'D', Default, 1) = 0)
EndFunc
Func _zr($4l)
Return Int(FileExists($4l) And StringInStr(FileGetAttrib($4l), 'D', Default, 1) > 0)
EndFunc
Func _zs($4l)
Local $88 = Null
If FileExists($4l) Then
Local $89 = StringInStr(FileGetAttrib($4l), 'D', Default, 1)
If $89 = 0 Then
$88 = 'file'
ElseIf $89 > 0 Then
$88 = 'folder'
EndIf
EndIf
Return $88
EndFunc
Func _zt()
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
Func _zu($84)
If StringRegExp($84, "^(HKLM|HKCU|HKU|HKCR|HKCC)64") Then
Local $8a = StringReplace($84, "64", "", 1)
Return $8a
EndIf
Return $84
EndFunc
Func _zv($8b, $84)
If $8b.Exists($84) Then
Local $89 = $8b.Item($84) + 1
$8b.Item($84) = $89
Else
$8b.add($84, 1)
EndIf
Return $8b
EndFunc
Func _zw($8c, $8d, $8e)
Dim $8f
Local $8g = $8f.Item($8c)
Local $8h = _zv($8g.Item($8d), $8e)
$8g.Item($8d) = $8h
$8f.Item($8c) = $8g
EndFunc
Func _zx($8i, $8j)
If $8i = Null Or $8i = "" Then Return
Local $8k = ProcessExists($8i)
If $8k <> 0 Then
_zj("     [!] Process " & $8i & " exists, it is possible that the deletion is not complete (" & $8j & ")")
EndIf
EndFunc
Func _zy($8l, $8j)
If $8l = Null Or $8l = "" Then Return
Local $8m = "[X]"
RegEnumVal($8l, "1")
If @error >= 0 Then
$8m = "[OK]"
EndIf
_zj("     " & $8m & " " & _zu($8l) & " deleted (" & $8j & ")")
EndFunc
Func _0zz($8l, $8j)
If $8l = Null Or $8l = "" Then Return
Local $4u = "", $4v = "", $4r = "", $4w = ""
Local $8n = _xe($8l, $4u, $4v, $4r, $4w)
If $4w = ".exe" Then
Local $8o = $8n[1] & $8n[2]
Local $8m = "[OK]"
If FileExists($8o) Then
$8m = "[X]"
EndIf
_zj("     " & $8m & " Uninstaller run correctly (" & $8j & ")")
EndIf
EndFunc
Func _100($8l, $8j)
If $8l = Null Or $8l = "" Then Return
Local $8m = "[OK]"
If FileExists($8l) Then
$8m = "[X]"
EndIf
_zj("     " & $8m & " " & $8l & " deleted (" & $8j & ")")
EndFunc
Func _101($8p, $8l, $8j)
Switch $8p
Case "process"
_zx($8l, $8j)
Case "key"
_zy($8l, $8j)
Case "uninstall"
_0zz($8l, $8j)
Case "element"
_100($8l, $8j)
Case Else
_zj("     [?] Unknown type " & $8p)
EndSwitch
EndFunc
Local $8q = 39
Local $8r
Local Const $8s = Floor(100 / $8q)
Func _102($8t = 1)
$8r += $8t
Dim $8u
GUICtrlSetData($8u, $8r * $8s)
If $8r = $8q Then
GUICtrlSetData($8u, 100)
EndIf
EndFunc
Func _103()
$8r = 0
Dim $8u
GUICtrlSetData($8u, 0)
EndFunc
Func _104()
_zj(@CRLF & "- Clear All System Restore Points -" & @CRLF)
Local Const $8v = _y2()
Local $6z = 0
If $8v[0][0] = 0 Then
_zj("  [I] No system recovery points were found")
Return Null
EndIf
Local $8w[1][3] = [[Null, Null, Null]]
For $43 = 1 To $8v[0][0]
Local $8k = _y4($8v[$43][0])
$6z += $8k
If $8k = 1 Then
_zj("    => [OK] RP named " & $8v[$43][1] & " created at " & $8v[$43][2] & " deleted")
Else
Local $8x[1][3] = [[$8v[$43][0], $8v[$43][1], $8v[$43][2]]]
_vv($8w, $8x)
EndIf
Next
If 1 < UBound($8w) Then
Sleep(3000)
For $43 = 1 To UBound($8w) - 1
Local $8k = _y4($8w[$43][0])
$6z += $8k
If $8k = 1 Then
_zj("    => [OK] RP named " & $8w[$43][1] & " created at " & $8v[$43][2] & " deleted")
Else
_zj("    => [X] RP named " & $8w[$43][1] & " created at " & $8v[$43][2] & " deleted")
EndIf
Next
EndIf
If $8v[0][0] = $6z Then
_zj(@CRLF & "  [OK] All system restore points have been successfully deleted")
Else
_zj(@CRLF & "  [X] Failure when deleting all restore points")
EndIf
EndFunc
Func _105($5o)
Local $8y = StringLeft($5o, 4)
Local $8z = StringMid($5o, 6, 2)
Local $90 = StringMid($5o, 9, 2)
Local $91 = StringRight($5o, 8)
Return $8z & "/" & $90 & "/" & $8y & " " & $91
EndFunc
Func _106($92 = False)
Local Const $8v = _y2()
If $8v[0][0] = 0 Then
Return Null
EndIf
Local Const $93 = _105(_31('n', -1470, _3p()))
Local $94 = False
Local $95 = False
Local $96 = False
For $43 = 1 To $8v[0][0]
Local $97 = $8v[$43][2]
If $97 > $93 Then
If $96 = False Then
$96 = True
$95 = True
_zj(@CRLF & "  [I] Recent System Restore Point Deletion before create new:" & @CRLF)
EndIf
Local $8k = _y4($8v[$43][0])
If $8k = 1 Then
_zj("    => [OK] RP named " & $8v[$43][1] & " created at " & $97 & " deleted")
ElseIf $92 = False Then
$94 = True
Else
_zj("    => [X] RP named " & $8v[$43][1] & " created at " & $97 & " deleted")
EndIf
EndIf
Next
If $94 = True Then
Sleep(3000)
_zj("  [I] Retry deleting restore point")
_106(True)
EndIf
If $95 = True Then
_zj(@CRLF)
EndIf
Sleep(3000)
EndFunc
Func _107()
Sleep(3000)
_zj(@CRLF & "- Display All System Restore Point -" & @CRLF)
Local Const $8v = _y2()
If $8v[0][0] = 0 Then
_zj("  [X] No System Restore point found")
Return
EndIf
For $43 = 1 To $8v[0][0]
_zj("    => [I] RP named " & $8v[$43][1] & " created at " & $8v[$43][2] & " found")
Next
EndFunc
Func _108()
RunWait(@ComSpec & ' /c ' & 'wmic.exe /Namespace:\\root\default Path SystemRestore Call CreateRestorePoint "KpRm", 100, 7', "", @SW_HIDE)
Return @error
EndFunc
Func _109($92 = False)
If $92 = False Then
_zj(@CRLF & "- Create New System Restore Point -" & @CRLF)
Else
_zj("  [I] Retry Create New System Restore Point")
EndIf
Dim $98
Local $99 = _y6()
If $99 = 0 Then
Sleep(3000)
$99 = _y6()
If $99 = 0 Then
_zj("  [X] Enable System Restore")
EndIf
ElseIf $99 = 1 Then
_zj("  [OK] Enable System Restore")
EndIf
_106()
Local Const $9a = _108()
If $9a <> 0 Then
_zj("  [X] System Restore Point created")
If $92 = False Then
_zj("  [I] Retry to create System Restore Point!")
_109(True)
Return
Else
_107()
Return
EndIf
ElseIf $9a = 0 Then
_zj("  [OK] System Restore Point created")
_107()
EndIf
EndFunc
Func _10a()
_zj(@CRLF & "- Create Registry Backup -" & @CRLF)
Local Const $9b = @HomeDrive & "\KPRM"
Local Const $9c = $9b & "\regedit-backup-" & @YEAR & @MON & @MDAY & @HOUR & @MIN & ".reg"
If FileExists($9c) Then
FileMove($9c, $9c & ".old")
EndIf
Local Const $8k = RunWait("Regedit /e " & $9c)
If Not FileExists($9c) Or @error <> 0 Then
_zj("  [X] Failed to create registry backup")
MsgBox(16, $57, $58)
_zi()
Else
_zj("  [OK] Registry Backup: " & $9c)
EndIf
EndFunc
Func _10b()
_zj(@CRLF & "- Restore UAC Default Value -" & @CRLF)
Local $8k = _xr()
If $8k = 1 Then
_zj("  [OK] Set ConsentPromptBehaviorAdmin with default (5) value")
Else
_zj("  [X] Set ConsentPromptBehaviorAdmin with default value")
EndIf
Local $8k = _xs(3)
If $8k = 1 Then
_zj("  [OK] Set ConsentPromptBehaviorUser with default (3) value")
Else
_zj("  [X] Set ConsentPromptBehaviorUser with default value")
EndIf
Local $8k = _xt()
If $8k = 1 Then
_zj("  [OK] Set EnableInstallerDetection with default (0) value")
Else
_zj("  [X] Set EnableInstallerDetection with default value")
EndIf
Local $8k = _xu()
If $8k = 1 Then
_zj("  [OK] Set EnableLUA with default (1) value")
Else
_zj("  [X] Set EnableLUA with default value")
EndIf
Local $8k = _xv()
If $8k = 1 Then
_zj("  [OK] Set EnableSecureUIAPaths with default (1) value")
Else
_zj("  [X] Set EnableSecureUIAPaths with default value")
EndIf
Local $8k = _xw()
If $8k = 1 Then
_zj("  [OK] Set EnableUIADesktopToggle with default (0) value")
Else
_zj("  [X] Set EnableUIADesktopToggle with default value")
EndIf
Local $8k = _xx()
If $8k = 1 Then
_zj("  [OK] Set EnableVirtualization with default (1) value")
Else
_zj("  [X] Set EnableVirtualization with default value")
EndIf
Local $8k = _xy()
If $8k = 1 Then
_zj("  [OK] Set FilterAdministratorToken with default (0) value")
Else
_zj("  [X] Set FilterAdministratorToken with default value")
EndIf
Local $8k = _xz()
If $8k = 1 Then
_zj("  [OK] Set PromptOnSecureDesktop with default (1) value")
Else
_zj("  [X] Set PromptOnSecureDesktop with default value")
EndIf
Local $8k = _y0()
If $8k = 1 Then
_zj("  [OK] Set ValidateAdminCodeSignatures with default (0) value")
Else
_zj("  [X] Set ValidateAdminCodeSignatures with default value")
EndIf
EndFunc
Func _10c()
_zj(@CRLF & "- Restore Default System Settings -" & @CRLF)
Local $8k = RunWait(@ComSpec & " /c " & "ipconfig /flushdns", @TempDir, @SW_HIDE)
If @error <> 0 Then
_zj("  [X] Flush DNS")
Else
_zj("  [OK] Flush DNS")
EndIf
Local Const $9d[7] = [ "netsh winsock reset", "netsh winhttp reset proxy", "netsh winhttp reset tracing", "netsh winsock reset catalog", "netsh int ip reset all", "netsh int ipv4 reset catalog", "netsh int ipv6 reset catalog" ]
$8k = 0
For $43 = 0 To UBound($9d) -1
RunWait(@ComSpec & " /c " & $9d[$43], @TempDir, @SW_HIDE)
If @error <> 0 Then
$8k += 1
EndIf
Next
If $8k = 0 Then
_zj("  [OK] Reset WinSock")
Else
_zj("  [X] Reset WinSock")
EndIf
Local $9e = "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced"
$8k = RegWrite($9e, "Hidden", "REG_DWORD", "2")
If $8k = 1 Then
_zj("  [OK] Hide Hidden file.")
Else
_zj("  [X] Hide Hidden File")
EndIf
$8k = RegWrite($9e, "HideFileExt", "REG_DWORD", "1")
If $8k = 1 Then
_zj("  [OK] Hide Extensions for known file types")
Else
_zj("  [X] Hide Extensions for known file types")
EndIf
$8k = RegWrite($9e, "ShowSuperHidden", "REG_DWORD", "0")
If $8k = 1 Then
_zj("  [OK] Hide protected operating system files")
Else
_zj("  [X] Hide protected operating system files")
EndIf
_zk()
EndFunc
Global $8f = ObjCreate("Scripting.Dictionary")
Local Const $9f[36] = [ "frst", "zhpdiag", "zhpcleaner", "zhpfix", "zhplite", "mbar", "roguekiller", "usbfix", "adwcleaner", "adsfix", "aswmbr", "fss", "toolsdiag", "scanrapide", "otl", "otm", "listparts", "minitoolbox", "miniregtool", "zhp", "combofix", "regtoolexport", "tdsskiller", "winupdatefix", "rsthosts", "winchk", "avenger", "blitzblank", "zoek", "remediate-vbs-worm", "ckscanner", "quickdiag", "adlicediag", "rstassociations", "sft", "grantperms"]
For $9g = 0 To UBound($9f) - 1
Local $9h = ObjCreate("Scripting.Dictionary")
Local $9i = ObjCreate("Scripting.Dictionary")
Local $9j = ObjCreate("Scripting.Dictionary")
Local $9k = ObjCreate("Scripting.Dictionary")
Local $9l = ObjCreate("Scripting.Dictionary")
$9h.add("key", $9i)
$9h.add("element", $9j)
$9h.add("uninstall", $9k)
$9h.add("process", $9l)
$8f.add($9f[$9g], $9h)
Next
Global $9m[1][2] = [[Null, Null]]
Global $9n[1][5] = [[Null, Null, Null, Null, Null]]
Global $9o[1][5] = [[Null, Null, Null, Null, Null]]
Global $9p[1][5] = [[Null, Null, Null, Null, Null]]
Global $9q[1][5] = [[Null, Null, Null, Null, Null]]
Global $9r[1][5] = [[Null, Null, Null, Null, Null]]
Global $9s[1][2] = [[Null, Null]]
Global $9t[1][2] = [[Null, Null]]
Global $9u[1][4] = [[Null, Null, Null, Null]]
Global $9v[1][5] = [[Null, Null, Null, Null, Null]]
Global $9w[1][5] = [[Null, Null, Null, Null, Null]]
Global $9x[1][5] = [[Null, Null, Null, Null, Null]]
Global $9y[1][5] = [[Null, Null, Null, Null, Null]]
Global $9z[1][3] = [[Null, Null, Null]]
Func _10d($82, $a0 = 0, $a1 = False)
Dim $a2
If $a2 Then _zj("[I] prepareRemove " & $82)
If $a1 Then
_yx($82)
_yf($82)
EndIf
Local Const $a3 = FileGetAttrib($82)
If StringInStr($a3, "R") Then
FileSetAttrib($82, "-R", $a0)
EndIf
If StringInStr($a3, "S") Then
FileSetAttrib($82, "-S", $a0)
EndIf
If StringInStr($a3, "H") Then
FileSetAttrib($82, "-H", $a0)
EndIf
If StringInStr($a3, "A") Then
FileSetAttrib($82, "-A", $a0)
EndIf
EndFunc
Func _10e($a4, $8c, $a5 = Null, $a1 = False)
Dim $a2
If $a2 Then _zj("[I] RemoveFile " & $a4)
Local Const $a6 = _zq($a4)
If $a6 Then
If $a5 And StringRegExp($a4, "(?i)\.exe$") Then
Local Const $a7 = FileGetVersion($a4, "CompanyName")
If @error Then
Return 0
ElseIf Not StringRegExp($a7, $a5) Then
Return 0
EndIf
EndIf
_zw($8c, 'element', $a4)
_10d($a4, 0, $a1)
Local $a8 = FileDelete($a4)
If $a8 Then
If $a2 Then
_zj("  [OK] File " & $a4 & " deleted successfully")
EndIf
Return 1
EndIf
Return 2
EndIf
Return 0
EndFunc
Func _10f($82, $8c, $a1 = False)
Dim $a2
If $a2 Then _zj("[I] RemoveFolder " & $82)
Local $a6 = _zr($82)
If $a6 Then
_zw($8c, 'element', $82)
_10d($82, 1, $a1)
Local Const $a8 = DirRemove($82, $l)
If $a8 Then
If $a2 Then
_zj("  [OK] Directory " & $82 & " deleted successfully")
EndIf
Return 1
EndIf
Return 2
EndIf
Return 0
EndFunc
Func _10g($82, $a4, $a9)
Dim $a2
If $a2 Then _zj("[I] FindGlob " & $82 & " " & $a4)
Local Const $aa = $82 & "\" & $a4
Local Const $4t = FileFindFirstFile($aa)
Local $ab = []
If $4t = -1 Then
Return $ab
EndIf
Local $4r = FileFindNextFile($4t)
While @error = 0
If StringRegExp($4r, $a9) Then
_vv($ab, $82 & "\" & $4r)
EndIf
$4r = FileFindNextFile($4t)
WEnd
FileClose($4t)
Return $ab
EndFunc
Func _10h($82, $ac)
Dim $a2
If $a2 Then _zj("[I] RemoveAllFileFrom " & $82)
Local Const $aa = $82 & "\*"
Local Const $4t = FileFindFirstFile($aa)
If $4t = -1 Then
Return Null
EndIf
Local $4r = FileFindNextFile($4t)
While @error = 0
For $ad = 1 To UBound($ac) - 1
Local $ae = $82 & "\" & $4r
Local $af = _zs($ae)
If $af And $ac[$ad][3] And $af = $ac[$ad][1] And StringRegExp($4r, $ac[$ad][3]) Then
Local $8k = 0
Local $a1 = False
If $ac[$ad][4] = True Then
$a1 = True
EndIf
If $af = 'file' Then
$8k = _10e($ae, $ac[$ad][0], $ac[$ad][2], $a1)
ElseIf $af = 'folder' Then
$8k = _10f($ae, $ac[$ad][0], $a1)
EndIf
EndIf
Next
$4r = FileFindNextFile($4t)
WEnd
FileClose($4t)
EndFunc
Func _10i($84, $8c)
Dim $a2
If $a2 Then _zj("[I] RemoveRegistryKey " & $84)
Local Const $8k = RegDelete($84)
If $8k <> 0 Then
_zw($8c, "key", $84)
If $a2 Then
If $8k = 1 Then
_zj("  [OK] " & $84 & " deleted successfully")
ElseIf $8k = 2 Then
_zj("  [X] " & $84 & " deleted failed")
EndIf
EndIf
EndIf
Return $8k
EndFunc
Func _10j($8i)
Local $ag = 50
Dim $a2
If $a2 Then _zj("[I] CloseProcessAndWait " & $8i)
If 0 = ProcessExists($8i) Then Return 0
ProcessClose($8i)
Do
$ag -= 1
Sleep(250)
Until($ag = 0 Or 0 = ProcessExists($8i))
Local Const $8k = ProcessExists($8i)
If 0 = $8k Then
If $a2 Then _zj("  [OK] Proccess " & $8i & " stopped successfully")
Return 1
EndIf
Return 0
EndFunc
Func _10k($7u)
Dim $ag
Dim $a2
If $a2 Then _zj("[I] RemoveAllProcess")
Local $ah = ProcessList()
For $43 = 1 To $ah[0][0]
Local $ai = $ah[$43][0]
Local $aj = $ah[$43][1]
For $ag = 1 To UBound($7u) - 1
If StringRegExp($ai, $7u[$ag][1]) Then
_10j($aj)
_zw($7u[$ag][0], "process", $ai)
EndIf
Next
Next
EndFunc
Func _10l($ak)
Dim $a2
If $a2 Then _zj("[I] RemoveScheduleTask")
For $43 = 1 To UBound($ak) - 1
RunWait('schtasks.exe /delete /tn "' & $ak[$43][1] & '" /f', @TempDir, @SW_HIDE)
Next
EndFunc
Func _10m($ak)
Dim $a2
If $a2 Then _zj("[I] UninstallNormaly")
Local Const $87 = _zp()
For $43 = 1 To UBound($87) - 1
For $al = 1 To UBound($ak) - 1
Local $am = $ak[$al][1]
Local $an = $ak[$al][2]
Local $ao = _10g($87[$43], "*", $am)
For $ap = 1 To UBound($ao) - 1
Local $aq = _10g($ao[$ap], "*", $an)
For $ar = 1 To UBound($aq) - 1
If _zq($aq[$ar]) Then
RunWait($aq[$ar])
_zw($ak[$al][0], "uninstall", $aq[$ar])
EndIf
Next
Next
Next
Next
EndFunc
Func _10n($ak)
Dim $a2
If $a2 Then _zj("[I] RemoveAllProgramFilesDir")
Local Const $87 = _zp()
For $43 = 1 To UBound($87) - 1
_10h($87[$43], $ak)
Next
EndFunc
Func _10o($ak)
Dim $a2
If $a2 Then _zj("[I] RemoveAllSoftwareKeyList")
Local $5g = ""
If @OSArch = "X64" Then $5g = "64"
Local $as[2] = ["HKCU" & $5g & "\SOFTWARE", "HKLM" & $5g & "\SOFTWARE"]
For $7g = 0 To UBound($as) - 1
Local $43 = 0
While True
$43 += 1
Local $85 = RegEnumKey($as[$7g], $43)
If @error <> 0 Then ExitLoop
For $al = 1 To UBound($ak) - 1
If $85 And $ak[$al][1] Then
If StringRegExp($85, $ak[$al][1]) Then
Local $at = $as[$7g] & "\" & $85
_10i($at, $ak[$al][0])
EndIf
EndIf
Next
WEnd
Next
EndFunc
Func _10p($ak)
Dim $a2
If $a2 Then _zj("[I] RemoveUninstallStringWithSearch")
For $43 = 1 To UBound($ak) - 1
Local $at = _zn($ak[$43][1], $ak[$43][2], $ak[$43][3])
If $at And $at <> "" Then
_10i($at, $ak[$43][0])
EndIf
Next
EndFunc
Func _10q()
Local Const $au = "frst"
Dim $9m
Dim $9n
Dim $av
Dim $9p
Dim $aw
Dim $9r
Local Const $a5 = "(?i)^Farbar"
Local Const $ax = "(?i)^FRST.*\.exe$"
Local Const $ay = "(?i)^FRST-OlderVersion$"
Local Const $az = "(?i)^(FRST|fixlist|fixlog|Addition|Shortcut).*\.(exe|txt)$"
Local Const $b0 = "(?i)^FRST"
Local Const $b1[1][2] = [[$au, $ax]]
Local Const $b2[1][5] = [[$au, 'file', $a5, $az, False]]
Local Const $b3[1][5] = [[$au, 'folder', Null, $ay, False]]
Local Const $b4[1][5] = [[$au, 'folder', Null, $b0, True]]
_vv($9m, $b1)
_vv($9n, $b2)
_vv($9p, $b2)
_vv($9n, $b3)
_vv($9p, $b3)
_vv($9r, $b4)
EndFunc
_10q()
Func _10r()
Dim $9x
Dim $9s
Dim $9w
Local $au = "zhp"
Local Const $89[1][2] = [[$au, "(?i)^ZHP$"]]
Local Const $b5[1][5] = [[$au, 'folder', Null, "(?i)^ZHP$", True]]
_vv($9s, $89)
_vv($9x, $b5)
_vv($9w, $b5)
EndFunc
_10r()
Func _10s()
Local Const $b6 = Null
Local Const $au = "zhpdiag"
Dim $9m
Dim $9n
Dim $9o
Dim $9p
Dim $9r
Local Const $ax = "(?i)^ZHPDiag.*\.exe$"
Local Const $ay = "(?i)^ZHPDiag.*\.(exe|txt|lnk)$"
Local Const $az = "(?i)^PhysicalDisk[0-9]_MBR\.bin$"
Local Const $b1[1][2] = [[$au, $ax]]
Local Const $b2[1][5] = [[$au, 'file', $b6, $ay, False]]
Local Const $b3[1][5] = [[$au, 'file', Null, $az, True]]
_vv($9m, $b1)
_vv($9n, $b2)
_vv($9p, $b2)
_vv($9o, $b2)
_vv($9r, $b3)
EndFunc
_10s()
Func _10t()
Local Const $b6 = Null
Local Const $b7 = "zhpfix"
Dim $9m
Dim $9n
Dim $9p
Local Const $ax = "(?i)^ZHPFix.*\.exe$"
Local Const $ay = "(?i)^ZHPFix.*\.(exe|txt|lnk)$"
Local Const $b1[1][2] = [[$b7, $ax]]
Local Const $b2[1][5] = [[$b7, 'file', $b6, $ay, False]]
_vv($9m, $b1)
_vv($9n, $b2)
_vv($9p, $b2)
EndFunc
_10t()
Func _10u()
Local Const $b6 = Null
Local Const $b7 = "zhplite"
Dim $9m
Dim $9n
Dim $9p
Local Const $ax = "(?i)^ZHPLite.*\.exe$"
Local Const $ay = "(?i)^ZHPLite.*\.(exe|txt|lnk)$"
Local Const $b1[1][2] = [[$b7, $ax]]
Local Const $b2[1][5] = [[$b7, 'file', $b6, $ay, False]]
_vv($9m, $b1)
_vv($9n, $b2)
_vv($9p, $b2)
EndFunc
_10u()
Func _10v($92 = False)
Local Const $a5 = "(?i)^Malwarebytes Anti-Rootkit$"
Local Const $b8 = "(?i)^Malwarebytes"
Local Const $au = "mbar"
Dim $9m
Dim $9n
Dim $9p
Dim $9s
Local Const $ax = "(?i)^mbar.*\.exe$"
Local Const $ay = "(?i)^mbar"
Local Const $b1[1][2] = [[$au, $ax]]
Local Const $b2[1][2] = [[$au, $a5]]
Local Const $b3[1][5] = [[$au, 'file', $b8, $ax, False]]
Local Const $b4[1][5] = [[$au, 'folder', $a5, $ay, False]]
_vv($9m, $b1)
_vv($9n, $b3)
_vv($9p, $b3)
_vv($9n, $b4)
_vv($9p, $b4)
_vv($9s, $b2)
EndFunc
_10v()
Func _10w()
Local Const $au = "roguekiller"
Dim $9m
Dim $9t
Dim $9u
Dim $9q
Dim $9v
Dim $9n
Dim $9o
Dim $9y
Dim $9p
Local $5g = ""
If @OSArch = "X64" Then $5g = "64"
Local Const $b9 = "(?i)^Adlice"
Local Const $ax = "(?i)^RogueKiller"
Local Const $ay = "(?i)^RogueKiller.*\.(exe|lnk|txt)$"
Local Const $az = "(?i)^RogueKiller.*\.exe$"
Local Const $b0 = "(?i)^RogueKiller_portable(32|64)\.exe$"
Local Const $b1[1][2] = [[$au, $az]]
Local Const $b2[1][2] = [[$au, "RogueKiller Anti-Malware"]]
Local Const $b3[1][4] = [[$au, "HKLM" & $5g & "\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall", $ax, "DisplayName"]]
Local Const $b4[1][5] = [[$au, 'file', $b9, $ay, False]]
Local Const $ba[1][5] = [[$au, 'folder', Null, $ax, True]]
Local Const $bb[1][5] = [[$au, 'file', Null, $b0, False]]
_vv($9m, $b1)
_vv($9t, $b2)
_vv($9u, $b3)
_vv($9q, $ba)
_vv($9v, $ba)
_vv($9n, $bb)
_vv($9n, $b4)
_vv($9n, $ba)
_vv($9p, $bb)
_vv($9p, $b4)
_vv($9p, $ba)
_vv($9o, $b4)
_vv($9y, $ba)
EndFunc
_10w()
Func _10x()
Local Const $au = "adwcleaner"
Local Const $a5 = "(?i)^AdwCleaner"
Local Const $b8 = "(?i)^Malwarebytes"
Local Const $ax = "(?i)^AdwCleaner.*\.exe$"
Dim $9m
Dim $9n
Dim $9p
Dim $9r
Local Const $b1[1][2] = [[$au, $ax]]
Local Const $b2[1][5] = [[$au, 'file', $b8, $ax, False]]
Local Const $b3[1][5] = [[$au, 'folder', Null, $a5, True]]
_vv($9m, $b1)
_vv($9n, $b2)
_vv($9p, $b2)
_vv($9r, $b3)
EndFunc
_10x()
Func _10y()
Local Const $b6 = Null
Local Const $au = "zhpcleaner"
Dim $9m
Dim $9n
Dim $9p
Local Const $ax = "(?i)^ZHPCleaner.*\.exe$"
Local Const $ay = "(?i)^ZHPCleaner.*\.(exe|txt|lnk)$"
Local Const $b1[1][2] = [[$au, $ax]]
Local Const $b2[1][5] = [[$au, 'file', $b6, $ay, False]]
_vv($9m, $b1)
_vv($9n, $b2)
_vv($9p, $b2)
EndFunc
_10y()
Func _10z()
Local Const $au = "usbfix"
Dim $9m
Dim $9z
Dim $9n
Dim $9o
Dim $9p
Dim $9s
Dim $9r
Dim $9q
Local Const $a5 = "(?i)^UsbFix"
Local Const $b8 = "(?i)^SosVirus"
Local Const $ax = "(?i)^UsbFix.*\.(exe|lnk|txt)$"
Local Const $ay = "(?i)^Un-UsbFix.exe$"
Local Const $az = "(?i)^UsbFixQuarantine$"
Local Const $b0 = "(?i)^UsbFix.*\.exe$"
Local Const $bc[1][2] = [[$au, $b0]]
Local Const $b1[1][2] = [[$au, $a5]]
Local Const $b2[1][3] = [[$au, $a5, $ay]]
Local Const $b3[1][5] = [[$au, 'file', $b8, $ax, False]]
Local Const $b4[1][5] = [[$au, 'folder', Null, $az, True]]
Local Const $ba[1][5] = [[$au, 'folder', Null, $a5, False]]
_vv($9m, $bc)
_vv($9z, $b2)
_vv($9n, $b3)
_vv($9o, $b3)
_vv($9p, $b3)
_vv($9s, $b1)
_vv($9r, $b4)
_vv($9r, $ba)
_vv($9q, $ba)
EndFunc
_10z()
Func _110()
Local Const $au = "adsfix"
Dim $9m
Dim $9n
Dim $9p
Dim $9r
Dim $9o
Dim $9s
Local Const $a5 = "(?i)^AdsFix"
Local Const $b8 = "(?i)^SosVirus"
Local Const $ax = "(?i)^AdsFix.*\.exe$"
Local Const $ay = "(?i)^AdsFix.*\.(exe|txt|lnk)$"
Local Const $az = "(?i)^AdsFix.*\.txt$"
Local Const $b1[1][2] = [[$au, $ax]]
Local Const $b2[1][5] = [[$au, 'file', $b8, $ay, False]]
Local Const $b3[1][5] = [[$au, 'file', Null, $az, False]]
Local Const $b4[1][5] = [[$au, 'folder', Null, $a5, True]]
Local Const $ba[1][2] = [[$au, $a5]]
_vv($9m, $b1)
_vv($9n, $b2)
_vv($9o, $b2)
_vv($9p, $b2)
_vv($9r, $b3)
_vv($9r, $b4)
_vv($9s, $ba)
EndFunc
_110()
Func _111()
Local Const $au = "aswmbr"
Dim $9m
Dim $9n
Dim $9p
Local Const $a5 = "(?i)^avast"
Local Const $ax = "(?i)^aswmbr.*\.(exe|txt|lnk)$"
Local Const $ay = "(?i)^MBR\.dat$"
Local Const $az = "(?i)^aswmbr.*\.exe$"
Local Const $b1[1][2] = [[$au, $az]]
Local Const $b2[1][5] = [[$au, 'file', $a5, $ax, False]]
Local Const $b3[1][5] = [[$au, 'file', Null, $ay, False]]
_vv($9m, $b1)
_vv($9n, $b2)
_vv($9n, $b3)
_vv($9p, $b2)
EndFunc
_111()
Func _112()
Local Const $au = "fss"
Dim $9m
Dim $9n
Dim $9p
Local Const $a5 = "(?i)^Farbar"
Local Const $ax = "(?i)^FSS.*\.(exe|txt|lnk)$"
Local Const $ay = "(?i)^FSS.*\.exe$"
Local Const $b1[1][2] = [[$au, $ay]]
Local Const $b2[1][5] = [[$au, 'file', $a5, $ax, False]]
_vv($9m, $b1)
_vv($9n, $b2)
_vv($9p, $b2)
EndFunc
_112()
Func _113()
Local Const $au = "toolsdiag"
Dim $9m
Dim $9n
Dim $9p
Dim $9r
Local Const $ax = "(?i)^toolsdiag.*\.exe$"
Local Const $ay = "(?i)^ToolsDiag$"
Local Const $b1[1][5] = [[$au, 'folder', Null, $ay, False]]
Local Const $b2[1][5] = [[$au, 'file', Null, $ax, False]]
Local Const $b3[1][2] = [[$au, $ax]]
_vv($9m, $b3)
_vv($9n, $b2)
_vv($9p, $b2)
_vv($9r, $b1)
EndFunc
_113()
Func _114()
Local Const $au = "scanrapide"
Dim $9r
Dim $9n
Dim $9p
Local Const $a5 = Null
Local Const $ax = "(?i)^ScanRapide.*\.exe$"
Local Const $ay = "(?i)^ScanRapide\[R[0-9]+\]\.txt$"
Local Const $b1[1][5] = [[$au, 'file', $a5, $ax, False]]
Local Const $b2[1][5] = [[$au, 'file', Null, $ay, False]]
_vv($9n, $b1)
_vv($9p, $b1)
_vv($9r, $b2)
EndFunc
_114()
Func _115()
Local Const $au = "otl"
Dim $9m
Dim $9n
Dim $9p
Dim $9r
Local Const $a5 = "(?i)^OldTimer"
Local Const $ax = "(?i)^OTL.*\.exe$"
Local Const $ay = "(?i)^OTL.*\.(exe|txt)$"
Local Const $az = "(?i)^Extras\.txt$"
Local Const $b0 = "(?i)^_OTL$"
Local Const $b1[1][2] = [[$au, $ax]]
Local Const $b2[1][5] = [[$au, 'file', $a5, $ay, False]]
Local Const $b3[1][5] = [[$au, 'file', Null, $az, False]]
Local Const $b4[1][5] = [[$au, 'folder', Null, $b0, True]]
_vv($9m, $b1)
_vv($9n, $b2)
_vv($9n, $b3)
_vv($9p, $b2)
_vv($9r, $b4)
EndFunc
_115()
Func _116()
Local Const $au = "otm"
Dim $9m
Dim $9n
Dim $9p
Dim $9r
Local Const $a5 = "(?i)^OldTimer"
Local Const $ax = "(?i)^OTM.*\.exe$"
Local Const $ay = "(?i)^_OTM$"
Local Const $b1[1][2] = [[$au, $ax]]
Local Const $b2[1][5] = [[$au, 'file', $a5, $ax, False]]
Local Const $b3[1][5] = [[$au, 'folder', Null, $ay, True]]
_vv($9m, $b1)
_vv($9n, $b2)
_vv($9p, $b2)
_vv($9r, $b3)
EndFunc
_116()
Func _117()
Local Const $au = "listparts"
Dim $9m
Dim $9n
Dim $9p
Dim $9r
Local Const $a5 = "(?i)^Farbar"
Local Const $ax = "(?i)^listParts.*\.exe$"
Local Const $ay = "(?i)^Results\.txt$"
Local Const $b1[1][2] = [[$au, $ax]]
Local Const $b2[1][5] = [[$au, 'file', $a5, $ax, False]]
Local Const $b3[1][5] = [[$au, 'file', Null, $ay, False]]
_vv($9m, $b1)
_vv($9n, $b2)
_vv($9n, $b3)
_vv($9p, $b2)
_vv($9p, $b3)
EndFunc
_117()
Func _118()
Local Const $au = "minitoolbox"
Dim $9m
Dim $9n
Dim $9p
Dim $9r
Local Const $a5 = "(?i)^Farbar"
Local Const $ax = "(?i)^MiniToolBox.*\.exe$"
Local Const $ay = "(?i)^MTB\.txt$"
Local Const $b1[1][2] = [[$au, $ax]]
Local Const $b2[1][5] = [[$au, 'file', $a5, $ax, False]]
Local Const $b3[1][5] = [[$au, 'file', Null, $ay, False]]
_vv($9m, $b1)
_vv($9n, $b2)
_vv($9n, $b3)
_vv($9p, $b2)
_vv($9p, $b3)
EndFunc
_118()
Func _119()
Local Const $au = "miniregtool"
Dim $9m
Dim $9n
Dim $9p
Dim $9r
Local Const $a5 = Null
Local Const $ax = "(?i)^MiniRegTool.*\.exe$"
Local Const $ay = "(?i)^MiniRegTool.*\.(exe|zip)$"
Local Const $az = "(?i)^Result\.txt$"
Local Const $b0 = "(?i)^MiniRegTool"
Local Const $b1[1][2] = [[$au, $ax]]
Local Const $b2[1][5] = [[$au, 'file', $a5, $ay, False]]
Local Const $b3[1][5] = [[$au, 'file', $a5, $az, False]]
Local Const $b4[1][5] = [[$au, 'folder', $a5, $b0, False]]
_vv($9m, $b1)
_vv($9n, $b2)
_vv($9n, $b3)
_vv($9n, $b4)
_vv($9p, $b2)
_vv($9p, $b3)
_vv($9p, $b4)
EndFunc
_119()
Func _11a()
Local Const $au = "grantperms"
Dim $9m
Dim $9n
Dim $9p
Dim $9r
Local Const $a5 = Null
Local Const $ax = "(?i)^GrantPerms.*\.exe$"
Local Const $ay = "(?i)^GrantPerms.*\.(exe|zip)$"
Local Const $az = "(?i)^Perms\.txt$"
Local Const $b0 = "(?i)^GrantPerms"
Local Const $b1[1][2] = [[$au, $ax]]
Local Const $b2[1][5] = [[$au, 'file', $a5, $ay, False]]
Local Const $b3[1][5] = [[$au, 'file', $a5, $az, False]]
Local Const $b4[1][5] = [[$au, 'folder', $a5, $b0, False]]
_vv($9m, $b1)
_vv($9n, $b2)
_vv($9n, $b3)
_vv($9n, $b4)
_vv($9p, $b2)
_vv($9p, $b3)
_vv($9p, $b4)
EndFunc
_11a()
Func _11b()
Local Const $au = "combofix"
Dim $9n
Dim $9p
Dim $9r
Local Const $a5 = "(?i)^Swearware"
Local Const $ax = "(?i)^Combofix.*\.exe$"
Local Const $ay = "(?i)^CFScript\.txt$"
Local Const $az = "(?i)^Qoobox$"
Local Const $b0 = "(?i)^Combofix.*\.txt$"
Local Const $b1[1][5] = [[$au, 'file', $a5, $ax, False]]
Local Const $b2[1][5] = [[$au, 'file', Null, $ay, False]]
Local Const $b3[1][5] = [[$au, 'folder', Null, $az, True]]
Local Const $b4[1][5] = [[$au, 'file', Null, $b0, False]]
_vv($9n, $b1)
_vv($9n, $b2)
_vv($9p, $b1)
_vv($9p, $b2)
_vv($9r, $b3)
_vv($9r, $b4)
EndFunc
_11b()
Func _11c()
Local Const $au = "regtoolexport"
Dim $9m
Dim $9n
Dim $9p
Local Const $a5 = Null
Local Const $ax = "(?i)^regtoolexport.*\.exe$"
Local Const $ay = "(?i)^Export.*\.reg$"
Local Const $b1[1][2] = [[$au, $ax]]
Local Const $b2[1][5] = [[$au, 'file', $a5, $ax, False]]
Local Const $b3[1][5] = [[$au, 'file', $a5, $ay, False]]
_vv($9m, $b1)
_vv($9n, $b2)
_vv($9n, $b3)
_vv($9p, $b2)
_vv($9p, $b3)
EndFunc
_11c()
Func _11d()
Local Const $au = "tdsskiller"
Dim $9m
Dim $9n
Dim $9p
Dim $9r
Local Const $a5 = "(?i)^.*Kaspersky"
Local Const $ax = "(?i)^tdsskiller.*\.exe$"
Local Const $ay = "(?i)^tdsskiller.*\.(exe|zip)$"
Local Const $az = "(?i)^TDSSKiller.*_log\.txt$"
Local Const $b0 = "(?i)^TDSSKiller"
Local Const $b1[1][2] = [[$au, $ax]]
Local Const $b2[1][5] = [[$au, 'file', $a5, $ay, False]]
Local Const $b3[1][5] = [[$au, 'file', Null, $az, False]]
Local Const $b4[1][5] = [[$au, 'folder', Null, $b0, False]]
_vv($9m, $b1)
_vv($9n, $b2)
_vv($9n, $b4)
_vv($9p, $b2)
_vv($9p, $b4)
_vv($9r, $b3)
_vv($9r, $b4)
EndFunc
_11d()
Func _11e()
Local Const $au = "winupdatefix"
Dim $9m
Dim $9n
Dim $9p
Dim $9r
Local Const $a5 = Null
Local Const $ax = "(?i)^winupdatefix.*\.exe$"
Local Const $ay = "(?i)^winupdatefix.*\.txt$"
Local Const $b1[1][2] = [[$au, $ax]]
Local Const $b2[1][5] = [[$au, 'file', $a5, $ax, False]]
Local Const $b3[1][5] = [[$au, 'file', $a5, $ay, False]]
_vv($9m, $b1)
_vv($9n, $b2)
_vv($9p, $b2)
_vv($9r, $b3)
EndFunc
_11e()
Func _11f()
Local Const $au = "rsthosts"
Dim $9m
Dim $9n
Dim $9p
Dim $9r
Local Const $a5 = Null
Local Const $ax = "(?i)^rsthosts.*\.exe$"
Local Const $ay = "(?i)^RstHosts.*\.txt$"
Local Const $b1[1][2] = [[$au, $ax]]
Local Const $b2[1][5] = [[$au, 'file', $a5, $ax, Null]]
Local Const $b3[1][5] = [[$au, 'file', $a5, $ay, Null]]
_vv($9m, $b1)
_vv($9n, $b2)
_vv($9p, $b2)
_vv($9r, $b3)
EndFunc
_11f()
Func _11g()
Local Const $au = "winchk"
Dim $9m
Dim $9n
Dim $9p
Dim $9r
Local Const $a5 = Null
Local Const $ax = "(?i)^winchk.*\.exe$"
Local Const $ay = "(?i)^WinChk.*\.txt$"
Local Const $b1[1][2] = [[$au, $ax]]
Local Const $b2[1][5] = [[$au, 'file', $a5, $ax, False]]
Local Const $b3[1][5] = [[$au, 'file', $a5, $ay, False]]
_vv($9m, $b1)
_vv($9n, $b2)
_vv($9p, $b2)
_vv($9r, $b3)
EndFunc
_11g()
Func _11h()
Local Const $au = "avenger"
Dim $9m
Dim $9n
Dim $9p
Dim $9r
Local Const $a5 = Null
Local Const $ax = "(?i)^avenger.*\.(exe|zip)$"
Local Const $ay = "(?i)^avenger"
Local Const $az = "(?i)^avenger.*\.txt$"
Local Const $b0 = "(?i)^avenger.*\.exe$"
Local Const $b1[1][2] = [[$au, $b0]]
Local Const $b2[1][5] = [[$au, 'file', $a5, $ax, False]]
Local Const $b3[1][5] = [[$au, 'folder', $a5, $ay, False]]
Local Const $b4[1][5] = [[$au, 'file', $a5, $az, False]]
_vv($9m, $b1)
_vv($9n, $b2)
_vv($9n, $b3)
_vv($9p, $b2)
_vv($9p, $b3)
_vv($9r, $b3)
_vv($9r, $b4)
EndFunc
_11h()
Func _11i()
Local Const $au = "blitzblank"
Dim $9m
Dim $9n
Dim $9p
Dim $9r
Dim $9o
Dim $9s
Local Const $a5 = "(?i)^Emsi"
Local Const $ax = "(?i)^BlitzBlank.*\.exe$"
Local Const $ay = "(?i)^BlitzBlank.*\.log$"
Local Const $b1[1][2] = [[$au, $ax]]
Local Const $b2[1][5] = [[$au, 'file', $a5, $ax, False]]
Local Const $b3[1][5] = [[$au, 'file', Null, $ay, False]]
_vv($9m, $b1)
_vv($9n, $b2)
_vv($9p, $b2)
_vv($9r, $b3)
EndFunc
_11i()
Func _11j()
Local Const $au = "zoek"
Dim $9m
Dim $9n
Dim $9p
Dim $9r
Dim $9o
Dim $9s
Local Const $a5 = Null
Local Const $ax = "(?i)^zoek.*\.exe$"
Local Const $ay = "(?i)^zoek.*\.log$"
Local Const $az = "(?i)^zoek"
Local Const $b0 = "(?i)^runcheck.*\.txt$"
Local Const $b1[1][2] = [[$au, $ax]]
Local Const $b2[1][5] = [[$au, 'file', $a5, $ax, False]]
Local Const $b3[1][5] = [[$au, 'file', $a5, $ay, False]]
Local Const $b4[1][5] = [[$au, 'folder', $a5, $az, True]]
Local Const $ba[1][5] = [[$au, 'file', $a5, $b0, False]]
_vv($9m, $b1)
_vv($9n, $b2)
_vv($9p, $b2)
_vv($9r, $b3)
_vv($9r, $b4)
_vv($9r, $ba)
EndFunc
_11j()
Func _11k()
Local Const $au = "remediate-vbs-worm"
Dim $9m
Dim $9n
Dim $9p
Dim $9r
Dim $9o
Dim $9s
Local Const $a5 = "(?i).*VBS autorun worms.*"
Local Const $b8 = Null
Local Const $ax = "(?i)^remediate.?vbs.?worm.*\.exe$"
Local Const $ay = "(?i)^Rem-VBS.*\.log$"
Local Const $az = "(?i)^Rem-VBS"
Local Const $b1[1][2] = [[$au, $ax]]
Local Const $b2[1][5] = [[$au, 'file', $b8, $ax, False]]
Local Const $b3[1][5] = [[$au, 'file', $b8, $ay, False]]
Local Const $b4[1][5] = [[$au, 'folder', $a5, $az, True]]
_vv($9m, $b1)
_vv($9n, $b2)
_vv($9p, $b2)
_vv($9r, $b3)
_vv($9r, $b4)
EndFunc
_11k()
Func _11l()
Local Const $au = "ckscanner"
Dim $9m
Dim $9n
Dim $9p
Local Const $a5 = Null
Local Const $ax = "(?i)^CKScanner.*\.exe$"
Local Const $ay = "(?i)^CKfiles.*\.txt$"
Local Const $b1[1][2] = [[$au, $ax]]
Local Const $b2[1][5] = [[$au, 'file', $a5, $ax, False]]
Local Const $b3[1][5] = [[$au, 'file', $a5, $ay, False]]
_vv($9m, $b1)
_vv($9n, $b2)
_vv($9p, $b2)
_vv($9n, $b3)
_vv($9p, $b3)
EndFunc
_11l()
Func _11m()
Local Const $au = "quickdiag"
Dim $9m
Dim $9n
Dim $9p
Dim $9r
Local Const $a5 = "(?i)^SosVirus"
Local Const $ax = "(?i)^QuickDiag.*\.exe$"
Local Const $ay = "(?i)^QuickDiag.*\.(exe|txt)$"
Local Const $az = "(?i)^QuickScript.*\.txt$"
Local Const $b0 = "(?i)^QuickDiag.*\.txt$"
Local Const $bd = "(?i)^QuickDiag"
Local Const $b1[1][2] = [[$au, $ax]]
Local Const $b2[1][5] = [[$au, 'file', $a5, $ay, True]]
Local Const $b3[1][5] = [[$au, 'file', Null, $az, True]]
Local Const $b4[1][5] = [[$au, 'file', Null, $b0, True]]
Local Const $ba[1][5] = [[$au, 'folder', Null, $bd, True]]
_vv($9m, $b1)
_vv($9n, $b2)
_vv($9p, $b2)
_vv($9n, $b3)
_vv($9p, $b3)
_vv($9r, $b4)
_vv($9r, $ba)
EndFunc
_11m()
Func _11n()
Local Const $au = "adlicediag"
Dim $9m
Dim $9u
Dim $9q
Dim $9v
Dim $9n
Dim $9p
Dim $9o
Dim $9y
Local $5g = ""
If @OSArch = "X64" Then $5g = "64"
Local Const $be = "(?i)^Adlice Diag"
Local Const $ax = "(?i)^Diag version"
Local Const $ay = "(?i)^Diag$"
Local Const $az = "(?i)^ADiag$"
Local Const $b0 = "(?i)^Diag_portable(32|64)\.exe$"
Local Const $bd = "(?i)^Diag\.lnk$"
Local Const $bf = "(?i)^Diag_setup\.exe$"
Local Const $bg = "(?i)^Diag(32|64)?\.exe$"
Local Const $b1[1][2] = [[$au, $be]]
Local Const $b2[1][4] = [[$au, "HKLM" & $5g & "\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall", $ax, "DisplayName"]]
Local Const $b3[1][5] = [[$au, 'folder', Null, $ay, True]]
Local Const $b4[1][5] = [[$au, 'folder', Null, $az, True]]
Local Const $ba[1][5] = [[$au, 'file', Null, $b0, False]]
Local Const $bb[1][5] = [[$au, 'file', Null, $bd, False]]
Local Const $bh[1][5] = [[$au, 'file', Null, $bf, False]]
Local Const $bi[1][2] = [[$au, $bg]]
_vv($9m, $b1)
_vv($9m, $bi)
_vv($9u, $b2)
_vv($9q, $b3)
_vv($9v, $b4)
_vv($9n, $ba)
_vv($9n, $bb)
_vv($9n, $bh)
_vv($9p, $ba)
_vv($9p, $bh)
_vv($9o, $bb)
_vv($9y, $b3)
EndFunc
_11n()
Func _11o()
Local Const $b6 = Null
Local Const $au = "rstassociations"
Dim $9m
Dim $9n
Dim $9p
Dim $9r
Local Const $ax = "(?i)^rstassociations.*\.(exe|scr)$"
Local Const $ay = "(?i)^RstAssociations.*\.txt$"
Local Const $b1[1][2] = [[$au, $ax]]
Local Const $b2[1][5] = [[$au, 'file', $b6, $ax, False]]
Local Const $b3[1][5] = [[$au, 'file', $b6, $ay, False]]
_vv($9m, $b1)
_vv($9n, $b2)
_vv($9p, $b2)
_vv($9r, $b3)
EndFunc
_11o()
Func _11p()
Local Const $b6 = Null
Local Const $au = "sft"
Dim $9m
Dim $9n
Dim $9p
Local Const $ax = "(?i)^SFT.*\.exe$"
Local Const $ay = "(?i)^SFT.*\.(txt|exe|zip)$"
Local Const $b1[1][2] = [[$au, $ax]]
Local Const $b2[1][5] = [[$au, 'file', $b6, $ay, False]]
_vv($9m, $b1)
_vv($9n, $b2)
_vv($9p, $b2)
EndFunc
_11p()
Func _11q()
Local $5g = ""
If @OSArch = "X64" Then $5g = "64"
If FileExists(@AppDataCommonDir & "\Malwarebytes\Malwarebytes' Anti-Malware\Quarantine") Then
Local $bj = _x1(@AppDataCommonDir & "\Malwarebytes\Malwarebytes' Anti-Malware\Quarantine")
If @error = 0 Then
For $43 = 1 To $bj[0]
_10e(@AppDataCommonDir & "\Malwarebytes\Malwarebytes' Anti-Malware\Quarantine" & '\' & $bj[$43], "mbar", Null, True)
Next
EndIf
EndIf
_10i("HKLM" & $5g & "\SOFTWARE\Microsoft\Windows\Windows Error Reporting\LocalDumps\RogueKiller.exe", "roguekiller")
_10i("HKLM" & $5g & "\SOFTWARE\Microsoft\Windows\CurrentVersion\App Paths\combofix.exe", "combofix")
EndFunc
Func _11r($92 = False)
If $92 = True Then
_zj(@CRLF & "- Search Tools -" & @CRLF)
EndIf
_10k($9m)
_102()
_10m($9z)
_102()
_10l($9t)
_102()
_10h(@DesktopDir, $9n)
_102()
_10h(@DesktopCommonDir, $9o)
_102()
If FileExists(@UserProfileDir & "\Downloads") Then
_10h(@UserProfileDir & "\Downloads", $9p)
_102()
Else
_102()
EndIf
_10n($9q)
_102()
_10h(@HomeDrive, $9r)
_102()
_10h(@AppDataDir, $9w)
_102()
_10h(@AppDataCommonDir, $9v)
_102()
_10h(@LocalAppDataDir, $9x)
_102()
_10o($9s)
_102()
_10p($9u)
_102()
_10h(@AppDataCommonDir & "\Microsoft\Windows\Start Menu\Programs", $9y)
_102()
_11q()
_102()
If $92 = True Then
Local $bk = False
Local Const $bl[4] = ["process", "uninstall", "element", "key"]
For $bm In $8f
Local $bn = $8f.Item($bm)
Local $bo = False
For $bp = 0 To UBound($bl) - 1
Local $bq = $bl[$bp]
Local $br = $bn.Item($bq)
Local $bs = $br.Keys
If UBound($bs) > 0 Then
If $bo = False Then
$bo = True
$bk = True
_zj(@CRLF & "  ## " & StringUpper($bm) & " found")
EndIf
For $bt = 0 To UBound($bs) - 1
Local $bu = $bs[$bt]
Local $bv = $br.Item($bu)
_101($bq, $bu, $bv)
Next
EndIf
Next
Next
If $bk = False Then
_zj("  [I] No tools found")
EndIf
EndIf
_102()
EndFunc
FileInstall("C:\Users\test\Desktop\kpRemover\src\assets\bug.gif", @TempDir & "\kprm-logo.gif")
Global $98 = "KpRm"
Global $a2 = False
Global $7w = "kprm-" & @YEAR & @MON & @MDAY & @HOUR & @MIN & ".txt"
Local Const $bw = GUICreate($98, 500, 195, 202, 112)
Local Const $bx = GUICtrlCreateGroup("Actions", 8, 8, 400, 153)
Local Const $by = GUICtrlCreateCheckbox($4z, 16, 40, 129, 17)
Local Const $bz = GUICtrlCreateCheckbox($50, 16, 80, 190, 17)
Local Const $c0 = GUICtrlCreateCheckbox($51, 16, 120, 190, 17)
Local Const $c1 = GUICtrlCreateCheckbox($52, 220, 40, 137, 17)
Local Const $c2 = GUICtrlCreateCheckbox($53, 220, 80, 137, 17)
Local Const $c3 = GUICtrlCreateCheckbox($54, 220, 120, 180, 17)
Global $8u = GUICtrlCreateProgress(8, 170, 480, 17)
GUICtrlCreateGroup("", -99, -99, 1, 1)
GUICtrlSetState($by, 1)
Local Const $c4 = GUICtrlCreatePic(@TempDir & "\kprm-logo.gif", 415, 16, 76, 76)
Local Const $c5 = GUICtrlCreateButton($55, 415, 120, 75, 40)
GUISetState(@SW_SHOW)
While 1
Local $c6 = GUIGetMsg()
Switch $c6
Case $0
Exit
Case $c5
_11u()
EndSwitch
WEnd
Func _11s()
Local Const $c7 = @HomeDrive & "\KPRM"
If Not FileExists($c7) Then
DirCreate($c7)
EndIf
If Not FileExists($c7) Then
MsgBox(16, $57, $58)
Exit
EndIf
EndFunc
Func _11t()
_11s()
_zj("#################################################################################################################" & @CRLF)
_zj("# Run at " & _3o())
_zj("# KpRm version " & $4x)
_zj("# Run by " & @UserName & " from " & @WorkingDir)
_zj("# Computer Name: " & @ComputerName)
_zj("# OS: " & _zt() & " " & @OSArch & " (" & @OSBuild & ") " & @OSServicePack)
_103()
EndFunc
Func _11u()
_11t()
_102()
If GUICtrlRead($c1) = $1 Then
_10a()
EndIf
_102()
If GUICtrlRead($by) = $1 Then
_11r()
_11r(True)
Else
_102(32)
EndIf
_102()
If GUICtrlRead($c3) = $1 Then
_10c()
EndIf
_102()
If GUICtrlRead($c2) = $1 Then
_10b()
EndIf
_102()
If GUICtrlRead($bz) = $1 Then
_104()
EndIf
_102()
If GUICtrlRead($c0) = $1 Then
_109()
EndIf
GUICtrlSetData($8u, 100)
MsgBox(64, "OK", $56)
_zi()
EndFunc
