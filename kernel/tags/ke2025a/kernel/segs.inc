; File:
;                           segs.inc
; Description:
;     Segment definitions for the kernel
;
;                       Copyright (c) 1998
;                       Pasquale J. Villani
;                       All Rights Reserved
;
; This file is part of DOS-C.
;
; DOS-C is free software; you can redistribute it and/or
; modify it under the terms of the GNU General Public License
; as published by the Free Software Foundation; either version
; 2, or (at your option) any later version.
;
; DOS-C is distributed in the hope that it will be useful, but
; WITHOUT ANY WARRANTY; without even the implied warranty of
; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See
; the GNU General Public License for more details.
;
; You should have received a copy of the GNU General Public
; License along with DOS-C; see the file COPYING.  If not,
; write to the Free Software Foundation, 675 Mass Ave,
; Cambridge, MA 02139, USA.
;
; $Logfile:   C:/usr/patv/dos-c/src/kernel/segs.inv  $
;
; $Header$
;
; $Log$
; Revision 1.9  2001/09/23 20:39:44  bartoldeman
; FAT32 support, misc fixes, INT2F/AH=12 support, drive B: handling
;
; Revision 1.8  2001/07/09 22:19:33  bartoldeman
; LBA/FCB/FAT/SYS/Ctrl-C/ioctl fixes + memory savings
;
; Revision 1.7  2001/04/29 17:34:40  bartoldeman
; A new SYS.COM/config.sys single stepping/console output/misc fixes.
;
; Revision 1.6  2001/04/21 22:32:53  bartoldeman
; Init DS=Init CS, fixed stack overflow problems and misc bugs.
;
; Revision 1.5  2001/04/15 03:21:50  bartoldeman
; See history.txt for the list of fixes.
;
; Revision 1.4  2001/03/21 02:56:26  bartoldeman
; See history.txt for changes. Bug fixes and HMA support are the main ones.
;
; Revision 1.3  2000/05/25 20:56:21  jimtabor
; Fixed project history
;
; Revision 1.2  2000/05/08 04:30:00  jimtabor
; Update CVS to 2020
;
; Revision 1.1.1.1  2000/05/06 19:34:53  jhall1
; The FreeDOS Kernel.  A DOS kernel that aims to be 100% compatible with
; MS-DOS.  Distributed under the GNU GPL.
;
; Revision 1.2  1999/08/10 17:57:13  jprice
; ror4 2011-02 patch
;
; Revision 1.1.1.1  1999/03/29 15:41:30  jprice
; New version without IPL.SYS
;
; Revision 1.1  1999/02/08 05:55:57  jprice
; Added Pat's 1937 kernel patches
;
;
;    Rev 1.0   06 Dec 1998  8:12:36   patv
; Initial revision.
; $EndLog
;

group   PGROUP          PSP
group	TGROUP		_TEXT _IO_TEXT _IO_FIXED_DATA 
group	DGROUP		_FIXED_DATA _DATA _BSSSTART _BSS _BSSEND DYN_DATA DCONST
group	HGROUP		HMA_TEXT_START HMA_TEXT HMA_TEXT_END
group	IGROUP		INIT_TEXT_START INIT_TEXT INIT_TEXT_END ID_B ID ID_E IB_B IB IB_E IC IDATA

segment PSP             class=PSP
segment	_TEXT		class=CODE
segment	_IO_TEXT	class=CODE
segment	_IO_FIXED_DATA	class=CODE align=2
segment	_FIXED_DATA	class=DATA align=16
segment	_DATA		class=DATA align=2
segment	_BSSSTART       class=BSS align=2
segment	_BSS		class=BSS align=2
segment	_BSSEND		class=BSS
;for MSC
segment	DCONST      	class=DCONST   align=2     
segment	DYN_DATA    class=DYN_DATA
segment	HMA_TEXT_START	class=HMA align=16
segment	HMA_TEXT	class=HMA
segment	HMA_TEXT_END	class=HMA
segment	INIT_TEXT_START	class=INIT align=16
segment	INIT_TEXT	class=INIT
segment	INIT_TEXT_END	class=INIT
segment ID_B            class=ID   align=2
segment ID              class=ID   align=2
segment ID_E            class=ID   align=2
segment IDATA           class=ID   align=2
segment	IB_B      	class=IB   align=2
segment	IB      	class=IB   align=2     
segment	IB_E      	class=IB   align=2
segment	IC      	class=IC   align=2     

