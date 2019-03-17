Global $ToolsCpt = ObjCreate("Scripting.Dictionary")
$ToolsCpt.add("frst", 0)
$ToolsCpt.add("zhpdiag", 0)
$ToolsCpt.add("zhpcleaner", 0)
$ToolsCpt.add("zhpfix", 0)
$ToolsCpt.add("mbar", 0)
$ToolsCpt.add("roguekiller", 0)
$ToolsCpt.add("usbfix", 0)
$ToolsCpt.add("adwcleaner", 0)
$ToolsCpt.add("adsfix", 0)
$ToolsCpt.add("aswmbr", 0)
$ToolsCpt.add("fss", 0)
$ToolsCpt.add("toolsdiag", 0)
$ToolsCpt.add("scanrapide", 0)
$ToolsCpt.add("fake", 0)

Global $KPRemoveProcessList[1][2] = [[Null, Null]]

Global $KPRemoveDesktopList[1][3] = [[Null, Null, Null]]
Global $KPRemoveDesktopFolderList[1][2] = [[Null, Null]]
Global $KPRemoveDesktopCommonList[1][3] = [[Null, Null, Null]]

Global $KPRemoveDownloadList[1][3] = [[Null, Null, Null]]
Global $KPRemoveDownloadFolderList[1][2] = [[Null, Null]]

Global $KPRemoveProgramFilesList[1][2] = [[Null, Null]] ; C:\Program Files...

Global $KPRemoveHomeDriveList[1][2] = [[Null, Null]] ; C:\
Global $KPRemoveHomeDriveFileList[1][3] = [[Null, Null, Null]] ; C:\

Global $KPRemoveSoftwareKeyList[1][2] = [[Null, Null]]

Global $KPRemoveScheduleTasksList[1][2] = [[Null, Null]]
Global $KPRemoveSearchRegistryKeyStringsList[1][4] = [[Null, Null, Null, Null]]

Global $KPRemoveAppDataCommonDirList[1][2] = [[Null, Null]] ; C:\ProgramData
Global $KPRemoveAppDataDirList[1][2] = [[Null, Null]] ; C:\Users\IEUser\AppData\Roaming
Global $KPRemoveAppDataLoacalDirList[1][2] = [[Null, Null]] ; C:\Users\IEUser\AppData\Local

Global $KPRemoveAppDataCommonDirStartMenuFolderList[1][2] = [[Null, Null]] ; RemoveFolder(@AppDataCommonDir & "\Microsoft\Windows\Start Menu\Programs\RogueKiller")

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

LoadFRST()
LoadZHPDiag()
LoadZHPFix()
LoadZHPCleaner()
LoadCommonZHP()
LoadMBAR()
LoadRogueKiller()
LoadAdwcleaner()
LoadUSBFIX()
LoadADSFix()
LoadAswMbr()
LoadFSS()
LoadToolsDiag()
LoadScanRapide()

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

	RemoveAllDirFrom(@DesktopDir, $KPRemoveDesktopFolderList)
	ProgressBarUpdate()

	If FileExists(@UserProfileDir & "\Downloads") Then
		RemoveAllFileFrom(@UserProfileDir & "\Downloads", $KPRemoveDownloadList)
		ProgressBarUpdate()

		RemoveAllDirFrom(@UserProfileDir & "\Downloads", $KPRemoveDownloadFolderList)
		ProgressBarUpdate()
	Else
		ProgressBarUpdate()
		ProgressBarUpdate()
	EndIf

	RemoveAllProgramFilesDir($KPRemoveProgramFilesList)
	ProgressBarUpdate()

	RemoveAllDirFrom(@HomeDrive, $KPRemoveHomeDriveList)
	ProgressBarUpdate()

	RemoveAllFileFrom(@HomeDrive, $KPRemoveHomeDriveFileList)
	ProgressBarUpdate()

	RemoveAllDirFrom(@AppDataDir, $KPRemoveAppDataDirList)
	ProgressBarUpdate()

	RemoveAllDirFrom(@AppDataCommonDir, $KPRemoveAppDataCommonDirList)
	ProgressBarUpdate()

	RemoveAllDirFrom(@LocalAppDataDir, $KPRemoveAppDataLoacalDirList)
	ProgressBarUpdate()

	RemoveAllSoftwareKeyList($KPRemoveSoftwareKeyList)
	ProgressBarUpdate()

	RemoveUninstallStringWithSearch($KPRemoveSearchRegistryKeyStringsList)
	ProgressBarUpdate()

	RemoveAllDirFrom(@AppDataCommonDir & "\Microsoft\Windows\Start Menu\Programs", $KPRemoveAppDataCommonDirStartMenuFolderList)
	ProgressBarUpdate()

EndFunc   ;==>RunRemoveTools
