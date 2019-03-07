#include <ButtonConstants.au3>
#include <GUIConstantsEx.au3>
#include <StaticConstants.au3>
#include <WindowsConstants.au3>
#include <Date.au3>
#include "SystemRestore.au3"
#Region ### START Koda GUI section ### Form=C:\Users\IEUser\Desktop\kpRemover\Form1.kxf

$ProgramName = "KpRemover"

$MainWindow = GUICreate($ProgramName, 449, 175, 202, 112)
$Group1 = GUICtrlCreateGroup("Actions", 8, 8, 337, 153)

$RemoveTools = GUICtrlCreateCheckbox("Suppression des outils", 16, 40, 129, 17)
$RemoveRP = GUICtrlCreateCheckbox("Supprimer les PR", 16, 80, 105, 17)
$CreateRP = GUICtrlCreateCheckbox("Nouveau PR", 16, 120, 97, 17)
$BackupRegistry = GUICtrlCreateCheckbox("Sauvegarde du registre", 192, 40, 137, 17)

GUICtrlCreateGroup("", -99, -99, 1, 1)
$Pic1 = GUICtrlCreatePic("C:\Users\IEUser\Desktop\kpRemover\bug.gif", 360, 16, 76, 76)

$RunKp = GUICtrlCreateButton("Button1", 360, 120, 75, 41)
GUISetState(@SW_SHOW)

#EndRegion ### END Koda GUI section ###

While 1
    Sleep(1000)
    
	$nMsg = GUIGetMsg()

	Switch $nMsg
		Case $GUI_EVENT_CLOSE
			Exit
		Case $RunKp
			kpRemover()
	EndSwitch
WEnd

Func Init()
	FileWrite( @DesktopDir & "\kp-remover.txt", "##########################################" & @CRLF)
	FileWrite( @DesktopDir & "\kp-remover.txt", "Run at " & _NowTime() & " by " &  @UserName  & " from " & @WorkingDir  & @CRLF)
EndFunc

Func logMessage($message)
	FileWrite( @DesktopDir & "\kp-remover.txt", "- " & $message & @CRLF)
EndFunc

Func ClearRestorePoint()
	$message = "[I] ************* clear restore point **************"
	logMessage($message)

	$arrEnum = _SR_EnumRestorePoints()
	$nbrRestorePoint = $arrEnum[0][0]
	$message = "[I] " & $nbrRestorePoint & " restore point found"
	logMessage($message)

	$nbrRemovedRestorePoint = _SR_RemoveAllRestorePoints()
	$message = "[I] " & $nbrRemovedRestorePoint & " restore point deleted"
	logMessage($message)

	If $nbrRemovedRestorePoint = $nbrRestorePoint AND $nbrRemovedRestorePoint <> 0 Then
		$message = "[OK] all restore point are deleted"
		logMessage($message)
	EndIf
EndFunc

Func CreateRestorePoint()
	$message = "[I] ************* create restore point **************"
	logMessage($message)

	$arrEnum = _SR_EnumRestorePoints()
	$nbrRestorePoint = $arrEnum[0][0]
	$message = "[I] " & $nbrRestorePoint & " restore point found"
	logMessage($message)

    $createdPointStatus = _SR_CreateRestorePoint($ProgramName)

    Do
       Sleep(3000)
    Until $createdPointStatus = 0 or $createdPointStatus = 1

    If $pid = 0 Then
      logMessage("[X] Failed to create System Restore Point!")
    ElseIf $pid = 1 Then
       logMessage("[OK] System Restore Point created successfully.")
    EndIf

EndFunc

Func KpRemover()
	Init()
	If GUICtrlRead($RemoveRP) = $GUI_CHECKED Then
		ClearRestorePoint()
	EndIf

	If GUICtrlRead($CreateRP) = $GUI_CHECKED Then
    	CreateRestorePoint()
    EndIf
EndFunc
