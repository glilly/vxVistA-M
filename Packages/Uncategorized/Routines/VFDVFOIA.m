VFDVFOIA ;DSS/SGM - SETUP VA FOIA CACHE.DAT ;31AUG2009
 ;;2009.2;DSS,INC VXVISTA OPEN SOURCE;;01 Dec 2009
 ;Copyright 1995-2009,Document Storage Systems Inc. All Rights Reserved
 ;
 ;This routine was written by Document Storage Systems, Inc for the VSA
 ;This routine was written for the VSA for Cache only.
 ;It will perform much of the setup that is necessary
 ;to make the VA's FOIA Cache.dat ready for use on your
 ;system.
 ;
 ;This routine should be installed in your VAH account
 ;or your production account.
 ;
 ;DBIA# Supported References
 ;----- --------------------------------------------
 ; 2050 MSG^DIALOG
 ; 2053 ^DIE: CHK, FILE, UPDATE
 ;10013 ^DIK
 ;10097 GETENV^%ZOSV
 ;10104 $$UP^XLFSTR
 ;
 ;MUMPS Globals touched: IBE,%ZIS,ZOSF,%ZTSCH,%ZTSK,DIC,DD,XTV,XMB,HLCS,XWB,MPIF,DG,VA
 ;
 ;Description of VFDV(subscript) array
 ;Subscript  Value
 ;---------  --------------------------------------------
 ;%SYS       0, 1:%ZSTART, 2:%ZSTOP, 3:Both
 ;AUDIT
 ;C-VT320    ptr to file 3.2 or <null>
 ;DEFDIR     default HFS directory
 ;DNS        DNS IP Address
 ;DOM,0      IEN of DOMAIN created
 ;DOMNAME    name of DOMAIN created
 ;ENV        p1^p2^p3^p4
 ;             p1 = namespace   p3 = machine name
 ;             p2 = database    p4 = database:<cache instance name>
 ;INSTNAME   Name of File 4 entry       
 ;INST,0     ptr to file 4 of institution created
 ;MG         ptr to file 3.8 - mail group VFDV SYS MGMT
 ;P-OTHER    ptr to file 4.3 or <null>
 ;PORT       Broker port#
 ;TZ         ptr to file 4.4 Mailman timezone
 ;VOL        volume name
 ;
 I $O(^VFDVFOIA(0)) W !,"INITIALIZATION ALREADY RUN, ",$$FMTE^XLFDT($$HTFM^XLFDT($O(^(0)))) Q
 ;
 N I,J,X,Y,Z,VFDTAB,VFDV,VFDVMODE
 S VFDVMODE="B" ; the "wino" mode!
 Q:$$INIT<1  Q:$$BEG^VFDVFOI2<1  ;**GFT
 D ^VFDVFOI2 ; SET UP VFDTAB()
 D D1^VFDVFOI1 ; getenv^%zosv - vfdv("env")
 ;
 ;HERE IS WHERE WE GET ALL THE ANSWERS, WITHOUT CHANGING ANYTHING
 Q:$$A^VFDVFOI3  D DSP
 S X="Are you sure you want to do this [no turning back]? "
 S Y="NO" Q:$$YN^VFDVFOI3(X,Y)<1
 ;
 W ! ;NOW WE GO DO IT!!
 D D2^VFDVFOI1 ; %zosf("prod"),%zosf("mgr")
 D D3^VFDVFOI1 ; %zosf("vol")
 D D15^VFDVFOI1 ; mail group
 D D4^VFDVFOI1 ; taskman globals
 D D5^VFDVFOI1 ; Volume (14.5)
 D D6^VFDVFOI1 ; Taskman Site Params (14.7)
 ;D D7^VFDVFOI1,DSP ; init FM -- done in INIT below, if necessary
 ;D D8^VFDVFOI1,DSP ; init kernel -- done in INIT below, if necessary
 D D9^VFDVFOI1 ; Domain (4.2)
 D D11^VFDVFOI1 ; Institution
 D D12^VFDVFOI1 ; Kernel Sys Param (8989.3) will give us DEFAULT DIRECTORY FOR HFS
 D D10GFT^VFDVFOIT ; set up devices without answers from user
 D D13^VFDVFOI1 ; Mailman Site Param (4.3)
 D D14^VFDVFOI1 ; RPC Broker Site Param (8994.1)
 D D16^VFDVFOI1 ; add mail group to bulletins
 D D17^VFDVFOI1 ; init HL
 ;D D19^VFDVFOI4 ; %zstart, %zstop routines  --THEY DON'T EXIST YET
 D D20^VFDVFOI1 ; DD("site")
 I $G(VFDV("AUDIT"))=1 D D21AUDIT^VFDVFOIT,S(22,2) ;AUDITING -- GFT
 I $D(^VA(200,1,0)),$P(^(0),U,3)="" D  D S(19,2) ;GIVE USER NUMBER 1 AN ACCESS CODE --GFT
 .N DIE,DR,DA
 .S DIE=200,DR="2////AA12345",DA=1 D ^DIE
 D D22IVM^VFDVFOI1 ;301.9
 D D23^VFDVFOIT,DSP ;40.8,389.9,984.1
 S X=$$YN^VFDVFOI3 D ODSP^VFDVFOI2
 D D18^VFDVFOI4 S X=$$YN^VFDVFOI3 ; schedule tasks
 N ARR D TASK^VFDVFOI2
 I $$YN^VFDVFOI3("Do you wish to start Taskman now? ","NO")>0 D ^ZTMB,WAIT^DICD H 10 D ^ZTMON
 S ^VFDVFOIA($H)=$G(DUZ) D END
 Q
 ;
