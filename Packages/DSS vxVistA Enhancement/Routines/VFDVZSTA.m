VFDVZSTA ;DSS/SGM - Initialize Cache ;16 Sep 2009 21:26
 ;;2.0;DSS,INC VXVISTA OPEN SOURCE;;29 Jul 2011;Build 92
 ;Copyright 1995-2011,Document Storage Systems Inc. All Rights Reserved
 ;
 ; This routine should only be invoked via the ^VFDVZST routine
 ;ICR#  SUPPORTED DESCRIPTION
 ;----  ----------------------------------------------
 ;      DT^DICRW
 ;      FILE^DIE
 ;      ^HLCS: CLEAR,LLP
 ;      STOPALL^HLCS1
 ;      HOME^%ZIS
 ;      GETENV^%ZOSV
 ;      GET^XPAR
 ;      DUZ^XUP
 ;      STOPALL^XWBTCP
 ;      ^ZTMB
 ;      GROUP^ZTMKU
 ;      Direct global read/set of ^XMB(1,1)
 ;      Direct global read of ^%ZIS(14.5,1)
 ;      Direct global read of ^HLCS(869.3)
 ;      Set of fields 1,3 in file 14.5 using Fileman
 ;      Set of field 53 in file 869.3 using Fileman
 ;
 N I,J,X,Y,Z,CACHE,CH,VFDDUZ
 S CACHE=$$CACHE
 ;;Start Taskman
 ;;Stop Taskman (and all tasked jobs)
 ;;Start Broker on this node
 ;;Stop Broker on this node
 ;;Initialize Scheduled Tasks
 ;;Create Cache %ZSTART and %ZSTOP routines
 S CH=$$ASK^VFDVZSTB I CH>0 D @CH
OUT I $D(VFDDUZ) K DUZ M DUZ=VFDDUZ
 Q
 ;
START ; silent entry point for start up
 N A,I,J,X,Y,Z,CACHE,CUR,DIQUIET,QUIET,VAL,VFDDUZ,VFDENV,VNULL,ZTQUEUED
 Q:'$$INIT
 D GETVAL(1,VAL) Q:VAL=""
 D MMCLEAR
 D VOLCLEAR
 D XWBSTART
 D ZTM
 D USER(1)
 D CLOSE
 G OUT
 ;
STOP ; silent entry point for shutdown
 N A,I,J,X,Y,Z,CACHE,CUR,DIQUIET,QUIET,VAL,VFDDUZ,VFDENV,VNULL,ZTQUEUED
 Q:'$$INIT
 D GETVAL(2,.VAL) Q:VAL=""
 D MMSTOP
 D HLSTOP
 D XWBSTOP
 D XWBSTOP1
 D USER(2)
 D ZTMSTOP
 D CLOSE
 G OUT
 ;
VFDVFOIA ;called from VFDVFOIA via VFDVZST
 ;Q:$D(ZTQUEUED)  ;A queued Taskman process detected, nothing done
 ;N A,I,X,Y,Z,DIQUIET,RTN,TUCI,ZTQUEUED
 ;S:$G(IOF)="" X=$$INIT I $G(CLEAR) W @IOF
 ;W @IOF D DSP^VFDVZST0(,"T1",1,1,1) S Y=$$DIR^VFDVZST0(,1) Q:'CACHE
 ;S A(1)="The current Namespace is "_CUR
 ;W !! D DSP^VFDVZST0(,"T2",1,1,2,.A) I $$DIR^VFDVZST0(,2)>0 D C
 Q
 ;
 ;-----------------------  PRIVATE SUBROUTINES  -----------------------
