Global $oToolsCpt = ObjCreate("Scripting.Dictionary")

Local Const $aAllToolsList[91] = [ _
		"AdliceDiag", _
		"AdsFix", _
		"AdwCleaner", _
		"AHK_NavScan", _
		"AlphaDecrypter", _
		"AswMBR", _
		"AuroraDecrypter", _
		"Avast Decryptor Cryptomix", _
		"Avenger", _
		"BlitzBlank", _
		"BitKangarooDecrypter", _
		"BitStakDecrypter", _
		"BTCWareDecrypter", _
		"Catchme", _
		"Check Browsers LNK", _
		"CKScanner", _
		"Clean_DNS", _
		"ClearLNK", _
		"CMD_Command", _
		"Combofix", _
		"Crypt38Decrypter", _
		"CryptoSearch", _
		"DDS", _
		"DCryDecrypter", _
		"Decrypt CryptON", _
		"Defogger", _
		"ESET Online Scanner", _
		"FilesLockerDecrypter", _
		"FixExec", _
		"FixPurge", _
		"FRST", _
		"FSS", _
		"g3n-h@ckm@n tools", _
		"GetSystemInfo", _
		"GhostCryptDecrypter", _
		"GibonDecrypter", _
		"Grantperms", _
		"HiddenTearDecrypter", _
		"Hosts-perm", _
		"InsaneCryptDecrypter", _
		"JavaRa", _
		"Junkware Removal Tool", _
		"JigSawDecrypter", _
		"ListCWall", _
		"ListParts", _
		"LogonFix", _
		"Malwarebytes Anti-Rootkit", _
		"MiniregTool", _
		"Minitoolbox", _
		"MirCopDecrypter", _
		"OTL", _
		"OTM", _
		"PowerLockyDecrypter", _
		"Pre_Scan", _
		"ProcessClose", _
		"QuickDiag", _
		"Rakhni Decryptor", _
		"Rannoh Decryptor", _
		"RansomNoteCleaner", _
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
		"Shortcut Cleaner", _
		"StrikedDecrypter", _
		"StupidDecrypter", _
		"Symantec Kovter Removal Tool", _
		"Systemlook", _
		"TDSSKiller", _
		"ToolsDiag", _
		"UnHide", _
		"USB File Resc", _
		"USBFix", _
		"Unlock92Decrypter", _
		"UnZacMe", _
		"WinCHK", _
		"WinUpdatefix", _
		"ZHP Tools", _
		"ZHPCleaner", _
		"ZHPDiag", _
		"ZHPFix", _
		"ZHPLite", _
		"Zoek"]

For $ti = 0 To UBound($aAllToolsList) - 1
	Local $oToolsValue = ObjCreate("Scripting.Dictionary")
	Local $oToolsValueKey = ObjCreate("Scripting.Dictionary")
	Local $oToolsValueFile = ObjCreate("Scripting.Dictionary")
	Local $oToolsValueUninstall = ObjCreate("Scripting.Dictionary")
	Local $oToolsValueProcess = ObjCreate("Scripting.Dictionary")

	$oToolsValue.add("key", $oToolsValueKey)
	$oToolsValue.add("element", $oToolsValueFile)
	$oToolsValue.add("uninstall", $oToolsValueUninstall)
	$oToolsValue.add("process", $oToolsValueProcess)
	$oToolsCpt.add($aAllToolsList[$ti], $oToolsValue)
Next

Global $aKPRemoveProcessList[1][3] = [[Null, Null, Null]]

Global $aKPRemoveDesktopList[1][5] = [[Null, Null, Null, Null, Null]]
Global $aKPRemoveDesktopCommonList[1][5] = [[Null, Null, Null, Null, Null]]
Global $aKPRemoveDownloadList[1][5] = [[Null, Null, Null, Null, Null]]

Global $aKPRemoveProgramFilesList[1][5] = [[Null, Null, Null, Null, Null]] ; C:\Program Files...

Global $aKPRemoveHomeDriveList[1][5] = [[Null, Null, Null, Null, Null]] ; C:\

Global $aKPRemoveSoftwareKeyList[1][2] = [[Null, Null]]

