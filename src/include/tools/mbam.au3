
Func RemoveMBAM()
	RemoveService("MBAMService")
	Sleep(1000)

	RemoveFolder(@HomeDrive & "\Program Files(x86)" & "\Malwarebytes")
	RemoveFolder(@HomeDrive & "\Program Files" & "\Malwarebytes")

	RemoveFile(@WindowsDir & "\System32" & "\drivers\mbae.sys")
	RemoveFile(@WindowsDir & "\System32" & "\drivers\MbamChameleon.sys")
	RemoveFile(@WindowsDir & "\System32" & "\drivers\farflt.sys")
	RemoveFile(@WindowsDir & "\System32" & "\drivers\mbamswissarmy.sys")
	RemoveFile(@WindowsDir & "\System32" & "\drivers\mwac.sys")

	RemoveFile(@WindowsDir & "\SYSWOW64" & "\drivers\mbae.sys")
	RemoveFile(@WindowsDir & "\SYSWOW64" & "\drivers\MbamChameleon.sys")
	RemoveFile(@WindowsDir & "\SYSWOW64" & "\drivers\farflt.sys")
	RemoveFile(@WindowsDir & "\SYSWOW64" & "\drivers\mbamswissarmy.sys")
	RemoveFile(@WindowsDir & "\SYSWOW64" & "\drivers\mwac.sys")

	RemoveFile(@DesktopDir & "\Malwarebytes.lnk")

	RemoveFolder(@LocalAppDataDir & "\mbamtray")
	RemoveFolder(@LocalAppDataDir & "\mbam")

	RemoveFolder(@HomeDrive & "\ProgramData\Malwarebytes")
	RemoveFolder(@HomeDrive & "\ProgramData\Microsoft\Windows\Start Menu\Programs\Malwarebytes")

	ProgressBarUpdate()
EndFunc   ;==>RemoveMBAM
