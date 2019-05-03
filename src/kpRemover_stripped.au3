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
Local $4y = "0.0.13"
Local Const $4z[6] = ["040C", "080C", "0C0C", "100C", "140C", "180C"]
If _we($4z, @MUILang) <> 1 Then
Global $50 = "Supprimer les outils"
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
Global $5c = "Mise à jour"
Global $5d = "Une version plus récente de KpRm existe, merci de la télécharger."
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
Global $5c = "Update"
Global $5d = "A more recent version of KpRm exists, please download it!"
EndIf
Global Const $5e = 1
Global Const $5f = 5
Global Const $5g = 0
Global Const $5h = 1
Func _xr($5i = $5f)
If Not IsAdmin() Then Return SetError(-3, 0, -1)
If StringRegExp(@OSVersion, "_(XP|200(0|3))") Then Return SetError(-4, 0, -1)
Local $5j = ""
If @OSArch = "X64" Then $5j = "64"
If $5i < 0 Or $5i > 5 Then Return SetError(-5, 0, -1)
Local $2m = RegWrite("HKEY_LOCAL_MACHINE" & $5j & "\Software\Microsoft\Windows\CurrentVersion\Policies\System", "ConsentPromptBehaviorAdmin", "REG_DWORD", $5i)
If $2m = 0 Then $2m = -1
Return SetError(@error, 0, $2m)
EndFunc
Func _xs($5i = $5e)
If Not IsAdmin() Then Return SetError(-3, 0, -1)
If StringRegExp(@OSVersion, "_(XP|200(0|3))") Then Return SetError(-4, 0, -1)
If $5i < 0 Or $5i = 2 Or $5i > 3 Then Return SetError(-5, 0, -1)
Local $5j = ""
If @OSArch = "X64" Then $5j = "64"
Local $2m = RegWrite("HKEY_LOCAL_MACHINE" & $5j & "\Software\Microsoft\Windows\CurrentVersion\Policies\System", "ConsentPromptBehaviorUser", "REG_DWORD", $5i)
If $2m = 0 Then $2m = -1
Return SetError(@error, 0, $2m)
EndFunc
Func _xt($5i = $5g)
If Not IsAdmin() Then Return SetError(-3, 0, -1)
If StringRegExp(@OSVersion, "_(XP|200(0|3))") Then Return SetError(-4, 0, -1)
If $5i < 0 Or $5i > 1 Then Return SetError(-5, 0, -1)
Local $5j = ""
If @OSArch = "X64" Then $5j = "64"
Local $2m = RegWrite("HKEY_LOCAL_MACHINE" & $5j & "\Software\Microsoft\Windows\CurrentVersion\Policies\System", "EnableInstallerDetection", "REG_DWORD", $5i)
If $2m = 0 Then $2m = -1
Return SetError(@error, 0, $2m)
EndFunc
Func _xu($5i = $5h)
If Not IsAdmin() Then Return SetError(-3, 0, -1)
If StringRegExp(@OSVersion, "_(XP|200(0|3))") Then Return SetError(-4, 0, -1)
If $5i < 0 Or $5i > 1 Then Return SetError(-5, 0, -1)
Local $5j = ""
If @OSArch = "X64" Then $5j = "64"
Local $2m = RegWrite("HKEY_LOCAL_MACHINE" & $5j & "\Software\Microsoft\Windows\CurrentVersion\Policies\System", "EnableLUA", "REG_DWORD", $5i)
If $2m = 0 Then $2m = -1
Return SetError(@error, 0, $2m)
EndFunc
Func _xv($5i = $5h)
If Not IsAdmin() Then Return SetError(-3, 0, -1)
If StringRegExp(@OSVersion, "_(XP|200(0|3))") Then Return SetError(-4, 0, -1)
If $5i < 0 Or $5i > 1 Then Return SetError(-5, 0, -1)
Local $5j = ""
If @OSArch = "X64" Then $5j = "64"
Local $2m = RegWrite("HKEY_LOCAL_MACHINE" & $5j & "\Software\Microsoft\Windows\CurrentVersion\Policies\System", "EnableSecureUIAPaths", "REG_DWORD", $5i)
If $2m = 0 Then $2m = -1
Return SetError(@error, 0, $2m)
EndFunc
Func _xw($5i = $5g)
If Not IsAdmin() Then Return SetError(-3, 0, -1)
If StringRegExp(@OSVersion, "_(XP|200(0|3))") Then Return SetError(-4, 0, -1)
If $5i < 0 Or $5i > 1 Then Return SetError(-5, 0, -1)
Local $5j = ""
If @OSArch = "X64" Then $5j = "64"
Local $2m = RegWrite("HKEY_LOCAL_MACHINE" & $5j & "\Software\Microsoft\Windows\CurrentVersion\Policies\System", "EnableUIADesktopToggle", "REG_DWORD", $5i)
If $2m = 0 Then $2m = -1
Return SetError(@error, 0, $2m)
EndFunc
Func _xx($5i = $5h)
If Not IsAdmin() Then Return SetError(-3, 0, -1)
If StringRegExp(@OSVersion, "_(XP|200(0|3))") Then Return SetError(-4, 0, -1)
If $5i < 0 Or $5i > 1 Then Return SetError(-5, 0, -1)
Local $5j = ""
If @OSArch = "X64" Then $5j = "64"
Local $2m = RegWrite("HKEY_LOCAL_MACHINE" & $5j & "\Software\Microsoft\Windows\CurrentVersion\Policies\System", "EnableVirtualization", "REG_DWORD", $5i)
If $2m = 0 Then $2m = -1
Return SetError(@error, 0, $2m)
EndFunc
Func _xy($5i = $5g)
If Not IsAdmin() Then Return SetError(-3, 0, -1)
If StringRegExp(@OSVersion, "_(XP|200(0|3))") Then Return SetError(-4, 0, -1)
If $5i < 0 Or $5i > 1 Then Return SetError(-5, 0, -1)
Local $5j = ""
If @OSArch = "X64" Then $5j = "64"
Local $2m = RegWrite("HKEY_LOCAL_MACHINE" & $5j & "\Software\Microsoft\Windows\CurrentVersion\Policies\System", "FilterAdministratorToken", "REG_DWORD", $5i)
If $2m = 0 Then $2m = -1
Return SetError(@error, 0, $2m)
EndFunc
Func _xz($5i = $5h)
If Not IsAdmin() Then Return SetError(-3, 0, -1)
If StringRegExp(@OSVersion, "_(XP|200(0|3))") Then Return SetError(-4, 0, -1)
If $5i < 0 Or $5i > 1 Then Return SetError(-5, 0, -1)
Local $5j = ""
If @OSArch = "X64" Then $5j = "64"
Local $2m = RegWrite("HKEY_LOCAL_MACHINE" & $5j & "\Software\Microsoft\Windows\CurrentVersion\Policies\System", "PromptOnSecureDesktop", "REG_DWORD", $5i)
If $2m = 0 Then $2m = -1
Return SetError(@error, 0, $2m)
EndFunc
Func _y0($5i = $5g)
If Not IsAdmin() Then Return SetError(-3, 0, -1)
If StringRegExp(@OSVersion, "_(XP|200(0|3))") Then Return SetError(-4, 0, -1)
If $5i < 0 Or $5i > 1 Then Return SetError(-5, 0, -1)
Local $5j = ""
If @OSArch = "X64" Then $5j = "64"
Local $2m = RegWrite("HKEY_LOCAL_MACHINE" & $5j & "\Software\Microsoft\Windows\CurrentVersion\Policies\System", "ValidateAdminCodeSignatures", "REG_DWORD", $5i)
If $2m = 0 Then $2m = -1
Return SetError(@error, 0, $2m)
EndFunc
Global $5k = Null, $5l = Null
Global $5m = EnvGet('SystemDrive') & '\'
Func _y2()
Local $5n[1][3], $5o = 0
$5n[0][0] = $5o
If Not IsObj($5l) Then $5l = ObjGet("winmgmts:root/default")
If Not IsObj($5l) Then Return $5n
Local $5p = $5l.InstancesOf("SystemRestore")
If Not IsObj($5p) Then Return $5n
For $5q In $5p
$5o += 1
ReDim $5n[$5o + 1][3]
$5n[$5o][0] = $5q.SequenceNumber
$5n[$5o][1] = $5q.Description
$5n[$5o][2] = _y3($5q.CreationTime)
Next
$5n[0][0] = $5o
Return $5n
EndFunc
Func _y3($5r)
Return(StringMid($5r, 5, 2) & "/" & StringMid($5r, 7, 2) & "/" & StringLeft($5r, 4) & " " & StringMid($5r, 9, 2) & ":" & StringMid($5r, 11, 2) & ":" & StringMid($5r, 13, 2))
EndFunc
Func _y4($5s)
Local $w = DllCall('SrClient.dll', 'DWORD', 'SRRemoveRestorePoint', 'DWORD', $5s)
If @error Then Return SetError(1, 0, 0)
If $w[0] = 0 Then Return 1
Return SetError(1, 0, 0)
EndFunc
Func _y6($5t = $5m)
If Not IsObj($5k) Then $5k = ObjGet("winmgmts:{impersonationLevel=impersonate}!root/default:SystemRestore")
If Not IsObj($5k) Then Return 0
If $5k.Enable($5t) = 0 Then Return 1
Return 0
EndFunc
Global Enum $5u = 0, $5v, $5w, $5x, $5y, $5z, $60, $61, $62, $63, $64, $65, $66
Global Const $67 = 2
Global $68 = @SystemDir&'\Advapi32.dll'
Global $69 = @SystemDir&'\Kernel32.dll'
Global $6a[4][2], $6b[4][2]
Global $6c = 0
Func _y9()
$68 = DllOpen(@SystemDir&'\Advapi32.dll')
$69 = DllOpen(@SystemDir&'\Kernel32.dll')
$6a[0][0] = "SeRestorePrivilege"
$6a[0][1] = 2
$6a[1][0] = "SeTakeOwnershipPrivilege"
$6a[1][1] = 2
$6a[2][0] = "SeDebugPrivilege"
$6a[2][1] = 2
$6a[3][0] = "SeSecurityPrivilege"
$6a[3][1] = 2
$6b = _zh($6a)
$6c = 1
EndFunc
Func _yf($6d, $6e = $5v, $6f = 'Administrators', $6g = 1)
Local $6h[1][3]
$6h[0][0] = 'Everyone'
$6h[0][1] = 1
$6h[0][2] = $m
Return _yi($6d, $6h, $6e, $6f, 1, $6g)
EndFunc
Func _yi($6d, $6i, $6e = $5v, $6f = '', $6j = 0, $6g = 0, $6k = 3)
If $6c = 0 Then _y9()
If Not IsArray($6i) Or UBound($6i,2) < 3 Then Return SetError(1,0,0)
Local $6l = _yn($6i,$6k)
Local $6m = @extended
Local $6n = 4, $6o = 0
If $6f <> '' Then
If Not IsDllStruct($6f) Then $6f = _za($6f)
$6o = DllStructGetPtr($6f)
If $6o And _zg($6o) Then
$6n = 5
Else
$6o = 0
EndIf
EndIf
If Not IsPtr($6d) And $6e = $5v Then
Return _yv($6d, $6l, $6o, $6j, $6g, $6m, $6n)
ElseIf Not IsPtr($6d) And $6e = $5y Then
Return _yw($6d, $6l, $6o, $6j, $6g, $6m, $6n)
Else
If $6j Then _yx($6d,$6e)
Return _yo($6d, $6e, $6n, $6o, 0, $6l,0)
EndIf
EndFunc
Func _yn(ByRef $6i, ByRef $6k)
Local $6p = UBound($6i,2)
If Not IsArray($6i) Or $6p < 3 Then Return SetError(1,0,0)
Local $6q = UBound($6i), $6r[$6q], $6s = 0, $6t = 1
Local $6u, $6m = 0, $6v
Local $6w, $6x = 'DWORD;DWORD;DWORD;ptr;DWORD;DWORD;DWORD;ptr'
For $43 = 1 To $6q - 1
$6x &= ';DWORD;DWORD;DWORD;ptr;DWORD;DWORD;DWORD;ptr'
Next
$6w = DllStructCreate($6x)
For $43 = 0 To $6q -1
If Not IsDllStruct($6i[$43][0]) Then $6i[$43][0] = _za($6i[$43][0])
$6r[$43] = DllStructGetPtr($6i[$43][0])
If Not _zg($6r[$43]) Then ContinueLoop
DllStructSetData($6w,$6s+1,$6i[$43][2])
If $6i[$43][1] = 0 Then
$6m = 1
$6u = $8
Else
$6u = $7
EndIf
If $6p > 3 Then $6k = $6i[$43][3]
DllStructSetData($6w,$6s+2,$6u)
DllStructSetData($6w,$6s+3,$6k)
DllStructSetData($6w,$6s+6,0)
$6v = DllCall($68,'BOOL','LookupAccountSid','ptr',0,'ptr',$6r[$43],'ptr*',0,'dword*',32,'ptr*',0,'dword*',32,'dword*',0)
If Not @error Then $6t = $6v[7]
DllStructSetData($6w,$6s+7,$6t)
DllStructSetData($6w,$6s+8,$6r[$43])
$6s += 8
Next
Local $6y = DllStructGetPtr($6w)
$6v = DllCall($68,'DWORD','SetEntriesInAcl','ULONG',$6q,'ptr',$6y ,'ptr',0,'ptr*',0)
If @error Or $6v[0] Then Return SetError(1,0,0)
Return SetExtended($6m, $6v[4])
EndFunc
Func _yo($6d, $6e, $6n, $6o = 0, $6z = 0, $6l = 0, $70 = 0)
Local $6v
If $6c = 0 Then _y9()
If $6l And Not _yp($6l) Then Return 0
If $70 And Not _yp($70) Then Return 0
If IsPtr($6d) Then
$6v = DllCall($68,'dword','SetSecurityInfo','handle',$6d,'dword',$6e, 'dword',$6n,'ptr',$6o,'ptr',$6z,'ptr',$6l,'ptr',$70)
Else
If $6e = $5y Then $6d = _zb($6d)
$6v = DllCall($68,'dword','SetNamedSecurityInfo','str',$6d,'dword',$6e, 'dword',$6n,'ptr',$6o,'ptr',$6z,'ptr',$6l,'ptr',$70)
EndIf
If @error Then Return SetError(1,0,0)
If $6v[0] And $6o Then
If _z0($6d, $6e,_zf($6o)) Then Return _yo($6d, $6e, $6n - 1, 0, $6z, $6l, $70)
EndIf
Return SetError($6v[0] , 0, Number($6v[0] = 0))
EndFunc
Func _yp($71)
If $71 = 0 Then Return SetError(1,0,0)
Local $6v = DllCall($68,'bool','IsValidAcl','ptr',$71)
If @error Or Not $6v[0] Then Return 0
Return 1
EndFunc
Func _yv($6d, ByRef $6l, ByRef $6o, ByRef $6j, ByRef $6g, ByRef $6m, ByRef $6n)
Local $72, $73
If Not $6m Then
If $6j Then _yx($6d,$5v)
$72 = _yo($6d, $5v, $6n, $6o, 0, $6l,0)
EndIf
If $6g Then
Local $74 = FileFindFirstFile($6d&'\*')
While 1
$73 = FileFindNextFile($74)
If $6g = 1 Or $6g = 2 And @extended = 1 Then
_yv($6d&'\'&$73, $6l, $6o, $6j, $6g, $6m,$6n)
ElseIf @error Then
ExitLoop
ElseIf $6g = 1 Or $6g = 3 Then
If $6j Then _yx($6d&'\'&$73,$5v)
_yo($6d&'\'&$73, $5v, $6n, $6o, 0, $6l,0)
EndIf
WEnd
FileClose($74)
EndIf
If $6m Then
If $6j Then _yx($6d,$5v)
$72 = _yo($6d, $5v, $6n, $6o, 0, $6l,0)
EndIf
Return $72
EndFunc
Func _yw($6d, ByRef $6l, ByRef $6o, ByRef $6j, ByRef $6g, ByRef $6m, ByRef $6n)
If $6c = 0 Then _y9()
Local $72, $43 = 0, $73
If Not $6m Then
If $6j Then _yx($6d,$5y)
$72 = _yo($6d, $5y, $6n, $6o, 0, $6l,0)
EndIf
If $6g Then
While 1
$43 += 1
$73 = RegEnumKey($6d,$43)
If @error Then ExitLoop
_yw($6d&'\'&$73, $6l, $6o, $6j, $6g, $6m, $6n)
WEnd
EndIf
If $6m Then
If $6j Then _yx($6d,$5y)
$72 = _yo($6d, $5y, $6n, $6o, 0, $6l,0)
EndIf
Return $72
EndFunc
Func _yx($6d, $6e = $5v)
If $6c = 0 Then _y9()
Local $75 = DllStructCreate('byte[32]'), $w
Local $6l = DllStructGetPtr($75,1)
DllCall($68,'bool','InitializeAcl','Ptr',$6l,'dword',DllStructGetSize($75),'dword',$67)
If IsPtr($6d) Then
$w = DllCall($68,"dword","SetSecurityInfo",'handle',$6d,'dword',$6e,'dword',4,'ptr',0,'ptr',0,'ptr',$6l,'ptr',0)
Else
If $6e = $5y Then $6d = _zb($6d)
DllCall($68,'DWORD','SetNamedSecurityInfo','str',$6d,'dword',$6e,'DWORD',4,'ptr',0,'ptr',0,'ptr',0,'ptr',0)
$w = DllCall($68,'DWORD','SetNamedSecurityInfo','str',$6d,'dword',$6e,'DWORD',4,'ptr',0,'ptr',0,'ptr',$6l,'ptr',0)
EndIf
If @error Then Return SetError(@error,0,0)
Return SetError($w[0],0,Number($w[0] = 0))
EndFunc
Func _z0($6d, $6e = $5v, $76 = 'Administrators')
If $6c = 0 Then _y9()
Local $77 = _za($76), $w
Local $6r = DllStructGetPtr($77)
If IsPtr($6d) Then
$w = DllCall($68,"dword","SetSecurityInfo",'handle',$6d,'dword',$6e,'dword',1,'ptr',$6r,'ptr',0,'ptr',0,'ptr',0)
Else
If $6e = $5y Then $6d = _zb($6d)
$w = DllCall($68,'DWORD','SetNamedSecurityInfo','str',$6d,'dword',$6e,'DWORD',1,'ptr',$6r,'ptr',0,'ptr',0,'ptr',0)
EndIf
If @error Then Return SetError(@error,0,False)
Return SetError($w[0],0,Number($w[0] = 0))
EndFunc
Func _za($76)
If $76 = 'TrustedInstaller' Then $76 = 'NT SERVICE\TrustedInstaller'
If $76 = 'Everyone' Then
Return _zd('S-1-1-0')
ElseIf $76 = 'Authenticated Users' Then
Return _zd('S-1-5-11')
ElseIf $76 = 'System' Then
Return _zd('S-1-5-18')
ElseIf $76 = 'Administrators' Then
Return _zd('S-1-5-32-544')
ElseIf $76 = 'Users' Then
Return _zd('S-1-5-32-545')
ElseIf $76 = 'Guests' Then
Return _zd('S-1-5-32-546')
ElseIf $76 = 'Power Users' Then
Return _zd('S-1-5-32-547')
ElseIf $76 = 'Local Authority' Then
Return _zd('S-1-2')
ElseIf $76 = 'Creator Owner' Then
Return _zd('S-1-3-0')
ElseIf $76 = 'NT Authority' Then
Return _zd('S-1-5-1')
ElseIf $76 = 'Restricted' Then
Return _zd('S-1-5-12')
ElseIf StringRegExp($76,'\A(S-1-\d+(-\d+){0,5})\z') Then
Return _zd($76)
Else
Local $77 = _zc($76)
Return _zd($77)
EndIf
EndFunc
Func _zb($78)
If StringInStr($78,'\\') = 1 Then
$78 = StringRegExpReplace($78,'(?i)\\(HKEY_CLASSES_ROOT|HKCR)','\CLASSES_ROOT')
$78 = StringRegExpReplace($78,'(?i)\\(HKEY_CURRENT_USER|HKCU)','\CURRENT_USER')
$78 = StringRegExpReplace($78,'(?i)\\(HKEY_LOCAL_MACHINE|HKLM)','\MACHINE')
$78 = StringRegExpReplace($78,'(?i)\\(HKEY_USERS|HKU)','\USERS')
Else
$78 = StringRegExpReplace($78,'(?i)\A(HKEY_CLASSES_ROOT|HKCR)','CLASSES_ROOT')
$78 = StringRegExpReplace($78,'(?i)\A(HKEY_CURRENT_USER|HKCU)','CURRENT_USER')
$78 = StringRegExpReplace($78,'(?i)\A(HKEY_LOCAL_MACHINE|HKLM)','MACHINE')
$78 = StringRegExpReplace($78,'(?i)\A(HKEY_USERS|HKU)','USERS')
EndIf
Return $78
EndFunc
Func _zc($79, $7a = "")
Local $7b = DllStructCreate("byte SID[256]")
Local $6r = DllStructGetPtr($7b, "SID")
Local $2q = DllCall($68, "bool", "LookupAccountNameW", "wstr", $7a, "wstr", $79, "ptr", $6r, "dword*", 256, "wstr", "", "dword*", 256, "int*", 0)
If @error Then Return SetError(@error, @extended, 0)
If Not $2q[0] Then Return 0
Return _zf($6r)
EndFunc
Func _zd($7c)
Local $2q = DllCall($68, "bool", "ConvertStringSidToSidW", "wstr", $7c, "ptr*", 0)
If @error Then Return SetError(@error, @extended, 0)
If Not $2q[0] Then Return 0
Local $7d = _ze($2q[2])
Local $3h = DllStructCreate("byte Data[" & $7d & "]", $2q[2])
Local $7e = DllStructCreate("byte Data[" & $7d & "]")
DllStructSetData($7e, "Data", DllStructGetData($3h, "Data"))
DllCall($69, "ptr", "LocalFree", "ptr", $2q[2])
Return $7e
EndFunc
Func _ze($6r)
If Not _zg($6r) Then Return SetError(-1, 0, "")
Local $2q = DllCall($68, "dword", "GetLengthSid", "ptr", $6r)
If @error Then Return SetError(@error, @extended, 0)
Return $2q[0]
EndFunc
Func _zf($6r)
If Not _zg($6r) Then Return SetError(-1, 0, "")
Local $2q = DllCall($68, "int", "ConvertSidToStringSidW", "ptr", $6r, "ptr*", 0)
If @error Then Return SetError(@error, @extended, "")
If Not $2q[0] Then Return ""
Local $3h = DllStructCreate("wchar Text[256]", $2q[2])
Local $7c = DllStructGetData($3h, "Text")
DllCall($69, "ptr", "LocalFree", "ptr", $2q[2])
Return $7c
EndFunc
Func _zg($6r)
Local $2q = DllCall($68, "bool", "IsValidSid", "ptr", $6r)
If @error Then Return SetError(@error, @extended, False)
Return $2q[0]
EndFunc
Func _zh($7f)
Local $7g = UBound($7f, 0), $7h[1][2]
If Not($7g <= 2 And UBound($7f, $7g) = 2 ) Then Return SetError(1300, 0, $7h)
If $7g = 1 Then
Local $7i[1][2]
$7i[0][0] = $7f[0]
$7i[0][1] = $7f[1]
$7f = $7i
$7i = 0
EndIf
Local $7j, $7k = "dword", $7l = UBound($7f, 1)
Do
$7j += 1
$7k &= ";dword;long;dword"
Until $7j = $7l
Local $7m, $7n, $7o, $7p, $7q, $7r, $7s
$7m = DLLStructCreate($7k)
$7n = DllStructCreate($7k)
$7o = DllStructGetPtr($7n)
$7p = DllStructCreate("dword;long")
DLLStructSetData($7m, 1, $7l)
For $43 = 0 To $7l - 1
DllCall($68, "int", "LookupPrivilegeValue", "str", "", "str", $7f[$43][0], "ptr", DllStructGetPtr($7p) )
DLLStructSetData( $7m, 3 * $43 + 2, DllStructGetData($7p, 1) )
DLLStructSetData( $7m, 3 * $43 + 3, DllStructGetData($7p, 2) )
DLLStructSetData( $7m, 3 * $43 + 4, $7f[$43][1] )
Next
$7q = DllCall($69, "hwnd", "GetCurrentProcess")
$7r = DllCall($68, "int", "OpenProcessToken", "hwnd", $7q[0], "dword", BitOR(0x00000020, 0x00000008), "hwnd*", 0 )
DllCall( $68, "int", "AdjustTokenPrivileges", "hwnd", $7r[3], "int", False, "ptr", DllStructGetPtr($7m), "dword", DllStructGetSize($7m), "ptr", $7o, "dword*", 0 )
$7s = DllCall($69, "dword", "GetLastError")
DllCall($69, "int", "CloseHandle", "hwnd", $7r[3])
Local $7t = DllStructGetData($7n, 1)
If $7t > 0 Then
Local $7u, $7v, $7w, $7h[$7t][2]
For $43 = 0 To $7t - 1
$7u = $7o + 12 * $43 + 4
$7v = DllCall($68, "int", "LookupPrivilegeName", "str", "", "ptr", $7u, "ptr", 0, "dword*", 0 )
$7w = DllStructCreate("char[" & $7v[4] & "]")
DllCall($68, "int", "LookupPrivilegeName", "str", "", "ptr", $7u, "ptr", DllStructGetPtr($7w), "dword*", DllStructGetSize($7w) )
$7h[$43][0] = DllStructGetData($7w, 1)
$7h[$43][1] = DllStructGetData($7n, 3 * $43 + 4)
Next
EndIf
Return SetError($7s[0], 0, $7h)
EndFunc
Func _zi($7x = False, $7y = True)
Dim $4x
Dim $7z
FileDelete(@TempDir & "\kprm-logo.gif")
If $7x = True Then
If $7y = True Then
Run("notepad.exe " & @HomeDrive & "\KPRM" & "\" & $7z)
EndIf
If $4x = False Then
Run(@ComSpec & ' /c timeout 3 && del /F /Q "' & @ScriptFullPath & '"', @TempDir, @SW_HIDE)
FileDelete(@ScriptFullPath)
EndIf
EndIf
Exit
EndFunc
Func _zj()
Dim $4y
Local Const $80 = _zk("https://kernel-panik.me/_api/v1/kprm/version")
If $80 <> Null And $80 <> "" And $80 <> $4y Then
MsgBox(64, $5c, $5d)
ShellExecute("https://kernel-panik.me/tool/kprm/")
_zi(True, False)
EndIf
EndFunc
_zj()
If Not IsAdmin() Then
MsgBox(16, $58, $5a)
_zi()
EndIf
Local $81 = ProcessList("mbar.exe")
If $81[0][0] > 0 Then
MsgBox(16, $58, $5b)
_zi()
EndIf
Func _zk($82, $83 = "")
Local $84 = ObjCreate("WinHttp.WinHttpRequest.5.1")
$84.Open("GET", $82 & "?" & $83, False)
$84.SetTimeouts(50, 50, 50, 50)
If(@error) Then Return SetError(1, 0, 0)
$84.Send()
If(@error) Then Return SetError(2, 0, 0)
If($84.Status <> 200) Then Return SetError(3, 0, 0)
Return SetError(0, 0, $84.ResponseText)
EndFunc
Func _zl($85)
Dim $7z
FileWrite(@HomeDrive & "\KPRM" & "\" & $7z, $85 & @CRLF)
EndFunc
Func _zm()
Local $86 = 100, $87 = 100, $88 = 0, $89 = @WindowsDir & "\Explorer.exe"
_hf($2z, 0, 0, 0)
Local $8a = _d0("Shell_TrayWnd", "")
_51($8a, 1460, 0, 0)
While ProcessExists("Explorer.exe")
Sleep(10)
$86 -= ProcessClose("Explorer.exe") ? 0 : 1
If $86 < 1 Then Return SetError(1, 0, 0)
WEnd
While(Not ProcessExists("Explorer.exe"))
If Not FileExists($89) Then Return SetError(-1, 0, 0)
Sleep(500)
$88 = ShellExecute($89)
$87 -= $88 ? 0 : 1
If $87 < 1 Then Return SetError(2, 0, 0)
WEnd
Return $88
EndFunc
Func _zp($8b, $8c, $8d)
Local $43 = 0
While True
$43 += 1
Local $8e = RegEnumKey($8b, $43)
If @error <> 0 Then ExitLoop
Local $8f = $8b & "\" & $8e
Local $73 = RegRead($8f, $8d)
If StringRegExp($73, $8c) Then
Return $8f
EndIf
WEnd
Return Null
EndFunc
Func _zr()
Local $8g = []
If FileExists(@HomeDrive & "\Program Files") Then
_vv($8g, @HomeDrive & "\Program Files")
EndIf
If FileExists(@HomeDrive & "\Program Files (x86)") Then
_vv($8g, @HomeDrive & "\Program Files (x86)")
EndIf
If FileExists(@HomeDrive & "\Program Files(x86)") Then
_vv($8g, @HomeDrive & "\Program Files(x86)")
EndIf
Return $8g
EndFunc
Func _zs($4l)
Return Int(FileExists($4l) And StringInStr(FileGetAttrib($4l), 'D', Default, 1) = 0)
EndFunc
Func _zt($4l)
Return Int(FileExists($4l) And StringInStr(FileGetAttrib($4l), 'D', Default, 1) > 0)
EndFunc
Func _zu($4l)
Local $8h = Null
If FileExists($4l) Then
Local $8i = StringInStr(FileGetAttrib($4l), 'D', Default, 1)
If $8i = 0 Then
$8h = 'file'
ElseIf $8i > 0 Then
$8h = 'folder'
EndIf
EndIf
Return $8h
EndFunc
Func _zv()
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
Func _zw($8d)
If StringRegExp($8d, "^(HKLM|HKCU|HKU|HKCR|HKCC)64") Then
Local $8j = StringReplace($8d, "64", "", 1)
Return $8j
EndIf
Return $8d
EndFunc
Func _zx($8k, $8d)
If $8k.Exists($8d) Then
Local $8i = $8k.Item($8d) + 1
$8k.Item($8d) = $8i
Else
$8k.add($8d, 1)
EndIf
Return $8k
EndFunc
Func _zy($8l, $8m, $8n)
Dim $8o
Local $8p = $8o.Item($8l)
Local $8q = _zx($8p.Item($8m), $8n)
$8p.Item($8m) = $8q
$8o.Item($8l) = $8p
EndFunc
Func _0zz($8r, $8s)
If $8r = Null Or $8r = "" Then Return
Local $8t = ProcessExists($8r)
If $8t <> 0 Then
_zl("     [X] Process " & $8r & " not killed, it is possible that the deletion is not complete (" & $8s & ")")
Else
_zl("     [OK] Process " & $8r & " killed (" & $8s & ")")
EndIf
EndFunc
Func _100($8u, $8s)
If $8u = Null Or $8u = "" Then Return
Local $8v = "[X]"
RegEnumVal($8u, "1")
If @error >= 0 Then
$8v = "[OK]"
EndIf
_zl("     " & $8v & " " & _zw($8u) & " deleted (" & $8s & ")")
EndFunc
Func _101($8u, $8s)
If $8u = Null Or $8u = "" Then Return
Local $4u = "", $4v = "", $4r = "", $4w = ""
Local $8w = _xe($8u, $4u, $4v, $4r, $4w)
If $4w = ".exe" Then
Local $8x = $8w[1] & $8w[2]
Local $8v = "[OK]"
If FileExists($8x) Then
$8v = "[X]"
EndIf
_zl("     " & $8v & " Uninstaller run correctly (" & $8s & ")")
EndIf
EndFunc
Func _102($8u, $8s)
If $8u = Null Or $8u = "" Then Return
Local $8v = "[OK]"
If FileExists($8u) Then
$8v = "[X]"
EndIf
_zl("     " & $8v & " " & $8u & " deleted (" & $8s & ")")
EndFunc
Func _103($8y, $8u, $8s)
Switch $8y
Case "process"
_0zz($8u, $8s)
Case "key"
_100($8u, $8s)
Case "uninstall"
_101($8u, $8s)
Case "element"
_102($8u, $8s)
Case Else
_zl("     [?] Unknown type " & $8y)
EndSwitch
EndFunc
Local $8z = 43
Local $90
Local Const $91 = Floor(100 / $8z)
Func _104($92 = 1)
$90 += $92
Dim $93
GUICtrlSetData($93, $90 * $91)
If $90 = $8z Then
GUICtrlSetData($93, 100)
EndIf
EndFunc
Func _105()
$90 = 0
Dim $93
GUICtrlSetData($93, 0)
EndFunc
Func _106()
_zl(@CRLF & "- Clear All System Restore Points -" & @CRLF)
Local Const $94 = _y2()
Local $72 = 0
If $94[0][0] = 0 Then
_zl("  [I] No system recovery points were found")
Return Null
EndIf
Local $95[1][3] = [[Null, Null, Null]]
For $43 = 1 To $94[0][0]
Local $8t = _y4($94[$43][0])
$72 += $8t
If $8t = 1 Then
_zl("    => [OK] RP named " & $94[$43][1] & " created at " & $94[$43][2] & " deleted")
Else
Local $96[1][3] = [[$94[$43][0], $94[$43][1], $94[$43][2]]]
_vv($95, $96)
EndIf
Next
If 1 < UBound($95) Then
Sleep(3000)
For $43 = 1 To UBound($95) - 1
Local $8t = _y4($95[$43][0])
$72 += $8t
If $8t = 1 Then
_zl("    => [OK] RP named " & $95[$43][1] & " created at " & $94[$43][2] & " deleted")
Else
_zl("    => [X] RP named " & $95[$43][1] & " created at " & $94[$43][2] & " deleted")
EndIf
Next
EndIf
If $94[0][0] = $72 Then
_zl(@CRLF & "  [OK] All system restore points have been successfully deleted")
Else
_zl(@CRLF & "  [X] Failure when deleting all restore points")
EndIf
EndFunc
Func _107($5r)
Local $97 = StringLeft($5r, 4)
Local $98 = StringMid($5r, 6, 2)
Local $99 = StringMid($5r, 9, 2)
Local $9a = StringRight($5r, 8)
Return $98 & "/" & $99 & "/" & $97 & " " & $9a
EndFunc
Func _108($9b = False)
Local Const $94 = _y2()
If $94[0][0] = 0 Then
Return Null
EndIf
Local Const $9c = _107(_31('n', -1470, _3p()))
Local $9d = False
Local $9e = False
Local $9f = False
For $43 = 1 To $94[0][0]
Local $9g = $94[$43][2]
If $9g > $9c Then
If $9f = False Then
$9f = True
$9e = True
_zl(@CRLF & "  [I] Recent System Restore Point Deletion before create new:" & @CRLF)
EndIf
Local $8t = _y4($94[$43][0])
If $8t = 1 Then
_zl("    => [OK] RP named " & $94[$43][1] & " created at " & $9g & " deleted")
ElseIf $9b = False Then
$9d = True
Else
_zl("    => [X] RP named " & $94[$43][1] & " created at " & $9g & " deleted")
EndIf
EndIf
Next
If $9d = True Then
Sleep(3000)
_zl("  [I] Retry deleting restore point")
_108(True)
EndIf
If $9e = True Then
_zl(@CRLF)
EndIf
Sleep(3000)
EndFunc
Func _109()
Sleep(3000)
_zl(@CRLF & "- Display All System Restore Point -" & @CRLF)
Local Const $94 = _y2()
If $94[0][0] = 0 Then
_zl("  [X] No System Restore point found")
Return
EndIf
For $43 = 1 To $94[0][0]
_zl("    => [I] RP named " & $94[$43][1] & " created at " & $94[$43][2] & " found")
Next
EndFunc
Func _10a()
RunWait(@ComSpec & ' /c ' & 'wmic.exe /Namespace:\\root\default Path SystemRestore Call CreateRestorePoint "KpRm", 100, 7', "", @SW_HIDE)
Return @error
EndFunc
Func _10b($9b = False)
If $9b = False Then
_zl(@CRLF & "- Create New System Restore Point -" & @CRLF)
Else
_zl("  [I] Retry Create New System Restore Point")
EndIf
Dim $9h
Local $9i = _y6()
If $9i = 0 Then
Sleep(3000)
$9i = _y6()
If $9i = 0 Then
_zl("  [X] Enable System Restore")
EndIf
ElseIf $9i = 1 Then
_zl("  [OK] Enable System Restore")
EndIf
_108()
Local Const $9j = _10a()
If $9j <> 0 Then
_zl("  [X] System Restore Point created")
If $9b = False Then
_zl("  [I] Retry to create System Restore Point!")
_10b(True)
Return
Else
_109()
Return
EndIf
ElseIf $9j = 0 Then
_zl("  [OK] System Restore Point created")
_109()
EndIf
EndFunc
Func _10c()
_zl(@CRLF & "- Create Registry Backup -" & @CRLF)
Local Const $9k = @HomeDrive & "\KPRM"
Local Const $9l = $9k & "\regedit-backup-" & @YEAR & @MON & @MDAY & @HOUR & @MIN & ".reg"
If FileExists($9l) Then
FileMove($9l, $9l & ".old")
EndIf
Local Const $8t = RunWait("Regedit /e " & $9l)
If Not FileExists($9l) Or @error <> 0 Then
_zl("  [X] Failed to create registry backup")
MsgBox(16, $58, $59)
_zi()
Else
_zl("  [OK] Registry Backup: " & $9l)
EndIf
EndFunc
Func _10d()
_zl(@CRLF & "- Restore UAC Default Value -" & @CRLF)
Local $8t = _xr()
If $8t = 1 Then
_zl("  [OK] Set ConsentPromptBehaviorAdmin with default (5) value")
Else
_zl("  [X] Set ConsentPromptBehaviorAdmin with default value")
EndIf
Local $8t = _xs(3)
If $8t = 1 Then
_zl("  [OK] Set ConsentPromptBehaviorUser with default (3) value")
Else
_zl("  [X] Set ConsentPromptBehaviorUser with default value")
EndIf
Local $8t = _xt()
If $8t = 1 Then
_zl("  [OK] Set EnableInstallerDetection with default (0) value")
Else
_zl("  [X] Set EnableInstallerDetection with default value")
EndIf
Local $8t = _xu()
If $8t = 1 Then
_zl("  [OK] Set EnableLUA with default (1) value")
Else
_zl("  [X] Set EnableLUA with default value")
EndIf
Local $8t = _xv()
If $8t = 1 Then
_zl("  [OK] Set EnableSecureUIAPaths with default (1) value")
Else
_zl("  [X] Set EnableSecureUIAPaths with default value")
EndIf
Local $8t = _xw()
If $8t = 1 Then
_zl("  [OK] Set EnableUIADesktopToggle with default (0) value")
Else
_zl("  [X] Set EnableUIADesktopToggle with default value")
EndIf
Local $8t = _xx()
If $8t = 1 Then
_zl("  [OK] Set EnableVirtualization with default (1) value")
Else
_zl("  [X] Set EnableVirtualization with default value")
EndIf
Local $8t = _xy()
If $8t = 1 Then
_zl("  [OK] Set FilterAdministratorToken with default (0) value")
Else
_zl("  [X] Set FilterAdministratorToken with default value")
EndIf
Local $8t = _xz()
If $8t = 1 Then
_zl("  [OK] Set PromptOnSecureDesktop with default (1) value")
Else
_zl("  [X] Set PromptOnSecureDesktop with default value")
EndIf
Local $8t = _y0()
If $8t = 1 Then
_zl("  [OK] Set ValidateAdminCodeSignatures with default (0) value")
Else
_zl("  [X] Set ValidateAdminCodeSignatures with default value")
EndIf
EndFunc
Func _10e()
_zl(@CRLF & "- Restore Default System Settings -" & @CRLF)
Local $8t = RunWait(@ComSpec & " /c " & "ipconfig /flushdns", @TempDir, @SW_HIDE)
If @error <> 0 Then
_zl("  [X] Flush DNS")
Else
_zl("  [OK] Flush DNS")
EndIf
Local Const $9m[7] = [ "netsh winsock reset", "netsh winhttp reset proxy", "netsh winhttp reset tracing", "netsh winsock reset catalog", "netsh int ip reset all", "netsh int ipv4 reset catalog", "netsh int ipv6 reset catalog" ]
$8t = 0
For $43 = 0 To UBound($9m) -1
RunWait(@ComSpec & " /c " & $9m[$43], @TempDir, @SW_HIDE)
If @error <> 0 Then
$8t += 1
EndIf
Next
If $8t = 0 Then
_zl("  [OK] Reset WinSock")
Else
_zl("  [X] Reset WinSock")
EndIf
Local $9n = "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced"
$8t = RegWrite($9n, "Hidden", "REG_DWORD", "2")
If $8t = 1 Then
_zl("  [OK] Hide Hidden file.")
Else
_zl("  [X] Hide Hidden File")
EndIf
$8t = RegWrite($9n, "HideFileExt", "REG_DWORD", "0")
If $8t = 1 Then
_zl("  [OK] Hide Extensions for known file types")
Else
_zl("  [X] Hide Extensions for known file types")
EndIf
$8t = RegWrite($9n, "ShowSuperHidden", "REG_DWORD", "0")
If $8t = 1 Then
_zl("  [OK] Hide protected operating system files")
Else
_zl("  [X] Hide protected operating system files")
EndIf
_zm()
EndFunc
Global $8o = ObjCreate("Scripting.Dictionary")
Local Const $9o[40] = [ "adlicediag", "adsfix", "adwcleaner", "aswmbr", "avenger", "blitzblank", "ckscanner", "cmd-command", "combofix", "frst", "fss", "grantperms", "listparts", "logonfix", "mbar", "miniregtool", "minitoolbox", "otl", "otm", "quickdiag", "regtoolexport", "remediate-vbs-worm", "report_chkdsk", "roguekiller", "rstassociations", "rsthosts", "scanrapide", "seaf", "sft", "tdsskiller", "toolsdiag", "usbfix", "winchk", "winupdatefix", "zhp", "zhpcleaner", "zhpdiag", "zhpfix", "zhplite", "zoek"]
For $9p = 0 To UBound($9o) - 1
Local $9q = ObjCreate("Scripting.Dictionary")
Local $9r = ObjCreate("Scripting.Dictionary")
Local $9s = ObjCreate("Scripting.Dictionary")
Local $9t = ObjCreate("Scripting.Dictionary")
Local $9u = ObjCreate("Scripting.Dictionary")
$9q.add("key", $9r)
$9q.add("element", $9s)
$9q.add("uninstall", $9t)
$9q.add("process", $9u)
$8o.add($9o[$9p], $9q)
Next
Global $9v[1][2] = [[Null, Null]]
Global $9w[1][5] = [[Null, Null, Null, Null, Null]]
Global $9x[1][5] = [[Null, Null, Null, Null, Null]]
Global $9y[1][5] = [[Null, Null, Null, Null, Null]]
Global $9z[1][5] = [[Null, Null, Null, Null, Null]]
Global $a0[1][5] = [[Null, Null, Null, Null, Null]]
Global $a1[1][2] = [[Null, Null]]
Global $a2[1][2] = [[Null, Null]]
Global $a3[1][4] = [[Null, Null, Null, Null]]
Global $a4[1][5] = [[Null, Null, Null, Null, Null]]
Global $a5[1][5] = [[Null, Null, Null, Null, Null]]
Global $a6[1][5] = [[Null, Null, Null, Null, Null]]
Global $a7[1][5] = [[Null, Null, Null, Null, Null]]
Global $a8[1][5] = [[Null, Null, Null, Null, Null]]
Global $a9[1][3] = [[Null, Null, Null]]
Global $aa[1][3] = [[Null, Null, Null]]
Func _10f($8b, $ab = 0, $ac = False)
Dim $ad
If $ad Then _zl("[I] prepareRemove " & $8b)
If $ac Then
_yx($8b)
_yf($8b)
EndIf
Local Const $ae = FileGetAttrib($8b)
If StringInStr($ae, "R") Then
FileSetAttrib($8b, "-R", $ab)
EndIf
If StringInStr($ae, "S") Then
FileSetAttrib($8b, "-S", $ab)
EndIf
If StringInStr($ae, "H") Then
FileSetAttrib($8b, "-H", $ab)
EndIf
If StringInStr($ae, "A") Then
FileSetAttrib($8b, "-A", $ab)
EndIf
EndFunc
Func _10g($af, $8l, $ag = Null, $ac = False)
Dim $ad
If $ad Then _zl("[I] RemoveFile " & $af)
Local Const $ah = _zs($af)
If $ah Then
If $ag And StringRegExp($af, "(?i)\.exe$") Then
Local Const $ai = FileGetVersion($af, "CompanyName")
If @error Then
Return 0
ElseIf Not StringRegExp($ai, $ag) Then
Return 0
EndIf
EndIf
_zy($8l, 'element', $af)
_10f($af, 0, $ac)
Local $aj = FileDelete($af)
If $aj Then
If $ad Then
_zl("  [OK] File " & $af & " deleted successfully")
EndIf
Return 1
EndIf
Return 2
EndIf
Return 0
EndFunc
Func _10h($8b, $8l, $ac = False)
Dim $ad
If $ad Then _zl("[I] RemoveFolder " & $8b)
Local $ah = _zt($8b)
If $ah Then
_zy($8l, 'element', $8b)
_10f($8b, 1, $ac)
Local Const $aj = DirRemove($8b, $l)
If $aj Then
If $ad Then
_zl("  [OK] Directory " & $8b & " deleted successfully")
EndIf
Return 1
EndIf
Return 2
EndIf
Return 0
EndFunc
Func _10i($8b, $af, $ak)
Dim $ad
If $ad Then _zl("[I] FindGlob " & $8b & " " & $af)
Local Const $al = $8b & "\" & $af
Local Const $4t = FileFindFirstFile($al)
Local $am = []
If $4t = -1 Then
Return $am
EndIf
Local $4r = FileFindNextFile($4t)
While @error = 0
If StringRegExp($4r, $ak) Then
_vv($am, $8b & "\" & $4r)
EndIf
$4r = FileFindNextFile($4t)
WEnd
FileClose($4t)
Return $am
EndFunc
Func _10j($8b, $an)
Dim $ad
If $ad Then _zl("[I] RemoveAllFileFrom " & $8b)
Local Const $al = $8b & "\*"
Local Const $4t = FileFindFirstFile($al)
If $4t = -1 Then
Return Null
EndIf
Local $4r = FileFindNextFile($4t)
While @error = 0
For $ao = 1 To UBound($an) - 1
Local $ap = $8b & "\" & $4r
Local $aq = _zu($ap)
If $aq And $an[$ao][3] And $aq = $an[$ao][1] And StringRegExp($4r, $an[$ao][3]) Then
Local $8t = 0
Local $ac = False
If $an[$ao][4] = True Then
$ac = True
EndIf
If $aq = 'file' Then
$8t = _10g($ap, $an[$ao][0], $an[$ao][2], $ac)
ElseIf $aq = 'folder' Then
$8t = _10h($ap, $an[$ao][0], $ac)
EndIf
EndIf
Next
$4r = FileFindNextFile($4t)
WEnd
FileClose($4t)
EndFunc
Func _10k($8d, $8l, $ac = False)
Dim $ad
If $ad Then _zl("[I] RemoveRegistryKey " & $8d)
If $ac = True Then
_yx($8d)
_yf($8d, $5y)
EndIf
Local Const $8t = RegDelete($8d)
If $8t <> 0 Then
_zy($8l, "key", $8d)
If $ad Then
If $8t = 1 Then
_zl("  [OK] " & $8d & " deleted successfully")
ElseIf $8t = 2 Then
_zl("  [X] " & $8d & " deleted failed")
EndIf
EndIf
EndIf
Return $8t
EndFunc
Func _10l($8r)
Local $ar = 50
Dim $ad
If $ad Then _zl("[I] CloseProcessAndWait " & $8r)
If 0 = ProcessExists($8r) Then Return 0
ProcessClose($8r)
Do
$ar -= 1
Sleep(250)
Until($ar = 0 Or 0 = ProcessExists($8r))
Local Const $8t = ProcessExists($8r)
If 0 = $8t Then
If $ad Then _zl("  [OK] Proccess " & $8r & " stopped successfully")
Return 1
EndIf
Return 0
EndFunc
Func _10m($81)
Dim $ar
Dim $ad
If $ad Then _zl("[I] RemoveAllProcess")
Local $as = ProcessList()
For $43 = 1 To $as[0][0]
Local $at = $as[$43][0]
Local $au = $as[$43][1]
For $ar = 1 To UBound($81) - 1
If StringRegExp($at, $81[$ar][1]) Then
_10l($au)
_zy($81[$ar][0], "process", $at)
EndIf
Next
Next
EndFunc
Func _10n($av)
Dim $ad
If $ad Then _zl("[I] RemoveScheduleTask")
For $43 = 1 To UBound($av) - 1
RunWait('schtasks.exe /delete /tn "' & $av[$43][1] & '" /f', @TempDir, @SW_HIDE)
Next
EndFunc
Func _10o($av)
Dim $ad
If $ad Then _zl("[I] UninstallNormaly")
Local Const $8g = _zr()
For $43 = 1 To UBound($8g) - 1
For $aw = 1 To UBound($av) - 1
Local $ax = $av[$aw][1]
Local $ay = $av[$aw][2]
Local $az = _10i($8g[$43], "*", $ax)
For $b0 = 1 To UBound($az) - 1
Local $b1 = _10i($az[$b0], "*", $ay)
For $b2 = 1 To UBound($b1) - 1
If _zs($b1[$b2]) Then
RunWait($b1[$b2])
_zy($av[$aw][0], "uninstall", $b1[$b2])
EndIf
Next
Next
Next
Next
EndFunc
Func _10p($av)
Dim $ad
If $ad Then _zl("[I] RemoveAllProgramFilesDir")
Local Const $8g = _zr()
For $43 = 1 To UBound($8g) - 1
_10j($8g[$43], $av)
Next
EndFunc
Func _10q($av)
Dim $ad
If $ad Then _zl("[I] RemoveAllSoftwareKeyList")
Local $5j = ""
If @OSArch = "X64" Then $5j = "64"
Local $b3[2] = ["HKCU" & $5j & "\SOFTWARE", "HKLM" & $5j & "\SOFTWARE"]
For $7j = 0 To UBound($b3) - 1
Local $43 = 0
While True
$43 += 1
Local $8e = RegEnumKey($b3[$7j], $43)
If @error <> 0 Then ExitLoop
For $aw = 1 To UBound($av) - 1
If $8e And $av[$aw][1] Then
If StringRegExp($8e, $av[$aw][1]) Then
Local $b4 = $b3[$7j] & "\" & $8e
_10k($b4, $av[$aw][0])
EndIf
EndIf
Next
WEnd
Next
EndFunc
Func _10r($av)
Dim $ad
If $ad Then _zl("[I] RemoveUninstallStringWithSearch")
For $43 = 1 To UBound($av) - 1
Local $b4 = _zp($av[$43][1], $av[$43][2], $av[$43][3])
If $b4 And $b4 <> "" Then
_10k($b4, $av[$43][0])
EndIf
Next
EndFunc
Func _10s($av)
Dim $ad
If $ad Then _zl("[I] RemoveAllRegistryKeys")
For $43 = 1 To UBound($av) - 1
_10k($av[$43][1], $av[$43][0], $av[$43][2])
Next
EndFunc
Func _10t()
Local Const $b5 = "frst"
Dim $9v
Dim $9w
Dim $b6
Dim $9y
Dim $b7
Dim $a0
Local Const $ag = "(?i)^Farbar"
Local Const $b8 = "(?i)^FRST.*\.exe$"
Local Const $b9 = "(?i)^FRST-OlderVersion$"
Local Const $ba = "(?i)^(FRST|fixlist|fixlog|Addition|Shortcut).*\.(exe|txt)$"
Local Const $bb = "(?i)^FRST"
Local Const $bc[1][2] = [[$b5, $b8]]
Local Const $bd[1][5] = [[$b5, 'file', $ag, $ba, False]]
Local Const $be[1][5] = [[$b5, 'folder', Null, $b9, False]]
Local Const $bf[1][5] = [[$b5, 'folder', Null, $bb, True]]
_vv($9v, $bc)
_vv($9w, $bd)
_vv($9y, $bd)
_vv($9w, $be)
_vv($9y, $be)
_vv($a0, $bf)
EndFunc
_10t()
Func _10u()
Dim $a6
Dim $a1
Local $b5 = "zhp"
Local Const $8i[1][2] = [[$b5, "(?i)^ZHP$"]]
Local Const $bg[1][5] = [[$b5, 'folder', Null, "(?i)^ZHP$", True]]
_vv($a1, $8i)
_vv($a6, $bg)
EndFunc
_10u()
Func _10v()
Local Const $bh = Null
Local Const $b5 = "zhpdiag"
Dim $9v
Dim $9w
Dim $9x
Dim $9y
Dim $a0
Local Const $b8 = "(?i)^ZHPDiag.*\.exe$"
Local Const $b9 = "(?i)^ZHPDiag.*\.(exe|txt|lnk)$"
Local Const $ba = "(?i)^PhysicalDisk[0-9]_MBR\.bin$"
Local Const $bc[1][2] = [[$b5, $b8]]
Local Const $bd[1][5] = [[$b5, 'file', $bh, $b9, False]]
Local Const $be[1][5] = [[$b5, 'file', Null, $ba, True]]
_vv($9v, $bc)
_vv($9w, $bd)
_vv($9y, $bd)
_vv($9x, $bd)
_vv($a0, $be)
EndFunc
_10v()
Func _10w()
Local Const $bh = Null
Local Const $bi = "zhpfix"
Dim $9v
Dim $9w
Dim $9y
Local Const $b8 = "(?i)^ZHPFix.*\.exe$"
Local Const $b9 = "(?i)^ZHPFix.*\.(exe|txt|lnk)$"
Local Const $bc[1][2] = [[$bi, $b8]]
Local Const $bd[1][5] = [[$bi, 'file', $bh, $b9, False]]
_vv($9v, $bc)
_vv($9w, $bd)
_vv($9y, $bd)
EndFunc
_10w()
Func _10x()
Local Const $bh = Null
Local Const $bi = "zhplite"
Dim $9v
Dim $9w
Dim $9y
Local Const $b8 = "(?i)^ZHPLite.*\.exe$"
Local Const $b9 = "(?i)^ZHPLite.*\.(exe|txt|lnk)$"
Local Const $bc[1][2] = [[$bi, $b8]]
Local Const $bd[1][5] = [[$bi, 'file', $bh, $b9, False]]
_vv($9v, $bc)
_vv($9w, $bd)
_vv($9y, $bd)
EndFunc
_10x()
Func _10y($9b = False)
Local Const $ag = "(?i)^Malwarebytes Anti-Rootkit$"
Local Const $bj = "(?i)^Malwarebytes"
Local Const $b5 = "mbar"
Dim $9v
Dim $9w
Dim $9y
Dim $a1
Local Const $b8 = "(?i)^mbar.*\.exe$"
Local Const $b9 = "(?i)^mbar"
Local Const $bc[1][2] = [[$b5, $b8]]
Local Const $bd[1][2] = [[$b5, $ag]]
Local Const $be[1][5] = [[$b5, 'file', $bj, $b8, False]]
Local Const $bf[1][5] = [[$b5, 'folder', $ag, $b9, False]]
_vv($9v, $bc)
_vv($9w, $be)
_vv($9y, $be)
_vv($9w, $bf)
_vv($9y, $bf)
_vv($a1, $bd)
EndFunc
_10y()
Func _10z()
Local Const $b5 = "roguekiller"
Dim $9v
Dim $a2
Dim $a3
Dim $9z
Dim $a4
Dim $9w
Dim $9x
Dim $a7
Dim $9y
Local $5j = ""
If @OSArch = "X64" Then $5j = "64"
Local Const $bk = "(?i)^Adlice"
Local Const $b8 = "(?i)^RogueKiller"
Local Const $b9 = "(?i)^RogueKiller.*\.(exe|lnk|txt)$"
Local Const $ba = "(?i)^RogueKiller.*\.exe$"
Local Const $bb = "(?i)^RogueKiller_portable(32|64)\.exe$"
Local Const $bc[1][2] = [[$b5, $ba]]
Local Const $bd[1][2] = [[$b5, "RogueKiller Anti-Malware"]]
Local Const $be[1][4] = [[$b5, "HKLM" & $5j & "\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall", $b8, "DisplayName"]]
Local Const $bf[1][5] = [[$b5, 'file', $bk, $b9, False]]
Local Const $bl[1][5] = [[$b5, 'folder', Null, $b8, True]]
Local Const $bm[1][5] = [[$b5, 'file', Null, $bb, False]]
_vv($9v, $bc)
_vv($a2, $bd)
_vv($a3, $be)
_vv($9z, $bl)
_vv($a4, $bl)
_vv($9w, $bm)
_vv($9w, $bf)
_vv($9w, $bl)
_vv($9y, $bm)
_vv($9y, $bf)
_vv($9y, $bl)
_vv($9x, $bf)
_vv($a7, $bl)
EndFunc
_10z()
Func _110()
Local Const $b5 = "adwcleaner"
Local Const $ag = "(?i)^AdwCleaner"
Local Const $bj = "(?i)^Malwarebytes"
Local Const $b8 = "(?i)^AdwCleaner.*\.exe$"
Dim $9v
Dim $9w
Dim $9y
Dim $a0
Local Const $bc[1][2] = [[$b5, $b8]]
Local Const $bd[1][5] = [[$b5, 'file', $bj, $b8, False]]
Local Const $be[1][5] = [[$b5, 'folder', Null, $ag, True]]
_vv($9v, $bc)
_vv($9w, $bd)
_vv($9y, $bd)
_vv($a0, $be)
EndFunc
_110()
Func _111()
Local Const $bh = Null
Local Const $b5 = "zhpcleaner"
Dim $9v
Dim $9w
Dim $9y
Local Const $b8 = "(?i)^ZHPCleaner.*\.exe$"
Local Const $b9 = "(?i)^ZHPCleaner.*\.(exe|txt|lnk)$"
Local Const $bc[1][2] = [[$b5, $b8]]
Local Const $bd[1][5] = [[$b5, 'file', $bh, $b9, False]]
_vv($9v, $bc)
_vv($9w, $bd)
_vv($9y, $bd)
EndFunc
_111()
Func _112()
Local Const $b5 = "usbfix"
Dim $9v
Dim $a9
Dim $9w
Dim $9x
Dim $9y
Dim $a1
Dim $a0
Dim $9z
Local Const $ag = "(?i)^UsbFix"
Local Const $bj = "(?i)^SosVirus"
Local Const $b8 = "(?i)^UsbFix.*\.(exe|lnk|txt)$"
Local Const $b9 = "(?i)^Un-UsbFix\.exe$"
Local Const $ba = "(?i)^UsbFixQuarantine$"
Local Const $bb = "(?i)^UsbFix.*\.exe$"
Local Const $bn[1][2] = [[$b5, $bb]]
Local Const $bc[1][2] = [[$b5, $ag]]
Local Const $bd[1][3] = [[$b5, $ag, $b9]]
Local Const $be[1][5] = [[$b5, 'file', $bj, $b8, False]]
Local Const $bf[1][5] = [[$b5, 'folder', Null, $ba, True]]
Local Const $bl[1][5] = [[$b5, 'folder', Null, $ag, False]]
_vv($9v, $bn)
_vv($a9, $bd)
_vv($9w, $be)
_vv($9x, $be)
_vv($9y, $be)
_vv($a1, $bc)
_vv($a0, $bf)
_vv($a0, $bl)
_vv($9z, $bl)
EndFunc
_112()
Func _113()
Local Const $b5 = "adsfix"
Dim $9v
Dim $9w
Dim $9y
Dim $a0
Dim $9x
Dim $a1
Local Const $ag = "(?i)^AdsFix"
Local Const $bj = "(?i)^SosVirus"
Local Const $b8 = "(?i)^AdsFix.*\.exe$"
Local Const $b9 = "(?i)^AdsFix.*\.(exe|txt|lnk)$"
Local Const $ba = "(?i)^AdsFix.*\.txt$"
Local Const $bc[1][2] = [[$b5, $b8]]
Local Const $bd[1][5] = [[$b5, 'file', $bj, $b9, False]]
Local Const $be[1][5] = [[$b5, 'file', Null, $ba, False]]
Local Const $bf[1][5] = [[$b5, 'folder', Null, $ag, True]]
Local Const $bl[1][2] = [[$b5, $ag]]
_vv($9v, $bc)
_vv($9w, $bd)
_vv($9x, $bd)
_vv($9y, $bd)
_vv($a0, $be)
_vv($a0, $bf)
_vv($a1, $bl)
EndFunc
_113()
Func _114()
Local Const $b5 = "aswmbr"
Dim $9v
Dim $9w
Dim $9y
Dim $aa
Local Const $ag = "(?i)^avast"
Local Const $b8 = "(?i)^aswmbr.*\.(exe|txt|lnk)$"
Local Const $b9 = "(?i)^MBR\.dat$"
Local Const $ba = "(?i)^aswmbr.*\.exe$"
Local $5j = ""
If @OSArch = "X64" Then $5j = "64"
Local Const $bc[1][2] = [[$b5, $ba]]
Local Const $bd[1][5] = [[$b5, 'file', $ag, $b8, False]]
Local Const $be[1][5] = [[$b5, 'file', Null, $b9, False]]
Local Const $bf[1][3] = [[$b5, "HKLM" & $5j & "\SYSTEM\CurrentControlSet\Enum\Root\LEGACY_ASWMBR", True]]
_vv($9v, $bc)
_vv($9w, $bd)
_vv($9w, $be)
_vv($9y, $bd)
_vv($aa, $bf)
EndFunc
_114()
Func _115()
Local Const $b5 = "fss"
Dim $9v
Dim $9w
Dim $9y
Local Const $ag = "(?i)^Farbar"
Local Const $b8 = "(?i)^FSS.*\.(exe|txt|lnk)$"
Local Const $b9 = "(?i)^FSS.*\.exe$"
Local Const $bc[1][2] = [[$b5, $b9]]
Local Const $bd[1][5] = [[$b5, 'file', $ag, $b8, False]]
_vv($9v, $bc)
_vv($9w, $bd)
_vv($9y, $bd)
EndFunc
_115()
Func _116()
Local Const $b5 = "toolsdiag"
Dim $9v
Dim $9w
Dim $9y
Dim $a0
Local Const $b8 = "(?i)^toolsdiag.*\.exe$"
Local Const $b9 = "(?i)^ToolsDiag$"
Local Const $bc[1][5] = [[$b5, 'folder', Null, $b9, False]]
Local Const $bd[1][5] = [[$b5, 'file', Null, $b8, False]]
Local Const $be[1][2] = [[$b5, $b8]]
_vv($9v, $be)
_vv($9w, $bd)
_vv($9y, $bd)
_vv($a0, $bc)
EndFunc
_116()
Func _117()
Local Const $b5 = "scanrapide"
Dim $a0
Dim $9w
Dim $9y
Local Const $ag = Null
Local Const $b8 = "(?i)^ScanRapide.*\.exe$"
Local Const $b9 = "(?i)^ScanRapide\[R[0-9]+\]\.txt$"
Local Const $bc[1][5] = [[$b5, 'file', $ag, $b8, False]]
Local Const $bd[1][5] = [[$b5, 'file', Null, $b9, False]]
_vv($9w, $bc)
_vv($9y, $bc)
_vv($a0, $bd)
EndFunc
_117()
Func _118()
Local Const $b5 = "otl"
Dim $9v
Dim $9w
Dim $9y
Dim $a0
Dim $a1
Local Const $ag = "(?i)^OldTimer"
Local Const $b8 = "(?i)^OTL.*\.exe$"
Local Const $b9 = "(?i)^OTL.*\.(exe|txt)$"
Local Const $ba = "(?i)^Extras\.txt$"
Local Const $bb = "(?i)^_OTL$"
Local Const $bo = "(?i)^OldTimer Tools$"
Local Const $bc[1][2] = [[$b5, $b8]]
Local Const $bd[1][5] = [[$b5, 'file', $ag, $b9, False]]
Local Const $be[1][5] = [[$b5, 'file', Null, $ba, False]]
Local Const $bf[1][5] = [[$b5, 'folder', Null, $bb, True]]
Local Const $bl[1][2] = [[$b5, $bo]]
_vv($9v, $bc)
_vv($9w, $bd)
_vv($9w, $be)
_vv($9y, $bd)
_vv($a0, $bf)
_vv($a1, $bl)
EndFunc
_118()
Func _119()
Local Const $b5 = "otm"
Dim $9v
Dim $9w
Dim $9y
Dim $a0
Local Const $ag = "(?i)^OldTimer"
Local Const $b8 = "(?i)^OTM.*\.exe$"
Local Const $b9 = "(?i)^_OTM$"
Local Const $bc[1][2] = [[$b5, $b8]]
Local Const $bd[1][5] = [[$b5, 'file', $ag, $b8, False]]
Local Const $be[1][5] = [[$b5, 'folder', Null, $b9, True]]
_vv($9v, $bc)
_vv($9w, $bd)
_vv($9y, $bd)
_vv($a0, $be)
EndFunc
_119()
Func _11a()
Local Const $b5 = "listparts"
Dim $9v
Dim $9w
Dim $9y
Dim $a0
Local Const $ag = "(?i)^Farbar"
Local Const $b8 = "(?i)^listParts.*\.exe$"
Local Const $b9 = "(?i)^Results\.txt$"
Local Const $bc[1][2] = [[$b5, $b8]]
Local Const $bd[1][5] = [[$b5, 'file', $ag, $b8, False]]
Local Const $be[1][5] = [[$b5, 'file', Null, $b9, False]]
_vv($9v, $bc)
_vv($9w, $bd)
_vv($9w, $be)
_vv($9y, $bd)
_vv($9y, $be)
EndFunc
_11a()
Func _11b()
Local Const $b5 = "minitoolbox"
Dim $9v
Dim $9w
Dim $9y
Dim $a0
Local Const $ag = "(?i)^Farbar"
Local Const $b8 = "(?i)^MiniToolBox.*\.exe$"
Local Const $b9 = "(?i)^MTB\.txt$"
Local Const $bc[1][2] = [[$b5, $b8]]
Local Const $bd[1][5] = [[$b5, 'file', $ag, $b8, False]]
Local Const $be[1][5] = [[$b5, 'file', Null, $b9, False]]
_vv($9v, $bc)
_vv($9w, $bd)
_vv($9w, $be)
_vv($9y, $bd)
_vv($9y, $be)
EndFunc
_11b()
Func _11c()
Local Const $b5 = "miniregtool"
Dim $9v
Dim $9w
Dim $9y
Dim $a0
Local Const $ag = Null
Local Const $b8 = "(?i)^MiniRegTool.*\.exe$"
Local Const $b9 = "(?i)^MiniRegTool.*\.(exe|zip)$"
Local Const $ba = "(?i)^Result\.txt$"
Local Const $bb = "(?i)^MiniRegTool"
Local Const $bc[1][2] = [[$b5, $b8]]
Local Const $bd[1][5] = [[$b5, 'file', $ag, $b9, False]]
Local Const $be[1][5] = [[$b5, 'file', $ag, $ba, False]]
Local Const $bf[1][5] = [[$b5, 'folder', $ag, $bb, False]]
_vv($9v, $bc)
_vv($9w, $bd)
_vv($9w, $be)
_vv($9w, $bf)
_vv($9y, $bd)
_vv($9y, $be)
_vv($9y, $bf)
EndFunc
_11c()
Func _11d()
Local Const $b5 = "grantperms"
Dim $9v
Dim $9w
Dim $9y
Dim $a0
Local Const $ag = Null
Local Const $b8 = "(?i)^GrantPerms.*\.exe$"
Local Const $b9 = "(?i)^GrantPerms.*\.(exe|zip)$"
Local Const $ba = "(?i)^Perms\.txt$"
Local Const $bb = "(?i)^GrantPerms"
Local Const $bc[1][2] = [[$b5, $b8]]
Local Const $bd[1][5] = [[$b5, 'file', $ag, $b9, False]]
Local Const $be[1][5] = [[$b5, 'file', $ag, $ba, False]]
Local Const $bf[1][5] = [[$b5, 'folder', $ag, $bb, False]]
_vv($9v, $bc)
_vv($9w, $bd)
_vv($9w, $be)
_vv($9w, $bf)
_vv($9y, $bd)
_vv($9y, $be)
_vv($9y, $bf)
EndFunc
_11d()
Func _11e()
Local Const $b5 = "combofix"
Dim $9w
Dim $9y
Dim $a0
Dim $a8
Dim $a1
Dim $9v
Dim $aa
Local Const $ag = "(?i)^Swearware"
Local Const $b8 = "(?i)^Combofix.*\.exe$"
Local Const $b9 = "(?i)^CFScript\.txt$"
Local Const $ba = "(?i)^Qoobox$"
Local Const $bb = "(?i)^Combofix.*\.txt$"
Local Const $bo = "(?i)^(grep|PEV|NIRCMD|MBR|SED|SWREG|SWSC|SWXCACLS|Zip)\.exe$"
Local Const $bp = "(?i)^Swearware$"
Local $5j = ""
If @OSArch = "X64" Then $5j = "64"
Local Const $bc[1][5] = [[$b5, 'file', $ag, $b8, False]]
Local Const $bd[1][5] = [[$b5, 'file', Null, $b9, False]]
Local Const $be[1][5] = [[$b5, 'folder', Null, $ba, True]]
Local Const $bf[1][5] = [[$b5, 'file', Null, $bb, False]]
Local Const $bl[1][5] = [[$b5, 'file', Null, $bo, True]]
Local Const $bm[1][2] = [[$b5, $bp]]
Local Const $bq[1][2] = [[$b5, $b8]]
Local Const $br[1][3] = [[$b5, "HKLM" & $5j & "\SOFTWARE\Microsoft\Windows\CurrentVersion\App Paths\combofix.exe", False]]
_vv($9w, $bc)
_vv($9w, $bd)
_vv($9y, $bc)
_vv($9y, $bd)
_vv($a0, $be)
_vv($a0, $bf)
_vv($a8, $bl)
_vv($a1, $bm)
_vv($9v, $bq)
_vv($aa, $br)
EndFunc
_11e()
Func _11f()
Local Const $b5 = "regtoolexport"
Dim $9v
Dim $9w
Dim $9y
Local Const $ag = Null
Local Const $b8 = "(?i)^regtoolexport.*\.exe$"
Local Const $b9 = "(?i)^Export.*\.reg$"
Local Const $bc[1][2] = [[$b5, $b8]]
Local Const $bd[1][5] = [[$b5, 'file', $ag, $b8, False]]
Local Const $be[1][5] = [[$b5, 'file', $ag, $b9, False]]
_vv($9v, $bc)
_vv($9w, $bd)
_vv($9w, $be)
_vv($9y, $bd)
_vv($9y, $be)
EndFunc
_11f()
Func _11g()
Local Const $b5 = "tdsskiller"
Dim $9v
Dim $9w
Dim $9y
Dim $a0
Local Const $ag = "(?i)^.*Kaspersky"
Local Const $b8 = "(?i)^tdsskiller.*\.exe$"
Local Const $b9 = "(?i)^tdsskiller.*\.(exe|zip)$"
Local Const $ba = "(?i)^TDSSKiller.*_log\.txt$"
Local Const $bb = "(?i)^TDSSKiller"
Local Const $bc[1][2] = [[$b5, $b8]]
Local Const $bd[1][5] = [[$b5, 'file', $ag, $b9, False]]
Local Const $be[1][5] = [[$b5, 'file', Null, $ba, False]]
Local Const $bf[1][5] = [[$b5, 'folder', Null, $bb, False]]
_vv($9v, $bc)
_vv($9w, $bd)
_vv($9w, $bf)
_vv($9y, $bd)
_vv($9y, $bf)
_vv($a0, $be)
_vv($a0, $bf)
EndFunc
_11g()
Func _11h()
Local Const $b5 = "winupdatefix"
Dim $9v
Dim $9w
Dim $9y
Dim $a0
Local Const $ag = Null
Local Const $b8 = "(?i)^winupdatefix.*\.exe$"
Local Const $b9 = "(?i)^winupdatefix.*\.txt$"
Local Const $bc[1][2] = [[$b5, $b8]]
Local Const $bd[1][5] = [[$b5, 'file', $ag, $b8, False]]
Local Const $be[1][5] = [[$b5, 'file', $ag, $b9, False]]
_vv($9v, $bc)
_vv($9w, $bd)
_vv($9y, $bd)
_vv($a0, $be)
EndFunc
_11h()
Func _11i()
Local Const $b5 = "rsthosts"
Dim $9v
Dim $9w
Dim $9y
Dim $a0
Local Const $ag = Null
Local Const $b8 = "(?i)^rsthosts.*\.exe$"
Local Const $b9 = "(?i)^RstHosts.*\.txt$"
Local Const $bc[1][2] = [[$b5, $b8]]
Local Const $bd[1][5] = [[$b5, 'file', $ag, $b8, Null]]
Local Const $be[1][5] = [[$b5, 'file', $ag, $b9, Null]]
_vv($9v, $bc)
_vv($9w, $bd)
_vv($9y, $bd)
_vv($a0, $be)
EndFunc
_11i()
Func _11j()
Local Const $b5 = "winchk"
Dim $9v
Dim $9w
Dim $9y
Dim $a0
Local Const $ag = Null
Local Const $b8 = "(?i)^winchk.*\.exe$"
Local Const $b9 = "(?i)^WinChk.*\.txt$"
Local Const $bc[1][2] = [[$b5, $b8]]
Local Const $bd[1][5] = [[$b5, 'file', $ag, $b8, False]]
Local Const $be[1][5] = [[$b5, 'file', $ag, $b9, False]]
_vv($9v, $bc)
_vv($9w, $bd)
_vv($9y, $bd)
_vv($a0, $be)
EndFunc
_11j()
Func _11k()
Local Const $b5 = "avenger"
Dim $9v
Dim $9w
Dim $9y
Dim $a0
Local Const $ag = Null
Local Const $b8 = "(?i)^avenger.*\.(exe|zip)$"
Local Const $b9 = "(?i)^avenger"
Local Const $ba = "(?i)^avenger.*\.txt$"
Local Const $bb = "(?i)^avenger.*\.exe$"
Local Const $bc[1][2] = [[$b5, $bb]]
Local Const $bd[1][5] = [[$b5, 'file', $ag, $b8, False]]
Local Const $be[1][5] = [[$b5, 'folder', $ag, $b9, False]]
Local Const $bf[1][5] = [[$b5, 'file', $ag, $ba, False]]
_vv($9v, $bc)
_vv($9w, $bd)
_vv($9w, $be)
_vv($9y, $bd)
_vv($9y, $be)
_vv($a0, $be)
_vv($a0, $bf)
EndFunc
_11k()
Func _11l()
Local Const $b5 = "blitzblank"
Dim $9v
Dim $9w
Dim $9y
Dim $a0
Dim $9x
Dim $a1
Local Const $ag = "(?i)^Emsi"
Local Const $b8 = "(?i)^BlitzBlank.*\.exe$"
Local Const $b9 = "(?i)^BlitzBlank.*\.log$"
Local Const $bc[1][2] = [[$b5, $b8]]
Local Const $bd[1][5] = [[$b5, 'file', $ag, $b8, False]]
Local Const $be[1][5] = [[$b5, 'file', Null, $b9, False]]
_vv($9v, $bc)
_vv($9w, $bd)
_vv($9y, $bd)
_vv($a0, $be)
EndFunc
_11l()
Func _11m()
Local Const $b5 = "zoek"
Dim $9v
Dim $9w
Dim $9y
Dim $a0
Dim $9x
Dim $a1
Local Const $ag = Null
Local Const $b8 = "(?i)^zoek.*\.exe$"
Local Const $b9 = "(?i)^zoek.*\.log$"
Local Const $ba = "(?i)^zoek"
Local Const $bb = "(?i)^runcheck.*\.txt$"
Local Const $bc[1][2] = [[$b5, $b8]]
Local Const $bd[1][5] = [[$b5, 'file', $ag, $b8, False]]
Local Const $be[1][5] = [[$b5, 'file', $ag, $b9, False]]
Local Const $bf[1][5] = [[$b5, 'folder', $ag, $ba, True]]
Local Const $bl[1][5] = [[$b5, 'file', $ag, $bb, False]]
_vv($9v, $bc)
_vv($9w, $bd)
_vv($9y, $bd)
_vv($a0, $be)
_vv($a0, $bf)
_vv($a0, $bl)
EndFunc
_11m()
Func _11n()
Local Const $b5 = "remediate-vbs-worm"
Dim $9v
Dim $9w
Dim $9y
Dim $a0
Dim $9x
Dim $a1
Local Const $ag = "(?i).*VBS autorun worms.*"
Local Const $bj = Null
Local Const $b8 = "(?i)^remediate.?vbs.?worm.*\.exe$"
Local Const $b9 = "(?i)^Rem-VBS.*\.log$"
Local Const $ba = "(?i)^Rem-VBS"
Local Const $bb = "(?i)^Rem-VBSworm.*\.exe$"
Local Const $bc[1][2] = [[$b5, $b8]]
Local Const $bd[1][5] = [[$b5, 'file', $bj, $b8, False]]
Local Const $be[1][5] = [[$b5, 'file', $bj, $b9, False]]
Local Const $bf[1][5] = [[$b5, 'folder', $ag, $ba, True]]
Local Const $bl[1][2] = [[$b5, $bb]]
Local Const $bm[1][5] = [[$b5, 'file', $bj, $bb, False]]
_vv($9v, $bc)
_vv($9v, $bl)
_vv($9w, $bd)
_vv($9w, $bm)
_vv($9y, $bd)
_vv($9y, $bm)
_vv($a0, $be)
_vv($a0, $bf)
EndFunc
_11n()
Func _11o()
Local Const $b5 = "ckscanner"
Dim $9v
Dim $9w
Dim $9y
Local Const $ag = Null
Local Const $b8 = "(?i)^CKScanner.*\.exe$"
Local Const $b9 = "(?i)^CKfiles.*\.txt$"
Local Const $bc[1][2] = [[$b5, $b8]]
Local Const $bd[1][5] = [[$b5, 'file', $ag, $b8, False]]
Local Const $be[1][5] = [[$b5, 'file', $ag, $b9, False]]
_vv($9v, $bc)
_vv($9w, $bd)
_vv($9y, $bd)
_vv($9w, $be)
_vv($9y, $be)
EndFunc
_11o()
Func _11p()
Local Const $b5 = "quickdiag"
Dim $9v
Dim $9w
Dim $9y
Dim $a0
Dim $a1
Local Const $ag = "(?i)^SosVirus"
Local Const $b8 = "(?i)^QuickDiag.*\.exe$"
Local Const $b9 = "(?i)^QuickDiag.*\.(exe|txt)$"
Local Const $ba = "(?i)^QuickScript.*\.txt$"
Local Const $bb = "(?i)^QuickDiag.*\.txt$"
Local Const $bo = "(?i)^QuickDiag"
Local Const $bp = "(?i)^g3n-h@ckm@n$"
Local Const $bc[1][2] = [[$b5, $b8]]
Local Const $bd[1][5] = [[$b5, 'file', $ag, $b9, True]]
Local Const $be[1][5] = [[$b5, 'file', Null, $ba, True]]
Local Const $bf[1][5] = [[$b5, 'file', Null, $bb, True]]
Local Const $bl[1][5] = [[$b5, 'folder', Null, $bo, True]]
Local Const $bm[1][2] = [[$b5, $bp]]
_vv($9v, $bc)
_vv($9w, $bd)
_vv($9y, $bd)
_vv($9w, $be)
_vv($9y, $be)
_vv($a0, $bf)
_vv($a0, $bl)
_vv($a1, $bm)
EndFunc
_11p()
Func _11q()
Local Const $b5 = "adlicediag"
Dim $9v
Dim $a3
Dim $9z
Dim $a4
Dim $9w
Dim $9y
Dim $9x
Dim $a7
Local $5j = ""
If @OSArch = "X64" Then $5j = "64"
Local Const $bs = "(?i)^Adlice Diag"
Local Const $b8 = "(?i)^Diag version"
Local Const $b9 = "(?i)^Diag$"
Local Const $ba = "(?i)^ADiag$"
Local Const $bb = "(?i)^Diag_portable(32|64)\.exe$"
Local Const $bo = "(?i)^Diag\.lnk$"
Local Const $bp = "(?i)^Diag_setup\.exe$"
Local Const $bt = "(?i)^Diag(32|64)?\.exe$"
Local Const $bc[1][2] = [[$b5, $bs]]
Local Const $bd[1][4] = [[$b5, "HKLM" & $5j & "\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall", $b8, "DisplayName"]]
Local Const $be[1][5] = [[$b5, 'folder', Null, $b9, True]]
Local Const $bf[1][5] = [[$b5, 'folder', Null, $ba, True]]
Local Const $bl[1][5] = [[$b5, 'file', Null, $bb, False]]
Local Const $bm[1][5] = [[$b5, 'file', Null, $bo, False]]
Local Const $bq[1][5] = [[$b5, 'file', Null, $bp, False]]
Local Const $br[1][2] = [[$b5, $bt]]
_vv($9v, $bc)
_vv($9v, $br)
_vv($a3, $bd)
_vv($9z, $be)
_vv($a4, $bf)
_vv($9w, $bl)
_vv($9w, $bm)
_vv($9w, $bq)
_vv($9y, $bl)
_vv($9y, $bq)
_vv($9x, $bm)
_vv($a7, $be)
EndFunc
_11q()
Func _11r()
Local Const $bh = Null
Local Const $b5 = "rstassociations"
Dim $9v
Dim $9w
Dim $9y
Dim $a0
Local Const $b8 = "(?i)^rstassociations.*\.(exe|scr)$"
Local Const $b9 = "(?i)^RstAssociations.*\.txt$"
Local Const $bc[1][2] = [[$b5, $b8]]
Local Const $bd[1][5] = [[$b5, 'file', $bh, $b8, False]]
Local Const $be[1][5] = [[$b5, 'file', $bh, $b9, False]]
_vv($9v, $bc)
_vv($9w, $bd)
_vv($9y, $bd)
_vv($a0, $be)
EndFunc
_11r()
Func _11s()
Local Const $bh = Null
Local Const $b5 = "sft"
Dim $9v
Dim $9w
Dim $9y
Local Const $b8 = "(?i)^SFT.*\.exe$"
Local Const $b9 = "(?i)^SFT.*\.(txt|exe|zip)$"
Local Const $bc[1][2] = [[$b5, $b8]]
Local Const $bd[1][5] = [[$b5, 'file', $bh, $b9, False]]
_vv($9v, $bc)
_vv($9w, $bd)
_vv($9y, $bd)
EndFunc
_11s()
Func _11t()
Local Const $b5 = "logonfix"
Dim $9v
Dim $9w
Dim $9y
Dim $a0
Local Const $ag = Null
Local Const $b8 = "(?i)^logonfix.*\.exe$"
Local Const $b9 = "(?i)^LogonFix.*\.txt$"
Local Const $bc[1][2] = [[$b5, $b8]]
Local Const $bd[1][5] = [[$b5, 'file', $ag, $b8, False]]
Local Const $be[1][5] = [[$b5, 'file', $ag, $b9, False]]
_vv($9v, $bc)
_vv($9w, $bd)
_vv($9y, $bd)
_vv($a0, $be)
EndFunc
_11t()
Func _11u()
Local Const $b5 = "cmd-command"
Dim $9v
Dim $9w
Dim $9y
Local Const $ag = "(?i)^g3n-h@ckm@n$"
Local Const $b8 = "(?i)^cmd-command.*\.exe$"
Local Const $bc[1][2] = [[$b5, $b8]]
Local Const $bd[1][5] = [[$b5, 'file', $ag, $b8, False]]
_vv($9v, $bc)
_vv($9w, $bd)
_vv($9y, $bd)
EndFunc
_11u()
Func _11v()
Local Const $b5 = "report_chkdsk"
Dim $9v
Dim $9w
Dim $9y
Local Const $ag = Null
Local Const $b8 = "(?i)^Report_CHKDSK.*\.exe$"
Local Const $b9 = "(?i)^RapportCHK.*\.txt$"
Local Const $bc[1][2] = [[$b5, $b8]]
Local Const $bd[1][5] = [[$b5, 'file', $ag, $b8, False]]
Local Const $be[1][5] = [[$b5, 'file', $ag, $b9, False]]
_vv($9v, $bc)
_vv($9w, $bd)
_vv($9w, $be)
_vv($9y, $bd)
_vv($9y, $be)
EndFunc
_11v()
Func _11w()
Local Const $b5 = "seaf"
Dim $9v
Dim $9w
Dim $9y
Dim $a9
Dim $aa
Dim $a0
Dim $9z
Local Const $ag = "(?i)^C_XX$"
Local Const $bu = "(?i)^SEAF$"
Local Const $b8 = "(?i)^seaf.*\.exe$"
Local Const $b9 = "(?i)^Un-SEAF\.exe$"
Local Const $ba = "(?i)^SeafLog.*\.txt$"
Local $5j = ""
If @OSArch = "X64" Then $5j = "64"
Local Const $bc[1][2] = [[$b5, $b8]]
Local Const $bd[1][5] = [[$b5, 'file', $ag, $b8, False]]
Local Const $be[1][3] = [[$b5, $bu, $b9]]
Local Const $bf[1][3] = [[$b5, "HKLM" & $5j & "\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\SEAF", False]]
Local Const $bl[1][5] = [[$b5, 'file', Null, $ba, False]]
Local Const $bm[1][5] = [[$b5, 'folder', Null, $bu, True]]
_vv($9v, $bc)
_vv($9w, $bd)
_vv($9y, $bd)
_vv($a9, $be)
_vv($aa, $bf)
_vv($a0, $bl)
_vv($9z, $bm)
EndFunc
_11w()
Func _11x()
Local $5j = ""
If @OSArch = "X64" Then $5j = "64"
If FileExists(@AppDataCommonDir & "\Malwarebytes\Malwarebytes' Anti-Malware\Quarantine") Then
Local $bv = _x1(@AppDataCommonDir & "\Malwarebytes\Malwarebytes' Anti-Malware\Quarantine")
If @error = 0 Then
For $43 = 1 To $bv[0]
_10g(@AppDataCommonDir & "\Malwarebytes\Malwarebytes' Anti-Malware\Quarantine" & '\' & $bv[$43], "mbar", Null, True)
Next
EndIf
EndIf
EndFunc
Func _11y($9b = False)
If $9b = True Then
_zl(@CRLF & "- Search Tools -" & @CRLF)
EndIf
_10m($9v)
_104()
_10o($a9)
_104()
_10n($a2)
_104()
_10j(@DesktopDir, $9w)
_104()
_10j(@DesktopCommonDir, $9x)
_104()
If FileExists(@UserProfileDir & "\Downloads") Then
_10j(@UserProfileDir & "\Downloads", $9y)
_104()
Else
_104()
EndIf
_10p($9z)
_104()
_10j(@HomeDrive, $a0)
_104()
_10j(@AppDataDir, $a5)
_104()
_10j(@AppDataCommonDir, $a4)
_104()
_10j(@LocalAppDataDir, $a6)
_104()
_10j(@WindowsDir, $a8)
_104()
_10q($a1)
_104()
_10s($aa)
_104()
_10r($a3)
_104()
_10j(@AppDataCommonDir & "\Microsoft\Windows\Start Menu\Programs", $a7)
_104()
_11x()
_104()
If $9b = True Then
Local $bw = False
Local Const $bx[4] = ["process", "uninstall", "element", "key"]
Local Const $by = "Warning, folder " & @AppDataDir & "\ZHP exists and contains the quarantines of the ZHP tools. At the request of the publisher (Nicolas Coolman) this folder is not deleted. "
Local $bz = False
Local Const $c0 = _zt(@AppDataDir & "\ZHP")
For $c1 In $8o
Local $c2 = $8o.Item($c1)
Local $c3 = False
For $c4 = 0 To UBound($bx) - 1
Local $c5 = $bx[$c4]
Local $c6 = $c2.Item($c5)
Local $c7 = $c6.Keys
If UBound($c7) > 0 Then
If $c3 = False Then
$c3 = True
$bw = True
_zl(@CRLF & "  ## " & StringUpper($c1) & " found")
EndIf
For $c8 = 0 To UBound($c7) - 1
Local $c9 = $c7[$c8]
Local $ca = $c6.Item($c9)
_103($c5, $c9, $ca)
Next
If $c1 = "zhp" And $c0 = True Then
_zl("     [!] " & $by)
$bz = True
EndIf
EndIf
Next
Next
If $bz = False And $c0 = True Then
_zl(@CRLF & "  ## " & StringUpper("zhp") & " found")
_zl("     [!] " & $by)
ElseIf $bw = False Then
_zl("  [I] No tools found")
EndIf
EndIf
_104()
EndFunc
FileInstall("C:\Users\IEUser\Desktop\kpRemover\src\assets\bug.gif", @TempDir & "\kprm-logo.gif")
Global $9h = "KpRm"
Global $ad = False
Global $7z = "kprm-" & @YEAR & @MON & @MDAY & @HOUR & @MIN & ".txt"
Local Const $cb = GUICreate($9h, 500, 195, 202, 112)
Local Const $cc = GUICtrlCreateGroup("Actions", 8, 8, 400, 153)
Local Const $cd = GUICtrlCreateCheckbox($50, 16, 40, 129, 17)
Local Const $ce = GUICtrlCreateCheckbox($51, 16, 80, 190, 17)
Local Const $cf = GUICtrlCreateCheckbox($52, 16, 120, 190, 17)
Local Const $cg = GUICtrlCreateCheckbox($53, 220, 40, 137, 17)
Local Const $ch = GUICtrlCreateCheckbox($54, 220, 80, 137, 17)
Local Const $ci = GUICtrlCreateCheckbox($55, 220, 120, 180, 17)
Global $93 = GUICtrlCreateProgress(8, 170, 480, 17)
GUICtrlCreateGroup("", -99, -99, 1, 1)
GUICtrlSetState($cd, 1)
Local Const $cj = GUICtrlCreatePic(@TempDir & "\kprm-logo.gif", 415, 16, 76, 76)
Local Const $ck = GUICtrlCreateButton($56, 415, 120, 75, 40)
GUISetState(@SW_SHOW)
While 1
Local $cl = GUIGetMsg()
Switch $cl
Case $0
Exit
Case $ck
_121()
EndSwitch
WEnd
Func _11z()
Local Const $cm = @HomeDrive & "\KPRM"
If Not FileExists($cm) Then
DirCreate($cm)
EndIf
If Not FileExists($cm) Then
MsgBox(16, $58, $59)
Exit
EndIf
EndFunc
Func _120()
_11z()
_zl("#################################################################################################################" & @CRLF)
_zl("# Run at " & _3o())
_zl("# KpRm (Kernel-panik) version " & $4y)
_zl("# Website https://kernel-panik.me/tool/kprm/")
_zl("# Run by " & @UserName & " from " & @WorkingDir)
_zl("# Computer Name: " & @ComputerName)
_zl("# OS: " & _zv() & " " & @OSArch & " (" & @OSBuild & ") " & @OSServicePack)
_105()
EndFunc
Func _121()
_120()
_104()
If GUICtrlRead($cg) = $1 Then
_10c()
EndIf
_104()
If GUICtrlRead($cd) = $1 Then
_11y()
_11y(True)
Else
_104(32)
EndIf
_104()
If GUICtrlRead($ci) = $1 Then
_10e()
EndIf
_104()
If GUICtrlRead($ch) = $1 Then
_10d()
EndIf
_104()
If GUICtrlRead($ce) = $1 Then
_106()
EndIf
_104()
If GUICtrlRead($cf) = $1 Then
_10b()
EndIf
GUICtrlSetData($93, 100)
MsgBox(64, "OK", $57)
_zi(True)
EndFunc
