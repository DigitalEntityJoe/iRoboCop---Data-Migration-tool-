::---------------------------------------::
::  iRoboCop v2.1.2 - Build date 7/7/2016 ::
::---------------------------------------::


::------------------------------------------------------------------------::
:: This is an Interactive CLI, Just run it, it will ask you for everything::
::------------------------------------------------------------------------::

::----------------------------------------------------------------------------::
:: So you want to see my source code... I'm not sure how I feel about this... ::
::----------------------------------------------------------------------------::









































::-------------------------------------------------------::
:: your kind of freaking me out.... stop following me... ::
::-------------------------------------------------------::












::-------------::
:: Fine........::
::-------------::




@echo off

::-----------------------------::
:: First, we need admin rights ::
::-----------------------------::

CLS
echo We need Admin Rights, I'll Check that for you...

:checkPrivileges
NET FILE 1>NUL 2>NUL
if '%errorlevel%' == '0' ( goto gotPrivileges ) else ( goto getPrivileges )

:getPrivileges
if '%1'=='ELEV' (echo ELEV & shift /1 & goto gotPrivileges)
echo.
echo Nope, Not an Admin, I'll Fix that...
echo.
echo Click on Yes/OK if the UAC box pops up... thanks 

setlocal DisableDelayedExpansion
set "batchPath=%~0"
setlocal EnableDelayedExpansion
ECHO Set UAC = CreateObject^("Shell.Application"^) > "%temp%\OEgetPrivileges.vbs"
ECHO args = "ELEV " >> "%temp%\OEgetPrivileges.vbs"
ECHO For Each strArg in WScript.Arguments >> "%temp%\OEgetPrivileges.vbs"
ECHO args = args ^& strArg ^& " "  >> "%temp%\OEgetPrivileges.vbs"
ECHO Next >> "%temp%\OEgetPrivileges.vbs"
ECHO UAC.ShellExecute "!batchPath!", args, "", "runas", 1 >> "%temp%\OEgetPrivileges.vbs"
"%SystemRoot%\System32\WScript.exe" "%temp%\OEgetPrivileges.vbs" %*
exit /B

:gotPrivileges
echo.
echo Yay, we have Admin rights, moving along... 
if '%1'=='ELEV' shift /1
setlocal & pushd .
cd /d %~dp0

::ECHO Arguments: %1 %2 %3 %4 %5 %6 %7 %8 %9

::----------------------------------------------------------------------::
:: Now that thats taken care of we can kill that annoying beeping sound ::
::----------------------------------------------------------------------::

::we dont like beeps
@echo off
@sc config beep start= disabled /f > nul
:: or outputs on service controls (/f > nul)

echo.
echo.
echo.
echo.
echo.

::----------------------::
:: Ok, now we can Start ::
::----------------------::


