@echo off
REM Simple Django SQLite Backup Script with Year in Timestamp
REM Save as: backup_db.bat

REM Update these paths for your setup
set SOURCE_DB=C:\inetpub\wwwroot\Auto-auction\
set BACKUP_FOLDER=C:\Users\Administrator\Documents\AUTOBID ALL FILES BACKUPS

REM Create backup folder if it doesn't exist
if not exist "%BACKUP_FOLDER%" mkdir "%BACKUP_FOLDER%"

REM Get system date and time in yyyy-mm-dd_hhmm format
for /f %%a in ('wmic os get localdatetime ^| find "."') do set datetime=%%a
set timestamp=%datetime:~0,4%-%datetime:~4,2%-%datetime:~6,2%_%datetime:~8,2%%datetime:~10,2%

REM Copy database file
copy "%SOURCE_DB%" "%BACKUP_FOLDER%\AUTOBID ALL FILES BACKUPS_%timestamp%"

echo Backup completed: %BACKUP_FOLDER%\AUTOBID ALL FILES BACKUPS_%timestamp%
