;
; File:
;                          execrh.asm
; Description:
;             request handler for calling device drivers
;
;                    Copyright (c) 1995, 1998
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
; $Logfile:   C:/usr/patv/dos-c/src/kernel/execrh.asv  $
;
; $Id: execrh.asm 314 2001-11-04 19:47:39Z bartoldeman $
;
; $Log$
; Revision 1.8  2001/11/04 19:47:39  bartoldeman
; kernel 2025a changes: see history.txt
;
; Revision 1.7  2001/04/21 22:32:53  bartoldeman
; Init DS=Init CS, fixed stack overflow problems and misc bugs.
;
; Revision 1.6  2001/04/15 03:21:50  bartoldeman
; See history.txt for the list of fixes.
;
; Revision 1.5  2001/04/02 23:18:30  bartoldeman
; Misc, zero terminated device names and redirector bugs fixed.
;
; Revision 1.4  2001/03/21 02:56:25  bartoldeman
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
; Revision 1.3  2000/03/09 06:07:11  kernel
; 2017f updates by James Tabor
;
; Revision 1.2  1999/08/10 17:57:12  jprice
; ror4 2011-02 patch
;
; Revision 1.1.1.1  1999/03/29 15:40:54  jprice
; New version without IPL.SYS
;
; Revision 1.4  1999/02/08 05:55:57  jprice
; Added Pat's 1937 kernel patches
;
; Revision 1.3  1999/02/01 01:48:41  jprice
; Clean up; Now you can use hex numbers in config.sys. added config.sys screen function to change screen mode (28 or 43/50 lines)
;
; Revision 1.2  1999/01/22 04:13:25  jprice
; Formating
;
; Revision 1.1.1.1  1999/01/20 05:51:01  jprice
; Imported sources
;
;
;   Rev 1.3   06 Dec 1998  8:45:06   patv
;Bug fixes.
;
;   Rev 1.2   29 May 1996 21:03:30   patv
;bug fixes for v0.91a
;
;   Rev 1.1   01 Sep 1995 17:54:22   patv
;First GPL release.
;
;   Rev 1.0   02 Jul 1995  9:05:34   patv
;Initial revision.
; $EndLog$
;

                %include "segs.inc"

segment	HMA_TEXT
                ; _execrh
                ;       Execute Device Request
                ;
                ; execrh(rhp, dhp)
                ; request far *rhp;
                ; struct dhdr far *dhp;
                ;
;
; The stack is very critical in here.
;
        global  _execrh
_execrh:
                push    bp              ; perform c entry
                mov     bp,sp
                push    si
                push    ds              ; sp=bp-8

                lds     si,[bp+8]       ; ds:si = device header
                les     bx,[bp+4]       ; es:bx = request header


                mov     ax, [si+6]      ; construct strategy address
                mov     [bp+8], ax    

                mov     si, [si+8]      ; save 'interrupt' address
        
                call    far[bp+8]       ; call far the strategy

                mov     [bp+8],si       ; construct interrupt address 
                call    far[bp+8]       ; call far the interrupt

                sti                     ; damm driver turn off ints
                cld                     ; has gone backwards
                pop     ds
                pop     si
                pop     bp
                ret
