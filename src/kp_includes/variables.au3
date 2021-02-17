Global $bKpRmDev = False
Global $sKprmVersion = "2.9"
Global Const $sUPLOAD_PAGE = "upload-logs.php"
Global Const $sUPDATE_SITE = "kernel-panik.ovh"
Global Const $sFtpUA = "Autoit/3 KPRM"
Global $sTmpDir = @TempDir & "\KPRM"
Global $sProgramName = "KpRm"
Global $sCurrentTime = @YEAR & @MON & @MDAY & @HOUR & @MIN & @SEC
Global $sCurrentHumanTime = @YEAR & '-' & @MON & '-' & @MDAY & '-' & @HOUR & '-' & @MIN & '-' & @SEC
Global $sKPLogFile = "kprm-" & $sCurrentTime & ".txt"
Global $bPowerShellAvailable = Null
Global $bDeleteQuarantines = Null
Global $bSearchOnly = False
Global $bSearchOnlyHasFoundElement = False
Global $bNeedRestart = False
Global $aElementsToKeep[1][2] = [[]]
Global $aElementsFound[1][2] = [[]]
Global $aRemoveRestart = []
Global $pLeft = 16
Global $pRight = 220
Global $pPadding1 = 8
Global $pWidth1 = 400
Global $pCtrSize = 17
Global $pButtonDetectionHeight = 39
Global $pButtonDetectionPT = 31
Global $pStep = 36
Global $cWhite = 0xFFFFFF
Global $cBlack = 0x1a1a1a
Global $cDisabled = 0x2a2a2a
Global $cBlue = 0x63c0f5
Global $cGreen = 0xb5e853
Global $cRed = 0xf74432
Global $SC_DRAGMOVE = 0xF012
Global $oHStatus = Null
Global $oProgressBar = Null
Global $oListView = Null
Global $oRemoveSearchLines
Global $oSearchLines
Global $oUnSelectAllSearchLines
Global $oSelectAllSearchLines
Global $oClearSearchLines
Global $oBackupRegistry
Global $oRemoveTools
Global $oRestoreSystemSettings
Global $oRestoreUAC
Global $oRemoveRP
Global $oCreateRP
Global $oDeleteQuarantine
Global $oDeleteQuarantineAfter7Days
Global $oProgressBar
Global $iNbrTask = 27
Global $iCurrentNbrTask
Global Const $iTaskStep = Floor(100 / $iNbrTask)
Global $oToolsCpt = Null
Global $aActionsFile = ["desktop", "desktopCommon", "download", "homeDrive", "programFiles", "appData", "appDataCommon", "appDataLocal", "windowsFolder", "startMenu"]
Global $__g_oSR_WMI = Null
Global $__g_oSR = Null
