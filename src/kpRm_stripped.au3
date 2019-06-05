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
Global $7b = True
Local $7c = "1.0.1"
If $7b = True Then
AutoItSetOption("MustDeclareVars", 1)
EndIf
Local Const $7d = _10r()
If $7d = "fr" Then
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
Global $7p = "Mise à jour"
Global $7q = "Une version plus récente de KpRm existe, merci de la télécharger."
ElseIf $7d = "de" Then
Global $7e = "Werkzeuge löschen"
Global $7f = "Wiederherstellungspunkte löschen"
Global $7g = "Erstellen eines Wiederherstellungspunktes"
Global $7h = "Speichern der Registrierung"
Global $7i = "UAC wiederherstellen"
Global $7j = "Systemeinstellungen wiederherstellen"
Global $7k = "Ausführen"
Global $7l = "Alle Vorgänge sind abgeschlossen"
Global $7m = "Ausfall"
Global $7n = "Es ist nicht möglich, ein Registrierungs-Backup zu erstellen"
Global $7o = "Sie müssen das Programm mit Administratorrechten ausführen"
Global $7p = "Update"
Global $7q = "Es gibt eine neuere Version von KpRm, bitte laden Sie sie herunter."
ElseIf $7d = "it" Then
Global $7e = "Cancella strumenti"
Global $7f = "Elimina punti di ripristino"
Global $7g = "Crea un punto di ripristino"
Global $7h = "Salva registro"
Global $7i = "Ripristina UAC"
Global $7j = "Ripristina impostazioni di sistema"
Global $7k = "Eseguire"
Global $7l = "Tutte le operazioni sono completate"
Global $7m = "Fallimento"
Global $7n = "Impossibile creare un backup del registro di sistema"
Global $7o = "È necessario eseguire il programma con i diritti di amministratore"
Global $7p = "Aggiorna"
Global $7q = "Esiste una versione più recente di KpRm, scaricatela, per favore"
ElseIf $7d = "es" Then
Global $7e = "Borrar herramientas"
Global $7f = "Eliminar puntos de restauración"
Global $7g = "Crear un punto de restauración"
Global $7h = "Guardar el registro"
Global $7i = "Restaurar UAC"
Global $7j = "Restaurar ajustes del sistema"
Global $7k = "Ejecutar"
Global $7l = "Todas las operaciones están terminadas"
Global $7m = "fallo"
Global $7n = "Incapaz de crear una copia de seguridad del registro"
Global $7o = "Debe ejecutar el programa con derechos de administrador"
Global $7p = "Actualización"
Global $7q = "Existe una nueva versión de KpRm, por favor descárguela."
ElseIf $7d = "pt" Then
Global $7e = "Apagar ferramentas"
Global $7f = "Deletar pontos de restauração"
Global $7g = "Criar um ponto de restauração"
Global $7h = "Salvar registro"
Global $7i = "Restaurar UAC"
Global $7j = "Restaurar configurações do sistema"
Global $7k = "Executar"
Global $7l = "Todas as operações estão concluídas"
Global $7m = "Falha"
Global $7n = "Incapaz de criar um backup do registro"
Global $7o = "Você deve executar o programa com direitos de administrador"
Global $7p = "Atualizar"
Global $7q = "Uma nova versão do KpRm existe, por favor faça o download."
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
Global $7p = "Update"
Global $7q = "A more recent version of KpRm exists, please download it!"
EndIf
Global Const $7r = 1
Global Const $7s = 5
Global Const $7t = 0
Global Const $7u = 1
Func _xr($7v = $7s)
If Not IsAdmin() Then Return SetError(-3, 0, -1)
If StringRegExp(@OSVersion, "_(XP|200(0|3))") Then Return SetError(-4, 0, -1)
Local $7w = ""
If @OSArch = "X64" Then $7w = "64"
If $7v < 0 Or $7v > 5 Then Return SetError(-5, 0, -1)
Local $2z = RegWrite("HKEY_LOCAL_MACHINE" & $7w & "\Software\Microsoft\Windows\CurrentVersion\Policies\System", "ConsentPromptBehaviorAdmin", "REG_DWORD", $7v)
If $2z = 0 Then $2z = -1
Return SetError(@error, 0, $2z)
EndFunc
Func _xs($7v = $7r)
If Not IsAdmin() Then Return SetError(-3, 0, -1)
If StringRegExp(@OSVersion, "_(XP|200(0|3))") Then Return SetError(-4, 0, -1)
If $7v < 0 Or $7v = 2 Or $7v > 3 Then Return SetError(-5, 0, -1)
Local $7w = ""
If @OSArch = "X64" Then $7w = "64"
Local $2z = RegWrite("HKEY_LOCAL_MACHINE" & $7w & "\Software\Microsoft\Windows\CurrentVersion\Policies\System", "ConsentPromptBehaviorUser", "REG_DWORD", $7v)
If $2z = 0 Then $2z = -1
Return SetError(@error, 0, $2z)
EndFunc
Func _xt($7v = $7t)
If Not IsAdmin() Then Return SetError(-3, 0, -1)
If StringRegExp(@OSVersion, "_(XP|200(0|3))") Then Return SetError(-4, 0, -1)
If $7v < 0 Or $7v > 1 Then Return SetError(-5, 0, -1)
Local $7w = ""
If @OSArch = "X64" Then $7w = "64"
Local $2z = RegWrite("HKEY_LOCAL_MACHINE" & $7w & "\Software\Microsoft\Windows\CurrentVersion\Policies\System", "EnableInstallerDetection", "REG_DWORD", $7v)
If $2z = 0 Then $2z = -1
Return SetError(@error, 0, $2z)
EndFunc
Func _xu($7v = $7u)
If Not IsAdmin() Then Return SetError(-3, 0, -1)
If StringRegExp(@OSVersion, "_(XP|200(0|3))") Then Return SetError(-4, 0, -1)
If $7v < 0 Or $7v > 1 Then Return SetError(-5, 0, -1)
Local $7w = ""
If @OSArch = "X64" Then $7w = "64"
Local $2z = RegWrite("HKEY_LOCAL_MACHINE" & $7w & "\Software\Microsoft\Windows\CurrentVersion\Policies\System", "EnableLUA", "REG_DWORD", $7v)
If $2z = 0 Then $2z = -1
Return SetError(@error, 0, $2z)
EndFunc
Func _xv($7v = $7u)
If Not IsAdmin() Then Return SetError(-3, 0, -1)
If StringRegExp(@OSVersion, "_(XP|200(0|3))") Then Return SetError(-4, 0, -1)
If $7v < 0 Or $7v > 1 Then Return SetError(-5, 0, -1)
Local $7w = ""
If @OSArch = "X64" Then $7w = "64"
Local $2z = RegWrite("HKEY_LOCAL_MACHINE" & $7w & "\Software\Microsoft\Windows\CurrentVersion\Policies\System", "EnableSecureUIAPaths", "REG_DWORD", $7v)
If $2z = 0 Then $2z = -1
Return SetError(@error, 0, $2z)
EndFunc
Func _xw($7v = $7t)
If Not IsAdmin() Then Return SetError(-3, 0, -1)
If StringRegExp(@OSVersion, "_(XP|200(0|3))") Then Return SetError(-4, 0, -1)
If $7v < 0 Or $7v > 1 Then Return SetError(-5, 0, -1)
Local $7w = ""
If @OSArch = "X64" Then $7w = "64"
Local $2z = RegWrite("HKEY_LOCAL_MACHINE" & $7w & "\Software\Microsoft\Windows\CurrentVersion\Policies\System", "EnableUIADesktopToggle", "REG_DWORD", $7v)
If $2z = 0 Then $2z = -1
Return SetError(@error, 0, $2z)
EndFunc
Func _xx($7v = $7u)
If Not IsAdmin() Then Return SetError(-3, 0, -1)
If StringRegExp(@OSVersion, "_(XP|200(0|3))") Then Return SetError(-4, 0, -1)
If $7v < 0 Or $7v > 1 Then Return SetError(-5, 0, -1)
Local $7w = ""
If @OSArch = "X64" Then $7w = "64"
Local $2z = RegWrite("HKEY_LOCAL_MACHINE" & $7w & "\Software\Microsoft\Windows\CurrentVersion\Policies\System", "EnableVirtualization", "REG_DWORD", $7v)
If $2z = 0 Then $2z = -1
Return SetError(@error, 0, $2z)
EndFunc
Func _xy($7v = $7t)
If Not IsAdmin() Then Return SetError(-3, 0, -1)
If StringRegExp(@OSVersion, "_(XP|200(0|3))") Then Return SetError(-4, 0, -1)
If $7v < 0 Or $7v > 1 Then Return SetError(-5, 0, -1)
Local $7w = ""
If @OSArch = "X64" Then $7w = "64"
Local $2z = RegWrite("HKEY_LOCAL_MACHINE" & $7w & "\Software\Microsoft\Windows\CurrentVersion\Policies\System", "FilterAdministratorToken", "REG_DWORD", $7v)
If $2z = 0 Then $2z = -1
Return SetError(@error, 0, $2z)
EndFunc
Func _xz($7v = $7u)
If Not IsAdmin() Then Return SetError(-3, 0, -1)
If StringRegExp(@OSVersion, "_(XP|200(0|3))") Then Return SetError(-4, 0, -1)
If $7v < 0 Or $7v > 1 Then Return SetError(-5, 0, -1)
Local $7w = ""
If @OSArch = "X64" Then $7w = "64"
Local $2z = RegWrite("HKEY_LOCAL_MACHINE" & $7w & "\Software\Microsoft\Windows\CurrentVersion\Policies\System", "PromptOnSecureDesktop", "REG_DWORD", $7v)
If $2z = 0 Then $2z = -1
Return SetError(@error, 0, $2z)
EndFunc
Func _y0($7v = $7t)
If Not IsAdmin() Then Return SetError(-3, 0, -1)
If StringRegExp(@OSVersion, "_(XP|200(0|3))") Then Return SetError(-4, 0, -1)
If $7v < 0 Or $7v > 1 Then Return SetError(-5, 0, -1)
Local $7w = ""
If @OSArch = "X64" Then $7w = "64"
Local $2z = RegWrite("HKEY_LOCAL_MACHINE" & $7w & "\Software\Microsoft\Windows\CurrentVersion\Policies\System", "ValidateAdminCodeSignatures", "REG_DWORD", $7v)
If $2z = 0 Then $2z = -1
Return SetError(@error, 0, $2z)
EndFunc
Global $7x = Null, $7y = Null
Global $7z = EnvGet('SystemDrive') & '\'
Func _y2()
Local $80[1][3], $81 = 0
$80[0][0] = $81
If Not IsObj($7y) Then $7y = ObjGet("winmgmts:root/default")
If Not IsObj($7y) Then Return $80
Local $82 = $7y.InstancesOf("SystemRestore")
If Not IsObj($82) Then Return $80
For $83 In $82
$81 += 1
ReDim $80[$81 + 1][3]
$80[$81][0] = $83.SequenceNumber
$80[$81][1] = $83.Description
$80[$81][2] = _y3($83.CreationTime)
Next
$80[0][0] = $81
Return $80
EndFunc
Func _y3($84)
Return(StringMid($84, 5, 2) & "/" & StringMid($84, 7, 2) & "/" & StringLeft($84, 4) & " " & StringMid($84, 9, 2) & ":" & StringMid($84, 11, 2) & ":" & StringMid($84, 13, 2))
EndFunc
Func _y4($85)
Local $19 = DllCall('SrClient.dll', 'DWORD', 'SRRemoveRestorePoint', 'DWORD', $85)
If @error Then Return SetError(1, 0, 0)
If $19[0] = 0 Then Return 1
Return SetError(1, 0, 0)
EndFunc
Func _y6($86 = $7z)
If Not IsObj($7x) Then $7x = ObjGet("winmgmts:{impersonationLevel=impersonate}!root/default:SystemRestore")
If Not IsObj($7x) Then Return 0
If $7x.Enable($86) = 0 Then Return 1
Return 0
EndFunc
Global Enum $87 = 0, $88, $89, $8a, $8b, $8c, $8d, $8e, $8f, $8g, $8h, $8i, $8j
Global Const $8k = 2
Global $8l = @SystemDir&'\Advapi32.dll'
Global $8m = @SystemDir&'\Kernel32.dll'
Global $8n[4][2], $8o[4][2]
Global $8p = 0
Func _y9()
$8l = DllOpen(@SystemDir&'\Advapi32.dll')
$8m = DllOpen(@SystemDir&'\Kernel32.dll')
$8n[0][0] = "SeRestorePrivilege"
$8n[0][1] = 2
$8n[1][0] = "SeTakeOwnershipPrivilege"
$8n[1][1] = 2
$8n[2][0] = "SeDebugPrivilege"
$8n[2][1] = 2
$8n[3][0] = "SeSecurityPrivilege"
$8n[3][1] = 2
$8o = _zh($8n)
$8p = 1
EndFunc
Func _yf($8q, $8r = $88, $8s = 'Administrators', $8t = 1)
Local $8u[1][3]
$8u[0][0] = 'Everyone'
$8u[0][1] = 1
$8u[0][2] = $r
Return _yi($8q, $8u, $8r, $8s, 1, $8t)
EndFunc
Func _yi($8q, $8v, $8r = $88, $8s = '', $8w = 0, $8t = 0, $8x = 3)
If $8p = 0 Then _y9()
If Not IsArray($8v) Or UBound($8v,2) < 3 Then Return SetError(1,0,0)
Local $8y = _yn($8v,$8x)
Local $8z = @extended
Local $90 = 4, $91 = 0
If $8s <> '' Then
If Not IsDllStruct($8s) Then $8s = _za($8s)
$91 = DllStructGetPtr($8s)
If $91 And _zg($91) Then
$90 = 5
Else
$91 = 0
EndIf
EndIf
If Not IsPtr($8q) And $8r = $88 Then
Return _yv($8q, $8y, $91, $8w, $8t, $8z, $90)
ElseIf Not IsPtr($8q) And $8r = $8b Then
Return _yw($8q, $8y, $91, $8w, $8t, $8z, $90)
Else
If $8w Then _yx($8q,$8r)
Return _yo($8q, $8r, $90, $91, 0, $8y,0)
EndIf
EndFunc
Func _yn(ByRef $8v, ByRef $8x)
Local $92 = UBound($8v,2)
If Not IsArray($8v) Or $92 < 3 Then Return SetError(1,0,0)
Local $93 = UBound($8v), $94[$93], $95 = 0, $96 = 1
Local $97, $8z = 0, $98
Local $99, $9a = 'DWORD;DWORD;DWORD;ptr;DWORD;DWORD;DWORD;ptr'
For $4g = 1 To $93 - 1
$9a &= ';DWORD;DWORD;DWORD;ptr;DWORD;DWORD;DWORD;ptr'
Next
$99 = DllStructCreate($9a)
For $4g = 0 To $93 -1
If Not IsDllStruct($8v[$4g][0]) Then $8v[$4g][0] = _za($8v[$4g][0])
$94[$4g] = DllStructGetPtr($8v[$4g][0])
If Not _zg($94[$4g]) Then ContinueLoop
DllStructSetData($99,$95+1,$8v[$4g][2])
If $8v[$4g][1] = 0 Then
$8z = 1
$97 = $c
Else
$97 = $b
EndIf
If $92 > 3 Then $8x = $8v[$4g][3]
DllStructSetData($99,$95+2,$97)
DllStructSetData($99,$95+3,$8x)
DllStructSetData($99,$95+6,0)
$98 = DllCall($8l,'BOOL','LookupAccountSid','ptr',0,'ptr',$94[$4g],'ptr*',0,'dword*',32,'ptr*',0,'dword*',32,'dword*',0)
If Not @error Then $96 = $98[7]
DllStructSetData($99,$95+7,$96)
DllStructSetData($99,$95+8,$94[$4g])
$95 += 8
Next
Local $9b = DllStructGetPtr($99)
$98 = DllCall($8l,'DWORD','SetEntriesInAcl','ULONG',$93,'ptr',$9b ,'ptr',0,'ptr*',0)
If @error Or $98[0] Then Return SetError(1,0,0)
Return SetExtended($8z, $98[4])
EndFunc
Func _yo($8q, $8r, $90, $91 = 0, $9c = 0, $8y = 0, $9d = 0)
Local $98
If $8p = 0 Then _y9()
If $8y And Not _yp($8y) Then Return 0
If $9d And Not _yp($9d) Then Return 0
If IsPtr($8q) Then
$98 = DllCall($8l,'dword','SetSecurityInfo','handle',$8q,'dword',$8r, 'dword',$90,'ptr',$91,'ptr',$9c,'ptr',$8y,'ptr',$9d)
Else
If $8r = $8b Then $8q = _zb($8q)
$98 = DllCall($8l,'dword','SetNamedSecurityInfo','str',$8q,'dword',$8r, 'dword',$90,'ptr',$91,'ptr',$9c,'ptr',$8y,'ptr',$9d)
EndIf
If @error Then Return SetError(1,0,0)
If $98[0] And $91 Then
If _z0($8q, $8r,_zf($91)) Then Return _yo($8q, $8r, $90 - 1, 0, $9c, $8y, $9d)
EndIf
Return SetError($98[0] , 0, Number($98[0] = 0))
EndFunc
Func _yp($9e)
If $9e = 0 Then Return SetError(1,0,0)
Local $98 = DllCall($8l,'bool','IsValidAcl','ptr',$9e)
If @error Or Not $98[0] Then Return 0
Return 1
EndFunc
Func _ys($9f, $9g = -1)
If $8p = 0 Then _y9()
If $9g = -1 Then $9g = BitOR($5, $6, $7, $8)
$9f = ProcessExists($9f)
If $9f = 0 Then Return SetError(1,0,0)
Local $98 = DllCall($8m,'handle','OpenProcess','dword',$9g,'bool',False,'dword',$9f)
If @error Or $98[0] = 0 Then Return SetError(2,0,0)
Return $98[0]
EndFunc
Func _yt($9f)
Local $9h = _ys($9f,BitOR(1,$5, $6, $7, $8))
If $9h = 0 Then Return SetError(1,0,0)
Local $9i = 0
_yf($9h,$8d)
For $4g = 1 To 10
DllCall($8m,'bool','TerminateProcess','handle',$9h,'uint',0)
If @error Then $9i = 0
Sleep(30)
If Not ProcessExists($9f) Then
$9i = 1
ExitLoop
EndIf
Next
_yu($9h)
Return $9i
EndFunc
Func _yu($9j)
Local $98 = DllCall($8m,'bool','CloseHandle','handle',$9j)
If @error Then Return SetError(@error,0,0)
Return $98[0]
EndFunc
Func _yv($8q, ByRef $8y, ByRef $91, ByRef $8w, ByRef $8t, ByRef $8z, ByRef $90)
Local $9i, $9k
If Not $8z Then
If $8w Then _yx($8q,$88)
$9i = _yo($8q, $88, $90, $91, 0, $8y,0)
EndIf
If $8t Then
Local $9l = FileFindFirstFile($8q&'\*')
While 1
$9k = FileFindNextFile($9l)
If $8t = 1 Or $8t = 2 And @extended = 1 Then
_yv($8q&'\'&$9k, $8y, $91, $8w, $8t, $8z,$90)
ElseIf @error Then
ExitLoop
ElseIf $8t = 1 Or $8t = 3 Then
If $8w Then _yx($8q&'\'&$9k,$88)
_yo($8q&'\'&$9k, $88, $90, $91, 0, $8y,0)
EndIf
WEnd
FileClose($9l)
EndIf
If $8z Then
If $8w Then _yx($8q,$88)
$9i = _yo($8q, $88, $90, $91, 0, $8y,0)
EndIf
Return $9i
EndFunc
Func _yw($8q, ByRef $8y, ByRef $91, ByRef $8w, ByRef $8t, ByRef $8z, ByRef $90)
If $8p = 0 Then _y9()
Local $9i, $4g = 0, $9k
If Not $8z Then
If $8w Then _yx($8q,$8b)
$9i = _yo($8q, $8b, $90, $91, 0, $8y,0)
EndIf
If $8t Then
While 1
$4g += 1
$9k = RegEnumKey($8q,$4g)
If @error Then ExitLoop
_yw($8q&'\'&$9k, $8y, $91, $8w, $8t, $8z, $90)
WEnd
EndIf
If $8z Then
If $8w Then _yx($8q,$8b)
$9i = _yo($8q, $8b, $90, $91, 0, $8y,0)
EndIf
Return $9i
EndFunc
Func _yx($8q, $8r = $88)
If $8p = 0 Then _y9()
Local $9m = DllStructCreate('byte[32]'), $19
Local $8y = DllStructGetPtr($9m,1)
DllCall($8l,'bool','InitializeAcl','Ptr',$8y,'dword',DllStructGetSize($9m),'dword',$8k)
If IsPtr($8q) Then
$19 = DllCall($8l,"dword","SetSecurityInfo",'handle',$8q,'dword',$8r,'dword',4,'ptr',0,'ptr',0,'ptr',$8y,'ptr',0)
Else
If $8r = $8b Then $8q = _zb($8q)
DllCall($8l,'DWORD','SetNamedSecurityInfo','str',$8q,'dword',$8r,'DWORD',4,'ptr',0,'ptr',0,'ptr',0,'ptr',0)
$19 = DllCall($8l,'DWORD','SetNamedSecurityInfo','str',$8q,'dword',$8r,'DWORD',4,'ptr',0,'ptr',0,'ptr',$8y,'ptr',0)
EndIf
If @error Then Return SetError(@error,0,0)
Return SetError($19[0],0,Number($19[0] = 0))
EndFunc
Func _z0($8q, $8r = $88, $9n = 'Administrators')
If $8p = 0 Then _y9()
Local $9o = _za($9n), $19
Local $94 = DllStructGetPtr($9o)
If IsPtr($8q) Then
$19 = DllCall($8l,"dword","SetSecurityInfo",'handle',$8q,'dword',$8r,'dword',1,'ptr',$94,'ptr',0,'ptr',0,'ptr',0)
Else
If $8r = $8b Then $8q = _zb($8q)
$19 = DllCall($8l,'DWORD','SetNamedSecurityInfo','str',$8q,'dword',$8r,'DWORD',1,'ptr',$94,'ptr',0,'ptr',0,'ptr',0)
EndIf
If @error Then Return SetError(@error,0,False)
Return SetError($19[0],0,Number($19[0] = 0))
EndFunc
Func _za($9n)
If $9n = 'TrustedInstaller' Then $9n = 'NT SERVICE\TrustedInstaller'
If $9n = 'Everyone' Then
Return _zd('S-1-1-0')
ElseIf $9n = 'Authenticated Users' Then
Return _zd('S-1-5-11')
ElseIf $9n = 'System' Then
Return _zd('S-1-5-18')
ElseIf $9n = 'Administrators' Then
Return _zd('S-1-5-32-544')
ElseIf $9n = 'Users' Then
Return _zd('S-1-5-32-545')
ElseIf $9n = 'Guests' Then
Return _zd('S-1-5-32-546')
ElseIf $9n = 'Power Users' Then
Return _zd('S-1-5-32-547')
ElseIf $9n = 'Local Authority' Then
Return _zd('S-1-2')
ElseIf $9n = 'Creator Owner' Then
Return _zd('S-1-3-0')
ElseIf $9n = 'NT Authority' Then
Return _zd('S-1-5-1')
ElseIf $9n = 'Restricted' Then
Return _zd('S-1-5-12')
ElseIf StringRegExp($9n,'\A(S-1-\d+(-\d+){0,5})\z') Then
Return _zd($9n)
Else
Local $9o = _zc($9n)
Return _zd($9o)
EndIf
EndFunc
Func _zb($9p)
If StringInStr($9p,'\\') = 1 Then
$9p = StringRegExpReplace($9p,'(?i)\\(HKEY_CLASSES_ROOT|HKCR)','\CLASSES_ROOT')
$9p = StringRegExpReplace($9p,'(?i)\\(HKEY_CURRENT_USER|HKCU)','\CURRENT_USER')
$9p = StringRegExpReplace($9p,'(?i)\\(HKEY_LOCAL_MACHINE|HKLM)','\MACHINE')
$9p = StringRegExpReplace($9p,'(?i)\\(HKEY_USERS|HKU)','\USERS')
Else
$9p = StringRegExpReplace($9p,'(?i)\A(HKEY_CLASSES_ROOT|HKCR)','CLASSES_ROOT')
$9p = StringRegExpReplace($9p,'(?i)\A(HKEY_CURRENT_USER|HKCU)','CURRENT_USER')
$9p = StringRegExpReplace($9p,'(?i)\A(HKEY_LOCAL_MACHINE|HKLM)','MACHINE')
$9p = StringRegExpReplace($9p,'(?i)\A(HKEY_USERS|HKU)','USERS')
EndIf
Return $9p
EndFunc
Func _zc($9q, $9r = "")
Local $9s = DllStructCreate("byte SID[256]")
Local $94 = DllStructGetPtr($9s, "SID")
Local $33 = DllCall($8l, "bool", "LookupAccountNameW", "wstr", $9r, "wstr", $9q, "ptr", $94, "dword*", 256, "wstr", "", "dword*", 256, "int*", 0)
If @error Then Return SetError(@error, @extended, 0)
If Not $33[0] Then Return 0
Return _zf($94)
EndFunc
Func _zd($9t)
Local $33 = DllCall($8l, "bool", "ConvertStringSidToSidW", "wstr", $9t, "ptr*", 0)
If @error Then Return SetError(@error, @extended, 0)
If Not $33[0] Then Return 0
Local $9u = _ze($33[2])
Local $3u = DllStructCreate("byte Data[" & $9u & "]", $33[2])
Local $9v = DllStructCreate("byte Data[" & $9u & "]")
DllStructSetData($9v, "Data", DllStructGetData($3u, "Data"))
DllCall($8m, "ptr", "LocalFree", "ptr", $33[2])
Return $9v
EndFunc
Func _ze($94)
If Not _zg($94) Then Return SetError(-1, 0, "")
Local $33 = DllCall($8l, "dword", "GetLengthSid", "ptr", $94)
If @error Then Return SetError(@error, @extended, 0)
Return $33[0]
EndFunc
Func _zf($94)
If Not _zg($94) Then Return SetError(-1, 0, "")
Local $33 = DllCall($8l, "int", "ConvertSidToStringSidW", "ptr", $94, "ptr*", 0)
If @error Then Return SetError(@error, @extended, "")
If Not $33[0] Then Return ""
Local $3u = DllStructCreate("wchar Text[256]", $33[2])
Local $9t = DllStructGetData($3u, "Text")
DllCall($8m, "ptr", "LocalFree", "ptr", $33[2])
Return $9t
EndFunc
Func _zg($94)
Local $33 = DllCall($8l, "bool", "IsValidSid", "ptr", $94)
If @error Then Return SetError(@error, @extended, False)
Return $33[0]
EndFunc
Func _zh($9w)
Local $9x = UBound($9w, 0), $9y[1][2]
If Not($9x <= 2 And UBound($9w, $9x) = 2 ) Then Return SetError(1300, 0, $9y)
If $9x = 1 Then
Local $9z[1][2]
$9z[0][0] = $9w[0]
$9z[0][1] = $9w[1]
$9w = $9z
$9z = 0
EndIf
Local $59, $a0 = "dword", $a1 = UBound($9w, 1)
Do
$59 += 1
$a0 &= ";dword;long;dword"
Until $59 = $a1
Local $a2, $a3, $a4, $a5, $a6, $a7, $a8
$a2 = DLLStructCreate($a0)
$a3 = DllStructCreate($a0)
$a4 = DllStructGetPtr($a3)
$a5 = DllStructCreate("dword;long")
DLLStructSetData($a2, 1, $a1)
For $4g = 0 To $a1 - 1
DllCall($8l, "int", "LookupPrivilegeValue", "str", "", "str", $9w[$4g][0], "ptr", DllStructGetPtr($a5) )
DLLStructSetData( $a2, 3 * $4g + 2, DllStructGetData($a5, 1) )
DLLStructSetData( $a2, 3 * $4g + 3, DllStructGetData($a5, 2) )
DLLStructSetData( $a2, 3 * $4g + 4, $9w[$4g][1] )
Next
$a6 = DllCall($8m, "hwnd", "GetCurrentProcess")
$a7 = DllCall($8l, "int", "OpenProcessToken", "hwnd", $a6[0], "dword", BitOR(0x00000020, 0x00000008), "hwnd*", 0 )
DllCall( $8l, "int", "AdjustTokenPrivileges", "hwnd", $a7[3], "int", False, "ptr", DllStructGetPtr($a2), "dword", DllStructGetSize($a2), "ptr", $a4, "dword*", 0 )
$a8 = DllCall($8m, "dword", "GetLastError")
DllCall($8m, "int", "CloseHandle", "hwnd", $a7[3])
Local $a9 = DllStructGetData($a3, 1)
If $a9 > 0 Then
Local $aa, $ab, $ac, $9y[$a9][2]
For $4g = 0 To $a9 - 1
$aa = $a4 + 12 * $4g + 4
$ab = DllCall($8l, "int", "LookupPrivilegeName", "str", "", "ptr", $aa, "ptr", 0, "dword*", 0 )
$ac = DllStructCreate("char[" & $ab[4] & "]")
DllCall($8l, "int", "LookupPrivilegeName", "str", "", "ptr", $aa, "ptr", DllStructGetPtr($ac), "dword*", DllStructGetSize($ac) )
$9y[$4g][0] = DllStructGetData($ac, 1)
$9y[$4g][1] = DllStructGetData($a3, 3 * $4g + 4)
Next
EndIf
Return SetError($a8[0], 0, $9y)
EndFunc
Global $ad
Global $ae
Global $af
Global $ag
Global $ah
Global $ai = -1
Func _zi($aj, $ak = "", $al = -1, $am = True)
If $al <> -1 Then
If $al > -1 And $al < 7 Then
$ae = ObjCreate("Msxml2.DOMDocument." & $al & ".0")
If IsObj($ae) Then
$ai = $al
EndIf
Else
MsgBox(266288, "Error:", "Failed to create object with MSXML version " & $al)
SetError(1)
Return 0
EndIf
Else
For $2b = 8 To 0 Step - 1
If FileExists(@SystemDir & "\msxml" & $2b & ".dll") Then
$ae = ObjCreate("Msxml2.DOMDocument." & $2b & ".0")
If IsObj($ae) Then
$ai = $2b
ExitLoop
EndIf
EndIf
Next
EndIf
If Not IsObj($ae) Then
_10d("Error: MSXML not found. This object is required to use this program.")
SetError(2)
Return -1
EndIf
$af = ObjEvent("AutoIt.Error")
If $af = "" Then
$af = ObjEvent("AutoIt.Error", "_10e")
EndIf
$ad = $aj
$ae.async = False
$ae.preserveWhiteSpace = True
$ae.validateOnParse = $am
if $ai > 4 Then $ae.setProperty("ProhibitDTD",false)
$ae.Load($ad)
$ae.setProperty("SelectionLanguage", "XPath")
$ae.setProperty("SelectionNamespaces", $ak)
if $ae.parseError.errorCode >0 Then consoleWrite($ae.parseError.reason&@LF)
If $ae.parseError.errorCode <> 0 Then
_10d("Error opening specified file: " & $aj & @CRLF & $ae.parseError.reason)
SetError(1,$ae.parseError.errorCode,-1)
$ae = 0
Return -1
EndIf
Return 1
EndFunc
Func _zl($an)
If not IsObj($ae) then
_10d("No object passed to function _XMLSelectNodes")
Return SetError(2,0,-1)
EndIf
Local $ao, $ap, $aq[1], $ar
$ap = $ae.selectNodes($an)
If Not IsObj($ap) Then
_10d("\nNo matching nodes found")
Return SetError(1,0,-1)
EndIf
If $ap.length < 1 Then
_10d("\nNo matching nodes found")
Return SetError(1,0,-1)
EndIf
For $ao In $ap
_10q($aq, $ao.nodeName)
_10g($ao.nodeName)
_10g($ao.namespaceURI)
Next
$aq[0] = $ap.length
Return $aq
_10d("Error Selecting Node(s): " & $an & $ar)
Return SetError(1,0,-1)
EndFunc
Func _zr($an, $as, $at = "")
If not IsObj($ae) then
_10d("No object passed to function _XMLGetAttrib")
Return SetError(2,0,-1)
EndIf
Local $ap, $aq, $4g, $ar, $au
$ap = $ae.documentElement.selectNodes($an & $at)
_10g("Get Attrib length= " & $ap.length)
If $ap.length > 0 Then
For $4g = 0 To $ap.length - 1
$au = $ap.item($4g).getAttribute($as)
$aq = $au
_10g("RET>>" & $au)
Next
Return $aq
EndIf
$ar = "\nNo qualified items found"
_10d("Attribute " & $as & " not found for: " & $an & $ar)
Return SetError(1,0,-1)
EndFunc
Func _zt($an, ByRef $av, ByRef $aw, $ax = "")
If not IsObj($ae) then
_10d("No object passed to function _XMLGetAllAttrib")
Return SetError(1,9,-1)
EndIf
Local $ap, $ay, $ao, $aq[2][1], $4g
$ay = $ae.selectNodes($an & $ax)
If $ay.length > 0 Then
For $ao In $ay
$ap = $ao.attributes
If($ap.length) Then
_10g("Get all attrib " & $ap.length)
ReDim $aq[2][$ap.length + 2]
ReDim $av[$ap.length]
ReDim $aw[$ap.length]
For $4g = 0 To $ap.length - 1
$aq[0][$4g + 1] = $ap.item($4g).nodeName
$aq[1][$4g + 1] = $ap.item($4g).Value
$av[$4g] = $ap.item($4g).nodeName
$aw[$4g] = $ap.item($4g).Value
Next
Else
_10d("No Attributes found for node")
Return SetError(1,0, -1)
EndIf
Next
$aq[0][0] = $ap.length
Return $aq
EndIf
_10d("Error retrieving attributes for: " & $an & @CRLF)
return SetError(1,0 ,-1)
EndFunc
Func _10d($az = "")
If $az = "" Then
$az = $ag
$ag = ""
Return $az
Else
$ag = StringFormat($az)
EndIf
_10g($ag)
EndFunc
Func _10e()
_10f()
Return
EndFunc
Func _10f($b0 = "")
Local $b1, $b2
If $b0 = True Or $b0 = False Then
$b1 = $b0
$b0 = ""
EndIf
$b2 = Hex($af.number, 8)
If @error Then Return
Local $b3 = "COM Error with DOM!" & @CRLF & @CRLF & "err.description is: " & @TAB & $af.description & @CRLF & "err.windescription:" & @TAB & $af.windescription & @CRLF & "err.number is: " & @TAB & $b2 & @CRLF & "err.lastdllerror is: " & @TAB & $af.lastdllerror & @CRLF & "err.scriptline is: " & @TAB & $af.scriptline & @CRLF & "err.source is: " & @TAB & $af.source & @CRLF & "err.helpfile is: " & @TAB & $af.helpfile & @CRLF & "err.helpcontext is: " & @TAB & $af.helpcontext
If $b1 <> True Then
MsgBox(0, @AutoItExe, $b3)
Else
_10d($b3)
EndIf
SetError(1)
EndFunc
Func _10g($b4, $b5 = @LF)
If $ah Then
ConsoleWrite(StringFormat($b4)&$b5)
EndIf
EndFunc
Func _10q(ByRef $b6, $b7)
If IsArray($b6) Then
ReDim $b6[UBound($b6) + 1]
$b6[UBound($b6) - 1] = $b7
SetError(0)
Return 1
Else
SetError(1)
Return 0
EndIf
EndFunc
Func _10r()
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
Func _10s($b8 = False, $b9 = True)
Dim $7b
Dim $ba
FileDelete(@TempDir & "\kprm-logo.gif")
FileDelete(@TempDir & "\kprm-tools.xml")
If $b8 = True Then
If $b9 = True Then
Run("notepad.exe " & @HomeDrive & "\KPRM" & "\" & $ba)
EndIf
If $7b = False Then
Run(@ComSpec & ' /c timeout 3 && del /F /Q "' & @ScriptFullPath & '"', @TempDir, @SW_HIDE)
FileDelete(@ScriptFullPath)
EndIf
EndIf
Exit
EndFunc
Func _10t()
Local $bb = DllCall('connect.dll', 'long', 'IsInternetConnected')
If @error Then
Return SetError(1, 0, False)
EndIf
Return $bb[0] = 0
EndFunc
Func _10u($bc, $bd = "")
Local $be = ObjCreate("WinHttp.WinHttpRequest.5.1")
$be.Open("GET", $bc & "?" & $bd, False)
$be.SetTimeouts(50, 50, 50, 50)
If(@error) Then Return SetError(1, 0, 0)
$be.Send()
If(@error) Then Return SetError(2, 0, 0)
If($be.Status <> 200) Then Return SetError(3, 0, 0)
Return SetError(0, 0, $be.ResponseText)
EndFunc
Func _10v()
Dim $7c
Dim $7b
If $7b = True Then Return
Local Const $bf = _10t()
If $bf = False Then
Return Null
EndIf
Local Const $bg = _10u("https://kernel-panik.me/_api/v1/kprm/version")
If $bg <> Null And $bg <> "" And $bg <> $7c Then
MsgBox(64, $7p, $7q)
ShellExecute("https://kernel-panik.me/tool/kprm/")
_10s(True, False)
EndIf
EndFunc
Func _10w()
Local $7w = ""
If @OSArch = "X64" Then $7w = "64"
Return $7w
EndFunc
Func _10x($b4)
Dim $ba
FileWrite(@HomeDrive & "\KPRM" & "\" & $ba, $b4 & @CRLF)
EndFunc
Func _10y()
Local $bh = 100, $bi = 100, $bj = 0, $bk = @WindowsDir & "\Explorer.exe"
_hf($3c, 0, 0, 0)
Local $bl = _d0("Shell_TrayWnd", "")
_51($bl, 1460, 0, 0)
While ProcessExists("Explorer.exe")
Sleep(10)
$bh -= ProcessClose("Explorer.exe") ? 0 : 1
If $bh < 1 Then Return SetError(1, 0, 0)
WEnd
While(Not ProcessExists("Explorer.exe"))
If Not FileExists($bk) Then Return SetError(-1, 0, 0)
Sleep(500)
$bj = ShellExecute($bk)
$bi -= $bj ? 0 : 1
If $bi < 1 Then Return SetError(2, 0, 0)
WEnd
Return $bj
EndFunc
Func _10z($bm, $bn, $bo)
Local $4g = 0
While True
$4g += 1
Local $bp = RegEnumKey($bm, $4g)
If @error <> 0 Then ExitLoop
Local $bq = $bm & "\" & $bp
Local $6s = RegRead($bq, $bo)
If StringRegExp($6s, $bn) Then
Return $bq
EndIf
WEnd
Return Null
EndFunc
Func _111()
Local $br = []
If FileExists(@HomeDrive & "\Program Files") Then
_vv($br, @HomeDrive & "\Program Files")
EndIf
If FileExists(@HomeDrive & "\Program Files (x86)") Then
_vv($br, @HomeDrive & "\Program Files (x86)")
EndIf
If FileExists(@HomeDrive & "\Program Files(x86)") Then
_vv($br, @HomeDrive & "\Program Files(x86)")
EndIf
Return $br
EndFunc
Func _112($5r)
Return Int(FileExists($5r) And StringInStr(FileGetAttrib($5r), 'D', Default, 1) = 0)
EndFunc
Func _113($5r)
Return Int(FileExists($5r) And StringInStr(FileGetAttrib($5r), 'D', Default, 1) > 0)
EndFunc
Func _114($5r)
Local $bs = Null
If FileExists($5r) Then
Local $bt = StringInStr(FileGetAttrib($5r), 'D', Default, 1)
If $bt = 0 Then
$bs = 'file'
ElseIf $bt > 0 Then
$bs = 'folder'
EndIf
EndIf
Return $bs
EndFunc
Func _115()
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
Func _116($bu)
If StringRegExp($bu, "^(HKLM|HKCU|HKU|HKCR|HKCC)64") Then
Local $bo = StringReplace($bu, "64", "", 1)
Return $bo
EndIf
Return $bu
EndFunc
Func _117($bv, $bo)
If $bv.Exists($bo) Then
Local $bt = $bv.Item($bo) + 1
$bv.Item($bo) = $bt
Else
$bv.add($bo, 1)
EndIf
Return $bv
EndFunc
Func _118($bw, $bx, $by)
Dim $bz
Local $c0 = $bz.Item($bw)
Local $c1 = _117($c0.Item($bx), $by)
$c0.Item($bx) = $c1
$bz.Item($bw) = $c0
EndFunc
Func _119($c2, $c3)
If $c2 = Null Or $c2 = "" Then Return
Local $c4 = ProcessExists($c2)
If $c4 <> 0 Then
_10x("     [X] Process " & $c2 & " not killed, it is possible that the deletion is not complete (" & $c3 & ")")
Else
_10x("     [OK] Process " & $c2 & " killed (" & $c3 & ")")
EndIf
EndFunc
Func _11a($c5, $c3)
If $c5 = Null Or $c5 = "" Then Return
Local $c6 = "[X]"
RegEnumVal($c5, "1")
If @error >= 0 Then
$c6 = "[OK]"
EndIf
_10x("     " & $c6 & " " & _116($c5) & " deleted (" & $c3 & ")")
EndFunc
Func _11b($c5, $c3)
If $c5 = Null Or $c5 = "" Then Return
Local $78 = "", $79 = "", $5x = "", $7a = ""
Local $c7 = _xe($c5, $78, $79, $5x, $7a)
If $7a = ".exe" Then
Local $c8 = $c7[1] & $c7[2]
Local $c6 = "[OK]"
If FileExists($c8) Then
$c6 = "[X]"
EndIf
_10x("     " & $c6 & " Uninstaller run correctly (" & $c3 & ")")
EndIf
EndFunc
Func _11c($c5, $c3)
If $c5 = Null Or $c5 = "" Then Return
Local $c6 = "[OK]"
If FileExists($c5) Then
$c6 = "[X]"
EndIf
_10x("     " & $c6 & " " & $c5 & " deleted (" & $c3 & ")")
EndFunc
Func _11d($1p, $c5, $c3)
Switch $1p
Case "process"
_119($c5, $c3)
Case "key"
_11a($c5, $c3)
Case "uninstall"
_11b($c5, $c3)
Case "element"
_11c($c5, $c3)
Case Else
_10x("     [?] Unknown type " & $1p)
EndSwitch
EndFunc
Local $c9 = 43
Local $ca
Local Const $cb = Floor(100 / $c9)
Func _11e($cc = 1)
$ca += $cc
Dim $cd
GUICtrlSetData($cd, $ca * $cb)
If $ca = $c9 Then
GUICtrlSetData($cd, 100)
EndIf
EndFunc
Func _11f()
$ca = 0
Dim $cd
GUICtrlSetData($cd, 0)
EndFunc
Func _11g()
_10x(@CRLF & "- Clear All System Restore Points -" & @CRLF)
Local Const $ce = _y2()
Local $cf = 0
If $ce[0][0] = 0 Then
_10x("  [I] No system recovery points were found")
Return Null
EndIf
Local $cg[1][3] = [[Null, Null, Null]]
For $4g = 1 To $ce[0][0]
Local $c4 = _y4($ce[$4g][0])
$cf += $c4
If $c4 = 1 Then
_10x("    => [OK] RP named " & $ce[$4g][1] & " created at " & $ce[$4g][2] & " deleted")
Else
Local $ch[1][3] = [[$ce[$4g][0], $ce[$4g][1], $ce[$4g][2]]]
_vv($cg, $ch)
EndIf
Next
If 1 < UBound($cg) Then
Sleep(3000)
For $4g = 1 To UBound($cg) - 1
Local $c4 = _y4($cg[$4g][0])
$cf += $c4
If $c4 = 1 Then
_10x("    => [OK] RP named " & $cg[$4g][1] & " created at " & $ce[$4g][2] & " deleted")
Else
_10x("    => [X] RP named " & $cg[$4g][1] & " created at " & $ce[$4g][2] & " deleted")
EndIf
Next
EndIf
If $ce[0][0] = $cf Then
_10x(@CRLF & "  [OK] All system restore points have been successfully deleted")
Else
_10x(@CRLF & "  [X] Failure when deleting all restore points")
EndIf
EndFunc
Func _11h($ci)
Local $cj = StringLeft($ci, 4)
Local $ck = StringMid($ci, 6, 2)
Local $cl = StringMid($ci, 9, 2)
Local $cm = StringRight($ci, 8)
Return $ck & "/" & $cl & "/" & $cj & " " & $cm
EndFunc
Func _11i($cn = False)
Local Const $ce = _y2()
If $ce[0][0] = 0 Then
Return Null
EndIf
Local Const $co = _11h(_31('n', -1470, _3p()))
Local $cp = False
Local $cq = False
Local $cr = False
For $4g = 1 To $ce[0][0]
Local $cs = $ce[$4g][2]
If $cs > $co Then
If $cr = False Then
$cr = True
$cq = True
_10x(@CRLF & "  [I] Recent System Restore Point Deletion before create new:" & @CRLF)
EndIf
Local $c4 = _y4($ce[$4g][0])
If $c4 = 1 Then
_10x("    => [OK] RP named " & $ce[$4g][1] & " created at " & $cs & " deleted")
ElseIf $cn = False Then
$cp = True
Else
_10x("    => [X] RP named " & $ce[$4g][1] & " created at " & $cs & " deleted")
EndIf
EndIf
Next
If $cp = True Then
Sleep(3000)
_10x("  [I] Retry deleting restore point")
_11i(True)
EndIf
If $cq = True Then
_10x(@CRLF)
EndIf
Sleep(3000)
EndFunc
Func _11j()
Sleep(3000)
_10x(@CRLF & "- Display All System Restore Point -" & @CRLF)
Local Const $ce = _y2()
If $ce[0][0] = 0 Then
_10x("  [X] No System Restore point found")
Return
EndIf
For $4g = 1 To $ce[0][0]
_10x("    => [I] RP named " & $ce[$4g][1] & " created at " & $ce[$4g][2] & " found")
Next
EndFunc
Func _11k()
RunWait(@ComSpec & ' /c ' & 'wmic.exe /Namespace:\\root\default Path SystemRestore Call CreateRestorePoint "KpRm", 100, 7', "", @SW_HIDE)
Return @error
EndFunc
Func _11l($cn = False)
If $cn = False Then
_10x(@CRLF & "- Create New System Restore Point -" & @CRLF)
Else
_10x("  [I] Retry Create New System Restore Point")
EndIf
Local $ct = _y6()
If $ct = 0 Then
Sleep(3000)
$ct = _y6()
If $ct = 0 Then
_10x("  [X] Enable System Restore")
EndIf
ElseIf $ct = 1 Then
_10x("  [OK] Enable System Restore")
EndIf
_11i()
Local Const $cu = _11k()
If $cu <> 0 Then
_10x("  [X] System Restore Point created")
If $cn = False Then
_10x("  [I] Retry to create System Restore Point!")
_11l(True)
Return
Else
_11j()
Return
EndIf
ElseIf $cu = 0 Then
_10x("  [OK] System Restore Point created")
_11j()
EndIf
EndFunc
Func _11m()
_10x(@CRLF & "- Create Registry Backup -" & @CRLF)
Local Const $cv = @HomeDrive & "\KPRM"
Local Const $cw = $cv & "\regedit-backup-" & @YEAR & @MON & @MDAY & @HOUR & @MIN & ".reg"
If FileExists($cw) Then
FileMove($cw, $cw & ".old")
EndIf
Local Const $cx = RunWait("Regedit /e " & $cw)
If Not FileExists($cw) Or @error <> 0 Then
_10x("  [X] Failed to create registry backup")
MsgBox(16, $7m, $7n)
_10s()
Else
_10x("  [OK] Registry Backup: " & $cw)
EndIf
EndFunc
Func _11n()
_10x(@CRLF & "- Restore UAC Default Value -" & @CRLF)
Local $c4 = _xr()
If $c4 = 1 Then
_10x("  [OK] Set ConsentPromptBehaviorAdmin with default (5) value")
Else
_10x("  [X] Set ConsentPromptBehaviorAdmin with default value")
EndIf
Local $c4 = _xs(3)
If $c4 = 1 Then
_10x("  [OK] Set ConsentPromptBehaviorUser with default (3) value")
Else
_10x("  [X] Set ConsentPromptBehaviorUser with default value")
EndIf
Local $c4 = _xt()
If $c4 = 1 Then
_10x("  [OK] Set EnableInstallerDetection with default (0) value")
Else
_10x("  [X] Set EnableInstallerDetection with default value")
EndIf
Local $c4 = _xu()
If $c4 = 1 Then
_10x("  [OK] Set EnableLUA with default (1) value")
Else
_10x("  [X] Set EnableLUA with default value")
EndIf
Local $c4 = _xv()
If $c4 = 1 Then
_10x("  [OK] Set EnableSecureUIAPaths with default (1) value")
Else
_10x("  [X] Set EnableSecureUIAPaths with default value")
EndIf
Local $c4 = _xw()
If $c4 = 1 Then
_10x("  [OK] Set EnableUIADesktopToggle with default (0) value")
Else
_10x("  [X] Set EnableUIADesktopToggle with default value")
EndIf
Local $c4 = _xx()
If $c4 = 1 Then
_10x("  [OK] Set EnableVirtualization with default (1) value")
Else
_10x("  [X] Set EnableVirtualization with default value")
EndIf
Local $c4 = _xy()
If $c4 = 1 Then
_10x("  [OK] Set FilterAdministratorToken with default (0) value")
Else
_10x("  [X] Set FilterAdministratorToken with default value")
EndIf
Local $c4 = _xz()
If $c4 = 1 Then
_10x("  [OK] Set PromptOnSecureDesktop with default (1) value")
Else
_10x("  [X] Set PromptOnSecureDesktop with default value")
EndIf
Local $c4 = _y0()
If $c4 = 1 Then
_10x("  [OK] Set ValidateAdminCodeSignatures with default (0) value")
Else
_10x("  [X] Set ValidateAdminCodeSignatures with default value")
EndIf
EndFunc
Func _11o()
_10x(@CRLF & "- Restore Default System Settings -" & @CRLF)
Local $c4 = RunWait(@ComSpec & " /c " & "ipconfig /flushdns", @TempDir, @SW_HIDE)
If @error <> 0 Then
_10x("  [X] Flush DNS")
Else
_10x("  [OK] Flush DNS")
EndIf
Local Const $cy[7] = [ "netsh winsock reset", "netsh winhttp reset proxy", "netsh winhttp reset tracing", "netsh winsock reset catalog", "netsh int ip reset all", "netsh int ipv4 reset catalog", "netsh int ipv6 reset catalog" ]
$c4 = 0
For $4g = 0 To UBound($cy) -1
RunWait(@ComSpec & " /c " & $cy[$4g], @TempDir, @SW_HIDE)
If @error <> 0 Then
$c4 += 1
EndIf
Next
If $c4 = 0 Then
_10x("  [OK] Reset WinSock")
Else
_10x("  [X] Reset WinSock")
EndIf
Local $cz = "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced"
$c4 = RegWrite($cz, "Hidden", "REG_DWORD", "2")
If $c4 = 1 Then
_10x("  [OK] Hide Hidden file.")
Else
_10x("  [X] Hide Hidden File")
EndIf
$c4 = RegWrite($cz, "HideFileExt", "REG_DWORD", "0")
If $c4 = 1 Then
_10x("  [OK] Show Extensions for known file types")
Else
_10x("  [X] Show Extensions for known file types")
EndIf
$c4 = RegWrite($cz, "ShowSuperHidden", "REG_DWORD", "0")
If $c4 = 1 Then
_10x("  [OK] Hide protected operating system files")
Else
_10x("  [X] Hide protected operating system files")
EndIf
_10y()
EndFunc
Func _11p($bm, $d0 = 0, $d1 = False)
If $d1 Then
_yx($bm)
_yf($bm)
EndIf
Local Const $d2 = FileGetAttrib($bm)
If StringInStr($d2, "R") Then
FileSetAttrib($bm, "-R", $d0)
EndIf
If StringInStr($d2, "S") Then
FileSetAttrib($bm, "-S", $d0)
EndIf
If StringInStr($d2, "H") Then
FileSetAttrib($bm, "-H", $d0)
EndIf
If StringInStr($d2, "A") Then
FileSetAttrib($bm, "-A", $d0)
EndIf
EndFunc
Func _11q($d3, $bw, $d4 = Null, $d1 = False)
Local Const $d5 = _112($d3)
If $d5 Then
If $d4 And StringRegExp($d3, "(?i)\.(exe|com)$") Then
Local Const $d6 = FileGetVersion($d3, "CompanyName")
If @error Then
Return 0
ElseIf Not StringRegExp($d6, $d4) Then
Return 0
EndIf
EndIf
_118($bw, 'element', $d3)
_11p($d3, 0, $d1)
Local $d7 = FileDelete($d3)
If $d7 Then
Return 1
EndIf
Return 2
EndIf
Return 0
EndFunc
Func _11r($bm, $bw, $d1 = False)
Local $d5 = _113($bm)
If $d5 Then
_118($bw, 'element', $bm)
_11p($bm, 1, $d1)
Local Const $d7 = DirRemove($bm, $q)
If $d7 Then
Return 1
EndIf
Return 2
EndIf
Return 0
EndFunc
Func _11s($bm, $d3, $d8)
Local Const $d9 = $bm & "\" & $d3
Local Const $5z = FileFindFirstFile($d9)
Local $bb = []
If $5z = -1 Then
Return $bb
EndIf
Local $5x = FileFindNextFile($5z)
While @error = 0
If StringRegExp($5x, $d8) Then
_vv($bb, $bm & "\" & $5x)
EndIf
$5x = FileFindNextFile($5z)
WEnd
FileClose($5z)
Return $bb
EndFunc
Func _11t($da, $db)
Local $dc = _114($da)
If $dc = Null Then
Return Null
EndIf
Local $78 = "", $79 = "", $5x = "", $7a = ""
Local $c7 = _xe($da, $78, $79, $5x, $7a)
Local $d3 = $5x & $7a
For $dd = 1 To UBound($db) - 1
If $db[$dd][3] And $dc = $db[$dd][1] And StringRegExp($d3, $db[$dd][3]) Then
Local $c4 = 0
Local $d1 = False
If $db[$dd][4] = True Then
$d1 = True
EndIf
If $dc = 'file' Then
$c4 = _11q($da, $db[$dd][0], $db[$dd][2], $d1)
ElseIf $dc = 'folder' Then
$c4 = _11r($da, $db[$dd][0], $d1)
EndIf
EndIf
Next
EndFunc
Func _11u($bm, $db, $de = -2)
Local $46 = _x2($bm, "*.exe;*.txt;*.lnk;*.log;*.reg;*.zip;*.dat;*.scr;*.com;*.bat", $t, $de, $y, $10)
If @error <> 0 Then
Return Null
EndIf
For $4g = 1 To $46[0]
_11t($46[$4g], $db)
Next
EndFunc
Func _11v($bm, $db)
Local Const $d9 = $bm & "\*"
Local Const $5z = FileFindFirstFile($d9)
If $5z = -1 Then
Return Null
EndIf
Local $5x = FileFindNextFile($5z)
While @error = 0
Local $da = $bm & "\" & $5x
_11t($da, $db)
$5x = FileFindNextFile($5z)
WEnd
FileClose($5z)
EndFunc
Func _11w($df, $bw, $d1 = False)
If $d1 = True Then
_yx($df)
_yf($df, $8b)
EndIf
Local Const $c4 = RegDelete($df)
If $c4 <> 0 Then
_118($bw, "key", $df)
EndIf
Return $c4
EndFunc
Func _11x($c2, $d1)
Local $dg = 50
Local $c4 = Null
If 0 = ProcessExists($c2) Then Return 0
If $d1 = True Then
_yt($c2)
If 0 = ProcessExists($c2) Then Return 0
EndIf
ProcessClose($c2)
Do
$dg -= 1
Sleep(250)
Until($dg = 0 Or 0 = ProcessExists($c2))
$c4 = ProcessExists($c2)
If 0 = $c4 Then
Return 1
EndIf
Return 0
EndFunc
Func _11y($74)
Dim $dg
Local $dh = ProcessList()
For $4g = 1 To $dh[0][0]
Local $di = $dh[$4g][0]
Local $dj = $dh[$4g][1]
For $dg = 1 To UBound($74) - 1
If StringRegExp($di, $74[$dg][1]) Then
_11x($dj, $74[$dg][2])
_118($74[$dg][0], "process", $di)
EndIf
Next
Next
EndFunc
Func _11z($74)
For $4g = 1 To UBound($74) - 1
RunWait('schtasks.exe /delete /tn "' & $74[$4g][1] & '" /f', @TempDir, @SW_HIDE)
Next
EndFunc
Func _120($74)
Local Const $br = _111()
For $4g = 1 To UBound($br) - 1
For $dk = 1 To UBound($74) - 1
Local $dl = $74[$dk][1]
Local $dm = $74[$dk][2]
Local $dn = _11s($br[$4g], "*", $dl)
For $do = 1 To UBound($dn) - 1
Local $dp = _11s($dn[$do], "*", $dm)
For $dq = 1 To UBound($dp) - 1
If _112($dp[$dq]) Then
RunWait($dp[$dq])
_118($74[$dk][0], "uninstall", $dp[$dq])
EndIf
Next
Next
Next
Next
EndFunc
Func _121($74)
Local Const $br = _111()
For $4g = 1 To UBound($br) - 1
_11v($br[$4g], $74)
Next
EndFunc
Func _122($74)
Local $7w = _10w()
Local $dr[2] = ["HKCU" & $7w & "\SOFTWARE", "HKLM" & $7w & "\SOFTWARE"]
For $59 = 0 To UBound($dr) - 1
Local $4g = 0
While True
$4g += 1
Local $bp = RegEnumKey($dr[$59], $4g)
If @error <> 0 Then ExitLoop
For $dk = 1 To UBound($74) - 1
If $bp And $74[$dk][1] Then
If StringRegExp($bp, $74[$dk][1]) Then
Local $ds = $dr[$59] & "\" & $bp
_11w($ds, $74[$dk][0])
EndIf
EndIf
Next
WEnd
Next
EndFunc
Func _123($74)
For $4g = 1 To UBound($74) - 1
Local $ds = _10z($74[$4g][1], $74[$4g][2], $74[$4g][3])
If $ds And $ds <> "" Then
_11w($ds, $74[$4g][0])
EndIf
Next
EndFunc
Func _124($74)
For $4g = 1 To UBound($74) - 1
_11w($74[$4g][1], $74[$4g][0], $74[$4g][2])
Next
EndFunc
Func _125($74)
For $4g = 1 To UBound($74) - 1
If FileExists($74[$4g][1]) Then
Local $dt = _x1($74[$4g][1])
If @error = 0 Then
For $do = 1 To $dt[0]
_11q($74[$4g][1] & '\' & $dt[$do], $74[$4g][0], $74[$4g][2], $74[$4g][3])
Next
EndIf
EndIf
Next
EndFunc
Global $bz = ObjCreate("Scripting.Dictionary")
Local $du[0]
Local $dv = ["desktop", "desktopCommon", "download", "homeDrive", "programFiles", "appData", "appDataCommon", "appDataLocal", "windowsFolder", "appDataCommonStartMenuFolder"]
Local $dw = _zi(@TempDir & "\kprm-tools.xml")
Func _126($cm)
If _we($dv, $cm) Then
Local $dx[4] = ["type", "companyName", "pattern", "force"]
Return $dx
ElseIf $cm = "uninstal" Then
Local $dx[2] = ["folder", "binary"]
Return $dx
ElseIf $cm = "task" Then
Local $dx[1] = ["name"]
Return $dx
ElseIf $cm = "softwareKey" Then
Local $dx[1] = ["pattern"]
Return $dx
ElseIf $cm = "registryKey" Then
Local $dx[2] = ["key", "force"]
Return $dx
ElseIf $cm = "searchRegistryKey" Then
Local $dx[3] = ["key", "pattern", "value"]
Return $dx
ElseIf $cm = "cleanDirectory" Then
Local $dx[3] = ["path", "companyName", "force"]
Return $dx
EndIf
EndFunc
Func _127($dy, $dz, $e0, $dx)
Local $33[1] = [$dy]
For $4g = 0 To UBound($dx) - 1
For $dk = 0 To UBound($dz) - 1
If $dx[$4g] = $dz[$dk] Then
_vv($33, $e0[$dk], 0, "£")
EndIf
Next
Next
Return $33
EndFunc
Local $e1 = _zl("/tools/tool")
For $4g = 1 To $e1[0]
Local $e2 = _zr("/tools/tool[" & $4g & "]", "name")
_vv($du, $e2)
Local $e3 = ObjCreate("Scripting.Dictionary")
Local $e4 = ObjCreate("Scripting.Dictionary")
Local $e5 = ObjCreate("Scripting.Dictionary")
Local $e6 = ObjCreate("Scripting.Dictionary")
Local $e7 = ObjCreate("Scripting.Dictionary")
$e3.add("key", $e4)
$e3.add("element", $e5)
$e3.add("uninstall", $e6)
$e3.add("process", $e7)
$bz.add($e2, $e3)
Next
For $e8 = 0 To UBound($du) - 1
Next
Func _128($cn = False)
If $cn = True Then
_10x(@CRLF & "- Search Tools -" & @CRLF)
EndIf
Local Const $e9 = [ "process", "uninstall", "task", "desktop", "desktopCommon", "download", "programFile", "homeDrive", "appData", "appDataCommon", "appDataLocal", "windowsFolder", "softwareKey", "registryKey", "searchRegistryKey", "appDataCommonStartMenuFolder", "cleanDirectory"]
Local $e1 = _zl("/tools/tool")
For $ea = 0 To UBound($e9) - 1
Local $eb = $e9[$ea]
Local $dx = _126($eb)
Local $ec[1][UBound($dx + 1)] = [[]]
For $4g = 1 To $e1[0]
Local $e2 = _zr("/tools/tool[" & $4g & "]", "name")
_vv($du, $e2)
Local $ed = _zl("/tools/tool[" & $4g & "]/*")
For $dk = 1 To $ed[0]
Local $ee = $ed[$dk]
If $ee = $eb Then
Local $av[1], $aw[1]
_zt("/tools/tool[" & $4g & "]/*[" & $dk & "]", $av, $aw)
Local $ef = _127($e2, $av, $aw, $dx)
_vv($ec, $ef)
EndIf
Next
Next
Switch $eb
Case "process"
_11y($ec)
Case "uninstall"
_120($ec)
Case "task"
_11z($ec)
Case "desktop"
_11u(@DesktopDir, $ec)
Case "desktopCommon"
_11v(@DesktopCommonDir, $ec)
Case "download"
_11u(@UserProfileDir & "\Downloads", $ec)
Case "programFile"
_121($ec)
Case "homeDrive"
_11v(@HomeDrive, $ec)
Case "appDataCommon"
_11v(@AppDataCommonDir, $ec)
Case "appDataLocal"
_11v(@LocalAppDataDir, $ec)
Case "windowsFolder"
_11v(@WindowsDir, $ec)
Case "softwareKey"
_122($ec)
Case "registryKey"
_124($ec)
Case "searchRegistryKey"
_123($ec)
Case "appDataCommonStartMenuFolder"
_11v(@AppDataCommonDir & "\Microsoft\Windows\Start Menu\Programs", $ec)
Case "cleanDirectory"
_125($ec)
EndSwitch
_11e()
Next
If $cn = True Then
Local $eg = False
Local Const $eh[4] = ["process", "uninstall", "element", "key"]
Local Const $ei = "Warning, folder " & @AppDataDir & "\ZHP exists and contains the quarantines of the ZHP tools. At the request of the publisher (Nicolas Coolman) this folder is not deleted. "
Local $ej = False
Local Const $ek = _113(@AppDataDir & "\ZHP")
For $el In $bz
Local $em = $bz.Item($el)
Local $en = False
For $eo = 0 To UBound($eh) - 1
Local $ep = $eh[$eo]
Local $eq = $em.Item($ep)
Local $er = $eq.Keys
If UBound($er) > 0 Then
If $en = False Then
$en = True
$eg = True
_10x(@CRLF & "  ## " & $el & " found")
EndIf
For $es = 0 To UBound($er) - 1
Local $et = $er[$es]
Local $eu = $eq.Item($et)
_11d($ep, $et, $eu)
Next
If $el = "ZHP Tools" And $ek = True And $ej = False Then
_10x("     [!] " & $ei)
$ej = True
EndIf
EndIf
Next
Next
If $ej = False And $ek = True Then
_10x(@CRLF & "  ## " & "ZHP Tools" & " found")
_10x("     [!] " & $ei)
ElseIf $eg = False Then
_10x("  [I] No tools found")
EndIf
EndIf
_11e()
EndFunc
FileInstall("C:\Users\IEUser\Desktop\KpRm\src\assets\bug.gif", @TempDir & "\kprm-logo.gif")
FileInstall("C:\Users\IEUser\Desktop\KpRm\src\config\tools.xml", @TempDir & "\kprm-tools.xml")
_10v()
If Not IsAdmin() Then
MsgBox(16, $7m, $7o)
_10s()
EndIf
Global $ev = "KpRm"
Global $ba = "kprm-" & @YEAR & @MON & @MDAY & @HOUR & @MIN & ".txt"
Local Const $ew = GUICreate($ev, 500, 195, 202, 112)
Local Const $ex = GUICtrlCreateGroup("Actions", 8, 8, 400, 153)
Local Const $ey = GUICtrlCreateCheckbox($7e, 16, 40, 129, 17)
Local Const $ez = GUICtrlCreateCheckbox($7f, 16, 80, 190, 17)
Local Const $f0 = GUICtrlCreateCheckbox($7g, 16, 120, 190, 17)
Local Const $f1 = GUICtrlCreateCheckbox($7h, 220, 40, 137, 17)
Local Const $f2 = GUICtrlCreateCheckbox($7i, 220, 80, 137, 17)
Local Const $f3 = GUICtrlCreateCheckbox($7j, 220, 120, 180, 17)
Global $cd = GUICtrlCreateProgress(8, 170, 480, 17)
GUICtrlCreateGroup("", -99, -99, 1, 1)
GUICtrlSetState($ey, 1)
Local Const $f4 = GUICtrlCreatePic(@TempDir & "\kprm-logo.gif", 415, 16, 76, 76)
Local Const $f5 = GUICtrlCreateButton($7k, 415, 120, 75, 40)
GUISetState(@SW_SHOW)
While 1
Local $f6 = GUIGetMsg()
Switch $f6
Case $0
Exit
Case $f5
_12b()
EndSwitch
WEnd
Func _129()
Local Const $79 = @HomeDrive & "\KPRM"
If Not FileExists($79) Then
DirCreate($79)
EndIf
If Not FileExists($79) Then
MsgBox(16, $7m, $7n)
Exit
EndIf
EndFunc
Func _12a()
_129()
_10x("#################################################################################################################" & @CRLF)
_10x("# Run at " & _3o())
_10x("# KpRm (Kernel-panik) version " & $7c)
_10x("# Website https://kernel-panik.me/tool/kprm/")
_10x("# Run by " & @UserName & " from " & @WorkingDir)
_10x("# Computer Name: " & @ComputerName)
_10x("# OS: " & _115() & " " & @OSArch & " (" & @OSBuild & ") " & @OSServicePack)
_11f()
EndFunc
Func _12b()
_12a()
_11e()
If GUICtrlRead($f1) = $1 Then
_11m()
EndIf
_11e()
If GUICtrlRead($ey) = $1 Then
_128(False)
_128(True)
Else
_11e(32)
EndIf
_11e()
If GUICtrlRead($f3) = $1 Then
_11o()
EndIf
_11e()
If GUICtrlRead($f2) = $1 Then
_11n()
EndIf
_11e()
If GUICtrlRead($ez) = $1 Then
_11g()
EndIf
_11e()
If GUICtrlRead($f0) = $1 Then
_11l()
EndIf
GUICtrlSetData($cd, 100)
MsgBox(64, "OK", $7l)
_10s(True)
EndFunc