1 N VAL S VAL("ZTM")="" D ZTM Q
2 N VAL S VAL("ZTM")="" D ZTMSTOP Q
3 N VAL S VAL("XWB")="" D STRT^VFDXWB Q
4 N VAL S VAL("XWB")="" D STOP^VFDXWB Q
5 Q
6 Q:'$$H2^VFDVZSTB
 N I,X,Y,Z,CODE,ROUDEL,SY
 S SY="%SYS",CUR=$$CUR
 S ROUDEL("ZSTU")="" F X="",0,1,2,U S ROUDEL("VFDVZST"_X)=""
 S CODE="N X ZR  S X=0 F  S X=$O(ROUDEL(X)) Q:X=""""  ZS @X"
 W !!?3,"Delete routines VFDVZSTU, VFDVZST0, VFDVZST1, VFDVZST2, ZSTU"
 X CODE W !?3,"Namespace: "_CUR_"      done!"
 S X=$ZU(5,SY) X CODE S X=$ZU(5,CUR)
 W !?3,"Namespace: "_CUR_"      done!"
 S CODE="N I ZR  X ""F I=1:1 Q:'$D(ROU(I))  ZI ROU(I)"" ZS @ROU"
 W !?3,"Installing the %ZSTART routine" D ROU(1)
 W !?3,"Installing the %ZSTOP routine" D ROU(2)
 Q
 ;
CACHE() Q $$VERSION^%ZOSV(1)["Cache"
 ;
CLOSE C:$G(VNULL)'="" VNULL Q
 ;
CUR() Q $ZU(5)
 ;
GETENV() ; get the name of this node
 N I,X,Y D GETENV^%ZOSV Q $P(Y,U,4)
 ;
GETVAL(INST,VAL) ; get instance of a parameter
 ; INST - opt - 1:startup or 2:shutdown - default to 1
 ; .VAL - return variable - VAL = value plus VAL(mnemonic)=""
 ;NOTE: parameter value = ZTM means that Taskman will start up HL7
 ;      processes, mailman, and broker
 N I,X,Y,Z,VFDERR
 S INST=$G(INST) S:INST="" INST=1
 I INST'=1!(INST'=2) Q ""
 S X=$$XPAR("ZTM."_VFDENV,"VFD IT ZSTU",INST)
 F I=1:1:$L(X,",") S Y=$P(X,",",I) S:Y'="" VAL(Y)=""
 S VAL=X
 S X=$$XPAR(ENT,"VFD IT ZSTU USER",INST)
 I X'="" S VAL("USER")=$TR(X,"~",U)
 Q
 ;
INIT() ;
 N I,X,Y
 S (DIQUIET,ZTQUEUED)=1
 Q:'$$TST("DT^DICRW") 0
 D DT^DICRW,HOME^%ZIS
 S CACHE=$$CACHE,CUR=$$CUR
 I $G(QUIET),CACHE S VNULL="//./nul" O VNULL U VNULL
 M VFDDUZ=DUZ S:'$G(DUZ) VFDDUZ=0
 I $G(DUZ)<1 D DUZ^XUP(.5) S DUZ(0)="@"
 S VFDENV=$$GETENV
 Q 1
 ;
ROU(L) ; save %ZSTART/%ZTOP routines
 ; L - req - 1:%zstart  2:%zstop
 N A,I,X,Y,Z,ROU
 D ROU^VFDVZSTB(L)
 I L=1 S X=$P($T(UCI^%ZSTART),";;",2)
 I L=2 S X=$P($T(UCI^%ZSTOP),";;",2)
 S Y=$O(ROU(" "),-1),Z="UCI ;;",Z(CUR)=""
 S A=$P(X,";") I A'="" S Z(A)=""
 S A=$P(X,U) I A'="" S Z(A)=""
 I X[";" F I=2:1 S A=$P(X,";",I) Q:A=""  S Z(A)=""
 I X["^" F I=2:1 S A=$P(X,";",I) Q:A=""  S Z(A)=""
 S A=0 F  S A=$O(Z(A)) Q:A=""  S Z=Z_A_U
 S ROU(Y)=Z,X=$ZU(5,SY) X CODE S X=$ZU(5,CUR)
 Q
 ;
TST(ROU,V) ; Boolean test to see if it can be done
 ; ROU - opt - [tag]^routine - test to see if it exists
 ;   V - req - mnemonic of task to perform
 I $G(V)="" Q 0
 I '$D(VAL(V)) Q 0
 I $G(ROU)="" Q 1
 I ROU["^",$T(@ROU)'="" Q 1
 Q 0
 ;
VALID ; validate value for param VFD IT ZSTU USER
 ; X - req - tag^routine for user defined to run at startup.shutdown
 ; acceptable input routine, ~routine, or tag~routine
 ; Cache Object Script names not supported
 N I,T,TAG,RTN,VAL
 S T="~",VAL("USER")=""
 I $L(X,T)>2 K X Q
 F I=1:1:$L(X) I $E(X,I)?1P,$E(X,I)'=T K X Q
 I $D(X) S:X'[T X=T_X D
 .S TAG=$P(X,T),RTN=$P(X,T,2)
 .I TAG'?.8UN K X
 .I RTN'?1U1.15UN K X
 .I $D(X),'$$TST($TR(X,T,U),"USER") K X
 .Q
 Q
 ;
VALIDATE ; validate value for param VFD IT ZSTU
 ; X - req - string of mnemonics to be done on this node
 N A,I,L,Y I $G(V)="" K X Q
 F I=1:1 S A=$P("HL^XOB^XWB^ZTM",U,I) Q:A=""  S L(A)=""
 F I=1:1:$L(V,",") S A=$P(V,",",I) I $S(A="":1,1:'$D(L(A))) K X Q
 Q
 ;
XPAR(ENT,PARM,INST)  Q $$GET^XPAR(ENT,PARM,INST,"Q")
 ;
 ;-----------  CODE TO ACTUALLY PERFORM AT STARTUP/SHUTDOWN  ----------
HLSTOP ; stop all HL7
 ; 9/6/2009 - need to add stop HLO
 Q:'$$TST("CLEAR^HLCS2","ZTM")
 N I,X
 D CLEAR^HLCS2,LLP^HLCS2(1)
 F X="IN","OUT" D STOPALL^HLCS1(X)
 N DIERR,VFDV,VFDER S I=+$O(^HLCS(869.3,0)) Q:'I
 S VFDV(869.3,I_",",53)=1 D FILE^DIE(,"VFDV","VFDER") H 10
 Q
 ;
MMCLEAR ; clear Mailman stop filer flag
 I $$TST(,"ZTM"),$G(^XMB(1,1,0))'="" S $P(^(0),U,16)=""
 Q
 ;
MMSTOP ; stop Mailman filers
 I $$TST(,"ZTM"),$G(^XMB(1,1,0))'="" S $P(^(0),U,16)=1
 Q
 ;
USER ; user defined startup/shutdown actions to perform
 ; Set the Kernel Parameter VFD IT ZSTU USER with routine to run
 I $D(VAL("USER")) D @VAL("USER")
 Q
 ;
VOLCLEAR ; clear volume set flags
 Q:'$$TST("FILE^DIE","ZTM")
 N I,VFD
 S I=0 F  S I=$O(^%ZIS(14.5,I)) Q:'I  S VFD=$G(^(I,0)) D
 .N DIERR,IEN,VFDV,VFDER S IEN=I_","
 .I "N"'[$P(VFD,U,2) S VFDV(14.5,IEN,1)=""
 .I "N"'[$P(VFD,U,4) S VFDV(14.5,IEN,3)=""
 .I $D(VFDV) N I D FILE^DIE(,"VFDV","VFDER")
 .Q
 Q
 ;
XWBSTART ; start listener on this node
 Q:'$$TST("GETPORT^VFDXWB","XWB")
 N I,X,IENS,PORT,QUIET,TYPE
 S QUIET=1,X=$$GETPORT^VFDXWB(,1) Q:X=-1
 S PORT=+X,IENS=$P(X,U,2),TYPE=$P(X,U,3)
 I 'TYPE D STRTOLD^VFDXWB
 I TYPE D STRTNEW^VFDXWB
 Q
 ;
XWBSTOP ; stop all Broker Listeners
 I '$D(VAL("XWB")),$$TST("STOPALL^XWBTCP","ZTM") D STOPALL^XWBTCP
 Q
 ;
XWBSTOP1 ; stop listener on this node
 Q:'$$TST("GETPORT^VFDXWB","XWB")
 N I,X,IENS,PORT,QUIET,TYPE
 S QUIET=1,X=$$GETPORT^VFDXWB(,1) Q:X=-1
 S PORT=+X,IENS=$P(X,U,2),TYPE=$P(X,U,3)
 I 'TYPE D STOPOLD^VFDXWB
 I TYPE D STOPNEW^VFDXWB
 Q
 ;
ZTM ; start taskman
 I $$TST("^ZTMB","ZTM") D ^ZTMB
 Q
 ;
ZTMSTOP ; shutdown all Taskman
 Q:'$$TST("^ZTMKU","ZTM")
 D GROUP^ZTMKU("SMAN(NODE)"),GROUP^ZTMKU("SSUB(NODE)")
 Q
