Global $oToolsCpt = ObjCreate("Scripting.Dictionary")


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
	$oToolsCpt.add($aAllToolsList[$ti], $oTosValue)
Next

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
