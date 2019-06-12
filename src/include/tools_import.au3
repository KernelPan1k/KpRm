#include "tools_remove.au3"

Global $oToolsCpt = ObjCreate("Scripting.Dictionary")
Local $aActionsFile = ["desktop", "desktopCommon", "download", "homeDrive", "programFiles", "appData", "appDataCommon", "appDataLocal", "windowsFolder", "startMenu"]

Local $s = _XMLFileOpen(@TempDir & "\kprm-tools.xml")

Func GetSwapOrder($sT)
	If _ArraySearch($aActionsFile, $sT) <> -1 Then
		Local $aOrder[4] = ["type", "companyName", "pattern", "force"]
		Return $aOrder
	ElseIf $sT = "uninstall" Then
		Local $aOrder[2] = ["folder", "uninstaller"]
		Return $aOrder
	ElseIf $sT = "task" Then
		Local $aOrder[1] = ["name"]
		Return $aOrder
	ElseIf $sT = "softwareKey" Then
		Local $aOrder[1] = ["pattern"]
		Return $aOrder
	ElseIf $sT = "process" Then
		Local $aOrder[2] = ["process", "force"]
		Return $aOrder
	ElseIf $sT = "registryKey" Then
		Local $aOrder[2] = ["key", "force"]
		Return $aOrder
	ElseIf $sT = "searchRegistryKey" Then
		Local $aOrder[3] = ["key", "pattern", "value"]
		Return $aOrder
	ElseIf $sT = "cleanDirectory" Then
		Local $aOrder[3] = ["path", "companyName", "force"]
		Return $aOrder
	ElseIf $sT = "file" Then
		Local $aOrder[3] = ["path", "companyName", "force"]
		Return $aOrder
	ElseIf $sT = "folder" Then
		Local $aOrder[3] = ["path", "force"]
		Return $aOrder
	EndIf
EndFunc   ;==>GetSwapOrder

Func Swap($sTn, $aK, $aV, $aOrder)
	Local $sData = $sTn & "~~"

	For $i = 0 To UBound($aOrder) - 1
		For $c = 0 To UBound($aK) - 1
			If $aOrder[$i] = $aK[$c] Then
				$sData &= $aV[$c] & "~~"
			EndIf
		Next
	Next

	$sData = StringTrimRight($sData, 2)

	Return $sData
EndFunc   ;==>Swap

Local $aNodes = _XMLSelectNodes("/tools/tool")

For $i = 1 To $aNodes[0]
	Local $sToolName = _XMLGetAttrib("/tools/tool[" & $i & "]", "name")
	Local $oToolsValue = ObjCreate("Scripting.Dictionary")
	Local $oToolsValueKey = ObjCreate("Scripting.Dictionary")
	Local $oToolsValueFile = ObjCreate("Scripting.Dictionary")
	Local $oToolsValueUninstall = ObjCreate("Scripting.Dictionary")
	Local $oToolsValueProcess = ObjCreate("Scripting.Dictionary")

	$oToolsValue.add("key", $oToolsValueKey)
	$oToolsValue.add("element", $oToolsValueFile)
	$oToolsValue.add("uninstall", $oToolsValueUninstall)
	$oToolsValue.add("process", $oToolsValueProcess)
	$oToolsCpt.add($sToolName, $oToolsValue)
Next

Func RunRemoveTools($bRetry = False)
	If $bRetry = True Then
		LogMessage(@CRLF & "- Search Tools -" & @CRLF)
	EndIf

	Local Const $aListActions = [ _
			"process", _
			"uninstall", _
			"task", _
			"desktop", _
			"desktopCommon", _
			"download", _
			"programFiles", _
			"homeDrive", _
			"appData", _
			"appDataCommon", _
			"appDataLocal", _
			"windowsFolder", _
			"softwareKey", _
			"registryKey", _
			"searchRegistryKey", _
			"startMenu", _
			"cleanDirectory", _
			"file", _
			"folder"]

	Local $aNodes = _XMLSelectNodes("/tools/tool")

	For $n = 0 To UBound($aListActions) - 1
		Local $sAction = $aListActions[$n]
		Local $aOrder = GetSwapOrder($sAction)
		Local $aListTasks[0][UBound($aOrder) + 1]

		For $i = 1 To $aNodes[0]
			Local $sToolName = _XMLGetAttrib("/tools/tool[" & $i & "]", "name")
			Local $aActions = _XMLSelectNodes("/tools/tool[" & $i & "]/*")

			For $c = 1 To $aActions[0]
				Local $sType = $aActions[$c]

				If $sType = $sAction Then
					Local $aName[1], $aValue[1]
					_XMLGetAllAttrib("/tools/tool[" & $i & "]/*[" & $c & "]", $aName, $aValue)
					Local $sCurrentTask = Swap($sToolName, $aName, $aValue, $aOrder)
					_ArrayAdd($aListTasks, $sCurrentTask, 0, "~~")
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
			Case "programFiles"
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
			Case "startMenu"
				RemoveAllFileFrom(@AppDataCommonDir & "\Microsoft\Windows\Start Menu\Programs", $aListTasks)
			Case "cleanDirectory"
				CleanDirectoryContent($aListTasks)
			Case "file"
				RemoveFileCustomPath($aListTasks)
			Case "folder"
				RemoveFolderCustomPath($aListTasks)
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
