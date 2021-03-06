#
# Makefile for Borland C++ 3.1 for kernel.sys
#
# $Id: makefile 750 2004-01-25 22:37:20Z bartoldeman $
#

!include "../mkfiles/generic.mak"

RELEASE = 1.00

# Compiler and Options 

INCLUDE=..\hdr
LIB=    $(COMPILERBASE)\lib

LIBPATH = .
#AFLAGS      = /Mx /DSTANDALONE=1 /I..\HDR

LIBS        =..\lib\device.lib ..\lib\libm.lib
#INITCFLAGS =$(ALLCFLAGS) -zAINIT -zCINIT_TEXT -zDIB -zRID -zTID -zPIGROUP -zBIB \
#-zGIGROUP -zSIGROUP
#CFLAGS     =$(ALLCFLAGS) -zAHMA -zCHMA_TEXT
HDR=../hdr/

#               *Implicit Rules*
#     'standard' compiles

.c.obj :
	$(CC) $(CFLAGS) $<

#               *List Macros*


OBJS1=kernel.obj entry.obj io.obj console.obj serial.obj printer.obj dsk.obj \
sysclk.obj
OBJS2=asmsupt.obj execrh.obj nlssupt.obj procsupt.obj dosidle.obj int2f.obj \
nls_hc.obj
OBJS3= apisupt.obj intr.obj irqstack.obj blockio.obj chario.obj systime.obj \
error.obj
OBJS4=break.obj dosfns.obj fatdir.obj fatfs.obj fattab.obj fcbfns.obj \
inthndlr.obj
OBJS5=ioctl.obj dosnames.obj memmgr.obj task.obj newstuff.obj nls.obj network.obj
OBJS6=prf.obj misc.obj strings.obj syspack.obj lfnapi.obj
OBJS7=main.obj config.obj initoem.obj inithma.obj dyninit.obj iprf.obj \
initdisk.obj initclk.obj
OBJS = $(OBJS1) $(OBJS2) $(OBJS3) $(OBJS4) $(OBJS5) $(OBJS6) $(OBJS7)

#               *Explicit Rules*

production:     ..\bin\kernel.sys

..\bin\kernel.sys: kernel.sys
		copy kernel.sys ..\bin
		copy kernel.sys ..\bin\$(THETARGET).sys
		copy kernel.map ..\bin\$(THETARGET).map

kernel.sys:	kernel.exe ..\utils\exeflat.exe
		$(XUPX) kernel.exe
		..\utils\exeflat kernel.exe kernel.sys 0x60 -S0x10 -S0x8B $(UPXOPT)

clobber:        clean
		-$(RM) kernel.exe kernel.sys status.me

clean:
		-$(RM) *.res *.obj *.bak *.crf *.xrf *.map *.lst *.cod *.err *.lnk

# XXX: This is a very ugly way of linking the kernel, forced upon us by the
# inability of Turbo `make' 2.0 to perform command line redirection. -- ror4

ECHOTO=..\utils\echoto

kernel.res: $(OBJS) $(LIBS)
	-$(RM) kernel.res
	$(ECHOTO) kernel.res $(OBJS1)+
	$(ECHOTO) kernel.res $(OBJS2)+
	$(ECHOTO) kernel.res $(OBJS3)+
	$(ECHOTO) kernel.res $(OBJS4)+
	$(ECHOTO) kernel.res $(OBJS5)+
	$(ECHOTO) kernel.res $(OBJS6)+
	$(ECHOTO) kernel.res $(OBJS7)
	$(ECHOTO) kernel.res kernel.exe
	$(ECHOTO) kernel.res kernel.map
	$(ECHOTO) kernel.res $(LIBS)

kernel.exe: kernel.res $(OBJS) $(LIBS)
	$(LINK) @kernel.res;

#               *Individual File Dependencies*
kernel.obj: kernel.asm segs.inc ludivmul.inc

console.obj: console.asm io.inc

printer.obj: printer.asm io.inc

serial.obj: serial.asm io.inc

entry.obj: entry.asm segs.inc $(HDR)stacks.inc

apisupt.obj: apisupt.asm segs.inc

execrh.obj: execrh.asm segs.inc

int2f.obj: int2f.asm segs.inc

intr.obj: intr.asm segs.inc

io.obj: io.asm segs.inc

irqstack.obj: irqstack.asm

nls_hc.obj: nls_hc.asm segs.inc

nlssupt.obj: nlssupt.asm segs.inc

procsupt.obj: procsupt.asm segs.inc $(HDR)stacks.inc

dosidle.obj: dosidle.asm segs.inc

# XXX: Special handling for initialization modules -- this is required because
# TC 2.01 cannot handle `#pragma option' like TC 3 can. -- ror4

INITHEADERS=init-mod.h init-dat.h 

