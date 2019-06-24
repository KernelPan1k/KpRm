@echo off

set HomeDrive="C:"
set LOGFILE=C:\robocopy.log
set SNAPDOS=B:

rem Backup Documents and Settings folder
set SYSTEM_HIVES=%SNAPDOS%\Windows\System32\config
set USER_HIVES=%userprofile%
set BACKUP=C:\KPRM\backup

dosdev %SNAPDOS% %1%

robocopy "%SYSTEM_HIVES%" "%BACKUP%" SOFTWARE >> "%LOGFILE%"
robocopy "%SYSTEM_HIVES%" "%BACKUP%" SAM >> "%LOGFILE%"
robocopy "%SYSTEM_HIVES%" "%BACKUP%" SECURITY >> "%LOGFILE%"
robocopy "%SYSTEM_HIVES%" "%BACKUP%" SYSTEM >> "%LOGFILE%"
robocopy "%SYSTEM_HIVES%" "%BACKUP%" DEFAULT >> "%LOGFILE%"
robocopy "%USER_HIVES%" "%BACKUP%" Ntuser.dat >> "%LOGFILE%"

dosdev /D %SNAPDOS% 
