#Region ;**** Directives created by AutoIt3Wrapper_GUI ****
#AutoIt3Wrapper_Res_File_Add=C:\Users\IEUser\Desktop\kpRemover\assets\bug.gif
#EndRegion ;**** Directives created by AutoIt3Wrapper_GUI ****
#include <ButtonConstants.au3>
#include <GUIConstantsEx.au3>
#include <StaticConstants.au3>
#include <WindowsConstants.au3>
#include <Date.au3>
#include "include\utils.au3"
#include "include\progress_bar.au3"
#include "include\restore_points.au3"
#include "include\registry_backup.au3"
#include "include\restore_uac.au3"
#include "include\restore_system_settings.au3"
#include "include\tools_import.au3"

#Region ### START Koda GUI section ### Form=C:\Users\IEUser\Desktop\kpRemover\gui\Form1.kxf

FileInstall("C:\Users\IEUser\Desktop\kpRemover\assets\bug.gif", @TempDir & "\iwgefiwefecbeifbibi.gif")

Global Const $ProgramName = "KpRm"

Local Const $MainWindow = GUICreate($ProgramName, 449, 175, 202, 112)
Local Const $Group1 = GUICtrlCreateGroup("Actions", 8, 8, 337, 153)
Local Const $RemoveTools = GUICtrlCreateCheckbox("Suppression des outils", 16, 40, 129, 17)
Local Const $RemoveRP = GUICtrlCreateCheckbox("Supprimer les PR", 16, 80, 105, 17)
Local Const $CreateRP = GUICtrlCreateCheckbox("Nouveau PR", 16, 120, 97, 17)
Local Const $BackupRegistry = GUICtrlCreateCheckbox("Sauvegarde du registre", 192, 40, 137, 17)
Local Const $RestoreUAC = GUICtrlCreateCheckbox("Restaurer UAC", 192, 80, 137, 17)
Local Const $RestoreSystemSettings = GUICtrlCreateCheckbox("Restaurer les paramètres système", 192, 120, 137, 17)

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

Func Init()
	FileWrite(@DesktopDir & "\kp-remover.txt", "##########################################" & @CRLF)
	FileWrite(@DesktopDir & "\kp-remover.txt", "Run at " & _NowTime() & " by " & @UserName & " from " & @WorkingDir & @CRLF)
	ProgressBarInit()
EndFunc   ;==>Init

Func KpRemover()
	Init()

	If GUICtrlRead($BackupRegistry) = $GUI_CHECKED Then
		CreateBackupRegistry()
	EndIf

	ProgressBarUpdate()

	If GUICtrlRead($RestoreSystemSettings) = $GUI_CHECKED Then
		RestoreSystemSettingsByDefault()
	EndIf

	ProgressBarUpdate()

	If GUICtrlRead($RestoreUAC) = $GUI_CHECKED Then
		RestaureUACByDefault()
	EndIf

	ProgressBarUpdate()

	If GUICtrlRead($RemoveTools) = $GUI_CHECKED Then
		RunRemoveTools()
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
EndFunc   ;==>KpRemover
