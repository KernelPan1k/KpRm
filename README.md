## KpRm


### KpRm is a tool to use to finalize a disinfection, it removes the following software:

 - AdliceDiag (Tigzy)
 - AdsFix (Gen-Hackman)
 - AdwCleaner (Malwarebytes)
 - AHK_NavScan (Batch_Man)
 - AlphaDecrypter (Michael Gillespie)
 - Aswmbr (Avast!Software)
 - AuroraDecrypter (Michael Gillespie)
 - Offline CryptoMix Ransomware Decryptor (Avast!Software)
 - Avenger (swandog46)
 - BitKangarooDecrypter (Michael Gillespie)
 - BitStakDecrypter (Michael Gillespie)
 - Blitzblank (Emsisoft)
 - BTCWareDecrypter (Michael Gillespie)
 - Catchme (Gmer)
 - Check Browsers LNK (Alex Dragokas & regist)
 - CKScanner (askey127)
 - Clean_DNS (Gen-Hackman)
 - ClearLNK (Alex Dragokas)
 - CMD_Command (Gen-Hackman)
 - Combofix (sUBs)
 - Crypt38Decrypter (Michael Gillespie)
 - CryptoSearch (Michael Gillespie)
 - DDS (sUBs)
 - CryptON Ransomware Decryptor (Emsisoft)
 - Defogger (jpshortstuff)
 - DCryDecrypter (Michael Gillespie)
 - Eset Online Scanner (Eset)
 - FilesLockerDecrypter (Michael Gillespie)
 - FixExec (BleepingComputer)
 - Fix-Purge (McVivien2)
 - FRST (Farbar)
 - FSS (Farbar)
 - FTC (Old_Timer)
 - GetSystemInfo (Kaspersky Labs)
 - GhostCryptDecrypter (Michael Gillespie)
 - GIBON Ransomware Decryptor (Michael Gillespie)
 - GooredFix (jpshortstuff)
 - GrantPerms (Farbar)
 - Hidden Tear Decrypter (Michael Gillespie)
 - HostsXpert (funkytoad)
 - Hosts-perm.bat (BleepingComputer)
 - InsaneCryptDecrypter (Michael Gillespie)
 - JavaRa (Fred de Vries et Paul McLain)
 - Jigsaw Decrypter (Michael Gillespie)
 - Junkware Removal Tool (Malwarebytes corporation)
 - ListCWall (BleepingComputer)
 - ListParts (Farbar)
 - LogOnFix (Xplode)
 - MBAR (Malwarebytes corporation)
 - MBRCheck (a_d_13)
 - mbr.exe (Gmer)
 - MicroCop Decryptor (Michael Gillespie)
 - Miniregtool (Farbar)
 - Minitoolbox (Farbar)
 - MKV (El Desaparecido & C_XX)
 - OTA (Old_Timer)
 - OTC (Old_Timer)
 - OTH (Old_Timer)
 - OTL (Old_Timer)
 - OTM (Old_Timer)
 - OTS (Old_Timer)
 - Pre_Scan (Gen-Hackman)
 - PowerLockyDecrypter (Michael Gillespie)
 - ProcessClose (Gen-Hackman)
 - QuickDiag (Gen-Hackman)
 - RakhniDecryptor (Kaspersky Lab)
 - Rannoh Decryptor (Kaspersky Lab)
 - RansomNoteCleaner (Michael Gillespie)
 - RegtoolExport (Xplode)
 - Remediate VBS Worm (bartblaze)
 - Report_CHKDSK (Laddy)
 - Rkill (Grinler)
 - RogueKiller (Tigzy)
 - RstAssociations (Xplode) (scr) (exe)
 - RstHosts (Xplode)
 - ScanRapide (Lydem)
 - Shortcut Cleaner (BleepingComputer)
 - Seaf (C_XX)
 - SecurityCheck (screen317)
 - StrikedDecrypter (Michael Gillespie)
 - StupidDecryptor (Michael Gillespie)
 - Symantec Kovter Removal Tool (Symantec)
 - SystemLook (jpshortstuff)
 - SFTGC (Pierre13)
 - TDSSkiller (Kaspersky Labs)
 - ToolsDiag (Amesam)
 - UnHide (BleepingComputer)
 - Unlock92Decrypter (Michael Gillespie)
 - Usb File Resc (Streuner Corporation)
 - UsbFix (El desaparecido & C_XX)
 - UnZacMe (Gen-Hackman)
 - WinChk (Xplode)
 - WinUpdatefix (Xplode)
 - ZHPCleaner (Nicolas Coolman)
 - ZHPDiag (Nicolas Coolman)
 - ZHPLite (Nicolas Coolman)
 - ZHPFix (Nicolas Coolman)
 - Zoek (Smeenk)


The search for executables downloaded by the user is only performed in the Desktop and the download folder.
To respect Nicolas Coolman's choice, the quarantine of ZHP tools located under AppData\ZHP is no longer deleted,
however a line in the report indicates its presence.


### - Save the registry

I try to be careful that this tool only deletes what it is supposed to delete, but since KpRm is still "young" we
should always make a backup of the registry.


### - Delete recovery points


### - Create a restore point

During this phase, KpRm first activates system recovery and then deletes recovery points that were created less
than 24 hours ago. After creating a restore point, this tool will list all the points on the machine.
It is important to always check in this list if the restore point has been created, especially if the machine is
running on Windows 10.


### - Restore system settings

- Reset DNS cache
- Reset the WinSock catalog
- Hide hidden files
- Hide protected files
- Show known file extensions


### - Restore the UAC

- ConsentPromptBehaviorAdmin (5)
- ConsentPromptBehaviorUser (3)
- EnableInstallerDetection (0)
- EnableLUA (1)
- EnableSecureUIAPaths (1)
- EnableUIADesktopToggle (0)
- EnableVirtualization (1)
- FilterAdministratorToken (0)
- PromptOnSecureDesktop (1)
- ValidateAdminCodeSignatures (0)


Project website: https://kernel-panik.me/tool/kprm/
