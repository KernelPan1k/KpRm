Dim $sTmpDir

FileInstall(".\config\tools.xml", $sTmpDir & "\kprm-tools.xml")

Global $oToolsCpt = Null
Local $aActionsFile = ["desktop", "desktopCommon", "download", "homeDrive", "programFiles", "appData", "appDataCommon", "appDataLocal", "windowsFolder", "startMenu"]

Local $s = _XMLFileOpen($sTmpDir & "\kprm-tools.xml")

Func GetSwapOrder(ByRef $sT)
	If _ArraySearch($aActionsFile, $sT) <> -1 Then
		Local $aOrder[5][2] = [["type", "file"], ["companyName", ""], ["pattern", "__REQUIRED__"], ["force", "0"], ["quarantine", "0"]]
		Return $aOrder
	ElseIf $sT = "uninstall" Then
		Local $aOrder[2][2] = [["folder", "__REQUIRED__"], ["uninstaller", "__REQUIRED__"]]
		Return $aOrder
	ElseIf $sT = "task" Then
		Local $aOrder[1][2] = [["name", "__REQUIRED__"]]
		Return $aOrder
	ElseIf $sT = "softwareKey" Then
		Local $aOrder[1][2] = [["pattern", "__REQUIRED__"]]
		Return $aOrder
	ElseIf $sT = "process" Then
		Local $aOrder[3][2] = [["process", "__REQUIRED__"], ["companyName", ""], ["force", "0"]]
		Return $aOrder
	ElseIf $sT = "registryKey" Then
		Local $aOrder[2][2] = [["key", "__REQUIRED__"], ["force", "0"]]
		Return $aOrder
	ElseIf $sT = "searchRegistryKey" Then
		Local $aOrder[3][2] = [["key", "__REQUIRED__"], ["pattern", "__REQUIRED__"], ["value", "__REQUIRED__"]]
		Return $aOrder
	ElseIf $sT = "cleanDirectory" Then
		Local $aOrder[4][2] = [["path", "__REQUIRED__"], ["companyName", ""], ["force", "0"], ["quarantine", "0"]]
		Return $aOrder
	ElseIf $sT = "file" Then
		Local $aOrder[3][2] = [["path", "__REQUIRED__"], ["companyName", ""], ["force", "0"]]
		Return $aOrder
	ElseIf $sT = "folder" Then
		Local $aOrder[3][2] = [["path", "__REQUIRED__"], ["force", "0"], ["quarantine", "0"]]
		Return $aOrder
	EndIf
EndFunc   ;==>GetSwapOrder

Func Swap($sTn, $aK, $aV, $aOrder)
	Local $sData = $sTn & "~~"
	Local $iLength = 0
	Local $iCountOrder = UBound($aOrder)

	For $i = 0 To $iCountOrder - 1
		Local $bFound = False

		For $c = 0 To UBound($aK) - 1
			If $aOrder[$i][0] = $aK[$c] Then
				$sData &= $aV[$c] & "~~"
				$bFound = True
				$iLength += 1
			EndIf
		Next

		If $bFound = False Then
			Local $sDefaultValue = $aOrder[$i][1]

			If $sDefaultValue = "__REQUIRED__" Then
				MsgBox(16, "Fail", "Attribute " & $aOrder[$i][0] & " for tool " & $sTn & " is required")
				Exit
			EndIf

			$sData &= $sDefaultValue & "~~"
			$iLength += 1
		EndIf
	Next

	If $iLength <> $iCountOrder Then
		MsgBox(16, "Fail", "Values for tool " & $sTn & " are invalid ! Number of expected values " & $iLength & " and number of values received " & $iCountOrder)
		Exit
	EndIf

	$sData = StringTrimRight($sData, 2)

	Return $sData
EndFunc   ;==>Swap

Func InitOToolCpt()
	Dim $oToolsCpt

	$oToolsCpt = ObjCreate("Scripting.Dictionary")

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
EndFunc   ;==>InitOToolCpt

