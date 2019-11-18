Func AddToSearchList($sLine, $sTool)
	Dim $oListView
	ConsoleWrite($sLine & " " & $sTool & @CRLF)
	GUICtrlCreateListViewItem($sLine & '|' & $sTool, $oListView)
EndFunc