:: this prints the ASCII art
for /f "delims=: tokens=*" %%A in ('findstr /b ::: "%~f0"') do @echo(%%A


:: gotta be hacker green
color 0A

echo.
echo.
echo.
echo                       **** Welcome to iRoboCop v2.1.2 ****
echo.
echo    This is an Interactive data migration program that will copy all files and folders
echo            with all rights and attributes previously given to them.
echo.
echo.

:SETSDL
echo.
echo      You can specify a folder locally or on a server
echo.

:BROWSESRCYN
set /P BROWSESRC=Do you want to Browse to find Source folder? [Y/N]:
if /I "%BROWSESRC%" EQU "Y" goto BROWSESRCY
if /I "%BROWSESRC%" EQU "N" goto PROMPTSRC
goto BROWSESRCYN

:BROWSESRCY
set "psCommand="(new-object -COM 'Shell.Application')^
.BrowseForFolder(0,'Where am I copying from?',0,0).self.path""

for /f "usebackq delims=" %%I in (`powershell %psCommand%`) do set "SORC=%%I"
goto BROWSEDESTYN

:PROMPTSRC
echo.
echo Examples = \\server\share (folder) or \\server\c$ (entire drive) or c:\folder (local)
echo.
SET /P SORC=Where am I copying things from?:
goto BROWSEDESTYN

:BROWSEDESTYN
echo.
set /P BROWSEDEST=Do you want to Browse to find Destination folder? [Y/N]:
if /I "%BROWSEDEST%" EQU "Y" goto :BROWSEDESTY
if /I "%BROWSEDEST%" EQU "N" goto :PROMPTDEST
goto :BROWSEDESTYN

:BROWSEDESTY
set "psCommand="(new-object -COM 'Shell.Application')^
.BrowseForFolder(0,'And where am I putting them?',0,0).self.path""

for /f "usebackq delims=" %%I in (`powershell %psCommand%`) do set "DEST=%%I"
goto BROWSELOGYN

:PROMPTDEST
echo.
SET /P DEST=And where am I putting them?:
echo.
echo Logs are important, please tell me where they should go
echo Make sure there are no spaces in the log folder.  things get weird... thanks
echo.
goto BROWSELOGYN

:BROWSELOGYN
echo.
set /P BROWSELOG=Do you want to Browse to find Log folder? [Y/N]:
if /I "%BROWSELOG%" EQU "Y" goto BROWSELOGY
if /I "%BROWSELOG%" EQU "N" goto PROMPTLOG
goto BROWSELOGYN

:BROWSELOGY
set "psCommand="(new-object -COM 'Shell.Application')^
.BrowseForFolder(0,'Where is the log going?',0,0).self.path""

for /f "usebackq delims=" %%I in (`powershell %psCommand%`) do set "LOG=%%I"
goto CHOICESDL


:PROMPTLOG
echo Example = c:\logs or \\server\share
echo.
SET /P LOG=What folder should I put the logs in?:

:CHOICESDL
echo.
set /P SDLYN=So are we copying %SORC% to %DEST%, with a log in %LOG%? [Y/N]:
if /I "%SDLYN%" EQU "Y" goto :CONFIRM
if /I "%SDLYN%" EQU "N" goto :RETRY
goto :CHOICESDL

:RETRY
echo.
set /P RETRYYN=Do you want to try again? [Y/N]:
if /I "%RETRYYN%" EQU "Y" goto :SETSDL
if /I "%RETRYYN%" EQU "N" goto :RETRYNO
goto :RETRY


:CONFIRM
echo.
@echo Moving All files from %SORC% to %DEST%...
echo.
@echo (if you need to exit press ctrl+c)

: Sets the proper date and time stamp with 24Hr Time for log file naming
: convention

SET HOUR=%time:~0,2%
SET dtStamp9=%date:~-4%%date:~4,2%%date:~7,2%_0%time:~1,1%%time:~3,2%%time:~6,2% 
SET dtStamp24=%date:~-4%%date:~4,2%%date:~7,2%_%time:~0,2%%time:~3,2%%time:~6,2%

if "%HOUR:~0,1%" == " " (SET dtStamp=%dtStamp9%) else (SET dtStamp=%dtStamp24%)

::ECHO %dtStamp%

ROBOCOPY %SORC% %DEST% /E /SEC /COPYALL /ZB /R:3 /W:5 /XO /XD $RECYCLE.BIN /XF pagefile.sys /LOG:%LOG%\iRoboCopV2-%dtStamp%.log /NP
echo.
@if errorlevel 16 echo Something was wrong, Nothing Copied, Check Source and Destination and log input & goto RETRY
@if errorlevel 8  echo Couldn't copy some files, I tried & goto DELTACH
@if errorlevel 4  echo Theres some mismatches, check logs & goto DELTACH
@if errorlevel 2  echo Some extra stuff is there, check logs & goto DELTACH
@if errorlevel 1  echo --Copy Successful-- & goto SFSG
@if errorlevel 0  echo --Copy Successful-- & goto SFSG

:SFSG
echo. 
@echo so far, so good..
echo.
goto DELTACH

:DELTACH
set waitHours=2
echo.
echo I will look for changes in %waitHours% hours: Press N to look for changes [N]ow or C to [C]ancel
:: Calculate Seconds
set /a waitMins=waitHours*3600
choice /c nc /d n /t %waitMins%

:: [N]ow = 1; [C]ancel = 2
goto Label%errorlevel%

:Label1
goto CONFIRM

:Label2 
echo.
echo I will not look for changes, moving forward...
goto HIDDEN



::-----------------------------------------------------------------------------------::
:: this is in case you copied from root of drive, robocopy likes to play hard to get ::
::-----------------------------------------------------------------------------------::

:HIDDEN
echo.
echo If you copied an entire drive the output will be hidden
echo.
set /P c=Is %DEST% hidden? I will fix that! [Y/N]
if /I "%c%" EQU "Y" goto :YES
if /I "%c%" EQU "N" goto :NO
goto :HIDDEN

::------------------------------------::
:: All good stories have good endings ::
::------------------------------------::

:YES
echo.
@echo "I am now changing attributes of %DEST% so its not hidden"
attrib -h -s %DEST%
echo.
echo Have a great day!
goto BYE

:NO
echo.
@echo Well thats good!
goto END

:ENDF
echo.
@echo "Something failed, please check logs"
goto END

:END
echo.
@echo All done here
goto BYE

:RETRYNO
echo.
echo SHEESH...NO ONE LIKES A QUITTER ANYWAY....
goto BYE

:BYE
echo.
echo Thank you for your compliance.
for /f "delims=: tokens=*" %%A in ('findstr /b ::: "%~f0"') do @echo(%%A
pause


::-----------------------------------------------::
::  Well we all know who the nosey one is now... ::
::-----------------------------------------------::


















































::Well that was fun
::Peace, DigitalEntity
























::  P.S. Dont steal my code... ill find you!



































:::        .____________      ___.          _________                
:::        |__\______   \ ____\_ |__   ____ \_   ___ \  ____ ______  
:::        |  ||       _//  _ \| __ \ /  _ \/    \  \/ /  _ \\____ \ 
:::        |  ||    |   (  <_> ) \_\ (  <_> )     \___(  <_> )  |_> >
:::        |__||____|_  /\____/|___  /\____/ \______  /\____/|   __/ 
:::                   \/           \/               \/       |__|    


