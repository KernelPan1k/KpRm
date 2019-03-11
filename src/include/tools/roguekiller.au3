
Func RemoveRogueKiller()
	logMessage(@CRLF & "- Search RogueKiller Files -" & @CRLF)

	ProcessClose("RogueKiller.exe")
	ProgressBarUpdate()
EndFunc   ;==>RemoveRogueKiller

;~ O38 - TASK: {1ECBE92A-12CA-487E-A8C6-AB12B5CD2AC7}[\RogueKiller Anti-Malware] - (.Adlice Software - .) -- C:\Program Files\RogueKiller\RogueKiller.exe  [27313720] Adlice Software[-minimize]  =>Adlice Software
;~ C:\Windows\System32\Tasks\RogueKiller Anti-Malware - (.Adlice Software.) -- C:\Program Files\RogueKiller\RogueKiller.exe  [-minimize] Adlice Software[-minimize]  =>Adlice Software
;~ [MD5.978E4F90580C3778A1BF9212C996FE52] - (...) -- C:\Program Files\RogueKiller\RogueKiller.exe [27313720] [PID.336]  =>.Adlice®
;~ O42 - Logiciel: RogueKiller version 13.1.7.0 - (.Adlice Software.) [HKLM] -- 8B3D7924-ED89-486B-8322-E8594065D5CB_is1  =>.Adlice®
;~ O43 - CFD: 11/03/2019 - [] D -- C:\Program Files\RogueKiller  =>.Adlice Software
;~ O43 - CFD: 11/03/2019 - [] D -- C:\ProgramData\Microsoft\Windows\Start Menu\Programs\RogueKiller  =>.Adlice Software
;~ O43 - CFD: 11/03/2019 - [] D -- C:\ProgramData\RogueKiller  =>.Adlice Software
