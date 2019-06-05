Global $oToolsCpt = ObjCreate("Scripting.Dictionary")

Local $aAllToolsList[0]
Local $aActionsFile = ["desktop", "desktopCommon","download","homeDrive","programFiles","appData","appDataCommon","appDataLocal","windowsFolder","appDataCommonStartMenuFolder"]

_XMLFileOpen("../config/tools.xml")

Func GetSwapOrder($sT)
	If _ArraySearch($aActionsFile, $sT) Then 
		Return ["type", "companyName", "pattern", "force"]
	ElseIf $sT == "uninstal" Then 
		Return ["folder", "binary"]
	ElseIf $sT == "task" Then 
		Return ["name"]
	ElseIf $sT == "softwareKey" Then 
		Return ["pattern"]
	ElseIf $sT == "registryKey" Then 
		Return ["key", "force"]
	ElseIf $sT == "searchRegistryKey" Then 
		Return ["key", "pattern", "value"]
	ElseIf $sT == "cleanDirectory" Then 
		Return ["path", "companyName, "force"]
	EndIf
EndFunc

Func Swap($sTn, $aK, $aV, $aOrder)
	Local $aResult[1] = [$sTn]

	For $i = 0 To UBound($ref) - 1
		For $c = 0 To UBound($aK) - 1
			If $ref[$i] = $aK[$c] Then
				_ArrayAdd($result, $aV[$c], 0, "£")
			EndIf
		Next
	Next

	Retrun $aResult
EndFunc   ;==>Swap

For $i = 1 To $aNodes[0]
	Local $sToolName = _XMLGetAttrib("/tools/tool[" & $i & "]", "name")
	_ArrayAdd($aAllToolsList, $sToolName)
	Local $oToolsValue = ObjCreate("Scripting.Dictionary")
	Local $oToolsValueKey = ObjCreate("Scripting.Dictionary")
	Local $oToolsValueFile = ObjCreate("Scripting.Dictionary")
	Local $oToolsValueUninstall = ObjCreate("Scripting.Dictionary")
	Local $oToolsValueProcess = ObjCreate("Scripting.Dictionary")

	$oToolsValue.add("key", $oToolsValueKey)
	$oToolsValue.add("element", $oToolsValueFile)
	$oToolsValue.add("uninstall", $oToolsValueUninstall)
	$oToolsValue.add("process", $oToolsValueProcess)
	$oToolsCpt.add($sToolName, $oTosValue)
Next


For $ti = 0 To UBound($aAllToolsList) - 1
	
Next

Func RunRemoveTools($bRetry = False)
	If $bRetry = True Then
		LogMessage(@CRLF & "- Search Tools -" & @CRLF)
	EndIf

	Local $aNodes = _XMLSelectNodes("/tools/tool")
	
	For $sAction In [_
		"process", _
		"uninstall", _
		"task", _
		"desktop", _
		"desktopCommon", _
		"download", _
		"programFile", _
		"homeDrive", _
		"appData", _
		"appDataCommon", _
		"appDataLocal", _
		"windowsFolder", _
		"softwareKey", _
		"registryKey", _
		"searchRegistryKey", _
		"appDataCommonStartMenuFolder", _
		"cleanDirectory"]
		
		Local $aOrder = GetSwapOrder($sTn)
		Local $aListTasks[1][Ubound($aOrder + 1)] = [[]]

		For $i = 1 To $aNodes[0]
			Local $sToolName = _XMLGetAttrib("/tools/tool[" & $i & "]", "name")

			_ArrayAdd($aAllToolsList, $sToolName)

			Local $aActions = _XMLSelectNodes("/tools/tool[" & $i & "]/*")

			For $c = 1 To $aActions[0]
				Local $type = $aActions[$c]
				
				If $type = $sAction Then
					Local $aName[1], $aValue[1]
					_XMLGetAllAttrib("/tools/tool[" & $i & "]/*[" & $c & "]", $aName, $aValue)
					Local $aCurrentTask = Swap($sToolName, $aName, $aValue, $aOrder)
					_ArrayAdd($aListTasks, $aCurrentTask)
				EndIf
			Next
		Next
		
		Switch $sAction
			Case "process"
				RemoveAllProcess($aListTasks)
			Case "uninstall"
				UninstallNormally($aListTasks)
			Case "task"
				RemoveScheduleTask($aListTasks)
			Case "desktop"
				RemoveAllFileFromWithMaxDepth(@DesktopDir, $aListTasks)
			Case "desktopCommon"
				RemoveAllFileFrom(@DesktopCommonDir, $aListTasks)
			Case "download"
				RemoveAllFileFromWithMaxDepth(@UserProfileDir & "\Downloads", $aListTasks)
			Case "programFile"
				RemoveAllProgramFilesDir($aListTasks)
			Case "homeDrive"
				RemoveAllFileFrom(@HomeDrive, $aListTasks)
			Case "appDataCommon"
				RemoveAllFileFrom(@AppDataCommonDir, $aListTasks)
			Case "appDataLocal"
				RemoveAllFileFrom(@LocalAppDataDir, $aListTasks)
			Case "windowsFolder"
				RemoveAllFileFrom(@WindowsDir, $aListTasks)
			Case "softwareKey"
				RemoveAllSoftwareKeyList($aListTasks)
			Case "registryKey"
				RemoveAllRegistryKeys($aListTasks)
			Case "searchRegistryKey"
				RemoveUninstallStringWithSearch($aListTasks)
			Case "appDataCommonStartMenuFolder"
				RemoveAllFileFrom(@AppDataCommonDir & "\Microsoft\Windows\Start Menu\Programs", $aListTasks)
			Case "cleanDirectory"
				CleanDirectoryContent($aListTasks)
		EndSwitch
			ProgressBarUpdate()
	Next

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