Global $aKPRemoveScheduleTasksList[1][2] = [[Null, Null]]
Global $aKPRemoveSearchRegistryKeyStringsList[1][4] = [[Null, Null, Null, Null]]

Global $aKPRemoveAppDataCommonList[1][5] = [[Null, Null, Null, Null, Null]] ; C:\ProgramData
Global $aKPRemoveAppDataList[1][5] = [[Null, Null, Null, Null, Null]] ; C:\Users\IEUser\AppData\Roaming
Global $aKPRemoveAppDataLocalList[1][5] = [[Null, Null, Null, Null, Null]] ; C:\Users\IEUser\AppData\Local

Global $aKPRemoveAppDataCommonStartMenuFolderList[1][5] = [[Null, Null, Null, Null, Null]] ; RemoveFolder(@AppDataCommonDir & "\Microsoft\Windows\Start Menu\Programs\RogueKiller")

Global $aKPRemoveWindowsFolderList[1][5] = [[Null, Null, Null, Null, Null]] ; RemoveFolder(C:\Windows)

Global $aKPUninstallNormallyList[1][3] = [[Null, Null, Null]]

Global $aKPRemoveRegistryKeysList[1][3] = [[Null, Null, Null]]

Global $aKPCleanDirectoryContentList[1][4] = [[Null, Null, Null, Null]]

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
#include "tools/ahk_navscan.au3"
#include "tools/avast_decryptor_cryptomix.au3"
#include "tools/decrypt_crypton.au3"
#include "tools/rakhni_decryptor.au3"
#include "tools/rannoh_decryptor.au3"
#include "tools/list_cwall.au3"
#include "tools/hosts-perm.au3"
#include "tools/jrt.au3"
#include "tools/sc-cleaner.au3"
#include "tools/unhide.au3"
#include "tools/fixexec.au3"
#include "tools/pre_scan.au3"
#include "tools/unzacme.au3"
#include "tools/symantec_kovter_removal_tool.au3"
#include "tools/check-browsers-lnk.au3"
#include "tools/clearlnk.au3"
#include "tools/processclose.au3"
#include "tools/roguekiller_cmd.au3"
#include "tools/usb-file-resc.au3"
#include "tools/clean_dns.au3"
#include "tools/ransom_note_cleaner.au3"
#include "tools/ghost_crypt_decrypter.au3"
#include "tools/jigsaw_decrypter.au3"
#include "tools/crypto_search.au3"
#include "tools/crypt38_decrypter.au3"
#include "tools/power_locky_decrypter.au3"
#include "tools/insane_crypt_decrypter.au3"
#include "tools/btc_ware_decrypter.au3"
#include "tools/alpha_decrypter.au3"
#include "tools/hidden_tear_decrypter.au3"
#include "tools/stupid_decrypter.au3"
#include "tools/gibon_decrypter.au3"
#include "tools/aurora_decrypter.au3"
#include "tools/files_locker_decrypter.au3"
#include "tools/dcry_decrypter.au3"
#include "tools/striked_decrypter.au3"
#include "tools/unlock92_decrypter.au3"
#include "tools/bit_stak_decrypter.au3"
#include "tools/bit_kangaroo_decrypter.au3"
#include "tools/mir_cop_decrypter.au3"
#include "tools/catchme.au3"
#include "tools/fix_purge.au3"
#include "tools/get_system_info.au3"

