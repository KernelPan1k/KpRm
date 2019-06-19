#include-once
#include <FileConstants.au3>
#include <StringConstants.au3>

; #FUNCTION# ====================================================================================================================
; Name ..........: _SelfUpdate
; Description ...: Update the running executable with another executable.
; Syntax ........: _SelfUpdate($sUpdatePath[, $fRestart = False[, $iDelay = 5[, $fUsePID = False]]])
; Parameters ....: $sUpdatePath         - Path string of the update file to overwrite the running executable.
;                  $fRestart            - [optional] Restart the application (True) or to not restart (False) after overwriting. Default is False.
;                  $iDelay              - [optional] An integer value for the delay to wait (in seconds) before stopping the process and deleting the executable.
;                                         If 0 is specified then the batch will wait indefinitely until the process no longer exits. Default is 5 (seconds).
;                  $fUsePID             - [optional] Use the process name (False) or PID (True). Default is False.
;                  $fBackupPath         - [optional] Backup the filepath. Default is True.
; Return values .: Success - Returns the PID of the batch file.
;                  Failure - Returns 0 & sets @error to non-zero
; Author ........: guinness
; Modified ......:
; Remarks .......: The current executable is renamed to AppName_Backup.exe if $fBackupPath is set to True.
; Example .......: Yes
; ===============================================================================================================================
Func _SelfUpdate($sUpdatePath, $fRestart = Default, $iDelay = 5, $fUsePID = Default, $fBackupPath = Default)
	If @Compiled = 0 Or FileExists($sUpdatePath) = 0 Then
		Return SetError(1, 0, 0)
	EndIf

	Local $sTempFileName = @ScriptName
	$sTempFileName = StringLeft($sTempFileName, StringInStr($sTempFileName, '.', $STR_NOCASESENSEBASIC, -1) - 1)

	Local Const $sScriptPath = @ScriptFullPath
	Local $sBackupPath = ''
	If $fBackupPath Or $fBackupPath = Default Then
		$sBackupPath = 'MOVE /Y ' & '"' & $sScriptPath & '"' & ' "' & @ScriptDir & '\' & $sTempFileName & '_Backup.exe' & '"' & @CRLF
	EndIf

	While FileExists(@TempDir & '\' & $sTempFileName & '.bat')
		$sTempFileName &= Chr(Random(65, 122, 1))
	WEnd
	$sTempFileName = @TempDir & '\' & $sTempFileName & '.bat'

	If $iDelay = Default Then
		$iDelay = 5
	EndIf

	Local $sDelay = ''
	$iDelay = Int($iDelay)
	If $iDelay > 0 Then
		$sDelay = 'IF %TIMER% GTR ' & $iDelay & ' GOTO DELETE'
	EndIf

	Local $sAppID = @ScriptName, $sImageName = 'IMAGENAME'
	If $fUsePID Then
		$sAppID = @AutoItPID
		$sImageName = 'PID'
	EndIf

	Local $sRestart = ''
	If $fRestart Then
		$sRestart = 'START "" "' & $sScriptPath & '"'
	EndIf

	Local Const $iInternalDelay = 2
	Local Const $sData = '@ECHO OFF' & @CRLF & 'SET TIMER=0' & @CRLF _
			 & ':START' & @CRLF _
			 & 'PING -n ' & $iInternalDelay & ' 127.0.0.1 > nul' & @CRLF _
			 & $sDelay & @CRLF _
			 & 'SET /A TIMER+=1' & @CRLF _
			 & @CRLF _
			 & 'TASKLIST /NH /FI "' & $sImageName & ' EQ ' & $sAppID & '" | FIND /I "' & $sAppID & '" >nul && GOTO START' & @CRLF _
			 & 'GOTO MOVE' & @CRLF _
			 & @CRLF _
			 & ':MOVE' & @CRLF _
			 & 'TASKKILL /F /FI "' & $sImageName & ' EQ ' & $sAppID & '"' & @CRLF _
			 & $sBackupPath & _
			'GOTO END' & @CRLF _
			 & @CRLF _
			 & ':END' & @CRLF _
			 & 'MOVE /Y ' & '"' & $sUpdatePath & '"' & ' "' & $sScriptPath & '"' & @CRLF _
			 & $sRestart & @CRLF _
			 & 'DEL "' & $sTempFileName & '"'

	Local Const $hFileOpen = FileOpen($sTempFileName, $FO_OVERWRITE)
	If $hFileOpen = -1 Then
		Return SetError(2, 0, 0)
	EndIf
	FileWrite($hFileOpen, $sData)
	FileClose($hFileOpen)

	Run(@ComSpec & ' /c timeout 3 && ' & $sTempFileName, @TempDir, @SW_HIDE)
	Exit
EndFunc   ;==>_SelfUpdate