Func GenerateDeleteReport()
	Dim $bDeleteQuarantines
	Dim $bRemoveToolLastPass
	Dim $aElementsToKeep
	Dim $bRemoveToolLastPass

	If $bRemoveToolLastPass = True Then
		Local Const $aToolCptSubKeys[4] = ["process", "uninstall", "element", "key"]
		Local $bHasFoundTools = False

		For $sToolsCptKey In $oToolsCpt
			Local $oToolCptTool = $oToolsCpt.Item($sToolsCptKey)
			Local $bToolExistDisplayMessage = False

			For $sToolCptSubKeyI = 0 To UBound($aToolCptSubKeys) - 1
				Local $sToolCptSubKey = $aToolCptSubKeys[$sToolCptSubKeyI]
				Local $oToolCptSubTool = $oToolCptTool.Item($sToolCptSubKey)
				Local $oToolCptSubToolKeys = $oToolCptSubTool.Keys

				If UBound($oToolCptSubToolKeys) > 0 Then
					$bHasFoundTools = True
					If $bToolExistDisplayMessage = False Then
						$bToolExistDisplayMessage = True
						LogMessage(@CRLF & "  ## " & $sToolsCptKey)
					EndIf

					For $oToolCptSubToolKeyI = 0 To UBound($oToolCptSubToolKeys) - 1
						Local $oToolCptSubToolKey = $oToolCptSubToolKeys[$oToolCptSubToolKeyI]
						Local $oToolCptSubToolVal = $oToolCptSubTool.Item($oToolCptSubToolKey)
						CheckIfExist($sToolCptSubKey, $oToolCptSubToolKey, $oToolCptSubToolVal)
					Next
				EndIf
			Next
		Next

		If $bHasFoundTools = False Then
			LogMessage("  [I] No tools found")
		EndIf

		Local Const $bToolZhpQuarantineExist = IsDir(@AppDataDir & "\ZHP")
		Local Const $bHasElementToKeep = UBound($aElementsToKeep) > 1
		Local Const $bUseOtherLinesSection = $bToolZhpQuarantineExist = True Or $bHasElementToKeep = True

		If $bUseOtherLinesSection = True Then
			LogMessage(@CRLF & "- Other Lines -" & @CRLF)
		EndIf

		If $bToolZhpQuarantineExist = True Then
			LogMessage(@CRLF & "  ## Never deleted")
			LogMessage("    ~ " & @AppDataDir & "\ZHP (ZHP)")
		EndIf

		If $bHasElementToKeep = True Then
			If $bDeleteQuarantines = Null Then
				LogMessage(@CRLF & "  ## Keeped")

			ElseIf $bDeleteQuarantines = 7 Then
				LogMessage(@CRLF & "  ## Will be deleted in 7 days (" & _DateAdd('d', 7, _NowCalcDate()) & ")")
			EndIf

			_ArraySort($aElementsToKeep, 0, 0, 0, 1)

			For $i = 1 To UBound($aElementsToKeep) - 1
				LogMessage("    ~ " & $aElementsToKeep[$i][0] & " (" & $aElementsToKeep[$i][1] & ")")
			Next
		EndIf
	EndIf
EndFunc   ;==>GenerateDeleteReport


Func RunRemoveTools()
	Dim $bRemoveToolLastPass
	Dim $bSearchOnly

	If $bRemoveToolLastPass = True Then
		LogMessage(@CRLF & "- Remove Tools -" & @CRLF)
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
				UpdateStatusBar("Search process ...")
				RemoveAllProcess($aListTasks)
			Case "uninstall"
				UpdateStatusBar("Search uninstaller ...")
				UninstallNormally($aListTasks)
			Case "task"
				UpdateStatusBar("Search tasks ...")
				RemoveScheduleTask($aListTasks)
			Case "desktop"
				UpdateStatusBar("Search tools in desktop ...")
				RemoveAllFileFromWithMaxDepth(@DesktopDir, $aListTasks)
			Case "desktopCommon"
				UpdateStatusBar("Search tools in common desktop ...")
				RemoveAllFileFrom(@DesktopCommonDir, $aListTasks)
			Case "download"
				UpdateStatusBar("Search tools in download ...")
				RemoveAllFileFromWithMaxDepth(@UserProfileDir & "\Downloads", $aListTasks)
			Case "programFiles"
				UpdateStatusBar("Search tools in Program files ...")
				RemoveAllProgramFilesDir($aListTasks)
			Case "homeDrive"
				UpdateStatusBar("Search tools in home drive ...")
				RemoveAllFileFrom(@HomeDrive, $aListTasks)
			Case "appDataCommon"
				UpdateStatusBar("Search tools in AppData ...")
				RemoveAllFileFrom(@AppDataCommonDir, $aListTasks)
			Case "appDataLocal"
				UpdateStatusBar("Search tools in AppLocalData ...")
				RemoveAllFileFrom(@LocalAppDataDir, $aListTasks)
			Case "windowsFolder"
				UpdateStatusBar("Search tools in Windows ...")
				RemoveAllFileFrom(@WindowsDir, $aListTasks)
			Case "softwareKey"
				UpdateStatusBar("Search software keys ...")
				RemoveAllSoftwareKeyList($aListTasks)
			Case "registryKey"
				UpdateStatusBar("Search tools in registry ...")
				RemoveAllRegistryKeys($aListTasks)
			Case "searchRegistryKey"
				UpdateStatusBar("Specific search in registry ...")
				RemoveUninstallStringWithSearch($aListTasks)
			Case "startMenu"
				UpdateStatusBar("Search tools in start menu ...")
				RemoveAllFileFrom(@AppDataCommonDir & "\Microsoft\Windows\Start Menu\Programs", $aListTasks)
			Case "cleanDirectory"
				UpdateStatusBar("Search tools in specific directory ...")
				CleanDirectoryContent($aListTasks)
			Case "file"
				UpdateStatusBar("Search specific files ...")
				RemoveFileCustomPath($aListTasks)
			Case "folder"
				UpdateStatusBar("Search specific directory ...")
				RemoveFolderCustomPath($aListTasks)
		EndSwitch

		Local $iStepProgress = 1

		If $bSearchOnly = True Then
			$iStepProgress = 2
		EndIf

		ProgressBarUpdate($iStepProgress)
	Next

	If $bSearchOnly = True Then
		ProgressBarUpdate(50)
		UpdateStatusBar("Finish ...")
		SetSearchList()
		Return
	EndIf

	GenerateDeleteReport()
	ProgressBarUpdate()

EndFunc   ;==>RunRemoveTools