CONFIGURATION = turboc.cfg makefile ..\mkfiles\generic.mak ..\mkfiles\$(COMPILER).MAK

HEADERS=\
    $(HDR)portab.h $(HDR)device.h $(HDR)mcb.h $(HDR)pcb.h \
    $(HDR)fat.h $(HDR)fcb.h $(HDR)tail.h $(HDR)time.h $(HDR)process.h \
    $(HDR)dcb.h $(HDR)sft.h $(HDR)cds.h $(HDR)exe.h $(HDR)fnode.h     \
    $(HDR)dirmatch.h $(HDR)file.h $(HDR)clock.h $(HDR)kbd.h $(HDR)error.h  \
    $(HDR)version.h  globals.h proto.h dyndata.h 

# XXX: I generated these using `gcc -MM' and `sed', so they may not be
# completely correct... -- ror4

blockio.obj: blockio.c    $(HEADERS) $(CONFIGURATION)  

break.obj: break.c        $(HEADERS) $(CONFIGURATION)  

chario.obj: chario.c      $(HEADERS) $(CONFIGURATION)  

dosfns.obj: dosfns.c      $(HEADERS) $(CONFIGURATION)  

dosnames.obj: dosnames.c  $(HEADERS) $(CONFIGURATION)  

dsk.obj: dsk.c            $(HEADERS) $(CONFIGURATION)  

error.obj: error.c        $(HEADERS) $(CONFIGURATION)  

fatdir.obj: fatdir.c      $(HEADERS) $(CONFIGURATION)  

fatfs.obj: fatfs.c        $(HEADERS) $(CONFIGURATION)  

fattab.obj: fattab.c      $(HEADERS) $(CONFIGURATION)  

fcbfns.obj: fcbfns.c      $(HEADERS) $(CONFIGURATION)  

inthndlr.obj: inthndlr.c  $(HEADERS) $(CONFIGURATION)  

ioctl.obj: ioctl.c        $(HEADERS) $(CONFIGURATION)  

memmgr.obj: memmgr.c      $(HEADERS) $(CONFIGURATION)  

misc.obj: misc.c          $(HEADERS) $(CONFIGURATION)  

lfnapi.obj: lfnapi.c      $(HEADERS) $(CONFIGURATION)

newstuff.obj: newstuff.c  $(HEADERS) $(CONFIGURATION)  

network.obj: network.c    $(HEADERS) $(CONFIGURATION)  

nls.obj: nls.c            $(HEADERS) $(CONFIGURATION)  

# \
# 001-437.nls

prf.obj: prf.c  $(HDR)portab.h $(CONFIGURATION)

strings.obj: strings.c  $(CONFIGURATION)

sysclk.obj: sysclk.c    $(HEADERS) $(CONFIGURATION)

syspack.obj: syspack.c  $(HEADERS) $(CONFIGURATION)

systime.obj: systime.c  $(HEADERS) $(CONFIGURATION)

task.obj: task.c        $(HEADERS) $(CONFIGURATION)

# now the funny stuff :-)
# Files in the INIT segment

#   $(CC) $(INITCFLAGS) -c $*.c
#   patchobj $*.obj $(INITPATCH)

config.obj:   config.c  $(INITHEADERS) $(HEADERS) $(CONFIGURATION)  
	$(CC) $(INITCFLAGS) $*.c
	$(INITPATCH) $*.obj

initoem.obj:  initoem.c  $(INITHEADERS) $(HEADERS) $(CONFIGURATION)  
	$(CC) $(INITCFLAGS) $*.c
	$(INITPATCH) $*.obj

main.obj:     main.c  $(INITHEADERS) $(HEADERS) $(CONFIGURATION) 
	$(CC) $(INITCFLAGS) $*.c
	$(INITPATCH) $*.obj

inithma.obj:  inithma.c  $(INITHEADERS) $(HEADERS) $(CONFIGURATION)  
	$(CC) $(INITCFLAGS) $*.c
	$(INITPATCH) $*.obj

dyninit.obj:  dyninit.c  $(INITHEADERS) $(HEADERS) $(CONFIGURATION)  
	$(CC) $(INITCFLAGS) $*.c
	$(INITPATCH) $*.obj

initdisk.obj: initdisk.c  $(INITHEADERS) $(HEADERS) $(CONFIGURATION)  
	$(CC) $(INITCFLAGS) $*.c
	$(INITPATCH) $*.obj

initclk.obj: initclk.c  $(INITHEADERS) $(HEADERS) $(CONFIGURATION)  
	$(CC) $(INITCFLAGS) $*.c
	$(INITPATCH) $*.obj

#the printf for INIT_TEXT - yet another special case, this file includes prf.c
iprf.obj: iprf.c prf.c $(HDR)portab.h $(CONFIGURATION)
	$(CC) $(INITCFLAGS) $*.c
	$(INITPATCH) $*.obj
