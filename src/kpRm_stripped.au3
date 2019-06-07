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
Global Const $9 = 1
Global Const $a = 2
Global Const $b = 0x00020000
Global Const $c = 0x00040000
Global Const $d = 0x00080000
Global Const $e = 0x01000000
Global Enum $f = 0, $g, $h, $i, $j, $k, $l
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
If Not StringStripWS($1m, $3 + $4) Then
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
Return _2e(BitAND($1z, $a) ? $1i : $1h, $1k, 0, BitAND($1z, $9) ? "ddd" : "dddd")
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
$22 = StringStripWS($22 & " " & $23, $3 + $4)
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
Return _2e(BitAND($1z, $a) ? $1i : $1h, $1k, 0, BitAND($1z, $9) ? "MMM" : "MMMM")
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
Local $4e = StringSplit($47, $49, $6 + $5)
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
Local $4l = StringSplit($47, $4a, $6 + $5)
$4i = UBound($4l, $o)
Local $4e[$4i][0], $4m
For $4g = 0 To $4i - 1
$4m = StringSplit($4l[$4g], $49, $6 + $5)
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
Func _wm(Const ByRef $46, $5r = "|", $5s = -1, $5t = -1, $4a = @CRLF, $5u = -1, $5v = -1)
If $5r = Default Then $5r = "|"
If $4a = Default Then $4a = @CRLF
If $5s = Default Then $5s = -1
If $5t = Default Then $5t = -1
If $5u = Default Then $5u = -1
If $5v = Default Then $5v = -1
If Not IsArray($46) Then Return SetError(1, 0, -1)
Local $4c = UBound($46, $o) - 1
If $5s = -1 Then $5s = 0
If $5t = -1 Then $5t = $4c
If $5s < -1 Or $5t < -1 Then Return SetError(3, 0, -1)
If $5s > $4c Or $5t > $4c Then Return SetError(3, 0, "")
If $5s > $5t Then Return SetError(4, 0, -1)
Local $5w = ""
Switch UBound($46, $n)
Case 1
For $4g = $5s To $5t
$5w &= $46[$4g] & $5r
Next
Return StringTrimRight($5w, StringLen($5r))
Case 2
Local $4h = UBound($46, $p) - 1
If $5u = -1 Then $5u = 0
If $5v = -1 Then $5v = $4h
If $5u < -1 Or $5v < -1 Then Return SetError(5, 0, -1)
If $5u > $4h Or $5v > $4h Then Return SetError(5, 0, -1)
If $5u > $5v Then Return SetError(6, 0, -1)
For $4g = $5s To $5t
For $4n = $5u To $5v
$5w &= $46[$4g][$4n] & $5r
Next
$5w = StringTrimRight($5w, StringLen($5r)) & $4a
Next
Return StringTrimRight($5w, StringLen($4a))
Case Else
Return SetError(2, 0, -1)
EndSwitch
Return 1
EndFunc
Func _x1($5x, $5y = "*", $5z = $s, $60 = False)
Local $61 = "|", $62 = "", $63 = "", $64 = ""
$5x = StringRegExpReplace($5x, "[\\/]+$", "") & "\"
If $5z = Default Then $5z = $s
If $60 Then $64 = $5x
If $5y = Default Then $5y = "*"
If Not FileExists($5x) Then Return SetError(1, 0, 0)
If StringRegExp($5y, "[\\/:><\|]|(?s)^\s*$") Then Return SetError(2, 0, 0)
If Not($5z = 0 Or $5z = 1 Or $5z = 2) Then Return SetError(3, 0, 0)
Local $65 = FileFindFirstFile($5x & $5y)
If @error Then Return SetError(4, 0, 0)
While 1
$63 = FileFindNextFile($65)
If @error Then ExitLoop
If($5z + @extended = 2) Then ContinueLoop
$62 &= $61 & $64 & $63
WEnd
FileClose($65)
If $62 = "" Then Return SetError(4, 0, 0)
Return StringSplit(StringTrimLeft($62, 1), $61)
EndFunc
Func _x2($5x, $66 = "*", $2z = $t, $67 = $x, $68 = $y, $69 = $0z)
If Not FileExists($5x) Then Return SetError(1, 1, "")
If $66 = Default Then $66 = "*"
If $2z = Default Then $2z = $t
If $67 = Default Then $67 = $x
If $68 = Default Then $68 = $y
If $69 = Default Then $69 = $0z
If $67 > 1 Or Not IsInt($67) Then Return SetError(1, 6, "")
Local $6a = False
If StringLeft($5x, 4) == "\\?\" Then
$6a = True
EndIf
Local $6b = ""
If StringRight($5x, 1) = "\" Then
$6b = "\"
Else
$5x = $5x & "\"
EndIf
Local $6c[100] = [1]
$6c[1] = $5x
Local $6d = 0, $6e = ""
If BitAND($2z, $u) Then
$6d += 2
$6e &= "H"
$2z -= $u
EndIf
If BitAND($2z, $v) Then
$6d += 4
$6e &= "S"
$2z -= $v
EndIf
Local $6f = 0
If BitAND($2z, $w) Then
$6f = 0x400
$2z -= $w
EndIf
Local $6g = 0
If $67 < 0 Then
StringReplace($5x, "\", "", 0, $2)
$6g = @extended - $67
EndIf
Local $6h = "", $6i = "", $6j = "*"
Local $6k = StringSplit($66, "|")
Switch $6k[0]
Case 3
$6i = $6k[3]
ContinueCase
Case 2
$6h = $6k[2]
ContinueCase
Case 1
$6j = $6k[1]
EndSwitch
Local $6l = ".+"
If $6j <> "*" Then
If Not _x5($6l, $6j) Then Return SetError(1, 2, "")
EndIf
Local $6m = ".+"
Switch $2z
Case 0
Switch $67
Case 0
$6m = $6l
EndSwitch
Case 2
$6m = $6l
EndSwitch
Local $6n = ":"
If $6h <> "" Then
If Not _x5($6n, $6h) Then Return SetError(1, 3, "")
EndIf
Local $6o = ":"
If $67 Then
If $6i Then
If Not _x5($6o, $6i) Then Return SetError(1, 4, "")
EndIf
If $2z = 2 Then
$6o = $6n
EndIf
Else
$6o = $6n
EndIf
If Not($2z = 0 Or $2z = 1 Or $2z = 2) Then Return SetError(1, 5, "")
If Not($68 = 0 Or $68 = 1 Or $68 = 2) Then Return SetError(1, 7, "")
If Not($69 = 0 Or $69 = 1 Or $69 = 2) Then Return SetError(1, 8, "")
If $6f Then
Local $6p = DllStructCreate("struct;align 4;dword FileAttributes;uint64 CreationTime;uint64 LastAccessTime;uint64 LastWriteTime;" & "dword FileSizeHigh;dword FileSizeLow;dword Reserved0;dword Reserved1;wchar FileName[260];wchar AlternateFileName[14];endstruct")
Local $6q = DllOpen('kernel32.dll'), $6r
EndIf
Local $6s[100] = [0]
Local $6t = $6s, $6u = $6s, $6v = $6s
Local $6w = False, $65 = 0, $6x = "", $6y = "", $6z = ""
Local $70 = 0, $71 = ''
Local $72[100][2] = [[0, 0]]
While $6c[0] > 0
$6x = $6c[$6c[0]]
$6c[0] -= 1
Switch $69
Case 1
$6z = StringReplace($6x, $5x, "")
Case 2
If $6a Then
$6z = StringTrimLeft($6x, 4)
Else
$6z = $6x
EndIf
EndSwitch
If $6f Then
$6r = DllCall($6q, 'handle', 'FindFirstFileW', 'wstr', $6x & "*", 'struct*', $6p)
If @error Or Not $6r[0] Then
ContinueLoop
EndIf
$65 = $6r[0]
Else
$65 = FileFindFirstFile($6x & "*")
If $65 = -1 Then
ContinueLoop
EndIf
EndIf
If $2z = 0 And $68 And $69 Then
_x4($72, $6z, $6t[0] + 1)
EndIf
$71 = ''
While 1
If $6f Then
$6r = DllCall($6q, 'int', 'FindNextFileW', 'handle', $65, 'struct*', $6p)
If @error Or Not $6r[0] Then
ExitLoop
EndIf
$6y = DllStructGetData($6p, "FileName")
If $6y = ".." Then
ContinueLoop
EndIf
$70 = DllStructGetData($6p, "FileAttributes")
If $6d And BitAND($70, $6d) Then
ContinueLoop
EndIf
If BitAND($70, $6f) Then
ContinueLoop
EndIf
$6w = False
If BitAND($70, 16) Then
$6w = True
EndIf
Else
$6w = False
$6y = FileFindNextFile($65, 1)
If @error Then
ExitLoop
EndIf
$71 = @extended
If StringInStr($71, "D") Then
$6w = True
EndIf
If StringRegExp($71, "[" & $6e & "]") Then
ContinueLoop
EndIf
EndIf
If $6w Then
Select
Case $67 < 0
StringReplace($6x, "\", "", 0, $2)
If @extended < $6g Then
ContinueCase
EndIf
Case $67 = 1
If Not StringRegExp($6y, $6o) Then
_x4($6c, $6x & $6y & "\")
EndIf
EndSelect
EndIf
If $68 Then
If $6w Then
If StringRegExp($6y, $6m) And Not StringRegExp($6y, $6o) Then
_x4($6v, $6z & $6y & $6b)
EndIf
Else
If StringRegExp($6y, $6l) And Not StringRegExp($6y, $6n) Then
If $6x = $5x Then
_x4($6u, $6z & $6y)
Else
_x4($6t, $6z & $6y)
EndIf
EndIf
EndIf
Else
If $6w Then
If $2z <> 1 And StringRegExp($6y, $6m) And Not StringRegExp($6y, $6o) Then
_x4($6s, $6z & $6y & $6b)
EndIf
Else
If $2z <> 2 And StringRegExp($6y, $6l) And Not StringRegExp($6y, $6n) Then
_x4($6s, $6z & $6y)
EndIf
EndIf
EndIf
WEnd
If $6f Then
DllCall($6q, 'int', 'FindClose', 'ptr', $65)
Else
FileClose($65)
EndIf
WEnd
If $6f Then
DllClose($6q)
EndIf
If $68 Then
Switch $2z
Case 2
If $6v[0] = 0 Then Return SetError(1, 9, "")
ReDim $6v[$6v[0] + 1]
$6s = $6v
_wj($6s, 1, $6s[0])
Case 1
If $6u[0] = 0 And $6t[0] = 0 Then Return SetError(1, 9, "")
If $69 = 0 Then
_x3($6s, $6u, $6t)
_wj($6s, 1, $6s[0])
Else
_x3($6s, $6u, $6t, 1)
EndIf
Case 0
If $6u[0] = 0 And $6v[0] = 0 Then Return SetError(1, 9, "")
If $69 = 0 Then
_x3($6s, $6u, $6t)
$6s[0] += $6v[0]
ReDim $6v[$6v[0] + 1]
_w0($6s, $6v, 1)
_wj($6s, 1, $6s[0])
Else
Local $6s[$6t[0] + $6u[0] + $6v[0] + 1]
$6s[0] = $6t[0] + $6u[0] + $6v[0]
_wj($6u, 1, $6u[0])
For $4g = 1 To $6u[0]
$6s[$4g] = $6u[$4g]
Next
Local $73 = $6u[0] + 1
_wj($6v, 1, $6v[0])
Local $74 = ""
For $4g = 1 To $6v[0]
$6s[$73] = $6v[$4g]
$73 += 1
If $6b Then
$74 = $6v[$4g]
Else
$74 = $6v[$4g] & "\"
EndIf
Local $75 = 0, $76 = 0
For $4n = 1 To $72[0][0]
If $74 = $72[$4n][0] Then
$76 = $72[$4n][1]
If $4n = $72[0][0] Then
$75 = $6t[0]
Else
$75 = $72[$4n + 1][1] - 1
EndIf
If $68 = 1 Then
_wj($6t, $76, $75)
EndIf
For $59 = $76 To $75
$6s[$73] = $6t[$59]
$73 += 1
Next
ExitLoop
EndIf
Next
Next
EndIf
EndSwitch
Else
If $6s[0] = 0 Then Return SetError(1, 9, "")
ReDim $6s[$6s[0] + 1]
EndIf
Return $6s
EndFunc
Func _x3(ByRef $77, $78, $79, $68 = 0)
ReDim $78[$78[0] + 1]
If $68 = 1 Then _wj($78, 1, $78[0])
$77 = $78
$77[0] += $79[0]
ReDim $79[$79[0] + 1]
If $68 = 1 Then _wj($79, 1, $79[0])
_w0($77, $79, 1)
EndFunc
Func _x4(ByRef $7a, $7b, $7c = -1)
If $7c = -1 Then
$7a[0] += 1
If UBound($7a) <= $7a[0] Then ReDim $7a[UBound($7a) * 2]
$7a[$7a[0]] = $7b
Else
$7a[0][0] += 1
If UBound($7a) <= $7a[0][0] Then ReDim $7a[UBound($7a) * 2][2]
$7a[$7a[0][0]][0] = $7b
$7a[$7a[0][0]][1] = $7c
EndIf
EndFunc
Func _x5(ByRef $66, $7d)
If StringRegExp($7d, "\\|/|:|\<|\>|\|") Then Return 0
$7d = StringReplace(StringStripWS(StringRegExpReplace($7d, "\s*;\s*", ";"), BitOR($3, $4)), ";", "|")
$7d = StringReplace(StringReplace(StringRegExpReplace($7d, "[][$^.{}()+\-]", "\\$0"), "?", "."), "*", ".*?")
$66 = "(?i)^(" & $7d & ")\z"
Return 1
EndFunc
Func _xe($5x, ByRef $7e, ByRef $7f, ByRef $63, ByRef $7g)
Local $46 = StringRegExp($5x, "^\h*((?:\\\\\?\\)*(\\\\[^\?\/\\]+|[A-Za-z]:)?(.*[\/\\]\h*)?((?:[^\.\/\\]|(?(?=\.[^\/\\]*\.)\.))*)?([^\/\\]*))$", $7)
If @error Then
ReDim $46[5]
$46[$11] = $5x
EndIf
$7e = $46[$12]
If StringLeft($46[$13], 1) == "/" Then
$7f = StringRegExpReplace($46[$13], "\h*[\/\\]+\h*", "\/")
Else
$7f = StringRegExpReplace($46[$13], "\h*[\/\\]+\h*", "\\")
EndIf
$46[$13] = $7f
$63 = $46[$14]
$7g = $46[$15]
Return $46
EndFunc
Global $7h = True
Local $7i = "1.0.1"
If $7h = True Then
AutoItSetOption("MustDeclareVars", 1)
EndIf
Local Const $7j = _10r()
If $7j = "fr" Then
Global $7k = "Supprimer les outils"
Global $7l = "Supprimer les points de restaurations"
Global $7m = "Créer un point de restauration"
Global $7n = "Sauvegarder le registre"
Global $7o = "Restaurer UAC"
Global $7p = "Restaurer les paramètres système"
Global $7q = "Exécuter"
Global $7r = "Toutes les opérations sont terminées"
Global $7s = "Echec"
Global $7t = "Impossible de créer une sauvegarde du registre"
Global $7u = "Vous devez exécuter le programme avec les droits administrateurs"
Global $7v = "Mise à jour"
Global $7w = "Une version plus récente de KpRm existe, merci de la télécharger."
ElseIf $7j = "de" Then
Global $7k = "Werkzeuge löschen"
Global $7l = "Wiederherstellungspunkte löschen"
Global $7m = "Erstellen eines Wiederherstellungspunktes"
Global $7n = "Speichern der Registrierung"
Global $7o = "UAC wiederherstellen"
Global $7p = "Systemeinstellungen wiederherstellen"
Global $7q = "Ausführen"
Global $7r = "Alle Vorgänge sind abgeschlossen"
Global $7s = "Ausfall"
Global $7t = "Es ist nicht möglich, ein Registrierungs-Backup zu erstellen"
Global $7u = "Sie müssen das Programm mit Administratorrechten ausführen"
Global $7v = "Update"
Global $7w = "Es gibt eine neuere Version von KpRm, bitte laden Sie sie herunter."
ElseIf $7j = "it" Then
Global $7k = "Cancella strumenti"
Global $7l = "Elimina punti di ripristino"
Global $7m = "Crea un punto di ripristino"
Global $7n = "Salva registro"
Global $7o = "Ripristina UAC"
Global $7p = "Ripristina impostazioni di sistema"
Global $7q = "Eseguire"
Global $7r = "Tutte le operazioni sono completate"
Global $7s = "Fallimento"
Global $7t = "Impossibile creare un backup del registro di sistema"
Global $7u = "È necessario eseguire il programma con i diritti di amministratore"
Global $7v = "Aggiorna"
Global $7w = "Esiste una versione più recente di KpRm, scaricatela, per favore"
ElseIf $7j = "es" Then
Global $7k = "Borrar herramientas"
Global $7l = "Eliminar puntos de restauración"
Global $7m = "Crear un punto de restauración"
Global $7n = "Guardar el registro"
Global $7o = "Restaurar UAC"
Global $7p = "Restaurar ajustes del sistema"
Global $7q = "Ejecutar"
Global $7r = "Todas las operaciones están terminadas"
Global $7s = "fallo"
Global $7t = "Incapaz de crear una copia de seguridad del registro"
Global $7u = "Debe ejecutar el programa con derechos de administrador"
Global $7v = "Actualización"
Global $7w = "Existe una nueva versión de KpRm, por favor descárguela."
ElseIf $7j = "pt" Then
Global $7k = "Apagar ferramentas"
Global $7l = "Deletar pontos de restauração"
Global $7m = "Criar um ponto de restauração"
Global $7n = "Salvar registro"
Global $7o = "Restaurar UAC"
Global $7p = "Restaurar configurações do sistema"
Global $7q = "Executar"
Global $7r = "Todas as operações estão concluídas"
Global $7s = "Falha"
Global $7t = "Incapaz de criar um backup do registro"
Global $7u = "Você deve executar o programa com direitos de administrador"
Global $7v = "Atualizar"
Global $7w = "Uma nova versão do KpRm existe, por favor faça o download."
Else
Global $7k = "Delete Tools"
Global $7l = "Delete Restore Points"
Global $7m = "Create Restore Point"
Global $7n = "Registry Backup"
Global $7o = "UAC Restore"
Global $7p = "Restore System Settings"
Global $7q = "Run"
Global $7r = "All operations are completed"
Global $7s = "Fail"
Global $7t = "Unable to create a registry backup"
Global $7u = "You must run the program with administrator rights"
Global $7v = "Update"
Global $7w = "A more recent version of KpRm exists, please download it!"
EndIf
Global Const $7x = 1
Global Const $7y = 5
Global Const $7z = 0
Global Const $80 = 1
Func _xr($81 = $7y)
If Not IsAdmin() Then Return SetError(-3, 0, -1)
If StringRegExp(@OSVersion, "_(XP|200(0|3))") Then Return SetError(-4, 0, -1)
Local $82 = ""
If @OSArch = "X64" Then $82 = "64"
If $81 < 0 Or $81 > 5 Then Return SetError(-5, 0, -1)
Local $2z = RegWrite("HKEY_LOCAL_MACHINE" & $82 & "\Software\Microsoft\Windows\CurrentVersion\Policies\System", "ConsentPromptBehaviorAdmin", "REG_DWORD", $81)
If $2z = 0 Then $2z = -1
Return SetError(@error, 0, $2z)
EndFunc
Func _xs($81 = $7x)
If Not IsAdmin() Then Return SetError(-3, 0, -1)
If StringRegExp(@OSVersion, "_(XP|200(0|3))") Then Return SetError(-4, 0, -1)
If $81 < 0 Or $81 = 2 Or $81 > 3 Then Return SetError(-5, 0, -1)
Local $82 = ""
If @OSArch = "X64" Then $82 = "64"
Local $2z = RegWrite("HKEY_LOCAL_MACHINE" & $82 & "\Software\Microsoft\Windows\CurrentVersion\Policies\System", "ConsentPromptBehaviorUser", "REG_DWORD", $81)
If $2z = 0 Then $2z = -1
Return SetError(@error, 0, $2z)
EndFunc
Func _xt($81 = $7z)
If Not IsAdmin() Then Return SetError(-3, 0, -1)
If StringRegExp(@OSVersion, "_(XP|200(0|3))") Then Return SetError(-4, 0, -1)
If $81 < 0 Or $81 > 1 Then Return SetError(-5, 0, -1)
Local $82 = ""
If @OSArch = "X64" Then $82 = "64"
Local $2z = RegWrite("HKEY_LOCAL_MACHINE" & $82 & "\Software\Microsoft\Windows\CurrentVersion\Policies\System", "EnableInstallerDetection", "REG_DWORD", $81)
If $2z = 0 Then $2z = -1
Return SetError(@error, 0, $2z)
EndFunc
Func _xu($81 = $80)
If Not IsAdmin() Then Return SetError(-3, 0, -1)
If StringRegExp(@OSVersion, "_(XP|200(0|3))") Then Return SetError(-4, 0, -1)
If $81 < 0 Or $81 > 1 Then Return SetError(-5, 0, -1)
Local $82 = ""
If @OSArch = "X64" Then $82 = "64"
Local $2z = RegWrite("HKEY_LOCAL_MACHINE" & $82 & "\Software\Microsoft\Windows\CurrentVersion\Policies\System", "EnableLUA", "REG_DWORD", $81)
If $2z = 0 Then $2z = -1
Return SetError(@error, 0, $2z)
EndFunc
Func _xv($81 = $80)
If Not IsAdmin() Then Return SetError(-3, 0, -1)
If StringRegExp(@OSVersion, "_(XP|200(0|3))") Then Return SetError(-4, 0, -1)
If $81 < 0 Or $81 > 1 Then Return SetError(-5, 0, -1)
Local $82 = ""
If @OSArch = "X64" Then $82 = "64"
Local $2z = RegWrite("HKEY_LOCAL_MACHINE" & $82 & "\Software\Microsoft\Windows\CurrentVersion\Policies\System", "EnableSecureUIAPaths", "REG_DWORD", $81)
If $2z = 0 Then $2z = -1
Return SetError(@error, 0, $2z)
EndFunc
Func _xw($81 = $7z)
If Not IsAdmin() Then Return SetError(-3, 0, -1)
If StringRegExp(@OSVersion, "_(XP|200(0|3))") Then Return SetError(-4, 0, -1)
If $81 < 0 Or $81 > 1 Then Return SetError(-5, 0, -1)
Local $82 = ""
If @OSArch = "X64" Then $82 = "64"
Local $2z = RegWrite("HKEY_LOCAL_MACHINE" & $82 & "\Software\Microsoft\Windows\CurrentVersion\Policies\System", "EnableUIADesktopToggle", "REG_DWORD", $81)
If $2z = 0 Then $2z = -1
Return SetError(@error, 0, $2z)
EndFunc
Func _xx($81 = $80)
If Not IsAdmin() Then Return SetError(-3, 0, -1)
If StringRegExp(@OSVersion, "_(XP|200(0|3))") Then Return SetError(-4, 0, -1)
If $81 < 0 Or $81 > 1 Then Return SetError(-5, 0, -1)
Local $82 = ""
If @OSArch = "X64" Then $82 = "64"
Local $2z = RegWrite("HKEY_LOCAL_MACHINE" & $82 & "\Software\Microsoft\Windows\CurrentVersion\Policies\System", "EnableVirtualization", "REG_DWORD", $81)
If $2z = 0 Then $2z = -1
Return SetError(@error, 0, $2z)
EndFunc
Func _xy($81 = $7z)
If Not IsAdmin() Then Return SetError(-3, 0, -1)
If StringRegExp(@OSVersion, "_(XP|200(0|3))") Then Return SetError(-4, 0, -1)
If $81 < 0 Or $81 > 1 Then Return SetError(-5, 0, -1)
Local $82 = ""
If @OSArch = "X64" Then $82 = "64"
Local $2z = RegWrite("HKEY_LOCAL_MACHINE" & $82 & "\Software\Microsoft\Windows\CurrentVersion\Policies\System", "FilterAdministratorToken", "REG_DWORD", $81)
If $2z = 0 Then $2z = -1
Return SetError(@error, 0, $2z)
EndFunc
Func _xz($81 = $80)
If Not IsAdmin() Then Return SetError(-3, 0, -1)
If StringRegExp(@OSVersion, "_(XP|200(0|3))") Then Return SetError(-4, 0, -1)
If $81 < 0 Or $81 > 1 Then Return SetError(-5, 0, -1)
Local $82 = ""
If @OSArch = "X64" Then $82 = "64"
Local $2z = RegWrite("HKEY_LOCAL_MACHINE" & $82 & "\Software\Microsoft\Windows\CurrentVersion\Policies\System", "PromptOnSecureDesktop", "REG_DWORD", $81)
If $2z = 0 Then $2z = -1
Return SetError(@error, 0, $2z)
EndFunc
Func _y0($81 = $7z)
If Not IsAdmin() Then Return SetError(-3, 0, -1)
If StringRegExp(@OSVersion, "_(XP|200(0|3))") Then Return SetError(-4, 0, -1)
If $81 < 0 Or $81 > 1 Then Return SetError(-5, 0, -1)
Local $82 = ""
If @OSArch = "X64" Then $82 = "64"
Local $2z = RegWrite("HKEY_LOCAL_MACHINE" & $82 & "\Software\Microsoft\Windows\CurrentVersion\Policies\System", "ValidateAdminCodeSignatures", "REG_DWORD", $81)
If $2z = 0 Then $2z = -1
Return SetError(@error, 0, $2z)
EndFunc
Global $83 = Null, $84 = Null
Global $85 = EnvGet('SystemDrive') & '\'
Func _y2()
Local $86[1][3], $87 = 0
$86[0][0] = $87
If Not IsObj($84) Then $84 = ObjGet("winmgmts:root/default")
If Not IsObj($84) Then Return $86
Local $88 = $84.InstancesOf("SystemRestore")
If Not IsObj($88) Then Return $86
For $89 In $88
$87 += 1
ReDim $86[$87 + 1][3]
$86[$87][0] = $89.SequenceNumber
$86[$87][1] = $89.Description
$86[$87][2] = _y3($89.CreationTime)
Next
$86[0][0] = $87
Return $86
EndFunc
Func _y3($8a)
Return(StringMid($8a, 5, 2) & "/" & StringMid($8a, 7, 2) & "/" & StringLeft($8a, 4) & " " & StringMid($8a, 9, 2) & ":" & StringMid($8a, 11, 2) & ":" & StringMid($8a, 13, 2))
EndFunc
Func _y4($8b)
Local $19 = DllCall('SrClient.dll', 'DWORD', 'SRRemoveRestorePoint', 'DWORD', $8b)
If @error Then Return SetError(1, 0, 0)
If $19[0] = 0 Then Return 1
Return SetError(1, 0, 0)
EndFunc
Func _y6($8c = $85)
If Not IsObj($83) Then $83 = ObjGet("winmgmts:{impersonationLevel=impersonate}!root/default:SystemRestore")
If Not IsObj($83) Then Return 0
If $83.Enable($8c) = 0 Then Return 1
Return 0
EndFunc
Global Enum $8d = 0, $8e, $8f, $8g, $8h, $8i, $8j, $8k, $8l, $8m, $8n, $8o, $8p
Global Const $8q = 2
Global $8r = @SystemDir&'\Advapi32.dll'
Global $8s = @SystemDir&'\Kernel32.dll'
Global $8t[4][2], $8u[4][2]
Global $8v = 0
Func _y9()
$8r = DllOpen(@SystemDir&'\Advapi32.dll')
$8s = DllOpen(@SystemDir&'\Kernel32.dll')
$8t[0][0] = "SeRestorePrivilege"
$8t[0][1] = 2
$8t[1][0] = "SeTakeOwnershipPrivilege"
$8t[1][1] = 2
$8t[2][0] = "SeDebugPrivilege"
$8t[2][1] = 2
$8t[3][0] = "SeSecurityPrivilege"
$8t[3][1] = 2
$8u = _zh($8t)
$8v = 1
EndFunc
Func _yf($8w, $8x = $8e, $8y = 'Administrators', $8z = 1)
Local $90[1][3]
$90[0][0] = 'Everyone'
$90[0][1] = 1
$90[0][2] = $r
Return _yi($8w, $90, $8x, $8y, 1, $8z)
EndFunc
Func _yi($8w, $91, $8x = $8e, $8y = '', $92 = 0, $8z = 0, $93 = 3)
If $8v = 0 Then _y9()
If Not IsArray($91) Or UBound($91,2) < 3 Then Return SetError(1,0,0)
Local $94 = _yn($91,$93)
Local $95 = @extended
Local $96 = 4, $97 = 0
If $8y <> '' Then
If Not IsDllStruct($8y) Then $8y = _za($8y)
$97 = DllStructGetPtr($8y)
If $97 And _zg($97) Then
$96 = 5
Else
$97 = 0
EndIf
EndIf
If Not IsPtr($8w) And $8x = $8e Then
Return _yv($8w, $94, $97, $92, $8z, $95, $96)
ElseIf Not IsPtr($8w) And $8x = $8h Then
Return _yw($8w, $94, $97, $92, $8z, $95, $96)
Else
If $92 Then _yx($8w,$8x)
Return _yo($8w, $8x, $96, $97, 0, $94,0)
EndIf
EndFunc
Func _yn(ByRef $91, ByRef $93)
Local $98 = UBound($91,2)
If Not IsArray($91) Or $98 < 3 Then Return SetError(1,0,0)
Local $99 = UBound($91), $9a[$99], $9b = 0, $9c = 1
Local $9d, $95 = 0, $9e
Local $9f, $9g = 'DWORD;DWORD;DWORD;ptr;DWORD;DWORD;DWORD;ptr'
For $4g = 1 To $99 - 1
$9g &= ';DWORD;DWORD;DWORD;ptr;DWORD;DWORD;DWORD;ptr'
Next
$9f = DllStructCreate($9g)
For $4g = 0 To $99 -1
If Not IsDllStruct($91[$4g][0]) Then $91[$4g][0] = _za($91[$4g][0])
$9a[$4g] = DllStructGetPtr($91[$4g][0])
If Not _zg($9a[$4g]) Then ContinueLoop
DllStructSetData($9f,$9b+1,$91[$4g][2])
If $91[$4g][1] = 0 Then
$95 = 1
$9d = $i
Else
$9d = $h
EndIf
If $98 > 3 Then $93 = $91[$4g][3]
DllStructSetData($9f,$9b+2,$9d)
DllStructSetData($9f,$9b+3,$93)
DllStructSetData($9f,$9b+6,0)
$9e = DllCall($8r,'BOOL','LookupAccountSid','ptr',0,'ptr',$9a[$4g],'ptr*',0,'dword*',32,'ptr*',0,'dword*',32,'dword*',0)
If Not @error Then $9c = $9e[7]
DllStructSetData($9f,$9b+7,$9c)
DllStructSetData($9f,$9b+8,$9a[$4g])
$9b += 8
Next
Local $9h = DllStructGetPtr($9f)
$9e = DllCall($8r,'DWORD','SetEntriesInAcl','ULONG',$99,'ptr',$9h ,'ptr',0,'ptr*',0)
If @error Or $9e[0] Then Return SetError(1,0,0)
Return SetExtended($95, $9e[4])
EndFunc
Func _yo($8w, $8x, $96, $97 = 0, $9i = 0, $94 = 0, $9j = 0)
Local $9e
If $8v = 0 Then _y9()
If $94 And Not _yp($94) Then Return 0
If $9j And Not _yp($9j) Then Return 0
If IsPtr($8w) Then
$9e = DllCall($8r,'dword','SetSecurityInfo','handle',$8w,'dword',$8x, 'dword',$96,'ptr',$97,'ptr',$9i,'ptr',$94,'ptr',$9j)
Else
If $8x = $8h Then $8w = _zb($8w)
$9e = DllCall($8r,'dword','SetNamedSecurityInfo','str',$8w,'dword',$8x, 'dword',$96,'ptr',$97,'ptr',$9i,'ptr',$94,'ptr',$9j)
EndIf
If @error Then Return SetError(1,0,0)
If $9e[0] And $97 Then
If _z0($8w, $8x,_zf($97)) Then Return _yo($8w, $8x, $96 - 1, 0, $9i, $94, $9j)
EndIf
Return SetError($9e[0] , 0, Number($9e[0] = 0))
EndFunc
Func _yp($9k)
If $9k = 0 Then Return SetError(1,0,0)
Local $9e = DllCall($8r,'bool','IsValidAcl','ptr',$9k)
If @error Or Not $9e[0] Then Return 0
Return 1
EndFunc
Func _ys($9l, $9m = -1)
If $8v = 0 Then _y9()
If $9m = -1 Then $9m = BitOR($b, $c, $d, $e)
$9l = ProcessExists($9l)
If $9l = 0 Then Return SetError(1,0,0)
Local $9e = DllCall($8s,'handle','OpenProcess','dword',$9m,'bool',False,'dword',$9l)
If @error Or $9e[0] = 0 Then Return SetError(2,0,0)
Return $9e[0]
EndFunc
Func _yt($9l)
Local $9n = _ys($9l,BitOR(1,$b, $c, $d, $e))
If $9n = 0 Then Return SetError(1,0,0)
Local $9o = 0
_yf($9n,$8j)
For $4g = 1 To 10
DllCall($8s,'bool','TerminateProcess','handle',$9n,'uint',0)
If @error Then $9o = 0
Sleep(30)
If Not ProcessExists($9l) Then
$9o = 1
ExitLoop
EndIf
Next
_yu($9n)
Return $9o
EndFunc
Func _yu($9p)
Local $9e = DllCall($8s,'bool','CloseHandle','handle',$9p)
If @error Then Return SetError(@error,0,0)
Return $9e[0]
EndFunc
Func _yv($8w, ByRef $94, ByRef $97, ByRef $92, ByRef $8z, ByRef $95, ByRef $96)
Local $9o, $9q
If Not $95 Then
If $92 Then _yx($8w,$8e)
$9o = _yo($8w, $8e, $96, $97, 0, $94,0)
EndIf
If $8z Then
Local $9r = FileFindFirstFile($8w&'\*')
While 1
$9q = FileFindNextFile($9r)
If $8z = 1 Or $8z = 2 And @extended = 1 Then
_yv($8w&'\'&$9q, $94, $97, $92, $8z, $95,$96)
ElseIf @error Then
ExitLoop
ElseIf $8z = 1 Or $8z = 3 Then
If $92 Then _yx($8w&'\'&$9q,$8e)
_yo($8w&'\'&$9q, $8e, $96, $97, 0, $94,0)
EndIf
WEnd
FileClose($9r)
EndIf
If $95 Then
If $92 Then _yx($8w,$8e)
$9o = _yo($8w, $8e, $96, $97, 0, $94,0)
EndIf
Return $9o
EndFunc
Func _yw($8w, ByRef $94, ByRef $97, ByRef $92, ByRef $8z, ByRef $95, ByRef $96)
If $8v = 0 Then _y9()
Local $9o, $4g = 0, $9q
If Not $95 Then
If $92 Then _yx($8w,$8h)
$9o = _yo($8w, $8h, $96, $97, 0, $94,0)
EndIf
If $8z Then
While 1
$4g += 1
$9q = RegEnumKey($8w,$4g)
If @error Then ExitLoop
_yw($8w&'\'&$9q, $94, $97, $92, $8z, $95, $96)
WEnd
EndIf
If $95 Then
If $92 Then _yx($8w,$8h)
$9o = _yo($8w, $8h, $96, $97, 0, $94,0)
EndIf
Return $9o
EndFunc
Func _yx($8w, $8x = $8e)
If $8v = 0 Then _y9()
Local $9s = DllStructCreate('byte[32]'), $19
Local $94 = DllStructGetPtr($9s,1)
DllCall($8r,'bool','InitializeAcl','Ptr',$94,'dword',DllStructGetSize($9s),'dword',$8q)
If IsPtr($8w) Then
$19 = DllCall($8r,"dword","SetSecurityInfo",'handle',$8w,'dword',$8x,'dword',4,'ptr',0,'ptr',0,'ptr',$94,'ptr',0)
Else
If $8x = $8h Then $8w = _zb($8w)
DllCall($8r,'DWORD','SetNamedSecurityInfo','str',$8w,'dword',$8x,'DWORD',4,'ptr',0,'ptr',0,'ptr',0,'ptr',0)
$19 = DllCall($8r,'DWORD','SetNamedSecurityInfo','str',$8w,'dword',$8x,'DWORD',4,'ptr',0,'ptr',0,'ptr',$94,'ptr',0)
EndIf
If @error Then Return SetError(@error,0,0)
Return SetError($19[0],0,Number($19[0] = 0))
EndFunc
Func _z0($8w, $8x = $8e, $9t = 'Administrators')
If $8v = 0 Then _y9()
Local $9u = _za($9t), $19
Local $9a = DllStructGetPtr($9u)
If IsPtr($8w) Then
$19 = DllCall($8r,"dword","SetSecurityInfo",'handle',$8w,'dword',$8x,'dword',1,'ptr',$9a,'ptr',0,'ptr',0,'ptr',0)
Else
If $8x = $8h Then $8w = _zb($8w)
$19 = DllCall($8r,'DWORD','SetNamedSecurityInfo','str',$8w,'dword',$8x,'DWORD',1,'ptr',$9a,'ptr',0,'ptr',0,'ptr',0)
EndIf
If @error Then Return SetError(@error,0,False)
Return SetError($19[0],0,Number($19[0] = 0))
EndFunc
Func _za($9t)
If $9t = 'TrustedInstaller' Then $9t = 'NT SERVICE\TrustedInstaller'
If $9t = 'Everyone' Then
Return _zd('S-1-1-0')
ElseIf $9t = 'Authenticated Users' Then
Return _zd('S-1-5-11')
ElseIf $9t = 'System' Then
Return _zd('S-1-5-18')
ElseIf $9t = 'Administrators' Then
Return _zd('S-1-5-32-544')
ElseIf $9t = 'Users' Then
Return _zd('S-1-5-32-545')
ElseIf $9t = 'Guests' Then
Return _zd('S-1-5-32-546')
ElseIf $9t = 'Power Users' Then
Return _zd('S-1-5-32-547')
ElseIf $9t = 'Local Authority' Then
Return _zd('S-1-2')
ElseIf $9t = 'Creator Owner' Then
Return _zd('S-1-3-0')
ElseIf $9t = 'NT Authority' Then
Return _zd('S-1-5-1')
ElseIf $9t = 'Restricted' Then
Return _zd('S-1-5-12')
ElseIf StringRegExp($9t,'\A(S-1-\d+(-\d+){0,5})\z') Then
Return _zd($9t)
Else
Local $9u = _zc($9t)
Return _zd($9u)
EndIf
EndFunc
Func _zb($9v)
If StringInStr($9v,'\\') = 1 Then
$9v = StringRegExpReplace($9v,'(?i)\\(HKEY_CLASSES_ROOT|HKCR)','\CLASSES_ROOT')
$9v = StringRegExpReplace($9v,'(?i)\\(HKEY_CURRENT_USER|HKCU)','\CURRENT_USER')
$9v = StringRegExpReplace($9v,'(?i)\\(HKEY_LOCAL_MACHINE|HKLM)','\MACHINE')
$9v = StringRegExpReplace($9v,'(?i)\\(HKEY_USERS|HKU)','\USERS')
Else
$9v = StringRegExpReplace($9v,'(?i)\A(HKEY_CLASSES_ROOT|HKCR)','CLASSES_ROOT')
$9v = StringRegExpReplace($9v,'(?i)\A(HKEY_CURRENT_USER|HKCU)','CURRENT_USER')
$9v = StringRegExpReplace($9v,'(?i)\A(HKEY_LOCAL_MACHINE|HKLM)','MACHINE')
$9v = StringRegExpReplace($9v,'(?i)\A(HKEY_USERS|HKU)','USERS')
EndIf
Return $9v
EndFunc
Func _zc($9w, $9x = "")
Local $9y = DllStructCreate("byte SID[256]")
Local $9a = DllStructGetPtr($9y, "SID")
Local $33 = DllCall($8r, "bool", "LookupAccountNameW", "wstr", $9x, "wstr", $9w, "ptr", $9a, "dword*", 256, "wstr", "", "dword*", 256, "int*", 0)
If @error Then Return SetError(@error, @extended, 0)
If Not $33[0] Then Return 0
Return _zf($9a)
EndFunc
Func _zd($9z)
Local $33 = DllCall($8r, "bool", "ConvertStringSidToSidW", "wstr", $9z, "ptr*", 0)
If @error Then Return SetError(@error, @extended, 0)
If Not $33[0] Then Return 0
Local $a0 = _ze($33[2])
Local $3u = DllStructCreate("byte Data[" & $a0 & "]", $33[2])
Local $a1 = DllStructCreate("byte Data[" & $a0 & "]")
DllStructSetData($a1, "Data", DllStructGetData($3u, "Data"))
DllCall($8s, "ptr", "LocalFree", "ptr", $33[2])
Return $a1
EndFunc
Func _ze($9a)
If Not _zg($9a) Then Return SetError(-1, 0, "")
Local $33 = DllCall($8r, "dword", "GetLengthSid", "ptr", $9a)
If @error Then Return SetError(@error, @extended, 0)
Return $33[0]
EndFunc
Func _zf($9a)
If Not _zg($9a) Then Return SetError(-1, 0, "")
Local $33 = DllCall($8r, "int", "ConvertSidToStringSidW", "ptr", $9a, "ptr*", 0)
If @error Then Return SetError(@error, @extended, "")
If Not $33[0] Then Return ""
Local $3u = DllStructCreate("wchar Text[256]", $33[2])
Local $9z = DllStructGetData($3u, "Text")
DllCall($8s, "ptr", "LocalFree", "ptr", $33[2])
Return $9z
EndFunc
Func _zg($9a)
Local $33 = DllCall($8r, "bool", "IsValidSid", "ptr", $9a)
If @error Then Return SetError(@error, @extended, False)
Return $33[0]
EndFunc
Func _zh($a2)
Local $a3 = UBound($a2, 0), $a4[1][2]
If Not($a3 <= 2 And UBound($a2, $a3) = 2 ) Then Return SetError(1300, 0, $a4)
If $a3 = 1 Then
Local $a5[1][2]
$a5[0][0] = $a2[0]
$a5[0][1] = $a2[1]
$a2 = $a5
$a5 = 0
EndIf
Local $59, $a6 = "dword", $a7 = UBound($a2, 1)
Do
$59 += 1
$a6 &= ";dword;long;dword"
Until $59 = $a7
Local $a8, $a9, $aa, $ab, $ac, $ad, $ae
$a8 = DLLStructCreate($a6)
$a9 = DllStructCreate($a6)
$aa = DllStructGetPtr($a9)
$ab = DllStructCreate("dword;long")
DLLStructSetData($a8, 1, $a7)
For $4g = 0 To $a7 - 1
DllCall($8r, "int", "LookupPrivilegeValue", "str", "", "str", $a2[$4g][0], "ptr", DllStructGetPtr($ab) )
DLLStructSetData( $a8, 3 * $4g + 2, DllStructGetData($ab, 1) )
DLLStructSetData( $a8, 3 * $4g + 3, DllStructGetData($ab, 2) )
DLLStructSetData( $a8, 3 * $4g + 4, $a2[$4g][1] )
Next
$ac = DllCall($8s, "hwnd", "GetCurrentProcess")
$ad = DllCall($8r, "int", "OpenProcessToken", "hwnd", $ac[0], "dword", BitOR(0x00000020, 0x00000008), "hwnd*", 0 )
DllCall( $8r, "int", "AdjustTokenPrivileges", "hwnd", $ad[3], "int", False, "ptr", DllStructGetPtr($a8), "dword", DllStructGetSize($a8), "ptr", $aa, "dword*", 0 )
$ae = DllCall($8s, "dword", "GetLastError")
DllCall($8s, "int", "CloseHandle", "hwnd", $ad[3])
Local $af = DllStructGetData($a9, 1)
If $af > 0 Then
Local $ag, $ah, $ai, $a4[$af][2]
For $4g = 0 To $af - 1
$ag = $aa + 12 * $4g + 4
$ah = DllCall($8r, "int", "LookupPrivilegeName", "str", "", "ptr", $ag, "ptr", 0, "dword*", 0 )
$ai = DllStructCreate("char[" & $ah[4] & "]")
DllCall($8r, "int", "LookupPrivilegeName", "str", "", "ptr", $ag, "ptr", DllStructGetPtr($ai), "dword*", DllStructGetSize($ai) )
$a4[$4g][0] = DllStructGetData($ai, 1)
$a4[$4g][1] = DllStructGetData($a9, 3 * $4g + 4)
Next
EndIf
Return SetError($ae[0], 0, $a4)
EndFunc
Global $aj
Global $ak
Global $al
Global $am
Global $an
Global $ao = -1
Func _zi($ap, $aq = "", $ar = -1, $as = True)
If $ar <> -1 Then
If $ar > -1 And $ar < 7 Then
$ak = ObjCreate("Msxml2.DOMDocument." & $ar & ".0")
If IsObj($ak) Then
$ao = $ar
EndIf
Else
MsgBox(266288, "Error:", "Failed to create object with MSXML version " & $ar)
SetError(1)
Return 0
EndIf
Else
For $2b = 8 To 0 Step - 1
If FileExists(@SystemDir & "\msxml" & $2b & ".dll") Then
$ak = ObjCreate("Msxml2.DOMDocument." & $2b & ".0")
If IsObj($ak) Then
$ao = $2b
ExitLoop
EndIf
EndIf
Next
EndIf
If Not IsObj($ak) Then
_10d("Error: MSXML not found. This object is required to use this program.")
SetError(2)
Return -1
EndIf
$al = ObjEvent("AutoIt.Error")
If $al = "" Then
$al = ObjEvent("AutoIt.Error", "_10e")
EndIf
$aj = $ap
$ak.async = False
$ak.preserveWhiteSpace = True
$ak.validateOnParse = $as
if $ao > 4 Then $ak.setProperty("ProhibitDTD",false)
$ak.Load($aj)
$ak.setProperty("SelectionLanguage", "XPath")
$ak.setProperty("SelectionNamespaces", $aq)
if $ak.parseError.errorCode >0 Then consoleWrite($ak.parseError.reason&@LF)
If $ak.parseError.errorCode <> 0 Then
_10d("Error opening specified file: " & $ap & @CRLF & $ak.parseError.reason)
ConsoleWrite("Error opening specified file: " & $ap & @CRLF & $ak.parseError.reason)
SetError(1,$ak.parseError.errorCode,-1)
$ak = 0
Return -1
EndIf
Return 1
EndFunc
Func _zl($at)
If not IsObj($ak) then
_10d("No object passed to function _XMLSelectNodes")
Return SetError(2,0,-1)
EndIf
Local $au, $av, $aw[1], $ax
$av = $ak.selectNodes($at)
If Not IsObj($av) Then
_10d("\nNo matching nodes found")
Return SetError(1,0,-1)
EndIf
If $av.length < 1 Then
_10d("\nNo matching nodes found")
Return SetError(1,0,-1)
EndIf
For $au In $av
_10q($aw, $au.nodeName)
_10g($au.nodeName)
_10g($au.namespaceURI)
Next
$aw[0] = $av.length
Return $aw
_10d("Error Selecting Node(s): " & $at & $ax)
Return SetError(1,0,-1)
EndFunc
Func _zr($at, $ay, $az = "")
If not IsObj($ak) then
_10d("No object passed to function _XMLGetAttrib")
ConsoleWrite("No object passed to function _XMLGetAttrib")
Return SetError(2,0,-1)
EndIf
Local $av, $aw, $4g, $ax, $b0
$av = $ak.documentElement.selectNodes($at & $az)
_10g("Get Attrib length= " & $av.length)
If $av.length > 0 Then
For $4g = 0 To $av.length - 1
$b0 = $av.item($4g).getAttribute($ay)
$aw = $b0
_10g("RET>>" & $b0)
Next
Return $aw
EndIf
$ax = "\nNo qualified items found"
_10d("Attribute " & $ay & " not found for: " & $at & $ax)
ConsoleWrite("Attribute " & $ay & " not found for: " & $at & $ax)
Return SetError(1,0,-1)
EndFunc
Func _zt($at, ByRef $b1, ByRef $b2, $b3 = "")
If not IsObj($ak) then
_10d("No object passed to function _XMLGetAllAttrib")
Return SetError(1,9,-1)
EndIf
Local $av, $b4, $au, $aw[2][1], $4g
$b4 = $ak.selectNodes($at & $b3)
If $b4.length > 0 Then
For $au In $b4
$av = $au.attributes
If($av.length) Then
_10g("Get all attrib " & $av.length)
ReDim $aw[2][$av.length + 2]
ReDim $b1[$av.length]
ReDim $b2[$av.length]
For $4g = 0 To $av.length - 1
$aw[0][$4g + 1] = $av.item($4g).nodeName
$aw[1][$4g + 1] = $av.item($4g).Value
$b1[$4g] = $av.item($4g).nodeName
$b2[$4g] = $av.item($4g).Value
Next
Else
_10d("No Attributes found for node")
Return SetError(1,0, -1)
EndIf
Next
$aw[0][0] = $av.length
Return $aw
EndIf
_10d("Error retrieving attributes for: " & $at & @CRLF)
return SetError(1,0 ,-1)
EndFunc
Func _10d($b5 = "")
If $b5 = "" Then
$b5 = $am
$am = ""
Return $b5
Else
$am = StringFormat($b5)
EndIf
_10g($am)
EndFunc
Func _10e()
_10f()
Return
EndFunc
Func _10f($b6 = "")
Local $b7, $b8
If $b6 = True Or $b6 = False Then
$b7 = $b6
$b6 = ""
EndIf
$b8 = Hex($al.number, 8)
If @error Then Return
Local $b9 = "COM Error with DOM!" & @CRLF & @CRLF & "err.description is: " & @TAB & $al.description & @CRLF & "err.windescription:" & @TAB & $al.windescription & @CRLF & "err.number is: " & @TAB & $b8 & @CRLF & "err.lastdllerror is: " & @TAB & $al.lastdllerror & @CRLF & "err.scriptline is: " & @TAB & $al.scriptline & @CRLF & "err.source is: " & @TAB & $al.source & @CRLF & "err.helpfile is: " & @TAB & $al.helpfile & @CRLF & "err.helpcontext is: " & @TAB & $al.helpcontext
If $b7 <> True Then
MsgBox(0, @AutoItExe, $b9)
Else
_10d($b9)
EndIf
SetError(1)
EndFunc
Func _10g($ba, $bb = @LF)
If $an Then
ConsoleWrite(StringFormat($ba)&$bb)
EndIf
EndFunc
Func _10q(ByRef $bc, $bd)
If IsArray($bc) Then
ReDim $bc[UBound($bc) + 1]
$bc[UBound($bc) - 1] = $bd
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
Func _10s($be = False, $bf = True)
Dim $7h
Dim $bg
FileDelete(@TempDir & "\kprm-logo.gif")
FileDelete(@TempDir & "\kprm-tools.xml")
If $be = True Then
If $bf = True Then
Run("notepad.exe " & @HomeDrive & "\KPRM" & "\" & $bg)
EndIf
If $7h = False Then
Run(@ComSpec & ' /c timeout 3 && del /F /Q "' & @ScriptFullPath & '"', @TempDir, @SW_HIDE)
FileDelete(@ScriptFullPath)
EndIf
EndIf
Exit
EndFunc
Func _10t()
Local $bh = DllCall('connect.dll', 'long', 'IsInternetConnected')
If @error Then
Return SetError(1, 0, False)
EndIf
Return $bh[0] = 0
EndFunc
Func _10u($bi, $bj = "")
Local $bk = ObjCreate("WinHttp.WinHttpRequest.5.1")
$bk.Open("GET", $bi & "?" & $bj, False)
$bk.SetTimeouts(50, 50, 50, 50)
If(@error) Then Return SetError(1, 0, 0)
$bk.Send()
If(@error) Then Return SetError(2, 0, 0)
If($bk.Status <> 200) Then Return SetError(3, 0, 0)
Return SetError(0, 0, $bk.ResponseText)
EndFunc
Func _10v()
Dim $7i
Dim $7h
If $7h = True Then Return
Local Const $bl = _10t()
If $bl = False Then
Return Null
EndIf
Local Const $bm = _10u("https://kernel-panik.me/_api/v1/kprm/version")
If $bm <> Null And $bm <> "" And $bm <> $7i Then
MsgBox(64, $7v, $7w)
ShellExecute("https://kernel-panik.me/tool/kprm/")
_10s(True, False)
EndIf
EndFunc
Func _10w()
Local $82 = ""
If @OSArch = "X64" Then $82 = "64"
Return $82
EndFunc
Func _10x($ba)
Dim $bg
FileWrite(@HomeDrive & "\KPRM" & "\" & $bg, $ba & @CRLF)
EndFunc
Func _10y()
Local $bn = 100, $bo = 100, $bp = 0, $bq = @WindowsDir & "\Explorer.exe"
_hf($3c, 0, 0, 0)
Local $br = _d0("Shell_TrayWnd", "")
_51($br, 1460, 0, 0)
While ProcessExists("Explorer.exe")
Sleep(10)
$bn -= ProcessClose("Explorer.exe") ? 0 : 1
If $bn < 1 Then Return SetError(1, 0, 0)
WEnd
While(Not ProcessExists("Explorer.exe"))
If Not FileExists($bq) Then Return SetError(-1, 0, 0)
Sleep(500)
$bp = ShellExecute($bq)
$bo -= $bp ? 0 : 1
If $bo < 1 Then Return SetError(2, 0, 0)
WEnd
Return $bp
EndFunc
Func _10z($bs, $bt, $bu)
Local $4g = 0
While True
$4g += 1
Local $bv = RegEnumKey($bs, $4g)
If @error <> 0 Then ExitLoop
Local $bw = $bs & "\" & $bv
Local $6y = RegRead($bw, $bu)
If StringRegExp($6y, $bt) Then
Return $bw
EndIf
WEnd
Return Null
EndFunc
Func _111()
Local $bx[0]
If FileExists(@HomeDrive & "\Program Files") Then
_vv($bx, @HomeDrive & "\Program Files")
EndIf
If FileExists(@HomeDrive & "\Program Files (x86)") Then
_vv($bx, @HomeDrive & "\Program Files (x86)")
EndIf
If FileExists(@HomeDrive & "\Program Files(x86)") Then
_vv($bx, @HomeDrive & "\Program Files(x86)")
EndIf
Return $bx
EndFunc
Func _112($5x)
Return Int(FileExists($5x) And StringInStr(FileGetAttrib($5x), 'D', Default, 1) = 0)
EndFunc
Func _113($5x)
Return Int(FileExists($5x) And StringInStr(FileGetAttrib($5x), 'D', Default, 1) > 0)
EndFunc
Func _114($5x)
Local $by = Null
If FileExists($5x) Then
Local $bz = StringInStr(FileGetAttrib($5x), 'D', Default, 1)
If $bz = 0 Then
$by = 'file'
ElseIf $bz > 0 Then
$by = 'folder'
EndIf
EndIf
Return $by
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
Func _116($c0)
If StringRegExp($c0, "(?i)^(HKLM|HKCU|HKU|HKCR|HKCC)64") Then
Local $bu = StringReplace($c0, "64", "", 1)
Return $bu
EndIf
Return $c0
EndFunc
Func _117($c0)
If StringRegExp($c0, "(?i)^(HKLM|HKCU|HKU|HKCR|HKCC)") And @OSArch = "X64" Then
Local $c1 = StringSplit($c0, "\", $6)
$c1[0] = $c1[0] & "64"
$c0 = _wm($c1, "\")
EndIf
Return $c0
EndFunc
Func _118($bs)
If StringRegExp($bs, "(?i)^@AppDataCommonDir") Then
$bs = @AppDataCommonDir & StringReplace($bs, "@AppDataCommonDir", "")
EndIf
Return $bs
EndFunc
Func _119($c2, $bu)
If $c2.Exists($bu) Then
Local $bz = $c2.Item($bu) + 1
$c2.Item($bu) = $bz
Else
$c2.add($bu, 1)
EndIf
Return $c2
EndFunc
Func _11a($c3, $c4, $c5)
Dim $c6
Local $c7 = $c6.Item($c3)
Local $c8 = _119($c7.Item($c4), $c5)
$c7.Item($c4) = $c8
$c6.Item($c3) = $c7
EndFunc
Func _11b($c9, $ca)
If $c9 = Null Or $c9 = "" Then Return
Local $cb = ProcessExists($c9)
If $cb <> 0 Then
_10x("     [X] Process " & $c9 & " not killed, it is possible that the deletion is not complete (" & $ca & ")")
Else
_10x("     [OK] Process " & $c9 & " killed (" & $ca & ")")
EndIf
EndFunc
Func _11c($cc, $ca)
If $cc = Null Or $cc = "" Then Return
Local $cd = "[X]"
RegEnumVal($cc, "1")
If @error >= 0 Then
$cd = "[OK]"
EndIf
_10x("     " & $cd & " " & _116($cc) & " deleted (" & $ca & ")")
EndFunc
Func _11d($cc, $ca)
If $cc = Null Or $cc = "" Then Return
Local $7e = "", $7f = "", $63 = "", $7g = ""
Local $ce = _xe($cc, $7e, $7f, $63, $7g)
If $7g = ".exe" Then
Local $cf = $ce[1] & $ce[2]
Local $cd = "[OK]"
If FileExists($cf) Then
$cd = "[X]"
EndIf
_10x("     " & $cd & " Uninstaller run correctly (" & $ca & ")")
EndIf
EndFunc
Func _11e($cc, $ca)
If $cc = Null Or $cc = "" Then Return
Local $cd = "[OK]"
If FileExists($cc) Then
$cd = "[X]"
EndIf
_10x("     " & $cd & " " & $cc & " deleted (" & $ca & ")")
EndFunc
Func _11f($1p, $cc, $ca)
Switch $1p
Case "process"
_11b($cc, $ca)
Case "key"
_11c($cc, $ca)
Case "uninstall"
_11d($cc, $ca)
Case "element"
_11e($cc, $ca)
Case Else
_10x("     [?] Unknown type " & $1p)
EndSwitch
EndFunc
Local $cg = 43
Local $ch
Local Const $ci = Floor(100 / $cg)
Func _11g($cj = 1)
$ch += $cj
Dim $ck
GUICtrlSetData($ck, $ch * $ci)
If $ch = $cg Then
GUICtrlSetData($ck, 100)
EndIf
EndFunc
Func _11h()
$ch = 0
Dim $ck
GUICtrlSetData($ck, 0)
EndFunc
Func _11i()
_10x(@CRLF & "- Clear All System Restore Points -" & @CRLF)
Local Const $cl = _y2()
Local $cm = 0
If $cl[0][0] = 0 Then
_10x("  [I] No system recovery points were found")
Return Null
EndIf
Local $cn[1][3] = [[Null, Null, Null]]
For $4g = 1 To $cl[0][0]
Local $cb = _y4($cl[$4g][0])
$cm += $cb
If $cb = 1 Then
_10x("    => [OK] RP named " & $cl[$4g][1] & " created at " & $cl[$4g][2] & " deleted")
Else
Local $co[1][3] = [[$cl[$4g][0], $cl[$4g][1], $cl[$4g][2]]]
_vv($cn, $co)
EndIf
Next
If 1 < UBound($cn) Then
Sleep(3000)
For $4g = 1 To UBound($cn) - 1
Local $cb = _y4($cn[$4g][0])
$cm += $cb
If $cb = 1 Then
_10x("    => [OK] RP named " & $cn[$4g][1] & " created at " & $cl[$4g][2] & " deleted")
Else
_10x("    => [X] RP named " & $cn[$4g][1] & " created at " & $cl[$4g][2] & " deleted")
EndIf
Next
EndIf
If $cl[0][0] = $cm Then
_10x(@CRLF & "  [OK] All system restore points have been successfully deleted")
Else
_10x(@CRLF & "  [X] Failure when deleting all restore points")
EndIf
EndFunc
Func _11j($cp)
Local $cq = StringLeft($cp, 4)
Local $cr = StringMid($cp, 6, 2)
Local $cs = StringMid($cp, 9, 2)
Local $ct = StringRight($cp, 8)
Return $cr & "/" & $cs & "/" & $cq & " " & $ct
EndFunc
Func _11k($cu = False)
Local Const $cl = _y2()
If $cl[0][0] = 0 Then
Return Null
EndIf
Local Const $cv = _11j(_31('n', -1470, _3p()))
Local $cw = False
Local $cx = False
Local $cy = False
For $4g = 1 To $cl[0][0]
Local $cz = $cl[$4g][2]
If $cz > $cv Then
If $cy = False Then
$cy = True
$cx = True
_10x(@CRLF & "  [I] Recent System Restore Point Deletion before create new:" & @CRLF)
EndIf
Local $cb = _y4($cl[$4g][0])
If $cb = 1 Then
_10x("    => [OK] RP named " & $cl[$4g][1] & " created at " & $cz & " deleted")
ElseIf $cu = False Then
$cw = True
Else
_10x("    => [X] RP named " & $cl[$4g][1] & " created at " & $cz & " deleted")
EndIf
EndIf
Next
If $cw = True Then
Sleep(3000)
_10x("  [I] Retry deleting restore point")
_11k(True)
EndIf
If $cx = True Then
_10x(@CRLF)
EndIf
Sleep(3000)
EndFunc
Func _11l()
Sleep(3000)
_10x(@CRLF & "- Display All System Restore Point -" & @CRLF)
Local Const $cl = _y2()
If $cl[0][0] = 0 Then
_10x("  [X] No System Restore point found")
Return
EndIf
For $4g = 1 To $cl[0][0]
_10x("    => [I] RP named " & $cl[$4g][1] & " created at " & $cl[$4g][2] & " found")
Next
EndFunc
Func _11m()
RunWait(@ComSpec & ' /c ' & 'wmic.exe /Namespace:\\root\default Path SystemRestore Call CreateRestorePoint "KpRm", 100, 7', "", @SW_HIDE)
Return @error
EndFunc
Func _11n($cu = False)
If $cu = False Then
_10x(@CRLF & "- Create New System Restore Point -" & @CRLF)
Else
_10x("  [I] Retry Create New System Restore Point")
EndIf
Local $d0 = _y6()
If $d0 = 0 Then
Sleep(3000)
$d0 = _y6()
If $d0 = 0 Then
_10x("  [X] Enable System Restore")
EndIf
ElseIf $d0 = 1 Then
_10x("  [OK] Enable System Restore")
EndIf
_11k()
Local Const $d1 = _11m()
If $d1 <> 0 Then
_10x("  [X] System Restore Point created")
If $cu = False Then
_10x("  [I] Retry to create System Restore Point!")
_11n(True)
Return
Else
_11l()
Return
EndIf
ElseIf $d1 = 0 Then
_10x("  [OK] System Restore Point created")
_11l()
EndIf
EndFunc
Func _11o()
_10x(@CRLF & "- Create Registry Backup -" & @CRLF)
Local Const $d2 = @HomeDrive & "\KPRM"
Local Const $d3 = $d2 & "\regedit-backup-" & @YEAR & @MON & @MDAY & @HOUR & @MIN & ".reg"
If FileExists($d3) Then
FileMove($d3, $d3 & ".old")
EndIf
Local Const $d4 = RunWait("Regedit /e " & $d3)
If Not FileExists($d3) Or @error <> 0 Then
_10x("  [X] Failed to create registry backup")
MsgBox(16, $7s, $7t)
_10s()
Else
_10x("  [OK] Registry Backup: " & $d3)
EndIf
EndFunc
Func _11p()
_10x(@CRLF & "- Restore UAC Default Value -" & @CRLF)
Local $cb = _xr()
If $cb = 1 Then
_10x("  [OK] Set ConsentPromptBehaviorAdmin with default (5) value")
Else
_10x("  [X] Set ConsentPromptBehaviorAdmin with default value")
EndIf
Local $cb = _xs(3)
If $cb = 1 Then
_10x("  [OK] Set ConsentPromptBehaviorUser with default (3) value")
Else
_10x("  [X] Set ConsentPromptBehaviorUser with default value")
EndIf
Local $cb = _xt()
If $cb = 1 Then
_10x("  [OK] Set EnableInstallerDetection with default (0) value")
Else
_10x("  [X] Set EnableInstallerDetection with default value")
EndIf
Local $cb = _xu()
If $cb = 1 Then
_10x("  [OK] Set EnableLUA with default (1) value")
Else
_10x("  [X] Set EnableLUA with default value")
EndIf
Local $cb = _xv()
If $cb = 1 Then
_10x("  [OK] Set EnableSecureUIAPaths with default (1) value")
Else
_10x("  [X] Set EnableSecureUIAPaths with default value")
EndIf
Local $cb = _xw()
If $cb = 1 Then
_10x("  [OK] Set EnableUIADesktopToggle with default (0) value")
Else
_10x("  [X] Set EnableUIADesktopToggle with default value")
EndIf
Local $cb = _xx()
If $cb = 1 Then
_10x("  [OK] Set EnableVirtualization with default (1) value")
Else
_10x("  [X] Set EnableVirtualization with default value")
EndIf
Local $cb = _xy()
If $cb = 1 Then
_10x("  [OK] Set FilterAdministratorToken with default (0) value")
Else
_10x("  [X] Set FilterAdministratorToken with default value")
EndIf
Local $cb = _xz()
If $cb = 1 Then
_10x("  [OK] Set PromptOnSecureDesktop with default (1) value")
Else
_10x("  [X] Set PromptOnSecureDesktop with default value")
EndIf
Local $cb = _y0()
If $cb = 1 Then
_10x("  [OK] Set ValidateAdminCodeSignatures with default (0) value")
Else
_10x("  [X] Set ValidateAdminCodeSignatures with default value")
EndIf
EndFunc
Func _11q()
_10x(@CRLF & "- Restore Default System Settings -" & @CRLF)
Local $cb = RunWait(@ComSpec & " /c " & "ipconfig /flushdns", @TempDir, @SW_HIDE)
If @error <> 0 Then
_10x("  [X] Flush DNS")
Else
_10x("  [OK] Flush DNS")
EndIf
Local Const $d5[7] = [ "netsh winsock reset", "netsh winhttp reset proxy", "netsh winhttp reset tracing", "netsh winsock reset catalog", "netsh int ip reset all", "netsh int ipv4 reset catalog", "netsh int ipv6 reset catalog" ]
$cb = 0
For $4g = 0 To UBound($d5) -1
RunWait(@ComSpec & " /c " & $d5[$4g], @TempDir, @SW_HIDE)
If @error <> 0 Then
$cb += 1
EndIf
Next
If $cb = 0 Then
_10x("  [OK] Reset WinSock")
Else
_10x("  [X] Reset WinSock")
EndIf
Local $d6 = "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced"
$cb = RegWrite($d6, "Hidden", "REG_DWORD", "2")
If $cb = 1 Then
_10x("  [OK] Hide Hidden file.")
Else
_10x("  [X] Hide Hidden File")
EndIf
$cb = RegWrite($d6, "HideFileExt", "REG_DWORD", "0")
If $cb = 1 Then
_10x("  [OK] Show Extensions for known file types")
Else
_10x("  [X] Show Extensions for known file types")
EndIf
$cb = RegWrite($d6, "ShowSuperHidden", "REG_DWORD", "0")
If $cb = 1 Then
_10x("  [OK] Hide protected operating system files")
Else
_10x("  [X] Hide protected operating system files")
EndIf
_10y()
EndFunc
Func _11r($bs, $d7 = 0, $d8 = False)
If $d8 Then
_yx($bs)
_yf($bs)
EndIf
Local Const $d9 = FileGetAttrib($bs)
If StringInStr($d9, "R") Then
FileSetAttrib($bs, "-R", $d7)
EndIf
If StringInStr($d9, "S") Then
FileSetAttrib($bs, "-S", $d7)
EndIf
If StringInStr($d9, "H") Then
FileSetAttrib($bs, "-H", $d7)
EndIf
If StringInStr($d9, "A") Then
FileSetAttrib($bs, "-A", $d7)
EndIf
EndFunc
Func _11s($da, $c3, $db = Null, $d8 = False)
Local Const $dc = _112($da)
If $dc Then
If $db And StringRegExp($da, "(?i)\.(exe|com)$") Then
Local Const $dd = FileGetVersion($da, "CompanyName")
If @error Then
Return 0
ElseIf Not StringRegExp($dd, $db) Then
Return 0
EndIf
EndIf
_11a($c3, 'element', $da)
_11r($da, 0, $d8)
Local $de = FileDelete($da)
If $de Then
Return 1
EndIf
Return 2
EndIf
Return 0
EndFunc
Func _11t($bs, $c3, $d8 = False)
Local $dc = _113($bs)
If $dc Then
_11a($c3, 'element', $bs)
_11r($bs, 1, $d8)
Local Const $de = DirRemove($bs, $q)
If $de Then
Return 1
EndIf
Return 2
EndIf
Return 0
EndFunc
Func _11u($bs, $da, $df)
Local Const $dg = $bs & "\" & $da
Local Const $65 = FileFindFirstFile($dg)
Local $bh = []
If $65 = -1 Then
Return $bh
EndIf
Local $63 = FileFindNextFile($65)
While @error = 0
If StringRegExp($63, $df) Then
_vv($bh, $bs & "\" & $63)
EndIf
$63 = FileFindNextFile($65)
WEnd
FileClose($65)
Return $bh
EndFunc
Func _11v($dh, $di)
Local $dj = _114($dh)
If $dj = Null Then
Return Null
EndIf
Local $7e = "", $7f = "", $63 = "", $7g = ""
Local $ce = _xe($dh, $7e, $7f, $63, $7g)
Local $da = $63 & $7g
For $dk = 0 To UBound($di) - 1
If $di[$dk][3] And $dj = $di[$dk][1] And StringRegExp($da, $di[$dk][3]) Then
Local $cb = 0
Local $d8 = False
If $dj = 'file' Then
$cb = _11s($dh, $di[$dk][0], $di[$dk][2], $d8)
ElseIf $dj = 'folder' Then
$cb = _11t($dh, $di[$dk][0], $d8)
EndIf
EndIf
Next
EndFunc
Func _11w($bs, $di, $dl = -2)
Local $46 = _x2($bs, "*.exe;*.txt;*.lnk;*.log;*.reg;*.zip;*.dat;*.scr;*.com;*.bat", $t, $dl, $y, $10)
If @error <> 0 Then
Return Null
EndIf
For $4g = 1 To $46[0]
_11v($46[$4g], $di)
Next
EndFunc
Func _11x($bs, $di)
Local Const $dg = $bs & "\*"
Local Const $65 = FileFindFirstFile($dg)
If $65 = -1 Then
Return Null
EndIf
Local $63 = FileFindNextFile($65)
While @error = 0
Local $dh = $bs & "\" & $63
_11v($dh, $di)
$63 = FileFindNextFile($65)
WEnd
FileClose($65)
EndFunc
Func _11y($dm, $c3, $d8 = False)
If $d8 = True Then
_yx($dm)
_yf($dm, $8h)
EndIf
Local Const $cb = RegDelete($dm)
If $cb <> 0 Then
_11a($c3, "key", $dm)
EndIf
Return $cb
EndFunc
Func _11z($c9, $d8)
Local $dn = 50
Local $cb = Null
If 0 = ProcessExists($c9) Then Return 0
If $d8 = True Then
_yt($c9)
If 0 = ProcessExists($c9) Then Return 0
EndIf
ProcessClose($c9)
Do
$dn -= 1
Sleep(250)
Until($dn = 0 Or 0 = ProcessExists($c9))
$cb = ProcessExists($c9)
If 0 = $cb Then
Return 1
EndIf
Return 0
EndFunc
Func _120($7a)
Dim $dn
Local $do = ProcessList()
For $4g = 1 To $do[0][0]
Local $dp = $do[$4g][0]
Local $dq = $do[$4g][1]
For $dn = 0 To UBound($7a) - 1
If StringRegExp($dp, $7a[$dn][1]) Then
_11z($dq, $7a[$dn][2])
_11a($7a[$dn][0], "process", $dp)
EndIf
Next
Next
EndFunc
Func _121($7a)
For $4g = 0 To UBound($7a) - 1
RunWait('schtasks.exe /delete /tn "' & $7a[$4g][1] & '" /f', @TempDir, @SW_HIDE)
Next
EndFunc
Func _122($7a)
Local Const $bx = _111()
For $4g = 0 To UBound($bx) - 1
For $dr = 0 To UBound($7a) - 1
Local $ds = $7a[$dr][1]
Local $dt = $7a[$dr][2]
Local $du = _11u($bx[$4g], "*", $ds)
For $dv = 1 To UBound($du) - 1
Local $dw = _11u($du[$dv], "*", $dt)
For $dx = 1 To UBound($dw) - 1
If _112($dw[$dx]) Then
RunWait($dw[$dx])
_11a($7a[$dr][0], "uninstall", $dw[$dx])
EndIf
Next
Next
Next
Next
EndFunc
Func _123($7a)
Local Const $bx = _111()
For $4g = 0 To UBound($bx) - 1
_11x($bx[$4g], $7a)
Next
EndFunc
Func _124($7a)
Local $82 = _10w()
Local $dy[2] = ["HKCU" & $82 & "\SOFTWARE", "HKLM" & $82 & "\SOFTWARE"]
For $59 = 0 To UBound($dy) - 1
Local $4g = 0
While True
$4g += 1
Local $bv = RegEnumKey($dy[$59], $4g)
If @error <> 0 Then ExitLoop
For $dr = 0 To UBound($7a) - 1
If $bv And $7a[$dr][1] Then
If StringRegExp($bv, $7a[$dr][1]) Then
Local $dz = $dy[$59] & "\" & $bv
_11y($dz, $7a[$dr][0])
EndIf
EndIf
Next
WEnd
Next
EndFunc
Func _125($7a)
For $4g = 1 To UBound($7a) - 1
Local $bu = _117($7a[$4g][1])
Local $dz = _10z($bu, $7a[$4g][2], $7a[$4g][3])
If $dz And $dz <> "" Then
_11y($dz, $7a[$4g][0])
EndIf
Next
EndFunc
Func _126($7a)
For $4g = 0 To UBound($7a) - 1
Local $bu = _117($7a[$4g][1])
_11y($bu, $7a[$4g][0], $7a[$4g][2])
Next
EndFunc
Func _127($7a)
For $4g = 0 To UBound($7a) - 1
Local $bs = _118($7a[$4g][1])
If FileExists($bs) Then
Local $e0 = _x1($bs)
If @error = 0 Then
For $dv = 1 To $e0[0]
_11s($bs & '\' & $e0[$dv], $7a[$4g][0], $7a[$4g][2], $7a[$4g][3])
Next
EndIf
EndIf
Next
EndFunc
Global $c6 = ObjCreate("Scripting.Dictionary")
Local $e1 = ["desktop", "desktopCommon", "download", "homeDrive", "programFiles", "appData", "appDataCommon", "appDataLocal", "windowsFolder", "appDataCommonStartMenuFolder"]
Local $e2 = _zi(@TempDir & "\kprm-tools.xml")
Func _128($ct)
If _we($e1, $ct) <> -1 Then
Local $e3[4] = ["type", "companyName", "pattern", "force"]
Return $e3
ElseIf $ct = "uninstall" Then
Local $e3[2] = ["folder", "uninstaller"]
Return $e3
ElseIf $ct = "task" Then
Local $e3[1] = ["name"]
Return $e3
ElseIf $ct = "softwareKey" Then
Local $e3[1] = ["pattern"]
Return $e3
ElseIf $ct = "process" Then
Local $e3[2] = ["process", "force"]
Return $e3
ElseIf $ct = "registryKey" Then
Local $e3[2] = ["key", "force"]
Return $e3
ElseIf $ct = "searchRegistryKey" Then
Local $e3[3] = ["key", "pattern", "value"]
Return $e3
ElseIf $ct = "cleanDirectory" Then
Local $e3[3] = ["path", "companyName", "force"]
Return $e3
EndIf
EndFunc
Func _129($e4, $e5, $e6, $e3)
Local $bj = $e4 & "~~"
For $4g = 0 To UBound($e3) - 1
For $dr = 0 To UBound($e5) - 1
If $e3[$4g] = $e5[$dr] Then
$bj &= $e6[$dr] & "~~"
EndIf
Next
Next
$bj = StringTrimRight($bj, 2)
Return $bj
EndFunc
Local $e7 = _zl("/tools/tool")
For $4g = 1 To $e7[0]
Local $e8 = _zr("/tools/tool[" & $4g & "]", "name")
Local $e9 = ObjCreate("Scripting.Dictionary")
Local $ea = ObjCreate("Scripting.Dictionary")
Local $eb = ObjCreate("Scripting.Dictionary")
Local $ec = ObjCreate("Scripting.Dictionary")
Local $ed = ObjCreate("Scripting.Dictionary")
$e9.add("key", $ea)
$e9.add("element", $eb)
$e9.add("uninstall", $ec)
$e9.add("process", $ed)
$c6.add($e8, $e9)
Next
Func _12a($cu = False)
If $cu = True Then
_10x(@CRLF & "- Search Tools -" & @CRLF)
EndIf
Local Const $ee = [ "process", "uninstall", "task", "desktop", "desktopCommon", "download", "programFiles", "homeDrive", "appData", "appDataCommon", "appDataLocal", "windowsFolder", "softwareKey", "registryKey", "searchRegistryKey", "appDataCommonStartMenuFolder", "cleanDirectory"]
Local $e7 = _zl("/tools/tool")
For $ef = 0 To UBound($ee) - 1
Local $eg = $ee[$ef]
Local $e3 = _128($eg)
Local $eh[0][UBound($e3) + 1]
For $4g = 1 To $e7[0]
Local $e8 = _zr("/tools/tool[" & $4g & "]", "name")
Local $ei = _zl("/tools/tool[" & $4g & "]/*")
For $dr = 1 To $ei[0]
Local $1p = $ei[$dr]
If $1p = $eg Then
Local $b1[1], $b2[1]
_zt("/tools/tool[" & $4g & "]/*[" & $dr & "]", $b1, $b2)
Local $ej = _129($e8, $b1, $b2, $e3)
_vv($eh, $ej, 0, "~~")
EndIf
Next
Next
Switch $eg
Case "process"
_120($eh)
Case "uninstall"
_122($eh)
Case "task"
_121($eh)
Case "desktop"
_11w(@DesktopDir, $eh)
Case "desktopCommon"
_11x(@DesktopCommonDir, $eh)
Case "download"
_11w(@UserProfileDir & "\Downloads", $eh)
Case "programFiles"
_123($eh)
Case "homeDrive"
_11x(@HomeDrive, $eh)
Case "appDataCommon"
_11x(@AppDataCommonDir, $eh)
Case "appDataLocal"
_11x(@LocalAppDataDir, $eh)
Case "windowsFolder"
_11x(@WindowsDir, $eh)
Case "softwareKey"
_124($eh)
Case "registryKey"
_126($eh)
Case "searchRegistryKey"
_125($eh)
Case "appDataCommonStartMenuFolder"
_11x(@AppDataCommonDir & "\Microsoft\Windows\Start Menu\Programs", $eh)
Case "cleanDirectory"
_127($eh)
EndSwitch
_11g()
Next
If $cu = True Then
Local $ek = False
Local Const $el[4] = ["process", "uninstall", "element", "key"]
Local Const $em = "Warning, folder " & @AppDataDir & "\ZHP exists and contains the quarantines of the ZHP tools. At the request of the publisher (Nicolas Coolman) this folder is not deleted. "
Local $en = False
Local Const $eo = _113(@AppDataDir & "\ZHP")
For $ep In $c6
Local $eq = $c6.Item($ep)
Local $er = False
For $es = 0 To UBound($el) - 1
Local $et = $el[$es]
Local $eu = $eq.Item($et)
Local $ev = $eu.Keys
If UBound($ev) > 0 Then
If $er = False Then
$er = True
$ek = True
_10x(@CRLF & "  ## " & $ep & " found")
EndIf
For $ew = 0 To UBound($ev) - 1
Local $ex = $ev[$ew]
Local $ey = $eu.Item($ex)
_11f($et, $ex, $ey)
Next
If $ep = "ZHP Tools" And $eo = True And $en = False Then
_10x("     [!] " & $em)
$en = True
EndIf
EndIf
Next
Next
If $en = False And $eo = True Then
_10x(@CRLF & "  ## " & "ZHP Tools" & " found")
_10x("     [!] " & $em)
ElseIf $ek = False Then
_10x("  [I] No tools found")
EndIf
EndIf
_11g()
EndFunc
_10v()
If Not IsAdmin() Then
MsgBox(16, $7s, $7u)
_10s()
EndIf
Global $ez = "KpRm"
Global $bg = "kprm-" & @YEAR & @MON & @MDAY & @HOUR & @MIN & ".txt"
Local Const $f0 = GUICreate($ez, 500, 195, 202, 112)
Local Const $f1 = GUICtrlCreateGroup("Actions", 8, 8, 400, 153)
Local Const $f2 = GUICtrlCreateCheckbox($7k, 16, 40, 129, 17)
Local Const $f3 = GUICtrlCreateCheckbox($7l, 16, 80, 190, 17)
Local Const $f4 = GUICtrlCreateCheckbox($7m, 16, 120, 190, 17)
Local Const $f5 = GUICtrlCreateCheckbox($7n, 220, 40, 137, 17)
Local Const $f6 = GUICtrlCreateCheckbox($7o, 220, 80, 137, 17)
Local Const $f7 = GUICtrlCreateCheckbox($7p, 220, 120, 180, 17)
Global $ck = GUICtrlCreateProgress(8, 170, 480, 17)
GUICtrlCreateGroup("", -99, -99, 1, 1)
GUICtrlSetState($f2, 1)
Local Const $f8 = GUICtrlCreatePic(@TempDir & "\kprm-logo.gif", 415, 16, 76, 76)
Local Const $f9 = GUICtrlCreateButton($7q, 415, 120, 75, 40)
GUISetState(@SW_SHOW)
While 1
Local $fa = GUIGetMsg()
Switch $fa
Case $0
Exit
Case $f9
_12d()
EndSwitch
WEnd
Func _12b()
Local Const $7f = @HomeDrive & "\KPRM"
If Not FileExists($7f) Then
DirCreate($7f)
EndIf
If Not FileExists($7f) Then
MsgBox(16, $7s, $7t)
Exit
EndIf
EndFunc
Func _12c()
_12b()
_10x("#################################################################################################################" & @CRLF)
_10x("# Run at " & _3o())
_10x("# KpRm (Kernel-panik) version " & $7i)
_10x("# Website https://kernel-panik.me/tool/kprm/")
_10x("# Run by " & @UserName & " from " & @WorkingDir)
_10x("# Computer Name: " & @ComputerName)
_10x("# OS: " & _115() & " " & @OSArch & " (" & @OSBuild & ") " & @OSServicePack)
_11h()
EndFunc
Func _12d()
_12c()
_11g()
If GUICtrlRead($f5) = $1 Then
_11o()
EndIf
_11g()
If GUICtrlRead($f2) = $1 Then
_12a(False)
_12a(True)
Else
_11g(32)
EndIf
_11g()
If GUICtrlRead($f7) = $1 Then
_11q()
EndIf
_11g()
If GUICtrlRead($f6) = $1 Then
_11p()
EndIf
_11g()
If GUICtrlRead($f3) = $1 Then
_11i()
EndIf
_11g()
If GUICtrlRead($f4) = $1 Then
_11n()
EndIf
GUICtrlSetData($ck, 100)
MsgBox(64, "OK", $7r)
_10s(True)
EndFunc
