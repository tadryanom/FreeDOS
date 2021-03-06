@echo off
: Prepare binary distribution
set DBG=Yes
set DBG=

: don't forget to pass on the default rather than mine
copy config.dflt config.mak

for %pkg in (binary debug plainedt) for %fnam in (ptchldrv.exe ptchsize.exe kssf.com vspawn.com command.com) (set fn=packages\%pkg.std\%fnam %+ if exist %fn del /q %fn)


set _DBG=REM
if NOT "%DBG%"=="" set _DBG=

%_DBG setdos /y1 %+ %_DBG echo on

set compiler=tc101
set compiler=bc5
set lng=english

iff exist config.h.backup then
	echo config.h.backup exists
	echo something went wrong last time
	cancel 30
endiff

iff not isdir old then
	mkdir old
	if not isdir old (echo Cannot create OLD %+ quit 10)
else
	del /y old\*.*
endiff
for %stem in (cmddebug command kssf kssf_dbg) do for %ext in (new exe com cln) do (set file=%stem.%ext %+ if exist %file move %file old\%file)

%_DBG setdos /y0 %+ %_DBG echo off
dmake clobber || quit
%_DBG setdos /y1 %+ %_DBG echo on


: pause

: Make the "with debug" binary
set ndebug=
set debug=1

%_DBG setdos /y0 %+ %_DBG echo off
dmake MODEL!:=l || quit
%_DBG setdos /y1 %+ %_DBG echo on
: pause

if not exist com.com goto ende
move com.com packages\debug.std\command.com
if exist com.com goto ende
for %file in (tools\kssf.com tools\vspawn.com tools\ptchldrv.exe tools\ptchsize.exe) (if exist %file move %file packages\debug.std\ %+ if exist %file goto ende)
:noKSSFDBG
: pause

: Disable all debug stuff
set ndebug=Yes
set debug=
set compiler=tc101

ren /q config.h config.h.backup || cancel 20
echo #define IGNORE_ENHANCED_INPUT >config.h
type config.h.backup >>config.h


set err=
%_DBG setdos /y0 %+ %_DBG echo off
dmake || set err=%?
%_DBG setdos /y1 %+ %_DBG echo on

del /q config.h
ren /q config.h.backup config.h || cancel 21

if not x%err == x cancel %err
if not exist com.com goto ende
move com.com packages\plainedt.std\command.com
if exist com.com goto ende
: pause


touch config.h
%_DBG setdos /y0 %+ %_DBG echo off
dmake -W config.h || quit
%_DBG setdos /y1 %+ %_DBG echo on
: pause
for %file in (tools\kssf.com tools\vspawn.com tools\ptchldrv.exe tools\ptchsize.exe) (if exist %file copy %file packages\plainedt.std\ %+ if exist %file move %file packages\binary.std\ %+ if exist %file goto ende)

if not exist com.com goto ende
copy /b shell\com.exe +infores + criter\criter + criter\criter1 command.cln
ren com.com command.com
if exist com.com goto ende

perl get_ver.pl .\command.com

: %_DBG echo on %+ setdos /y1

:: Make HTML documents
pushd docs\html\commands || quit
echo Updating HTML documents
perl db2html
: Call it two times to have the command list updated
perl db2html
perl parseHTML
popd

: %_DBG echo on %+ setdos /y1
call mkpkgs.bat

%_DBG setdos /y0 %+ %_DBG echo off
dmake clean dist || quit
%_DBG setdos /y1 %+ %_DBG echo on

rm -frd old

:ende