Func RunRemoveTools($bRetry = False)
	If $bRetry = True Then
		LogMessage(@CRLF & "- Search Tools -" & @CRLF)
	EndIf

	RemoveAllProcess($aKPRemoveProcessList)
	ProgressBarUpdate()

	UninstallNormally($aKPUninstallNormallyList)
	ProgressBarUpdate()

	RemoveScheduleTask($aKPRemoveScheduleTasksList)
	ProgressBarUpdate()

	RemoveAllFileFromWithMaxDepth(@DesktopDir, $aKPRemoveDesktopList)
	ProgressBarUpdate()

	RemoveAllFileFrom(@DesktopCommonDir, $aKPRemoveDesktopCommonList)
	ProgressBarUpdate()

	If FileExists(@UserProfileDir & "\Downloads") Then
		RemoveAllFileFromWithMaxDepth(@UserProfileDir & "\Downloads", $aKPRemoveDownloadList)
		ProgressBarUpdate()
	Else
		ProgressBarUpdate()
	EndIf

	RemoveAllProgramFilesDir($aKPRemoveProgramFilesList)
	ProgressBarUpdate()

	RemoveAllFileFrom(@HomeDrive, $aKPRemoveHomeDriveList)
	ProgressBarUpdate()

	RemoveAllFileFrom(@AppDataDir, $aKPRemoveAppDataList)
	ProgressBarUpdate()

	RemoveAllFileFrom(@AppDataCommonDir, $aKPRemoveAppDataCommonList)
	ProgressBarUpdate()

	RemoveAllFileFrom(@LocalAppDataDir, $aKPRemoveAppDataLocalList)
	ProgressBarUpdate()

	RemoveAllFileFrom(@WindowsDir, $aKPRemoveWindowsFolderList)
	ProgressBarUpdate()

	RemoveAllSoftwareKeyList($aKPRemoveSoftwareKeyList)
	ProgressBarUpdate()

	RemoveAllRegistryKeys($aKPRemoveRegistryKeysList)
	ProgressBarUpdate()

	RemoveUninstallStringWithSearch($aKPRemoveSearchRegistryKeyStringsList)
	ProgressBarUpdate()

	RemoveAllFileFrom(@AppDataCommonDir & "\Microsoft\Windows\Start Menu\Programs", $aKPRemoveAppDataCommonStartMenuFolderList)
	ProgressBarUpdate()

	CleanDirectoryContent($aKPCleanDirectoryContentList)
	ProgressBarUpdate()

	If $bRetry = True Then
		Local $bHasFoundTools = False
		Local Const $aToolCptSubKeys[4] = ["process", "uninstall", "element", "key"]
		Local Const $sMessageZHP = "Warning, folder " & @AppDataDir & "\ZHP exists and contains the quarantines of the ZHP tools. At the request of the publisher (Nicolas Coolman) this folder is not deleted. "
		Local $bToolZhpQuantineDisplay = False
		Local Const $bToolZhpQuantineExist = IsDir(@AppDataDir & "\ZHP")

		For $sToolsCptKey In $oToolsCpt
			Local $oToolCptTool = $oToolsCpt.Item($sToolsCptKey)
			Local $bToolExistDisplayMessage = False

			For $sToolCptSubKeyI = 0 To UBound($aToolCptSubKeys) - 1
				Local $sToolCptSubKey = $aToolCptSubKeys[$sToolCptSubKeyI]
				Local $oToolCptSubTool = $oToolCptTool.Item($sToolCptSubKey)
				Local $oToolCptSubToolKeys = $oToolCptSubTool.Keys

				If UBound($oToolCptSubToolKeys) > 0 Then
					If $bToolExistDisplayMessage = False Then
						$bToolExistDisplayMessage = True
						$bHasFoundTools = True
						LogMessage(@CRLF & "  ## " & $sToolsCptKey & " found")
					EndIf

					For $oToolCptSubToolKeyI = 0 To UBound($oToolCptSubToolKeys) - 1
						Local $oToolCptSubToolKey = $oToolCptSubToolKeys[$oToolCptSubToolKeyI]
						Local $oToolCptSubToolVal = $oToolCptSubTool.Item($oToolCptSubToolKey)
						CheckIfExist($sToolCptSubKey, $oToolCptSubToolKey, $oToolCptSubToolVal)
					Next

					If $sToolsCptKey = "ZHP Tools" And $bToolZhpQuantineExist = True And $bToolZhpQuantineDisplay = False Then
						LogMessage("     [!] " & $sMessageZHP)
						$bToolZhpQuantineDisplay = True
					EndIf
				EndIf
			Next
		Next

		If $bToolZhpQuantineDisplay = False And $bToolZhpQuantineExist = True Then
			LogMessage(@CRLF & "  ## " & "ZHP Tools" & " found")
			LogMessage("     [!] " & $sMessageZHP)
		ElseIf $bHasFoundTools = False Then
			LogMessage("  [I] No tools found")
		EndIf
	EndIf

	ProgressBarUpdate()


EndFunc   ;==>RunRemoveTools
