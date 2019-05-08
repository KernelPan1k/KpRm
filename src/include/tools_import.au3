Global $ToolsCpt = ObjCreate("Scripting.Dictionary")

Local Const $allToolsList[49] = [ _
		"AdliceDiag", _
		"AdsFix", _
		"AdwCleaner", _
		"AswMBR", _
		"Avenger", _
		"BlitzBlank", _
		"CKScanner", _
		"CMD_Command", _
		"Combofix", _
		"DDS", _
		"Defogger", _
		"ESET Online Scanner", _
		"FRST", _
		"FSS", _
		"g3n-h@ckm@n tools", _
		"Grantperms", _
		"JavaRa", _
		"ListParts", _
		"LogonFix", _
		"Malwarebytes tools", _
		"Malwarebytes Anti-Rootkit", _
		"MiniregTool", _
		"Minitoolbox", _
		"OTL", _
		"OTM", _
		"QuickDiag", _
		"RegtoolExport", _
		"Remediate VBS Worm", _
		"Report_CHKDSK", _
		"Rkill", _
		"RogueKiller", _
		"RstAssociations", _
		"RstHosts", _
		"ScanRapide", _
		"SEAF", _
		"SecurityCheck", _
		"SFT", _
		"Systemlook", _
		"TDSSKiller", _
		"ToolsDiag", _
		"USBFix", _
		"WinCHK", _
		"WinUpdatefix", _
		"ZHP Tools", _
		"ZHPCleaner", _
		"ZHPDiag", _
		"ZHPFix", _
		"ZHPLite", _
		"Zoek"]

For $ti = 0 To UBound($allToolsList) - 1
	Local $toolsValue = ObjCreate("Scripting.Dictionary")
	Local $toolsValueKey = ObjCreate("Scripting.Dictionary")
	Local $toolsValueFile = ObjCreate("Scripting.Dictionary")
	Local $toolsValueUninstall = ObjCreate("Scripting.Dictionary")
	Local $toolsValueProcess = ObjCreate("Scripting.Dictionary")

	$toolsValue.add("key", $toolsValueKey)
	$toolsValue.add("element", $toolsValueFile)
	$toolsValue.add("uninstall", $toolsValueUninstall)
	$toolsValue.add("process", $toolsValueProcess)

	$ToolsCpt.add($allToolsList[$ti], $toolsValue)
Next

Global $KPRemoveProcessList[1][3] = [[Null, Null, Null]]

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

Global $KPRemoveWindowsFolderList[1][5] = [[Null, Null, Null, Null, Null]] ; RemoveFolder(C:\Windows)

Global $KPUninstallNormalyList[1][3] = [[Null, Null, Null]]

Global $KPRemoveRegistryKeysList[1][3] = [[Null, Null, Null]]

Global $KPCleanDirectoryContentList[1][4] = [[Null, Null, Null, Null]]

#include-once
#include "tools_remove.au3"
#include "tools/frst.au3"
#include "tools/zhp.au3"
#include "tools/zhpdiag.au3"
#include "tools/zhpfix.au3"
#include "tools/zhplite.au3"
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
#include "tools/rstassociations.au3"
#include "tools/sft.au3"
#include "tools/logonfix.au3"
#include "tools/cmd-command.au3"
#include "tools/report_chkdsk.au3"
#include "tools/seaf.au3"
#include "tools/dds.au3"
#include "tools/defogger.au3"
#include "tools/javara.au3"
#include "tools/g3n-hackman.au3"
#include "tools/systemlook.au3"
#include "tools/eset_online_scanner.au3"
#include "tools/security_check.au3"
#include "tools/rkill.au3"

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

	RemoveAllFileFromWithMaxDepth(@DesktopDir, $KPRemoveDesktopList)
	ProgressBarUpdate()

	RemoveAllFileFrom(@DesktopCommonDir, $KPRemoveDesktopCommonList)
	ProgressBarUpdate()

	If FileExists(@UserProfileDir & "\Downloads") Then
		RemoveAllFileFromWithMaxDepth(@UserProfileDir & "\Downloads", $KPRemoveDownloadList)
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

	RemoveAllFileFrom(@WindowsDir, $KPRemoveWindowsFolderList)
	ProgressBarUpdate()

	RemoveAllSoftwareKeyList($KPRemoveSoftwareKeyList)
	ProgressBarUpdate()

	RemoveAllRegistryKeys($KPRemoveRegistryKeysList)
	ProgressBarUpdate()

	RemoveUninstallStringWithSearch($KPRemoveSearchRegistryKeyStringsList)
	ProgressBarUpdate()

	RemoveAllFileFrom(@AppDataCommonDir & "\Microsoft\Windows\Start Menu\Programs", $KPRemoveAppDataCommonStartMenuFolderList)
	ProgressBarUpdate()

	CleanDirectoryContent($KPCleanDirectoryContentList)
	ProgressBarUpdate()


	If $retry = True Then
		Local $hasFoundTools = False
		Local Const $ToolCptSubKeys[4] = ["process", "uninstall", "element", "key"]
		Local Const $messageZHP = "Warning, folder " & @AppDataDir & "\ZHP exists and contains the quarantines of the ZHP tools. At the request of the publisher (Nicolas Coolman) this folder is not deleted. "
		Local $ToolZhpQuantineDisplay = False
		Local Const $ToolZhpQuantineExist = IsDir(@AppDataDir & "\ZHP")

		For $ToolsCptKey In $ToolsCpt
			Local $toolCptTool = $ToolsCpt.Item($ToolsCptKey)
			Local $ToolExistDisplayMessage = False

			For $ToolCptSubKeyI = 0 To UBound($ToolCptSubKeys) - 1
				Local $ToolCptSubKey = $ToolCptSubKeys[$ToolCptSubKeyI]
				Local $ToolCptSubTool = $toolCptTool.Item($ToolCptSubKey)
				Local $ToolCptSubToolKeys = $ToolCptSubTool.Keys

				If UBound($ToolCptSubToolKeys) > 0 Then
					If $ToolExistDisplayMessage = False Then
						$ToolExistDisplayMessage = True
						$hasFoundTools = True
						logMessage(@CRLF & "  ## " & $ToolsCptKey & " found")
					EndIf

					For $ToolCptSubToolKeyI = 0 To UBound($ToolCptSubToolKeys) - 1
						Local $ToolCptSubToolKey = $ToolCptSubToolKeys[$ToolCptSubToolKeyI]
						Local $ToolCptSubToolVal = $ToolCptSubTool.Item($ToolCptSubToolKey)
						CheckIfExist($ToolCptSubKey, $ToolCptSubToolKey, $ToolCptSubToolVal)
					Next

					If $ToolsCptKey = "ZHP Tools" And $ToolZhpQuantineExist = True And $ToolZhpQuantineDisplay = False Then
						logMessage("     [!] " & $messageZHP)
						$ToolZhpQuantineDisplay = True
					EndIf
				EndIf
			Next
		Next

		If $ToolZhpQuantineDisplay = False And $ToolZhpQuantineExist = True Then
			logMessage(@CRLF & "  ## " & "ZHP Tools" & " found")
			logMessage("     [!] " & $messageZHP)
		ElseIf $hasFoundTools = False Then
			logMessage("  [I] No tools found")
		EndIf
	EndIf

	ProgressBarUpdate()


EndFunc   ;==>RunRemoveTools
