Global $ToolsCpt = ObjCreate("Scripting.Dictionary")

Local Const $allToolsList[21] = [ _
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
	"grantperms"]

For $ti = 0 To UBound($allToolsList) -1
	$ToolsCpt.add($allToolsList[$ti], 0)
Next

Global $KPRemoveProcessList[1][2] = [[Null, Null]]

Global $KPRemoveDesktopList[1][4] = [[Null, Null, Null, Null]]
Global $KPRemoveDesktopCommonList[1][4] = [[Null, Null, Null, Null]]
Global $KPRemoveDownloadList[1][4] = [[Null, Null, Null, Null]]

Global $KPRemoveProgramFilesList[1][4] = [[Null, Null, Null, Null]] ; C:\Program Files...

Global $KPRemoveHomeDriveList[1][4] = [[Null, Null]] ; C:\

Global $KPRemoveSoftwareKeyList[1][2] = [[Null, Null]]

Global $KPRemoveScheduleTasksList[1][2] = [[Null, Null]]
Global $KPRemoveSearchRegistryKeyStringsList[1][4] = [[Null, Null, Null, Null]]

Global $KPRemoveAppDataCommonList[1][4] = [[Null, Null, Null, Null]] ; C:\ProgramData
Global $KPRemoveAppDataList[1][4] = [[Null, Null, Null, Null]] ; C:\Users\IEUser\AppData\Roaming
Global $KPRemoveAppDataLocalList[1][4] = [[Null, Null, Null, Null]] ; C:\Users\IEUser\AppData\Local

Global $KPRemoveAppDataCommonStartMenuFolderList[1][4] = [[Null, Null, Null, Null]] ; RemoveFolder(@AppDataCommonDir & "\Microsoft\Windows\Start Menu\Programs\RogueKiller")

Global $KPUninstallNormalyList[1][3] = [[Null, Null, Null]]

#include-once
#include "tools_remove.au3"
#include "tools/frst.au3"
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

Func RunRemoveTools()
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

EndFunc   ;==>RunRemoveTools
