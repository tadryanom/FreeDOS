;
; File:
;                         floppy.asm
; Description:
;                   floppy disk driver primitives
;
;                       Copyright (c) 1995
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
; $Logfile:   C:/usr/patv/dos-c/src/drivers/floppy.asv  $
;
; $Id: floppy.asm 314 2001-11-04 19:47:39Z bartoldeman $
;
; $Log$
; Revision 1.9  2001/11/04 19:47:39  bartoldeman
; kernel 2025a changes: see history.txt
;
; Revision 1.8  2001/09/23 20:39:44  bartoldeman
; FAT32 support, misc fixes, INT2F/AH=12 support, drive B: handling
;
; Revision 1.7  2001/07/09 22:19:33  bartoldeman
; LBA/FCB/FAT/SYS/Ctrl-C/ioctl fixes + memory savings
;
;
; Revision 1.7  2001/04/29           brianreifsnyder
; Added phase 1 support for LBA hard drives
;
; Revision 1.6  2001/04/22 01:19:33  bartoldeman
; Avoid sys warning and have a VDISK signature in the HMA
;
; Revision 1.5  2001/04/15 03:21:50  bartoldeman
; See history.txt for the list of fixes.
;
; Revision 1.4  2001/03/21 02:56:25  bartoldeman
; See history.txt for changes. Bug fixes and HMA support are the main ones.
;
; Revision 1.3  2000/05/25 20:56:19  jimtabor
; Fixed project history
;
; Revision 1.2  2000/05/11 03:56:20  jimtabor
; Clean up and Release
;
; Revision 1.1.1.1  2000/05/06 19:34:53  jhall1
; The FreeDOS Kernel.  A DOS kernel that aims to be 100% compatible with
; MS-DOS.  Distributed under the GNU GPL.
;
; Revision 1.4  1999/08/10 17:21:08  jprice
; ror4 2011-01 patch
;
; Revision 1.3  1999/04/16 21:29:17  jprice
; ror4 multi-sector IO
;
; Revision 1.2  1999/03/29 17:08:31  jprice
; ror4 changes
;
; Revision 1.1.1.1  1999/03/29 15:40:24  jprice
; New version without IPL.SYS
;
; Revision 1.4  1999/02/14 04:25:16  jprice
; Added functions to check if a floppy disk has been changed.
;
; Revision 1.3  1999/02/08 05:49:47  jprice
; Added Pat's 1937 kernel patches
;
; Revision 1.2  1999/01/22 04:16:39  jprice
; Formating
;
; Revision 1.1.1.1  1999/01/20 05:51:00  jprice
; Imported sources
;
;   Rev 1.3   06 Dec 1998  8:43:00   patv
;New floppy support functions.
;
;   Rev 1.2   29 Aug 1996 13:07:14   patv
;Bug fixes for v0.91b
;
;   Rev 1.1   01 Sep 1995 18:50:34   patv
;Initial GPL release.
;
;   Rev 1.0   02 Jul 1995  7:57:02   patv
;Initial revision.
;

%ifndef SYS
     %include "..\kernel\segs.inc"
     segment HMA_TEXT
%else
     segment _TEXT class=CODE
%endif
;
;
; Reset both the diskette and hard disk system
;
; BOOL fl_reset(WORD drive)
;
;       returns TRUE if successful
;

		global	_fl_reset
_fl_reset:
		mov	bx,sp
                mov     ah,0            ; BIOS reset disketter & fixed disk
		mov	dl,[bx+2]
                int     13h

                jc      fl_rst1         ; cy==1 is error
                mov     ax,1            ; TRUE on success
                ret

fl_rst1:        xor     ax,ax           ; FALSE on error
                ret


;
;
; Read DASD Type
;
; COUNT fl_readdasd(WORD drive)
;
;       returns 0-3 if successful, 0xFF if error
;
; Code   Meaning
;  0     The drive is not present
;  1     Drive present, cannot detect disk change
;  2     Drive present, can detect disk change
;  3     Fixed disk
;

		global	_fl_readdasd
_fl_readdasd:
                push    bp
                mov     bp,sp

                mov     dl,[bp+4]       ; get the drive number
                mov     ah,15h          ;  read DASD type
                int     13h

                jc      fl_rdasd1       ; cy==1 is error
                mov     al,ah           ; for the return code
                xor     ah,ah
                pop     bp              ; C exit
                ret

fl_rdasd1:      mov     ah,0            ; BIOS reset disketter & fixed disk
                int     13h
                mov     ax,0FFh         ; 0xFF on error
                pop     bp              ; C exit
                ret


