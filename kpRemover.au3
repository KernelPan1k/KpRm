#Region ;**** Directives created by AutoIt3Wrapper_GUI ****
#AutoIt3Wrapper_Res_File_Add=C:\Users\IEUser\Desktop\kpRemover\bug.gif
#EndRegion ;**** Directives created by AutoIt3Wrapper_GUI ****
#include <ButtonConstants.au3>
#include <GUIConstantsEx.au3>
#include <StaticConstants.au3>
#include <WindowsConstants.au3>
#include <Date.au3>
#include "SystemRestore.au3"
#include "UAC.au3"

#Region ### START Koda GUI section ### Form=C:\Users\IEUser\Desktop\kpRemover\Form1.kxf

FileInstall("C:\Users\IEUser\Desktop\kpRemover\bug.gif", @TempDir & "\iwgefiwefecbeifbibi.gif")

Local Const $ProgramName = "KpRm"
Local Const $nbrTask = 3
Global $currentNbrTask = 0
Global Const $taskStep = Floor(100 / $nbrTask)

Local Const $MainWindow = GUICreate($ProgramName, 449, 175, 202, 112)
Local Const $Group1 = GUICtrlCreateGroup("Actions", 8, 8, 337, 153)
Local Const $RemoveTools = GUICtrlCreateCheckbox("Suppression des outils", 16, 40, 129, 17)
Local Const $RemoveRP = GUICtrlCreateCheckbox("Supprimer les PR", 16, 80, 105, 17)
Local Const $CreateRP = GUICtrlCreateCheckbox("Nouveau PR", 16, 120, 97, 17)
Local Const $BackupRegistry = GUICtrlCreateCheckbox("Sauvegarde du registre", 192, 40, 137, 17)
Local Const $RestoreUAC = GUICtrlCreateCheckbox("Restaurer UAC", 192, 80, 137, 17)

GUICtrlCreateGroup("", -99, -99, 1, 1)

Local Const $Pic1 = GUICtrlCreatePic(@TempDir & "\iwgefiwefecbeifbibi.gif", 360, 16, 76, 76)
Local Const $RunKp = GUICtrlCreateButton("Button1", 360, 120, 75, 41)

GUISetState(@SW_SHOW)

#EndRegion ### END Koda GUI section ###

While 1

	$nMsg = GUIGetMsg()

	Switch $nMsg
		Case $GUI_EVENT_CLOSE
			Exit

		Case $RunKp
			KpRemover()

	EndSwitch
WEnd

Func ProgressBarUpdate()
	$currentNbrTask += 1
	ProgressSet($currentNbrTask * $taskStep)

	If $currentNbrTask = $nbrTask Then
		ProgressSet(100, "Done!")
		Sleep(750)
		ProgressOff()
	EndIf
EndFunc   ;==>ProgressBarUpdate


Func Init()
	FileWrite(@DesktopDir & "\kp-remover.txt", "##########################################" & @CRLF)
	FileWrite(@DesktopDir & "\kp-remover.txt", "Run at " & _NowTime() & " by " & @UserName & " from " & @WorkingDir & @CRLF)
	ProgressOn($ProgramName, $ProgramName & " progress", "Working...")
EndFunc   ;==>Init


Func logMessage($message)
	FileWrite(@DesktopDir & "\kp-remover.txt", $message & @CRLF)
EndFunc   ;==>logMessage



Func ClearRestorePoint()
	logMessage(@CRLF & "=> ************* Clear All System Restore Point ************** <=" & @CRLF)

	Local Const $aRP = _SR_EnumRestorePoints()
	Local $ret = 0

	If $aRP[0][0] = 0 Then
		logMessage("  [I] Any System Restore Point are found.")
		Return Null
	EndIf

	For $i = 1 To $aRP[0][0]
		Local $status = _SR_RemoveRestorePoint($aRP[$i][0])
		$ret += $status

		If $status = 1 Then
			logMessage("  [OK] RP " & $aRP[$i][1] & " has deleted successfully")
		Else
			logMessage("  [X] RP " & $aRP[$i][1] & " has not deleted successfully")
		EndIf
	Next

	If $aRP[0][0] = $ret Then
		logMessage("  [OK] All System Restore Point deleted successfully.")
	Else
		logMessage("  [X] All System Restore Point are not deleted successfully.")
	EndIf

EndFunc   ;==>ClearRestorePoint



Func CreateRestorePoint()
	logMessage(@CRLF & "=> ************* Create New System Restore Point ************** <=" & @CRLF)

	Local Const $iSR_Enabled = _SR_Enable()

	If $iSR_Enabled = 0 Then
		logMessage("  [X] Failed to enable System Restore!")
	ElseIf $iSR_Enabled = 1 Then
		logMessage("  [OK] System Restore enabled successfully.")
	EndIf

	Sleep(1000)

	Local Const $createdPointStatus = _SR_CreateRestorePoint($ProgramName)

	Do
		Sleep(3000)
	Until $createdPointStatus = 0 Or $createdPointStatus = 1

	If $createdPointStatus = 0 Then
		logMessage("  [X] Failed to create System Restore Point!")
	ElseIf $createdPointStatus = 1 Then
		logMessage("  [OK] System Restore Point created successfully.")
	EndIf

EndFunc   ;==>CreateRestorePoint

