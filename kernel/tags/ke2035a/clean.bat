@echo off

:- batch file to clean everything
:- $Id: clean.bat 1036 2004-09-12 04:46:28Z perditionc $

if not exist config.bat echo You must copy CONFIG.B to CONFIG.BAT and edit it to reflect your setup!
if not exist config.bat goto end

call config.bat
call default.bat

cd utils
%MAKE% clean

cd ..\lib
%MAKE% clean

cd ..\drivers
%MAKE% clean

cd ..\boot
%MAKE% clean

cd ..\sys
%MAKE% clean

cd ..\kernel
%MAKE% clean

cd ..\hdr
if exist *.bak del *.bak

cd ..
if exist *.bak del *.bak

:end
default.bat clearset