END ; final msg in vfdvfoia
 ;;Initialization of the VA's FOIA Cache.dat is completed.
 ;;In a few minutes, D ^%SS at the programmer's prompt to view the
 ;; system status.
 ;; 1. Mailman should have started.
 ;; 2. Broker should have started.
 ;; 3. HL manager, one in-bound filer, and one out-bound filer should
 ;;    have started.
 ;;
 N I,X W !
 F I=1:1 S X=$P($T(END+I),";",3) Q:X=""  W !?3,X
 Q
 ;
 ;
 ;
 ;
S(A,B) D S^VFDVFOI2(A,B) ;ADD TICK AND RE-DISPLAY
DSP D DSP^VFDVFOI2 Q
 ;
INIT() ;modified by GFT    files %routines an Globals if needed
 I '$D(^%ZOSF("TEST")) D  I '$D(^%ZOSF("TEST")) Q -1
 .I $$CACHE D ^ZOSFONT
 I $T(^%DT)=""!($T(NOW^%DTC)="") D  I $T(^%DT)="" Q -1
 .I $$ZSAVE("DIRCR","%RCR"),$$ZSAVE("DIDTC","%DTC"),$$ZSAVE("DIDT","%DT")
 I $D(^DD)=0 D ^DINIT I $D(^DD)=0 Q -1
 I $T(HOME^%ZIS)="" D ^ZTMGRSET I $T(HOME^%ZIS)="" Q -1
 D DT^DICRW,HOME^%ZIS
 S DUZ(0)="@" S:$G(DUZ)<1 DUZ=.5 Q 1
 ;
 ;
 ;
CACHE() ; Boolean ext funct - 1:cache sys  0:not a cache sys
 I $T(VERSION^%ZOSV)="" Q 0
 Q $$VERSION^%ZOSV(1)["Cache"
 ;
 ;
 ;
ZSAVE(ROU,RENAME,NAMESPAC) ;GFT:  SAVE 'ROU' ROUTINE AS 'RENAME' WHERE IT SHOULD GO
 I $G(RENAME)="" Q 0
 I '$$CACHE Q 0
 I $T(@("^"_ROU))="" Q 0
 N Y,GO,COMEBACK S GO="",COMEBACK=""
 I $G(NAMESPAC)]"" S GO="ZN """_NAMESPAC_""""
 E  I RENAME?1"%".E ;S GO="ZN ""%SYS"""
 I GO]"" Q:$G(^%ZOSF("UCI"))="" 0 X ^("UCI") Q:Y<0 0 S COMEBACK="ZN """_$P(Y,",")_""""
 X "ZL @ROU "_GO_" ZS @RENAME  ZR  "_COMEBACK
 Q 1
 ;
 ;
 ;
 ;
 ;
 ;
 ;
 ;
 ;
DSS ; this entry point is if you just want to set up the %ZSTART and
 ; %ZSTOP programs and schedule the tasks to start up when Taskman
 ; starts up.
 N I,X,Y,Z,DSS,VFDV
 S DSS=1,VFDV("%SYS")=3
 S X="Do you wish to delete any existing user defined Cache startup routine? "
 I $$YN^VFDVFOI3(X,1)>0 D DSSINIT
 D D1^VFDVFOI1
 D D6^VFDVFOI1
 D D19^VFDVFOI4
 D D18^VFDVFOI4
 D TASK^VFDVFOI2
 D ^ZTMB H 5 D ^%SS
 Q
 ;
DSSINIT ; remove exisitng copies of routines in %SYS
 ;;ZN "%SYS" ZR  ZS ZSTU ZS %ZSTART ZS %ZSTOP ZN "VAH"
 X $P($T(DSSINIT+1),";",3)
 Q
