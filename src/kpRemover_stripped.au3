#RequireAdmin
Global Const $0 = -3
Global Const $1 = 1
Global Const $2 = 0x00040000
Global Const $3 = 1
Global Const $4 = 2
Global Const $5 = 0x00020000
Global Const $6 = 0x00040000
Global Const $7 = 0x00080000
Global Const $8 = 0x01000000
Global Enum $9 = 0, $a, $b, $c, $d, $e, $f
Global Const $g = 2
Global Const $h = 1
Global Const $i = 2
Global Const $j = 1
Global Const $k = 2
Global Const $l = 1
Global Const $m = "struct;word Year;word Month;word Dow;word Day;word Hour;word Minute;word Second;word MSeconds;endstruct"
Global Const $n = 0
Global Const $o = 1
Global Const $p = 2
Global Const $q= 1
Global Const $r = 0x10000000
Global Const $s = 0
Global Const $t = 0
Global Const $u = 4
Global Const $v = 8
Global Const $w = 16
Global Const $x = 0
Global Const $y = 0
Global Const $0z = 1
Global Const $10 = 2
Global Const $11 = 0
Global Const $12 = 1
Global Const $13 = 2
Global Const $14 = 3
Global Const $15 = 4
Global Const $16 = 'struct;dword OSVersionInfoSize;dword MajorVersion;dword MinorVersion;dword BuildNumber;dword PlatformId;wchar CSDVersion[128];endstruct'
Global Const $17 = _1v()
Func _1v()
Local $18 = DllStructCreate($16)
DllStructSetData($18, 1, DllStructGetSize($18))
Local $19 = DllCall('kernel32.dll', 'bool', 'GetVersionExW', 'struct*', $18)
If @error Or Not $19[0] Then Return SetError(@error, @extended, 0)
Return BitOR(BitShift(DllStructGetData($18, 2), -8), DllStructGetData($18, 3))
EndFunc
Global Const $1a = 0x001D
Global Const $1b = 0x001E
Global Const $1c = 0x001F
Global Const $1d = 0x0020
Global Const $1e = 0x1003
Global Const $1f = 0x0028
Global Const $1g = 0x0029
Global Const $1h = 0x007F
Global Const $1i = 0x0400
Func _2e($1j = 0, $1k = 0, $1l = 0, $1m = '')
If Not $1j Then $1j = 0x0400
Local $1n = 'wstr'
If Not StringStripWS($1m, $h + $i) Then
$1n = 'ptr'
$1m = 0
EndIf
Local $19 = DllCall('kernel32.dll', 'int', 'GetDateFormatW', 'dword', $1j, 'dword', $1l, 'struct*', $1k, $1n, $1m, 'wstr', '', 'int', 2048)
If @error Or Not $19[0] Then Return SetError(@error, @extended, '')
Return $19[5]
EndFunc
Func _2h($1j, $1o)
Local $19 = DllCall('kernel32.dll', 'int', 'GetLocaleInfoW', 'dword', $1j, 'dword', $1o, 'wstr', '', 'int', 2048)
If @error Or Not $19[0] Then Return SetError(@error + 10, @extended, '')
Return $19[3]
EndFunc
Func _31($1p, $1q, $1r)
Local $1s[4]
Local $1t[4]
Local $1u
$1p = StringLeft($1p, 1)
If StringInStr("D,M,Y,w,h,n,s", $1p) = 0 Or $1p = "" Then
Return SetError(1, 0, 0)
EndIf
If Not StringIsInt($1q) Then
Return SetError(2, 0, 0)
EndIf
If Not _37($1r) Then
Return SetError(3, 0, 0)
EndIf
_3g($1r, $1t, $1s)
If $1p = "d" Or $1p = "w" Then
If $1p = "w" Then $1q = $1q * 7
$1u = _3j($1t[1], $1t[2], $1t[3]) + $1q
_3l($1u, $1t[1], $1t[2], $1t[3])
EndIf
If $1p = "m" Then
$1t[2] = $1t[2] + $1q
While $1t[2] > 12
$1t[2] = $1t[2] - 12
$1t[1] = $1t[1] + 1
WEnd
While $1t[2] < 1
$1t[2] = $1t[2] + 12
$1t[1] = $1t[1] - 1
WEnd
EndIf
If $1p = "y" Then
$1t[1] = $1t[1] + $1q
EndIf
If $1p = "h" Or $1p = "n" Or $1p = "s" Then
Local $1v = _3w($1s[1], $1s[2], $1s[3]) / 1000
If $1p = "h" Then $1v = $1v + $1q * 3600
If $1p = "n" Then $1v = $1v + $1q * 60
If $1p = "s" Then $1v = $1v + $1q
Local $1w = Int($1v /(24 * 60 * 60))
$1v = $1v - $1w * 24 * 60 * 60
If $1v < 0 Then
$1w = $1w - 1
$1v = $1v + 24 * 60 * 60
EndIf
$1u = _3j($1t[1], $1t[2], $1t[3]) + $1w
_3l($1u, $1t[1], $1t[2], $1t[3])
_3v($1v * 1000, $1s[1], $1s[2], $1s[3])
EndIf
Local $1x = _3z($1t[1])
If $1x[$1t[2]] < $1t[3] Then $1t[3] = $1x[$1t[2]]
$1r = $1t[1] & '/' & StringRight("0" & $1t[2], 2) & '/' & StringRight("0" & $1t[3], 2)
If $1s[0] > 0 Then
If $1s[0] > 2 Then
$1r = $1r & " " & StringRight("0" & $1s[1], 2) & ':' & StringRight("0" & $1s[2], 2) & ':' & StringRight("0" & $1s[3], 2)
Else
$1r = $1r & " " & StringRight("0" & $1s[1], 2) & ':' & StringRight("0" & $1s[2], 2)
EndIf
EndIf
Return $1r
EndFunc
Func _32($1y, $1z = Default)
Local Const $20 = 128
If $1z = Default Then $1z = 0
$1y = Int($1y)
If $1y < 1 Or $1y > 7 Then Return SetError(1, 0, "")
Local $1k = DllStructCreate($m)
DllStructSetData($1k, "Year", BitAND($1z, $20) ? 2007 : 2006)
DllStructSetData($1k, "Month", 1)
DllStructSetData($1k, "Day", $1y)
Return _2e(BitAND($1z, $4) ? $1i : $1h, $1k, 0, BitAND($1z, $3) ? "ddd" : "dddd")
EndFunc
Func _35($21)
If StringIsInt($21) Then
Select
Case Mod($21, 4) = 0 And Mod($21, 100) <> 0
Return 1
Case Mod($21, 400) = 0
Return 1
Case Else
Return 0
EndSelect
EndIf
Return SetError(1, 0, 0)
EndFunc
Func _36($1q)
$1q = Int($1q)
Return $1q >= 1 And $1q <= 12
EndFunc
Func _37($1r)
Local $1t[4], $1s[4]
_3g($1r, $1t, $1s)
If Not StringIsInt($1t[1]) Then Return 0
If Not StringIsInt($1t[2]) Then Return 0
If Not StringIsInt($1t[3]) Then Return 0
$1t[1] = Int($1t[1])
$1t[2] = Int($1t[2])
$1t[3] = Int($1t[3])
Local $1x = _3z($1t[1])
If $1t[1] < 1000 Or $1t[1] > 2999 Then Return 0
If $1t[2] < 1 Or $1t[2] > 12 Then Return 0
If $1t[3] < 1 Or $1t[3] > $1x[$1t[2]] Then Return 0
If $1s[0] < 1 Then Return 1
If $1s[0] < 2 Then Return 0
If $1s[0] = 2 Then $1s[3] = "00"
If Not StringIsInt($1s[1]) Then Return 0
If Not StringIsInt($1s[2]) Then Return 0
If Not StringIsInt($1s[3]) Then Return 0
$1s[1] = Int($1s[1])
$1s[2] = Int($1s[2])
$1s[3] = Int($1s[3])
If $1s[1] < 0 Or $1s[1] > 23 Then Return 0
If $1s[2] < 0 Or $1s[2] > 59 Then Return 0
If $1s[3] < 0 Or $1s[3] > 59 Then Return 0
Return 1
EndFunc
Func _3f($1r, $1p)
Local $1t[4], $1s[4]
Local $22 = "", $23 = ""
Local $24, $25, $26 = ""
If Not _37($1r) Then
Return SetError(1, 0, "")
EndIf
If $1p < 0 Or $1p > 5 Or Not IsInt($1p) Then
Return SetError(2, 0, "")
EndIf
_3g($1r, $1t, $1s)
Switch $1p
Case 0
$26 = _2h($1i, $1c)
If Not @error And Not($26 = '') Then
$22 = $26
Else
$22 = "M/d/yyyy"
EndIf
If $1s[0] > 1 Then
$26 = _2h($1i, $1e)
If Not @error And Not($26 = '') Then
$23 = $26
Else
$23 = "h:mm:ss tt"
EndIf
EndIf
Case 1
$26 = _2h($1i, $1d)
If Not @error And Not($26 = '') Then
$22 = $26
Else
$22 = "dddd, MMMM dd, yyyy"
EndIf
Case 2
$26 = _2h($1i, $1c)
If Not @error And Not($26 = '') Then
$22 = $26
Else
$22 = "M/d/yyyy"
EndIf
Case 3
If $1s[0] > 1 Then
$26 = _2h($1i, $1e)
If Not @error And Not($26 = '') Then
$23 = $26
Else
$23 = "h:mm:ss tt"
EndIf
EndIf
Case 4
If $1s[0] > 1 Then
$23 = "hh:mm"
EndIf
Case 5
If $1s[0] > 1 Then
$23 = "hh:mm:ss"
EndIf
EndSwitch
If $22 <> "" Then
$26 = _2h($1i, $1a)
If Not @error And Not($26 = '') Then
$22 = StringReplace($22, "/", $26)
EndIf
Local $27 = _3h($1t[1], $1t[2], $1t[3])
$1t[3] = StringRight("0" & $1t[3], 2)
$1t[2] = StringRight("0" & $1t[2], 2)
$22 = StringReplace($22, "d", "@")
$22 = StringReplace($22, "m", "#")
$22 = StringReplace($22, "y", "&")
$22 = StringReplace($22, "@@@@", _32($27, 0))
$22 = StringReplace($22, "@@@", _32($27, 1))
$22 = StringReplace($22, "@@", $1t[3])
$22 = StringReplace($22, "@", StringReplace(StringLeft($1t[3], 1), "0", "") & StringRight($1t[3], 1))
$22 = StringReplace($22, "####", _3k($1t[2], 0))
$22 = StringReplace($22, "###", _3k($1t[2], 1))
$22 = StringReplace($22, "##", $1t[2])
$22 = StringReplace($22, "#", StringReplace(StringLeft($1t[2], 1), "0", "") & StringRight($1t[2], 1))
$22 = StringReplace($22, "&&&&", $1t[1])
$22 = StringReplace($22, "&&", StringRight($1t[1], 2))
EndIf
If $23 <> "" Then
$26 = _2h($1i, $1f)
If Not @error And Not($26 = '') Then
$24 = $26
Else
$24 = "AM"
EndIf
$26 = _2h($1i, $1g)
If Not @error And Not($26 = '') Then
$25 = $26
Else
$25 = "PM"
EndIf
$26 = _2h($1i, $1b)
If Not @error And Not($26 = '') Then
$23 = StringReplace($23, ":", $26)
EndIf
If StringInStr($23, "tt") Then
If $1s[1] < 12 Then
$23 = StringReplace($23, "tt", $24)
If $1s[1] = 0 Then $1s[1] = 12
Else
$23 = StringReplace($23, "tt", $25)
If $1s[1] > 12 Then $1s[1] = $1s[1] - 12
EndIf
EndIf
$1s[1] = StringRight("0" & $1s[1], 2)
$1s[2] = StringRight("0" & $1s[2], 2)
$1s[3] = StringRight("0" & $1s[3], 2)
$23 = StringReplace($23, "hh", StringFormat("%02d", $1s[1]))
$23 = StringReplace($23, "h", StringReplace(StringLeft($1s[1], 1), "0", "") & StringRight($1s[1], 1))
$23 = StringReplace($23, "mm", StringFormat("%02d", $1s[2]))
$23 = StringReplace($23, "ss", StringFormat("%02d", $1s[3]))
$22 = StringStripWS($22 & " " & $23, $h + $i)
EndIf
Return $22
EndFunc
Func _3g($1r, ByRef $28, ByRef $29)
Local $2a = StringSplit($1r, " T")
If $2a[0] > 0 Then $28 = StringSplit($2a[1], "/-.")
If $2a[0] > 1 Then
$29 = StringSplit($2a[2], ":")
If UBound($29) < 4 Then ReDim $29[4]
Else
Dim $29[4]
EndIf
If UBound($28) < 4 Then ReDim $28[4]
For $2b = 1 To 3
If StringIsInt($28[$2b]) Then
$28[$2b] = Int($28[$2b])
Else
$28[$2b] = -1
EndIf
If StringIsInt($29[$2b]) Then
$29[$2b] = Int($29[$2b])
Else
$29[$2b] = 0
EndIf
Next
Return 1
EndFunc
Func _3h($21, $2c, $2d)
If Not _37($21 & "/" & $2c & "/" & $2d) Then
Return SetError(1, 0, "")
EndIf
Local $2e = Int((14 - $2c) / 12)
Local $2f = $21 - $2e
Local $2g = $2c +(12 * $2e) - 2
Local $2h = Mod($2d + $2f + Int($2f / 4) - Int($2f / 100) + Int($2f / 400) + Int((31 * $2g) / 12), 7)
Return $2h + 1
EndFunc
Func _3j($21, $2c, $2d)
If Not _37(StringFormat("%04d/%02d/%02d", $21, $2c, $2d)) Then
Return SetError(1, 0, "")
EndIf
If $2c < 3 Then
$2c = $2c + 12
$21 = $21 - 1
EndIf
Local $2e = Int($21 / 100)
Local $2i = Int($2e / 4)
Local $2j = 2 - $2e + $2i
Local $2k = Int(1461 *($21 + 4716) / 4)
Local $2l = Int(153 *($2c + 1) / 5)
Local $1u = $2j + $2d + $2k + $2l - 1524.5
Return $1u
EndFunc
Func _3k($2m, $1z = Default)
If $1z = Default Then $1z = 0
$2m = Int($2m)
If Not _36($2m) Then Return SetError(1, 0, "")
Local $1k = DllStructCreate($m)
DllStructSetData($1k, "Year", @YEAR)
DllStructSetData($1k, "Month", $2m)
DllStructSetData($1k, "Day", 1)
Return _2e(BitAND($1z, $4) ? $1i : $1h, $1k, 0, BitAND($1z, $3) ? "MMM" : "MMMM")
EndFunc
Func _3l($1u, ByRef $21, ByRef $2c, ByRef $2d)
If $1u < 0 Or Not IsNumber($1u) Then
Return SetError(1, 0, 0)
EndIf
Local $2n = Int($1u + 0.5)
Local $2o = Int(($2n - 1867216.25) / 36524.25)
Local $2p = Int($2o / 4)
Local $2e = $2n + 1 + $2o - $2p
Local $2i = $2e + 1524
Local $2j = Int(($2i - 122.1) / 365.25)
Local $2h = Int(365.25 * $2j)
Local $2k = Int(($2i - $2h) / 30.6001)
Local $2l = Int(30.6001 * $2k)
$2d = $2i - $2h - $2l
If $2k - 1 < 13 Then
$2c = $2k - 1
Else
$2c = $2k - 13
EndIf
If $2c < 3 Then
$21 = $2j - 4715
Else
$21 = $2j - 4716
EndIf
$21 = StringFormat("%04d", $21)
$2c = StringFormat("%02d", $2c)
$2d = StringFormat("%02d", $2d)
Return $21 & "/" & $2c & "/" & $2d
EndFunc
Func _3o()
Return _3f(@YEAR & "/" & @MON & "/" & @MDAY & " " & @HOUR & ":" & @MIN & ":" & @SEC, 0)
EndFunc
Func _3p()
Return @YEAR & "/" & @MON & "/" & @MDAY & " " & @HOUR & ":" & @MIN & ":" & @SEC
EndFunc
Func _3v($2q, ByRef $2r, ByRef $2s, ByRef $2t)
If Number($2q) > 0 Then
$2q = Int($2q / 1000)
$2r = Int($2q / 3600)
$2q = Mod($2q, 3600)
$2s = Int($2q / 60)
$2t = Mod($2q, 60)
Return 1
ElseIf Number($2q) = 0 Then
$2r = 0
$2q = 0
$2s = 0
$2t = 0
Return 1
Else
Return SetError(1, 0, 0)
EndIf
EndFunc
Func _3w($2r = @HOUR, $2s = @MIN, $2t = @SEC)
If StringIsInt($2r) And StringIsInt($2s) And StringIsInt($2t) Then
Local $2q = 1000 *((3600 * $2r) +(60 * $2s) + $2t)
Return $2q
Else
Return SetError(1, 0, 0)
EndIf
EndFunc
Func _3z($21)
Local $2u = [12, 31,(_35($21) ? 29 : 28), 31, 30, 31, 30, 31, 31, 30, 31, 30, 31]
Return $2u
EndFunc
Func _51($2v, $2w, $2x = 0, $2y = 0, $2z = 0, $30 = "wparam", $31 = "lparam", $32 = "lresult")
Local $33 = DllCall("user32.dll", $32, "SendMessageW", "hwnd", $2v, "uint", $2w, $30, $2x, $31, $2y)
If @error Then Return SetError(@error, @extended, "")
If $2z >= 0 And $2z <= 4 Then Return $33[$2z]
Return $33
EndFunc
Global Const $34 = Ptr(-1)
Global Const $35 = Ptr(-1)
Global Const $36 = 0x0100
Global Const $37 = 0x2000
Global Const $38 = 0x8000
Global Const $39 = BitShift($36, 8)
Global Const $3a = BitShift($37, 8)
Global Const $3b = BitShift($38, 8)
Global Const $3c = 0x8000000
Func _d0($3d, $3e)
Local $33 = DllCall("user32.dll", "hwnd", "FindWindowW", "wstr", $3d, "wstr", $3e)
If @error Then Return SetError(@error, @extended, 0)
Return $33[0]
EndFunc
Func _hf($3f, $1l, $3g = 0, $3h = 0)
Local $3i = 'dword_ptr', $3j = 'dword_ptr'
If IsString($3g) Then
$3i = 'wstr'
EndIf
If IsString($3h) Then
$3j = 'wstr'
EndIf
DllCall('shell32.dll', 'none', 'SHChangeNotify', 'long', $3f, 'uint', $1l, $3i, $3g, $3j, $3h)
If @error Then Return SetError(@error, @extended, 0)
Return 1
EndFunc
Global Const $3k = 11
Global $3l[$3k]
Global Const $3m = "struct;uint Mask;int Item;int SubItem;uint State;uint StateMask;ptr Text;int TextMax;int Image;lparam Param;" & "int Indent;int GroupID;uint Columns;ptr pColumns;ptr piColFmt;int iGroup;endstruct"
#Au3Stripper_Ignore_Funcs=__ArrayDisplay_SortCallBack
Func __ArrayDisplay_SortCallBack($3n, $3o, $2v)
If $3l[3] = $3l[4] Then
If Not $3l[7] Then
$3l[5] *= -1
$3l[7] = 1
EndIf
Else
$3l[7] = 1
EndIf
$3l[6] = $3l[3]
Local $3p = _vr($2v, $3n, $3l[3])
Local $3q = _vr($2v, $3o, $3l[3])
If $3l[8] = 1 Then
If(StringIsFloat($3p) Or StringIsInt($3p)) Then $3p = Number($3p)
If(StringIsFloat($3q) Or StringIsInt($3q)) Then $3q = Number($3q)
EndIf
Local $3r
If $3l[8] < 2 Then
$3r = 0
If $3p < $3q Then
$3r = -1
ElseIf $3p > $3q Then
$3r = 1
EndIf
Else
$3r = DllCall('shlwapi.dll', 'int', 'StrCmpLogicalW', 'wstr', $3p, 'wstr', $3q)[0]
EndIf
$3r = $3r * $3l[5]
Return $3r
EndFunc
Func _vr($2v, $3s, $3t = 0)
Local $3u = DllStructCreate("wchar Text[4096]")
Local $3v = DllStructGetPtr($3u)
Local $3w = DllStructCreate($3m)
DllStructSetData($3w, "SubItem", $3t)
DllStructSetData($3w, "TextMax", 4096)
DllStructSetData($3w, "Text", $3v)
If IsHWnd($2v) Then
DllCall("user32.dll", "lresult", "SendMessageW", "hwnd", $2v, "uint", 0x1073, "wparam", $3s, "struct*", $3w)
Else
Local $3x = DllStructGetPtr($3w)
GUICtrlSendMsg($2v, 0x1073, $3s, $3x)
EndIf
Return DllStructGetData($3u, "Text")
EndFunc
Global Enum $3y, $3z, $40, $41, $42, $43, $44, $45
Func _vv(ByRef $46, $47, $48 = 0, $49 = "|", $4a = @CRLF, $4b = $3y)
If $48 = Default Then $48 = 0
If $49 = Default Then $49 = "|"
If $4a = Default Then $4a = @CRLF
If $4b = Default Then $4b = $3y
If Not IsArray($46) Then Return SetError(1, 0, -1)
Local $4c = UBound($46, $o)
Local $4d = 0
Switch $4b
Case $40
$4d = Int
Case $41
$4d = Number
Case $42
$4d = Ptr
Case $43
$4d = Hwnd
Case $44
$4d = String
Case $45
$4d = "Boolean"
EndSwitch
Switch UBound($46, $n)
Case 1
If $4b = $3z Then
ReDim $46[$4c + 1]
$46[$4c] = $47
Return $4c
EndIf
If IsArray($47) Then
If UBound($47, $n) <> 1 Then Return SetError(5, 0, -1)
$4d = 0
Else
Local $4e = StringSplit($47, $49, $k + $j)
If UBound($4e, $o) = 1 Then
$4e[0] = $47
EndIf
$47 = $4e
EndIf
Local $4f = UBound($47, $o)
ReDim $46[$4c + $4f]
For $4g = 0 To $4f - 1
If String($4d) = "Boolean" Then
Switch $47[$4g]
Case "True", "1"
$46[$4c + $4g] = True
Case "False", "0", ""
$46[$4c + $4g] = False
EndSwitch
ElseIf IsFunc($4d) Then
$46[$4c + $4g] = $4d($47[$4g])
Else
$46[$4c + $4g] = $47[$4g]
EndIf
Next
Return $4c + $4f - 1
Case 2
Local $4h = UBound($46, $p)
If $48 < 0 Or $48 > $4h - 1 Then Return SetError(4, 0, -1)
Local $4i, $4j = 0, $4k
If IsArray($47) Then
If UBound($47, $n) <> 2 Then Return SetError(5, 0, -1)
$4i = UBound($47, $o)
$4j = UBound($47, $p)
$4d = 0
Else
Local $4l = StringSplit($47, $4a, $k + $j)
$4i = UBound($4l, $o)
Local $4e[$4i][0], $4m
For $4g = 0 To $4i - 1
$4m = StringSplit($4l[$4g], $49, $k + $j)
$4k = UBound($4m)
If $4k > $4j Then
$4j = $4k
ReDim $4e[$4i][$4j]
EndIf
For $4n = 0 To $4k - 1
$4e[$4g][$4n] = $4m[$4n]
Next
Next
$47 = $4e
EndIf
If UBound($47, $p) + $48 > UBound($46, $p) Then Return SetError(3, 0, -1)
ReDim $46[$4c + $4i][$4h]
For $4o = 0 To $4i - 1
For $4n = 0 To $4h - 1
If $4n < $48 Then
$46[$4o + $4c][$4n] = ""
ElseIf $4n - $48 > $4j - 1 Then
$46[$4o + $4c][$4n] = ""
Else
If String($4d) = "Boolean" Then
Switch $47[$4o][$4n - $48]
Case "True", "1"
$46[$4o + $4c][$4n] = True
Case "False", "0", ""
$46[$4o + $4c][$4n] = False
EndSwitch
ElseIf IsFunc($4d) Then
$46[$4o + $4c][$4n] = $4d($47[$4o][$4n - $48])
Else
$46[$4o + $4c][$4n] = $47[$4o][$4n - $48]
EndIf
EndIf
Next
Next
Case Else
Return SetError(2, 0, -1)
EndSwitch
Return UBound($46, $o) - 1
EndFunc
Func _w0(ByRef $4p, Const ByRef $4q, $48 = 0)
If $48 = Default Then $48 = 0
If Not IsArray($4p) Then Return SetError(1, 0, -1)
If Not IsArray($4q) Then Return SetError(2, 0, -1)
Local $4r = UBound($4p, $n)
Local $4s = UBound($4q, $n)
Local $4t = UBound($4p, $o)
Local $4u = UBound($4q, $o)
If $48 < 0 Or $48 > $4u - 1 Then Return SetError(6, 0, -1)
Switch $4r
Case 1
If $4s <> 1 Then Return SetError(4, 0, -1)
ReDim $4p[$4t + $4u - $48]
For $4g = $48 To $4u - 1
$4p[$4t + $4g - $48] = $4q[$4g]
Next
Case 2
If $4s <> 2 Then Return SetError(4, 0, -1)
Local $4v = UBound($4p, $p)
If UBound($4q, $p) <> $4v Then Return SetError(5, 0, -1)
ReDim $4p[$4t + $4u - $48][$4v]
For $4g = $48 To $4u - 1
For $4n = 0 To $4v - 1
$4p[$4t + $4g - $48][$4n] = $4q[$4g][$4n]
Next
Next
Case Else
Return SetError(3, 0, -1)
EndSwitch
Return UBound($4p, $o)
EndFunc
Func _we(Const ByRef $46, $47, $48 = 0, $4w = 0, $4x = 0, $4y = 0, $4z = 1, $3t = -1, $50 = False)
If $48 = Default Then $48 = 0
If $4w = Default Then $4w = 0
If $4x = Default Then $4x = 0
If $4y = Default Then $4y = 0
If $4z = Default Then $4z = 1
If $3t = Default Then $3t = -1
If $50 = Default Then $50 = False
If Not IsArray($46) Then Return SetError(1, 0, -1)
Local $4c = UBound($46) - 1
If $4c = -1 Then Return SetError(3, 0, -1)
Local $4h = UBound($46, $p) - 1
Local $51 = False
If $4y = 2 Then
$4y = 0
$51 = True
EndIf
If $50 Then
If UBound($46, $n) = 1 Then Return SetError(5, 0, -1)
If $4w < 1 Or $4w > $4h Then $4w = $4h
If $48 < 0 Then $48 = 0
If $48 > $4w Then Return SetError(4, 0, -1)
Else
If $4w < 1 Or $4w > $4c Then $4w = $4c
If $48 < 0 Then $48 = 0
If $48 > $4w Then Return SetError(4, 0, -1)
EndIf
Local $52 = 1
If Not $4z Then
Local $53 = $48
$48 = $4w
$4w = $53
$52 = -1
EndIf
Switch UBound($46, $n)
Case 1
If Not $4y Then
If Not $4x Then
For $4g = $48 To $4w Step $52
If $51 And VarGetType($46[$4g]) <> VarGetType($47) Then ContinueLoop
If $46[$4g] = $47 Then Return $4g
Next
Else
For $4g = $48 To $4w Step $52
If $51 And VarGetType($46[$4g]) <> VarGetType($47) Then ContinueLoop
If $46[$4g] == $47 Then Return $4g
Next
EndIf
Else
For $4g = $48 To $4w Step $52
If $4y = 3 Then
If StringRegExp($46[$4g], $47) Then Return $4g
Else
If StringInStr($46[$4g], $47, $4x) > 0 Then Return $4g
EndIf
Next
EndIf
Case 2
Local $54
If $50 Then
$54 = $4c
If $3t > $54 Then $3t = $54
If $3t < 0 Then
$3t = 0
Else
$54 = $3t
EndIf
Else
$54 = $4h
If $3t > $54 Then $3t = $54
If $3t < 0 Then
$3t = 0
Else
$54 = $3t
EndIf
EndIf
For $4n = $3t To $54
If Not $4y Then
If Not $4x Then
For $4g = $48 To $4w Step $52
If $50 Then
If $51 And VarGetType($46[$4n][$4g]) <> VarGetType($47) Then ContinueLoop
If $46[$4n][$4g] = $47 Then Return $4g
Else
If $51 And VarGetType($46[$4g][$4n]) <> VarGetType($47) Then ContinueLoop
If $46[$4g][$4n] = $47 Then Return $4g
EndIf
Next
Else
For $4g = $48 To $4w Step $52
If $50 Then
If $51 And VarGetType($46[$4n][$4g]) <> VarGetType($47) Then ContinueLoop
If $46[$4n][$4g] == $47 Then Return $4g
Else
If $51 And VarGetType($46[$4g][$4n]) <> VarGetType($47) Then ContinueLoop
If $46[$4g][$4n] == $47 Then Return $4g
EndIf
Next
EndIf
Else
For $4g = $48 To $4w Step $52
If $4y = 3 Then
If $50 Then
If StringRegExp($46[$4n][$4g], $47) Then Return $4g
Else
If StringRegExp($46[$4g][$4n], $47) Then Return $4g
EndIf
Else
If $50 Then
If StringInStr($46[$4n][$4g], $47, $4x) > 0 Then Return $4g
Else
If StringInStr($46[$4g][$4n], $47, $4x) > 0 Then Return $4g
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
Func _wj(ByRef $46, $55, $56, $57 = True)
If $55 > $56 Then Return
Local $58 = $56 - $55 + 1
Local $4g, $4n, $59, $5a, $5b, $5c, $5d, $5e
If $58 < 45 Then
If $57 Then
$4g = $55
While $4g < $56
$4n = $4g
$5a = $46[$4g + 1]
While $5a < $46[$4n]
$46[$4n + 1] = $46[$4n]
$4n -= 1
If $4n + 1 = $55 Then ExitLoop
WEnd
$46[$4n + 1] = $5a
$4g += 1
WEnd
Else
While 1
If $55 >= $56 Then Return 1
$55 += 1
If $46[$55] < $46[$55 - 1] Then ExitLoop
WEnd
While 1
$59 = $55
$55 += 1
If $55 > $56 Then ExitLoop
$5c = $46[$59]
$5d = $46[$55]
If $5c < $5d Then
$5d = $5c
$5c = $46[$55]
EndIf
$59 -= 1
While $5c < $46[$59]
$46[$59 + 2] = $46[$59]
$59 -= 1
WEnd
$46[$59 + 2] = $5c
While $5d < $46[$59]
$46[$59 + 1] = $46[$59]
$59 -= 1
WEnd
$46[$59 + 1] = $5d
$55 += 1
WEnd
$5e = $46[$56]
$56 -= 1
While $5e < $46[$56]
$46[$56 + 1] = $46[$56]
$56 -= 1
WEnd
$46[$56 + 1] = $5e
EndIf
Return 1
EndIf
Local $5f = BitShift($58, 3) + BitShift($58, 6) + 1
Local $5g, $5h, $5i, $5j, $5k, $5l
$5i = Ceiling(($55 + $56) / 2)
$5h = $5i - $5f
$5g = $5h - $5f
$5j = $5i + $5f
$5k = $5j + $5f
If $46[$5h] < $46[$5g] Then
$5l = $46[$5h]
$46[$5h] = $46[$5g]
$46[$5g] = $5l
EndIf
If $46[$5i] < $46[$5h] Then
$5l = $46[$5i]
$46[$5i] = $46[$5h]
$46[$5h] = $5l
If $5l < $46[$5g] Then
$46[$5h] = $46[$5g]
$46[$5g] = $5l
EndIf
EndIf
If $46[$5j] < $46[$5i] Then
$5l = $46[$5j]
$46[$5j] = $46[$5i]
$46[$5i] = $5l
If $5l < $46[$5h] Then
$46[$5i] = $46[$5h]
$46[$5h] = $5l
If $5l < $46[$5g] Then
$46[$5h] = $46[$5g]
$46[$5g] = $5l
EndIf
EndIf
EndIf
If $46[$5k] < $46[$5j] Then
$5l = $46[$5k]
$46[$5k] = $46[$5j]
$46[$5j] = $5l
If $5l < $46[$5i] Then
$46[$5j] = $46[$5i]
$46[$5i] = $5l
If $5l < $46[$5h] Then
$46[$5i] = $46[$5h]
$46[$5h] = $5l
If $5l < $46[$5g] Then
$46[$5h] = $46[$5g]
$46[$5g] = $5l
EndIf
EndIf
EndIf
EndIf
Local $5m = $55
Local $5n = $56
If(($46[$5g] <> $46[$5h]) And($46[$5h] <> $46[$5i]) And($46[$5i] <> $46[$5j]) And($46[$5j] <> $46[$5k])) Then
Local $5o = $46[$5h]
Local $5p = $46[$5j]
$46[$5h] = $46[$55]
$46[$5j] = $46[$56]
Do
$5m += 1
Until $46[$5m] >= $5o
Do
$5n -= 1
Until $46[$5n] <= $5p
$59 = $5m
While $59 <= $5n
$5b = $46[$59]
If $5b < $5o Then
$46[$59] = $46[$5m]
$46[$5m] = $5b
$5m += 1
ElseIf $5b > $5p Then
While $46[$5n] > $5p
$5n -= 1
If $5n + 1 = $59 Then ExitLoop 2
WEnd
If $46[$5n] < $5o Then
$46[$59] = $46[$5m]
$46[$5m] = $46[$5n]
$5m += 1
Else
$46[$59] = $46[$5n]
EndIf
$46[$5n] = $5b
$5n -= 1
EndIf
$59 += 1
WEnd
$46[$55] = $46[$5m - 1]
$46[$5m - 1] = $5o
$46[$56] = $46[$5n + 1]
$46[$5n + 1] = $5p
_wj($46, $55, $5m - 2, True)
_wj($46, $5n + 2, $56, False)
If($5m < $5g) And($5k < $5n) Then
While $46[$5m] = $5o
$5m += 1
WEnd
While $46[$5n] = $5p
$5n -= 1
WEnd
$59 = $5m
While $59 <= $5n
$5b = $46[$59]
If $5b = $5o Then
$46[$59] = $46[$5m]
$46[$5m] = $5b
$5m += 1
ElseIf $5b = $5p Then
While $46[$5n] = $5p
$5n -= 1
If $5n + 1 = $59 Then ExitLoop 2
WEnd
If $46[$5n] = $5o Then
$46[$59] = $46[$5m]
$46[$5m] = $5o
$5m += 1
Else
$46[$59] = $46[$5n]
EndIf
$46[$5n] = $5b
$5n -= 1
EndIf
$59 += 1
WEnd
EndIf
_wj($46, $5m, $5n, False)
Else
Local $5q = $46[$5i]
$59 = $5m
While $59 <= $5n
If $46[$59] = $5q Then
$59 += 1
ContinueLoop
EndIf
$5b = $46[$59]
If $5b < $5q Then
$46[$59] = $46[$5m]
$46[$5m] = $5b
$5m += 1
Else
While $46[$5n] > $5q
$5n -= 1
WEnd
If $46[$5n] < $5q Then
$46[$59] = $46[$5m]
$46[$5m] = $46[$5n]
$5m += 1
Else
$46[$59] = $5q
EndIf
$46[$5n] = $5b
$5n -= 1
EndIf
$59 += 1
WEnd
_wj($46, $55, $5m - 1, True)
_wj($46, $5n + 1, $56, False)
EndIf
EndFunc
Func _x1($5r, $5s = "*", $5t = $s, $5u = False)
Local $5v = "|", $5w = "", $5x = "", $5y = ""
$5r = StringRegExpReplace($5r, "[\\/]+$", "") & "\"
If $5t = Default Then $5t = $s
If $5u Then $5y = $5r
If $5s = Default Then $5s = "*"
If Not FileExists($5r) Then Return SetError(1, 0, 0)
If StringRegExp($5s, "[\\/:><\|]|(?s)^\s*$") Then Return SetError(2, 0, 0)
If Not($5t = 0 Or $5t = 1 Or $5t = 2) Then Return SetError(3, 0, 0)
Local $5z = FileFindFirstFile($5r & $5s)
If @error Then Return SetError(4, 0, 0)
While 1
$5x = FileFindNextFile($5z)
If @error Then ExitLoop
If($5t + @extended = 2) Then ContinueLoop
$5w &= $5v & $5y & $5x
WEnd
FileClose($5z)
If $5w = "" Then Return SetError(4, 0, 0)
Return StringSplit(StringTrimLeft($5w, 1), $5v)
EndFunc
Func _x2($5r, $60 = "*", $2z = $t, $61 = $x, $62 = $y, $63 = $0z)
If Not FileExists($5r) Then Return SetError(1, 1, "")
If $60 = Default Then $60 = "*"
If $2z = Default Then $2z = $t
If $61 = Default Then $61 = $x
If $62 = Default Then $62 = $y
If $63 = Default Then $63 = $0z
If $61 > 1 Or Not IsInt($61) Then Return SetError(1, 6, "")
Local $64 = False
If StringLeft($5r, 4) == "\\?\" Then
$64 = True
EndIf
Local $65 = ""
If StringRight($5r, 1) = "\" Then
$65 = "\"
Else
$5r = $5r & "\"
EndIf
Local $66[100] = [1]
$66[1] = $5r
Local $67 = 0, $68 = ""
If BitAND($2z, $u) Then
$67 += 2
$68 &= "H"
$2z -= $u
EndIf
If BitAND($2z, $v) Then
$67 += 4
$68 &= "S"
$2z -= $v
EndIf
Local $69 = 0
If BitAND($2z, $w) Then
$69 = 0x400
$2z -= $w
EndIf
Local $6a = 0
If $61 < 0 Then
StringReplace($5r, "\", "", 0, $g)
$6a = @extended - $61
EndIf
Local $6b = "", $6c = "", $6d = "*"
Local $6e = StringSplit($60, "|")
Switch $6e[0]
Case 3
$6c = $6e[3]
ContinueCase
Case 2
$6b = $6e[2]
ContinueCase
Case 1
$6d = $6e[1]
EndSwitch
Local $6f = ".+"
If $6d <> "*" Then
If Not _x5($6f, $6d) Then Return SetError(1, 2, "")
EndIf
Local $6g = ".+"
Switch $2z
Case 0
Switch $61
Case 0
$6g = $6f
EndSwitch
Case 2
$6g = $6f
EndSwitch
Local $6h = ":"
If $6b <> "" Then
If Not _x5($6h, $6b) Then Return SetError(1, 3, "")
EndIf
Local $6i = ":"
If $61 Then
If $6c Then
If Not _x5($6i, $6c) Then Return SetError(1, 4, "")
EndIf
If $2z = 2 Then
$6i = $6h
EndIf
Else
$6i = $6h
EndIf
If Not($2z = 0 Or $2z = 1 Or $2z = 2) Then Return SetError(1, 5, "")
If Not($62 = 0 Or $62 = 1 Or $62 = 2) Then Return SetError(1, 7, "")
If Not($63 = 0 Or $63 = 1 Or $63 = 2) Then Return SetError(1, 8, "")
If $69 Then
Local $6j = DllStructCreate("struct;align 4;dword FileAttributes;uint64 CreationTime;uint64 LastAccessTime;uint64 LastWriteTime;" & "dword FileSizeHigh;dword FileSizeLow;dword Reserved0;dword Reserved1;wchar FileName[260];wchar AlternateFileName[14];endstruct")
Local $6k = DllOpen('kernel32.dll'), $6l
EndIf
Local $6m[100] = [0]
Local $6n = $6m, $6o = $6m, $6p = $6m
Local $6q = False, $5z = 0, $6r = "", $6s = "", $6t = ""
Local $6u = 0, $6v = ''
Local $6w[100][2] = [[0, 0]]
While $66[0] > 0
$6r = $66[$66[0]]
$66[0] -= 1
Switch $63
Case 1
$6t = StringReplace($6r, $5r, "")
Case 2
If $64 Then
$6t = StringTrimLeft($6r, 4)
Else
$6t = $6r
EndIf
EndSwitch
If $69 Then
$6l = DllCall($6k, 'handle', 'FindFirstFileW', 'wstr', $6r & "*", 'struct*', $6j)
If @error Or Not $6l[0] Then
ContinueLoop
EndIf
$5z = $6l[0]
Else
$5z = FileFindFirstFile($6r & "*")
If $5z = -1 Then
ContinueLoop
EndIf
EndIf
If $2z = 0 And $62 And $63 Then
_x4($6w, $6t, $6n[0] + 1)
EndIf
$6v = ''
While 1
If $69 Then
$6l = DllCall($6k, 'int', 'FindNextFileW', 'handle', $5z, 'struct*', $6j)
If @error Or Not $6l[0] Then
ExitLoop
EndIf
$6s = DllStructGetData($6j, "FileName")
If $6s = ".." Then
ContinueLoop
EndIf
$6u = DllStructGetData($6j, "FileAttributes")
If $67 And BitAND($6u, $67) Then
ContinueLoop
EndIf
If BitAND($6u, $69) Then
ContinueLoop
EndIf
$6q = False
If BitAND($6u, 16) Then
$6q = True
EndIf
Else
$6q = False
$6s = FileFindNextFile($5z, 1)
If @error Then
ExitLoop
EndIf
$6v = @extended
If StringInStr($6v, "D") Then
$6q = True
EndIf
If StringRegExp($6v, "[" & $68 & "]") Then
ContinueLoop
EndIf
EndIf
If $6q Then
Select
Case $61 < 0
StringReplace($6r, "\", "", 0, $g)
If @extended < $6a Then
ContinueCase
EndIf
Case $61 = 1
If Not StringRegExp($6s, $6i) Then
_x4($66, $6r & $6s & "\")
EndIf
EndSelect
EndIf
If $62 Then
If $6q Then
If StringRegExp($6s, $6g) And Not StringRegExp($6s, $6i) Then
_x4($6p, $6t & $6s & $65)
EndIf
Else
If StringRegExp($6s, $6f) And Not StringRegExp($6s, $6h) Then
If $6r = $5r Then
_x4($6o, $6t & $6s)
Else
_x4($6n, $6t & $6s)
EndIf
EndIf
EndIf
Else
If $6q Then
If $2z <> 1 And StringRegExp($6s, $6g) And Not StringRegExp($6s, $6i) Then
_x4($6m, $6t & $6s & $65)
EndIf
Else
If $2z <> 2 And StringRegExp($6s, $6f) And Not StringRegExp($6s, $6h) Then
_x4($6m, $6t & $6s)
EndIf
EndIf
EndIf
WEnd
If $69 Then
DllCall($6k, 'int', 'FindClose', 'ptr', $5z)
Else
FileClose($5z)
EndIf
WEnd
If $69 Then
DllClose($6k)
EndIf
If $62 Then
Switch $2z
Case 2
If $6p[0] = 0 Then Return SetError(1, 9, "")
ReDim $6p[$6p[0] + 1]
$6m = $6p
_wj($6m, 1, $6m[0])
Case 1
If $6o[0] = 0 And $6n[0] = 0 Then Return SetError(1, 9, "")
If $63 = 0 Then
_x3($6m, $6o, $6n)
_wj($6m, 1, $6m[0])
Else
_x3($6m, $6o, $6n, 1)
EndIf
Case 0
If $6o[0] = 0 And $6p[0] = 0 Then Return SetError(1, 9, "")
If $63 = 0 Then
_x3($6m, $6o, $6n)
$6m[0] += $6p[0]
ReDim $6p[$6p[0] + 1]
_w0($6m, $6p, 1)
_wj($6m, 1, $6m[0])
Else
Local $6m[$6n[0] + $6o[0] + $6p[0] + 1]
$6m[0] = $6n[0] + $6o[0] + $6p[0]
_wj($6o, 1, $6o[0])
For $4g = 1 To $6o[0]
$6m[$4g] = $6o[$4g]
Next
Local $6x = $6o[0] + 1
_wj($6p, 1, $6p[0])
Local $6y = ""
For $4g = 1 To $6p[0]
$6m[$6x] = $6p[$4g]
$6x += 1
If $65 Then
$6y = $6p[$4g]
Else
$6y = $6p[$4g] & "\"
EndIf
Local $6z = 0, $70 = 0
For $4n = 1 To $6w[0][0]
If $6y = $6w[$4n][0] Then
$70 = $6w[$4n][1]
If $4n = $6w[0][0] Then
$6z = $6n[0]
Else
$6z = $6w[$4n + 1][1] - 1
EndIf
If $62 = 1 Then
_wj($6n, $70, $6z)
EndIf
For $59 = $70 To $6z
$6m[$6x] = $6n[$59]
$6x += 1
Next
ExitLoop
EndIf
Next
Next
EndIf
EndSwitch
Else
If $6m[0] = 0 Then Return SetError(1, 9, "")
ReDim $6m[$6m[0] + 1]
EndIf
Return $6m
EndFunc
Func _x3(ByRef $71, $72, $73, $62 = 0)
ReDim $72[$72[0] + 1]
If $62 = 1 Then _wj($72, 1, $72[0])
$71 = $72
$71[0] += $73[0]
ReDim $73[$73[0] + 1]
If $62 = 1 Then _wj($73, 1, $73[0])
_w0($71, $73, 1)
EndFunc
Func _x4(ByRef $74, $75, $76 = -1)
If $76 = -1 Then
$74[0] += 1
If UBound($74) <= $74[0] Then ReDim $74[UBound($74) * 2]
$74[$74[0]] = $75
Else
$74[0][0] += 1
If UBound($74) <= $74[0][0] Then ReDim $74[UBound($74) * 2][2]
$74[$74[0][0]][0] = $75
$74[$74[0][0]][1] = $76
EndIf
EndFunc
Func _x5(ByRef $60, $77)
If StringRegExp($77, "\\|/|:|\<|\>|\|") Then Return 0
$77 = StringReplace(StringStripWS(StringRegExpReplace($77, "\s*;\s*", ";"), BitOR($h, $i)), ";", "|")
$77 = StringReplace(StringReplace(StringRegExpReplace($77, "[][$^.{}()+\-]", "\\$0"), "?", "."), "*", ".*?")
$60 = "(?i)^(" & $77 & ")\z"
Return 1
EndFunc
Func _xe($5r, ByRef $78, ByRef $79, ByRef $5x, ByRef $7a)
Local $46 = StringRegExp($5r, "^\h*((?:\\\\\?\\)*(\\\\[^\?\/\\]+|[A-Za-z]:)?(.*[\/\\]\h*)?((?:[^\.\/\\]|(?(?=\.[^\/\\]*\.)\.))*)?([^\/\\]*))$", $l)
If @error Then
ReDim $46[5]
$46[$11] = $5r
EndIf
$78 = $46[$12]
If StringLeft($46[$13], 1) == "/" Then
$79 = StringRegExpReplace($46[$13], "\h*[\/\\]+\h*", "\/")
Else
$79 = StringRegExpReplace($46[$13], "\h*[\/\\]+\h*", "\\")
EndIf
$46[$13] = $79
$5x = $46[$14]
$7a = $46[$15]
Return $46
EndFunc
Global $7b = False
Local $7c = "0.0.20"
Local Const $7d[6] = ["040C", "080C", "0C0C", "100C", "140C", "180C"]
If _we($7d, @MUILang) <> 1 Then
Global $7e = "Supprimer les outils"
Global $7f = "Supprimer les points de restaurations"
Global $7g = "Créer un point de restauration"
Global $7h = "Sauvegarder le registre"
Global $7i = "Restaurer UAC"
Global $7j = "Restaurer les paramètres système"
Global $7k = "Exécuter"
Global $7l = "Toutes les opérations sont terminées"
Global $7m = "Echec"
Global $7n = "Impossible de créer une sauvegarde du registre"
Global $7o = "Vous devez exécuter le programme avec les droits administrateurs"
Global $7p = "Vous devez fermer MalwareBytes Anti-Rootkit avant de continuer"
Global $7q = "Mise à jour"
Global $7r = "Une version plus récente de KpRm existe, merci de la télécharger."
Else
Global $7e = "Delete Tools"
Global $7f = "Delete Restore Points"
Global $7g = "Create Restore Point"
Global $7h = "Registry Backup"
Global $7i = "UAC Restore"
Global $7j = "Restore System Settings"
Global $7k = "Run"
Global $7l = "All operations are completed"
Global $7m = "Fail"
Global $7n = "Unable to create a registry backup"
Global $7o = "You must run the program with administrator rights"
Global $7p = "You must close MalwareBytes Anti-Rootkit before continuing"
Global $7q = "Update"
Global $7r = "A more recent version of KpRm exists, please download it!"
EndIf
Global Const $7s = 1
Global Const $7t = 5
Global Const $7u = 0
Global Const $7v = 1
Func _xr($7w = $7t)
If Not IsAdmin() Then Return SetError(-3, 0, -1)
If StringRegExp(@OSVersion, "_(XP|200(0|3))") Then Return SetError(-4, 0, -1)
Local $7x = ""
If @OSArch = "X64" Then $7x = "64"
If $7w < 0 Or $7w > 5 Then Return SetError(-5, 0, -1)
Local $2z = RegWrite("HKEY_LOCAL_MACHINE" & $7x & "\Software\Microsoft\Windows\CurrentVersion\Policies\System", "ConsentPromptBehaviorAdmin", "REG_DWORD", $7w)
If $2z = 0 Then $2z = -1
Return SetError(@error, 0, $2z)
EndFunc
Func _xs($7w = $7s)
If Not IsAdmin() Then Return SetError(-3, 0, -1)
If StringRegExp(@OSVersion, "_(XP|200(0|3))") Then Return SetError(-4, 0, -1)
If $7w < 0 Or $7w = 2 Or $7w > 3 Then Return SetError(-5, 0, -1)
Local $7x = ""
If @OSArch = "X64" Then $7x = "64"
Local $2z = RegWrite("HKEY_LOCAL_MACHINE" & $7x & "\Software\Microsoft\Windows\CurrentVersion\Policies\System", "ConsentPromptBehaviorUser", "REG_DWORD", $7w)
If $2z = 0 Then $2z = -1
Return SetError(@error, 0, $2z)
EndFunc
Func _xt($7w = $7u)
If Not IsAdmin() Then Return SetError(-3, 0, -1)
If StringRegExp(@OSVersion, "_(XP|200(0|3))") Then Return SetError(-4, 0, -1)
If $7w < 0 Or $7w > 1 Then Return SetError(-5, 0, -1)
Local $7x = ""
If @OSArch = "X64" Then $7x = "64"
Local $2z = RegWrite("HKEY_LOCAL_MACHINE" & $7x & "\Software\Microsoft\Windows\CurrentVersion\Policies\System", "EnableInstallerDetection", "REG_DWORD", $7w)
If $2z = 0 Then $2z = -1
Return SetError(@error, 0, $2z)
EndFunc
Func _xu($7w = $7v)
If Not IsAdmin() Then Return SetError(-3, 0, -1)
If StringRegExp(@OSVersion, "_(XP|200(0|3))") Then Return SetError(-4, 0, -1)
If $7w < 0 Or $7w > 1 Then Return SetError(-5, 0, -1)
Local $7x = ""
If @OSArch = "X64" Then $7x = "64"
Local $2z = RegWrite("HKEY_LOCAL_MACHINE" & $7x & "\Software\Microsoft\Windows\CurrentVersion\Policies\System", "EnableLUA", "REG_DWORD", $7w)
If $2z = 0 Then $2z = -1
Return SetError(@error, 0, $2z)
EndFunc
Func _xv($7w = $7v)
If Not IsAdmin() Then Return SetError(-3, 0, -1)
If StringRegExp(@OSVersion, "_(XP|200(0|3))") Then Return SetError(-4, 0, -1)
If $7w < 0 Or $7w > 1 Then Return SetError(-5, 0, -1)
Local $7x = ""
If @OSArch = "X64" Then $7x = "64"
Local $2z = RegWrite("HKEY_LOCAL_MACHINE" & $7x & "\Software\Microsoft\Windows\CurrentVersion\Policies\System", "EnableSecureUIAPaths", "REG_DWORD", $7w)
If $2z = 0 Then $2z = -1
Return SetError(@error, 0, $2z)
EndFunc
Func _xw($7w = $7u)
If Not IsAdmin() Then Return SetError(-3, 0, -1)
If StringRegExp(@OSVersion, "_(XP|200(0|3))") Then Return SetError(-4, 0, -1)
If $7w < 0 Or $7w > 1 Then Return SetError(-5, 0, -1)
Local $7x = ""
If @OSArch = "X64" Then $7x = "64"
Local $2z = RegWrite("HKEY_LOCAL_MACHINE" & $7x & "\Software\Microsoft\Windows\CurrentVersion\Policies\System", "EnableUIADesktopToggle", "REG_DWORD", $7w)
If $2z = 0 Then $2z = -1
Return SetError(@error, 0, $2z)
EndFunc
Func _xx($7w = $7v)
If Not IsAdmin() Then Return SetError(-3, 0, -1)
If StringRegExp(@OSVersion, "_(XP|200(0|3))") Then Return SetError(-4, 0, -1)
If $7w < 0 Or $7w > 1 Then Return SetError(-5, 0, -1)
Local $7x = ""
If @OSArch = "X64" Then $7x = "64"
Local $2z = RegWrite("HKEY_LOCAL_MACHINE" & $7x & "\Software\Microsoft\Windows\CurrentVersion\Policies\System", "EnableVirtualization", "REG_DWORD", $7w)
If $2z = 0 Then $2z = -1
Return SetError(@error, 0, $2z)
EndFunc
Func _xy($7w = $7u)
If Not IsAdmin() Then Return SetError(-3, 0, -1)
If StringRegExp(@OSVersion, "_(XP|200(0|3))") Then Return SetError(-4, 0, -1)
If $7w < 0 Or $7w > 1 Then Return SetError(-5, 0, -1)
Local $7x = ""
If @OSArch = "X64" Then $7x = "64"
Local $2z = RegWrite("HKEY_LOCAL_MACHINE" & $7x & "\Software\Microsoft\Windows\CurrentVersion\Policies\System", "FilterAdministratorToken", "REG_DWORD", $7w)
If $2z = 0 Then $2z = -1
Return SetError(@error, 0, $2z)
EndFunc
Func _xz($7w = $7v)
If Not IsAdmin() Then Return SetError(-3, 0, -1)
If StringRegExp(@OSVersion, "_(XP|200(0|3))") Then Return SetError(-4, 0, -1)
If $7w < 0 Or $7w > 1 Then Return SetError(-5, 0, -1)
Local $7x = ""
If @OSArch = "X64" Then $7x = "64"
Local $2z = RegWrite("HKEY_LOCAL_MACHINE" & $7x & "\Software\Microsoft\Windows\CurrentVersion\Policies\System", "PromptOnSecureDesktop", "REG_DWORD", $7w)
If $2z = 0 Then $2z = -1
Return SetError(@error, 0, $2z)
EndFunc
Func _y0($7w = $7u)
If Not IsAdmin() Then Return SetError(-3, 0, -1)
If StringRegExp(@OSVersion, "_(XP|200(0|3))") Then Return SetError(-4, 0, -1)
If $7w < 0 Or $7w > 1 Then Return SetError(-5, 0, -1)
Local $7x = ""
If @OSArch = "X64" Then $7x = "64"
Local $2z = RegWrite("HKEY_LOCAL_MACHINE" & $7x & "\Software\Microsoft\Windows\CurrentVersion\Policies\System", "ValidateAdminCodeSignatures", "REG_DWORD", $7w)
If $2z = 0 Then $2z = -1
Return SetError(@error, 0, $2z)
EndFunc
Global $7y = Null, $7z = Null
Global $80 = EnvGet('SystemDrive') & '\'
Func _y2()
Local $81[1][3], $82 = 0
$81[0][0] = $82
If Not IsObj($7z) Then $7z = ObjGet("winmgmts:root/default")
If Not IsObj($7z) Then Return $81
Local $83 = $7z.InstancesOf("SystemRestore")
If Not IsObj($83) Then Return $81
For $84 In $83
$82 += 1
ReDim $81[$82 + 1][3]
$81[$82][0] = $84.SequenceNumber
$81[$82][1] = $84.Description
$81[$82][2] = _y3($84.CreationTime)
Next
$81[0][0] = $82
Return $81
EndFunc
Func _y3($85)
Return(StringMid($85, 5, 2) & "/" & StringMid($85, 7, 2) & "/" & StringLeft($85, 4) & " " & StringMid($85, 9, 2) & ":" & StringMid($85, 11, 2) & ":" & StringMid($85, 13, 2))
EndFunc
Func _y4($86)
Local $19 = DllCall('SrClient.dll', 'DWORD', 'SRRemoveRestorePoint', 'DWORD', $86)
If @error Then Return SetError(1, 0, 0)
If $19[0] = 0 Then Return 1
Return SetError(1, 0, 0)
EndFunc
Func _y6($87 = $80)
If Not IsObj($7y) Then $7y = ObjGet("winmgmts:{impersonationLevel=impersonate}!root/default:SystemRestore")
If Not IsObj($7y) Then Return 0
If $7y.Enable($87) = 0 Then Return 1
Return 0
EndFunc
Global Enum $88 = 0, $89, $8a, $8b, $8c, $8d, $8e, $8f, $8g, $8h, $8i, $8j, $8k
Global Const $8l = 2
Global $8m = @SystemDir&'\Advapi32.dll'
Global $8n = @SystemDir&'\Kernel32.dll'
Global $8o[4][2], $8p[4][2]
Global $8q = 0
Func _y9()
$8m = DllOpen(@SystemDir&'\Advapi32.dll')
$8n = DllOpen(@SystemDir&'\Kernel32.dll')
$8o[0][0] = "SeRestorePrivilege"
$8o[0][1] = 2
$8o[1][0] = "SeTakeOwnershipPrivilege"
$8o[1][1] = 2
$8o[2][0] = "SeDebugPrivilege"
$8o[2][1] = 2
$8o[3][0] = "SeSecurityPrivilege"
$8o[3][1] = 2
$8p = _zh($8o)
$8q = 1
EndFunc
Func _yf($8r, $8s = $89, $8t = 'Administrators', $8u = 1)
Local $8v[1][3]
$8v[0][0] = 'Everyone'
$8v[0][1] = 1
$8v[0][2] = $r
Return _yi($8r, $8v, $8s, $8t, 1, $8u)
EndFunc
Func _yi($8r, $8w, $8s = $89, $8t = '', $8x = 0, $8u = 0, $8y = 3)
If $8q = 0 Then _y9()
If Not IsArray($8w) Or UBound($8w,2) < 3 Then Return SetError(1,0,0)
Local $8z = _yn($8w,$8y)
Local $90 = @extended
Local $91 = 4, $92 = 0
If $8t <> '' Then
If Not IsDllStruct($8t) Then $8t = _za($8t)
$92 = DllStructGetPtr($8t)
If $92 And _zg($92) Then
$91 = 5
Else
$92 = 0
EndIf
EndIf
If Not IsPtr($8r) And $8s = $89 Then
Return _yv($8r, $8z, $92, $8x, $8u, $90, $91)
ElseIf Not IsPtr($8r) And $8s = $8c Then
Return _yw($8r, $8z, $92, $8x, $8u, $90, $91)
Else
If $8x Then _yx($8r,$8s)
Return _yo($8r, $8s, $91, $92, 0, $8z,0)
EndIf
EndFunc
Func _yn(ByRef $8w, ByRef $8y)
Local $93 = UBound($8w,2)
If Not IsArray($8w) Or $93 < 3 Then Return SetError(1,0,0)
Local $94 = UBound($8w), $95[$94], $96 = 0, $97 = 1
Local $98, $90 = 0, $99
Local $9a, $9b = 'DWORD;DWORD;DWORD;ptr;DWORD;DWORD;DWORD;ptr'
For $4g = 1 To $94 - 1
$9b &= ';DWORD;DWORD;DWORD;ptr;DWORD;DWORD;DWORD;ptr'
Next
$9a = DllStructCreate($9b)
For $4g = 0 To $94 -1
If Not IsDllStruct($8w[$4g][0]) Then $8w[$4g][0] = _za($8w[$4g][0])
$95[$4g] = DllStructGetPtr($8w[$4g][0])
If Not _zg($95[$4g]) Then ContinueLoop
DllStructSetData($9a,$96+1,$8w[$4g][2])
If $8w[$4g][1] = 0 Then
$90 = 1
$98 = $c
Else
$98 = $b
EndIf
If $93 > 3 Then $8y = $8w[$4g][3]
DllStructSetData($9a,$96+2,$98)
DllStructSetData($9a,$96+3,$8y)
DllStructSetData($9a,$96+6,0)
$99 = DllCall($8m,'BOOL','LookupAccountSid','ptr',0,'ptr',$95[$4g],'ptr*',0,'dword*',32,'ptr*',0,'dword*',32,'dword*',0)
If Not @error Then $97 = $99[7]
DllStructSetData($9a,$96+7,$97)
DllStructSetData($9a,$96+8,$95[$4g])
$96 += 8
Next
Local $9c = DllStructGetPtr($9a)
$99 = DllCall($8m,'DWORD','SetEntriesInAcl','ULONG',$94,'ptr',$9c ,'ptr',0,'ptr*',0)
If @error Or $99[0] Then Return SetError(1,0,0)
Return SetExtended($90, $99[4])
EndFunc
Func _yo($8r, $8s, $91, $92 = 0, $9d = 0, $8z = 0, $9e = 0)
Local $99
If $8q = 0 Then _y9()
If $8z And Not _yp($8z) Then Return 0
If $9e And Not _yp($9e) Then Return 0
If IsPtr($8r) Then
$99 = DllCall($8m,'dword','SetSecurityInfo','handle',$8r,'dword',$8s, 'dword',$91,'ptr',$92,'ptr',$9d,'ptr',$8z,'ptr',$9e)
Else
If $8s = $8c Then $8r = _zb($8r)
$99 = DllCall($8m,'dword','SetNamedSecurityInfo','str',$8r,'dword',$8s, 'dword',$91,'ptr',$92,'ptr',$9d,'ptr',$8z,'ptr',$9e)
EndIf
If @error Then Return SetError(1,0,0)
If $99[0] And $92 Then
If _z0($8r, $8s,_zf($92)) Then Return _yo($8r, $8s, $91 - 1, 0, $9d, $8z, $9e)
EndIf
Return SetError($99[0] , 0, Number($99[0] = 0))
EndFunc
Func _yp($9f)
If $9f = 0 Then Return SetError(1,0,0)
Local $99 = DllCall($8m,'bool','IsValidAcl','ptr',$9f)
If @error Or Not $99[0] Then Return 0
Return 1
EndFunc
Func _ys($9g, $9h = -1)
If $8q = 0 Then _y9()
If $9h = -1 Then $9h = BitOR($5, $6, $7, $8)
$9g = ProcessExists($9g)
If $9g = 0 Then Return SetError(1,0,0)
Local $99 = DllCall($8n,'handle','OpenProcess','dword',$9h,'bool',False,'dword',$9g)
If @error Or $99[0] = 0 Then Return SetError(2,0,0)
Return $99[0]
EndFunc
Func _yt($9g)
Local $9i = _ys($9g,BitOR(1,$5, $6, $7, $8))
If $9i = 0 Then Return SetError(1,0,0)
Local $9j = 0
_yf($9i,$8e)
For $4g = 1 To 10
DllCall($8n,'bool','TerminateProcess','handle',$9i,'uint',0)
If @error Then $9j = 0
Sleep(30)
If Not ProcessExists($9g) Then
$9j = 1
ExitLoop
EndIf
Next
_yu($9i)
Return $9j
EndFunc
Func _yu($9k)
Local $99 = DllCall($8n,'bool','CloseHandle','handle',$9k)
If @error Then Return SetError(@error,0,0)
Return $99[0]
EndFunc
Func _yv($8r, ByRef $8z, ByRef $92, ByRef $8x, ByRef $8u, ByRef $90, ByRef $91)
Local $9j, $9l
If Not $90 Then
If $8x Then _yx($8r,$89)
$9j = _yo($8r, $89, $91, $92, 0, $8z,0)
EndIf
If $8u Then
Local $9m = FileFindFirstFile($8r&'\*')
While 1
$9l = FileFindNextFile($9m)
If $8u = 1 Or $8u = 2 And @extended = 1 Then
_yv($8r&'\'&$9l, $8z, $92, $8x, $8u, $90,$91)
ElseIf @error Then
ExitLoop
ElseIf $8u = 1 Or $8u = 3 Then
If $8x Then _yx($8r&'\'&$9l,$89)
_yo($8r&'\'&$9l, $89, $91, $92, 0, $8z,0)
EndIf
WEnd
FileClose($9m)
EndIf
If $90 Then
If $8x Then _yx($8r,$89)
$9j = _yo($8r, $89, $91, $92, 0, $8z,0)
EndIf
Return $9j
EndFunc
Func _yw($8r, ByRef $8z, ByRef $92, ByRef $8x, ByRef $8u, ByRef $90, ByRef $91)
If $8q = 0 Then _y9()
Local $9j, $4g = 0, $9l
If Not $90 Then
If $8x Then _yx($8r,$8c)
$9j = _yo($8r, $8c, $91, $92, 0, $8z,0)
EndIf
If $8u Then
While 1
$4g += 1
$9l = RegEnumKey($8r,$4g)
If @error Then ExitLoop
_yw($8r&'\'&$9l, $8z, $92, $8x, $8u, $90, $91)
WEnd
EndIf
If $90 Then
If $8x Then _yx($8r,$8c)
$9j = _yo($8r, $8c, $91, $92, 0, $8z,0)
EndIf
Return $9j
EndFunc
Func _yx($8r, $8s = $89)
If $8q = 0 Then _y9()
Local $9n = DllStructCreate('byte[32]'), $19
Local $8z = DllStructGetPtr($9n,1)
DllCall($8m,'bool','InitializeAcl','Ptr',$8z,'dword',DllStructGetSize($9n),'dword',$8l)
If IsPtr($8r) Then
$19 = DllCall($8m,"dword","SetSecurityInfo",'handle',$8r,'dword',$8s,'dword',4,'ptr',0,'ptr',0,'ptr',$8z,'ptr',0)
Else
If $8s = $8c Then $8r = _zb($8r)
DllCall($8m,'DWORD','SetNamedSecurityInfo','str',$8r,'dword',$8s,'DWORD',4,'ptr',0,'ptr',0,'ptr',0,'ptr',0)
$19 = DllCall($8m,'DWORD','SetNamedSecurityInfo','str',$8r,'dword',$8s,'DWORD',4,'ptr',0,'ptr',0,'ptr',$8z,'ptr',0)
EndIf
If @error Then Return SetError(@error,0,0)
Return SetError($19[0],0,Number($19[0] = 0))
EndFunc
Func _z0($8r, $8s = $89, $9o = 'Administrators')
If $8q = 0 Then _y9()
Local $9p = _za($9o), $19
Local $95 = DllStructGetPtr($9p)
If IsPtr($8r) Then
$19 = DllCall($8m,"dword","SetSecurityInfo",'handle',$8r,'dword',$8s,'dword',1,'ptr',$95,'ptr',0,'ptr',0,'ptr',0)
Else
If $8s = $8c Then $8r = _zb($8r)
$19 = DllCall($8m,'DWORD','SetNamedSecurityInfo','str',$8r,'dword',$8s,'DWORD',1,'ptr',$95,'ptr',0,'ptr',0,'ptr',0)
EndIf
If @error Then Return SetError(@error,0,False)
Return SetError($19[0],0,Number($19[0] = 0))
EndFunc
Func _za($9o)
If $9o = 'TrustedInstaller' Then $9o = 'NT SERVICE\TrustedInstaller'
If $9o = 'Everyone' Then
Return _zd('S-1-1-0')
ElseIf $9o = 'Authenticated Users' Then
Return _zd('S-1-5-11')
ElseIf $9o = 'System' Then
Return _zd('S-1-5-18')
ElseIf $9o = 'Administrators' Then
Return _zd('S-1-5-32-544')
ElseIf $9o = 'Users' Then
Return _zd('S-1-5-32-545')
ElseIf $9o = 'Guests' Then
Return _zd('S-1-5-32-546')
ElseIf $9o = 'Power Users' Then
Return _zd('S-1-5-32-547')
ElseIf $9o = 'Local Authority' Then
Return _zd('S-1-2')
ElseIf $9o = 'Creator Owner' Then
Return _zd('S-1-3-0')
ElseIf $9o = 'NT Authority' Then
Return _zd('S-1-5-1')
ElseIf $9o = 'Restricted' Then
Return _zd('S-1-5-12')
ElseIf StringRegExp($9o,'\A(S-1-\d+(-\d+){0,5})\z') Then
Return _zd($9o)
Else
Local $9p = _zc($9o)
Return _zd($9p)
EndIf
EndFunc
Func _zb($9q)
If StringInStr($9q,'\\') = 1 Then
$9q = StringRegExpReplace($9q,'(?i)\\(HKEY_CLASSES_ROOT|HKCR)','\CLASSES_ROOT')
$9q = StringRegExpReplace($9q,'(?i)\\(HKEY_CURRENT_USER|HKCU)','\CURRENT_USER')
$9q = StringRegExpReplace($9q,'(?i)\\(HKEY_LOCAL_MACHINE|HKLM)','\MACHINE')
$9q = StringRegExpReplace($9q,'(?i)\\(HKEY_USERS|HKU)','\USERS')
Else
$9q = StringRegExpReplace($9q,'(?i)\A(HKEY_CLASSES_ROOT|HKCR)','CLASSES_ROOT')
$9q = StringRegExpReplace($9q,'(?i)\A(HKEY_CURRENT_USER|HKCU)','CURRENT_USER')
$9q = StringRegExpReplace($9q,'(?i)\A(HKEY_LOCAL_MACHINE|HKLM)','MACHINE')
$9q = StringRegExpReplace($9q,'(?i)\A(HKEY_USERS|HKU)','USERS')
EndIf
Return $9q
EndFunc
Func _zc($9r, $9s = "")
Local $9t = DllStructCreate("byte SID[256]")
Local $95 = DllStructGetPtr($9t, "SID")
Local $33 = DllCall($8m, "bool", "LookupAccountNameW", "wstr", $9s, "wstr", $9r, "ptr", $95, "dword*", 256, "wstr", "", "dword*", 256, "int*", 0)
If @error Then Return SetError(@error, @extended, 0)
If Not $33[0] Then Return 0
Return _zf($95)
EndFunc
Func _zd($9u)
Local $33 = DllCall($8m, "bool", "ConvertStringSidToSidW", "wstr", $9u, "ptr*", 0)
If @error Then Return SetError(@error, @extended, 0)
If Not $33[0] Then Return 0
Local $9v = _ze($33[2])
Local $3u = DllStructCreate("byte Data[" & $9v & "]", $33[2])
Local $9w = DllStructCreate("byte Data[" & $9v & "]")
DllStructSetData($9w, "Data", DllStructGetData($3u, "Data"))
DllCall($8n, "ptr", "LocalFree", "ptr", $33[2])
Return $9w
EndFunc
Func _ze($95)
If Not _zg($95) Then Return SetError(-1, 0, "")
Local $33 = DllCall($8m, "dword", "GetLengthSid", "ptr", $95)
If @error Then Return SetError(@error, @extended, 0)
Return $33[0]
EndFunc
Func _zf($95)
If Not _zg($95) Then Return SetError(-1, 0, "")
Local $33 = DllCall($8m, "int", "ConvertSidToStringSidW", "ptr", $95, "ptr*", 0)
If @error Then Return SetError(@error, @extended, "")
If Not $33[0] Then Return ""
Local $3u = DllStructCreate("wchar Text[256]", $33[2])
Local $9u = DllStructGetData($3u, "Text")
DllCall($8n, "ptr", "LocalFree", "ptr", $33[2])
Return $9u
EndFunc
Func _zg($95)
Local $33 = DllCall($8m, "bool", "IsValidSid", "ptr", $95)
If @error Then Return SetError(@error, @extended, False)
Return $33[0]
EndFunc
Func _zh($9x)
Local $9y = UBound($9x, 0), $9z[1][2]
If Not($9y <= 2 And UBound($9x, $9y) = 2 ) Then Return SetError(1300, 0, $9z)
If $9y = 1 Then
Local $a0[1][2]
$a0[0][0] = $9x[0]
$a0[0][1] = $9x[1]
$9x = $a0
$a0 = 0
EndIf
Local $59, $a1 = "dword", $a2 = UBound($9x, 1)
Do
$59 += 1
$a1 &= ";dword;long;dword"
Until $59 = $a2
Local $a3, $a4, $a5, $a6, $a7, $a8, $a9
$a3 = DLLStructCreate($a1)
$a4 = DllStructCreate($a1)
$a5 = DllStructGetPtr($a4)
$a6 = DllStructCreate("dword;long")
DLLStructSetData($a3, 1, $a2)
For $4g = 0 To $a2 - 1
DllCall($8m, "int", "LookupPrivilegeValue", "str", "", "str", $9x[$4g][0], "ptr", DllStructGetPtr($a6) )
DLLStructSetData( $a3, 3 * $4g + 2, DllStructGetData($a6, 1) )
DLLStructSetData( $a3, 3 * $4g + 3, DllStructGetData($a6, 2) )
DLLStructSetData( $a3, 3 * $4g + 4, $9x[$4g][1] )
Next
$a7 = DllCall($8n, "hwnd", "GetCurrentProcess")
$a8 = DllCall($8m, "int", "OpenProcessToken", "hwnd", $a7[0], "dword", BitOR(0x00000020, 0x00000008), "hwnd*", 0 )
DllCall( $8m, "int", "AdjustTokenPrivileges", "hwnd", $a8[3], "int", False, "ptr", DllStructGetPtr($a3), "dword", DllStructGetSize($a3), "ptr", $a5, "dword*", 0 )
$a9 = DllCall($8n, "dword", "GetLastError")
DllCall($8n, "int", "CloseHandle", "hwnd", $a8[3])
Local $aa = DllStructGetData($a4, 1)
If $aa > 0 Then
Local $ab, $ac, $ad, $9z[$aa][2]
For $4g = 0 To $aa - 1
$ab = $a5 + 12 * $4g + 4
$ac = DllCall($8m, "int", "LookupPrivilegeName", "str", "", "ptr", $ab, "ptr", 0, "dword*", 0 )
$ad = DllStructCreate("char[" & $ac[4] & "]")
DllCall($8m, "int", "LookupPrivilegeName", "str", "", "ptr", $ab, "ptr", DllStructGetPtr($ad), "dword*", DllStructGetSize($ad) )
$9z[$4g][0] = DllStructGetData($ad, 1)
$9z[$4g][1] = DllStructGetData($a4, 3 * $4g + 4)
Next
EndIf
Return SetError($a9[0], 0, $9z)
EndFunc
Func _zi($ae = False, $af = True)
Dim $7b
Dim $ag
FileDelete(@TempDir & "\kprm-logo.gif")
If $ae = True Then
If $af = True Then
Run("notepad.exe " & @HomeDrive & "\KPRM" & "\" & $ag)
EndIf
If $7b = False Then
Run(@ComSpec & ' /c timeout 3 && del /F /Q "' & @ScriptFullPath & '"', @TempDir, @SW_HIDE)
FileDelete(@ScriptFullPath)
EndIf
EndIf
Exit
EndFunc
Func _zj()
Local $ah = DllCall('connect.dll', 'long', 'IsInternetConnected')
If @error Then
Return SetError(1, 0, False)
EndIf
Return $ah[0] = 0
EndFunc
Func _zk()
Dim $7c
Dim $7b
If $7b = True Then Return
Local Const $ai = _zj()
If $ai = False Then
Return Null
EndIf
Local Const $aj = _zl("https://kernel-panik.me/_api/v1/kprm/version")
If $aj <> Null And $aj <> "" And $aj <> $7c Then
MsgBox(64, $7q, $7r)
ShellExecute("https://kernel-panik.me/tool/kprm/")
_zi(True, False)
EndIf
EndFunc
_zk()
If Not IsAdmin() Then
MsgBox(16, $7m, $7o)
_zi()
EndIf
Func _zl($ak, $al = "")
Local $am = ObjCreate("WinHttp.WinHttpRequest.5.1")
$am.Open("GET", $ak & "?" & $al, False)
$am.SetTimeouts(50, 50, 50, 50)
If(@error) Then Return SetError(1, 0, 0)
$am.Send()
If(@error) Then Return SetError(2, 0, 0)
If($am.Status <> 200) Then Return SetError(3, 0, 0)
Return SetError(0, 0, $am.ResponseText)
EndFunc
Func _zm($an)
Dim $ag
FileWrite(@HomeDrive & "\KPRM" & "\" & $ag, $an & @CRLF)
EndFunc
Func _zn()
Local $ao = 100, $ap = 100, $aq = 0, $ar = @WindowsDir & "\Explorer.exe"
_hf($3c, 0, 0, 0)
Local $as = _d0("Shell_TrayWnd", "")
_51($as, 1460, 0, 0)
While ProcessExists("Explorer.exe")
Sleep(10)
$ao -= ProcessClose("Explorer.exe") ? 0 : 1
If $ao < 1 Then Return SetError(1, 0, 0)
WEnd
While(Not ProcessExists("Explorer.exe"))
If Not FileExists($ar) Then Return SetError(-1, 0, 0)
Sleep(500)
$aq = ShellExecute($ar)
$ap -= $aq ? 0 : 1
If $ap < 1 Then Return SetError(2, 0, 0)
WEnd
Return $aq
EndFunc
Func _zq($at, $au, $av)
Local $4g = 0
While True
$4g += 1
Local $aw = RegEnumKey($at, $4g)
If @error <> 0 Then ExitLoop
Local $ax = $at & "\" & $aw
Local $9l = RegRead($ax, $av)
If StringRegExp($9l, $au) Then
Return $ax
EndIf
WEnd
Return Null
EndFunc
Func _zs()
Local $ay = []
If FileExists(@HomeDrive & "\Program Files") Then
_vv($ay, @HomeDrive & "\Program Files")
EndIf
If FileExists(@HomeDrive & "\Program Files (x86)") Then
_vv($ay, @HomeDrive & "\Program Files (x86)")
EndIf
If FileExists(@HomeDrive & "\Program Files(x86)") Then
_vv($ay, @HomeDrive & "\Program Files(x86)")
EndIf
Return $ay
EndFunc
Func _zt($5r)
Return Int(FileExists($5r) And StringInStr(FileGetAttrib($5r), 'D', Default, 1) = 0)
EndFunc
Func _zu($5r)
Return Int(FileExists($5r) And StringInStr(FileGetAttrib($5r), 'D', Default, 1) > 0)
EndFunc
Func _zv($5r)
Local $az = Null
If FileExists($5r) Then
Local $b0 = StringInStr(FileGetAttrib($5r), 'D', Default, 1)
If $b0 = 0 Then
$az = 'file'
ElseIf $b0 > 0 Then
$az = 'folder'
EndIf
EndIf
Return $az
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
Func _zx($av)
If StringRegExp($av, "^(HKLM|HKCU|HKU|HKCR|HKCC)64") Then
Local $b1 = StringReplace($av, "64", "", 1)
Return $b1
EndIf
Return $av
EndFunc
Func _zy($b2, $av)
If $b2.Exists($av) Then
Local $b0 = $b2.Item($av) + 1
$b2.Item($av) = $b0
Else
$b2.add($av, 1)
EndIf
Return $b2
EndFunc
Func _0zz($b3, $b4, $b5)
Dim $b6
Local $b7 = $b6.Item($b3)
Local $b8 = _zy($b7.Item($b4), $b5)
$b7.Item($b4) = $b8
$b6.Item($b3) = $b7
EndFunc
Func _100($9g, $b9)
If $9g = Null Or $9g = "" Then Return
Local $ba = ProcessExists($9g)
If $ba <> 0 Then
_zm("     [X] Process " & $9g & " not killed, it is possible that the deletion is not complete (" & $b9 & ")")
Else
_zm("     [OK] Process " & $9g & " killed (" & $b9 & ")")
EndIf
EndFunc
Func _101($bb, $b9)
If $bb = Null Or $bb = "" Then Return
Local $bc = "[X]"
RegEnumVal($bb, "1")
If @error >= 0 Then
$bc = "[OK]"
EndIf
_zm("     " & $bc & " " & _zx($bb) & " deleted (" & $b9 & ")")
EndFunc
Func _102($bb, $b9)
If $bb = Null Or $bb = "" Then Return
Local $78 = "", $79 = "", $5x = "", $7a = ""
Local $bd = _xe($bb, $78, $79, $5x, $7a)
If $7a = ".exe" Then
Local $be = $bd[1] & $bd[2]
Local $bc = "[OK]"
If FileExists($be) Then
$bc = "[X]"
EndIf
_zm("     " & $bc & " Uninstaller run correctly (" & $b9 & ")")
EndIf
EndFunc
Func _103($bb, $b9)
If $bb = Null Or $bb = "" Then Return
Local $bc = "[OK]"
If FileExists($bb) Then
$bc = "[X]"
EndIf
_zm("     " & $bc & " " & $bb & " deleted (" & $b9 & ")")
EndFunc
Func _104($bf, $bb, $b9)
Switch $bf
Case "process"
_100($bb, $b9)
Case "key"
_101($bb, $b9)
Case "uninstall"
_102($bb, $b9)
Case "element"
_103($bb, $b9)
Case Else
_zm("     [?] Unknown type " & $bf)
EndSwitch
EndFunc
Local $bg = 43
Local $bh
Local Const $bi = Floor(100 / $bg)
Func _105($bj = 1)
$bh += $bj
Dim $bk
GUICtrlSetData($bk, $bh * $bi)
If $bh = $bg Then
GUICtrlSetData($bk, 100)
EndIf
EndFunc
Func _106()
$bh = 0
Dim $bk
GUICtrlSetData($bk, 0)
EndFunc
Func _107()
_zm(@CRLF & "- Clear All System Restore Points -" & @CRLF)
Local Const $bl = _y2()
Local $9j = 0
If $bl[0][0] = 0 Then
_zm("  [I] No system recovery points were found")
Return Null
EndIf
Local $bm[1][3] = [[Null, Null, Null]]
For $4g = 1 To $bl[0][0]
Local $ba = _y4($bl[$4g][0])
$9j += $ba
If $ba = 1 Then
_zm("    => [OK] RP named " & $bl[$4g][1] & " created at " & $bl[$4g][2] & " deleted")
Else
Local $bn[1][3] = [[$bl[$4g][0], $bl[$4g][1], $bl[$4g][2]]]
_vv($bm, $bn)
EndIf
Next
If 1 < UBound($bm) Then
Sleep(3000)
For $4g = 1 To UBound($bm) - 1
Local $ba = _y4($bm[$4g][0])
$9j += $ba
If $ba = 1 Then
_zm("    => [OK] RP named " & $bm[$4g][1] & " created at " & $bl[$4g][2] & " deleted")
Else
_zm("    => [X] RP named " & $bm[$4g][1] & " created at " & $bl[$4g][2] & " deleted")
EndIf
Next
EndIf
If $bl[0][0] = $9j Then
_zm(@CRLF & "  [OK] All system restore points have been successfully deleted")
Else
_zm(@CRLF & "  [X] Failure when deleting all restore points")
EndIf
EndFunc
Func _108($85)
Local $bo = StringLeft($85, 4)
Local $bp = StringMid($85, 6, 2)
Local $bq = StringMid($85, 9, 2)
Local $5l = StringRight($85, 8)
Return $bp & "/" & $bq & "/" & $bo & " " & $5l
EndFunc
Func _109($br = False)
Local Const $bl = _y2()
If $bl[0][0] = 0 Then
Return Null
EndIf
Local Const $bs = _108(_31('n', -1470, _3p()))
Local $bt = False
Local $bu = False
Local $bv = False
For $4g = 1 To $bl[0][0]
Local $bw = $bl[$4g][2]
If $bw > $bs Then
If $bv = False Then
$bv = True
$bu = True
_zm(@CRLF & "  [I] Recent System Restore Point Deletion before create new:" & @CRLF)
EndIf
Local $ba = _y4($bl[$4g][0])
If $ba = 1 Then
_zm("    => [OK] RP named " & $bl[$4g][1] & " created at " & $bw & " deleted")
ElseIf $br = False Then
$bt = True
Else
_zm("    => [X] RP named " & $bl[$4g][1] & " created at " & $bw & " deleted")
EndIf
EndIf
Next
If $bt = True Then
Sleep(3000)
_zm("  [I] Retry deleting restore point")
_109(True)
EndIf
If $bu = True Then
_zm(@CRLF)
EndIf
Sleep(3000)
EndFunc
Func _10a()
Sleep(3000)
_zm(@CRLF & "- Display All System Restore Point -" & @CRLF)
Local Const $bl = _y2()
If $bl[0][0] = 0 Then
_zm("  [X] No System Restore point found")
Return
EndIf
For $4g = 1 To $bl[0][0]
_zm("    => [I] RP named " & $bl[$4g][1] & " created at " & $bl[$4g][2] & " found")
Next
EndFunc
Func _10b()
RunWait(@ComSpec & ' /c ' & 'wmic.exe /Namespace:\\root\default Path SystemRestore Call CreateRestorePoint "KpRm", 100, 7', "", @SW_HIDE)
Return @error
EndFunc
Func _10c($br = False)
If $br = False Then
_zm(@CRLF & "- Create New System Restore Point -" & @CRLF)
Else
_zm("  [I] Retry Create New System Restore Point")
EndIf
Dim $bx
Local $by = _y6()
If $by = 0 Then
Sleep(3000)
$by = _y6()
If $by = 0 Then
_zm("  [X] Enable System Restore")
EndIf
ElseIf $by = 1 Then
_zm("  [OK] Enable System Restore")
EndIf
_109()
Local Const $bz = _10b()
If $bz <> 0 Then
_zm("  [X] System Restore Point created")
If $br = False Then
_zm("  [I] Retry to create System Restore Point!")
_10c(True)
Return
Else
_10a()
Return
EndIf
ElseIf $bz = 0 Then
_zm("  [OK] System Restore Point created")
_10a()
EndIf
EndFunc
Func _10d()
_zm(@CRLF & "- Create Registry Backup -" & @CRLF)
Local Const $c0 = @HomeDrive & "\KPRM"
Local Const $c1 = $c0 & "\regedit-backup-" & @YEAR & @MON & @MDAY & @HOUR & @MIN & ".reg"
If FileExists($c1) Then
FileMove($c1, $c1 & ".old")
EndIf
Local Const $ba = RunWait("Regedit /e " & $c1)
If Not FileExists($c1) Or @error <> 0 Then
_zm("  [X] Failed to create registry backup")
MsgBox(16, $7m, $7n)
_zi()
Else
_zm("  [OK] Registry Backup: " & $c1)
EndIf
EndFunc
Func _10e()
_zm(@CRLF & "- Restore UAC Default Value -" & @CRLF)
Local $ba = _xr()
If $ba = 1 Then
_zm("  [OK] Set ConsentPromptBehaviorAdmin with default (5) value")
Else
_zm("  [X] Set ConsentPromptBehaviorAdmin with default value")
EndIf
Local $ba = _xs(3)
If $ba = 1 Then
_zm("  [OK] Set ConsentPromptBehaviorUser with default (3) value")
Else
_zm("  [X] Set ConsentPromptBehaviorUser with default value")
EndIf
Local $ba = _xt()
If $ba = 1 Then
_zm("  [OK] Set EnableInstallerDetection with default (0) value")
Else
_zm("  [X] Set EnableInstallerDetection with default value")
EndIf
Local $ba = _xu()
If $ba = 1 Then
_zm("  [OK] Set EnableLUA with default (1) value")
Else
_zm("  [X] Set EnableLUA with default value")
EndIf
Local $ba = _xv()
If $ba = 1 Then
_zm("  [OK] Set EnableSecureUIAPaths with default (1) value")
Else
_zm("  [X] Set EnableSecureUIAPaths with default value")
EndIf
Local $ba = _xw()
If $ba = 1 Then
_zm("  [OK] Set EnableUIADesktopToggle with default (0) value")
Else
_zm("  [X] Set EnableUIADesktopToggle with default value")
EndIf
Local $ba = _xx()
If $ba = 1 Then
_zm("  [OK] Set EnableVirtualization with default (1) value")
Else
_zm("  [X] Set EnableVirtualization with default value")
EndIf
Local $ba = _xy()
If $ba = 1 Then
_zm("  [OK] Set FilterAdministratorToken with default (0) value")
Else
_zm("  [X] Set FilterAdministratorToken with default value")
EndIf
Local $ba = _xz()
If $ba = 1 Then
_zm("  [OK] Set PromptOnSecureDesktop with default (1) value")
Else
_zm("  [X] Set PromptOnSecureDesktop with default value")
EndIf
Local $ba = _y0()
If $ba = 1 Then
_zm("  [OK] Set ValidateAdminCodeSignatures with default (0) value")
Else
_zm("  [X] Set ValidateAdminCodeSignatures with default value")
EndIf
EndFunc
Func _10f()
_zm(@CRLF & "- Restore Default System Settings -" & @CRLF)
Local $ba = RunWait(@ComSpec & " /c " & "ipconfig /flushdns", @TempDir, @SW_HIDE)
If @error <> 0 Then
_zm("  [X] Flush DNS")
Else
_zm("  [OK] Flush DNS")
EndIf
Local Const $c2[7] = [ "netsh winsock reset", "netsh winhttp reset proxy", "netsh winhttp reset tracing", "netsh winsock reset catalog", "netsh int ip reset all", "netsh int ipv4 reset catalog", "netsh int ipv6 reset catalog" ]
$ba = 0
For $4g = 0 To UBound($c2) -1
RunWait(@ComSpec & " /c " & $c2[$4g], @TempDir, @SW_HIDE)
If @error <> 0 Then
$ba += 1
EndIf
Next
If $ba = 0 Then
_zm("  [OK] Reset WinSock")
Else
_zm("  [X] Reset WinSock")
EndIf
Local $c3 = "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced"
$ba = RegWrite($c3, "Hidden", "REG_DWORD", "2")
If $ba = 1 Then
_zm("  [OK] Hide Hidden file.")
Else
_zm("  [X] Hide Hidden File")
EndIf
$ba = RegWrite($c3, "HideFileExt", "REG_DWORD", "0")
If $ba = 1 Then
_zm("  [OK] Hide Extensions for known file types")
Else
_zm("  [X] Hide Extensions for known file types")
EndIf
$ba = RegWrite($c3, "ShowSuperHidden", "REG_DWORD", "0")
If $ba = 1 Then
_zm("  [OK] Hide protected operating system files")
Else
_zm("  [X] Hide protected operating system files")
EndIf
_zn()
EndFunc
Global $b6 = ObjCreate("Scripting.Dictionary")
Local Const $c4[55] = [ "AdliceDiag", "AdsFix", "AdwCleaner", "AHK_NavScan", "AswMBR", "Avast Decryptor Cryptomix", "Avenger", "BlitzBlank", "CKScanner", "CMD_Command", "Combofix", "DDS", "Decrypt CryptON", "Defogger", "ESET Online Scanner", "FRST", "FSS", "g3n-h@ckm@n tools", "Grantperms", "Hosts-perm", "JavaRa", "ListCWall", "ListParts", "LogonFix", "Malwarebytes Anti-Rootkit", "MiniregTool", "Minitoolbox", "OTL", "OTM", "QuickDiag", "Rakhni Decryptor", "RegtoolExport", "Remediate VBS Worm", "Report_CHKDSK", "Rkill", "RogueKiller", "RstAssociations", "RstHosts", "ScanRapide", "SEAF", "SecurityCheck", "SFT", "Systemlook", "TDSSKiller", "ToolsDiag", "USBFix", "WinCHK", "WinUpdatefix", "ZHP Tools", "ZHPCleaner", "ZHPDiag", "ZHPFix", "ZHPLite", "Zoek"]
For $c5 = 0 To UBound($c4) - 1
Local $c6 = ObjCreate("Scripting.Dictionary")
Local $c7 = ObjCreate("Scripting.Dictionary")
Local $c8 = ObjCreate("Scripting.Dictionary")
Local $c9 = ObjCreate("Scripting.Dictionary")
Local $ca = ObjCreate("Scripting.Dictionary")
$c6.add("key", $c7)
$c6.add("element", $c8)
$c6.add("uninstall", $c9)
$c6.add("process", $ca)
$b6.add($c4[$c5], $c6)
Next
Global $cb[1][3] = [[Null, Null, Null]]
Global $cc[1][5] = [[Null, Null, Null, Null, Null]]
Global $cd[1][5] = [[Null, Null, Null, Null, Null]]
Global $ce[1][5] = [[Null, Null, Null, Null, Null]]
Global $cf[1][5] = [[Null, Null, Null, Null, Null]]
Global $cg[1][5] = [[Null, Null, Null, Null, Null]]
Global $ch[1][2] = [[Null, Null]]
Global $ci[1][2] = [[Null, Null]]
Global $cj[1][4] = [[Null, Null, Null, Null]]
Global $ck[1][5] = [[Null, Null, Null, Null, Null]]
Global $cl[1][5] = [[Null, Null, Null, Null, Null]]
Global $cm[1][5] = [[Null, Null, Null, Null, Null]]
Global $cn[1][5] = [[Null, Null, Null, Null, Null]]
Global $co[1][5] = [[Null, Null, Null, Null, Null]]
Global $cp[1][3] = [[Null, Null, Null]]
Global $cq[1][3] = [[Null, Null, Null]]
Global $cr[1][4] = [[Null, Null, Null, Null]]
Func _10g($at, $cs = 0, $ct = False)
If $ct Then
_yx($at)
_yf($at)
EndIf
Local Const $cu = FileGetAttrib($at)
If StringInStr($cu, "R") Then
FileSetAttrib($at, "-R", $cs)
EndIf
If StringInStr($cu, "S") Then
FileSetAttrib($at, "-S", $cs)
EndIf
If StringInStr($cu, "H") Then
FileSetAttrib($at, "-H", $cs)
EndIf
If StringInStr($cu, "A") Then
FileSetAttrib($at, "-A", $cs)
EndIf
EndFunc
Func _10h($cv, $b3, $cw = Null, $ct = False)
Local Const $cx = _zt($cv)
If $cx Then
If $cw And StringRegExp($cv, "(?i)\.(exe|com)$") Then
Local Const $cy = FileGetVersion($cv, "CompanyName")
If @error Then
Return 0
ElseIf Not StringRegExp($cy, $cw) Then
Return 0
EndIf
EndIf
_0zz($b3, 'element', $cv)
_10g($cv, 0, $ct)
Local $cz = FileDelete($cv)
If $cz Then
Return 1
EndIf
Return 2
EndIf
Return 0
EndFunc
Func _10i($at, $b3, $ct = False)
Local $cx = _zu($at)
If $cx Then
_0zz($b3, 'element', $at)
_10g($at, 1, $ct)
Local Const $cz = DirRemove($at, $q)
If $cz Then
Return 1
EndIf
Return 2
EndIf
Return 0
EndFunc
Func _10j($at, $cv, $d0)
Local Const $d1 = $at & "\" & $cv
Local Const $5z = FileFindFirstFile($d1)
Local $d2 = []
If $5z = -1 Then
Return $d2
EndIf
Local $5x = FileFindNextFile($5z)
While @error = 0
If StringRegExp($5x, $d0) Then
_vv($d2, $at & "\" & $5x)
EndIf
$5x = FileFindNextFile($5z)
WEnd
FileClose($5z)
Return $d2
EndFunc
Func _10k($d3, $d4)
Local $d5 = _zv($d3)
If $d5 = Null Then
Return Null
EndIf
Local $78 = "", $79 = "", $5x = "", $7a = ""
Local $bd = _xe($d3, $78, $79, $5x, $7a)
Local $d6 = $5x & $7a
For $d7 = 1 To UBound($d4) - 1
If $d4[$d7][3] And $d5 = $d4[$d7][1] And StringRegExp($d6, $d4[$d7][3]) Then
Local $ba = 0
Local $ct = False
If $d4[$d7][4] = True Then
$ct = True
EndIf
If $d5 = 'file' Then
$ba = _10h($d3, $d4[$d7][0], $d4[$d7][2], $ct)
ElseIf $d5 = 'folder' Then
$ba = _10i($d3, $d4[$d7][0], $ct)
EndIf
EndIf
Next
EndFunc
Func _10l($at, $d4, $d8 = -2)
Local $46 = _x2($at, "*.exe;*.txt;*.lnk;*.log;*.reg;*.zip;*.dat;*.scr;*.com;*.bat", $t, $d8, $y, $10)
If @error <> 0 Then
Return Null
EndIf
For $4g = 1 To $46[0]
_10k($46[$4g], $d4)
Next
EndFunc
Func _10m($at, $d4)
Local Const $d1 = $at & "\*"
Local Const $5z = FileFindFirstFile($d1)
If $5z = -1 Then
Return Null
EndIf
Local $5x = FileFindNextFile($5z)
While @error = 0
Local $d3 = $at & "\" & $5x
_10k($d3, $d4)
$5x = FileFindNextFile($5z)
WEnd
FileClose($5z)
EndFunc
Func _10n($av, $b3, $ct = False)
If $ct = True Then
_yx($av)
_yf($av, $8c)
EndIf
Local Const $ba = RegDelete($av)
If $ba <> 0 Then
_0zz($b3, "key", $av)
EndIf
Return $ba
EndFunc
Func _10o($9g, $ct)
Local $d9 = 50
Local $ba = Null
If 0 = ProcessExists($9g) Then Return 0
If $ct = True Then
_yt($9g)
If 0 = ProcessExists($9g) Then Return 0
EndIf
ProcessClose($9g)
Do
$d9 -= 1
Sleep(250)
Until($d9 = 0 Or 0 = ProcessExists($9g))
$ba = ProcessExists($9g)
If 0 = $ba Then
Return 1
EndIf
Return 0
EndFunc
Func _10p($da)
Dim $d9
Local $db = ProcessList()
For $4g = 1 To $db[0][0]
Local $dc = $db[$4g][0]
Local $dd = $db[$4g][1]
For $d9 = 1 To UBound($da) - 1
If StringRegExp($dc, $da[$d9][1]) Then
_10o($dd, $da[$d9][2])
_0zz($da[$d9][0], "process", $dc)
EndIf
Next
Next
EndFunc
Func _10q($de)
For $4g = 1 To UBound($de) - 1
RunWait('schtasks.exe /delete /tn "' & $de[$4g][1] & '" /f', @TempDir, @SW_HIDE)
Next
EndFunc
Func _10r($de)
Local Const $ay = _zs()
For $4g = 1 To UBound($ay) - 1
For $df = 1 To UBound($de) - 1
Local $dg = $de[$df][1]
Local $dh = $de[$df][2]
Local $di = _10j($ay[$4g], "*", $dg)
For $dj = 1 To UBound($di) - 1
Local $dk = _10j($di[$dj], "*", $dh)
For $dl = 1 To UBound($dk) - 1
If _zt($dk[$dl]) Then
RunWait($dk[$dl])
_0zz($de[$df][0], "uninstall", $dk[$dl])
EndIf
Next
Next
Next
Next
EndFunc
Func _10s($de)
Local Const $ay = _zs()
For $4g = 1 To UBound($ay) - 1
_10m($ay[$4g], $de)
Next
EndFunc
Func _10t($de)
Local $7x = ""
If @OSArch = "X64" Then $7x = "64"
Local $dm[2] = ["HKCU" & $7x & "\SOFTWARE", "HKLM" & $7x & "\SOFTWARE"]
For $59 = 0 To UBound($dm) - 1
Local $4g = 0
While True
$4g += 1
Local $aw = RegEnumKey($dm[$59], $4g)
If @error <> 0 Then ExitLoop
For $df = 1 To UBound($de) - 1
If $aw And $de[$df][1] Then
If StringRegExp($aw, $de[$df][1]) Then
Local $dn = $dm[$59] & "\" & $aw
_10n($dn, $de[$df][0])
EndIf
EndIf
Next
WEnd
Next
EndFunc
Func _10u($de)
For $4g = 1 To UBound($de) - 1
Local $dn = _zq($de[$4g][1], $de[$4g][2], $de[$4g][3])
If $dn And $dn <> "" Then
_10n($dn, $de[$4g][0])
EndIf
Next
EndFunc
Func _10v($de)
For $4g = 1 To UBound($de) - 1
_10n($de[$4g][1], $de[$4g][0], $de[$4g][2])
Next
EndFunc
Func _10w($de)
For $4g = 1 To UBound($de) - 1
If FileExists($de[$4g][1]) Then
Local $do = _x1($de[$4g][1])
If @error = 0 Then
For $dj = 1 To $do[0]
_10h($de[$4g][1] & '\' & $do[$dj], $de[$4g][0], $de[$4g][2], $de[$4g][3])
Next
EndIf
EndIf
Next
EndFunc
Func _10x()
Local Const $dp = "FRST"
Dim $cb
Dim $cc
Dim $dq
Dim $ce
Dim $dr
Dim $cg
Local Const $cw = "(?i)^Farbar"
Local Const $ds = "(?i)^FRST.*\.exe$"
Local Const $dt = "(?i)^FRST-OlderVersion$"
Local Const $du = "(?i)^(FRST|fixlist|fixlog|Addition|Shortcut).*\.(exe|txt)$"
Local Const $dv = "(?i)^FRST"
Local Const $dw[1][3] = [[$dp, $ds, False]]
Local Const $dx[1][5] = [[$dp, 'file', $cw, $du, False]]
Local Const $dy[1][5] = [[$dp, 'folder', Null, $dt, False]]
Local Const $dz[1][5] = [[$dp, 'folder', Null, $dv, True]]
_vv($cb, $dw)
_vv($cc, $dx)
_vv($ce, $dx)
_vv($cc, $dy)
_vv($ce, $dy)
_vv($cg, $dz)
EndFunc
_10x()
Func _10y()
Dim $cm
Dim $ch
Local $dp = "ZHP Tools"
Local Const $b0[1][2] = [[$dp, "(?i)^ZHP$"]]
Local Const $e0[1][5] = [[$dp, 'folder', Null, "(?i)^ZHP$", True]]
_vv($ch, $b0)
_vv($cm, $e0)
EndFunc
_10y()
Func _10z()
Local Const $e1 = Null
Local Const $dp = "ZHPDiag"
Dim $cb
Dim $cc
Dim $cd
Dim $ce
Dim $cg
Local Const $ds = "(?i)^ZHPDiag.*\.exe$"
Local Const $dt = "(?i)^ZHPDiag.*\.(exe|txt|lnk)$"
Local Const $du = "(?i)^PhysicalDisk[0-9]_MBR\.bin$"
Local Const $dw[1][3] = [[$dp, $ds, False]]
Local Const $dx[1][5] = [[$dp, 'file', $e1, $dt, False]]
Local Const $dy[1][5] = [[$dp, 'file', Null, $du, True]]
_vv($cb, $dw)
_vv($cc, $dx)
_vv($ce, $dx)
_vv($cd, $dx)
_vv($cg, $dy)
EndFunc
_10z()
Func _110()
Local Const $e1 = Null
Local Const $e2 = "ZHPFix"
Dim $cb
Dim $cc
Dim $ce
Local Const $ds = "(?i)^ZHPFix.*\.exe$"
Local Const $dt = "(?i)^ZHPFix.*\.(exe|txt|lnk)$"
Local Const $dw[1][3] = [[$e2, $ds, False]]
Local Const $dx[1][5] = [[$e2, 'file', $e1, $dt, False]]
_vv($cb, $dw)
_vv($cc, $dx)
_vv($ce, $dx)
EndFunc
_110()
Func _111()
Local Const $e1 = Null
Local Const $e2 = "ZHPLite"
Dim $cb
Dim $cc
Dim $ce
Local Const $ds = "(?i)^ZHPLite.*\.exe$"
Local Const $dt = "(?i)^ZHPLite.*\.(exe|txt|lnk)$"
Local Const $dw[1][3] = [[$e2, $ds, False]]
Local Const $dx[1][5] = [[$e2, 'file', $e1, $dt, False]]
_vv($cb, $dw)
_vv($cc, $dx)
_vv($ce, $dx)
EndFunc
_111()
Func _112($br = False)
Local Const $cw = "(?i)^Malwarebytes Anti-Rootkit$"
Local Const $e3 = "(?i)^Malwarebytes"
Local Const $dp = "Malwarebytes Anti-Rootkit"
Dim $cb
Dim $cc
Dim $ce
Dim $ch
Dim $cr
Local Const $ds = "(?i)^mbar.*\.exe$"
Local Const $dt = "(?i)^mbar"
Local Const $dw[1][3] = [[$dp, $ds, True]]
Local Const $dx[1][2] = [[$dp, $cw]]
Local Const $dy[1][5] = [[$dp, 'file', $e3, $ds, False]]
Local Const $dz[1][5] = [[$dp, 'folder', $cw, $dt, False]]
Local Const $e4[1][4] = [[$dp, @AppDataCommonDir & "\Malwarebytes\Malwarebytes' Anti-Malware\Quarantine", Null, True]]
_vv($cb, $dw)
_vv($cc, $dy)
_vv($ce, $dy)
_vv($cc, $dz)
_vv($ce, $dz)
_vv($ch, $dx)
_vv($cr, $e4)
EndFunc
_112()
Func _113()
Local Const $dp = "RogueKiller"
Dim $cb
Dim $ci
Dim $cj
Dim $cf
Dim $ck
Dim $cc
Dim $cd
Dim $cn
Dim $ce
Local $7x = ""
If @OSArch = "X64" Then $7x = "64"
Local Const $e5 = "(?i)^Adlice"
Local Const $ds = "(?i)^RogueKiller"
Local Const $dt = "(?i)^RogueKiller.*\.(exe|lnk|txt)$"
Local Const $du = "(?i)^RogueKiller.*\.exe$"
Local Const $dv = "(?i)^RogueKiller_portable(32|64)\.exe$"
Local Const $dw[1][3] = [[$dp, $du, False]]
Local Const $dx[1][2] = [[$dp, "RogueKiller Anti-Malware"]]
Local Const $dy[1][4] = [[$dp, "HKLM" & $7x & "\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall", $ds, "DisplayName"]]
Local Const $dz[1][5] = [[$dp, 'file', $e5, $dt, False]]
Local Const $e4[1][5] = [[$dp, 'folder', Null, $ds, True]]
Local Const $e6[1][5] = [[$dp, 'file', Null, $dv, False]]
_vv($cb, $dw)
_vv($ci, $dx)
_vv($cj, $dy)
_vv($cf, $e4)
_vv($ck, $e4)
_vv($cc, $e6)
_vv($cc, $dz)
_vv($cc, $e4)
_vv($ce, $e6)
_vv($ce, $dz)
_vv($ce, $e4)
_vv($cd, $dz)
_vv($cn, $e4)
EndFunc
_113()
Func _114()
Local Const $dp = "AdwCleaner"
Local Const $cw = "(?i)^AdwCleaner"
Local Const $e3 = "(?i)^Malwarebytes"
Local Const $ds = "(?i)^AdwCleaner.*\.exe$"
Dim $cb
Dim $cc
Dim $ce
Dim $cg
Local Const $dw[1][3] = [[$dp, $ds, False]]
Local Const $dx[1][5] = [[$dp, 'file', $e3, $ds, False]]
Local Const $dy[1][5] = [[$dp, 'folder', Null, $cw, True]]
_vv($cb, $dw)
_vv($cc, $dx)
_vv($ce, $dx)
_vv($cg, $dy)
EndFunc
_114()
Func _115()
Local Const $e1 = Null
Local Const $dp = "ZHPCleaner"
Dim $cb
Dim $cc
Dim $ce
Local Const $ds = "(?i)^ZHPCleaner.*\.exe$"
Local Const $dt = "(?i)^ZHPCleaner.*\.(exe|txt|lnk)$"
Local Const $dw[1][3] = [[$dp, $ds, False]]
Local Const $dx[1][5] = [[$dp, 'file', $e1, $dt, False]]
_vv($cb, $dw)
_vv($cc, $dx)
_vv($ce, $dx)
EndFunc
_115()
Func _116()
Local Const $dp = "USBFix"
Dim $cb
Dim $cp
Dim $cc
Dim $cd
Dim $ce
Dim $ch
Dim $cg
Dim $cf
Local Const $cw = "(?i)^UsbFix"
Local Const $e3 = "(?i)^SosVirus"
Local Const $ds = "(?i)^UsbFix.*\.(exe|lnk|txt)$"
Local Const $dt = "(?i)^Un-UsbFix\.exe$"
Local Const $du = "(?i)^UsbFixQuarantine$"
Local Const $dv = "(?i)^UsbFix.*\.exe$"
Local Const $e7[1][3] = [[$dp, $dv, False]]
Local Const $dw[1][2] = [[$dp, $cw]]
Local Const $dx[1][3] = [[$dp, $cw, $dt]]
Local Const $dy[1][5] = [[$dp, 'file', $e3, $ds, False]]
Local Const $dz[1][5] = [[$dp, 'folder', Null, $du, True]]
Local Const $e4[1][5] = [[$dp, 'folder', Null, $cw, False]]
_vv($cb, $e7)
_vv($cp, $dx)
_vv($cc, $dy)
_vv($cd, $dy)
_vv($ce, $dy)
_vv($ch, $dw)
_vv($cg, $dz)
_vv($cg, $e4)
_vv($cf, $e4)
EndFunc
_116()
Func _117()
Local Const $dp = "AdsFix"
Dim $cb
Dim $cc
Dim $ce
Dim $cg
Dim $cd
Dim $ch
Local Const $cw = "(?i)^AdsFix"
Local Const $e3 = "(?i)^SosVirus"
Local Const $ds = "(?i)^AdsFix.*\.exe$"
Local Const $dt = "(?i)^AdsFix.*\.(exe|txt|lnk)$"
Local Const $du = "(?i)^AdsFix.*\.txt$"
Local Const $dw[1][3] = [[$dp, $ds, False]]
Local Const $dx[1][5] = [[$dp, 'file', $e3, $dt, False]]
Local Const $dy[1][5] = [[$dp, 'file', Null, $du, False]]
Local Const $dz[1][5] = [[$dp, 'folder', Null, $cw, True]]
Local Const $e4[1][2] = [[$dp, $cw]]
_vv($cb, $dw)
_vv($cc, $dx)
_vv($cd, $dx)
_vv($ce, $dx)
_vv($cg, $dy)
_vv($cg, $dz)
_vv($ch, $e4)
EndFunc
_117()
Func _118()
Local Const $dp = "AswMBR"
Dim $cb
Dim $cc
Dim $ce
Dim $cq
Local Const $cw = "(?i)^avast"
Local Const $ds = "(?i)^aswmbr.*\.(exe|txt|lnk)$"
Local Const $dt = "(?i)^MBR\.dat$"
Local Const $du = "(?i)^aswmbr.*\.exe$"
Local $7x = ""
If @OSArch = "X64" Then $7x = "64"
Local Const $dw[1][3] = [[$dp, $du, True]]
Local Const $dx[1][5] = [[$dp, 'file', $cw, $ds, False]]
Local Const $dy[1][5] = [[$dp, 'file', Null, $dt, False]]
Local Const $dz[1][3] = [[$dp, "HKLM" & $7x & "\SYSTEM\CurrentControlSet\Enum\Root\LEGACY_ASWMBR", True]]
_vv($cb, $dw)
_vv($cc, $dx)
_vv($cc, $dy)
_vv($ce, $dx)
_vv($ce, $dy)
_vv($cq, $dz)
EndFunc
_118()
Func _119()
Local Const $dp = "FSS"
Dim $cb
Dim $cc
Dim $ce
Local Const $cw = "(?i)^Farbar"
Local Const $ds = "(?i)^FSS.*\.(exe|txt|lnk)$"
Local Const $dt = "(?i)^FSS.*\.exe$"
Local Const $dw[1][3] = [[$dp, $dt, False]]
Local Const $dx[1][5] = [[$dp, 'file', $cw, $ds, False]]
_vv($cb, $dw)
_vv($cc, $dx)
_vv($ce, $dx)
EndFunc
_119()
Func _11a()
Local Const $dp = "ToolsDiag"
Dim $cb
Dim $cc
Dim $ce
Dim $cg
Local Const $ds = "(?i)^toolsdiag.*\.exe$"
Local Const $dt = "(?i)^ToolsDiag$"
Local Const $dw[1][5] = [[$dp, 'folder', Null, $dt, False]]
Local Const $dx[1][5] = [[$dp, 'file', Null, $ds, False]]
Local Const $dy[1][3] = [[$dp, $ds, False]]
_vv($cb, $dy)
_vv($cc, $dx)
_vv($ce, $dx)
_vv($cg, $dw)
EndFunc
_11a()
Func _11b()
Local Const $dp = "ScanRapide"
Dim $cg
Dim $cc
Dim $ce
Local Const $cw = Null
Local Const $ds = "(?i)^ScanRapide.*\.exe$"
Local Const $dt = "(?i)^ScanRapide\[R[0-9]+\]\.txt$"
Local Const $dw[1][5] = [[$dp, 'file', $cw, $ds, False]]
Local Const $dx[1][5] = [[$dp, 'file', Null, $dt, False]]
_vv($cc, $dw)
_vv($ce, $dw)
_vv($cg, $dx)
EndFunc
_11b()
Func _11c()
Local Const $dp = "OTL"
Dim $cb
Dim $cc
Dim $ce
Dim $cg
Dim $ch
Local Const $cw = "(?i)^OldTimer"
Local Const $ds = "(?i)^OTL.*\.exe$"
Local Const $dt = "(?i)^OTL.*\.(exe|txt)$"
Local Const $du = "(?i)^Extras\.txt$"
Local Const $dv = "(?i)^_OTL$"
Local Const $e8 = "(?i)^OldTimer Tools$"
Local Const $dw[1][3] = [[$dp, $ds, False]]
Local Const $dx[1][5] = [[$dp, 'file', $cw, $dt, False]]
Local Const $dy[1][5] = [[$dp, 'file', Null, $du, False]]
Local Const $dz[1][5] = [[$dp, 'folder', Null, $dv, True]]
Local Const $e4[1][2] = [[$dp, $e8]]
_vv($cb, $dw)
_vv($cc, $dx)
_vv($cc, $dy)
_vv($ce, $dx)
_vv($cg, $dz)
_vv($ch, $e4)
EndFunc
_11c()
Func _11d()
Local Const $dp = "OTM"
Dim $cb
Dim $cc
Dim $ce
Dim $cg
Local Const $cw = "(?i)^OldTimer"
Local Const $ds = "(?i)^OTM.*\.exe$"
Local Const $dt = "(?i)^_OTM$"
Local Const $dw[1][3] = [[$dp, $ds, False]]
Local Const $dx[1][5] = [[$dp, 'file', $cw, $ds, False]]
Local Const $dy[1][5] = [[$dp, 'folder', Null, $dt, True]]
_vv($cb, $dw)
_vv($cc, $dx)
_vv($ce, $dx)
_vv($cg, $dy)
EndFunc
_11d()
Func _11e()
Local Const $dp = "ListParts"
Dim $cb
Dim $cc
Dim $ce
Dim $cg
Local Const $cw = "(?i)^Farbar"
Local Const $ds = "(?i)^listParts.*\.exe$"
Local Const $dt = "(?i)^Results\.txt$"
Local Const $dw[1][3] = [[$dp, $ds, False]]
Local Const $dx[1][5] = [[$dp, 'file', $cw, $ds, False]]
Local Const $dy[1][5] = [[$dp, 'file', Null, $dt, False]]
_vv($cb, $dw)
_vv($cc, $dx)
_vv($cc, $dy)
_vv($ce, $dx)
_vv($ce, $dy)
EndFunc
_11e()
Func _11f()
Local Const $dp = "Minitoolbox"
Dim $cb
Dim $cc
Dim $ce
Dim $cg
Local Const $cw = "(?i)^Farbar"
Local Const $ds = "(?i)^MiniToolBox.*\.exe$"
Local Const $dt = "(?i)^MTB\.txt$"
Local Const $dw[1][2] = [[$dp, $ds]]
Local Const $dx[1][5] = [[$dp, 'file', $cw, $ds, False]]
Local Const $dy[1][5] = [[$dp, 'file', Null, $dt, False]]
_vv($cb, $dw)
_vv($cc, $dx)
_vv($cc, $dy)
_vv($ce, $dx)
_vv($ce, $dy)
EndFunc
_11f()
Func _11g()
Local Const $dp = "MiniregTool"
Dim $cb
Dim $cc
Dim $ce
Dim $cg
Local Const $cw = Null
Local Const $ds = "(?i)^MiniRegTool.*\.exe$"
Local Const $dt = "(?i)^MiniRegTool.*\.(exe|zip)$"
Local Const $du = "(?i)^Result\.txt$"
Local Const $dv = "(?i)^MiniRegTool"
Local Const $dw[1][3] = [[$dp, $ds, False]]
Local Const $dx[1][5] = [[$dp, 'file', $cw, $dt, False]]
Local Const $dy[1][5] = [[$dp, 'file', $cw, $du, False]]
Local Const $dz[1][5] = [[$dp, 'folder', $cw, $dv, False]]
_vv($cb, $dw)
_vv($cc, $dx)
_vv($cc, $dy)
_vv($cc, $dz)
_vv($ce, $dx)
_vv($ce, $dy)
_vv($ce, $dz)
EndFunc
_11g()
Func _11h()
Local Const $dp = "Grantperms"
Dim $cb
Dim $cc
Dim $ce
Dim $cg
Local Const $cw = Null
Local Const $ds = "(?i)^GrantPerms.*\.exe$"
Local Const $dt = "(?i)^GrantPerms.*\.(exe|zip)$"
Local Const $du = "(?i)^Perms\.txt$"
Local Const $dv = "(?i)^GrantPerms"
Local Const $dw[1][3] = [[$dp, $ds, False]]
Local Const $dx[1][5] = [[$dp, 'file', $cw, $dt, False]]
Local Const $dy[1][5] = [[$dp, 'file', $cw, $du, False]]
Local Const $dz[1][5] = [[$dp, 'folder', $cw, $dv, False]]
_vv($cb, $dw)
_vv($cc, $dx)
_vv($cc, $dy)
_vv($cc, $dz)
_vv($ce, $dx)
_vv($ce, $dy)
_vv($ce, $dz)
EndFunc
_11h()
Func _11i()
Local Const $dp = "Combofix"
Dim $cc
Dim $ce
Dim $cg
Dim $co
Dim $ch
Dim $cb
Dim $cq
Local Const $cw = "(?i)^Swearware"
Local Const $ds = "(?i)^Combofix.*\.exe$"
Local Const $dt = "(?i)^CFScript\.txt$"
Local Const $du = "(?i)^Qoobox$"
Local Const $dv = "(?i)^Combofix.*\.txt$"
Local Const $e8 = "(?i)^(grep|PEV|NIRCMD|MBR|SED|SWREG|SWSC|SWXCACLS|Zip)\.exe$"
Local Const $e9 = "(?i)^Swearware$"
Local $7x = ""
If @OSArch = "X64" Then $7x = "64"
Local Const $dw[1][5] = [[$dp, 'file', $cw, $ds, False]]
Local Const $dx[1][5] = [[$dp, 'file', Null, $dt, False]]
Local Const $dy[1][5] = [[$dp, 'folder', Null, $du, True]]
Local Const $dz[1][5] = [[$dp, 'file', Null, $dv, False]]
Local Const $e4[1][5] = [[$dp, 'file', Null, $e8, True]]
Local Const $e6[1][2] = [[$dp, $e9]]
Local Const $ea[1][3] = [[$dp, $ds, True]]
Local Const $eb[1][3] = [[$dp, "HKLM" & $7x & "\SOFTWARE\Microsoft\Windows\CurrentVersion\App Paths\combofix.exe", False]]
_vv($cc, $dw)
_vv($cc, $dx)
_vv($ce, $dw)
_vv($ce, $dx)
_vv($cg, $dy)
_vv($cg, $dz)
_vv($co, $e4)
_vv($ch, $e6)
_vv($cb, $ea)
_vv($cq, $eb)
EndFunc
_11i()
Func _11j()
Local Const $dp = "RegtoolExport"
Dim $cb
Dim $cc
Dim $ce
Local Const $cw = Null
Local Const $ds = "(?i)^regtoolexport.*\.exe$"
Local Const $dt = "(?i)^Export.*\.reg$"
Local Const $dw[1][3] = [[$dp, $ds, False]]
Local Const $dx[1][5] = [[$dp, 'file', $cw, $ds, False]]
Local Const $dy[1][5] = [[$dp, 'file', $cw, $dt, False]]
_vv($cb, $dw)
_vv($cc, $dx)
_vv($cc, $dy)
_vv($ce, $dx)
_vv($ce, $dy)
EndFunc
_11j()
Func _11k()
Local Const $dp = "TDSSKiller"
Dim $cb
Dim $cc
Dim $ce
Dim $cg
Local Const $cw = "(?i)^.*Kaspersky"
Local Const $ds = "(?i)^tdsskiller.*\.exe$"
Local Const $dt = "(?i)^tdsskiller.*\.(exe|zip)$"
Local Const $du = "(?i)^TDSSKiller.*_log\.txt$"
Local Const $dv = "(?i)^TDSSKiller"
Local Const $dw[1][3] = [[$dp, $ds, True]]
Local Const $dx[1][5] = [[$dp, 'file', $cw, $dt, False]]
Local Const $dy[1][5] = [[$dp, 'file', Null, $du, False]]
Local Const $dz[1][5] = [[$dp, 'folder', Null, $dv, False]]
_vv($cb, $dw)
_vv($cc, $dx)
_vv($cc, $dz)
_vv($ce, $dx)
_vv($ce, $dz)
_vv($cg, $dy)
_vv($cg, $dz)
EndFunc
_11k()
Func _11l()
Local Const $dp = "WinUpdatefix"
Dim $cb
Dim $cc
Dim $ce
Dim $cg
Local Const $cw = Null
Local Const $ds = "(?i)^winupdatefix.*\.exe$"
Local Const $dt = "(?i)^winupdatefix.*\.txt$"
Local Const $dw[1][3] = [[$dp, $ds, False]]
Local Const $dx[1][5] = [[$dp, 'file', $cw, $ds, False]]
Local Const $dy[1][5] = [[$dp, 'file', $cw, $dt, False]]
_vv($cb, $dw)
_vv($cc, $dx)
_vv($ce, $dx)
_vv($cg, $dy)
EndFunc
_11l()
Func _11m()
Local Const $dp = "RstHosts"
Dim $cb
Dim $cc
Dim $ce
Dim $cg
Local Const $cw = Null
Local Const $ds = "(?i)^rsthosts.*\.exe$"
Local Const $dt = "(?i)^RstHosts.*\.txt$"
Local Const $dw[1][3] = [[$dp, $ds, False]]
Local Const $dx[1][5] = [[$dp, 'file', $cw, $ds, Null]]
Local Const $dy[1][5] = [[$dp, 'file', $cw, $dt, Null]]
_vv($cb, $dw)
_vv($cc, $dx)
_vv($ce, $dx)
_vv($cg, $dy)
EndFunc
_11m()
Func _11n()
Local Const $dp = "WinCHK"
Dim $cb
Dim $cc
Dim $ce
Dim $cg
Local Const $cw = Null
Local Const $ds = "(?i)^winchk.*\.exe$"
Local Const $dt = "(?i)^WinChk.*\.txt$"
Local Const $dw[1][3] = [[$dp, $ds, False]]
Local Const $dx[1][5] = [[$dp, 'file', $cw, $ds, False]]
Local Const $dy[1][5] = [[$dp, 'file', $cw, $dt, False]]
_vv($cb, $dw)
_vv($cc, $dx)
_vv($ce, $dx)
_vv($cg, $dy)
EndFunc
_11n()
Func _11o()
Local Const $dp = "Avenger"
Dim $cb
Dim $cc
Dim $ce
Dim $cg
Local Const $cw = Null
Local Const $ds = "(?i)^avenger.*\.(exe|zip)$"
Local Const $dt = "(?i)^avenger"
Local Const $du = "(?i)^avenger.*\.txt$"
Local Const $dv = "(?i)^avenger.*\.exe$"
Local Const $dw[1][3] = [[$dp, $dv, False]]
Local Const $dx[1][5] = [[$dp, 'file', $cw, $ds, False]]
Local Const $dy[1][5] = [[$dp, 'folder', $cw, $dt, False]]
Local Const $dz[1][5] = [[$dp, 'file', $cw, $du, False]]
_vv($cb, $dw)
_vv($cc, $dx)
_vv($cc, $dy)
_vv($ce, $dx)
_vv($ce, $dy)
_vv($cg, $dy)
_vv($cg, $dz)
EndFunc
_11o()
Func _11p()
Local Const $dp = "BlitzBlank"
Dim $cb
Dim $cc
Dim $ce
Dim $cg
Dim $cd
Dim $ch
Local Const $cw = "(?i)^Emsi"
Local Const $ds = "(?i)^BlitzBlank.*\.exe$"
Local Const $dt = "(?i)^BlitzBlank.*\.log$"
Local Const $dw[1][3] = [[$dp, $ds, False]]
Local Const $dx[1][5] = [[$dp, 'file', $cw, $ds, False]]
Local Const $dy[1][5] = [[$dp, 'file', Null, $dt, False]]
_vv($cb, $dw)
_vv($cc, $dx)
_vv($ce, $dx)
_vv($cg, $dy)
EndFunc
_11p()
Func _11q()
Local Const $dp = "Zoek"
Dim $cb
Dim $cc
Dim $ce
Dim $cg
Dim $cd
Dim $ch
Local Const $cw = Null
Local Const $ds = "(?i)^zoek.*\.exe$"
Local Const $dt = "(?i)^zoek.*\.log$"
Local Const $du = "(?i)^zoek"
Local Const $dv = "(?i)^runcheck.*\.txt$"
Local Const $dw[1][3] = [[$dp, $ds, False]]
Local Const $dx[1][5] = [[$dp, 'file', $cw, $ds, False]]
Local Const $dy[1][5] = [[$dp, 'file', $cw, $dt, False]]
Local Const $dz[1][5] = [[$dp, 'folder', $cw, $du, True]]
Local Const $e4[1][5] = [[$dp, 'file', $cw, $dv, False]]
_vv($cb, $dw)
_vv($cc, $dx)
_vv($ce, $dx)
_vv($cg, $dy)
_vv($cg, $dz)
_vv($cg, $e4)
EndFunc
_11q()
Func _11r()
Local Const $dp = "Remediate VBS Worm"
Dim $cb
Dim $cc
Dim $ce
Dim $cg
Dim $cd
Dim $ch
Local Const $cw = "(?i).*VBS autorun worms.*"
Local Const $e3 = Null
Local Const $ds = "(?i)^remediate.?vbs.?worm.*\.exe$"
Local Const $dt = "(?i)^Rem-VBS.*\.log$"
Local Const $du = "(?i)^Rem-VBS"
Local Const $dv = "(?i)^Rem-VBSworm.*\.exe$"
Local Const $dw[1][3] = [[$dp, $ds, False]]
Local Const $dx[1][5] = [[$dp, 'file', $e3, $ds, False]]
Local Const $dy[1][5] = [[$dp, 'file', $e3, $dt, False]]
Local Const $dz[1][5] = [[$dp, 'folder', $cw, $du, True]]
Local Const $e4[1][2] = [[$dp, $dv]]
Local Const $e6[1][5] = [[$dp, 'file', $e3, $dv, False]]
_vv($cb, $dw)
_vv($cb, $e4)
_vv($cc, $dx)
_vv($cc, $e6)
_vv($ce, $dx)
_vv($ce, $e6)
_vv($cg, $dy)
_vv($cg, $dz)
EndFunc
_11r()
Func _11s()
Local Const $dp = "CKScanner"
Dim $cb
Dim $cc
Dim $ce
Local Const $cw = Null
Local Const $ds = "(?i)^CKScanner.*\.exe$"
Local Const $dt = "(?i)^CKfiles.*\.txt$"
Local Const $dw[1][3] = [[$dp, $ds, False]]
Local Const $dx[1][5] = [[$dp, 'file', $cw, $ds, False]]
Local Const $dy[1][5] = [[$dp, 'file', $cw, $dt, False]]
_vv($cb, $dw)
_vv($cc, $dx)
_vv($ce, $dx)
_vv($cc, $dy)
_vv($ce, $dy)
EndFunc
_11s()
Func _11t()
Local Const $dp = "QuickDiag"
Dim $cb
Dim $cc
Dim $ce
Dim $cg
Local Const $cw = "(?i)^SosVirus"
Local Const $ds = "(?i)^QuickDiag.*\.exe$"
Local Const $dt = "(?i)^QuickDiag.*\.(exe|txt)$"
Local Const $du = "(?i)^QuickScript.*\.txt$"
Local Const $dv = "(?i)^QuickDiag.*\.txt$"
Local Const $e8 = "(?i)^QuickDiag"
Local Const $dw[1][3] = [[$dp, $ds, False]]
Local Const $dx[1][5] = [[$dp, 'file', $cw, $dt, True]]
Local Const $dy[1][5] = [[$dp, 'file', Null, $du, True]]
Local Const $dz[1][5] = [[$dp, 'file', Null, $dv, True]]
Local Const $e4[1][5] = [[$dp, 'folder', Null, $e8, True]]
_vv($cb, $dw)
_vv($cc, $dx)
_vv($ce, $dx)
_vv($cc, $dy)
_vv($ce, $dy)
_vv($cg, $dz)
_vv($cg, $e4)
EndFunc
_11t()
Func _11u()
Local Const $dp = "AdliceDiag"
Dim $cb
Dim $cj
Dim $cf
Dim $ck
Dim $cc
Dim $ce
Dim $cd
Dim $cn
Local $7x = ""
If @OSArch = "X64" Then $7x = "64"
Local Const $ec = "(?i)^Adlice Diag"
Local Const $ds = "(?i)^Diag version"
Local Const $dt = "(?i)^Diag$"
Local Const $du = "(?i)^ADiag$"
Local Const $dv = "(?i)^Diag_portable(32|64)\.exe$"
Local Const $e8 = "(?i)^Diag\.lnk$"
Local Const $e9 = "(?i)^Diag_setup\.exe$"
Local Const $ed = "(?i)^Diag(32|64)?\.exe$"
Local Const $dw[1][3] = [[$dp, $ec, False]]
Local Const $dx[1][4] = [[$dp, "HKLM" & $7x & "\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall", $ds, "DisplayName"]]
Local Const $dy[1][5] = [[$dp, 'folder', Null, $dt, True]]
Local Const $dz[1][5] = [[$dp, 'folder', Null, $du, True]]
Local Const $e4[1][5] = [[$dp, 'file', Null, $dv, False]]
Local Const $e6[1][5] = [[$dp, 'file', Null, $e8, False]]
Local Const $ea[1][5] = [[$dp, 'file', Null, $e9, False]]
Local Const $eb[1][2] = [[$dp, $ed]]
_vv($cb, $dw)
_vv($cb, $eb)
_vv($cj, $dx)
_vv($cf, $dy)
_vv($ck, $dz)
_vv($cc, $e4)
_vv($cc, $e6)
_vv($cc, $ea)
_vv($ce, $e4)
_vv($ce, $ea)
_vv($cd, $e6)
_vv($cn, $dy)
EndFunc
_11u()
Func _11v()
Local Const $e1 = Null
Local Const $dp = "RstAssociations"
Dim $cb
Dim $cc
Dim $ce
Dim $cg
Local Const $ds = "(?i)^rstassociations.*\.(exe|scr)$"
Local Const $dt = "(?i)^RstAssociations.*\.txt$"
Local Const $dw[1][3] = [[$dp, $ds, False]]
Local Const $dx[1][5] = [[$dp, 'file', $e1, $ds, False]]
Local Const $dy[1][5] = [[$dp, 'file', $e1, $dt, False]]
_vv($cb, $dw)
_vv($cc, $dx)
_vv($ce, $dx)
_vv($cg, $dy)
EndFunc
_11v()
Func _11w()
Local Const $e1 = Null
Local Const $dp = "SFT"
Dim $cb
Dim $cc
Dim $ce
Local Const $ds = "(?i)^SFT.*\.exe$"
Local Const $dt = "(?i)^SFT.*\.(txt|exe|zip)$"
Local Const $dw[1][3] = [[$dp, $ds, False]]
Local Const $dx[1][5] = [[$dp, 'file', $e1, $dt, False]]
_vv($cb, $dw)
_vv($cc, $dx)
_vv($ce, $dx)
EndFunc
_11w()
Func _11x()
Local Const $dp = "LogonFix"
Dim $cb
Dim $cc
Dim $ce
Dim $cg
Local Const $cw = Null
Local Const $ds = "(?i)^logonfix.*\.exe$"
Local Const $dt = "(?i)^LogonFix.*\.txt$"
Local Const $dw[1][3] = [[$dp, $ds, False]]
Local Const $dx[1][5] = [[$dp, 'file', $cw, $ds, False]]
Local Const $dy[1][5] = [[$dp, 'file', $cw, $dt, False]]
_vv($cb, $dw)
_vv($cc, $dx)
_vv($ce, $dx)
_vv($cg, $dy)
EndFunc
_11x()
Func _11y()
Local Const $dp = "CMD_Command"
Dim $cb
Dim $cc
Dim $ce
Local Const $cw = "(?i)^g3n-h@ckm@n$"
Local Const $ds = "(?i)^cmd-command.*\.exe$"
Local Const $dw[1][3] = [[$dp, $ds, False]]
Local Const $dx[1][5] = [[$dp, 'file', $cw, $ds, False]]
_vv($cb, $dw)
_vv($cc, $dx)
_vv($ce, $dx)
EndFunc
_11y()
Func _11z()
Local Const $dp = "Report_CHKDSK"
Dim $cb
Dim $cc
Dim $ce
Local Const $cw = Null
Local Const $ds = "(?i)^Report_CHKDSK.*\.exe$"
Local Const $dt = "(?i)^RapportCHK.*\.txt$"
Local Const $dw[1][3] = [[$dp, $ds, False]]
Local Const $dx[1][5] = [[$dp, 'file', $cw, $ds, False]]
Local Const $dy[1][5] = [[$dp, 'file', $cw, $dt, False]]
_vv($cb, $dw)
_vv($cc, $dx)
_vv($cc, $dy)
_vv($ce, $dx)
_vv($ce, $dy)
EndFunc
_11z()
Func _120()
Local Const $dp = "SEAF"
Dim $cb
Dim $cc
Dim $ce
Dim $cp
Dim $cq
Dim $cg
Dim $cf
Local Const $cw = "(?i)^C_XX$"
Local Const $ee = "(?i)^SEAF$"
Local Const $ds = "(?i)^seaf.*\.exe$"
Local Const $dt = "(?i)^Un-SEAF\.exe$"
Local Const $du = "(?i)^SeafLog.*\.txt$"
Local $7x = ""
If @OSArch = "X64" Then $7x = "64"
Local Const $dw[1][3] = [[$dp, $ds, False]]
Local Const $dx[1][5] = [[$dp, 'file', $cw, $ds, False]]
Local Const $dy[1][3] = [[$dp, $ee, $dt]]
Local Const $dz[1][3] = [[$dp, "HKLM" & $7x & "\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\SEAF", False]]
Local Const $e4[1][5] = [[$dp, 'file', Null, $du, False]]
Local Const $e6[1][5] = [[$dp, 'folder', Null, $ee, True]]
_vv($cb, $dw)
_vv($cc, $dx)
_vv($ce, $dx)
_vv($cp, $dy)
_vv($cq, $dz)
_vv($cg, $e4)
_vv($cf, $e6)
EndFunc
_120()
Func _121()
Dim $cb
Dim $cc
Dim $ce
Local Const $dp = "DDS"
Local Const $cw = "(?i)^Swearware"
Local Const $ds = "(?i)^dds.*\.com"
Local Const $dt = "(?i)^(dds|attach).*\.txt"
Local Const $dw[1][3] = [[$dp, $ds, False]]
Local Const $dx[1][5] = [[$dp, 'file', $cw, $ds, False]]
Local Const $dy[1][5] = [[$dp, 'file', Null, $dt, False]]
_vv($cb, $dw)
_vv($cc, $dx)
_vv($cc, $dy)
_vv($ce, $dx)
_vv($ce, $dy)
EndFunc
_121()
Func _122()
Dim $cb
Dim $cc
Dim $ce
Local Const $dp = "Defogger"
Local Const $cw = Null
Local Const $ds = "(?i)^defogger.*\.exe$"
Local Const $dt = "(?i)^defogger.*\.(log|exe)$"
Local Const $dw[1][3] = [[$dp, $ds, False]]
Local Const $dx[1][5] = [[$dp, 'file', $cw, $dt, False]]
_vv($cb, $dw)
_vv($cc, $dx)
_vv($ce, $dx)
EndFunc
_122()
Func _123()
Dim $cb
Dim $cc
Dim $ce
Dim $cg
Local Const $dp = "JavaRa"
Local Const $cw = "(?i)^The RaProducts Team"
Local Const $ds = "(?i)^Javara"
Local Const $dt = "(?i)^Javara.*\.exe$"
Local Const $du = "(?i)^Javara.*\.(zip|exe)$"
Local Const $dv = "(?i)^Javara.*\.log$"
Local Const $dw[1][3] = [[$dp, $dt, False]]
Local Const $dx[1][5] = [[$dp, 'file', $cw, $du, False]]
Local Const $dy[1][5] = [[$dp, 'file', Null, $dv, False]]
Local Const $dz[1][5] = [[$dp, 'folder', Null, $ds, False]]
_vv($cb, $dw)
_vv($cc, $dx)
_vv($cc, $dz)
_vv($ce, $dx)
_vv($ce, $dz)
_vv($cg, $dy)
EndFunc
_123()
Func _124()
Local Const $dp = "g3n-h@ckm@n tools"
Dim $ch
Local Const $e9 = "(?i)^g3n-h@ckm@n$"
Local Const $e6[1][2] = [[$dp, $e9]]
_vv($ch, $e6)
EndFunc
_124()
Func _125()
Local Const $dp = "Systemlook"
Dim $cb
Dim $cc
Dim $ce
Local Const $cw = Null
Local Const $ds = "(?i)^SystemLook.*\.exe$"
Local Const $dt = "(?i)^SystemLook.*\.(exe|txt)$"
Local Const $dw[1][3] = [[$dp, $ds, False]]
Local Const $dx[1][5] = [[$dp, 'file', $cw, $dt, False]]
_vv($cb, $dw)
_vv($cc, $dx)
_vv($ce, $dx)
EndFunc
_125()
Func _126()
Dim $cb
Dim $cc
Dim $ce
Dim $cm
Dim $cq
Local Const $dp = "ESET Online Scanner"
Local Const $cw = "(?i)^ESET"
Local Const $ds = "(?i)^esetonlinescanner.*\.exe$"
Local Const $dt = "(?i)^log.*\.txt$"
Local $7x = ""
If @OSArch = "X64" Then $7x = "64"
Local Const $dw[1][3] = [[$dp, $ds, False]]
Local Const $dx[1][5] = [[$dp, 'file', $cw, $ds, False]]
Local Const $dy[1][5] = [[$dp, 'file', Null, $dt, False]]
Local Const $dz[1][5] = [[$dp, 'folder', Null, "(?i)^ESET$", True]]
Local Const $e4[1][3] = [[$dp, "HKLM" & $7x & "\SOFTWARE\ESET\ESET Online Scanner", False]]
_vv($cb, $dw)
_vv($cc, $dx)
_vv($cc, $dy)
_vv($ce, $dx)
_vv($ce, $dy)
_vv($cm, $dz)
_vv($cq, $e4)
EndFunc
_126()
Func _127()
Local Const $dp = "SecurityCheck"
Dim $cb
Dim $cc
Dim $dq
Dim $ce
Dim $dr
Dim $cg
Local Const $ds = "(?i)^SecurityCheck.*\.exe$"
Local Const $dw[1][3] = [[$dp, $ds, False]]
Local Const $dx[1][5] = [[$dp, 'file', Null, $ds, False]]
_vv($cb, $dw)
_vv($cc, $dx)
_vv($ce, $dx)
EndFunc
_127()
Func _128()
Dim $cb
Dim $cc
Dim $ce
Local Const $dp = "Rkill"
Local Const $cw = "(?i)^Bleeping Computer"
Local Const $ds = "(?i)^(rkill|iExplore)\.exe$"
Local Const $dt = "(?i)^(rkill|iExplore).*\.(exe|txt|zip)$"
Local Const $du = "(?i)^rkill$"
Local Const $dw[1][3] = [[$dp, $ds, False]]
Local Const $dx[1][5] = [[$dp, 'file', $cw, $dt, True]]
Local Const $dy[1][5] = [[$dp, 'folder', Null, $du, False]]
_vv($cb, $dw)
_vv($cc, $dx)
_vv($cc, $dy)
_vv($ce, $dx)
_vv($ce, $dy)
EndFunc
_128()
Func _129()
Dim $cb
Dim $cc
Dim $ce
Local Const $dp = "AHK_NavScan"
Local Const $ds = "(?i)^AHK_NavScan.*\.exe"
Local Const $dt = "(?i)^AHK_NavScan.*\.(exe|txt)"
Local Const $dw[1][3] = [[$dp, $ds, False]]
Local Const $dx[1][5] = [[$dp, 'file', Null, $dt, False]]
_vv($cb, $dw)
_vv($cc, $dx)
_vv($ce, $dx)
EndFunc
_129()
Func _12a()
Dim $cb
Dim $cc
Dim $ce
Local Const $dp = "Avast Decryptor Cryptomix"
Local Const $cw = "(?i)^Avast"
Local Const $ds = "(?i)^avast_decryptor_cryptomix.*\.exe"
Local Const $dw[1][3] = [[$dp, $ds, False]]
Local Const $dx[1][5] = [[$dp, 'file', $cw, $ds, False]]
_vv($cb, $dw)
_vv($cc, $dx)
_vv($ce, $dx)
EndFunc
_12a()
Func _12b()
Dim $cb
Dim $cc
Dim $ce
Local Const $dp = "Decrypt CryptON"
Local Const $cw = "(?i)^Emsisoft"
Local Const $ds = "(?i)^decrypt_CryptON.*\.exe"
Local Const $dw[1][3] = [[$dp, $ds, False]]
Local Const $dx[1][5] = [[$dp, 'file', $cw, $ds, False]]
_vv($cb, $dw)
_vv($cc, $dx)
_vv($ce, $dx)
EndFunc
_12b()
Func _12c()
Dim $cb
Dim $cc
Dim $ce
Dim $cg
Local Const $dp = "Rakhni Decryptor"
Local Const $cw = "(?i)^Kaspersky"
Local Const $ds = "(?i)^RakhniDecryptor.*\.exe"
Local Const $dt = "(?i)^RakhniDecryptor.*\.(exe|txt|zip)"
Local Const $du = "(?i)^RakhniDecryptor"
Local Const $dw[1][3] = [[$dp, $ds, False]]
Local Const $dx[1][5] = [[$dp, 'file', $cw, $dt, False]]
Local Const $dy[1][5] = [[$dp, 'folder', Null, $du, False]]
_vv($cb, $dw)
_vv($cc, $dx)
_vv($cc, $dy)
_vv($ce, $dx)
_vv($ce, $dy)
_vv($cg, $dx)
_vv($cg, $dy)
EndFunc
_12c()
Func _12d()
Dim $cb
Dim $cc
Dim $ce
Dim $cg
Local Const $dp = "ListCWall"
Local Const $cw = "(?i)^Bleeping Computer"
Local Const $ds = "(?i)^ListCWall.*\.exe"
Local Const $dt = "(?i)^ListCWall.*\.(exe|txt)"
Local Const $dw[1][3] = [[$dp, $ds, False]]
Local Const $dx[1][5] = [[$dp, 'file', $cw, $dt, False]]
_vv($cb, $dw)
_vv($cc, $dx)
_vv($ce, $dx)
EndFunc
_12d()
Func _12e()
Local Const $dp = "Hosts-perm"
Dim $cc
Dim $ce
Local Const $ds = "(?i)^hosts\-perm.*\.bat$"
Local Const $dw[1][5] = [[$dp, 'file', Null, $ds, False]]
_vv($cc, $dw)
_vv($ce, $dw)
EndFunc
_12e()
Func _12f($br = False)
If $br = True Then
_zm(@CRLF & "- Search Tools -" & @CRLF)
EndIf
_10p($cb)
_105()
_10r($cp)
_105()
_10q($ci)
_105()
_10l(@DesktopDir, $cc)
_105()
_10m(@DesktopCommonDir, $cd)
_105()
If FileExists(@UserProfileDir & "\Downloads") Then
_10l(@UserProfileDir & "\Downloads", $ce)
_105()
Else
_105()
EndIf
_10s($cf)
_105()
_10m(@HomeDrive, $cg)
_105()
_10m(@AppDataDir, $cl)
_105()
_10m(@AppDataCommonDir, $ck)
_105()
_10m(@LocalAppDataDir, $cm)
_105()
_10m(@WindowsDir, $co)
_105()
_10t($ch)
_105()
_10v($cq)
_105()
_10u($cj)
_105()
_10m(@AppDataCommonDir & "\Microsoft\Windows\Start Menu\Programs", $cn)
_105()
_10w($cr)
_105()
If $br = True Then
Local $ef = False
Local Const $eg[4] = ["process", "uninstall", "element", "key"]
Local Const $eh = "Warning, folder " & @AppDataDir & "\ZHP exists and contains the quarantines of the ZHP tools. At the request of the publisher (Nicolas Coolman) this folder is not deleted. "
Local $ei = False
Local Const $ej = _zu(@AppDataDir & "\ZHP")
For $ek In $b6
Local $el = $b6.Item($ek)
Local $em = False
For $en = 0 To UBound($eg) - 1
Local $eo = $eg[$en]
Local $ep = $el.Item($eo)
Local $eq = $ep.Keys
If UBound($eq) > 0 Then
If $em = False Then
$em = True
$ef = True
_zm(@CRLF & "  ## " & $ek & " found")
EndIf
For $er = 0 To UBound($eq) - 1
Local $es = $eq[$er]
Local $et = $ep.Item($es)
_104($eo, $es, $et)
Next
If $ek = "ZHP Tools" And $ej = True And $ei = False Then
_zm("     [!] " & $eh)
$ei = True
EndIf
EndIf
Next
Next
If $ei = False And $ej = True Then
_zm(@CRLF & "  ## " & "ZHP Tools" & " found")
_zm("     [!] " & $eh)
ElseIf $ef = False Then
_zm("  [I] No tools found")
EndIf
EndIf
_105()
EndFunc
FileInstall("C:\Users\parfa\Desktop\kpRemover\src\assets\bug.gif", @TempDir & "\kprm-logo.gif")
Global $bx = "KpRm"
Global $ag = "kprm-" & @YEAR & @MON & @MDAY & @HOUR & @MIN & ".txt"
Local Const $eu = GUICreate($bx, 500, 195, 202, 112)
Local Const $ev = GUICtrlCreateGroup("Actions", 8, 8, 400, 153)
Local Const $ew = GUICtrlCreateCheckbox($7e, 16, 40, 129, 17)
Local Const $ex = GUICtrlCreateCheckbox($7f, 16, 80, 190, 17)
Local Const $ey = GUICtrlCreateCheckbox($7g, 16, 120, 190, 17)
Local Const $ez = GUICtrlCreateCheckbox($7h, 220, 40, 137, 17)
Local Const $f0 = GUICtrlCreateCheckbox($7i, 220, 80, 137, 17)
Local Const $f1 = GUICtrlCreateCheckbox($7j, 220, 120, 180, 17)
Global $bk = GUICtrlCreateProgress(8, 170, 480, 17)
GUICtrlCreateGroup("", -99, -99, 1, 1)
GUICtrlSetState($ew, 1)
Local Const $f2 = GUICtrlCreatePic(@TempDir & "\kprm-logo.gif", 415, 16, 76, 76)
Local Const $f3 = GUICtrlCreateButton($7k, 415, 120, 75, 40)
GUISetState(@SW_SHOW)
While 1
Local $f4 = GUIGetMsg()
Switch $f4
Case $0
Exit
Case $f3
_12i()
EndSwitch
WEnd
Func _12g()
Local Const $f5 = @HomeDrive & "\KPRM"
If Not FileExists($f5) Then
DirCreate($f5)
EndIf
If Not FileExists($f5) Then
MsgBox(16, $7m, $7n)
Exit
EndIf
EndFunc
Func _12h()
_12g()
_zm("#################################################################################################################" & @CRLF)
_zm("# Run at " & _3o())
_zm("# KpRm (Kernel-panik) version " & $7c)
_zm("# Website https://kernel-panik.me/tool/kprm/")
_zm("# Run by " & @UserName & " from " & @WorkingDir)
_zm("# Computer Name: " & @ComputerName)
_zm("# OS: " & _zw() & " " & @OSArch & " (" & @OSBuild & ") " & @OSServicePack)
_106()
EndFunc
Func _12i()
_12h()
_105()
If GUICtrlRead($ez) = $1 Then
_10d()
EndIf
_105()
If GUICtrlRead($ew) = $1 Then
_12f(False)
_12f(True)
Else
_105(32)
EndIf
_105()
If GUICtrlRead($f1) = $1 Then
_10f()
EndIf
_105()
If GUICtrlRead($f0) = $1 Then
_10e()
EndIf
_105()
If GUICtrlRead($ex) = $1 Then
_107()
EndIf
_105()
If GUICtrlRead($ey) = $1 Then
_10c()
EndIf
GUICtrlSetData($bk, 100)
MsgBox(64, "OK", $7l)
_zi(True)
EndFunc
