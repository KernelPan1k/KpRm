#Region ;**** Directives created by AutoIt3Wrapper_GUI ****
#AutoIt3Wrapper_Icon=assets\bug.ico
#AutoIt3Wrapper_Outfile=kpRm.exe
#AutoIt3Wrapper_Res_Description=Remove tools
#AutoIt3Wrapper_Res_Fileversion=0.1.0.0
#AutoIt3Wrapper_Res_ProductName=KpRm
#AutoIt3Wrapper_Res_ProductVersion=0.1
#AutoIt3Wrapper_Res_CompanyName=kernel-panik
#AutoIt3Wrapper_Res_requestedExecutionLevel=requireAdministrator
#AutoIt3Wrapper_Res_Icon_Add=C:\Users\IEUser\Desktop\kpRemover\src\assets\bug.ico
#AutoIt3Wrapper_Res_File_Add=C:\Users\IEUser\Desktop\kpRemover\src\assets\bug.gif
#EndRegion ;**** Directives created by AutoIt3Wrapper_GUI ****
#include <ButtonConstants.au3>
#include <GUIConstantsEx.au3>
#include <StaticConstants.au3>
#include <WindowsConstants.au3>
#include <Date.au3>
#include <WinAPIShellEx.au3>
#include <SendMessage.au3>
#include <Array.au3>

Local Const $codeFR[6] = ["040C", "080C", "0C0C", "100C", "140C", "180C"]

If _ArraySearch($codeFR, @MUILang) <> 1 Then
	#include "locales\fr.au3"
Else
	#include "locales\en.au3"
EndIf

#include "lib\UAC.au3"
#include "lib\SystemRestore.au3"
#include "include\utils.au3"
#include "include\progress_bar.au3"
#include "include\restore_points.au3"
#include "include\registry_backup.au3"
#include "include\restore_uac.au3"
#include "include\restore_system_settings.au3"
#include "include\tools_import.au3"

#Region ### START Koda GUI section ### Form=C:\Users\IEUser\Desktop\kpRemover\gui\Form1.kxf

FileInstall("C:\Users\IEUser\Desktop\kpRemover\src\assets\bug.gif", @TempDir & "\kprm-logo.gif")

Global Const $ProgramName = "KpRm"

Local Const $MainWindow = GUICreate($ProgramName, 449, 195, 202, 112)
Local Const $Group1 = GUICtrlCreateGroup("Actions", 8, 8, 337, 153)
Local Const $RemoveTools = GUICtrlCreateCheckbox($lDeleteTools, 16, 40, 129, 17)
Local Const $RemoveRP = GUICtrlCreateCheckbox($lDeleteSystemRestorePoints, 16, 80, 105, 17)
Local Const $CreateRP = GUICtrlCreateCheckbox($lCreateRestorePoint, 16, 120, 97, 17)
Local Const $BackupRegistry = GUICtrlCreateCheckbox($lSaveRegistry, 192, 40, 137, 17)
Local Const $RestoreUAC = GUICtrlCreateCheckbox($lRestoreUAC, 192, 80, 137, 17)
Local Const $RestoreSystemSettings = GUICtrlCreateCheckbox($lRestoreSettings, 192, 120, 137, 17)
Global Const $ProgressBar = GUICtrlCreateProgress(8, 170, 428, 17)

GUICtrlCreateGroup("", -99, -99, 1, 1)

Local Const $Pic1 = GUICtrlCreatePic(@TempDir & "\kprm-logo.gif", 360, 16, 76, 76)
Local Const $RunKp = GUICtrlCreateButton($lRun, 360, 120, 75, 40)

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
	FileWrite(@DesktopDir & "\kp-remover.txt", "#################################################################################################################" & @CRLF & @CRLF)
	FileWrite(@DesktopDir & "\kp-remover.txt", "# Run at " & _Now() & @CRLF)
	FileWrite(@DesktopDir & "\kp-remover.txt", "# Run by " & @UserName & " in " & @ComputerName & @CRLF)
	FileWrite(@DesktopDir & "\kp-remover.txt", "# Launch fom " & @WorkingDir & @CRLF)
	ProgressBarInit()
EndFunc   ;==>Init

Func KpRemover()
	Init()

	ProgressBarUpdate()

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

	GUICtrlSetData($ProgressBar, 100)
	MsgBox(64, "OK", $lFinish)
	Exit
EndFunc   ;==>KpRemover
