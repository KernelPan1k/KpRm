#RequireAdmin
Global Const $0 = -3
Global Const $1 = 1
Global Const $2 = 0x00040000
Global Const $3 = 1
Global Const $4 = 2
Global Const $5 = 1
Global Const $6 = 2
Global Const $7 = 1
Global Const $8 = 2
Global Const $9 = "struct;word Year;word Month;word Dow;word Day;word Hour;word Minute;word Second;word MSeconds;endstruct"
Global Const $a = 0
Global Const $b = 1
Global Const $c = 2
Global Const $d= 1
Global Const $e = 'struct;dword OSVersionInfoSize;dword MajorVersion;dword MinorVersion;dword BuildNumber;dword PlatformId;wchar CSDVersion[128];endstruct'
Global Const $f = _1v()
Func _1v()
Local $g = DllStructCreate($e)
DllStructSetData($g, 1, DllStructGetSize($g))
Local $h = DllCall('kernel32.dll', 'bool', 'GetVersionExW', 'struct*', $g)
If @error Or Not $h[0] Then Return SetError(@error, @extended, 0)
Return BitOR(BitShift(DllStructGetData($g, 2), -8), DllStructGetData($g, 3))
EndFunc
Global Const $i = 0x001D
Global Const $j = 0x001E
Global Const $k = 0x001F
Global Const $l = 0x0020
Global Const $m = 0x1003
Global Const $n = 0x0028
Global Const $o = 0x0029
Global Const $p = 0x007F
Global Const $q = 0x0400
Func _2e($r = 0, $s = 0, $t = 0, $u = '')
If Not $r Then $r = 0x0400
Local $v = 'wstr'
If Not StringStripWS($u, $5 + $6) Then
$v = 'ptr'
$u = 0
EndIf
Local $h = DllCall('kernel32.dll', 'int', 'GetDateFormatW', 'dword', $r, 'dword', $t, 'struct*', $s, $v, $u, 'wstr', '', 'int', 2048)
If @error Or Not $h[0] Then Return SetError(@error, @extended, '')
Return $h[5]
EndFunc
Func _2h($r, $w)
Local $h = DllCall('kernel32.dll', 'int', 'GetLocaleInfoW', 'dword', $r, 'dword', $w, 'wstr', '', 'int', 2048)
If @error Or Not $h[0] Then Return SetError(@error + 10, @extended, '')
Return $h[3]
EndFunc
Func _32($x, $y = Default)
Local Const $0z = 128
If $y = Default Then $y = 0
$x = Int($x)
If $x < 1 Or $x > 7 Then Return SetError(1, 0, "")
Local $s = DllStructCreate($9)
DllStructSetData($s, "Year", BitAND($y, $0z) ? 2007 : 2006)
DllStructSetData($s, "Month", 1)
DllStructSetData($s, "Day", $x)
Return _2e(BitAND($y, $4) ? $q : $p, $s, 0, BitAND($y, $3) ? "ddd" : "dddd")
EndFunc
Func _35($10)
If StringIsInt($10) Then
Select
Case Mod($10, 4) = 0 And Mod($10, 100) <> 0
Return 1
Case Mod($10, 400) = 0
Return 1
Case Else
Return 0
EndSelect
EndIf
Return SetError(1, 0, 0)
EndFunc
Func _36($11)
$11 = Int($11)
Return $11 >= 1 And $11 <= 12
EndFunc
Func _37($12)
Local $13[4], $14[4]
_3g($12, $13, $14)
If Not StringIsInt($13[1]) Then Return 0
If Not StringIsInt($13[2]) Then Return 0
If Not StringIsInt($13[3]) Then Return 0
$13[1] = Int($13[1])
$13[2] = Int($13[2])
$13[3] = Int($13[3])
Local $15 = _3z($13[1])
If $13[1] < 1000 Or $13[1] > 2999 Then Return 0
If $13[2] < 1 Or $13[2] > 12 Then Return 0
If $13[3] < 1 Or $13[3] > $15[$13[2]] Then Return 0
If $14[0] < 1 Then Return 1
If $14[0] < 2 Then Return 0
If $14[0] = 2 Then $14[3] = "00"
If Not StringIsInt($14[1]) Then Return 0
If Not StringIsInt($14[2]) Then Return 0
If Not StringIsInt($14[3]) Then Return 0
$14[1] = Int($14[1])
$14[2] = Int($14[2])
$14[3] = Int($14[3])
If $14[1] < 0 Or $14[1] > 23 Then Return 0
If $14[2] < 0 Or $14[2] > 59 Then Return 0
If $14[3] < 0 Or $14[3] > 59 Then Return 0
Return 1
EndFunc
Func _3f($12, $16)
Local $13[4], $14[4]
Local $17 = "", $18 = ""
Local $19, $1a, $1b = ""
If Not _37($12) Then
Return SetError(1, 0, "")
EndIf
If $16 < 0 Or $16 > 5 Or Not IsInt($16) Then
Return SetError(2, 0, "")
EndIf
_3g($12, $13, $14)
Switch $16
Case 0
$1b = _2h($q, $k)
If Not @error And Not($1b = '') Then
$17 = $1b
Else
$17 = "M/d/yyyy"
EndIf
If $14[0] > 1 Then
$1b = _2h($q, $m)
If Not @error And Not($1b = '') Then
$18 = $1b
Else
$18 = "h:mm:ss tt"
EndIf
EndIf
Case 1
$1b = _2h($q, $l)
If Not @error And Not($1b = '') Then
$17 = $1b
Else
$17 = "dddd, MMMM dd, yyyy"
EndIf
Case 2
$1b = _2h($q, $k)
If Not @error And Not($1b = '') Then
$17 = $1b
Else
$17 = "M/d/yyyy"
EndIf
Case 3
If $14[0] > 1 Then
$1b = _2h($q, $m)
If Not @error And Not($1b = '') Then
$18 = $1b
Else
$18 = "h:mm:ss tt"
EndIf
EndIf
Case 4
If $14[0] > 1 Then
$18 = "hh:mm"
EndIf
Case 5
If $14[0] > 1 Then
$18 = "hh:mm:ss"
EndIf
EndSwitch
If $17 <> "" Then
$1b = _2h($q, $i)
If Not @error And Not($1b = '') Then
$17 = StringReplace($17, "/", $1b)
EndIf
Local $1c = _3h($13[1], $13[2], $13[3])
$13[3] = StringRight("0" & $13[3], 2)
$13[2] = StringRight("0" & $13[2], 2)
$17 = StringReplace($17, "d", "@")
$17 = StringReplace($17, "m", "#")
$17 = StringReplace($17, "y", "&")
$17 = StringReplace($17, "@@@@", _32($1c, 0))
$17 = StringReplace($17, "@@@", _32($1c, 1))
$17 = StringReplace($17, "@@", $13[3])
$17 = StringReplace($17, "@", StringReplace(StringLeft($13[3], 1), "0", "") & StringRight($13[3], 1))
$17 = StringReplace($17, "####", _3k($13[2], 0))
$17 = StringReplace($17, "###", _3k($13[2], 1))
$17 = StringReplace($17, "##", $13[2])
$17 = StringReplace($17, "#", StringReplace(StringLeft($13[2], 1), "0", "") & StringRight($13[2], 1))
$17 = StringReplace($17, "&&&&", $13[1])
$17 = StringReplace($17, "&&", StringRight($13[1], 2))
EndIf
If $18 <> "" Then
$1b = _2h($q, $n)
If Not @error And Not($1b = '') Then
$19 = $1b
Else
$19 = "AM"
EndIf
$1b = _2h($q, $o)
If Not @error And Not($1b = '') Then
$1a = $1b
Else
$1a = "PM"
EndIf
$1b = _2h($q, $j)
If Not @error And Not($1b = '') Then
$18 = StringReplace($18, ":", $1b)
EndIf
If StringInStr($18, "tt") Then
If $14[1] < 12 Then
$18 = StringReplace($18, "tt", $19)
If $14[1] = 0 Then $14[1] = 12
Else
$18 = StringReplace($18, "tt", $1a)
If $14[1] > 12 Then $14[1] = $14[1] - 12
EndIf
EndIf
$14[1] = StringRight("0" & $14[1], 2)
$14[2] = StringRight("0" & $14[2], 2)
$14[3] = StringRight("0" & $14[3], 2)
$18 = StringReplace($18, "hh", StringFormat("%02d", $14[1]))
$18 = StringReplace($18, "h", StringReplace(StringLeft($14[1], 1), "0", "") & StringRight($14[1], 1))
$18 = StringReplace($18, "mm", StringFormat("%02d", $14[2]))
$18 = StringReplace($18, "ss", StringFormat("%02d", $14[3]))
$17 = StringStripWS($17 & " " & $18, $5 + $6)
EndIf
Return $17
EndFunc
Func _3g($12, ByRef $1d, ByRef $1e)
Local $1f = StringSplit($12, " T")
If $1f[0] > 0 Then $1d = StringSplit($1f[1], "/-.")
If $1f[0] > 1 Then
$1e = StringSplit($1f[2], ":")
If UBound($1e) < 4 Then ReDim $1e[4]
Else
Dim $1e[4]
EndIf
If UBound($1d) < 4 Then ReDim $1d[4]
For $1g = 1 To 3
If StringIsInt($1d[$1g]) Then
$1d[$1g] = Int($1d[$1g])
Else
$1d[$1g] = -1
EndIf
If StringIsInt($1e[$1g]) Then
$1e[$1g] = Int($1e[$1g])
Else
$1e[$1g] = 0
EndIf
Next
Return 1
EndFunc
Func _3h($10, $1h, $1i)
If Not _37($10 & "/" & $1h & "/" & $1i) Then
Return SetError(1, 0, "")
EndIf
Local $1j = Int((14 - $1h) / 12)
Local $1k = $10 - $1j
Local $1l = $1h +(12 * $1j) - 2
Local $1m = Mod($1i + $1k + Int($1k / 4) - Int($1k / 100) + Int($1k / 400) + Int((31 * $1l) / 12), 7)
Return $1m + 1
EndFunc
Func _3k($1n, $y = Default)
If $y = Default Then $y = 0
$1n = Int($1n)
If Not _36($1n) Then Return SetError(1, 0, "")
Local $s = DllStructCreate($9)
DllStructSetData($s, "Year", @YEAR)
DllStructSetData($s, "Month", $1n)
DllStructSetData($s, "Day", 1)
Return _2e(BitAND($y, $4) ? $q : $p, $s, 0, BitAND($y, $3) ? "MMM" : "MMMM")
EndFunc
Func _3o()
Return _3f(@YEAR & "/" & @MON & "/" & @MDAY & " " & @HOUR & ":" & @MIN & ":" & @SEC, 0)
EndFunc
Func _3z($10)
Local $1o = [12, 31,(_35($10) ? 29 : 28), 31, 30, 31, 30, 31, 31, 30, 31, 30, 31]
Return $1o
EndFunc
Func _51($1p, $1q, $1r = 0, $1s = 0, $1t = 0, $1u = "wparam", $1v = "lparam", $1w = "lresult")
Local $1x = DllCall("user32.dll", $1w, "SendMessageW", "hwnd", $1p, "uint", $1q, $1u, $1r, $1v, $1s)
If @error Then Return SetError(@error, @extended, "")
If $1t >= 0 And $1t <= 4 Then Return $1x[$1t]
Return $1x
EndFunc
Global Const $1y = Ptr(-1)
Global Const $1z = Ptr(-1)
Global Const $20 = 0x0100
Global Const $21 = 0x2000
Global Const $22 = 0x8000
Global Const $23 = BitShift($20, 8)
Global Const $24 = BitShift($21, 8)
Global Const $25 = BitShift($22, 8)
Global Const $26 = 0x8000000
Func _d0($27, $28)
Local $1x = DllCall("user32.dll", "hwnd", "FindWindowW", "wstr", $27, "wstr", $28)
If @error Then Return SetError(@error, @extended, 0)
Return $1x[0]
EndFunc
Func _hf($29, $t, $2a = 0, $2b = 0)
Local $2c = 'dword_ptr', $2d = 'dword_ptr'
If IsString($2a) Then
$2c = 'wstr'
EndIf
If IsString($2b) Then
$2d = 'wstr'
EndIf
DllCall('shell32.dll', 'none', 'SHChangeNotify', 'long', $29, 'uint', $t, $2c, $2a, $2d, $2b)
If @error Then Return SetError(@error, @extended, 0)
Return 1
EndFunc
Global Const $2e = 11
Global $2f[$2e]
Global Const $2g = "struct;uint Mask;int Item;int SubItem;uint State;uint StateMask;ptr Text;int TextMax;int Image;lparam Param;" & "int Indent;int GroupID;uint Columns;ptr pColumns;ptr piColFmt;int iGroup;endstruct"
#Au3Stripper_Ignore_Funcs=__ArrayDisplay_SortCallBack
Func __ArrayDisplay_SortCallBack($2h, $2i, $1p)
If $2f[3] = $2f[4] Then
If Not $2f[7] Then
$2f[5] *= -1
$2f[7] = 1
EndIf
Else
$2f[7] = 1
EndIf
$2f[6] = $2f[3]
Local $2j = _vr($1p, $2h, $2f[3])
Local $2k = _vr($1p, $2i, $2f[3])
If $2f[8] = 1 Then
If(StringIsFloat($2j) Or StringIsInt($2j)) Then $2j = Number($2j)
If(StringIsFloat($2k) Or StringIsInt($2k)) Then $2k = Number($2k)
EndIf
Local $2l
If $2f[8] < 2 Then
$2l = 0
If $2j < $2k Then
$2l = -1
ElseIf $2j > $2k Then
$2l = 1
EndIf
Else
$2l = DllCall('shlwapi.dll', 'int', 'StrCmpLogicalW', 'wstr', $2j, 'wstr', $2k)[0]
EndIf
$2l = $2l * $2f[5]
Return $2l
EndFunc
Func _vr($1p, $2m, $2n = 0)
Local $2o = DllStructCreate("wchar Text[4096]")
Local $2p = DllStructGetPtr($2o)
Local $2q = DllStructCreate($2g)
DllStructSetData($2q, "SubItem", $2n)
DllStructSetData($2q, "TextMax", 4096)
DllStructSetData($2q, "Text", $2p)
If IsHWnd($1p) Then
DllCall("user32.dll", "lresult", "SendMessageW", "hwnd", $1p, "uint", 0x1073, "wparam", $2m, "struct*", $2q)
Else
Local $2r = DllStructGetPtr($2q)
GUICtrlSendMsg($1p, 0x1073, $2m, $2r)
EndIf
Return DllStructGetData($2o, "Text")
EndFunc
Global Enum $2s, $2t, $2u, $2v, $2w, $2x, $2y, $2z
Func _vv(ByRef $30, $31, $32 = 0, $33 = "|", $34 = @CRLF, $35 = $2s)
If $32 = Default Then $32 = 0
If $33 = Default Then $33 = "|"
If $34 = Default Then $34 = @CRLF
If $35 = Default Then $35 = $2s
If Not IsArray($30) Then Return SetError(1, 0, -1)
Local $36 = UBound($30, $b)
Local $37 = 0
Switch $35
Case $2u
$37 = Int
Case $2v
$37 = Number
Case $2w
$37 = Ptr
Case $2x
$37 = Hwnd
Case $2y
$37 = String
Case $2z
$37 = "Boolean"
EndSwitch
Switch UBound($30, $a)
Case 1
If $35 = $2t Then
ReDim $30[$36 + 1]
$30[$36] = $31
Return $36
EndIf
If IsArray($31) Then
If UBound($31, $a) <> 1 Then Return SetError(5, 0, -1)
$37 = 0
Else
Local $38 = StringSplit($31, $33, $8 + $7)
If UBound($38, $b) = 1 Then
$38[0] = $31
EndIf
$31 = $38
EndIf
Local $39 = UBound($31, $b)
ReDim $30[$36 + $39]
For $3a = 0 To $39 - 1
If String($37) = "Boolean" Then
Switch $31[$3a]
Case "True", "1"
$30[$36 + $3a] = True
Case "False", "0", ""
$30[$36 + $3a] = False
EndSwitch
ElseIf IsFunc($37) Then
$30[$36 + $3a] = $37($31[$3a])
Else
$30[$36 + $3a] = $31[$3a]
EndIf
Next
Return $36 + $39 - 1
Case 2
Local $3b = UBound($30, $c)
If $32 < 0 Or $32 > $3b - 1 Then Return SetError(4, 0, -1)
Local $3c, $3d = 0, $3e
If IsArray($31) Then
If UBound($31, $a) <> 2 Then Return SetError(5, 0, -1)
$3c = UBound($31, $b)
$3d = UBound($31, $c)
$37 = 0
Else
Local $3f = StringSplit($31, $34, $8 + $7)
$3c = UBound($3f, $b)
Local $38[$3c][0], $3g
For $3a = 0 To $3c - 1
$3g = StringSplit($3f[$3a], $33, $8 + $7)
$3e = UBound($3g)
If $3e > $3d Then
$3d = $3e
ReDim $38[$3c][$3d]
EndIf
For $3h = 0 To $3e - 1
$38[$3a][$3h] = $3g[$3h]
Next
Next
$31 = $38
EndIf
If UBound($31, $c) + $32 > UBound($30, $c) Then Return SetError(3, 0, -1)
ReDim $30[$36 + $3c][$3b]
For $3i = 0 To $3c - 1
For $3h = 0 To $3b - 1
If $3h < $32 Then
$30[$3i + $36][$3h] = ""
ElseIf $3h - $32 > $3d - 1 Then
$30[$3i + $36][$3h] = ""
Else
If String($37) = "Boolean" Then
Switch $31[$3i][$3h - $32]
Case "True", "1"
$30[$3i + $36][$3h] = True
Case "False", "0", ""
$30[$3i + $36][$3h] = False
EndSwitch
ElseIf IsFunc($37) Then
$30[$3i + $36][$3h] = $37($31[$3i][$3h - $32])
Else
$30[$3i + $36][$3h] = $31[$3i][$3h - $32]
EndIf
EndIf
Next
Next
Case Else
Return SetError(2, 0, -1)
EndSwitch
Return UBound($30, $b) - 1
EndFunc
Func _we(Const ByRef $30, $31, $32 = 0, $3j = 0, $3k = 0, $3l = 0, $3m = 1, $2n = -1, $3n = False)
If $32 = Default Then $32 = 0
If $3j = Default Then $3j = 0
If $3k = Default Then $3k = 0
If $3l = Default Then $3l = 0
If $3m = Default Then $3m = 1
If $2n = Default Then $2n = -1
If $3n = Default Then $3n = False
If Not IsArray($30) Then Return SetError(1, 0, -1)
Local $36 = UBound($30) - 1
If $36 = -1 Then Return SetError(3, 0, -1)
Local $3b = UBound($30, $c) - 1
Local $3o = False
If $3l = 2 Then
$3l = 0
$3o = True
EndIf
If $3n Then
If UBound($30, $a) = 1 Then Return SetError(5, 0, -1)
If $3j < 1 Or $3j > $3b Then $3j = $3b
If $32 < 0 Then $32 = 0
If $32 > $3j Then Return SetError(4, 0, -1)
Else
If $3j < 1 Or $3j > $36 Then $3j = $36
If $32 < 0 Then $32 = 0
If $32 > $3j Then Return SetError(4, 0, -1)
EndIf
Local $3p = 1
If Not $3m Then
Local $3q = $32
$32 = $3j
$3j = $3q
$3p = -1
EndIf
Switch UBound($30, $a)
Case 1
If Not $3l Then
If Not $3k Then
For $3a = $32 To $3j Step $3p
If $3o And VarGetType($30[$3a]) <> VarGetType($31) Then ContinueLoop
If $30[$3a] = $31 Then Return $3a
Next
Else
For $3a = $32 To $3j Step $3p
If $3o And VarGetType($30[$3a]) <> VarGetType($31) Then ContinueLoop
If $30[$3a] == $31 Then Return $3a
Next
EndIf
Else
For $3a = $32 To $3j Step $3p
If $3l = 3 Then
If StringRegExp($30[$3a], $31) Then Return $3a
Else
If StringInStr($30[$3a], $31, $3k) > 0 Then Return $3a
EndIf
Next
EndIf
Case 2
Local $3r
If $3n Then
$3r = $36
If $2n > $3r Then $2n = $3r
If $2n < 0 Then
$2n = 0
Else
$3r = $2n
EndIf
Else
$3r = $3b
If $2n > $3r Then $2n = $3r
If $2n < 0 Then
$2n = 0
Else
$3r = $2n
EndIf
EndIf
For $3h = $2n To $3r
If Not $3l Then
If Not $3k Then
For $3a = $32 To $3j Step $3p
If $3n Then
If $3o And VarGetType($30[$3h][$3a]) <> VarGetType($31) Then ContinueLoop
If $30[$3h][$3a] = $31 Then Return $3a
Else
If $3o And VarGetType($30[$3a][$3h]) <> VarGetType($31) Then ContinueLoop
If $30[$3a][$3h] = $31 Then Return $3a
EndIf
Next
Else
For $3a = $32 To $3j Step $3p
If $3n Then
If $3o And VarGetType($30[$3h][$3a]) <> VarGetType($31) Then ContinueLoop
If $30[$3h][$3a] == $31 Then Return $3a
Else
If $3o And VarGetType($30[$3a][$3h]) <> VarGetType($31) Then ContinueLoop
If $30[$3a][$3h] == $31 Then Return $3a
EndIf
Next
EndIf
Else
For $3a = $32 To $3j Step $3p
If $3l = 3 Then
If $3n Then
If StringRegExp($30[$3h][$3a], $31) Then Return $3a
Else
If StringRegExp($30[$3a][$3h], $31) Then Return $3a
EndIf
Else
If $3n Then
If StringInStr($30[$3h][$3a], $31, $3k) > 0 Then Return $3a
Else
If StringInStr($30[$3a][$3h], $31, $3k) > 0 Then Return $3a
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
AutoItSetOption("MustDeclareVars", 1)
Local Const $3s[6] = ["040C", "080C", "0C0C", "100C", "140C", "180C"]
If _we($3s, @MUILang) <> 1 Then
Global $3t = "Supprimer des outils"
Global $3u = "Supprimer les points de restaurations"
Global $3v = "Créer un point de restauration"
Global $3w = "Sauvegarder le registre"
Global $3x = "Restaurer UAC"
Global $3y = "Restaurer les paramètres système"
Global $3z = "Exécuter"
Global $40 = "Toutes les opérations sont terminées"
Global $41 = "Echec"
Global $42 = "Impossible de créer une sauvegarde du registre"
Global $43 = "Vous devez exécuter le programme avec les droits administrateurs"
Global $44 = "Vous devez fermer MalwareBytes Anti-Rootkit avant de continuer"
Else
Global $3t = "Delete Tools"
Global $3u = "Delete Restore Points"
Global $3v = "Create Restore Point"
Global $3w = "Registry Backup"
Global $3x = "UAC Restore"
Global $3y = "Restore System Settings"
Global $3z = "Run"
Global $40 = "All operations are completed"
Global $41 = "Fail"
Global $42 = "Unable to create a registry backup"
Global $43 = "You must run the program with administrator rights"
Global $44 = "You must close MalwareBytes Anti-Rootkit before continuing"
EndIf
Global Const $45 = 1
Global Const $46 = 5
Global Const $47 = 0
Global Const $48 = 1
Func _x9($49 = $46)
If Not IsAdmin() Then Return SetError(-3, 0, -1)
If StringRegExp(@OSVersion, "_(XP|200(0|3))") Then Return SetError(-4, 0, -1)
Local $4a = ""
If @OSArch = "X64" Then $4a = "64"
If $49 < 0 Or $49 > 5 Then Return SetError(-5, 0, -1)
Local $1t = RegWrite("HKEY_LOCAL_MACHINE" & $4a & "\Software\Microsoft\Windows\CurrentVersion\Policies\System", "ConsentPromptBehaviorAdmin", "REG_DWORD", $49)
If $1t = 0 Then $1t = -1
Return SetError(@error, 0, $1t)
EndFunc
Func _xa($49 = $45)
If Not IsAdmin() Then Return SetError(-3, 0, -1)
If StringRegExp(@OSVersion, "_(XP|200(0|3))") Then Return SetError(-4, 0, -1)
If $49 < 0 Or $49 = 2 Or $49 > 3 Then Return SetError(-5, 0, -1)
Local $4a = ""
If @OSArch = "X64" Then $4a = "64"
Local $1t = RegWrite("HKEY_LOCAL_MACHINE" & $4a & "\Software\Microsoft\Windows\CurrentVersion\Policies\System", "ConsentPromptBehaviorUser", "REG_DWORD", $49)
If $1t = 0 Then $1t = -1
Return SetError(@error, 0, $1t)
EndFunc
Func _xb($49 = $47)
If Not IsAdmin() Then Return SetError(-3, 0, -1)
If StringRegExp(@OSVersion, "_(XP|200(0|3))") Then Return SetError(-4, 0, -1)
If $49 < 0 Or $49 > 1 Then Return SetError(-5, 0, -1)
Local $4a = ""
If @OSArch = "X64" Then $4a = "64"
Local $1t = RegWrite("HKEY_LOCAL_MACHINE" & $4a & "\Software\Microsoft\Windows\CurrentVersion\Policies\System", "EnableInstallerDetection", "REG_DWORD", $49)
If $1t = 0 Then $1t = -1
Return SetError(@error, 0, $1t)
EndFunc
Func _xc($49 = $48)
If Not IsAdmin() Then Return SetError(-3, 0, -1)
If StringRegExp(@OSVersion, "_(XP|200(0|3))") Then Return SetError(-4, 0, -1)
If $49 < 0 Or $49 > 1 Then Return SetError(-5, 0, -1)
Local $4a = ""
If @OSArch = "X64" Then $4a = "64"
Local $1t = RegWrite("HKEY_LOCAL_MACHINE" & $4a & "\Software\Microsoft\Windows\CurrentVersion\Policies\System", "EnableLUA", "REG_DWORD", $49)
If $1t = 0 Then $1t = -1
Return SetError(@error, 0, $1t)
EndFunc
Func _xd($49 = $48)
If Not IsAdmin() Then Return SetError(-3, 0, -1)
If StringRegExp(@OSVersion, "_(XP|200(0|3))") Then Return SetError(-4, 0, -1)
If $49 < 0 Or $49 > 1 Then Return SetError(-5, 0, -1)
Local $4a = ""
If @OSArch = "X64" Then $4a = "64"
Local $1t = RegWrite("HKEY_LOCAL_MACHINE" & $4a & "\Software\Microsoft\Windows\CurrentVersion\Policies\System", "EnableSecureUIAPaths", "REG_DWORD", $49)
If $1t = 0 Then $1t = -1
Return SetError(@error, 0, $1t)
EndFunc
Func _xe($49 = $47)
If Not IsAdmin() Then Return SetError(-3, 0, -1)
If StringRegExp(@OSVersion, "_(XP|200(0|3))") Then Return SetError(-4, 0, -1)
If $49 < 0 Or $49 > 1 Then Return SetError(-5, 0, -1)
Local $4a = ""
If @OSArch = "X64" Then $4a = "64"
Local $1t = RegWrite("HKEY_LOCAL_MACHINE" & $4a & "\Software\Microsoft\Windows\CurrentVersion\Policies\System", "EnableUIADesktopToggle", "REG_DWORD", $49)
If $1t = 0 Then $1t = -1
Return SetError(@error, 0, $1t)
EndFunc
Func _xf($49 = $48)
If Not IsAdmin() Then Return SetError(-3, 0, -1)
If StringRegExp(@OSVersion, "_(XP|200(0|3))") Then Return SetError(-4, 0, -1)
If $49 < 0 Or $49 > 1 Then Return SetError(-5, 0, -1)
Local $4a = ""
If @OSArch = "X64" Then $4a = "64"
Local $1t = RegWrite("HKEY_LOCAL_MACHINE" & $4a & "\Software\Microsoft\Windows\CurrentVersion\Policies\System", "EnableVirtualization", "REG_DWORD", $49)
If $1t = 0 Then $1t = -1
Return SetError(@error, 0, $1t)
EndFunc
Func _xg($49 = $47)
If Not IsAdmin() Then Return SetError(-3, 0, -1)
If StringRegExp(@OSVersion, "_(XP|200(0|3))") Then Return SetError(-4, 0, -1)
If $49 < 0 Or $49 > 1 Then Return SetError(-5, 0, -1)
Local $4a = ""
If @OSArch = "X64" Then $4a = "64"
Local $1t = RegWrite("HKEY_LOCAL_MACHINE" & $4a & "\Software\Microsoft\Windows\CurrentVersion\Policies\System", "FilterAdministratorToken", "REG_DWORD", $49)
If $1t = 0 Then $1t = -1
Return SetError(@error, 0, $1t)
EndFunc
Func _xh($49 = $48)
If Not IsAdmin() Then Return SetError(-3, 0, -1)
If StringRegExp(@OSVersion, "_(XP|200(0|3))") Then Return SetError(-4, 0, -1)
If $49 < 0 Or $49 > 1 Then Return SetError(-5, 0, -1)
Local $4a = ""
If @OSArch = "X64" Then $4a = "64"
Local $1t = RegWrite("HKEY_LOCAL_MACHINE" & $4a & "\Software\Microsoft\Windows\CurrentVersion\Policies\System", "PromptOnSecureDesktop", "REG_DWORD", $49)
If $1t = 0 Then $1t = -1
Return SetError(@error, 0, $1t)
EndFunc
Func _xi($49 = $47)
If Not IsAdmin() Then Return SetError(-3, 0, -1)
If StringRegExp(@OSVersion, "_(XP|200(0|3))") Then Return SetError(-4, 0, -1)
If $49 < 0 Or $49 > 1 Then Return SetError(-5, 0, -1)
Local $4a = ""
If @OSArch = "X64" Then $4a = "64"
Local $1t = RegWrite("HKEY_LOCAL_MACHINE" & $4a & "\Software\Microsoft\Windows\CurrentVersion\Policies\System", "ValidateAdminCodeSignatures", "REG_DWORD", $49)
If $1t = 0 Then $1t = -1
Return SetError(@error, 0, $1t)
EndFunc
Global $4b = Null, $4c = Null
Global $4d = EnvGet('SystemDrive') & '\'
Func _xj($4e)
Local Const $4f = 64
#forceref $4f
Local Const $4g = 256
Local Const $4h = 100
Local Const $4i = 12
Local $4j = DllStructCreate('DWORD dwEventType;DWORD dwRestorePtType;INT64 llSequenceNumber;WCHAR szDescription[' & $4g & ']')
DllStructSetData($4j, 'dwEventType', $4h)
DllStructSetData($4j, 'dwRestorePtType', $4i)
DllStructSetData($4j, 'llSequenceNumber', 0)
DllStructSetData($4j, 'szDescription', $4e)
Local $4k = DllStructGetPtr($4j)
Local $4l = DllStructCreate('UINT  nStatus;INT64 llSequenceNumber')
Local $4m = DllStructGetPtr($4l)
Local $h = DllCall('SrClient.dll', 'BOOL', 'SRSetRestorePointW', 'ptr', $4k, 'ptr', $4m)
If @error Then Return 0
Return $h[0]
EndFunc
Func _xk()
Local $4n[1][3], $4o = 0
$4n[0][0] = $4o
If Not IsObj($4c) Then $4c = ObjGet("winmgmts:root/default")
If Not IsObj($4c) Then Return $4n
Local $4p = $4c.InstancesOf("SystemRestore")
If Not IsObj($4p) Then Return $4n
For $4q In $4p
$4o += 1
ReDim $4n[$4o + 1][3]
$4n[$4o][0] = $4q.SequenceNumber
$4n[$4o][1] = $4q.Description
$4n[$4o][2] = _xl($4q.CreationTime)
Next
$4n[0][0] = $4o
Return $4n
EndFunc
Func _xl($4r)
Return(StringMid($4r, 5, 2) & "/" & StringMid($4r, 7, 2) & "/" & StringLeft($4r, 4) & " " & StringMid($4r, 9, 2) & ":" & StringMid($4r, 11, 2) & ":" & StringMid($4r, 13, 2))
EndFunc
Func _xm($4s)
Local $h = DllCall('SrClient.dll', 'DWORD', 'SRRemoveRestorePoint', 'DWORD', $4s)
If @error Then Return SetError(1, 0, 0)
If $h[0] = 0 Then Return 1
Return SetError(1, 0, 0)
EndFunc
Func _xo($4t = $4d)
If Not IsObj($4b) Then $4b = ObjGet("winmgmts:{impersonationLevel=impersonate}!root/default:SystemRestore")
If Not IsObj($4b) Then Return 0
If $4b.Enable($4t) = 0 Then Return 1
Return 0
EndFunc
If Not IsAdmin() Then
MsgBox(16, $41, $43)
Exit
EndIf
Local $4u = ProcessList("mbar.exe")
If $4u[0][0] > 0 Then
MsgBox(16, $41, $44)
Exit
EndIf
Func _xr($4v)
FileWrite(@DesktopDir & "\kp-remover.txt", $4v & @CRLF)
EndFunc
Func _xs()
Local $4w = 100, $4x = 100, $4y = 0, $4z = @WindowsDir & "\Explorer.exe"
_hf($26, 0, 0, 0)
Local $50 = _d0("Shell_TrayWnd", "")
_51($50, 1460, 0, 0)
While ProcessExists("Explorer.exe")
Sleep(10)
$4w -= ProcessClose("Explorer.exe") ? 0 : 1
If $4w < 1 Then Return SetError(1, 0, 0)
WEnd
While(Not ProcessExists("Explorer.exe"))
If Not FileExists($4z) Then Return SetError(-1, 0, 0)
Sleep(500)
$4y = ShellExecute($4z)
$4x -= $4y ? 0 : 1
If $4x < 1 Then Return SetError(2, 0, 0)
WEnd
Return $4y
EndFunc
Func _xv($51, $52, $53)
Local $3a = 0
While True
$3a += 1
Local $54 = RegEnumKey($51, $3a)
If @error <> 0 Then ExitLoop
Local $55 = $51 & "\" & $54
Local $56 = RegRead($55, $53)
If StringRegExp($56, $52) Then
Return $55
EndIf
WEnd
Return Null
EndFunc
Func _xx()
Local $57 = []
If FileExists(@HomeDrive & "\Program Files") Then
_vv($57, @HomeDrive & "\Program Files")
EndIf
If FileExists(@HomeDrive & "\Program Files (x86)") Then
_vv($57, @HomeDrive & "\Program Files (x86)")
EndIf
If FileExists(@HomeDrive & "\Program Files(x86)") Then
_vv($57, @HomeDrive & "\Program Files(x86)")
EndIf
Return $57
EndFunc
Func _xy($58)
Return Int(FileExists($58) And StringInStr(FileGetAttrib($58), 'D', Default, 1) = 0)
EndFunc
Func _xz($58)
Return Int(FileExists($58) And StringInStr(FileGetAttrib($58), 'D', Default, 1) > 0)
EndFunc
Local $59 = 23
Local $5a
Local Const $5b = Floor(100 / $59)
Func _y0()
$5a += 1
Dim $5c
GUICtrlSetData($5c, $5a * $5b)
If $5a = $59 Then
GUICtrlSetData($5c, 100)
EndIf
EndFunc
Func _y1()
$5a = 0
Dim $5c
GUICtrlSetData($5c, 0)
EndFunc
Func _y2()
_xr(@CRLF & "- Clear All System Restore Points -" & @CRLF)
Local Const $5d = _xk()
Local $5e = 0
If $5d[0][0] = 0 Then
_xr("  [I] No system recovery points were found")
Return Null
EndIf
Local $5f[1][3] = [[Null, Null, Null]]
For $3a = 1 To $5d[0][0]
Local $5g = _xm($5d[$3a][0])
$5e += $5g
If $5g = 1 Then
_xr("    => [OK] RP named " & $5d[$3a][1] & " has been successfully deleted")
Else
_vv($5f, $5d[$3a])
EndIf
Next
If 1 < UBound($5f) Then
Sleep(3000)
For $3a = 1 To UBound($5f) - 1
Local $5g = _xm($5f[$3a][0])
$5e += $5g
If $5g = 1 Then
_xr("    => [OK] RP named " & $5f[$3a][1] & " has been successfully deleted")
Else
_xr("    => [X] RP named " & $5f[$3a][1] & " has not been successfully deleted")
EndIf
Next
EndIf
If $5d[0][0] = $5e Then
_xr("  [OK] All system restore points have been successfully deleted")
Else
_xr("  [X] Failure when deleting all restore points")
EndIf
EndFunc
Func _y3($5h = False)
If $5h = False Then
_xr(@CRLF & "- Create New System Restore Point -" & @CRLF)
Else
_xr("  [I] Retry Create New System Restore Point")
EndIf
Dim $5i
Local $5j = _xo()
If $5j = 0 Then
Sleep(3000)
$5j = _xo()
If $5j = 0 Then
_xr("  [X] Failed to enable System Restore")
EndIf
ElseIf $5j = 1 Then
_xr("  [OK] System Restore enabled successfully")
EndIf
Local Const $5k = _xj($5i)
Local $5l = 50
Do
Sleep(250)
$5l -= 1
Until $5k = 0 Or $5k = 1 Or $5l = 0
If $5k = 0 Or $5l = 0 Then
_xr("  [X] Failed to create System Restore Point!")
If $5h = False Then
_y3(True)
Return
EndIf
ElseIf $5k = 1 Then
_xr("  [OK] System Restore Point successfully created")
EndIf
EndFunc
Func _y4()
_xr(@CRLF & "- Create Registry Backup -" & @CRLF)
Local Const $5m = @WindowsDir & "\KPRM-REGISTRY-BACKUP"
If Not FileExists($5m) Then
DirCreate($5m)
EndIf
If Not FileExists($5m) Then
_xr("  [X] Failed to create " & $5m & " directory")
MsgBox(16, $41, $42)
Exit
EndIf
Local Const $5n = $5m & "\kprm-registry-backup-" & @MON & @MDAY & @HOUR & @MIN & ".reg"
If FileExists($5n) Then
FileMove($5n, $5n & ".old")
EndIf
Local Const $5g = RunWait("Regedit /e " & $5n)
If Not FileExists($5n) Or @error <> 0 Then
_xr("  [X] Failed to create registry backup")
MsgBox(16, $41, $42)
Exit
Else
_xr("  [OK] Registry Backup created successfully at " & $5n)
EndIf
EndFunc
Func _y5()
_xr(@CRLF & "- Restore UAC Default Value -" & @CRLF)
Local $5g = _x9()
If $5g = 1 Then
_xr("  [OK] Set ConsentPromptBehaviorAdmin with default value successfully.")
Else
_xr("  [X] Set ConsentPromptBehaviorAdmin with default value failed")
EndIf
Local $5g = _xa()
If $5g = 1 Then
_xr("  [OK] Set ConsentPromptBehaviorUser with default value successfully.")
Else
_xr("  [X] Set ConsentPromptBehaviorUser with default value failed")
EndIf
Local $5g = _xb()
If $5g = 1 Then
_xr("  [OK] Set EnableInstallerDetection with default value successfully.")
Else
_xr("  [X] Set EnableInstallerDetection with default value failed")
EndIf
Local $5g = _xc()
If $5g = 1 Then
_xr("  [OK] Set EnableLUA with default value successfully.")
Else
_xr("  [X] Set EnableLUA with default value failed")
EndIf
Local $5g = _xd()
If $5g = 1 Then
_xr("  [OK] Set EnableSecureUIAPaths with default value successfully.")
Else
_xr("  [X] Set EnableSecureUIAPaths with default value failed")
EndIf
Local $5g = _xe()
If $5g = 1 Then
_xr("  [OK] Set EnableUIADesktopToggle with default value successfully.")
Else
_xr("  [X] Set EnableUIADesktopToggle with default value failed")
EndIf
Local $5g = _xf()
If $5g = 1 Then
_xr("  [OK] Set EnableVirtualization with default value successfully.")
Else
_xr("  [X] Set EnableVirtualization with default value failed")
EndIf
Local $5g = _xg()
If $5g = 1 Then
_xr("  [OK] Set FilterAdministratorToken with default value successfully.")
Else
_xr("  [X] Set FilterAdministratorToken with default value failed")
EndIf
Local $5g = _xh()
If $5g = 1 Then
_xr("  [OK] Set PromptOnSecureDesktop with default value successfully.")
Else
_xr("  [X] Set PromptOnSecureDesktop with default value failed")
EndIf
Local $5g = _xi()
If $5g = 1 Then
_xr("  [OK] Set ValidateAdminCodeSignatures with default value successfully.")
Else
_xr("  [X] Set ValidateAdminCodeSignatures with default value failed")
EndIf
EndFunc
Func _y6()
_xr(@CRLF & "- Restore Default System Settings -" & @CRLF)
Local $5g = RunWait(@ComSpec & " /c " & "ipconfig /flushdns", @TempDir, @SW_HIDE)
If @error <> 0 Then
_xr("  [X] Flush DNS failure")
Else
_xr("  [OK] Flush DNS successfully completed")
EndIf
Local Const $5o[7] = [ "netsh winsock reset", "netsh winhttp reset proxy", "netsh winhttp reset tracing", "netsh winsock reset catalog", "netsh int ip reset all", "netsh int ipv4 reset catalog", "netsh int ipv6 reset catalog" ]
$5g = 0
For $3a = 0 To UBound($5o) -1
RunWait(@ComSpec & " /c " & $5o[$3a], @TempDir, @SW_HIDE)
If @error <> 0 Then
$5g += 1
EndIf
Next
If $5g = 0 Then
_xr("  [OK] Reset WinSock successfully completed")
Else
_xr("  [X] Reset WinSock failure")
EndIf
$5p = "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced"
$5g = RegWrite($5p, "Hidden", "REG_DWORD", "2")
If $5g = 1 Then
_xr("  [OK] Hide Hidden file successfully.")
Else
_xr("  [X] Hide Hidden File failure")
EndIf
$5g = RegWrite($5p, "HideFileExt", "REG_DWORD", "1")
If $5g = 1 Then
_xr("  [OK] Hide Extensions for known file types successfully.")
Else
_xr("  [X] Hide Extensions for known file types failure")
EndIf
$5g = RegWrite($5p, "ShowSuperHidden", "REG_DWORD", "0")
If $5g = 1 Then
_xr("  [OK] Hide protected operating system files successfully.")
Else
_xr("  [X] Hide protected operating system files failure")
EndIf
_xs()
EndFunc
Global $5q = ObjCreate("Scripting.Dictionary")
$5q.add("frst", 0)
$5q.add("zhpdiag", 0)
$5q.add("zhpcleaner", 0)
$5q.add("zhpfix", 0)
$5q.add("mbar", 0)
$5q.add("roguekiller", 0)
$5q.add("usbfix", 0)
$5q.add("adwcleaner", 0)
$5q.add("adsfix", 0)
$5q.add("fake", 0)
Global $5r[1][2] = [[Null, Null]]
Global $5s[1][3] = [[Null, Null, Null]]
Global $5t[1][2] = [[Null, Null]]
Global $5u[1][3] = [[Null, Null, Null]]
Global $5v[1][3] = [[Null, Null, Null]]
Global $5w[1][2] = [[Null, Null]]
Global $5x[1][2] = [[Null, Null]]
Global $5y[1][2] = [[Null, Null]]
Global $5z[1][3] = [[Null, Null, Null]]
Global $60[1][2] = [[Null, Null]]
Global $61[1][2] = [[Null, Null]]
Global $62[1][4] = [[Null, Null, Null, Null]]
Global $63[1][2] = [[Null, Null]]
Global $64[1][2] = [[Null, Null]]
Global $65[1][2] = [[Null, Null]]
Global $66[1][2] = [[Null, Null]]
Global $67[1][3] = [[Null, Null, Null]]
Func _y7($51, $68 = 0)
FileSetAttrib($51, "-R", $68)
FileSetAttrib($51, "-A", $68)
FileSetAttrib($51, "-S", $68)
FileSetAttrib($51, "-H", $68)
EndFunc
Func _y8($69, $6a = Null)
Dim $6b
Local Const $6c = _xy($69)
If $6c Then
If $6a And StringRegExp($69, "(?i)\.exe$") Then
Local Const $6d = FileGetVersion($69, "FileDescription")
If @error Then
Return 0
ElseIf Not StringRegExp($6d, $6a) Then
Return 0
EndIf
EndIf
Local $6e = FileDelete($69)
If $6e Then
If $6b Then
_xr("  [OK] File " & $69 & " deleted successfully")
EndIf
Return 1
EndIf
EndIf
Return 0
EndFunc
Func _y9($51)
Dim $6b
Local $6c = _xz($51)
If $6c Then
_y7($51, 1)
Local Const $6e = DirRemove($51, $d)
If $6e Then
If $6b Then
_xr("  [OK] Directory " & $51 & " deleted successfully")
EndIf
Return 1
EndIf
EndIf
Return 0
EndFunc
Func _ya($51, $69, $6f)
Local Const $6g = $51 & "\" & $69
Local Const $6h = FileFindFirstFile($6g)
Local $6i = []
If $6h = -1 Then
Return $6i
EndIf
Local $6j = FileFindNextFile($6h)
While @error = 0
If StringRegExp($6j, $6f) Then
_vv($6i, $51 & "\" & $6j)
EndIf
$6j = FileFindNextFile($6h)
WEnd
FileClose($6h)
Return $6i
EndFunc
Func _yb($51, $69, $6f, $6a = Null)
Local $6i = 0
Local Const $6k = _ya($51, $69, $6f)
For $3a = 1 To UBound($6k) - 1
If $6k[$3a] And $6k[$3a] <> "" Then
$6i += _y8($6k[$3a], $6a)
EndIf
Next
Return $6i
EndFunc
Func _yc($51, $69, $6f)
Local $6i = 0
Local Const $6k = _ya($51, $69, $6f)
For $3a = 1 To UBound($6k) - 1
If $6k[$3a] And $6k[$3a] <> "" Then
$6i += _y9($6k[$3a])
EndIf
Next
Return $6i
EndFunc
Func _yd($53)
Dim $6b
Local Const $5g = RegDelete($53)
If $5g = 1 Then
If $6b Then
_xr("  [OK] " & $53 & " deleted successfully")
EndIf
Return 1
ElseIf $5g = 2 Then
If $6b Then
_xr("  [X] " & $53 & " deleted failed")
EndIf
EndIf
Return 0
EndFunc
Func _yh($6l)
Local $6m = 50
Dim $6b
If 0 = ProcessExists($6l) Then Return 0
ProcessClose($6l)
Do
$6m -= 1
Sleep(250)
Until($6m = 0 Or 0 = ProcessExists($6l))
Local Const $5g = ProcessExists($6l)
If 0 = $5g Then
If $6b Then _xr("  [OK] Porccess " & $6l & " stopped successfully")
Return 1
EndIf
Return 0
EndFunc
Func _yi($4u)
Dim $6m
Local $6n = ProcessList()
For $3a = 1 To $6n[0][0]
Local $6o = $6n[$3a][0]
Local $6p = $6n[$3a][1]
For $6m = 1 To UBound($4u) - 1
If StringRegExp($6o, $4u[$6m][1]) Then
$5q.Item($4u[$6m][0]) += _yh($6p)
EndIf
Next
Next
EndFunc
Func _yj($6q)
Dim $6b
Dim $5q
For $3a = 1 To UBound($6q) - 1
RunWait('schtasks.exe /delete /tn "' & $6q[$3a][1] & '" /f', @TempDir, @SW_HIDE)
If @error = 0 Then
If $6b Then _xr("  [OK] RogueKiller.exe was deleted from schedule")
$5q.Item($6q[$3a][0]) += 1
EndIf
Next
EndFunc
Func _yk($6q)
Dim $5q
Local Const $57 = _xx()
For $3a = 1 To UBound($57) - 1
For $6r = 1 To UBound($6q) - 1
Local $6s = $6q[$6r][1]
Local $6t = $6q[$6r][2]
Local $6u = _ya($57[$3a], "*", $6s)
For $6v = 1 To UBound($6u) - 1
Local $6w = _ya($6u[$6v], "*", $6t)
For $6x = 1 To UBound($6w) - 1
If FileExists($6w[$6x]) Then
RunWait($6w[$6x])
$5q.Item($6q[$6r][0]) += 1
EndIf
Next
Next
Next
Next
EndFunc
Func _yl($51, $6q)
Dim $5q
For $3a = 1 To UBound($6q) - 1
$5q.Item($6q[$3a][0]) += _yb($51, "*", $6q[$3a][2], $6q[$3a][1])
Next
EndFunc
Func _ym($51, $6q)
Dim $5q
For $3a = 1 To UBound($6q) - 1
$5q.Item($6q[$3a][0]) += _yc($51, "*", $6q[$3a][1])
Next
EndFunc
Func _yn($6q)
Local Const $57 = _xx()
For $3a = 1 To UBound($57) - 1
_ym($57[$3a], $6q)
Next
EndFunc
Func _yo($6q)
Dim $5q
Local $4a = ""
If @OSArch = "X64" Then $4a = "64"
Local $6y[2] = ["HKCU" & $4a & "\SOFTWARE", "HKLM" & $4a & "\SOFTWARE"]
For $6z = 0 To UBound($6y) - 1
Local $3a = 0
While True
$3a += 1
Local $54 = RegEnumKey($6y[$6z], $3a)
If @error <> 0 Then ExitLoop
For $6r = 1 To UBound($6q) - 1
If $54 And $6q[$6r][1] Then
If StringRegExp($54, $6q[$6r][1]) Then
$5q.Item($6q[$6r][0]) += _yd($6y[$6z] & "\" & $54)
EndIf
EndIf
Next
WEnd
Next
EndFunc
Func _yp($6q)
Dim $5q
For $3a = 1 To UBound($6q) - 1
Local $70 = _xv($6q[$3a][1], $6q[$3a][2], $6q[$3a][3])
If $70 And $70 <> "" Then
$5q.Item($6q[$3a][0]) += _yd($70)
EndIf
Next
EndFunc
Func _yq()
Local Const $71 = "frst"
Dim $5r
Dim $5s
Dim $5t
Dim $5v
Dim $5w
Dim $5y
Local Const $6a = "(?i)^Farbar"
Local Const $72 = "(?i)^FRST"
Local Const $73[1][2] = [[$71, $72]]
Local Const $74[1][3] = [[$71, $6a, "(?i)^(FRST|fixlist|fixlog|Addition|Shortcut).*\.(exe|txt)$"]]
Local Const $75[1][2] = [[$71, "(?i)^FRST-OlderVersion$"]]
_vv($5r, $73)
_vv($5s, $74)
_vv($5v, $74)
_vv($5t, $75)
_vv($5w, $75)
_vv($5y, $73)
EndFunc
Func _yr()
Dim $64
Dim $65
Dim $60
Local $76 = "fake"
Local Const $77[1][2] = [[$76, "(?i)^ZHP$"]]
_vv($64, $77)
_vv($65, $77)
_vv($60, $77)
EndFunc
Func _ys()
Local Const $78 = "(?i)^ZHPDiag"
Local Const $79 = "zhpdiag"
Dim $5r
Dim $5s
Dim $5u
Dim $5v
Local Const $73[1][2] = [[$79, $78]]
Local Const $74[1][3] = [[$79, $78, "(?i)^ZHPDiag.*\.(exe|txt|lnk)$"]]
_vv($5r, $73)
_vv($5s, $74)
_vv($5v, $74)
_vv($5u, $74)
EndFunc
Func _yt()
Local Const $78 = "(?i)^ZHPFix"
Local Const $7a = "zhpfix"
Dim $5r
Dim $5s
Dim $5v
Local Const $73[1][2] = [[$7a, $78]]
Local Const $74[1][3] = [[$7a, $78, "(?i)^ZHPFix.*\.(exe|txt|lnk)$"]]
_vv($5r, $73)
_vv($5s, $74)
_vv($5v, $74)
EndFunc
Func _yu($5h = False)
Local Const $6a = "(?i)^Malwarebytes Anti-Rootkit$"
Local Const $7b = "mbar"
Dim $5r
Dim $5t
Dim $5w
Dim $5s
Dim $5v
Dim $60
Local Const $73[1][2] = [[$7b, "(?i)^mbar"]]
Local Const $74[1][2] = [[$7b, $6a]]
Local Const $7c[1][3] = [[$7b, $6a, "(?i)^mbar.*\.exe$"]]
_vv($5r, $73)
_vv($5t, $73)
_vv($5w, $73)
_vv($5s, $7c)
_vv($5v, $7c)
_vv($60, $74)
EndFunc
Func _yv($5h = False)
Local Const $7d = "roguekiller"
Dim $5r
Dim $61
Dim $62
Dim $5x
Dim $63
Dim $5s
Dim $5u
Dim $5w
Dim $66
Dim $5v
Local $4a = ""
If @OSArch = "X64" Then $4a = "64"
Local Const $7e = "(?i)^(RogueKiller.*|Anti-Malware Scan and Removal)$"
Local Const $7f = "(?i)^RogueKiller"
Local Const $7g = "(?i)^RogueKiller.*\.(exe|lnk)"
Local Const $73[1][2] = [[$7d, $7f]]
Local Const $74[1][2] = [[$7d, "RogueKiller Anti-Malware"]]
Local Const $7c[1][4] = [[$7d, "HKLM" & $4a & "\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall", $7f, "DisplayName"]]
Local Const $75[1][3] = [[$7d, $7e, $7g]]
Local Const $7h[1][3] = [[$7d, Null, "(?i)^RogueKiller.*\.lnk"]]
_vv($5r,$73)
_vv($61, $74)
_vv($62, $7c)
_vv($5x, $73)
_vv($63, $73)
_vv($5s, $75)
_vv($5v, $75)
_vv($5u, $7h)
_vv($5w, $75)
_vv($66, $73)
EndFunc
Func _yw()
Dim $5r
Dim $5s
Dim $5v
Dim $5y
Local Const $7i = "adwcleaner"
Local Const $6a = "(?i)^AdwCleaner"
Local Const $73[1][2] = [[$7i, $6a]]
Local Const $74[1][3] = [[$7i, $6a, "(?i)^AdwCleaner.*\.exe$"]]
_vv($5r, $73)
_vv($5s, $74)
_vv($5v, $74)
_vv($5y, $73)
EndFunc
Func _yx()
Local Const $78 = "(?i)^ZHPCleaner"
Local Const $7j = "zhpcleaner"
Dim $5r
Dim $5s
Dim $5v
Local Const $73[1][2] = [[$7j, $78]]
Local Const $74[1][3] = [[$7j, $78, "(?i)^ZHPCleaner.*\.(exe|txt|lnk)$"]]
_vv($5r, $73)
_vv($5s, $74)
_vv($5v, $74)
EndFunc
Func _yy()
Local Const $7k = "usbfix"
Dim $5r
Dim $67
Dim $5s
Dim $5u
Dim $5v
Dim $60
Dim $5y
Dim $5x
Local Const $6a = "(?i)^UsbFix"
Local Const $73[1][2] = [[$7k, $6a]]
Local Const $74[1][3] = [[$7k, $6a, "(?i)^Un-UsbFix.exe$"]]
Local Const $7c[1][3] = [[$7k, $6a, "(?i)^UsbFix.*\.(exe|lnk)$"]]
Local Const $75[1][2] = [[$7k, "(?i)^UsbFixQuarantine$"]]
_vv($5r, $73)
_vv($67, $74)
_vv($5s, $7c)
_vv($5u, $7c)
_vv($5v, $7c)
_vv($60, $73)
_vv($5y, $75)
_vv($5y, $73)
EndFunc
Func _yz()
Local Const $7l = "adsfix"
Dim $5r
Dim $5s
Dim $5v
Dim $5y
Dim $5u
Dim $60
Dim $5z
Local Const $6a = "(?i)^AdsFix"
Local Const $73[1][2] = [[$7l, $6a]]
Local Const $74[1][3] = [[$7l, $6a, "(?i)^AdsFix.*\.(exe|txt|lnk)$"]]
Local Const $7c[1][3] = [[$7l, Null, "(?i)^AdsFix.*\.txt$"]]
_vv($5r, $73)
_vv($5s, $74)
_vv($5u, $74)
_vv($5v, $74)
_vv($5y, $73)
_vv($60, $73)
_vv($5z, $7c)
EndFunc
_yq()
_ys()
_yt()
_yx()
_yr()
_yu()
_yv()
_yw()
_yy()
_yz()
Func _z0()
_yi($5r)
_y0()
_yk($67)
_y0()
_yj($61)
_y0()
_yl(@DesktopDir, $5s)
_y0()
_yl(@DesktopCommonDir, $5u)
_y0()
_ym(@DesktopDir, $5t)
_y0()
If FileExists(@UserProfileDir & "\Downloads") Then
_yl(@UserProfileDir & "\Downloads", $5v)
_y0()
_ym(@UserProfileDir & "\Downloads", $5w)
_y0()
Else
_y0()
_y0()
EndIf
_yn($5x)
_y0()
_ym(@HomeDrive, $5y)
_y0()
_yl(@HomeDrive, $5z)
_y0()
_ym(@AppDataDir, $64)
_y0()
_ym(@AppDataCommonDir, $63)
_y0()
_ym(@LocalAppDataDir, $65)
_y0()
_yo($60)
_y0()
_yp($62)
_y0()
_ym(@AppDataCommonDir & "\Microsoft\Windows\Start Menu\Programs", $66)
_y0()
EndFunc
FileInstall("C:\Users\IEUser\Desktop\kpRemover\src\assets\bug.gif", @TempDir & "\kprm-logo.gif")
Global $5i = "KpRm"
Global $6b = True
Local Const $7m = GUICreate($5i, 500, 195, 202, 112)
Local Const $7n = GUICtrlCreateGroup("Actions", 8, 8, 400, 153)
Local Const $7o = GUICtrlCreateCheckbox($3t, 16, 40, 129, 17)
Local Const $7p = GUICtrlCreateCheckbox($3u, 16, 80, 190, 17)
Local Const $7q = GUICtrlCreateCheckbox($3v, 16, 120, 190, 17)
Local Const $7r = GUICtrlCreateCheckbox($3w, 220, 40, 137, 17)
Local Const $7s = GUICtrlCreateCheckbox($3x, 220, 80, 137, 17)
Local Const $7t = GUICtrlCreateCheckbox($3y, 220, 120, 180, 17)
Global $5c = GUICtrlCreateProgress(8, 170, 480, 17)
GUICtrlCreateGroup("", -99, -99, 1, 1)
Local Const $7u = GUICtrlCreatePic(@TempDir & "\kprm-logo.gif", 415, 16, 76, 76)
Local Const $7v = GUICtrlCreateButton($3z, 415, 120, 75, 40)
GUISetState(@SW_SHOW)
While 1
Local $7w = GUIGetMsg()
Switch $7w
Case $0
Exit
Case $7v
_z2()
EndSwitch
WEnd
Func _z1()
FileWrite(@DesktopDir & "\kp-remover.txt", "#################################################################################################################" & @CRLF & @CRLF)
FileWrite(@DesktopDir & "\kp-remover.txt", "# Run at " & _3o() & @CRLF)
FileWrite(@DesktopDir & "\kp-remover.txt", "# Run by " & @UserName & " in " & @ComputerName & @CRLF)
FileWrite(@DesktopDir & "\kp-remover.txt", "# Launch fom " & @WorkingDir & @CRLF)
_y1()
EndFunc
Func _z2()
_z1()
_y0()
If GUICtrlRead($7r) = $1 Then
_y4()
EndIf
_y0()
If GUICtrlRead($7o) = $1 Then
_z0()
EndIf
_y0()
If GUICtrlRead($7t) = $1 Then
_y6()
EndIf
_y0()
If GUICtrlRead($7s) = $1 Then
_y5()
EndIf
_y0()
If GUICtrlRead($7p) = $1 Then
_y2()
EndIf
_y0()
If GUICtrlRead($7q) = $1 Then
_y3()
EndIf
GUICtrlSetData($5c, 100)
MsgBox(64, "OK", $40)
Exit
EndFunc