;
;
; Read disk change line status
;
; COUNT fl_diskchanged(WORD drive)
;
;       returns 1 if disk has changed, 0 if not, 0xFF if error
;

		global	_fl_diskchanged
_fl_diskchanged:
                push    bp              ; C entry
                mov     bp,sp

                mov     dl,[bp+4]       ; get the drive number
                mov     ah,16h          ;  read change status type
                int     13h

                jc      fl_dchanged1    ; cy==1 is error or disk has changed
                xor     ax,ax           ; disk has not changed
                pop     bp              ; C exit
                ret

fl_dchanged1:   cmp     ah,6
                jne     fl_dc_error
                mov     ax,1
                pop     bp              ; C exit
                ret

fl_dc_error:    mov     ax,0FFh         ; 0xFF on error
                pop     bp              ; C exit
                ret


;
; Read the disk system status
;
; COUNT fl_rd_status(WORD drive)
;
; Returns error codes
;
; See Phoenix Bios Book for error code meanings
;

		global	_fl_rd_status
_fl_rd_status:
                push    bp              ; C entry
                mov     bp,sp

                mov     dl,[bp+4]       ; get the drive number
                mov     ah,1            ;  read status
                int     13h

                mov     al,ah           ; for the return code
                xor     ah,ah

                pop     bp              ; C exit
                ret


;
; Format Sectors
;
; COUNT fl_format(WORD drive, WORD head, WORD track, WORD sector, WORD count, BYTE FAR *buffer);
;
; Formats one or more tracks, sector should be 0.
;
; Returns 0 if successful, error code otherwise.
		global	_fl_format
_fl_format:
                mov     ah, 5
                jmp     short fl_common
;
; Read Sectors
;
; COUNT fl_read(WORD drive, WORD head, WORD track, WORD sector, WORD count, BYTE FAR *buffer);
;
; Reads one or more sectors.
;
; Returns 0 if successful, error code otherwise.
;
;
; Write Sectors
;
; COUNT fl_write(WORD drive, WORD head, WORD track, WORD sector, WORD count, BYTE FAR *buffer);
;
; Writes one or more sectors.
;
; Returns 0 if successful, error code otherwise.
;
		global	_fl_read
_fl_read:
                mov     ah,2            ; cmd READ
                jmp short fl_common
                
		global	_fl_verify
_fl_verify:
                mov     ah,4            ; cmd verify
                jmp short fl_common
                
		global	_fl_write
_fl_write:
                mov     ah,3            ; cmd WRITE

