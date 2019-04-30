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
Global $4x = False
Local Const $4y = "0.0.10"
Local Const $4z[6] = ["040C", "080C", "0C0C", "100C", "140C", "180C"]
If _we($4z, @MUILang) <> 1 Then
Global $50 = "Supprimer des outils"
Global $51 = "Supprimer les points de restaurations"
Global $52 = "Créer un point de restauration"
Global $53 = "Sauvegarder le registre"
Global $54 = "Restaurer UAC"
Global $55 = "Restaurer les paramètres système"
Global $56 = "Exécuter"
Global $57 = "Toutes les opérations sont terminées"
Global $58 = "Echec"
Global $59 = "Impossible de créer une sauvegarde du registre"
Global $5a = "Vous devez exécuter le programme avec les droits administrateurs"
Global $5b = "Vous devez fermer MalwareBytes Anti-Rootkit avant de continuer"
Else
Global $50 = "Delete Tools"
Global $51 = "Delete Restore Points"
Global $52 = "Create Restore Point"
Global $53 = "Registry Backup"
Global $54 = "UAC Restore"
Global $55 = "Restore System Settings"
Global $56 = "Run"
Global $57 = "All operations are completed"
Global $58 = "Fail"
Global $59 = "Unable to create a registry backup"
Global $5a = "You must run the program with administrator rights"
Global $5b = "You must close MalwareBytes Anti-Rootkit before continuing"
EndIf
Global Const $5c = 1
Global Const $5d = 5
Global Const $5e = 0
Global Const $5f = 1
Func _xr($5g = $5d)
If Not IsAdmin() Then Return SetError(-3, 0, -1)
If StringRegExp(@OSVersion, "_(XP|200(0|3))") Then Return SetError(-4, 0, -1)
Local $5h = ""
If @OSArch = "X64" Then $5h = "64"
If $5g < 0 Or $5g > 5 Then Return SetError(-5, 0, -1)
Local $2m = RegWrite("HKEY_LOCAL_MACHINE" & $5h & "\Software\Microsoft\Windows\CurrentVersion\Policies\System", "ConsentPromptBehaviorAdmin", "REG_DWORD", $5g)
If $2m = 0 Then $2m = -1
Return SetError(@error, 0, $2m)
EndFunc
Func _xs($5g = $5c)
If Not IsAdmin() Then Return SetError(-3, 0, -1)
If StringRegExp(@OSVersion, "_(XP|200(0|3))") Then Return SetError(-4, 0, -1)
If $5g < 0 Or $5g = 2 Or $5g > 3 Then Return SetError(-5, 0, -1)
Local $5h = ""
If @OSArch = "X64" Then $5h = "64"
Local $2m = RegWrite("HKEY_LOCAL_MACHINE" & $5h & "\Software\Microsoft\Windows\CurrentVersion\Policies\System", "ConsentPromptBehaviorUser", "REG_DWORD", $5g)
If $2m = 0 Then $2m = -1
Return SetError(@error, 0, $2m)
EndFunc
Func _xt($5g = $5e)
If Not IsAdmin() Then Return SetError(-3, 0, -1)
If StringRegExp(@OSVersion, "_(XP|200(0|3))") Then Return SetError(-4, 0, -1)
If $5g < 0 Or $5g > 1 Then Return SetError(-5, 0, -1)
Local $5h = ""
If @OSArch = "X64" Then $5h = "64"
Local $2m = RegWrite("HKEY_LOCAL_MACHINE" & $5h & "\Software\Microsoft\Windows\CurrentVersion\Policies\System", "EnableInstallerDetection", "REG_DWORD", $5g)
If $2m = 0 Then $2m = -1
Return SetError(@error, 0, $2m)
EndFunc
Func _xu($5g = $5f)
If Not IsAdmin() Then Return SetError(-3, 0, -1)
If StringRegExp(@OSVersion, "_(XP|200(0|3))") Then Return SetError(-4, 0, -1)
If $5g < 0 Or $5g > 1 Then Return SetError(-5, 0, -1)
Local $5h = ""
If @OSArch = "X64" Then $5h = "64"
Local $2m = RegWrite("HKEY_LOCAL_MACHINE" & $5h & "\Software\Microsoft\Windows\CurrentVersion\Policies\System", "EnableLUA", "REG_DWORD", $5g)
If $2m = 0 Then $2m = -1
Return SetError(@error, 0, $2m)
EndFunc
Func _xv($5g = $5f)
If Not IsAdmin() Then Return SetError(-3, 0, -1)
If StringRegExp(@OSVersion, "_(XP|200(0|3))") Then Return SetError(-4, 0, -1)
If $5g < 0 Or $5g > 1 Then Return SetError(-5, 0, -1)
Local $5h = ""
If @OSArch = "X64" Then $5h = "64"
Local $2m = RegWrite("HKEY_LOCAL_MACHINE" & $5h & "\Software\Microsoft\Windows\CurrentVersion\Policies\System", "EnableSecureUIAPaths", "REG_DWORD", $5g)
If $2m = 0 Then $2m = -1
Return SetError(@error, 0, $2m)
EndFunc
Func _xw($5g = $5e)
If Not IsAdmin() Then Return SetError(-3, 0, -1)
If StringRegExp(@OSVersion, "_(XP|200(0|3))") Then Return SetError(-4, 0, -1)
If $5g < 0 Or $5g > 1 Then Return SetError(-5, 0, -1)
Local $5h = ""
If @OSArch = "X64" Then $5h = "64"
Local $2m = RegWrite("HKEY_LOCAL_MACHINE" & $5h & "\Software\Microsoft\Windows\CurrentVersion\Policies\System", "EnableUIADesktopToggle", "REG_DWORD", $5g)
If $2m = 0 Then $2m = -1
Return SetError(@error, 0, $2m)
EndFunc
Func _xx($5g = $5f)
If Not IsAdmin() Then Return SetError(-3, 0, -1)
If StringRegExp(@OSVersion, "_(XP|200(0|3))") Then Return SetError(-4, 0, -1)
If $5g < 0 Or $5g > 1 Then Return SetError(-5, 0, -1)
Local $5h = ""
If @OSArch = "X64" Then $5h = "64"
Local $2m = RegWrite("HKEY_LOCAL_MACHINE" & $5h & "\Software\Microsoft\Windows\CurrentVersion\Policies\System", "EnableVirtualization", "REG_DWORD", $5g)
If $2m = 0 Then $2m = -1
Return SetError(@error, 0, $2m)
EndFunc
Func _xy($5g = $5e)
If Not IsAdmin() Then Return SetError(-3, 0, -1)
If StringRegExp(@OSVersion, "_(XP|200(0|3))") Then Return SetError(-4, 0, -1)
If $5g < 0 Or $5g > 1 Then Return SetError(-5, 0, -1)
Local $5h = ""
If @OSArch = "X64" Then $5h = "64"
Local $2m = RegWrite("HKEY_LOCAL_MACHINE" & $5h & "\Software\Microsoft\Windows\CurrentVersion\Policies\System", "FilterAdministratorToken", "REG_DWORD", $5g)
If $2m = 0 Then $2m = -1
Return SetError(@error, 0, $2m)
EndFunc
Func _xz($5g = $5f)
If Not IsAdmin() Then Return SetError(-3, 0, -1)
If StringRegExp(@OSVersion, "_(XP|200(0|3))") Then Return SetError(-4, 0, -1)
If $5g < 0 Or $5g > 1 Then Return SetError(-5, 0, -1)
Local $5h = ""
If @OSArch = "X64" Then $5h = "64"
Local $2m = RegWrite("HKEY_LOCAL_MACHINE" & $5h & "\Software\Microsoft\Windows\CurrentVersion\Policies\System", "PromptOnSecureDesktop", "REG_DWORD", $5g)
If $2m = 0 Then $2m = -1
Return SetError(@error, 0, $2m)
EndFunc
Func _y0($5g = $5e)
If Not IsAdmin() Then Return SetError(-3, 0, -1)
If StringRegExp(@OSVersion, "_(XP|200(0|3))") Then Return SetError(-4, 0, -1)
If $5g < 0 Or $5g > 1 Then Return SetError(-5, 0, -1)
Local $5h = ""
If @OSArch = "X64" Then $5h = "64"
Local $2m = RegWrite("HKEY_LOCAL_MACHINE" & $5h & "\Software\Microsoft\Windows\CurrentVersion\Policies\System", "ValidateAdminCodeSignatures", "REG_DWORD", $5g)
If $2m = 0 Then $2m = -1
Return SetError(@error, 0, $2m)
EndFunc
Global $5i = Null, $5j = Null
Global $5k = EnvGet('SystemDrive') & '\'
Func _y2()
Local $5l[1][3], $5m = 0
$5l[0][0] = $5m
If Not IsObj($5j) Then $5j = ObjGet("winmgmts:root/default")
If Not IsObj($5j) Then Return $5l
Local $5n = $5j.InstancesOf("SystemRestore")
If Not IsObj($5n) Then Return $5l
For $5o In $5n
$5m += 1
ReDim $5l[$5m + 1][3]
$5l[$5m][0] = $5o.SequenceNumber
$5l[$5m][1] = $5o.Description
$5l[$5m][2] = _y3($5o.CreationTime)
Next
$5l[0][0] = $5m
Return $5l
EndFunc
Func _y3($5p)
Return(StringMid($5p, 5, 2) & "/" & StringMid($5p, 7, 2) & "/" & StringLeft($5p, 4) & " " & StringMid($5p, 9, 2) & ":" & StringMid($5p, 11, 2) & ":" & StringMid($5p, 13, 2))
EndFunc
Func _y4($5q)
Local $w = DllCall('SrClient.dll', 'DWORD', 'SRRemoveRestorePoint', 'DWORD', $5q)
If @error Then Return SetError(1, 0, 0)
If $w[0] = 0 Then Return 1
Return SetError(1, 0, 0)
EndFunc
Func _y6($5r = $5k)
If Not IsObj($5i) Then $5i = ObjGet("winmgmts:{impersonationLevel=impersonate}!root/default:SystemRestore")
If Not IsObj($5i) Then Return 0
If $5i.Enable($5r) = 0 Then Return 1
Return 0
EndFunc
Global Enum $5s = 0, $5t, $5u, $5v, $5w, $5x, $5y, $5z, $60, $61, $62, $63, $64
Global Const $65 = 2
Global $66 = @SystemDir&'\Advapi32.dll'
Global $67 = @SystemDir&'\Kernel32.dll'
Global $68[4][2], $69[4][2]
Global $6a = 0
Func _y9()
$66 = DllOpen(@SystemDir&'\Advapi32.dll')
$67 = DllOpen(@SystemDir&'\Kernel32.dll')
$68[0][0] = "SeRestorePrivilege"
$68[0][1] = 2
$68[1][0] = "SeTakeOwnershipPrivilege"
$68[1][1] = 2
$68[2][0] = "SeDebugPrivilege"
$68[2][1] = 2
$68[3][0] = "SeSecurityPrivilege"
$68[3][1] = 2
$69 = _zh($68)
$6a = 1
EndFunc
Func _yf($6b, $6c = $5t, $6d = 'Administrators', $6e = 1)
Local $6f[1][3]
$6f[0][0] = 'Everyone'
$6f[0][1] = 1
$6f[0][2] = $m
Return _yi($6b, $6f, $6c, $6d, 1, $6e)
EndFunc
Func _yi($6b, $6g, $6c = $5t, $6d = '', $6h = 0, $6e = 0, $6i = 3)
If $6a = 0 Then _y9()
If Not IsArray($6g) Or UBound($6g,2) < 3 Then Return SetError(1,0,0)
Local $6j = _yn($6g,$6i)
Local $6k = @extended
Local $6l = 4, $6m = 0
If $6d <> '' Then
If Not IsDllStruct($6d) Then $6d = _za($6d)
$6m = DllStructGetPtr($6d)
If $6m And _zg($6m) Then
$6l = 5
Else
$6m = 0
EndIf
EndIf
If Not IsPtr($6b) And $6c = $5t Then
Return _yv($6b, $6j, $6m, $6h, $6e, $6k, $6l)
ElseIf Not IsPtr($6b) And $6c = $5w Then
Return _yw($6b, $6j, $6m, $6h, $6e, $6k, $6l)
Else
If $6h Then _yx($6b,$6c)
Return _yo($6b, $6c, $6l, $6m, 0, $6j,0)
EndIf
EndFunc
Func _yn(ByRef $6g, ByRef $6i)
Local $6n = UBound($6g,2)
If Not IsArray($6g) Or $6n < 3 Then Return SetError(1,0,0)
Local $6o = UBound($6g), $6p[$6o], $6q = 0, $6r = 1
Local $6s, $6k = 0, $6t
Local $6u, $6v = 'DWORD;DWORD;DWORD;ptr;DWORD;DWORD;DWORD;ptr'
For $43 = 1 To $6o - 1
$6v &= ';DWORD;DWORD;DWORD;ptr;DWORD;DWORD;DWORD;ptr'
Next
$6u = DllStructCreate($6v)
For $43 = 0 To $6o -1
If Not IsDllStruct($6g[$43][0]) Then $6g[$43][0] = _za($6g[$43][0])
$6p[$43] = DllStructGetPtr($6g[$43][0])
If Not _zg($6p[$43]) Then ContinueLoop
DllStructSetData($6u,$6q+1,$6g[$43][2])
If $6g[$43][1] = 0 Then
$6k = 1
$6s = $8
Else
$6s = $7
EndIf
If $6n > 3 Then $6i = $6g[$43][3]
DllStructSetData($6u,$6q+2,$6s)
DllStructSetData($6u,$6q+3,$6i)
DllStructSetData($6u,$6q+6,0)
$6t = DllCall($66,'BOOL','LookupAccountSid','ptr',0,'ptr',$6p[$43],'ptr*',0,'dword*',32,'ptr*',0,'dword*',32,'dword*',0)
If Not @error Then $6r = $6t[7]
DllStructSetData($6u,$6q+7,$6r)
DllStructSetData($6u,$6q+8,$6p[$43])
$6q += 8
Next
Local $6w = DllStructGetPtr($6u)
$6t = DllCall($66,'DWORD','SetEntriesInAcl','ULONG',$6o,'ptr',$6w ,'ptr',0,'ptr*',0)
If @error Or $6t[0] Then Return SetError(1,0,0)
Return SetExtended($6k, $6t[4])
EndFunc
Func _yo($6b, $6c, $6l, $6m = 0, $6x = 0, $6j = 0, $6y = 0)
Local $6t
If $6a = 0 Then _y9()
If $6j And Not _yp($6j) Then Return 0
If $6y And Not _yp($6y) Then Return 0
If IsPtr($6b) Then
$6t = DllCall($66,'dword','SetSecurityInfo','handle',$6b,'dword',$6c, 'dword',$6l,'ptr',$6m,'ptr',$6x,'ptr',$6j,'ptr',$6y)
Else
If $6c = $5w Then $6b = _zb($6b)
$6t = DllCall($66,'dword','SetNamedSecurityInfo','str',$6b,'dword',$6c, 'dword',$6l,'ptr',$6m,'ptr',$6x,'ptr',$6j,'ptr',$6y)
EndIf
If @error Then Return SetError(1,0,0)
If $6t[0] And $6m Then
If _z0($6b, $6c,_zf($6m)) Then Return _yo($6b, $6c, $6l - 1, 0, $6x, $6j, $6y)
EndIf
Return SetError($6t[0] , 0, Number($6t[0] = 0))
EndFunc
Func _yp($6z)
If $6z = 0 Then Return SetError(1,0,0)
Local $6t = DllCall($66,'bool','IsValidAcl','ptr',$6z)
If @error Or Not $6t[0] Then Return 0
Return 1
EndFunc
Func _yv($6b, ByRef $6j, ByRef $6m, ByRef $6h, ByRef $6e, ByRef $6k, ByRef $6l)
Local $70, $71
If Not $6k Then
If $6h Then _yx($6b,$5t)
$70 = _yo($6b, $5t, $6l, $6m, 0, $6j,0)
EndIf
If $6e Then
Local $72 = FileFindFirstFile($6b&'\*')
While 1
$71 = FileFindNextFile($72)
If $6e = 1 Or $6e = 2 And @extended = 1 Then
_yv($6b&'\'&$71, $6j, $6m, $6h, $6e, $6k,$6l)
ElseIf @error Then
ExitLoop
ElseIf $6e = 1 Or $6e = 3 Then
If $6h Then _yx($6b&'\'&$71,$5t)
_yo($6b&'\'&$71, $5t, $6l, $6m, 0, $6j,0)
EndIf
WEnd
FileClose($72)
EndIf
If $6k Then
If $6h Then _yx($6b,$5t)
$70 = _yo($6b, $5t, $6l, $6m, 0, $6j,0)
EndIf
Return $70
EndFunc
Func _yw($6b, ByRef $6j, ByRef $6m, ByRef $6h, ByRef $6e, ByRef $6k, ByRef $6l)
If $6a = 0 Then _y9()
Local $70, $43 = 0, $71
If Not $6k Then
If $6h Then _yx($6b,$5w)
$70 = _yo($6b, $5w, $6l, $6m, 0, $6j,0)
EndIf
If $6e Then
While 1
$43 += 1
$71 = RegEnumKey($6b,$43)
If @error Then ExitLoop
_yw($6b&'\'&$71, $6j, $6m, $6h, $6e, $6k, $6l)
WEnd
EndIf
If $6k Then
If $6h Then _yx($6b,$5w)
$70 = _yo($6b, $5w, $6l, $6m, 0, $6j,0)
EndIf
Return $70
EndFunc
Func _yx($6b, $6c = $5t)
If $6a = 0 Then _y9()
Local $73 = DllStructCreate('byte[32]'), $w
Local $6j = DllStructGetPtr($73,1)
DllCall($66,'bool','InitializeAcl','Ptr',$6j,'dword',DllStructGetSize($73),'dword',$65)
If IsPtr($6b) Then
$w = DllCall($66,"dword","SetSecurityInfo",'handle',$6b,'dword',$6c,'dword',4,'ptr',0,'ptr',0,'ptr',$6j,'ptr',0)
Else
If $6c = $5w Then $6b = _zb($6b)
DllCall($66,'DWORD','SetNamedSecurityInfo','str',$6b,'dword',$6c,'DWORD',4,'ptr',0,'ptr',0,'ptr',0,'ptr',0)
$w = DllCall($66,'DWORD','SetNamedSecurityInfo','str',$6b,'dword',$6c,'DWORD',4,'ptr',0,'ptr',0,'ptr',$6j,'ptr',0)
EndIf
If @error Then Return SetError(@error,0,0)
Return SetError($w[0],0,Number($w[0] = 0))
EndFunc
Func _z0($6b, $6c = $5t, $74 = 'Administrators')
If $6a = 0 Then _y9()
Local $75 = _za($74), $w
Local $6p = DllStructGetPtr($75)
If IsPtr($6b) Then
$w = DllCall($66,"dword","SetSecurityInfo",'handle',$6b,'dword',$6c,'dword',1,'ptr',$6p,'ptr',0,'ptr',0,'ptr',0)
Else
If $6c = $5w Then $6b = _zb($6b)
$w = DllCall($66,'DWORD','SetNamedSecurityInfo','str',$6b,'dword',$6c,'DWORD',1,'ptr',$6p,'ptr',0,'ptr',0,'ptr',0)
EndIf
If @error Then Return SetError(@error,0,False)
Return SetError($w[0],0,Number($w[0] = 0))
EndFunc
Func _za($74)
If $74 = 'TrustedInstaller' Then $74 = 'NT SERVICE\TrustedInstaller'
If $74 = 'Everyone' Then
Return _zd('S-1-1-0')
ElseIf $74 = 'Authenticated Users' Then
Return _zd('S-1-5-11')
ElseIf $74 = 'System' Then
Return _zd('S-1-5-18')
ElseIf $74 = 'Administrators' Then
Return _zd('S-1-5-32-544')
ElseIf $74 = 'Users' Then
Return _zd('S-1-5-32-545')
ElseIf $74 = 'Guests' Then
Return _zd('S-1-5-32-546')
ElseIf $74 = 'Power Users' Then
Return _zd('S-1-5-32-547')
ElseIf $74 = 'Local Authority' Then
Return _zd('S-1-2')
ElseIf $74 = 'Creator Owner' Then
Return _zd('S-1-3-0')
ElseIf $74 = 'NT Authority' Then
Return _zd('S-1-5-1')
ElseIf $74 = 'Restricted' Then
Return _zd('S-1-5-12')
ElseIf StringRegExp($74,'\A(S-1-\d+(-\d+){0,5})\z') Then
Return _zd($74)
Else
Local $75 = _zc($74)
Return _zd($75)
EndIf
EndFunc
Func _zb($76)
If StringInStr($76,'\\') = 1 Then
$76 = StringRegExpReplace($76,'(?i)\\(HKEY_CLASSES_ROOT|HKCR)','\CLASSES_ROOT')
$76 = StringRegExpReplace($76,'(?i)\\(HKEY_CURRENT_USER|HKCU)','\CURRENT_USER')
$76 = StringRegExpReplace($76,'(?i)\\(HKEY_LOCAL_MACHINE|HKLM)','\MACHINE')
$76 = StringRegExpReplace($76,'(?i)\\(HKEY_USERS|HKU)','\USERS')
Else
$76 = StringRegExpReplace($76,'(?i)\A(HKEY_CLASSES_ROOT|HKCR)','CLASSES_ROOT')
$76 = StringRegExpReplace($76,'(?i)\A(HKEY_CURRENT_USER|HKCU)','CURRENT_USER')
$76 = StringRegExpReplace($76,'(?i)\A(HKEY_LOCAL_MACHINE|HKLM)','MACHINE')
$76 = StringRegExpReplace($76,'(?i)\A(HKEY_USERS|HKU)','USERS')
EndIf
Return $76
EndFunc
Func _zc($77, $78 = "")
Local $79 = DllStructCreate("byte SID[256]")
Local $6p = DllStructGetPtr($79, "SID")
Local $2q = DllCall($66, "bool", "LookupAccountNameW", "wstr", $78, "wstr", $77, "ptr", $6p, "dword*", 256, "wstr", "", "dword*", 256, "int*", 0)
If @error Then Return SetError(@error, @extended, 0)
If Not $2q[0] Then Return 0
Return _zf($6p)
EndFunc
Func _zd($7a)
Local $2q = DllCall($66, "bool", "ConvertStringSidToSidW", "wstr", $7a, "ptr*", 0)
If @error Then Return SetError(@error, @extended, 0)
If Not $2q[0] Then Return 0
Local $7b = _ze($2q[2])
Local $3h = DllStructCreate("byte Data[" & $7b & "]", $2q[2])
Local $7c = DllStructCreate("byte Data[" & $7b & "]")
DllStructSetData($7c, "Data", DllStructGetData($3h, "Data"))
DllCall($67, "ptr", "LocalFree", "ptr", $2q[2])
Return $7c
EndFunc
Func _ze($6p)
If Not _zg($6p) Then Return SetError(-1, 0, "")
Local $2q = DllCall($66, "dword", "GetLengthSid", "ptr", $6p)
If @error Then Return SetError(@error, @extended, 0)
Return $2q[0]
EndFunc
Func _zf($6p)
If Not _zg($6p) Then Return SetError(-1, 0, "")
Local $2q = DllCall($66, "int", "ConvertSidToStringSidW", "ptr", $6p, "ptr*", 0)
If @error Then Return SetError(@error, @extended, "")
If Not $2q[0] Then Return ""
Local $3h = DllStructCreate("wchar Text[256]", $2q[2])
Local $7a = DllStructGetData($3h, "Text")
DllCall($67, "ptr", "LocalFree", "ptr", $2q[2])
Return $7a
EndFunc
Func _zg($6p)
Local $2q = DllCall($66, "bool", "IsValidSid", "ptr", $6p)
If @error Then Return SetError(@error, @extended, False)
Return $2q[0]
EndFunc
Func _zh($7d)
Local $7e = UBound($7d, 0), $7f[1][2]
If Not($7e <= 2 And UBound($7d, $7e) = 2 ) Then Return SetError(1300, 0, $7f)
If $7e = 1 Then
Local $7g[1][2]
$7g[0][0] = $7d[0]
$7g[0][1] = $7d[1]
$7d = $7g
$7g = 0
EndIf
Local $7h, $7i = "dword", $7j = UBound($7d, 1)
Do
$7h += 1
$7i &= ";dword;long;dword"
Until $7h = $7j
Local $7k, $7l, $7m, $7n, $7o, $7p, $7q
$7k = DLLStructCreate($7i)
$7l = DllStructCreate($7i)
$7m = DllStructGetPtr($7l)
$7n = DllStructCreate("dword;long")
DLLStructSetData($7k, 1, $7j)
For $43 = 0 To $7j - 1
DllCall($66, "int", "LookupPrivilegeValue", "str", "", "str", $7d[$43][0], "ptr", DllStructGetPtr($7n) )
DLLStructSetData( $7k, 3 * $43 + 2, DllStructGetData($7n, 1) )
DLLStructSetData( $7k, 3 * $43 + 3, DllStructGetData($7n, 2) )
DLLStructSetData( $7k, 3 * $43 + 4, $7d[$43][1] )
Next
$7o = DllCall($67, "hwnd", "GetCurrentProcess")
$7p = DllCall($66, "int", "OpenProcessToken", "hwnd", $7o[0], "dword", BitOR(0x00000020, 0x00000008), "hwnd*", 0 )
DllCall( $66, "int", "AdjustTokenPrivileges", "hwnd", $7p[3], "int", False, "ptr", DllStructGetPtr($7k), "dword", DllStructGetSize($7k), "ptr", $7m, "dword*", 0 )
$7q = DllCall($67, "dword", "GetLastError")
DllCall($67, "int", "CloseHandle", "hwnd", $7p[3])
Local $7r = DllStructGetData($7l, 1)
If $7r > 0 Then
Local $7s, $7t, $7u, $7f[$7r][2]
For $43 = 0 To $7r - 1
$7s = $7m + 12 * $43 + 4
$7t = DllCall($66, "int", "LookupPrivilegeName", "str", "", "ptr", $7s, "ptr", 0, "dword*", 0 )
$7u = DllStructCreate("char[" & $7t[4] & "]")
DllCall($66, "int", "LookupPrivilegeName", "str", "", "ptr", $7s, "ptr", DllStructGetPtr($7u), "dword*", DllStructGetSize($7u) )
$7f[$43][0] = DllStructGetData($7u, 1)
$7f[$43][1] = DllStructGetData($7l, 3 * $43 + 4)
Next
EndIf
Return SetError($7q[0], 0, $7f)
EndFunc
Func _zi($7v = False)
Dim $4x
Dim $7w
FileDelete(@TempDir & "\kprm-logo.gif")
If $7v = True Then
Run("notepad.exe " & @DesktopDir & "\" & $7w)
If $4x = False Then
Run(@ComSpec & ' /c timeout 3 && del /F /Q "' & @ScriptFullPath & '"', @TempDir, @SW_HIDE)
FileDelete(@ScriptFullPath)
EndIf
EndIf
Exit
EndFunc
If Not IsAdmin() Then
MsgBox(16, $58, $5a)
_zi()
EndIf
Local $7x = ProcessList("mbar.exe")
If $7x[0][0] > 0 Then
MsgBox(16, $58, $5b)
_zi()
EndIf
Func _zj($7y)
Dim $7w
FileWrite(@DesktopDir & "\" & $7w, $7y & @CRLF)
FileWrite(@HomeDrive & "\KPRM" & "\" & $7w, $7y & @CRLF)
EndFunc
Func _zk()
Local $7z = 100, $80 = 100, $81 = 0, $82 = @WindowsDir & "\Explorer.exe"
_hf($2z, 0, 0, 0)
Local $83 = _d0("Shell_TrayWnd", "")
_51($83, 1460, 0, 0)
While ProcessExists("Explorer.exe")
Sleep(10)
$7z -= ProcessClose("Explorer.exe") ? 0 : 1
If $7z < 1 Then Return SetError(1, 0, 0)
WEnd
While(Not ProcessExists("Explorer.exe"))
If Not FileExists($82) Then Return SetError(-1, 0, 0)
Sleep(500)
$81 = ShellExecute($82)
$80 -= $81 ? 0 : 1
If $80 < 1 Then Return SetError(2, 0, 0)
WEnd
Return $81
EndFunc
Func _zn($84, $85, $86)
Local $43 = 0
While True
$43 += 1
Local $87 = RegEnumKey($84, $43)
If @error <> 0 Then ExitLoop
Local $88 = $84 & "\" & $87
Local $71 = RegRead($88, $86)
If StringRegExp($71, $85) Then
Return $88
EndIf
WEnd
Return Null
EndFunc
Func _zp()
Local $89 = []
If FileExists(@HomeDrive & "\Program Files") Then
_vv($89, @HomeDrive & "\Program Files")
EndIf
If FileExists(@HomeDrive & "\Program Files (x86)") Then
_vv($89, @HomeDrive & "\Program Files (x86)")
EndIf
If FileExists(@HomeDrive & "\Program Files(x86)") Then
_vv($89, @HomeDrive & "\Program Files(x86)")
EndIf
Return $89
EndFunc
Func _zq($4l)
Return Int(FileExists($4l) And StringInStr(FileGetAttrib($4l), 'D', Default, 1) = 0)
EndFunc
Func _zr($4l)
Return Int(FileExists($4l) And StringInStr(FileGetAttrib($4l), 'D', Default, 1) > 0)
EndFunc
Func _zs($4l)
Local $8a = Null
If FileExists($4l) Then
Local $8b = StringInStr(FileGetAttrib($4l), 'D', Default, 1)
If $8b = 0 Then
$8a = 'file'
ElseIf $8b > 0 Then
$8a = 'folder'
EndIf
EndIf
Return $8a
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
Func _zu($86)
If StringRegExp($86, "^(HKLM|HKCU|HKU|HKCR|HKCC)64") Then
Local $8c = StringReplace($86, "64", "", 1)
Return $8c
EndIf
Return $86
EndFunc
Func _zv($8d, $86)
If $8d.Exists($86) Then
Local $8b = $8d.Item($86) + 1
$8d.Item($86) = $8b
Else
$8d.add($86, 1)
EndIf
Return $8d
EndFunc
Func _zw($8e, $8f, $8g)
Dim $8h
Local $8i = $8h.Item($8e)
Local $8j = _zv($8i.Item($8f), $8g)
$8i.Item($8f) = $8j
$8h.Item($8e) = $8i
EndFunc
Func _zx($8k, $8l)
If $8k = Null Or $8k = "" Then Return
Local $8m = ProcessExists($8k)
If $8m <> 0 Then
_zj("     [!] Process " & $8k & " exists, it is possible that the deletion is not complete (" & $8l & ")")
EndIf
EndFunc
Func _zy($8n, $8l)
If $8n = Null Or $8n = "" Then Return
Local $8o = "[X]"
RegEnumVal($8n, "1")
If @error >= 0 Then
$8o = "[OK]"
EndIf
_zj("     " & $8o & " " & _zu($8n) & " deleted (" & $8l & ")")
EndFunc
Func _0zz($8n, $8l)
If $8n = Null Or $8n = "" Then Return
Local $4u = "", $4v = "", $4r = "", $4w = ""
Local $8p = _xe($8n, $4u, $4v, $4r, $4w)
If $4w = ".exe" Then
Local $8q = $8p[1] & $8p[2]
Local $8o = "[OK]"
If FileExists($8q) Then
$8o = "[X]"
EndIf
_zj("     " & $8o & " Uninstaller run correctly (" & $8l & ")")
EndIf
EndFunc
Func _100($8n, $8l)
If $8n = Null Or $8n = "" Then Return
Local $8o = "[OK]"
If FileExists($8n) Then
$8o = "[X]"
EndIf
_zj("     " & $8o & " " & $8n & " deleted (" & $8l & ")")
EndFunc
Func _101($8r, $8n, $8l)
Switch $8r
Case "process"
_zx($8n, $8l)
Case "key"
_zy($8n, $8l)
Case "uninstall"
_0zz($8n, $8l)
Case "element"
_100($8n, $8l)
Case Else
_zj("     [?] Unknown type " & $8r)
EndSwitch
EndFunc
Local $8s = 41
Local $8t
Local Const $8u = Floor(100 / $8s)
Func _102($8v = 1)
$8t += $8v
Dim $8w
GUICtrlSetData($8w, $8t * $8u)
If $8t = $8s Then
GUICtrlSetData($8w, 100)
EndIf
EndFunc
Func _103()
$8t = 0
Dim $8w
GUICtrlSetData($8w, 0)
EndFunc
Func _104()
_zj(@CRLF & "- Clear All System Restore Points -" & @CRLF)
Local Const $8x = _y2()
Local $70 = 0
If $8x[0][0] = 0 Then
_zj("  [I] No system recovery points were found")
Return Null
EndIf
Local $8y[1][3] = [[Null, Null, Null]]
For $43 = 1 To $8x[0][0]
Local $8m = _y4($8x[$43][0])
$70 += $8m
If $8m = 1 Then
_zj("    => [OK] RP named " & $8x[$43][1] & " created at " & $8x[$43][2] & " deleted")
Else
Local $8z[1][3] = [[$8x[$43][0], $8x[$43][1], $8x[$43][2]]]
_vv($8y, $8z)
EndIf
Next
If 1 < UBound($8y) Then
Sleep(3000)
For $43 = 1 To UBound($8y) - 1
Local $8m = _y4($8y[$43][0])
$70 += $8m
If $8m = 1 Then
_zj("    => [OK] RP named " & $8y[$43][1] & " created at " & $8x[$43][2] & " deleted")
Else
_zj("    => [X] RP named " & $8y[$43][1] & " created at " & $8x[$43][2] & " deleted")
EndIf
Next
EndIf
If $8x[0][0] = $70 Then
_zj(@CRLF & "  [OK] All system restore points have been successfully deleted")
Else
_zj(@CRLF & "  [X] Failure when deleting all restore points")
EndIf
EndFunc
Func _105($5p)
Local $90 = StringLeft($5p, 4)
Local $91 = StringMid($5p, 6, 2)
Local $92 = StringMid($5p, 9, 2)
Local $93 = StringRight($5p, 8)
Return $91 & "/" & $92 & "/" & $90 & " " & $93
EndFunc
Func _106($94 = False)
Local Const $8x = _y2()
If $8x[0][0] = 0 Then
Return Null
EndIf
Local Const $95 = _105(_31('n', -1470, _3p()))
Local $96 = False
Local $97 = False
Local $98 = False
For $43 = 1 To $8x[0][0]
Local $99 = $8x[$43][2]
If $99 > $95 Then
If $98 = False Then
$98 = True
$97 = True
_zj(@CRLF & "  [I] Recent System Restore Point Deletion before create new:" & @CRLF)
EndIf
Local $8m = _y4($8x[$43][0])
If $8m = 1 Then
_zj("    => [OK] RP named " & $8x[$43][1] & " created at " & $99 & " deleted")
ElseIf $94 = False Then
$96 = True
Else
_zj("    => [X] RP named " & $8x[$43][1] & " created at " & $99 & " deleted")
EndIf
EndIf
Next
If $96 = True Then
Sleep(3000)
_zj("  [I] Retry deleting restore point")
_106(True)
EndIf
If $97 = True Then
_zj(@CRLF)
EndIf
Sleep(3000)
EndFunc
Func _107()
Sleep(3000)
_zj(@CRLF & "- Display All System Restore Point -" & @CRLF)
Local Const $8x = _y2()
If $8x[0][0] = 0 Then
_zj("  [X] No System Restore point found")
Return
EndIf
For $43 = 1 To $8x[0][0]
_zj("    => [I] RP named " & $8x[$43][1] & " created at " & $8x[$43][2] & " found")
Next
EndFunc
Func _108()
RunWait(@ComSpec & ' /c ' & 'wmic.exe /Namespace:\\root\default Path SystemRestore Call CreateRestorePoint "KpRm", 100, 7', "", @SW_HIDE)
Return @error
EndFunc
Func _109($94 = False)
If $94 = False Then
_zj(@CRLF & "- Create New System Restore Point -" & @CRLF)
Else
_zj("  [I] Retry Create New System Restore Point")
EndIf
Dim $9a
Local $9b = _y6()
If $9b = 0 Then
Sleep(3000)
$9b = _y6()
If $9b = 0 Then
_zj("  [X] Enable System Restore")
EndIf
ElseIf $9b = 1 Then
_zj("  [OK] Enable System Restore")
EndIf
_106()
Local Const $9c = _108()
If $9c <> 0 Then
_zj("  [X] System Restore Point created")
If $94 = False Then
_zj("  [I] Retry to create System Restore Point!")
_109(True)
Return
Else
_107()
Return
EndIf
ElseIf $9c = 0 Then
_zj("  [OK] System Restore Point created")
_107()
EndIf
EndFunc
Func _10a()
_zj(@CRLF & "- Create Registry Backup -" & @CRLF)
Local Const $9d = @HomeDrive & "\KPRM"
Local Const $9e = $9d & "\regedit-backup-" & @YEAR & @MON & @MDAY & @HOUR & @MIN & ".reg"
If FileExists($9e) Then
FileMove($9e, $9e & ".old")
EndIf
Local Const $8m = RunWait("Regedit /e " & $9e)
If Not FileExists($9e) Or @error <> 0 Then
_zj("  [X] Failed to create registry backup")
MsgBox(16, $58, $59)
_zi()
Else
_zj("  [OK] Registry Backup: " & $9e)
EndIf
EndFunc
Func _10b()
_zj(@CRLF & "- Restore UAC Default Value -" & @CRLF)
Local $8m = _xr()
If $8m = 1 Then
_zj("  [OK] Set ConsentPromptBehaviorAdmin with default (5) value")
Else
_zj("  [X] Set ConsentPromptBehaviorAdmin with default value")
EndIf
Local $8m = _xs(3)
If $8m = 1 Then
_zj("  [OK] Set ConsentPromptBehaviorUser with default (3) value")
Else
_zj("  [X] Set ConsentPromptBehaviorUser with default value")
EndIf
Local $8m = _xt()
If $8m = 1 Then
_zj("  [OK] Set EnableInstallerDetection with default (0) value")
Else
_zj("  [X] Set EnableInstallerDetection with default value")
EndIf
Local $8m = _xu()
If $8m = 1 Then
_zj("  [OK] Set EnableLUA with default (1) value")
Else
_zj("  [X] Set EnableLUA with default value")
EndIf
Local $8m = _xv()
If $8m = 1 Then
_zj("  [OK] Set EnableSecureUIAPaths with default (1) value")
Else
_zj("  [X] Set EnableSecureUIAPaths with default value")
EndIf
Local $8m = _xw()
If $8m = 1 Then
_zj("  [OK] Set EnableUIADesktopToggle with default (0) value")
Else
_zj("  [X] Set EnableUIADesktopToggle with default value")
EndIf
Local $8m = _xx()
If $8m = 1 Then
_zj("  [OK] Set EnableVirtualization with default (1) value")
Else
_zj("  [X] Set EnableVirtualization with default value")
EndIf
Local $8m = _xy()
If $8m = 1 Then
_zj("  [OK] Set FilterAdministratorToken with default (0) value")
Else
_zj("  [X] Set FilterAdministratorToken with default value")
EndIf
Local $8m = _xz()
If $8m = 1 Then
_zj("  [OK] Set PromptOnSecureDesktop with default (1) value")
Else
_zj("  [X] Set PromptOnSecureDesktop with default value")
EndIf
Local $8m = _y0()
If $8m = 1 Then
_zj("  [OK] Set ValidateAdminCodeSignatures with default (0) value")
Else
_zj("  [X] Set ValidateAdminCodeSignatures with default value")
EndIf
EndFunc
Func _10c()
_zj(@CRLF & "- Restore Default System Settings -" & @CRLF)
Local $8m = RunWait(@ComSpec & " /c " & "ipconfig /flushdns", @TempDir, @SW_HIDE)
If @error <> 0 Then
_zj("  [X] Flush DNS")
Else
_zj("  [OK] Flush DNS")
EndIf
Local Const $9f[7] = [ "netsh winsock reset", "netsh winhttp reset proxy", "netsh winhttp reset tracing", "netsh winsock reset catalog", "netsh int ip reset all", "netsh int ipv4 reset catalog", "netsh int ipv6 reset catalog" ]
$8m = 0
For $43 = 0 To UBound($9f) -1
RunWait(@ComSpec & " /c " & $9f[$43], @TempDir, @SW_HIDE)
If @error <> 0 Then
$8m += 1
EndIf
Next
If $8m = 0 Then
_zj("  [OK] Reset WinSock")
Else
_zj("  [X] Reset WinSock")
EndIf
Local $9g = "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced"
$8m = RegWrite($9g, "Hidden", "REG_DWORD", "2")
If $8m = 1 Then
_zj("  [OK] Hide Hidden file.")
Else
_zj("  [X] Hide Hidden File")
EndIf
$8m = RegWrite($9g, "HideFileExt", "REG_DWORD", "1")
If $8m = 1 Then
_zj("  [OK] Hide Extensions for known file types")
Else
_zj("  [X] Hide Extensions for known file types")
EndIf
$8m = RegWrite($9g, "ShowSuperHidden", "REG_DWORD", "0")
If $8m = 1 Then
_zj("  [OK] Hide protected operating system files")
Else
_zj("  [X] Hide protected operating system files")
EndIf
_zk()
EndFunc
Global $8h = ObjCreate("Scripting.Dictionary")
Local Const $9h[36] = [ "frst", "zhpdiag", "zhpcleaner", "zhpfix", "zhplite", "mbar", "roguekiller", "usbfix", "adwcleaner", "adsfix", "aswmbr", "fss", "toolsdiag", "scanrapide", "otl", "otm", "listparts", "minitoolbox", "miniregtool", "zhp", "combofix", "regtoolexport", "tdsskiller", "winupdatefix", "rsthosts", "winchk", "avenger", "blitzblank", "zoek", "remediate-vbs-worm", "ckscanner", "quickdiag", "adlicediag", "rstassociations", "sft", "grantperms"]
For $9i = 0 To UBound($9h) - 1
Local $9j = ObjCreate("Scripting.Dictionary")
Local $9k = ObjCreate("Scripting.Dictionary")
Local $9l = ObjCreate("Scripting.Dictionary")
Local $9m = ObjCreate("Scripting.Dictionary")
Local $9n = ObjCreate("Scripting.Dictionary")
$9j.add("key", $9k)
$9j.add("element", $9l)
$9j.add("uninstall", $9m)
$9j.add("process", $9n)
$8h.add($9h[$9i], $9j)
Next
Global $9o[1][2] = [[Null, Null]]
Global $9p[1][5] = [[Null, Null, Null, Null, Null]]
Global $9q[1][5] = [[Null, Null, Null, Null, Null]]
Global $9r[1][5] = [[Null, Null, Null, Null, Null]]
Global $9s[1][5] = [[Null, Null, Null, Null, Null]]
Global $9t[1][5] = [[Null, Null, Null, Null, Null]]
Global $9u[1][2] = [[Null, Null]]
Global $9v[1][2] = [[Null, Null]]
Global $9w[1][4] = [[Null, Null, Null, Null]]
Global $9x[1][5] = [[Null, Null, Null, Null, Null]]
Global $9y[1][5] = [[Null, Null, Null, Null, Null]]
Global $9z[1][5] = [[Null, Null, Null, Null, Null]]
Global $a0[1][5] = [[Null, Null, Null, Null, Null]]
Global $a1[1][5] = [[Null, Null, Null, Null, Null]]
Global $a2[1][3] = [[Null, Null, Null]]
Func _10d($84, $a3 = 0, $a4 = False)
Dim $a5
If $a5 Then _zj("[I] prepareRemove " & $84)
If $a4 Then
_yx($84)
_yf($84)
EndIf
Local Const $a6 = FileGetAttrib($84)
If StringInStr($a6, "R") Then
FileSetAttrib($84, "-R", $a3)
EndIf
If StringInStr($a6, "S") Then
FileSetAttrib($84, "-S", $a3)
EndIf
If StringInStr($a6, "H") Then
FileSetAttrib($84, "-H", $a3)
EndIf
If StringInStr($a6, "A") Then
FileSetAttrib($84, "-A", $a3)
EndIf
EndFunc
Func _10e($a7, $8e, $a8 = Null, $a4 = False)
Dim $a5
If $a5 Then _zj("[I] RemoveFile " & $a7)
Local Const $a9 = _zq($a7)
If $a9 Then
If $a8 And StringRegExp($a7, "(?i)\.exe$") Then
Local Const $aa = FileGetVersion($a7, "CompanyName")
If @error Then
Return 0
ElseIf Not StringRegExp($aa, $a8) Then
Return 0
EndIf
EndIf
_zw($8e, 'element', $a7)
_10d($a7, 0, $a4)
Local $ab = FileDelete($a7)
If $ab Then
If $a5 Then
_zj("  [OK] File " & $a7 & " deleted successfully")
EndIf
Return 1
EndIf
Return 2
EndIf
Return 0
EndFunc
Func _10f($84, $8e, $a4 = False)
Dim $a5
If $a5 Then _zj("[I] RemoveFolder " & $84)
Local $a9 = _zr($84)
If $a9 Then
_zw($8e, 'element', $84)
_10d($84, 1, $a4)
Local Const $ab = DirRemove($84, $l)
If $ab Then
If $a5 Then
_zj("  [OK] Directory " & $84 & " deleted successfully")
EndIf
Return 1
EndIf
Return 2
EndIf
Return 0
EndFunc
Func _10g($84, $a7, $ac)
Dim $a5
If $a5 Then _zj("[I] FindGlob " & $84 & " " & $a7)
Local Const $ad = $84 & "\" & $a7
Local Const $4t = FileFindFirstFile($ad)
Local $ae = []
If $4t = -1 Then
Return $ae
EndIf
Local $4r = FileFindNextFile($4t)
While @error = 0
If StringRegExp($4r, $ac) Then
_vv($ae, $84 & "\" & $4r)
EndIf
$4r = FileFindNextFile($4t)
WEnd
FileClose($4t)
Return $ae
EndFunc
Func _10h($84, $af)
Dim $a5
If $a5 Then _zj("[I] RemoveAllFileFrom " & $84)
Local Const $ad = $84 & "\*"
Local Const $4t = FileFindFirstFile($ad)
If $4t = -1 Then
Return Null
EndIf
Local $4r = FileFindNextFile($4t)
While @error = 0
For $ag = 1 To UBound($af) - 1
Local $ah = $84 & "\" & $4r
Local $ai = _zs($ah)
If $ai And $af[$ag][3] And $ai = $af[$ag][1] And StringRegExp($4r, $af[$ag][3]) Then
Local $8m = 0
Local $a4 = False
If $af[$ag][4] = True Then
$a4 = True
EndIf
If $ai = 'file' Then
$8m = _10e($ah, $af[$ag][0], $af[$ag][2], $a4)
ElseIf $ai = 'folder' Then
$8m = _10f($ah, $af[$ag][0], $a4)
EndIf
EndIf
Next
$4r = FileFindNextFile($4t)
WEnd
FileClose($4t)
EndFunc
Func _10i($86, $8e, $a4 = False)
Dim $a5
If $a5 Then _zj("[I] RemoveRegistryKey " & $86)
If $a4 = True Then
_yx($86)
_yf($86, $5w)
EndIf
Local Const $8m = RegDelete($86)
If $8m <> 0 Then
_zw($8e, "key", $86)
If $a5 Then
If $8m = 1 Then
_zj("  [OK] " & $86 & " deleted successfully")
ElseIf $8m = 2 Then
_zj("  [X] " & $86 & " deleted failed")
EndIf
EndIf
EndIf
Return $8m
EndFunc
Func _10j($8k)
Local $aj = 50
Dim $a5
If $a5 Then _zj("[I] CloseProcessAndWait " & $8k)
If 0 = ProcessExists($8k) Then Return 0
ProcessClose($8k)
Do
$aj -= 1
Sleep(250)
Until($aj = 0 Or 0 = ProcessExists($8k))
Local Const $8m = ProcessExists($8k)
If 0 = $8m Then
If $a5 Then _zj("  [OK] Proccess " & $8k & " stopped successfully")
Return 1
EndIf
Return 0
EndFunc
Func _10k($7x)
Dim $aj
Dim $a5
If $a5 Then _zj("[I] RemoveAllProcess")
Local $ak = ProcessList()
For $43 = 1 To $ak[0][0]
Local $al = $ak[$43][0]
Local $am = $ak[$43][1]
For $aj = 1 To UBound($7x) - 1
If StringRegExp($al, $7x[$aj][1]) Then
_10j($am)
_zw($7x[$aj][0], "process", $al)
EndIf
Next
Next
EndFunc
Func _10l($an)
Dim $a5
If $a5 Then _zj("[I] RemoveScheduleTask")
For $43 = 1 To UBound($an) - 1
RunWait('schtasks.exe /delete /tn "' & $an[$43][1] & '" /f', @TempDir, @SW_HIDE)
Next
EndFunc
Func _10m($an)
Dim $a5
If $a5 Then _zj("[I] UninstallNormaly")
Local Const $89 = _zp()
For $43 = 1 To UBound($89) - 1
For $ao = 1 To UBound($an) - 1
Local $ap = $an[$ao][1]
Local $aq = $an[$ao][2]
Local $ar = _10g($89[$43], "*", $ap)
For $as = 1 To UBound($ar) - 1
Local $at = _10g($ar[$as], "*", $aq)
For $au = 1 To UBound($at) - 1
If _zq($at[$au]) Then
RunWait($at[$au])
_zw($an[$ao][0], "uninstall", $at[$au])
EndIf
Next
Next
Next
Next
EndFunc
Func _10n($an)
Dim $a5
If $a5 Then _zj("[I] RemoveAllProgramFilesDir")
Local Const $89 = _zp()
For $43 = 1 To UBound($89) - 1
_10h($89[$43], $an)
Next
EndFunc
Func _10o($an)
Dim $a5
If $a5 Then _zj("[I] RemoveAllSoftwareKeyList")
Local $5h = ""
If @OSArch = "X64" Then $5h = "64"
Local $av[2] = ["HKCU" & $5h & "\SOFTWARE", "HKLM" & $5h & "\SOFTWARE"]
For $7h = 0 To UBound($av) - 1
Local $43 = 0
While True
$43 += 1
Local $87 = RegEnumKey($av[$7h], $43)
If @error <> 0 Then ExitLoop
For $ao = 1 To UBound($an) - 1
If $87 And $an[$ao][1] Then
If StringRegExp($87, $an[$ao][1]) Then
Local $aw = $av[$7h] & "\" & $87
_10i($aw, $an[$ao][0])
EndIf
EndIf
Next
WEnd
Next
EndFunc
Func _10p($an)
Dim $a5
If $a5 Then _zj("[I] RemoveUninstallStringWithSearch")
For $43 = 1 To UBound($an) - 1
Local $aw = _zn($an[$43][1], $an[$43][2], $an[$43][3])
If $aw And $aw <> "" Then
_10i($aw, $an[$43][0])
EndIf
Next
EndFunc
Func _10q()
Local Const $ax = "frst"
Dim $9o
Dim $9p
Dim $ay
Dim $9r
Dim $az
Dim $9t
Local Const $a8 = "(?i)^Farbar"
Local Const $b0 = "(?i)^FRST.*\.exe$"
Local Const $b1 = "(?i)^FRST-OlderVersion$"
Local Const $b2 = "(?i)^(FRST|fixlist|fixlog|Addition|Shortcut).*\.(exe|txt)$"
Local Const $b3 = "(?i)^FRST"
Local Const $b4[1][2] = [[$ax, $b0]]
Local Const $b5[1][5] = [[$ax, 'file', $a8, $b2, False]]
Local Const $b6[1][5] = [[$ax, 'folder', Null, $b1, False]]
Local Const $b7[1][5] = [[$ax, 'folder', Null, $b3, True]]
_vv($9o, $b4)
_vv($9p, $b5)
_vv($9r, $b5)
_vv($9p, $b6)
_vv($9r, $b6)
_vv($9t, $b7)
EndFunc
_10q()
Func _10r()
Dim $9z
Dim $9u
Dim $9y
Local $ax = "zhp"
Local Const $8b[1][2] = [[$ax, "(?i)^ZHP$"]]
Local Const $b8[1][5] = [[$ax, 'folder', Null, "(?i)^ZHP$", True]]
_vv($9u, $8b)
_vv($9z, $b8)
_vv($9y, $b8)
EndFunc
_10r()
Func _10s()
Local Const $b9 = Null
Local Const $ax = "zhpdiag"
Dim $9o
Dim $9p
Dim $9q
Dim $9r
Dim $9t
Local Const $b0 = "(?i)^ZHPDiag.*\.exe$"
Local Const $b1 = "(?i)^ZHPDiag.*\.(exe|txt|lnk)$"
Local Const $b2 = "(?i)^PhysicalDisk[0-9]_MBR\.bin$"
Local Const $b4[1][2] = [[$ax, $b0]]
Local Const $b5[1][5] = [[$ax, 'file', $b9, $b1, False]]
Local Const $b6[1][5] = [[$ax, 'file', Null, $b2, True]]
_vv($9o, $b4)
_vv($9p, $b5)
_vv($9r, $b5)
_vv($9q, $b5)
_vv($9t, $b6)
EndFunc
_10s()
Func _10t()
Local Const $b9 = Null
Local Const $ba = "zhpfix"
Dim $9o
Dim $9p
Dim $9r
Local Const $b0 = "(?i)^ZHPFix.*\.exe$"
Local Const $b1 = "(?i)^ZHPFix.*\.(exe|txt|lnk)$"
Local Const $b4[1][2] = [[$ba, $b0]]
Local Const $b5[1][5] = [[$ba, 'file', $b9, $b1, False]]
_vv($9o, $b4)
_vv($9p, $b5)
_vv($9r, $b5)
EndFunc
_10t()
Func _10u()
Local Const $b9 = Null
Local Const $ba = "zhplite"
Dim $9o
Dim $9p
Dim $9r
Local Const $b0 = "(?i)^ZHPLite.*\.exe$"
Local Const $b1 = "(?i)^ZHPLite.*\.(exe|txt|lnk)$"
Local Const $b4[1][2] = [[$ba, $b0]]
Local Const $b5[1][5] = [[$ba, 'file', $b9, $b1, False]]
_vv($9o, $b4)
_vv($9p, $b5)
_vv($9r, $b5)
EndFunc
_10u()
Func _10v($94 = False)
Local Const $a8 = "(?i)^Malwarebytes Anti-Rootkit$"
Local Const $bb = "(?i)^Malwarebytes"
Local Const $ax = "mbar"
Dim $9o
Dim $9p
Dim $9r
Dim $9u
Local Const $b0 = "(?i)^mbar.*\.exe$"
Local Const $b1 = "(?i)^mbar"
Local Const $b4[1][2] = [[$ax, $b0]]
Local Const $b5[1][2] = [[$ax, $a8]]
Local Const $b6[1][5] = [[$ax, 'file', $bb, $b0, False]]
Local Const $b7[1][5] = [[$ax, 'folder', $a8, $b1, False]]
_vv($9o, $b4)
_vv($9p, $b6)
_vv($9r, $b6)
_vv($9p, $b7)
_vv($9r, $b7)
_vv($9u, $b5)
EndFunc
_10v()
Func _10w()
Local Const $ax = "roguekiller"
Dim $9o
Dim $9v
Dim $9w
Dim $9s
Dim $9x
Dim $9p
Dim $9q
Dim $a0
Dim $9r
Local $5h = ""
If @OSArch = "X64" Then $5h = "64"
Local Const $bc = "(?i)^Adlice"
Local Const $b0 = "(?i)^RogueKiller"
Local Const $b1 = "(?i)^RogueKiller.*\.(exe|lnk|txt)$"
Local Const $b2 = "(?i)^RogueKiller.*\.exe$"
Local Const $b3 = "(?i)^RogueKiller_portable(32|64)\.exe$"
Local Const $b4[1][2] = [[$ax, $b2]]
Local Const $b5[1][2] = [[$ax, "RogueKiller Anti-Malware"]]
Local Const $b6[1][4] = [[$ax, "HKLM" & $5h & "\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall", $b0, "DisplayName"]]
Local Const $b7[1][5] = [[$ax, 'file', $bc, $b1, False]]
Local Const $bd[1][5] = [[$ax, 'folder', Null, $b0, True]]
Local Const $be[1][5] = [[$ax, 'file', Null, $b3, False]]
_vv($9o, $b4)
_vv($9v, $b5)
_vv($9w, $b6)
_vv($9s, $bd)
_vv($9x, $bd)
_vv($9p, $be)
_vv($9p, $b7)
_vv($9p, $bd)
_vv($9r, $be)
_vv($9r, $b7)
_vv($9r, $bd)
_vv($9q, $b7)
_vv($a0, $bd)
EndFunc
_10w()
Func _10x()
Local Const $ax = "adwcleaner"
Local Const $a8 = "(?i)^AdwCleaner"
Local Const $bb = "(?i)^Malwarebytes"
Local Const $b0 = "(?i)^AdwCleaner.*\.exe$"
Dim $9o
Dim $9p
Dim $9r
Dim $9t
Local Const $b4[1][2] = [[$ax, $b0]]
Local Const $b5[1][5] = [[$ax, 'file', $bb, $b0, False]]
Local Const $b6[1][5] = [[$ax, 'folder', Null, $a8, True]]
_vv($9o, $b4)
_vv($9p, $b5)
_vv($9r, $b5)
_vv($9t, $b6)
EndFunc
_10x()
Func _10y()
Local Const $b9 = Null
Local Const $ax = "zhpcleaner"
Dim $9o
Dim $9p
Dim $9r
Local Const $b0 = "(?i)^ZHPCleaner.*\.exe$"
Local Const $b1 = "(?i)^ZHPCleaner.*\.(exe|txt|lnk)$"
Local Const $b4[1][2] = [[$ax, $b0]]
Local Const $b5[1][5] = [[$ax, 'file', $b9, $b1, False]]
_vv($9o, $b4)
_vv($9p, $b5)
_vv($9r, $b5)
EndFunc
_10y()
Func _10z()
Local Const $ax = "usbfix"
Dim $9o
Dim $a2
Dim $9p
Dim $9q
Dim $9r
Dim $9u
Dim $9t
Dim $9s
Local Const $a8 = "(?i)^UsbFix"
Local Const $bb = "(?i)^SosVirus"
Local Const $b0 = "(?i)^UsbFix.*\.(exe|lnk|txt)$"
Local Const $b1 = "(?i)^Un-UsbFix.exe$"
Local Const $b2 = "(?i)^UsbFixQuarantine$"
Local Const $b3 = "(?i)^UsbFix.*\.exe$"
Local Const $bf[1][2] = [[$ax, $b3]]
Local Const $b4[1][2] = [[$ax, $a8]]
Local Const $b5[1][3] = [[$ax, $a8, $b1]]
Local Const $b6[1][5] = [[$ax, 'file', $bb, $b0, False]]
Local Const $b7[1][5] = [[$ax, 'folder', Null, $b2, True]]
Local Const $bd[1][5] = [[$ax, 'folder', Null, $a8, False]]
_vv($9o, $bf)
_vv($a2, $b5)
_vv($9p, $b6)
_vv($9q, $b6)
_vv($9r, $b6)
_vv($9u, $b4)
_vv($9t, $b7)
_vv($9t, $bd)
_vv($9s, $bd)
EndFunc
_10z()
Func _110()
Local Const $ax = "adsfix"
Dim $9o
Dim $9p
Dim $9r
Dim $9t
Dim $9q
Dim $9u
Local Const $a8 = "(?i)^AdsFix"
Local Const $bb = "(?i)^SosVirus"
Local Const $b0 = "(?i)^AdsFix.*\.exe$"
Local Const $b1 = "(?i)^AdsFix.*\.(exe|txt|lnk)$"
Local Const $b2 = "(?i)^AdsFix.*\.txt$"
Local Const $b4[1][2] = [[$ax, $b0]]
Local Const $b5[1][5] = [[$ax, 'file', $bb, $b1, False]]
Local Const $b6[1][5] = [[$ax, 'file', Null, $b2, False]]
Local Const $b7[1][5] = [[$ax, 'folder', Null, $a8, True]]
Local Const $bd[1][2] = [[$ax, $a8]]
_vv($9o, $b4)
_vv($9p, $b5)
_vv($9q, $b5)
_vv($9r, $b5)
_vv($9t, $b6)
_vv($9t, $b7)
_vv($9u, $bd)
EndFunc
_110()
Func _111()
Local Const $ax = "aswmbr"
Dim $9o
Dim $9p
Dim $9r
Local Const $a8 = "(?i)^avast"
Local Const $b0 = "(?i)^aswmbr.*\.(exe|txt|lnk)$"
Local Const $b1 = "(?i)^MBR\.dat$"
Local Const $b2 = "(?i)^aswmbr.*\.exe$"
Local Const $b4[1][2] = [[$ax, $b2]]
Local Const $b5[1][5] = [[$ax, 'file', $a8, $b0, False]]
Local Const $b6[1][5] = [[$ax, 'file', Null, $b1, False]]
_vv($9o, $b4)
_vv($9p, $b5)
_vv($9p, $b6)
_vv($9r, $b5)
EndFunc
_111()
Func _112()
Local Const $ax = "fss"
Dim $9o
Dim $9p
Dim $9r
Local Const $a8 = "(?i)^Farbar"
Local Const $b0 = "(?i)^FSS.*\.(exe|txt|lnk)$"
Local Const $b1 = "(?i)^FSS.*\.exe$"
Local Const $b4[1][2] = [[$ax, $b1]]
Local Const $b5[1][5] = [[$ax, 'file', $a8, $b0, False]]
_vv($9o, $b4)
_vv($9p, $b5)
_vv($9r, $b5)
EndFunc
_112()
Func _113()
Local Const $ax = "toolsdiag"
Dim $9o
Dim $9p
Dim $9r
Dim $9t
Local Const $b0 = "(?i)^toolsdiag.*\.exe$"
Local Const $b1 = "(?i)^ToolsDiag$"
Local Const $b4[1][5] = [[$ax, 'folder', Null, $b1, False]]
Local Const $b5[1][5] = [[$ax, 'file', Null, $b0, False]]
Local Const $b6[1][2] = [[$ax, $b0]]
_vv($9o, $b6)
_vv($9p, $b5)
_vv($9r, $b5)
_vv($9t, $b4)
EndFunc
_113()
Func _114()
Local Const $ax = "scanrapide"
Dim $9t
Dim $9p
Dim $9r
Local Const $a8 = Null
Local Const $b0 = "(?i)^ScanRapide.*\.exe$"
Local Const $b1 = "(?i)^ScanRapide\[R[0-9]+\]\.txt$"
Local Const $b4[1][5] = [[$ax, 'file', $a8, $b0, False]]
Local Const $b5[1][5] = [[$ax, 'file', Null, $b1, False]]
_vv($9p, $b4)
_vv($9r, $b4)
_vv($9t, $b5)
EndFunc
_114()
Func _115()
Local Const $ax = "otl"
Dim $9o
Dim $9p
Dim $9r
Dim $9t
Dim $9u
Local Const $a8 = "(?i)^OldTimer"
Local Const $b0 = "(?i)^OTL.*\.exe$"
Local Const $b1 = "(?i)^OTL.*\.(exe|txt)$"
Local Const $b2 = "(?i)^Extras\.txt$"
Local Const $b3 = "(?i)^_OTL$"
Local Const $bg = "(?i)^OldTimer Tools$"
Local Const $b4[1][2] = [[$ax, $b0]]
Local Const $b5[1][5] = [[$ax, 'file', $a8, $b1, False]]
Local Const $b6[1][5] = [[$ax, 'file', Null, $b2, False]]
Local Const $b7[1][5] = [[$ax, 'folder', Null, $b3, True]]
Local Const $bd[1][2] = [[$ax, $bg]]
_vv($9o, $b4)
_vv($9p, $b5)
_vv($9p, $b6)
_vv($9r, $b5)
_vv($9t, $b7)
_vv($9u, $bd)
EndFunc
_115()
Func _116()
Local Const $ax = "otm"
Dim $9o
Dim $9p
Dim $9r
Dim $9t
Local Const $a8 = "(?i)^OldTimer"
Local Const $b0 = "(?i)^OTM.*\.exe$"
Local Const $b1 = "(?i)^_OTM$"
Local Const $b4[1][2] = [[$ax, $b0]]
Local Const $b5[1][5] = [[$ax, 'file', $a8, $b0, False]]
Local Const $b6[1][5] = [[$ax, 'folder', Null, $b1, True]]
_vv($9o, $b4)
_vv($9p, $b5)
_vv($9r, $b5)
_vv($9t, $b6)
EndFunc
_116()
Func _117()
Local Const $ax = "listparts"
Dim $9o
Dim $9p
Dim $9r
Dim $9t
Local Const $a8 = "(?i)^Farbar"
Local Const $b0 = "(?i)^listParts.*\.exe$"
Local Const $b1 = "(?i)^Results\.txt$"
Local Const $b4[1][2] = [[$ax, $b0]]
Local Const $b5[1][5] = [[$ax, 'file', $a8, $b0, False]]
Local Const $b6[1][5] = [[$ax, 'file', Null, $b1, False]]
_vv($9o, $b4)
_vv($9p, $b5)
_vv($9p, $b6)
_vv($9r, $b5)
_vv($9r, $b6)
EndFunc
_117()
Func _118()
Local Const $ax = "minitoolbox"
Dim $9o
Dim $9p
Dim $9r
Dim $9t
Local Const $a8 = "(?i)^Farbar"
Local Const $b0 = "(?i)^MiniToolBox.*\.exe$"
Local Const $b1 = "(?i)^MTB\.txt$"
Local Const $b4[1][2] = [[$ax, $b0]]
Local Const $b5[1][5] = [[$ax, 'file', $a8, $b0, False]]
Local Const $b6[1][5] = [[$ax, 'file', Null, $b1, False]]
_vv($9o, $b4)
_vv($9p, $b5)
_vv($9p, $b6)
_vv($9r, $b5)
_vv($9r, $b6)
EndFunc
_118()
Func _119()
Local Const $ax = "miniregtool"
Dim $9o
Dim $9p
Dim $9r
Dim $9t
Local Const $a8 = Null
Local Const $b0 = "(?i)^MiniRegTool.*\.exe$"
Local Const $b1 = "(?i)^MiniRegTool.*\.(exe|zip)$"
Local Const $b2 = "(?i)^Result\.txt$"
Local Const $b3 = "(?i)^MiniRegTool"
Local Const $b4[1][2] = [[$ax, $b0]]
Local Const $b5[1][5] = [[$ax, 'file', $a8, $b1, False]]
Local Const $b6[1][5] = [[$ax, 'file', $a8, $b2, False]]
Local Const $b7[1][5] = [[$ax, 'folder', $a8, $b3, False]]
_vv($9o, $b4)
_vv($9p, $b5)
_vv($9p, $b6)
_vv($9p, $b7)
_vv($9r, $b5)
_vv($9r, $b6)
_vv($9r, $b7)
EndFunc
_119()
Func _11a()
Local Const $ax = "grantperms"
Dim $9o
Dim $9p
Dim $9r
Dim $9t
Local Const $a8 = Null
Local Const $b0 = "(?i)^GrantPerms.*\.exe$"
Local Const $b1 = "(?i)^GrantPerms.*\.(exe|zip)$"
Local Const $b2 = "(?i)^Perms\.txt$"
Local Const $b3 = "(?i)^GrantPerms"
Local Const $b4[1][2] = [[$ax, $b0]]
Local Const $b5[1][5] = [[$ax, 'file', $a8, $b1, False]]
Local Const $b6[1][5] = [[$ax, 'file', $a8, $b2, False]]
Local Const $b7[1][5] = [[$ax, 'folder', $a8, $b3, False]]
_vv($9o, $b4)
_vv($9p, $b5)
_vv($9p, $b6)
_vv($9p, $b7)
_vv($9r, $b5)
_vv($9r, $b6)
_vv($9r, $b7)
EndFunc
_11a()
Func _11b()
Local Const $ax = "combofix"
Dim $9p
Dim $9r
Dim $9t
Dim $a1
Dim $9u
Dim $9o
Local Const $a8 = "(?i)^Swearware"
Local Const $b0 = "(?i)^Combofix.*\.exe$"
Local Const $b1 = "(?i)^CFScript\.txt$"
Local Const $b2 = "(?i)^Qoobox$"
Local Const $b3 = "(?i)^Combofix.*\.txt$"
Local Const $bg = "(?i)^(grep|PEV|NIRCMD|MBR|SED|SWREG|SWSC|SWXCACLS|Zip)\.exe$"
Local Const $bh = "(?i)^Swearware$"
Local Const $b4[1][5] = [[$ax, 'file', $a8, $b0, False]]
Local Const $b5[1][5] = [[$ax, 'file', Null, $b1, False]]
Local Const $b6[1][5] = [[$ax, 'folder', Null, $b2, True]]
Local Const $b7[1][5] = [[$ax, 'file', Null, $b3, False]]
Local Const $bd[1][5] = [[$ax, 'file', Null, $bg, True]]
Local Const $be[1][2] = [[$ax, $bh]]
Local Const $bi[1][2] = [[$ax, $b0]]
_vv($9p, $b4)
_vv($9p, $b5)
_vv($9r, $b4)
_vv($9r, $b5)
_vv($9t, $b6)
_vv($9t, $b7)
_vv($a1, $bd)
_vv($9u, $be)
_vv($9o, $bi)
EndFunc
_11b()
Func _11c()
Local Const $ax = "regtoolexport"
Dim $9o
Dim $9p
Dim $9r
Local Const $a8 = Null
Local Const $b0 = "(?i)^regtoolexport.*\.exe$"
Local Const $b1 = "(?i)^Export.*\.reg$"
Local Const $b4[1][2] = [[$ax, $b0]]
Local Const $b5[1][5] = [[$ax, 'file', $a8, $b0, False]]
Local Const $b6[1][5] = [[$ax, 'file', $a8, $b1, False]]
_vv($9o, $b4)
_vv($9p, $b5)
_vv($9p, $b6)
_vv($9r, $b5)
_vv($9r, $b6)
EndFunc
_11c()
Func _11d()
Local Const $ax = "tdsskiller"
Dim $9o
Dim $9p
Dim $9r
Dim $9t
Local Const $a8 = "(?i)^.*Kaspersky"
Local Const $b0 = "(?i)^tdsskiller.*\.exe$"
Local Const $b1 = "(?i)^tdsskiller.*\.(exe|zip)$"
Local Const $b2 = "(?i)^TDSSKiller.*_log\.txt$"
Local Const $b3 = "(?i)^TDSSKiller"
Local Const $b4[1][2] = [[$ax, $b0]]
Local Const $b5[1][5] = [[$ax, 'file', $a8, $b1, False]]
Local Const $b6[1][5] = [[$ax, 'file', Null, $b2, False]]
Local Const $b7[1][5] = [[$ax, 'folder', Null, $b3, False]]
_vv($9o, $b4)
_vv($9p, $b5)
_vv($9p, $b7)
_vv($9r, $b5)
_vv($9r, $b7)
_vv($9t, $b6)
_vv($9t, $b7)
EndFunc
_11d()
Func _11e()
Local Const $ax = "winupdatefix"
Dim $9o
Dim $9p
Dim $9r
Dim $9t
Local Const $a8 = Null
Local Const $b0 = "(?i)^winupdatefix.*\.exe$"
Local Const $b1 = "(?i)^winupdatefix.*\.txt$"
Local Const $b4[1][2] = [[$ax, $b0]]
Local Const $b5[1][5] = [[$ax, 'file', $a8, $b0, False]]
Local Const $b6[1][5] = [[$ax, 'file', $a8, $b1, False]]
_vv($9o, $b4)
_vv($9p, $b5)
_vv($9r, $b5)
_vv($9t, $b6)
EndFunc
_11e()
Func _11f()
Local Const $ax = "rsthosts"
Dim $9o
Dim $9p
Dim $9r
Dim $9t
Local Const $a8 = Null
Local Const $b0 = "(?i)^rsthosts.*\.exe$"
Local Const $b1 = "(?i)^RstHosts.*\.txt$"
Local Const $b4[1][2] = [[$ax, $b0]]
Local Const $b5[1][5] = [[$ax, 'file', $a8, $b0, Null]]
Local Const $b6[1][5] = [[$ax, 'file', $a8, $b1, Null]]
_vv($9o, $b4)
_vv($9p, $b5)
_vv($9r, $b5)
_vv($9t, $b6)
EndFunc
_11f()
Func _11g()
Local Const $ax = "winchk"
Dim $9o
Dim $9p
Dim $9r
Dim $9t
Local Const $a8 = Null
Local Const $b0 = "(?i)^winchk.*\.exe$"
Local Const $b1 = "(?i)^WinChk.*\.txt$"
Local Const $b4[1][2] = [[$ax, $b0]]
Local Const $b5[1][5] = [[$ax, 'file', $a8, $b0, False]]
Local Const $b6[1][5] = [[$ax, 'file', $a8, $b1, False]]
_vv($9o, $b4)
_vv($9p, $b5)
_vv($9r, $b5)
_vv($9t, $b6)
EndFunc
_11g()
Func _11h()
Local Const $ax = "avenger"
Dim $9o
Dim $9p
Dim $9r
Dim $9t
Local Const $a8 = Null
Local Const $b0 = "(?i)^avenger.*\.(exe|zip)$"
Local Const $b1 = "(?i)^avenger"
Local Const $b2 = "(?i)^avenger.*\.txt$"
Local Const $b3 = "(?i)^avenger.*\.exe$"
Local Const $b4[1][2] = [[$ax, $b3]]
Local Const $b5[1][5] = [[$ax, 'file', $a8, $b0, False]]
Local Const $b6[1][5] = [[$ax, 'folder', $a8, $b1, False]]
Local Const $b7[1][5] = [[$ax, 'file', $a8, $b2, False]]
_vv($9o, $b4)
_vv($9p, $b5)
_vv($9p, $b6)
_vv($9r, $b5)
_vv($9r, $b6)
_vv($9t, $b6)
_vv($9t, $b7)
EndFunc
_11h()
Func _11i()
Local Const $ax = "blitzblank"
Dim $9o
Dim $9p
Dim $9r
Dim $9t
Dim $9q
Dim $9u
Local Const $a8 = "(?i)^Emsi"
Local Const $b0 = "(?i)^BlitzBlank.*\.exe$"
Local Const $b1 = "(?i)^BlitzBlank.*\.log$"
Local Const $b4[1][2] = [[$ax, $b0]]
Local Const $b5[1][5] = [[$ax, 'file', $a8, $b0, False]]
Local Const $b6[1][5] = [[$ax, 'file', Null, $b1, False]]
_vv($9o, $b4)
_vv($9p, $b5)
_vv($9r, $b5)
_vv($9t, $b6)
EndFunc
_11i()
Func _11j()
Local Const $ax = "zoek"
Dim $9o
Dim $9p
Dim $9r
Dim $9t
Dim $9q
Dim $9u
Local Const $a8 = Null
Local Const $b0 = "(?i)^zoek.*\.exe$"
Local Const $b1 = "(?i)^zoek.*\.log$"
Local Const $b2 = "(?i)^zoek"
Local Const $b3 = "(?i)^runcheck.*\.txt$"
Local Const $b4[1][2] = [[$ax, $b0]]
Local Const $b5[1][5] = [[$ax, 'file', $a8, $b0, False]]
Local Const $b6[1][5] = [[$ax, 'file', $a8, $b1, False]]
Local Const $b7[1][5] = [[$ax, 'folder', $a8, $b2, True]]
Local Const $bd[1][5] = [[$ax, 'file', $a8, $b3, False]]
_vv($9o, $b4)
_vv($9p, $b5)
_vv($9r, $b5)
_vv($9t, $b6)
_vv($9t, $b7)
_vv($9t, $bd)
EndFunc
_11j()
Func _11k()
Local Const $ax = "remediate-vbs-worm"
Dim $9o
Dim $9p
Dim $9r
Dim $9t
Dim $9q
Dim $9u
Local Const $a8 = "(?i).*VBS autorun worms.*"
Local Const $bb = Null
Local Const $b0 = "(?i)^remediate.?vbs.?worm.*\.exe$"
Local Const $b1 = "(?i)^Rem-VBS.*\.log$"
Local Const $b2 = "(?i)^Rem-VBS"
Local Const $b3 = "(?i)^Rem-VBSworm.*\.exe$"
Local Const $b4[1][2] = [[$ax, $b0]]
Local Const $b5[1][5] = [[$ax, 'file', $bb, $b0, False]]
Local Const $b6[1][5] = [[$ax, 'file', $bb, $b1, False]]
Local Const $b7[1][5] = [[$ax, 'folder', $a8, $b2, True]]
Local Const $bd[1][2] = [[$ax, $b3]]
Local Const $be[1][5] = [[$ax, 'file', $bb, $b3, False]]
_vv($9o, $b4)
_vv($9o, $bd)
_vv($9p, $b5)
_vv($9p, $be)
_vv($9r, $b5)
_vv($9r, $be)
_vv($9t, $b6)
_vv($9t, $b7)
EndFunc
_11k()
Func _11l()
Local Const $ax = "ckscanner"
Dim $9o
Dim $9p
Dim $9r
Local Const $a8 = Null
Local Const $b0 = "(?i)^CKScanner.*\.exe$"
Local Const $b1 = "(?i)^CKfiles.*\.txt$"
Local Const $b4[1][2] = [[$ax, $b0]]
Local Const $b5[1][5] = [[$ax, 'file', $a8, $b0, False]]
Local Const $b6[1][5] = [[$ax, 'file', $a8, $b1, False]]
_vv($9o, $b4)
_vv($9p, $b5)
_vv($9r, $b5)
_vv($9p, $b6)
_vv($9r, $b6)
EndFunc
_11l()
Func _11m()
Local Const $ax = "quickdiag"
Dim $9o
Dim $9p
Dim $9r
Dim $9t
Dim $9u
Local Const $a8 = "(?i)^SosVirus"
Local Const $b0 = "(?i)^QuickDiag.*\.exe$"
Local Const $b1 = "(?i)^QuickDiag.*\.(exe|txt)$"
Local Const $b2 = "(?i)^QuickScript.*\.txt$"
Local Const $b3 = "(?i)^QuickDiag.*\.txt$"
Local Const $bg = "(?i)^QuickDiag"
Local Const $bh = "(?i)^g3n-h@ckm@n$"
Local Const $b4[1][2] = [[$ax, $b0]]
Local Const $b5[1][5] = [[$ax, 'file', $a8, $b1, True]]
Local Const $b6[1][5] = [[$ax, 'file', Null, $b2, True]]
Local Const $b7[1][5] = [[$ax, 'file', Null, $b3, True]]
Local Const $bd[1][5] = [[$ax, 'folder', Null, $bg, True]]
Local Const $be[1][2] = [[$ax, $bh]]
_vv($9o, $b4)
_vv($9p, $b5)
_vv($9r, $b5)
_vv($9p, $b6)
_vv($9r, $b6)
_vv($9t, $b7)
_vv($9t, $bd)
_vv($9u, $be)
EndFunc
_11m()
Func _11n()
Local Const $ax = "adlicediag"
Dim $9o
Dim $9w
Dim $9s
Dim $9x
Dim $9p
Dim $9r
Dim $9q
Dim $a0
Local $5h = ""
If @OSArch = "X64" Then $5h = "64"
Local Const $bj = "(?i)^Adlice Diag"
Local Const $b0 = "(?i)^Diag version"
Local Const $b1 = "(?i)^Diag$"
Local Const $b2 = "(?i)^ADiag$"
Local Const $b3 = "(?i)^Diag_portable(32|64)\.exe$"
Local Const $bg = "(?i)^Diag\.lnk$"
Local Const $bh = "(?i)^Diag_setup\.exe$"
Local Const $bk = "(?i)^Diag(32|64)?\.exe$"
Local Const $b4[1][2] = [[$ax, $bj]]
Local Const $b5[1][4] = [[$ax, "HKLM" & $5h & "\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall", $b0, "DisplayName"]]
Local Const $b6[1][5] = [[$ax, 'folder', Null, $b1, True]]
Local Const $b7[1][5] = [[$ax, 'folder', Null, $b2, True]]
Local Const $bd[1][5] = [[$ax, 'file', Null, $b3, False]]
Local Const $be[1][5] = [[$ax, 'file', Null, $bg, False]]
Local Const $bi[1][5] = [[$ax, 'file', Null, $bh, False]]
Local Const $bl[1][2] = [[$ax, $bk]]
_vv($9o, $b4)
_vv($9o, $bl)
_vv($9w, $b5)
_vv($9s, $b6)
_vv($9x, $b7)
_vv($9p, $bd)
_vv($9p, $be)
_vv($9p, $bi)
_vv($9r, $bd)
_vv($9r, $bi)
_vv($9q, $be)
_vv($a0, $b6)
EndFunc
_11n()
Func _11o()
Local Const $b9 = Null
Local Const $ax = "rstassociations"
Dim $9o
Dim $9p
Dim $9r
Dim $9t
Local Const $b0 = "(?i)^rstassociations.*\.(exe|scr)$"
Local Const $b1 = "(?i)^RstAssociations.*\.txt$"
Local Const $b4[1][2] = [[$ax, $b0]]
Local Const $b5[1][5] = [[$ax, 'file', $b9, $b0, False]]
Local Const $b6[1][5] = [[$ax, 'file', $b9, $b1, False]]
_vv($9o, $b4)
_vv($9p, $b5)
_vv($9r, $b5)
_vv($9t, $b6)
EndFunc
_11o()
Func _11p()
Local Const $b9 = Null
Local Const $ax = "sft"
Dim $9o
Dim $9p
Dim $9r
Local Const $b0 = "(?i)^SFT.*\.exe$"
Local Const $b1 = "(?i)^SFT.*\.(txt|exe|zip)$"
Local Const $b4[1][2] = [[$ax, $b0]]
Local Const $b5[1][5] = [[$ax, 'file', $b9, $b1, False]]
_vv($9o, $b4)
_vv($9p, $b5)
_vv($9r, $b5)
EndFunc
_11p()
Func _11q()
Local $5h = ""
If @OSArch = "X64" Then $5h = "64"
If FileExists(@AppDataCommonDir & "\Malwarebytes\Malwarebytes' Anti-Malware\Quarantine") Then
Local $bm = _x1(@AppDataCommonDir & "\Malwarebytes\Malwarebytes' Anti-Malware\Quarantine")
If @error = 0 Then
For $43 = 1 To $bm[0]
_10e(@AppDataCommonDir & "\Malwarebytes\Malwarebytes' Anti-Malware\Quarantine" & '\' & $bm[$43], "mbar", Null, True)
Next
EndIf
EndIf
_10i("HKLM" & $5h & "\SOFTWARE\Microsoft\Windows\CurrentVersion\App Paths\combofix.exe", "combofix")
_10i("HKLM" & $5h & "\SYSTEM\CurrentControlSet\Enum\Root\LEGACY_ASWMBR", "aswmbr", True)
EndFunc
Func _11r($94 = False)
If $94 = True Then
_zj(@CRLF & "- Search Tools -" & @CRLF)
EndIf
_10k($9o)
_102()
_10m($a2)
_102()
_10l($9v)
_102()
_10h(@DesktopDir, $9p)
_102()
_10h(@DesktopCommonDir, $9q)
_102()
If FileExists(@UserProfileDir & "\Downloads") Then
_10h(@UserProfileDir & "\Downloads", $9r)
_102()
Else
_102()
EndIf
_10n($9s)
_102()
_10h(@HomeDrive, $9t)
_102()
_10h(@AppDataDir, $9y)
_102()
_10h(@AppDataCommonDir, $9x)
_102()
_10h(@LocalAppDataDir, $9z)
_102()
_10h(@WindowsDir, $a1)
_102()
_10o($9u)
_102()
_10p($9w)
_102()
_10h(@AppDataCommonDir & "\Microsoft\Windows\Start Menu\Programs", $a0)
_102()
_11q()
_102()
If $94 = True Then
Local $bn = False
Local Const $bo[4] = ["process", "uninstall", "element", "key"]
For $bp In $8h
Local $bq = $8h.Item($bp)
Local $br = False
For $bs = 0 To UBound($bo) - 1
Local $bt = $bo[$bs]
Local $bu = $bq.Item($bt)
Local $bv = $bu.Keys
If UBound($bv) > 0 Then
If $br = False Then
$br = True
$bn = True
_zj(@CRLF & "  ## " & StringUpper($bp) & " found")
EndIf
For $bw = 0 To UBound($bv) - 1
Local $bx = $bv[$bw]
Local $by = $bu.Item($bx)
_101($bt, $bx, $by)
Next
EndIf
Next
Next
If $bn = False Then
_zj("  [I] No tools found")
EndIf
EndIf
_102()
EndFunc
FileInstall("C:\Users\IEUser\Desktop\kpRemover\src\assets\bug.gif", @TempDir & "\kprm-logo.gif")
Global $9a = "KpRm"
Global $a5 = False
Global $7w = "kprm-" & @YEAR & @MON & @MDAY & @HOUR & @MIN & ".txt"
Local Const $bz = GUICreate($9a, 500, 195, 202, 112)
Local Const $c0 = GUICtrlCreateGroup("Actions", 8, 8, 400, 153)
Local Const $c1 = GUICtrlCreateCheckbox($50, 16, 40, 129, 17)
Local Const $c2 = GUICtrlCreateCheckbox($51, 16, 80, 190, 17)
Local Const $c3 = GUICtrlCreateCheckbox($52, 16, 120, 190, 17)
Local Const $c4 = GUICtrlCreateCheckbox($53, 220, 40, 137, 17)
Local Const $c5 = GUICtrlCreateCheckbox($54, 220, 80, 137, 17)
Local Const $c6 = GUICtrlCreateCheckbox($55, 220, 120, 180, 17)
Global $8w = GUICtrlCreateProgress(8, 170, 480, 17)
GUICtrlCreateGroup("", -99, -99, 1, 1)
GUICtrlSetState($c1, 1)
Local Const $c7 = GUICtrlCreatePic(@TempDir & "\kprm-logo.gif", 415, 16, 76, 76)
Local Const $c8 = GUICtrlCreateButton($56, 415, 120, 75, 40)
GUISetState(@SW_SHOW)
While 1
Local $c9 = GUIGetMsg()
Switch $c9
Case $0
Exit
Case $c8
_11u()
EndSwitch
WEnd
Func _11s()
Local Const $ca = @HomeDrive & "\KPRM"
If Not FileExists($ca) Then
DirCreate($ca)
EndIf
If Not FileExists($ca) Then
MsgBox(16, $58, $59)
Exit
EndIf
EndFunc
Func _11t()
_11s()
_zj("#################################################################################################################" & @CRLF)
_zj("# Run at " & _3o())
_zj("# KpRm version " & $4y)
_zj("# Run by " & @UserName & " from " & @WorkingDir)
_zj("# Computer Name: " & @ComputerName)
_zj("# OS: " & _zt() & " " & @OSArch & " (" & @OSBuild & ") " & @OSServicePack)
_103()
EndFunc
Func _11u()
_11t()
_102()
If GUICtrlRead($c4) = $1 Then
_10a()
EndIf
_102()
If GUICtrlRead($c1) = $1 Then
_11r()
_11r(True)
Else
_102(32)
EndIf
_102()
If GUICtrlRead($c6) = $1 Then
_10c()
EndIf
_102()
If GUICtrlRead($c5) = $1 Then
_10b()
EndIf
_102()
If GUICtrlRead($c2) = $1 Then
_104()
EndIf
_102()
If GUICtrlRead($c3) = $1 Then
_109()
EndIf
GUICtrlSetData($8w, 100)
MsgBox(64, "OK", $57)
_zi(True)
EndFunc
