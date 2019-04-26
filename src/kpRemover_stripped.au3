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
Local Const $4x[6] = ["040C", "080C", "0C0C", "100C", "140C", "180C"]
If _we($4x, @MUILang) <> 1 Then
Global $4y = "Supprimer des outils"
Global $4z = "Supprimer les points de restaurations"
Global $50 = "Créer un point de restauration"
Global $51 = "Sauvegarder le registre"
Global $52 = "Restaurer UAC"
Global $53 = "Restaurer les paramètres système"
Global $54 = "Exécuter"
Global $55 = "Toutes les opérations sont terminées"
Global $56 = "Echec"
Global $57 = "Impossible de créer une sauvegarde du registre"
Global $58 = "Vous devez exécuter le programme avec les droits administrateurs"
Global $59 = "Vous devez fermer MalwareBytes Anti-Rootkit avant de continuer"
Else
Global $4y = "Delete Tools"
Global $4z = "Delete Restore Points"
Global $50 = "Create Restore Point"
Global $51 = "Registry Backup"
Global $52 = "UAC Restore"
Global $53 = "Restore System Settings"
Global $54 = "Run"
Global $55 = "All operations are completed"
Global $56 = "Fail"
Global $57 = "Unable to create a registry backup"
Global $58 = "You must run the program with administrator rights"
Global $59 = "You must close MalwareBytes Anti-Rootkit before continuing"
EndIf
Global Const $5a = 1
Global Const $5b = 5
Global Const $5c = 0
Global Const $5d = 1
Func _xr($5e = $5b)
If Not IsAdmin() Then Return SetError(-3, 0, -1)
If StringRegExp(@OSVersion, "_(XP|200(0|3))") Then Return SetError(-4, 0, -1)
Local $5f = ""
If @OSArch = "X64" Then $5f = "64"
If $5e < 0 Or $5e > 5 Then Return SetError(-5, 0, -1)
Local $2m = RegWrite("HKEY_LOCAL_MACHINE" & $5f & "\Software\Microsoft\Windows\CurrentVersion\Policies\System", "ConsentPromptBehaviorAdmin", "REG_DWORD", $5e)
If $2m = 0 Then $2m = -1
Return SetError(@error, 0, $2m)
EndFunc
Func _xs($5e = $5a)
If Not IsAdmin() Then Return SetError(-3, 0, -1)
If StringRegExp(@OSVersion, "_(XP|200(0|3))") Then Return SetError(-4, 0, -1)
If $5e < 0 Or $5e = 2 Or $5e > 3 Then Return SetError(-5, 0, -1)
Local $5f = ""
If @OSArch = "X64" Then $5f = "64"
Local $2m = RegWrite("HKEY_LOCAL_MACHINE" & $5f & "\Software\Microsoft\Windows\CurrentVersion\Policies\System", "ConsentPromptBehaviorUser", "REG_DWORD", $5e)
If $2m = 0 Then $2m = -1
Return SetError(@error, 0, $2m)
EndFunc
Func _xt($5e = $5c)
If Not IsAdmin() Then Return SetError(-3, 0, -1)
If StringRegExp(@OSVersion, "_(XP|200(0|3))") Then Return SetError(-4, 0, -1)
If $5e < 0 Or $5e > 1 Then Return SetError(-5, 0, -1)
Local $5f = ""
If @OSArch = "X64" Then $5f = "64"
Local $2m = RegWrite("HKEY_LOCAL_MACHINE" & $5f & "\Software\Microsoft\Windows\CurrentVersion\Policies\System", "EnableInstallerDetection", "REG_DWORD", $5e)
If $2m = 0 Then $2m = -1
Return SetError(@error, 0, $2m)
EndFunc
Func _xu($5e = $5d)
If Not IsAdmin() Then Return SetError(-3, 0, -1)
If StringRegExp(@OSVersion, "_(XP|200(0|3))") Then Return SetError(-4, 0, -1)
If $5e < 0 Or $5e > 1 Then Return SetError(-5, 0, -1)
Local $5f = ""
If @OSArch = "X64" Then $5f = "64"
Local $2m = RegWrite("HKEY_LOCAL_MACHINE" & $5f & "\Software\Microsoft\Windows\CurrentVersion\Policies\System", "EnableLUA", "REG_DWORD", $5e)
If $2m = 0 Then $2m = -1
Return SetError(@error, 0, $2m)
EndFunc
Func _xv($5e = $5d)
If Not IsAdmin() Then Return SetError(-3, 0, -1)
If StringRegExp(@OSVersion, "_(XP|200(0|3))") Then Return SetError(-4, 0, -1)
If $5e < 0 Or $5e > 1 Then Return SetError(-5, 0, -1)
Local $5f = ""
If @OSArch = "X64" Then $5f = "64"
Local $2m = RegWrite("HKEY_LOCAL_MACHINE" & $5f & "\Software\Microsoft\Windows\CurrentVersion\Policies\System", "EnableSecureUIAPaths", "REG_DWORD", $5e)
If $2m = 0 Then $2m = -1
Return SetError(@error, 0, $2m)
EndFunc
Func _xw($5e = $5c)
If Not IsAdmin() Then Return SetError(-3, 0, -1)
If StringRegExp(@OSVersion, "_(XP|200(0|3))") Then Return SetError(-4, 0, -1)
If $5e < 0 Or $5e > 1 Then Return SetError(-5, 0, -1)
Local $5f = ""
If @OSArch = "X64" Then $5f = "64"
Local $2m = RegWrite("HKEY_LOCAL_MACHINE" & $5f & "\Software\Microsoft\Windows\CurrentVersion\Policies\System", "EnableUIADesktopToggle", "REG_DWORD", $5e)
If $2m = 0 Then $2m = -1
Return SetError(@error, 0, $2m)
EndFunc
Func _xx($5e = $5d)
If Not IsAdmin() Then Return SetError(-3, 0, -1)
If StringRegExp(@OSVersion, "_(XP|200(0|3))") Then Return SetError(-4, 0, -1)
If $5e < 0 Or $5e > 1 Then Return SetError(-5, 0, -1)
Local $5f = ""
If @OSArch = "X64" Then $5f = "64"
Local $2m = RegWrite("HKEY_LOCAL_MACHINE" & $5f & "\Software\Microsoft\Windows\CurrentVersion\Policies\System", "EnableVirtualization", "REG_DWORD", $5e)
If $2m = 0 Then $2m = -1
Return SetError(@error, 0, $2m)
EndFunc
Func _xy($5e = $5c)
If Not IsAdmin() Then Return SetError(-3, 0, -1)
If StringRegExp(@OSVersion, "_(XP|200(0|3))") Then Return SetError(-4, 0, -1)
If $5e < 0 Or $5e > 1 Then Return SetError(-5, 0, -1)
Local $5f = ""
If @OSArch = "X64" Then $5f = "64"
Local $2m = RegWrite("HKEY_LOCAL_MACHINE" & $5f & "\Software\Microsoft\Windows\CurrentVersion\Policies\System", "FilterAdministratorToken", "REG_DWORD", $5e)
If $2m = 0 Then $2m = -1
Return SetError(@error, 0, $2m)
EndFunc
Func _xz($5e = $5d)
If Not IsAdmin() Then Return SetError(-3, 0, -1)
If StringRegExp(@OSVersion, "_(XP|200(0|3))") Then Return SetError(-4, 0, -1)
If $5e < 0 Or $5e > 1 Then Return SetError(-5, 0, -1)
Local $5f = ""
If @OSArch = "X64" Then $5f = "64"
Local $2m = RegWrite("HKEY_LOCAL_MACHINE" & $5f & "\Software\Microsoft\Windows\CurrentVersion\Policies\System", "PromptOnSecureDesktop", "REG_DWORD", $5e)
If $2m = 0 Then $2m = -1
Return SetError(@error, 0, $2m)
EndFunc
Func _y0($5e = $5c)
If Not IsAdmin() Then Return SetError(-3, 0, -1)
If StringRegExp(@OSVersion, "_(XP|200(0|3))") Then Return SetError(-4, 0, -1)
If $5e < 0 Or $5e > 1 Then Return SetError(-5, 0, -1)
Local $5f = ""
If @OSArch = "X64" Then $5f = "64"
Local $2m = RegWrite("HKEY_LOCAL_MACHINE" & $5f & "\Software\Microsoft\Windows\CurrentVersion\Policies\System", "ValidateAdminCodeSignatures", "REG_DWORD", $5e)
If $2m = 0 Then $2m = -1
Return SetError(@error, 0, $2m)
EndFunc
Global $5g = Null, $5h = Null
Global $5i = EnvGet('SystemDrive') & '\'
Func _y2()
Local $5j[1][3], $5k = 0
$5j[0][0] = $5k
If Not IsObj($5h) Then $5h = ObjGet("winmgmts:root/default")
If Not IsObj($5h) Then Return $5j
Local $5l = $5h.InstancesOf("SystemRestore")
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
Local $w = DllCall('SrClient.dll', 'DWORD', 'SRRemoveRestorePoint', 'DWORD', $5o)
If @error Then Return SetError(1, 0, 0)
If $w[0] = 0 Then Return 1
Return SetError(1, 0, 0)
EndFunc
Func _y6($5p = $5i)
If Not IsObj($5g) Then $5g = ObjGet("winmgmts:{impersonationLevel=impersonate}!root/default:SystemRestore")
If Not IsObj($5g) Then Return 0
If $5g.Enable($5p) = 0 Then Return 1
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
$6d[0][2] = $m
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
For $43 = 1 To $6m - 1
$6t &= ';DWORD;DWORD;DWORD;ptr;DWORD;DWORD;DWORD;ptr'
Next
$6s = DllStructCreate($6t)
For $43 = 0 To $6m -1
If Not IsDllStruct($6e[$43][0]) Then $6e[$43][0] = _za($6e[$43][0])
$6n[$43] = DllStructGetPtr($6e[$43][0])
If Not _zg($6n[$43]) Then ContinueLoop
DllStructSetData($6s,$6o+1,$6e[$43][2])
If $6e[$43][1] = 0 Then
$6i = 1
$6q = $8
Else
$6q = $7
EndIf
If $6l > 3 Then $6g = $6e[$43][3]
DllStructSetData($6s,$6o+2,$6q)
DllStructSetData($6s,$6o+3,$6g)
DllStructSetData($6s,$6o+6,0)
$6r = DllCall($64,'BOOL','LookupAccountSid','ptr',0,'ptr',$6n[$43],'ptr*',0,'dword*',32,'ptr*',0,'dword*',32,'dword*',0)
If Not @error Then $6p = $6r[7]
DllStructSetData($6s,$6o+7,$6p)
DllStructSetData($6s,$6o+8,$6n[$43])
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
Local $6y, $43 = 0, $6z
If Not $6i Then
If $6f Then _yx($69,$5u)
$6y = _yo($69, $5u, $6j, $6k, 0, $6h,0)
EndIf
If $6c Then
While 1
$43 += 1
$6z = RegEnumKey($69,$43)
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
Local $71 = DllStructCreate('byte[32]'), $w
Local $6h = DllStructGetPtr($71,1)
DllCall($64,'bool','InitializeAcl','Ptr',$6h,'dword',DllStructGetSize($71),'dword',$63)
If IsPtr($69) Then
$w = DllCall($64,"dword","SetSecurityInfo",'handle',$69,'dword',$6a,'dword',4,'ptr',0,'ptr',0,'ptr',$6h,'ptr',0)
Else
If $6a = $5u Then $69 = _zb($69)
DllCall($64,'DWORD','SetNamedSecurityInfo','str',$69,'dword',$6a,'DWORD',4,'ptr',0,'ptr',0,'ptr',0,'ptr',0)
$w = DllCall($64,'DWORD','SetNamedSecurityInfo','str',$69,'dword',$6a,'DWORD',4,'ptr',0,'ptr',0,'ptr',$6h,'ptr',0)
EndIf
If @error Then Return SetError(@error,0,0)
Return SetError($w[0],0,Number($w[0] = 0))
EndFunc
Func _z0($69, $6a = $5r, $72 = 'Administrators')
If $68 = 0 Then _y9()
Local $73 = _za($72), $w
Local $6n = DllStructGetPtr($73)
If IsPtr($69) Then
$w = DllCall($64,"dword","SetSecurityInfo",'handle',$69,'dword',$6a,'dword',1,'ptr',$6n,'ptr',0,'ptr',0,'ptr',0)
Else
If $6a = $5u Then $69 = _zb($69)
$w = DllCall($64,'DWORD','SetNamedSecurityInfo','str',$69,'dword',$6a,'DWORD',1,'ptr',$6n,'ptr',0,'ptr',0,'ptr',0)
EndIf
If @error Then Return SetError(@error,0,False)
Return SetError($w[0],0,Number($w[0] = 0))
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
Local $2q = DllCall($64, "bool", "LookupAccountNameW", "wstr", $76, "wstr", $75, "ptr", $6n, "dword*", 256, "wstr", "", "dword*", 256, "int*", 0)
If @error Then Return SetError(@error, @extended, 0)
If Not $2q[0] Then Return 0
Return _zf($6n)
EndFunc
Func _zd($78)
Local $2q = DllCall($64, "bool", "ConvertStringSidToSidW", "wstr", $78, "ptr*", 0)
If @error Then Return SetError(@error, @extended, 0)
If Not $2q[0] Then Return 0
Local $79 = _ze($2q[2])
Local $3h = DllStructCreate("byte Data[" & $79 & "]", $2q[2])
Local $7a = DllStructCreate("byte Data[" & $79 & "]")
DllStructSetData($7a, "Data", DllStructGetData($3h, "Data"))
DllCall($65, "ptr", "LocalFree", "ptr", $2q[2])
Return $7a
EndFunc
Func _ze($6n)
If Not _zg($6n) Then Return SetError(-1, 0, "")
Local $2q = DllCall($64, "dword", "GetLengthSid", "ptr", $6n)
If @error Then Return SetError(@error, @extended, 0)
Return $2q[0]
EndFunc
Func _zf($6n)
If Not _zg($6n) Then Return SetError(-1, 0, "")
Local $2q = DllCall($64, "int", "ConvertSidToStringSidW", "ptr", $6n, "ptr*", 0)
If @error Then Return SetError(@error, @extended, "")
If Not $2q[0] Then Return ""
Local $3h = DllStructCreate("wchar Text[256]", $2q[2])
Local $78 = DllStructGetData($3h, "Text")
DllCall($65, "ptr", "LocalFree", "ptr", $2q[2])
Return $78
EndFunc
Func _zg($6n)
Local $2q = DllCall($64, "bool", "IsValidSid", "ptr", $6n)
If @error Then Return SetError(@error, @extended, False)
Return $2q[0]
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
For $43 = 0 To $7h - 1
DllCall($64, "int", "LookupPrivilegeValue", "str", "", "str", $7b[$43][0], "ptr", DllStructGetPtr($7l) )
DLLStructSetData( $7i, 3 * $43 + 2, DllStructGetData($7l, 1) )
DLLStructSetData( $7i, 3 * $43 + 3, DllStructGetData($7l, 2) )
DLLStructSetData( $7i, 3 * $43 + 4, $7b[$43][1] )
Next
$7m = DllCall($65, "hwnd", "GetCurrentProcess")
$7n = DllCall($64, "int", "OpenProcessToken", "hwnd", $7m[0], "dword", BitOR(0x00000020, 0x00000008), "hwnd*", 0 )
DllCall( $64, "int", "AdjustTokenPrivileges", "hwnd", $7n[3], "int", False, "ptr", DllStructGetPtr($7i), "dword", DllStructGetSize($7i), "ptr", $7k, "dword*", 0 )
$7o = DllCall($65, "dword", "GetLastError")
DllCall($65, "int", "CloseHandle", "hwnd", $7n[3])
Local $7p = DllStructGetData($7j, 1)
If $7p > 0 Then
Local $7q, $7r, $7s, $7d[$7p][2]
For $43 = 0 To $7p - 1
$7q = $7k + 12 * $43 + 4
$7r = DllCall($64, "int", "LookupPrivilegeName", "str", "", "ptr", $7q, "ptr", 0, "dword*", 0 )
$7s = DllStructCreate("char[" & $7r[4] & "]")
DllCall($64, "int", "LookupPrivilegeName", "str", "", "ptr", $7q, "ptr", DllStructGetPtr($7s), "dword*", DllStructGetSize($7s) )
$7d[$43][0] = DllStructGetData($7s, 1)
$7d[$43][1] = DllStructGetData($7j, 3 * $43 + 4)
Next
EndIf
Return SetError($7o[0], 0, $7d)
EndFunc
Func _zi()
FileDelete(@TempDir & "\kprm-logo.gif")
Exit
EndFunc
If Not IsAdmin() Then
MsgBox(16, $56, $58)
_zi()
EndIf
Local $7t = ProcessList("mbar.exe")
If $7t[0][0] > 0 Then
MsgBox(16, $56, $59)
_zi()
EndIf
Func _zj($7u)
Dim $7v
FileWrite(@DesktopDir & "\" & $7v, $7u & @CRLF)
FileWrite(@HomeDrive & "\KPRM" & "\" & $7v, $7u & @CRLF)
EndFunc
Func _zk()
Local $7w = 100, $7x = 100, $7y = 0, $7z = @WindowsDir & "\Explorer.exe"
_hf($2z, 0, 0, 0)
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
Func _zn($81, $82, $83)
Local $43 = 0
While True
$43 += 1
Local $84 = RegEnumKey($81, $43)
If @error <> 0 Then ExitLoop
Local $85 = $81 & "\" & $84
Local $6z = RegRead($85, $83)
If StringRegExp($6z, $82) Then
Return $85
EndIf
WEnd
Return Null
EndFunc
Func _zp()
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
Func _zq($4l)
Return Int(FileExists($4l) And StringInStr(FileGetAttrib($4l), 'D', Default, 1) = 0)
EndFunc
Func _zr($4l)
Return Int(FileExists($4l) And StringInStr(FileGetAttrib($4l), 'D', Default, 1) > 0)
EndFunc
Func _zs($4l)
Local $87 = Null
If FileExists($4l) Then
Local $88 = StringInStr(FileGetAttrib($4l), 'D', Default, 1)
If $88 = 0 Then
$87 = 'file'
ElseIf $88 > 0 Then
$87 = 'folder'
EndIf
EndIf
Return $87
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
Func _zu($83)
If StringRegExp($83, "^(HKLM|HKCU|HKU|HKCR|HKCC)64") Then
Local $89 = StringReplace($83, "64", "", 1)
Return $89
EndIf
Return $83
EndFunc
Func _zv($8a, $83)
If $8a.Exists($83) Then
Local $88 = $8a.Item($83) + 1
$8a.Item($83) = $88
Else
$8a.add($83, 1)
EndIf
Return $8a
EndFunc
Func _zw($8b, $8c, $8d)
Dim $8e
Local $8f = $8e.Item($8b)
Local $8g = _zv($8f.Item($8c), $8d)
$8f.Item($8c) = $8g
$8e.Item($8b) = $8f
EndFunc
Func _zx($8h, $8i)
If $8h = Null Or $8h = "" Then Return
Local $8j = ProcessExists($8h)
If $8j <> 0 Then
_zj("     [!] Process " & $8h & " exists, it is possible that the deletion is not complete (" & $8i & ")")
EndIf
EndFunc
Func _zy($8k, $8i)
If $8k = Null Or $8k = "" Then Return
Local $8l = "[X]"
RegEnumVal($8k, "1")
If @error >= 0 Then
$8l = "[OK]"
EndIf
_zj("     " & $8l & " " & _zu($8k) & " deleted (" & $8i & ")")
EndFunc
Func _0zz($8k, $8i)
If $8k = Null Or $8k = "" Then Return
Local $4u = "", $4v = "", $4r = "", $4w = ""
Local $8m = _xe($8k, $4u, $4v, $4r, $4w)
If $4w = ".exe" Then
Local $8n = $8m[1] & $8m[2]
Local $8l = "[OK]"
If FileExists($8n) Then
$8l = "[X]"
EndIf
_zj("     " & $8l & " Uninstaller run correctly (" & $8i & ")")
EndIf
EndFunc
Func _100($8k, $8i)
If $8k = Null Or $8k = "" Then Return
Local $8l = "[OK]"
If FileExists($8k) Then
$8l = "[X]"
EndIf
_zj("     " & $8l & " " & $8k & " deleted (" & $8i & ")")
EndFunc
Func _101($8o, $8k, $8i)
Switch $8o
Case "process"
_zx($8k, $8i)
Case "key"
_zy($8k, $8i)
Case "uninstall"
_0zz($8k, $8i)
Case "element"
_100($8k, $8i)
Case Else
_zj("     [?] Unknown type " & $8o)
EndSwitch
EndFunc
Local $8p = 39
Local $8q
Local Const $8r = Floor(100 / $8p)
Func _102($8s = 1)
$8q += $8s
Dim $8t
GUICtrlSetData($8t, $8q * $8r)
If $8q = $8p Then
GUICtrlSetData($8t, 100)
EndIf
EndFunc
Func _103()
$8q = 0
Dim $8t
GUICtrlSetData($8t, 0)
EndFunc
Func _104()
_zj(@CRLF & "- Clear All System Restore Points -" & @CRLF)
Local Const $8u = _y2()
Local $6y = 0
If $8u[0][0] = 0 Then
_zj("  [I] No system recovery points were found")
Return Null
EndIf
Local $8v[1][3] = [[Null, Null, Null]]
For $43 = 1 To $8u[0][0]
Local $8j = _y4($8u[$43][0])
$6y += $8j
If $8j = 1 Then
_zj("    => [OK] RP named " & $8u[$43][1] & " created at " & $8u[$43][2] & " deleted")
Else
Local $8w[1][3] = [[$8u[$43][0], $8u[$43][1], $8u[$43][2]]]
_vv($8v, $8w)
EndIf
Next
If 1 < UBound($8v) Then
Sleep(3000)
For $43 = 1 To UBound($8v) - 1
Local $8j = _y4($8v[$43][0])
$6y += $8j
If $8j = 1 Then
_zj("    => [OK] RP named " & $8v[$43][1] & " created at " & $8u[$43][2] & " deleted")
Else
_zj("    => [X] RP named " & $8v[$43][1] & " created at " & $8u[$43][2] & " deleted")
EndIf
Next
EndIf
If $8u[0][0] = $6y Then
_zj(@CRLF & "  [OK] All system restore points have been successfully deleted")
Else
_zj(@CRLF & "  [X] Failure when deleting all restore points")
EndIf
EndFunc
Func _105($5n)
Local $8x = StringLeft($5n, 4)
Local $8y = StringMid($5n, 6, 2)
Local $8z = StringMid($5n, 9, 2)
Local $90 = StringRight($5n, 8)
Return $8y & "/" & $8z & "/" & $8x & " " & $90
EndFunc
Func _106($91 = False)
Local Const $8u = _y2()
If $8u[0][0] = 0 Then
Return Null
EndIf
Local Const $92 = _105(_31('n', -1470, _3p()))
Local $93 = False
Local $94 = False
Local $95 = False
For $43 = 1 To $8u[0][0]
Local $96 = $8u[$43][2]
If $96 > $92 Then
If $95 = False Then
$95 = True
$94 = True
_zj(@CRLF & "  [I] Recent System Restore Point Deletion before create new:" & @CRLF)
EndIf
Local $8j = _y4($8u[$43][0])
If $8j = 1 Then
_zj("    => [OK] RP named " & $8u[$43][1] & " created at " & $96 & " deleted")
ElseIf $91 = False Then
$93 = True
Else
_zj("    => [X] RP named " & $8u[$43][1] & " created at " & $96 & " deleted")
EndIf
EndIf
Next
If $93 = True Then
Sleep(3000)
_zj("  [I] Retry deleting restore point")
_106(True)
EndIf
If $94 = True Then
_zj(@CRLF)
EndIf
Sleep(3000)
EndFunc
Func _107()
Sleep(3000)
_zj(@CRLF & "- Display All System Restore Point -" & @CRLF)
Local Const $8u = _y2()
If $8u[0][0] = 0 Then
_zj("  [X] No System Restore point found")
Return
EndIf
For $43 = 1 To $8u[0][0]
_zj("    => [I] RP named " & $8u[$43][1] & " created at " & $8u[$43][2] & " found")
Next
EndFunc
Func _108()
RunWait(@ComSpec & ' /c ' & 'wmic.exe /Namespace:\\root\default Path SystemRestore Call CreateRestorePoint "KpRm", 100, 7', "", @SW_HIDE)
Return @error
EndFunc
Func _109($91 = False)
If $91 = False Then
_zj(@CRLF & "- Create New System Restore Point -" & @CRLF)
Else
_zj("  [I] Retry Create New System Restore Point")
EndIf
Dim $97
Local $98 = _y6()
If $98 = 0 Then
Sleep(3000)
$98 = _y6()
If $98 = 0 Then
_zj("  [X] Enable System Restore")
EndIf
ElseIf $98 = 1 Then
_zj("  [OK] Enable System Restore")
EndIf
_106()
Local Const $99 = _108()
If $99 <> 0 Then
_zj("  [X] System Restore Point created")
If $91 = False Then
_zj("  [I] Retry to create System Restore Point!")
_109(True)
Return
Else
_107()
Return
EndIf
ElseIf $99 = 0 Then
_zj("  [OK] System Restore Point created")
_107()
EndIf
EndFunc
Func _10a()
_zj(@CRLF & "- Create Registry Backup -" & @CRLF)
Local Const $9a = @HomeDrive & "\KPRM"
Local Const $9b = $9a & "\regedit-backup-" & @YEAR & @MON & @MDAY & @HOUR & @MIN & ".reg"
If FileExists($9b) Then
FileMove($9b, $9b & ".old")
EndIf
Local Const $8j = RunWait("Regedit /e " & $9b)
If Not FileExists($9b) Or @error <> 0 Then
_zj("  [X] Failed to create registry backup")
MsgBox(16, $56, $57)
_zi()
Else
_zj("  [OK] Registry Backup: " & $9b)
EndIf
EndFunc
Func _10b()
_zj(@CRLF & "- Restore UAC Default Value -" & @CRLF)
Local $8j = _xr()
If $8j = 1 Then
_zj("  [OK] Set ConsentPromptBehaviorAdmin with default (5) value")
Else
_zj("  [X] Set ConsentPromptBehaviorAdmin with default value")
EndIf
Local $8j = _xs()
If $8j = 1 Then
_zj("  [OK] Set ConsentPromptBehaviorUser with default (1) value")
Else
_zj("  [X] Set ConsentPromptBehaviorUser with default value")
EndIf
Local $8j = _xt()
If $8j = 1 Then
_zj("  [OK] Set EnableInstallerDetection with default (0) value")
Else
_zj("  [X] Set EnableInstallerDetection with default value")
EndIf
Local $8j = _xu()
If $8j = 1 Then
_zj("  [OK] Set EnableLUA with default (1) value")
Else
_zj("  [X] Set EnableLUA with default value")
EndIf
Local $8j = _xv()
If $8j = 1 Then
_zj("  [OK] Set EnableSecureUIAPaths with default (1) value")
Else
_zj("  [X] Set EnableSecureUIAPaths with default value")
EndIf
Local $8j = _xw()
If $8j = 1 Then
_zj("  [OK] Set EnableUIADesktopToggle with default (0) value")
Else
_zj("  [X] Set EnableUIADesktopToggle with default value")
EndIf
Local $8j = _xx()
If $8j = 1 Then
_zj("  [OK] Set EnableVirtualization with default (1) value")
Else
_zj("  [X] Set EnableVirtualization with default value")
EndIf
Local $8j = _xy()
If $8j = 1 Then
_zj("  [OK] Set FilterAdministratorToken with default (0) value")
Else
_zj("  [X] Set FilterAdministratorToken with default value")
EndIf
Local $8j = _xz()
If $8j = 1 Then
_zj("  [OK] Set PromptOnSecureDesktop with default (1) value")
Else
_zj("  [X] Set PromptOnSecureDesktop with default value")
EndIf
Local $8j = _y0()
If $8j = 1 Then
_zj("  [OK] Set ValidateAdminCodeSignatures with default (0) value")
Else
_zj("  [X] Set ValidateAdminCodeSignatures with default value")
EndIf
EndFunc
Func _10c()
_zj(@CRLF & "- Restore Default System Settings -" & @CRLF)
Local $8j = RunWait(@ComSpec & " /c " & "ipconfig /flushdns", @TempDir, @SW_HIDE)
If @error <> 0 Then
_zj("  [X] Flush DNS")
Else
_zj("  [OK] Flush DNS")
EndIf
Local Const $9c[7] = [ "netsh winsock reset", "netsh winhttp reset proxy", "netsh winhttp reset tracing", "netsh winsock reset catalog", "netsh int ip reset all", "netsh int ipv4 reset catalog", "netsh int ipv6 reset catalog" ]
$8j = 0
For $43 = 0 To UBound($9c) -1
RunWait(@ComSpec & " /c " & $9c[$43], @TempDir, @SW_HIDE)
If @error <> 0 Then
$8j += 1
EndIf
Next
If $8j = 0 Then
_zj("  [OK] Reset WinSock")
Else
_zj("  [X] Reset WinSock")
EndIf
Local $9d = "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced"
$8j = RegWrite($9d, "Hidden", "REG_DWORD", "2")
If $8j = 1 Then
_zj("  [OK] Hide Hidden file.")
Else
_zj("  [X] Hide Hidden File")
EndIf
$8j = RegWrite($9d, "HideFileExt", "REG_DWORD", "1")
If $8j = 1 Then
_zj("  [OK] Hide Extensions for known file types")
Else
_zj("  [X] Hide Extensions for known file types")
EndIf
$8j = RegWrite($9d, "ShowSuperHidden", "REG_DWORD", "0")
If $8j = 1 Then
_zj("  [OK] Hide protected operating system files")
Else
_zj("  [X] Hide protected operating system files")
EndIf
_zk()
EndFunc
Global $8e = ObjCreate("Scripting.Dictionary")
Local Const $9e[33] = [ "frst", "zhpdiag", "zhpcleaner", "zhpfix", "mbar", "roguekiller", "usbfix", "adwcleaner", "adsfix", "aswmbr", "fss", "toolsdiag", "scanrapide", "otl", "otm", "listparts", "minitoolbox", "miniregtool", "zhp", "combofix", "regtoolexport", "tdsskiller", "winupdatefix", "rsthosts", "winchk", "avenger", "blitzblank", "zoek", "remediate-vbs-worm", "ckscanner", "quickdiag", "adlicediag", "grantperms"]
For $9f = 0 To UBound($9e) - 1
Local $9g = ObjCreate("Scripting.Dictionary")
Local $9h = ObjCreate("Scripting.Dictionary")
Local $9i = ObjCreate("Scripting.Dictionary")
Local $9j = ObjCreate("Scripting.Dictionary")
Local $9k = ObjCreate("Scripting.Dictionary")
$9g.add("key", $9h)
$9g.add("element", $9i)
$9g.add("uninstall", $9j)
$9g.add("process", $9k)
$8e.add($9e[$9f], $9g)
Next
Global $9l[1][2] = [[Null, Null]]
Global $9m[1][5] = [[Null, Null, Null, Null, Null]]
Global $9n[1][5] = [[Null, Null, Null, Null, Null]]
Global $9o[1][5] = [[Null, Null, Null, Null, Null]]
Global $9p[1][5] = [[Null, Null, Null, Null, Null]]
Global $9q[1][5] = [[Null, Null, Null, Null, Null]]
Global $9r[1][2] = [[Null, Null]]
Global $9s[1][2] = [[Null, Null]]
Global $9t[1][4] = [[Null, Null, Null, Null]]
Global $9u[1][5] = [[Null, Null, Null, Null, Null]]
Global $9v[1][5] = [[Null, Null, Null, Null, Null]]
Global $9w[1][5] = [[Null, Null, Null, Null, Null]]
Global $9x[1][5] = [[Null, Null, Null, Null, Null]]
Global $9y[1][3] = [[Null, Null, Null]]
Func _10d($81, $9z = 0, $a0 = False)
Dim $a1
If $a1 Then _zj("[I] prepareRemove " & $81)
If $a0 Then
_yx($81)
_yf($81)
EndIf
Local Const $a2 = FileGetAttrib($81)
If StringInStr($a2, "R") Then
FileSetAttrib($81, "-R", $9z)
EndIf
If StringInStr($a2, "S") Then
FileSetAttrib($81, "-S", $9z)
EndIf
If StringInStr($a2, "H") Then
FileSetAttrib($81, "-H", $9z)
EndIf
If StringInStr($a2, "A") Then
FileSetAttrib($81, "-A", $9z)
EndIf
EndFunc
Func _10e($a3, $8b, $a4 = Null, $a0 = False)
Dim $a1
If $a1 Then _zj("[I] RemoveFile " & $a3)
Local Const $a5 = _zq($a3)
If $a5 Then
If $a4 And StringRegExp($a3, "(?i)\.exe$") Then
Local Const $a6 = FileGetVersion($a3, "CompanyName")
If @error Then
Return 0
ElseIf Not StringRegExp($a6, $a4) Then
Return 0
EndIf
EndIf
_zw($8b, 'element', $a3)
_10d($a3, 0, $a0)
Local $a7 = FileDelete($a3)
If $a7 Then
If $a1 Then
_zj("  [OK] File " & $a3 & " deleted successfully")
EndIf
Return 1
EndIf
Return 2
EndIf
Return 0
EndFunc
Func _10f($81, $8b, $a0 = False)
Dim $a1
If $a1 Then _zj("[I] RemoveFolder " & $81)
Local $a5 = _zr($81)
If $a5 Then
_zw($8b, 'element', $81)
_10d($81, 1, $a0)
Local Const $a7 = DirRemove($81, $l)
If $a7 Then
If $a1 Then
_zj("  [OK] Directory " & $81 & " deleted successfully")
EndIf
Return 1
EndIf
Return 2
EndIf
Return 0
EndFunc
Func _10g($81, $a3, $a8)
Dim $a1
If $a1 Then _zj("[I] FindGlob " & $81 & " " & $a3)
Local Const $a9 = $81 & "\" & $a3
Local Const $4t = FileFindFirstFile($a9)
Local $aa = []
If $4t = -1 Then
Return $aa
EndIf
Local $4r = FileFindNextFile($4t)
While @error = 0
If StringRegExp($4r, $a8) Then
_vv($aa, $81 & "\" & $4r)
EndIf
$4r = FileFindNextFile($4t)
WEnd
FileClose($4t)
Return $aa
EndFunc
Func _10h($81, $ab)
Dim $a1
If $a1 Then _zj("[I] RemoveAllFileFrom " & $81)
Local Const $a9 = $81 & "\*"
Local Const $4t = FileFindFirstFile($a9)
If $4t = -1 Then
Return Null
EndIf
Local $4r = FileFindNextFile($4t)
While @error = 0
For $ac = 1 To UBound($ab) - 1
Local $ad = $81 & "\" & $4r
Local $ae = _zs($ad)
If $ae And $ab[$ac][3] And $ae = $ab[$ac][1] And StringRegExp($4r, $ab[$ac][3]) Then
Local $8j = 0
Local $a0 = False
If $ab[$ac][4] = True Then
$a0 = True
EndIf
If $ae = 'file' Then
$8j = _10e($ad, $ab[$ac][0], $ab[$ac][2], $a0)
ElseIf $ae = 'folder' Then
$8j = _10f($ad, $ab[$ac][0], $a0)
EndIf
EndIf
Next
$4r = FileFindNextFile($4t)
WEnd
FileClose($4t)
EndFunc
Func _10i($83, $8b)
Dim $a1
If $a1 Then _zj("[I] RemoveRegistryKey " & $83)
Local Const $8j = RegDelete($83)
If $8j <> 0 Then
_zw($8b, "key", $83)
If $a1 Then
If $8j = 1 Then
_zj("  [OK] " & $83 & " deleted successfully")
ElseIf $8j = 2 Then
_zj("  [X] " & $83 & " deleted failed")
EndIf
EndIf
EndIf
Return $8j
EndFunc
Func _10j($8h)
Local $af = 50
Dim $a1
If $a1 Then _zj("[I] CloseProcessAndWait " & $8h)
If 0 = ProcessExists($8h) Then Return 0
ProcessClose($8h)
Do
$af -= 1
Sleep(250)
Until($af = 0 Or 0 = ProcessExists($8h))
Local Const $8j = ProcessExists($8h)
If 0 = $8j Then
If $a1 Then _zj("  [OK] Proccess " & $8h & " stopped successfully")
Return 1
EndIf
Return 0
EndFunc
Func _10k($7t)
Dim $af
Dim $a1
If $a1 Then _zj("[I] RemoveAllProcess")
Local $ag = ProcessList()
For $43 = 1 To $ag[0][0]
Local $ah = $ag[$43][0]
Local $ai = $ag[$43][1]
For $af = 1 To UBound($7t) - 1
If StringRegExp($ah, $7t[$af][1]) Then
_10j($ai)
_zw($7t[$af][0], "process", $ah)
EndIf
Next
Next
EndFunc
Func _10l($aj)
Dim $a1
If $a1 Then _zj("[I] RemoveScheduleTask")
For $43 = 1 To UBound($aj) - 1
RunWait('schtasks.exe /delete /tn "' & $aj[$43][1] & '" /f', @TempDir, @SW_HIDE)
Next
EndFunc
Func _10m($aj)
Dim $a1
If $a1 Then _zj("[I] UninstallNormaly")
Local Const $86 = _zp()
For $43 = 1 To UBound($86) - 1
For $ak = 1 To UBound($aj) - 1
Local $al = $aj[$ak][1]
Local $am = $aj[$ak][2]
Local $an = _10g($86[$43], "*", $al)
For $ao = 1 To UBound($an) - 1
Local $ap = _10g($an[$ao], "*", $am)
For $aq = 1 To UBound($ap) - 1
If _zq($ap[$aq]) Then
RunWait($ap[$aq])
_zw($aj[$ak][0], "uninstall", $ap[$aq])
EndIf
Next
Next
Next
Next
EndFunc
Func _10n($aj)
Dim $a1
If $a1 Then _zj("[I] RemoveAllProgramFilesDir")
Local Const $86 = _zp()
For $43 = 1 To UBound($86) - 1
_10h($86[$43], $aj)
Next
EndFunc
Func _10o($aj)
Dim $a1
If $a1 Then _zj("[I] RemoveAllSoftwareKeyList")
Local $5f = ""
If @OSArch = "X64" Then $5f = "64"
Local $ar[2] = ["HKCU" & $5f & "\SOFTWARE", "HKLM" & $5f & "\SOFTWARE"]
For $7f = 0 To UBound($ar) - 1
Local $43 = 0
While True
$43 += 1
Local $84 = RegEnumKey($ar[$7f], $43)
If @error <> 0 Then ExitLoop
For $ak = 1 To UBound($aj) - 1
If $84 And $aj[$ak][1] Then
If StringRegExp($84, $aj[$ak][1]) Then
Local $as = $ar[$7f] & "\" & $84
_10i($as, $aj[$ak][0])
EndIf
EndIf
Next
WEnd
Next
EndFunc
Func _10p($aj)
Dim $a1
If $a1 Then _zj("[I] RemoveUninstallStringWithSearch")
For $43 = 1 To UBound($aj) - 1
Local $as = _zn($aj[$43][1], $aj[$43][2], $aj[$43][3])
If $as And $as <> "" Then
_10i($as, $aj[$43][0])
EndIf
Next
EndFunc
Func _10q()
Local Const $at = "frst"
Dim $9l
Dim $9m
Dim $au
Dim $9o
Dim $av
Dim $9q
Local Const $a4 = "(?i)^Farbar"
Local Const $aw = "(?i)^FRST.*\.exe$"
Local Const $ax = "(?i)^FRST-OlderVersion$"
Local Const $ay = "(?i)^(FRST|fixlist|fixlog|Addition|Shortcut).*\.(exe|txt)$"
Local Const $az = "(?i)^FRST"
Local Const $b0[1][2] = [[$at, $aw]]
Local Const $b1[1][5] = [[$at, 'file', $a4, $ay, False]]
Local Const $b2[1][5] = [[$at, 'folder', Null, $ax, False]]
Local Const $b3[1][5] = [[$at, 'folder', Null, $az, True]]
_vv($9l, $b0)
_vv($9m, $b1)
_vv($9o, $b1)
_vv($9m, $b2)
_vv($9o, $b2)
_vv($9q, $b3)
EndFunc
_10q()
Func _10r()
Dim $9w
Dim $9r
Dim $9v
Local $at = "zhp"
Local Const $88[1][2] = [[$at, "(?i)^ZHP$"]]
Local Const $b4[1][5] = [[$at, 'folder', Null, "(?i)^ZHP$", True]]
_vv($9r, $88)
_vv($9w, $b4)
_vv($9v, $b4)
EndFunc
_10r()
Func _10s()
Local Const $b5 = Null
Local Const $at = "zhpdiag"
Dim $9l
Dim $9m
Dim $9n
Dim $9o
Dim $9q
Local Const $aw = "(?i)^ZHPDiag.*\.exe$"
Local Const $ax = "(?i)^ZHPDiag.*\.(exe|txt|lnk)$"
Local Const $ay = "(?i)^PhysicalDisk[0-9]_MBR\.bin$"
Local Const $b0[1][2] = [[$at, $aw]]
Local Const $b1[1][5] = [[$at, 'file', $b5, $ax, False]]
Local Const $b2[1][5] = [[$at, 'file', Null, $ay, True]]
_vv($9l, $b0)
_vv($9m, $b1)
_vv($9o, $b1)
_vv($9n, $b1)
_vv($9q, $b2)
EndFunc
_10s()
Func _10t()
Local Const $b5 = Null
Local Const $b6 = "zhpfix"
Dim $9l
Dim $9m
Dim $9o
Local Const $aw = "(?i)^ZHPFix.*\.exe$"
Local Const $ax = "(?i)^ZHPFix.*\.(exe|txt|lnk)$"
Local Const $b0[1][2] = [[$b6, $aw]]
Local Const $b1[1][5] = [[$b6, 'file', $b5, $ax, False]]
_vv($9l, $b0)
_vv($9m, $b1)
_vv($9o, $b1)
EndFunc
_10t()
Func _10u($91 = False)
Local Const $a4 = "(?i)^Malwarebytes Anti-Rootkit$"
Local Const $b7 = "(?i)^Malwarebytes"
Local Const $at = "mbar"
Dim $9l
Dim $9m
Dim $9o
Dim $9r
Local Const $aw = "(?i)^mbar.*\.exe$"
Local Const $ax = "(?i)^mbar"
Local Const $b0[1][2] = [[$at, $aw]]
Local Const $b1[1][2] = [[$at, $a4]]
Local Const $b2[1][5] = [[$at, 'file', $b7, $aw, False]]
Local Const $b3[1][5] = [[$at, 'folder', $a4, $ax, False]]
_vv($9l, $b0)
_vv($9m, $b2)
_vv($9o, $b2)
_vv($9m, $b3)
_vv($9o, $b3)
_vv($9r, $b1)
EndFunc
_10u()
Func _10v()
Local Const $at = "roguekiller"
Dim $9l
Dim $9s
Dim $9t
Dim $9p
Dim $9u
Dim $9m
Dim $9n
Dim $9x
Dim $9o
Local $5f = ""
If @OSArch = "X64" Then $5f = "64"
Local Const $b8 = "(?i)^Adlice"
Local Const $aw = "(?i)^RogueKiller"
Local Const $ax = "(?i)^RogueKiller.*\.(exe|lnk|txt)$"
Local Const $ay = "(?i)^RogueKiller.*\.exe$"
Local Const $az = "(?i)^RogueKiller_portable(32|64)\.exe$"
Local Const $b0[1][2] = [[$at, $ay]]
Local Const $b1[1][2] = [[$at, "RogueKiller Anti-Malware"]]
Local Const $b2[1][4] = [[$at, "HKLM" & $5f & "\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall", $aw, "DisplayName"]]
Local Const $b3[1][5] = [[$at, 'file', $b8, $ax, False]]
Local Const $b9[1][5] = [[$at, 'folder', Null, $aw, True]]
Local Const $ba[1][5] = [[$at, 'file', Null, $az, False]]
_vv($9l, $b0)
_vv($9s, $b1)
_vv($9t, $b2)
_vv($9p, $b9)
_vv($9u, $b9)
_vv($9m, $ba)
_vv($9m, $b3)
_vv($9m, $b9)
_vv($9o, $ba)
_vv($9o, $b3)
_vv($9o, $b9)
_vv($9n, $b3)
_vv($9x, $b9)
EndFunc
_10v()
Func _10w()
Local Const $at = "adwcleaner"
Local Const $a4 = "(?i)^AdwCleaner"
Local Const $b7 = "(?i)^Malwarebytes"
Local Const $aw = "(?i)^AdwCleaner.*\.exe$"
Dim $9l
Dim $9m
Dim $9o
Dim $9q
Local Const $b0[1][2] = [[$at, $aw]]
Local Const $b1[1][5] = [[$at, 'file', $b7, $aw, False]]
Local Const $b2[1][5] = [[$at, 'folder', Null, $a4, True]]
_vv($9l, $b0)
_vv($9m, $b1)
_vv($9o, $b1)
_vv($9q, $b2)
EndFunc
_10w()
Func _10x()
Local Const $b5 = Null
Local Const $at = "zhpcleaner"
Dim $9l
Dim $9m
Dim $9o
Local Const $aw = "(?i)^ZHPCleaner.*\.exe$"
Local Const $ax = "(?i)^ZHPCleaner.*\.(exe|txt|lnk)$"
Local Const $b0[1][2] = [[$at, $aw]]
Local Const $b1[1][5] = [[$at, 'file', $b5, $ax, False]]
_vv($9l, $b0)
_vv($9m, $b1)
_vv($9o, $b1)
EndFunc
_10x()
Func _10y()
Local Const $at = "usbfix"
Dim $9l
Dim $9y
Dim $9m
Dim $9n
Dim $9o
Dim $9r
Dim $9q
Dim $9p
Local Const $a4 = "(?i)^UsbFix"
Local Const $b7 = "(?i)^SosVirus"
Local Const $aw = "(?i)^UsbFix.*\.(exe|lnk|txt)$"
Local Const $ax = "(?i)^Un-UsbFix.exe$"
Local Const $ay = "(?i)^UsbFixQuarantine$"
Local Const $az = "(?i)^UsbFix.*\.exe$"
Local Const $bb[1][2] = [[$at, $az]]
Local Const $b0[1][2] = [[$at, $a4]]
Local Const $b1[1][3] = [[$at, $a4, $ax]]
Local Const $b2[1][5] = [[$at, 'file', $b7, $aw, False]]
Local Const $b3[1][5] = [[$at, 'folder', Null, $ay, True]]
Local Const $b9[1][5] = [[$at, 'folder', Null, $a4, False]]
_vv($9l, $bb)
_vv($9y, $b1)
_vv($9m, $b2)
_vv($9n, $b2)
_vv($9o, $b2)
_vv($9r, $b0)
_vv($9q, $b3)
_vv($9q, $b9)
_vv($9p, $b9)
EndFunc
_10y()
Func _10z()
Local Const $at = "adsfix"
Dim $9l
Dim $9m
Dim $9o
Dim $9q
Dim $9n
Dim $9r
Local Const $a4 = "(?i)^AdsFix"
Local Const $b7 = "(?i)^SosVirus"
Local Const $aw = "(?i)^AdsFix.*\.exe$"
Local Const $ax = "(?i)^AdsFix.*\.(exe|txt|lnk)$"
Local Const $ay = "(?i)^AdsFix.*\.txt$"
Local Const $b0[1][2] = [[$at, $aw]]
Local Const $b1[1][5] = [[$at, 'file', $b7, $ax, False]]
Local Const $b2[1][5] = [[$at, 'file', Null, $ay, False]]
Local Const $b3[1][5] = [[$at, 'folder', Null, $a4, True]]
Local Const $b9[1][2] = [[$at, $a4]]
_vv($9l, $b0)
_vv($9m, $b1)
_vv($9n, $b1)
_vv($9o, $b1)
_vv($9q, $b2)
_vv($9q, $b3)
_vv($9r, $b9)
EndFunc
_10z()
Func _110()
Local Const $at = "aswmbr"
Dim $9l
Dim $9m
Dim $9o
Local Const $a4 = "(?i)^avast"
Local Const $aw = "(?i)^aswmbr.*\.(exe|txt|lnk)$"
Local Const $ax = "(?i)^MBR\.dat$"
Local Const $ay = "(?i)^aswmbr.*\.exe$"
Local Const $b0[1][2] = [[$at, $ay]]
Local Const $b1[1][5] = [[$at, 'file', $a4, $aw, False]]
Local Const $b2[1][5] = [[$at, 'file', Null, $ax, False]]
_vv($9l, $b0)
_vv($9m, $b1)
_vv($9m, $b2)
_vv($9o, $b1)
EndFunc
_110()
Func _111()
Local Const $at = "fss"
Dim $9l
Dim $9m
Dim $9o
Local Const $a4 = "(?i)^Farbar"
Local Const $aw = "(?i)^FSS.*\.(exe|txt|lnk)$"
Local Const $ax = "(?i)^FSS.*\.exe$"
Local Const $b0[1][2] = [[$at, $ax]]
Local Const $b1[1][5] = [[$at, 'file', $a4, $aw, False]]
_vv($9l, $b0)
_vv($9m, $b1)
_vv($9o, $b1)
EndFunc
_111()
Func _112()
Local Const $at = "toolsdiag"
Dim $9l
Dim $9m
Dim $9o
Dim $9q
Local Const $aw = "(?i)^toolsdiag.*\.exe$"
Local Const $ax = "(?i)^ToolsDiag$"
Local Const $b0[1][5] = [[$at, 'folder', Null, $ax, False]]
Local Const $b1[1][5] = [[$at, 'file', Null, $aw, False]]
Local Const $b2[1][2] = [[$at, $aw]]
_vv($9l, $b2)
_vv($9m, $b1)
_vv($9o, $b1)
_vv($9q, $b0)
EndFunc
_112()
Func _113()
Local Const $at = "scanrapide"
Dim $9q
Dim $9m
Dim $9o
Local Const $a4 = Null
Local Const $aw = "(?i)^ScanRapide.*\.exe$"
Local Const $ax = "(?i)^ScanRapide\[R[0-9]+\]\.txt$"
Local Const $b0[1][5] = [[$at, 'file', $a4, $aw, False]]
Local Const $b1[1][5] = [[$at, 'file', Null, $ax, False]]
_vv($9m, $b0)
_vv($9o, $b0)
_vv($9q, $b1)
EndFunc
_113()
Func _114()
Local Const $at = "otl"
Dim $9l
Dim $9m
Dim $9o
Dim $9q
Local Const $a4 = "(?i)^OldTimer"
Local Const $aw = "(?i)^OTL.*\.exe$"
Local Const $ax = "(?i)^OTL.*\.(exe|txt)$"
Local Const $ay = "(?i)^Extras\.txt$"
Local Const $az = "(?i)^_OTL$"
Local Const $b0[1][2] = [[$at, $aw]]
Local Const $b1[1][5] = [[$at, 'file', $a4, $ax, False]]
Local Const $b2[1][5] = [[$at, 'file', Null, $ay, False]]
Local Const $b3[1][5] = [[$at, 'folder', Null, $az, True]]
_vv($9l, $b0)
_vv($9m, $b1)
_vv($9m, $b2)
_vv($9o, $b1)
_vv($9q, $b3)
EndFunc
_114()
Func _115()
Local Const $at = "otm"
Dim $9l
Dim $9m
Dim $9o
Dim $9q
Local Const $a4 = "(?i)^OldTimer"
Local Const $aw = "(?i)^OTM.*\.exe$"
Local Const $ax = "(?i)^_OTM$"
Local Const $b0[1][2] = [[$at, $aw]]
Local Const $b1[1][5] = [[$at, 'file', $a4, $aw, False]]
Local Const $b2[1][5] = [[$at, 'folder', Null, $ax, True]]
_vv($9l, $b0)
_vv($9m, $b1)
_vv($9o, $b1)
_vv($9q, $b2)
EndFunc
_115()
Func _116()
Local Const $at = "listparts"
Dim $9l
Dim $9m
Dim $9o
Dim $9q
Local Const $a4 = "(?i)^Farbar"
Local Const $aw = "(?i)^listParts.*\.exe$"
Local Const $ax = "(?i)^Results\.txt$"
Local Const $b0[1][2] = [[$at, $aw]]
Local Const $b1[1][5] = [[$at, 'file', $a4, $aw, False]]
Local Const $b2[1][5] = [[$at, 'file', Null, $ax, False]]
_vv($9l, $b0)
_vv($9m, $b1)
_vv($9m, $b2)
_vv($9o, $b1)
_vv($9o, $b2)
EndFunc
_116()
Func _117()
Local Const $at = "minitoolbox"
Dim $9l
Dim $9m
Dim $9o
Dim $9q
Local Const $a4 = "(?i)^Farbar"
Local Const $aw = "(?i)^MiniToolBox.*\.exe$"
Local Const $ax = "(?i)^MTB\.txt$"
Local Const $b0[1][2] = [[$at, $aw]]
Local Const $b1[1][5] = [[$at, 'file', $a4, $aw, False]]
Local Const $b2[1][5] = [[$at, 'file', Null, $ax, False]]
_vv($9l, $b0)
_vv($9m, $b1)
_vv($9m, $b2)
_vv($9o, $b1)
_vv($9o, $b2)
EndFunc
_117()
Func _118()
Local Const $at = "miniregtool"
Dim $9l
Dim $9m
Dim $9o
Dim $9q
Local Const $a4 = Null
Local Const $aw = "(?i)^MiniRegTool.*\.exe$"
Local Const $ax = "(?i)^MiniRegTool.*\.(exe|zip)$"
Local Const $ay = "(?i)^Result\.txt$"
Local Const $az = "(?i)^MiniRegTool"
Local Const $b0[1][2] = [[$at, $aw]]
Local Const $b1[1][5] = [[$at, 'file', $a4, $ax, False]]
Local Const $b2[1][5] = [[$at, 'file', $a4, $ay, False]]
Local Const $b3[1][5] = [[$at, 'folder', $a4, $az, False]]
_vv($9l, $b0)
_vv($9m, $b1)
_vv($9m, $b2)
_vv($9m, $b3)
_vv($9o, $b1)
_vv($9o, $b2)
_vv($9o, $b3)
EndFunc
_118()
Func _119()
Local Const $at = "grantperms"
Dim $9l
Dim $9m
Dim $9o
Dim $9q
Local Const $a4 = Null
Local Const $aw = "(?i)^GrantPerms.*\.exe$"
Local Const $ax = "(?i)^GrantPerms.*\.(exe|zip)$"
Local Const $ay = "(?i)^Perms\.txt$"
Local Const $az = "(?i)^GrantPerms"
Local Const $b0[1][2] = [[$at, $aw]]
Local Const $b1[1][5] = [[$at, 'file', $a4, $ax, False]]
Local Const $b2[1][5] = [[$at, 'file', $a4, $ay, False]]
Local Const $b3[1][5] = [[$at, 'folder', $a4, $az, False]]
_vv($9l, $b0)
_vv($9m, $b1)
_vv($9m, $b2)
_vv($9m, $b3)
_vv($9o, $b1)
_vv($9o, $b2)
_vv($9o, $b3)
EndFunc
_119()
Func _11a()
Local Const $at = "combofix"
Dim $9m
Dim $9o
Dim $9q
Local Const $a4 = "(?i)^Swearware"
Local Const $aw = "(?i)^Combofix.*\.exe$"
Local Const $ax = "(?i)^CFScript\.txt$"
Local Const $ay = "(?i)^Qoobox$"
Local Const $az = "(?i)^Combofix.*\.txt$"
Local Const $b0[1][5] = [[$at, 'file', $a4, $aw, False]]
Local Const $b1[1][5] = [[$at, 'file', Null, $ax, False]]
Local Const $b2[1][5] = [[$at, 'folder', Null, $ay, True]]
Local Const $b3[1][5] = [[$at, 'file', Null, $az, False]]
_vv($9m, $b0)
_vv($9m, $b1)
_vv($9o, $b0)
_vv($9o, $b1)
_vv($9q, $b2)
_vv($9q, $b3)
EndFunc
_11a()
Func _11b()
Local Const $at = "regtoolexport"
Dim $9l
Dim $9m
Dim $9o
Local Const $a4 = Null
Local Const $aw = "(?i)^regtoolexport.*\.exe$"
Local Const $ax = "(?i)^Export.*\.reg$"
Local Const $b0[1][2] = [[$at, $aw]]
Local Const $b1[1][5] = [[$at, 'file', $a4, $aw, False]]
Local Const $b2[1][5] = [[$at, 'file', $a4, $ax, False]]
_vv($9l, $b0)
_vv($9m, $b1)
_vv($9m, $b2)
_vv($9o, $b1)
_vv($9o, $b2)
EndFunc
_11b()
Func _11c()
Local Const $at = "tdsskiller"
Dim $9l
Dim $9m
Dim $9o
Dim $9q
Local Const $a4 = "(?i)^.*Kaspersky"
Local Const $aw = "(?i)^tdsskiller.*\.exe$"
Local Const $ax = "(?i)^tdsskiller.*\.(exe|zip)$"
Local Const $ay = "(?i)^TDSSKiller.*_log\.txt$"
Local Const $az = "(?i)^TDSSKiller"
Local Const $b0[1][2] = [[$at, $aw]]
Local Const $b1[1][5] = [[$at, 'file', $a4, $ax, False]]
Local Const $b2[1][5] = [[$at, 'file', Null, $ay, False]]
Local Const $b3[1][5] = [[$at, 'folder', Null, $az, False]]
_vv($9l, $b0)
_vv($9m, $b1)
_vv($9m, $b3)
_vv($9o, $b1)
_vv($9o, $b3)
_vv($9q, $b2)
_vv($9q, $b3)
EndFunc
_11c()
Func _11d()
Local Const $at = "winupdatefix"
Dim $9l
Dim $9m
Dim $9o
Dim $9q
Local Const $a4 = Null
Local Const $aw = "(?i)^winupdatefix.*\.exe$"
Local Const $ax = "(?i)^winupdatefix.*\.txt$"
Local Const $b0[1][2] = [[$at, $aw]]
Local Const $b1[1][5] = [[$at, 'file', $a4, $aw, False]]
Local Const $b2[1][5] = [[$at, 'file', $a4, $ax, False]]
_vv($9l, $b0)
_vv($9m, $b1)
_vv($9o, $b1)
_vv($9q, $b2)
EndFunc
_11d()
Func _11e()
Local Const $at = "rsthosts"
Dim $9l
Dim $9m
Dim $9o
Dim $9q
Local Const $a4 = Null
Local Const $aw = "(?i)^rsthosts.*\.exe$"
Local Const $ax = "(?i)^RstHosts.*\.txt$"
Local Const $b0[1][2] = [[$at, $aw]]
Local Const $b1[1][5] = [[$at, 'file', $a4, $aw, Null]]
Local Const $b2[1][5] = [[$at, 'file', $a4, $ax, Null]]
_vv($9l, $b0)
_vv($9m, $b1)
_vv($9o, $b1)
_vv($9q, $b2)
EndFunc
_11e()
Func _11f()
Local Const $at = "winchk"
Dim $9l
Dim $9m
Dim $9o
Dim $9q
Local Const $a4 = Null
Local Const $aw = "(?i)^winchk.*\.exe$"
Local Const $ax = "(?i)^WinChk.*\.txt$"
Local Const $b0[1][2] = [[$at, $aw]]
Local Const $b1[1][5] = [[$at, 'file', $a4, $aw, False]]
Local Const $b2[1][5] = [[$at, 'file', $a4, $ax, False]]
_vv($9l, $b0)
_vv($9m, $b1)
_vv($9o, $b1)
_vv($9q, $b2)
EndFunc
_11f()
Func _11g()
Local Const $at = "avenger"
Dim $9l
Dim $9m
Dim $9o
Dim $9q
Local Const $a4 = Null
Local Const $aw = "(?i)^avenger.*\.(exe|zip)$"
Local Const $ax = "(?i)^avenger"
Local Const $ay = "(?i)^avenger.*\.txt$"
Local Const $az = "(?i)^avenger.*\.exe$"
Local Const $b0[1][2] = [[$at, $az]]
Local Const $b1[1][5] = [[$at, 'file', $a4, $aw, False]]
Local Const $b2[1][5] = [[$at, 'folder', $a4, $ax, False]]
Local Const $b3[1][5] = [[$at, 'file', $a4, $ay, False]]
_vv($9l, $b0)
_vv($9m, $b1)
_vv($9m, $b2)
_vv($9o, $b1)
_vv($9o, $b2)
_vv($9q, $b2)
_vv($9q, $b3)
EndFunc
_11g()
Func _11h()
Local Const $at = "blitzblank"
Dim $9l
Dim $9m
Dim $9o
Dim $9q
Dim $9n
Dim $9r
Local Const $a4 = "(?i)^Emsi"
Local Const $aw = "(?i)^BlitzBlank.*\.exe$"
Local Const $ax = "(?i)^BlitzBlank.*\.log$"
Local Const $b0[1][2] = [[$at, $aw]]
Local Const $b1[1][5] = [[$at, 'file', $a4, $aw, False]]
Local Const $b2[1][5] = [[$at, 'file', Null, $ax, False]]
_vv($9l, $b0)
_vv($9m, $b1)
_vv($9o, $b1)
_vv($9q, $b2)
EndFunc
_11h()
Func _11i()
Local Const $at = "zoek"
Dim $9l
Dim $9m
Dim $9o
Dim $9q
Dim $9n
Dim $9r
Local Const $a4 = Null
Local Const $aw = "(?i)^zoek.*\.exe$"
Local Const $ax = "(?i)^zoek.*\.log$"
Local Const $ay = "(?i)^zoek"
Local Const $az = "(?i)^runcheck.*\.txt$"
Local Const $b0[1][2] = [[$at, $aw]]
Local Const $b1[1][5] = [[$at, 'file', $a4, $aw, False]]
Local Const $b2[1][5] = [[$at, 'file', $a4, $ax, False]]
Local Const $b3[1][5] = [[$at, 'folder', $a4, $ay, True]]
Local Const $b9[1][5] = [[$at, 'file', $a4, $az, False]]
_vv($9l, $b0)
_vv($9m, $b1)
_vv($9o, $b1)
_vv($9q, $b2)
_vv($9q, $b3)
_vv($9q, $b9)
EndFunc
_11i()
Func _11j()
Local Const $at = "remediate-vbs-worm"
Dim $9l
Dim $9m
Dim $9o
Dim $9q
Dim $9n
Dim $9r
Local Const $a4 = "(?i).*VBS autorun worms.*"
Local Const $b7 = Null
Local Const $aw = "(?i)^remediate.?vbs.?worm.*\.exe$"
Local Const $ax = "(?i)^Rem-VBS.*\.log$"
Local Const $ay = "(?i)^Rem-VBS"
Local Const $b0[1][2] = [[$at, $aw]]
Local Const $b1[1][5] = [[$at, 'file', $b7, $aw, False]]
Local Const $b2[1][5] = [[$at, 'file', $b7, $ax, False]]
Local Const $b3[1][5] = [[$at, 'folder', $a4, $ay, True]]
_vv($9l, $b0)
_vv($9m, $b1)
_vv($9o, $b1)
_vv($9q, $b2)
_vv($9q, $b3)
EndFunc
_11j()
Func _11k()
Local Const $at = "ckscanner"
Dim $9l
Dim $9m
Dim $9o
Local Const $a4 = Null
Local Const $aw = "(?i)^CKScanner.*\.exe$"
Local Const $ax = "(?i)^CKfiles.*\.txt$"
Local Const $b0[1][2] = [[$at, $aw]]
Local Const $b1[1][5] = [[$at, 'file', $a4, $aw, False]]
Local Const $b2[1][5] = [[$at, 'file', $a4, $ax, False]]
_vv($9l, $b0)
_vv($9m, $b1)
_vv($9o, $b1)
_vv($9m, $b2)
_vv($9o, $b2)
EndFunc
_11k()
Func _11l()
Local Const $at = "quickdiag"
Dim $9l
Dim $9m
Dim $9o
Dim $9q
Local Const $a4 = "(?i)^SosVirus"
Local Const $aw = "(?i)^QuickDiag.*\.exe$"
Local Const $ax = "(?i)^QuickDiag.*\.(exe|txt)$"
Local Const $ay = "(?i)^QuickScript.*\.txt$"
Local Const $az = "(?i)^QuickDiag.*\.txt$"
Local Const $bc = "(?i)^QuickDiag"
Local Const $b0[1][2] = [[$at, $aw]]
Local Const $b1[1][5] = [[$at, 'file', $a4, $ax, True]]
Local Const $b2[1][5] = [[$at, 'file', Null, $ay, True]]
Local Const $b3[1][5] = [[$at, 'file', Null, $az, True]]
Local Const $b9[1][5] = [[$at, 'folder', Null, $bc, True]]
_vv($9l, $b0)
_vv($9m, $b1)
_vv($9o, $b1)
_vv($9m, $b2)
_vv($9o, $b2)
_vv($9q, $b3)
_vv($9q, $b9)
EndFunc
_11l()
Func _11m()
Local Const $at = "adlicediag"
Dim $9l
Dim $9t
Dim $9p
Dim $9u
Dim $9m
Dim $9o
Dim $9n
Dim $9x
Local $5f = ""
If @OSArch = "X64" Then $5f = "64"
Local Const $bd = "(?i)^Adlice Diag"
Local Const $aw = "(?i)^Diag version"
Local Const $ax = "(?i)^Diag$"
Local Const $ay = "(?i)^ADiag$"
Local Const $az = "(?i)^Diag_portable(32|64)\.exe$"
Local Const $bc = "(?i)^Diag\.lnk$"
Local Const $be = "(?i)^Diag_setup\.exe$"
Local Const $bf = "(?i)^Diag(32|64)?\.exe$"
Local Const $b0[1][2] = [[$at, $bd]]
Local Const $b1[1][4] = [[$at, "HKLM" & $5f & "\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall", $aw, "DisplayName"]]
Local Const $b2[1][5] = [[$at, 'folder', Null, $ax, True]]
Local Const $b3[1][5] = [[$at, 'folder', Null, $ay, True]]
Local Const $b9[1][5] = [[$at, 'file', Null, $az, False]]
Local Const $ba[1][5] = [[$at, 'file', Null, $bc, False]]
Local Const $bg[1][5] = [[$at, 'file', Null, $be, False]]
Local Const $bh[1][2] = [[$at, $bf]]
_vv($9l, $b0)
_vv($9l, $bh)
_vv($9t, $b1)
_vv($9p, $b2)
_vv($9u, $b3)
_vv($9m, $b9)
_vv($9m, $ba)
_vv($9m, $bg)
_vv($9o, $b9)
_vv($9o, $bg)
_vv($9n, $ba)
_vv($9x, $b2)
EndFunc
_11m()
Func _11n()
Local $5f = ""
If @OSArch = "X64" Then $5f = "64"
If FileExists(@AppDataCommonDir & "\Malwarebytes\Malwarebytes' Anti-Malware\Quarantine") Then
Local $bi = _x1(@AppDataCommonDir & "\Malwarebytes\Malwarebytes' Anti-Malware\Quarantine")
If @error = 0 Then
For $43 = 1 To $bi[0]
_10e(@AppDataCommonDir & "\Malwarebytes\Malwarebytes' Anti-Malware\Quarantine" & '\' & $bi[$43], "mbar", Null, True)
Next
EndIf
EndIf
_10i("HKLM" & $5f & "\SOFTWARE\Microsoft\Windows\Windows Error Reporting\LocalDumps\RogueKiller.exe", "roguekiller")
_10i("HKLM" & $5f & "\SOFTWARE\Microsoft\Windows\CurrentVersion\App Paths\combofix.exe", "combofix")
EndFunc
Func _11o($91 = False)
If $91 = True Then
_zj(@CRLF & "- Search Tools -" & @CRLF)
EndIf
_10k($9l)
_102()
_10m($9y)
_102()
_10l($9s)
_102()
_10h(@DesktopDir, $9m)
_102()
_10h(@DesktopCommonDir, $9n)
_102()
If FileExists(@UserProfileDir & "\Downloads") Then
_10h(@UserProfileDir & "\Downloads", $9o)
_102()
Else
_102()
EndIf
_10n($9p)
_102()
_10h(@HomeDrive, $9q)
_102()
_10h(@AppDataDir, $9v)
_102()
_10h(@AppDataCommonDir, $9u)
_102()
_10h(@LocalAppDataDir, $9w)
_102()
_10o($9r)
_102()
_10p($9t)
_102()
_10h(@AppDataCommonDir & "\Microsoft\Windows\Start Menu\Programs", $9x)
_102()
_11n()
_102()
If $91 = True Then
Local $bj = False
Local Const $bk[4] = ["process", "uninstall", "element", "key"]
For $bl In $8e
Local $bm = $8e.Item($bl)
Local $bn = False
For $bo = 0 To UBound($bk) - 1
Local $bp = $bk[$bo]
Local $bq = $bm.Item($bp)
Local $br = $bq.Keys
If UBound($br) > 0 Then
If $bn = False Then
$bn = True
$bj = True
_zj(@CRLF & "  ## " & StringUpper($bl) & " found")
EndIf
For $bs = 0 To UBound($br) - 1
Local $bt = $br[$bs]
Local $bu = $bq.Item($bt)
_101($bp, $bt, $bu)
Next
EndIf
Next
Next
If $bj = False Then
_zj("  [I] No tools found")
EndIf
EndIf
_102()
EndFunc
FileInstall("C:\Users\test\Desktop\kpRemover\src\assets\bug.gif", @TempDir & "\kprm-logo.gif")
Global $97 = "KpRm"
Global $a1 = False
Global $7v = "kprm-" & @YEAR & @MON & @MDAY & @HOUR & @MIN & ".txt"
Local Const $bv = GUICreate($97, 500, 195, 202, 112)
Local Const $bw = GUICtrlCreateGroup("Actions", 8, 8, 400, 153)
Local Const $bx = GUICtrlCreateCheckbox($4y, 16, 40, 129, 17)
Local Const $by = GUICtrlCreateCheckbox($4z, 16, 80, 190, 17)
Local Const $bz = GUICtrlCreateCheckbox($50, 16, 120, 190, 17)
Local Const $c0 = GUICtrlCreateCheckbox($51, 220, 40, 137, 17)
Local Const $c1 = GUICtrlCreateCheckbox($52, 220, 80, 137, 17)
Local Const $c2 = GUICtrlCreateCheckbox($53, 220, 120, 180, 17)
Global $8t = GUICtrlCreateProgress(8, 170, 480, 17)
GUICtrlCreateGroup("", -99, -99, 1, 1)
GUICtrlSetState($bx, 1)
Local Const $c3 = GUICtrlCreatePic(@TempDir & "\kprm-logo.gif", 415, 16, 76, 76)
Local Const $c4 = GUICtrlCreateButton($54, 415, 120, 75, 40)
GUISetState(@SW_SHOW)
While 1
Local $c5 = GUIGetMsg()
Switch $c5
Case $0
Exit
Case $c4
_11r()
EndSwitch
WEnd
Func _11p()
Local Const $c6 = @HomeDrive & "\KPRM"
If Not FileExists($c6) Then
DirCreate($c6)
EndIf
If Not FileExists($c6) Then
MsgBox(16, $56, $57)
Exit
EndIf
EndFunc
Func _11q()
_11p()
_zj("#################################################################################################################" & @CRLF)
_zj("# Run at " & _3o())
_zj("# Run by " & @UserName & " from " & @WorkingDir)
_zj("# Computer Name: " & @ComputerName)
_zj("# OS: " & _zt() & " " & @OSArch & " (" & @OSBuild & ") " & @OSServicePack)
_103()
EndFunc
Func _11r()
_11q()
_102()
If GUICtrlRead($c0) = $1 Then
_10a()
EndIf
_102()
If GUICtrlRead($bx) = $1 Then
_11o()
_11o(True)
Else
_102(32)
EndIf
_102()
If GUICtrlRead($c2) = $1 Then
_10c()
EndIf
_102()
If GUICtrlRead($c1) = $1 Then
_10b()
EndIf
_102()
If GUICtrlRead($by) = $1 Then
_104()
EndIf
_102()
If GUICtrlRead($bz) = $1 Then
_109()
EndIf
GUICtrlSetData($8t, 100)
MsgBox(64, "OK", $55)
_zi()
EndFunc