Func CreateBackupRegistry()
	logMessage(@CRLF & "=> ************* Create Registry Backup ************** <=" & @CRLF)

	Local Const $backUpPath = @WindowsDir & "\KPRM-REGISTRY-BACKUP"

	If Not FileExists($backUpPath) Then
		DirCreate($backUpPath)
	EndIf

	If Not FileExists($backUpPath) Then
		logMessage("  [X] Failed to create " & $backUpPath & " directory")
		Exit
	EndIf

	Local Const $backupLocation = $backUpPath & "\kprm-registry-backup-" & @MON & @MDAY & @HOUR & @MIN & ".reg"

	If FileExists($backupLocation) Then
		FileMove($backupLocation, $backupLocation & ".old")
	EndIf

	Local Const $status = RunWait("Regedit /e " & $backupLocation)

	Sleep(3000)

	If Not FileExists($backupLocation) Or $status <> 0 Then
		logMessage("  [X] Failed to create backup registry")
		Exit
	Else
		logMessage("  [OK] Backup Registry ceated successfully at " & $backupLocation)
	EndIf
EndFunc   ;==>CreateBackupRegistry

Func RestaureUACByDefault()
	logMessage(@CRLF & "=> ************* Restore UAC Default Value ************** <=" & @CRLF)

	Local $status = _UAC_SetConsentPromptBehaviorAdmin()

	If $status = 1 Then
		logMessage("  [OK] Set ConsentPromptBehaviorAdmin with default value " & $UAC_PROMPT_FOR_CONSENT_NONWINDOWS_BINARIES & " successfully.")
	Else
		logMessage("  [X] Set ConsentPromptBehaviorAdmin with default value failed")
	EndIf

;~ #################

	Local $status = _UAC_SetConsentPromptBehaviorUser()

	If $status = 1 Then
		logMessage("  [OK] Set ConsentPromptBehaviorUser with default value " & $UAC_PROMPT_FOR_CREDENTIALS_SECURE_DESKTOP & " successfully.")
	Else
		logMessage("  [X] Set ConsentPromptBehaviorUser with default value failed")
	EndIf

;~ #################

	Local $status = _UAC_SetEnableInstallerDetection()

	If $status = 1 Then
		logMessage("  [OK] Set EnableInstallerDetection with default value " & $UAC_DISABLED & " successfully.")
	Else
		logMessage("  [X] Set EnableInstallerDetection with default value failed")
	EndIf

;~ #################

	Local $status = _UAC_SetEnableLUA()

	If $status = 1 Then
		logMessage("  [OK] Set EnableLUA with default value " & $UAC_ENABLED & " successfully.")
	Else
		logMessage("  [X] Set EnableLUA with default value failed")
	EndIf

;~ #################

	Local $status = _UAC_SetEnableSecureUIAPaths()

	If $status = 1 Then
		logMessage("  [OK] Set EnableSecureUIAPaths with default value " & $UAC_ENABLED & " successfully.")
	Else
		logMessage("  [X] Set EnableSecureUIAPaths with default value failed")
	EndIf

;~ #################

	Local $status = _UAC_SetEnableUIADesktopToggle()

	If $status = 1 Then
		logMessage("  [OK] Set EnableUIADesktopToggle with default value " & $UAC_DISABLED & " successfully.")
	Else
		logMessage("  [X] Set EnableUIADesktopToggle with default value failed")
	EndIf

;~ #################

	Local $status = _UAC_SetEnableVirtualization()

	If $status = 1 Then
		logMessage("  [OK] Set EnableVirtualization with default value " & $UAC_ENABLED & " successfully.")
	Else
		logMessage("  [X] Set EnableVirtualization with default value failed")
	EndIf

;~ #################

	Local $status = _UAC_SetFilterAdministratorToken()

	If $status = 1 Then
		logMessage("  [OK] Set FilterAdministratorToken with default value " & $UAC_DISABLED & " successfully.")
	Else
		logMessage("  [X] Set FilterAdministratorToken with default value failed")
	EndIf

;~ #################

	Local $status = _UAC_SetPromptOnSecureDesktop()

	If $status = 1 Then
		logMessage("  [OK] Set PromptOnSecureDesktop with default value " & $UAC_ENABLED & " successfully.")
	Else
		logMessage("  [X] Set PromptOnSecureDesktop with default value failed")
	EndIf

;~ #################

	Local $status = _UAC_SetValidateAdminCodeSignatures()

	If $status = 1 Then
		logMessage("  [OK] Set ValidateAdminCodeSignatures with default value " & $UAC_DISABLED & " successfully.")
	Else
		logMessage("  [X] Set ValidateAdminCodeSignatures with default value failed")
	EndIf

EndFunc   ;==>RestaureUACByDefault


Func KpRemover()
	Init()

	If GUICtrlRead($BackupRegistry) = $GUI_CHECKED Then
		CreateBackupRegistry()
	EndIf

	ProgressBarUpdate()

	If GUICtrlRead($RestoreUAC) = $GUI_CHECKED Then
		RestaureUACByDefault()
	EndIf

	ProgressBarUpdate()

	If GUICtrlRead($RemoveRP) = $GUI_CHECKED Then
		ClearRestorePoint()
	EndIf

	ProgressBarUpdate()

	If GUICtrlRead($CreateRP) = $GUI_CHECKED Then
		CreateRestorePoint()
	EndIf

	ProgressBarUpdate()

	MsgBox(0, "Finish", "All opérations are finish")
EndFunc   ;==>KpRemover