fl_common:                
                push    bp              ; C entry
                mov     bp,sp

                mov     dl,[bp+4]       ; get the drive (if or'ed 80h its
                                        ; hard drive.
                mov     dh,[bp+6]       ; get the head number
                mov     bx,[bp+8]       ; cylinder number (lo only if hard)

                mov     al,1            ; this should be an error code                     
                cmp     bx,3ffh         ; this code can't write above 3ff=1023
                ja      fl_error

                mov     ch,bl           ; low 8 bits of cyl number
                
                xor     bl,bl           ; extract bits 8+9 to cl
                shr     bx,1
                shr     bx,1
                                
                
                mov     cl,[bp+0Ah]     ; sector number
                and     cl,03fh         ; mask to sector field bits 5-0
                or      cl,bl           ; or in bits 7-6

                mov     al,[bp+0Ch]     ; count to read/write
                les     bx,[bp+0Eh]   ; Load 32 bit buffer ptr

                int     13h             ;  write sectors from mem es:bx

                mov     al,ah
                jc      fl_wr1          ; error, return error code
                xor     al,al           ; Zero transfer count
fl_wr1:
fl_error:
                xor     ah,ah           ; force into < 255 count
                pop     bp
                ret


%if 0
;
;
; Get number of disks
;
; COUNT fl_nrdrives(VOID)
;
;       returns AX = number of harddisks
;

		global	_fl_nrdrives
_fl_nrdrives:
                push    di              ; di reserved by C-code ???

                mov     ah,8            ; DISK, get drive parameters
                mov     dl,80h
                int     13h
                mov     ax,0            ; fake 0 drives on error
                jc      fl_nrd1
                mov     al,dl
fl_nrd1:
                pop     di
                ret
%endif

; ---------------------------------------------------------------------------
;                             LBA Specific Code
;
;
; Added by:  Brian E. Reifsnyder
; ---------------------------------------------------------------------------

;
;
; Check for Enhanced Disk Drive support (EDD).  If EDD is supported then
;       LBA can be utilized to access the hard disk.
;
; unsigned int lba_support(WORD hard_disk_number)
;
;       returns TRUE if LBA can be utilized
;
%if 0
		global  _fl_lba_support
_fl_lba_support:
		push    bp              ; C entry
                mov     bp,sp

		mov     dl,[bp+4]       ; get the drive number
		mov     ah,41h          ; cmd CHECK EXTENSIONS PRESENT
		mov     bx,55aah
		int     13h             ; check for int 13h extensions

		jc      fl_lba_support_no_lba   
					; if carry set, don't use LBA
		cmp     bx,0aa55h
		jne     fl_lba_support_no_lba       
					; if bx!=0xaa55, don't use LBA
		test    cl,01h
		jz      fl_lba_support_no_lba
					; if DAP cannot be used, don't use
					; LBA
		mov     ax,0001h        ; return TRUE (LBA supported)

		pop     bp              ; C exit
		ret

fl_lba_support_no_lba
		xor    ax,ax            ; return FALSE (LBA not supported)
		pop     bp              ; C exit
		ret

;
; Read Sectors
;
; COUNT fl_lba_read(WORD drive, WORD dap_segment, WORD dap_offset);
;
; Reads one or more sectors.
;
; Returns 0 if successful, error code otherwise.
;
;
; Write Sectors
;
; COUNT fl_lba_write(WORD drive, WORD dap_segment, WORD dap_offset);
;
; Writes one or more sectors.
;
; Returns 0 if successful, error code otherwise.
;
		global  _fl_lba_read
_fl_lba_read:
		mov     ah,42h          ; cmd READ
		jmp short fl_lba_common
		
		global  _fl_lba_write
_fl_lba_write:
		mov     ax,4300h        ; cmd WRITE without verify
		jmp short fl_lba_common

		global  _fl_lba_write_and_verify
_fl_lba_write_and_verify:
		mov     ax,4302h        ; cmd WRITE with VERIFY
		jmp short fl_lba_common ; This has been added for
					; possible future use

		global  _fl_lba_verify
_fl_lba_verify:
		mov     ah,44h          ; cmd VERIFY

fl_lba_common:                
		push    bp              ; C entry
		mov     bp,sp
		
		push    ds

		mov     dl,[bp+4]       ; get the drive (if or'ed 80h its
					; hard drive.
		lds     si,[bp+6]       ; get far dap pointer
		int     13h             ; read from/write to drive
		
		mov     al,ah           ; place any error code into al
		
		xor     ah,ah           ; zero out ah           

		pop     ds
		
		pop     bp
		ret
%endif

; COUNT fl_lba_ReadWrite(BYTE drive, UWORD mode, VOID FAR *dap_p)
;
; Returns 0 if successful, error code otherwise.
;
		global  _fl_lba_ReadWrite
_fl_lba_ReadWrite:
		push    bp              ; C entry
		mov     bp,sp
		
		push    ds
		push    si              ; wasn't in kernel < KE2024Bo6!!

		mov     dl,[bp+4]       ; get the drive (if or'ed 80h its
		mov     ax,[bp+6]       ; get the command
		lds     si,[bp+8]       ; get far dap pointer
		int     13h             ; read from/write to drive
		
		mov     al,ah           ; place any error code into al
		
		xor     ah,ah           ; zero out ah           

                pop     si
		pop     ds
		
		pop     bp
		ret

global _fl_readkey
_fl_readkey:    xor	ah, ah
		int	16h
		ret

global _fl_setdisktype
_fl_setdisktype:
                push    bp
                mov     bp, sp
                mov     dl,[bp+4]       ; drive number
                mov     al,[bp+6]       ; disk type
                mov     ah,17h
                int     13h
                mov     al,ah
                xor     ah,ah
                pop     bp
                ret
                        
global _fl_setmediatype
_fl_setmediatype:
                push    bp
                mov     bp, sp
                push    di
        
                mov     dl,[bp+4]       ; drive number
                mov     bx,[bp+6]       ; number of tracks
		dec	bx		; should be highest track
                mov     ch,bl           ; low 8 bits of cyl number
                
                xor     bl,bl           ; extract bits 8+9 to cl
                shr     bx,1
                shr     bx,1
                
                mov     cl,[bp+8]       ; sectors/track
                and     cl,03fh         ; mask to sector field bits 5-0
                or      cl,bl           ; or in bits 7-6

                mov     ah,18h
                int     13h
                mov     al,ah
                mov     ah,0
		jc	skipint1e
                mov     bx,es
                xor     dx,dx
                mov     es,dx
		cli
                mov     [es:0x1e*4  ], di
                mov     [es:0x1e*4+2], bx ; set int 0x1e table to es:di (bx:di)
		sti
skipint1e:		
                pop     di
                pop     bp
                ret
                
                        
