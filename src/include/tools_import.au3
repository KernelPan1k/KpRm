Global $ToolsCpt = ObjCreate("Scripting.Dictionary")

Local Const $allToolsList[33] = [ _
		"frst", _
		"zhpdiag", _
		"zhpcleaner", _
		"zhpfix", _
		"mbar", _
		"roguekiller", _
		"usbfix", _
		"adwcleaner", _
		"adsfix", _
		"aswmbr", _
		"fss", _
		"toolsdiag", _
		"scanrapide", _
		"otl", _
		"otm", _
		"listparts", _
		"minitoolbox", _
		"miniregtool", _
		"zhp", _
		"combofix", _
		"regtoolexport", _
		"tdsskiller", _
		"winupdatefix", _
		"rsthosts", _
		"winchk", _
		"avenger", _
		"blitzblank", _
		"zoek", _
		"remediate-vbs-worm", _
		"ckscanner", _
		"quickdiag", _
		"adlicediag", _
		"grantperms"]

For $ti = 0 To UBound($allToolsList) - 1
	Local $toolsValue[2] = [0, ""]
	$ToolsCpt.add($allToolsList[$ti], $toolsValue)
Next

Global $KPRemoveProcessList[1][2] = [[Null, Null]]

Global $KPRemoveDesktopList[1][5] = [[Null, Null, Null, Null, Null]]
Global $KPRemoveDesktopCommonList[1][5] = [[Null, Null, Null, Null, Null]]
Global $KPRemoveDownloadList[1][5] = [[Null, Null, Null, Null, Null]]

Global $KPRemoveProgramFilesList[1][5] = [[Null, Null, Null, Null, Null]] ; C:\Program Files...

Global $KPRemoveHomeDriveList[1][5] = [[Null, Null, Null, Null, Null]] ; C:\

Global $KPRemoveSoftwareKeyList[1][2] = [[Null, Null]]

Global $KPRemoveScheduleTasksList[1][2] = [[Null, Null]]
Global $KPRemoveSearchRegistryKeyStringsList[1][4] = [[Null, Null, Null, Null]]

Global $KPRemoveAppDataCommonList[1][5] = [[Null, Null, Null, Null, Null]] ; C:\ProgramData
Global $KPRemoveAppDataList[1][5] = [[Null, Null, Null, Null, Null]] ; C:\Users\IEUser\AppData\Roaming
Global $KPRemoveAppDataLocalList[1][5] = [[Null, Null, Null, Null, Null]] ; C:\Users\IEUser\AppData\Local

Global $KPRemoveAppDataCommonStartMenuFolderList[1][5] = [[Null, Null, Null, Null, Null]] ; RemoveFolder(@AppDataCommonDir & "\Microsoft\Windows\Start Menu\Programs\RogueKiller")

Global $KPUninstallNormalyList[1][3] = [[Null, Null, Null]]


#include-once
#include "tools_remove.au3"
#include "tools/frst.au3"
#include "tools/zhp.au3"
#include "tools/zhpdiag.au3"
#include "tools/zhpfix.au3"
#include "tools/mbar.au3"
#include "tools/roguekiller.au3"
#include "tools/adwcleaner.au3"
#include "tools/zhpcleaner.au3"
#include "tools/usbfix.au3"
#include "tools/adsfix.au3"
#include "tools/aswmbr.au3"
#include "tools/fss.au3"
#include "tools/toolsdiag.au3"
#include "tools/scanrapide.au3"
#include "tools/otl.au3"
#include "tools/otm.au3"
#include "tools/listparts.au3"
#include "tools/minitoolbox.au3"
#include "tools/miniregtool.au3"
#include "tools/grantperms.au3"
#include "tools/combofix.au3"
#include "tools/regtoolexport.au3"
#include "tools/tdsskiller.au3"
#include "tools/winupdatefix.au3"
#include "tools/rsthosts.au3"
#include "tools/winchk.au3"
#include "tools/avenger.au3"
#include "tools/blitzblank.au3"
#include "tools/zoek.au3"
#include "tools/remediate-vbs-worm.au3"
#include "tools/ckscanner.au3"
#include "tools/quickdiag.au3"
#include "tools/adlice_diag.au3"
#include "tools/custom_end.au3"

Func RunRemoveTools($retry = False)
	If $retry = True Then
		logMessage(@CRLF & "- Search Tools -" & @CRLF)
	EndIf

	RemoveAllProcess($KPRemoveProcessList)
	ProgressBarUpdate()

	UninstallNormaly($KPUninstallNormalyList)
	ProgressBarUpdate()

	RemoveScheduleTask($KPRemoveScheduleTasksList)
	ProgressBarUpdate()

	RemoveAllFileFrom(@DesktopDir, $KPRemoveDesktopList)
	ProgressBarUpdate()

	RemoveAllFileFrom(@DesktopCommonDir, $KPRemoveDesktopCommonList)
	ProgressBarUpdate()

	If FileExists(@UserProfileDir & "\Downloads") Then
		RemoveAllFileFrom(@UserProfileDir & "\Downloads", $KPRemoveDownloadList)
		ProgressBarUpdate()
	Else
		ProgressBarUpdate()
	EndIf

	RemoveAllProgramFilesDir($KPRemoveProgramFilesList)
	ProgressBarUpdate()

	RemoveAllFileFrom(@HomeDrive, $KPRemoveHomeDriveList)
	ProgressBarUpdate()

	RemoveAllFileFrom(@AppDataDir, $KPRemoveAppDataList)
	ProgressBarUpdate()

	RemoveAllFileFrom(@AppDataCommonDir, $KPRemoveAppDataCommonList)
	ProgressBarUpdate()

	RemoveAllFileFrom(@LocalAppDataDir, $KPRemoveAppDataLocalList)
	ProgressBarUpdate()

	RemoveAllSoftwareKeyList($KPRemoveSoftwareKeyList)
	ProgressBarUpdate()

	RemoveUninstallStringWithSearch($KPRemoveSearchRegistryKeyStringsList)
	ProgressBarUpdate()

	RemoveAllFileFrom(@AppDataCommonDir & "\Microsoft\Windows\Start Menu\Programs", $KPRemoveAppDataCommonStartMenuFolderList)
	ProgressBarUpdate()

	If $retry = True Then
		CustomEnd()

		ProgressBarUpdate()

		For $ti = 0 To UBound($allToolsList) - 1
			Local $toolsValue = $ToolsCpt.Item($allToolsList[$ti])

			If $toolsValue[0] > 0 Then
				If $toolsValue[1] = "" Then
					logMessage(@CRLF & "  [OK] " & StringUpper($allToolsList[$ti]) & " has been successfully deleted")
				Else
					logMessage(@CRLF & "  [X] " & StringUpper($allToolsList[$ti]) & " was found but there were errors :")
					logMessage($toolsValue[1])
				EndIf
			EndIf
		Next
	Else
		ProgressBarUpdate()
	EndIf

	ProgressBarUpdate()


EndFunc   ;==>RunRemoveTools
