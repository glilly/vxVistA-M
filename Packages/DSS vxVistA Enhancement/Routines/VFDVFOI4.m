VFDVFOI4 ;DSS/SGM - SETUP VA FOIA CACHE.DAT ;27AUG2009
 ;;2009.2;DSS,INC VXVISTA OPEN SOURCE;;01 Dec 2009
 ;Copyright 1995-2009,Document Storage Systems Inc. All Rights Reserved
 ;
 ;This routine was written by Document Storage Systems, Inc for the VSA
 ;This routine was written for the VSA for Cache only.  It will perform
 ;much of the setup that is necessary to make the VA's FOIA Cache.dat
 ;ready for use on your system.
 ;
 ;This routine should be installed in your VAH account or your production
 ;account.  This routine is only to be called by VFDVFOIA.
 ;
 ;DBIA# Supported References
 ;----- --------------------------------------------
 ;10096 Execute ^%ZOSF nodes
 ;10103 $$FMADD^XLFDT
 ;
D18 ; schedule certain tasks
 N I,J,X,Y,Z,UCI,VDT
 S VDT=$$FMADD^XLFDT(DT,-1)
 F I=3:1 S X=$P($T(OPT+I),";",3,99) Q:X=""  D
 .N I,ARR,VOPT
 .F J=1:1:6 S VOPT(J)=$P(X,";",J)
 .I VOPT(3)?4N S VOPT(3)=+(VDT_"."_VOPT(3))
 .S X=+$O(^DIC(19,"B",VOPT(2),0)) Q:'X  S VOPT(0)=X
 .S VOPT=+$O(^DIC(19.2,"B",X,0)),VOPT(.1)=VOPT
 .I VOPT D
 ..N X,Y,UCI S UCI=$$ZOSF("UCI")
 ..S X=$$GET^VFDVFOI1(19.2,VOPT,"2;9;99.1",.ARR)
 ..K Y M Y=ARR(19.2,VOPT_",") K ARR
 ..F X=2,9,99.1 S ARR(X)=$G(Y(X,"I"))
 ..I ARR(9)["S" D  S ARR(99.1)=1
 ...Q:$D(^%ZTSCH("STARTUP",UCI,VOPT_"Q"_VOPT(0)))
 ...N DA S DA=VOPT D S9^XUTMG19 Q
 ...Q
 ..I 'ARR(99.1) S X=$$FILE^VFDVFOI1(13,VOPT) S:X<1 VOPT=-1
 ..Q
 .I 'VOPT S VOPT(.1)="",X=$$UPD^VFDVFOI1(13) S:X>0 VOPT=X
 .;boolean flag said do not schedule, so enter bogus queued time
 .S Y=VOPT(3)
 .I '$G(ARR(99.1)),VOPT>0,'VOPT(1),Y,VOPT'=VOPT(.1) S $P(^DIC(19.2,VOPT,0),U,2)=Y
 .;flag to fix up OPTION file
 .I VOPT,VOPT(6)'="" S X=$$FILE^VFDVFOI1(14,VOPT)
 .D OPT^VFDVFOI2
 .Q
 Q
 ;
OPT ;;p1;p2;p3;p4;p5;p6
 ;;p1=Boolean sched      p2=option name      p3=schedule time
 ;;p4= reschedule freq   p5=ZTQPARAM value   p6=fix in opt file
 ;;1;HL AUTOSTART LINK MANAGER;SP
 ;;1;HL TASK RESTART;S
 ;;0;LRTASK NIGHTY;0002;1D
 ;;0;LRTASK ROLLOVER;0001;1D
 ;;1;ORMTIME RUN;0040;1D
 ;;1;ORMTIME RUN CHECK;0050;1D
 ;;1;XMAUTOPURGE;0120;7D
 ;;1;XMCLEAN;0100;1D
 ;;1;XMMGR-IN-BASKET-PURGE;0110;7D
 ;;1;XMMGR-PURGE-AI-XREF;0130;7D
 ;;1;XMMGR-START-BACKGROUND-FILER;S
 ;;0;XOBV LISTENER STARTUP;S
 ;;1;XQ XUTL $J NODES;S
 ;;1;XQALERT DELETE OLD;0140;7D;30
 ;;1;XQBUILDTREEQUE;0200;1D
 ;;1;XTRMONITOR;0150;1D
 ;;1;XUERTRP AUTO CLEAN;0210;7D
 ;;1;XUSAZONK;0220;7D;;25^PURG^ZUA
 ;;1;XUSCZONK;0230;1D
 ;;1;XUSER-CLEAR-ALL;S
 ;;1;XUSERAOLD;0240;7D
 ;;1;XUTM QCLEAN;0250;7D
 ;;1;XWB LISTENER STARTER;S
 ;;0;XWB M2M CACHE LISTENER;S
 ;;
 ;
 ;
 ;
 ;
 ;
 ;
 ;
 ;
 ;
 ;
 ;
D19 ; save %ZSTART and %ZSTOP
 Q:'$$CACHE^VFDVFOIA  Q:'$G(VFDV("%SYS"))
 N I,X,Y,Z,RTN,SYS
 S SYS=VFDV("%SYS") ;1,2,or 3, FROM A11^VFDVFOI3
 I 13[SYS D
 .S X=$$DOIT("%ZSTART","%SYS")
 .I 'X S X=$$DOIT("VFDVZST1")
 .Q:'X  Q:'$D(RTN)
 .Q:'$$RESET
 .Q:'$$DOIT("%ZSTART","%SYS",1)
 K RTN I SYS>1 D
 .S X=$$DOIT("%ZSTOP","%SYS")
 .I 'X S X=$$DOIT("VFDVZST0")
 .Q:'X  Q:'$D(RTN)
 .Q:'$$RESET
 .Q:'$$DOIT("%ZSTOP","%SYS",1)
 Q
 ;---------------  subroutines  ---------------
 ;
DOIT(ROU,NMSP,FLG) ; zload/zsave routine ROU in namespace NMSP
 ;  ROU - req - name of routine    If ZLOAD, then return routine in RTN()
 ; NMSP - opt - name of cache namespace to get or save routine ROU
 ;  FLG - opt - default to 0   0:zload ROU in RTN(); 1:zsave ROU
 ;;X TEST I  ZL @X F I=1:1 S Z=$T(+I) Q:Z=""  S RTN(I)=$P(Z," ")_TAB_$P(Z," ",2,999)
 ;;ZR  X "S I=0 F  S I=$O(RTN(I)) Q:'I  ZI RTN(I)" ZS @ROU
 Q:'$$OS 0
 Q:$G(ROU)="" 0
 N I,X,Y,Z,FUCI,LOAD,SAVE,TAB,TEST
 I $G(NMSP)="" S NMSP=$$ZOSF("UCI")
 S X=NMSP Q:$$ZOSF("UCICHECK")=0
 S TAB=$C(9),FLG=+$G(FLG)
 S FUCI=$$ZOSF("UCI")
 S TEST=^%ZOSF("TEST")
 S LOAD=$P($T(DOIT+4),";;",2,99)
 S SAVE=$P($T(DOIT+5),";;",2,99)
 S Y=0 I 'FLG D
 .K RTN S X=ROU
 .I NMSP'=FUCI X "ZN NMSP X LOAD ZN FUCI"
 .I NMSP=FUCI X LOAD
 .S Y=$D(RTN)>0
 .Q
 I FLG,$D(RTN(1)) D
 .I NMSP'=FUCI X "ZN NMSP X SAVE ZN FUCI"
 .I NMSP=FUCI X SAVE
 .S Y=1
 .Q
 Q Y
 ;
OS() Q $G(^DD("OS"))=18 ; cache system
 ;
RESET() ; Add this namespace to %ZST* routines - expects RTN()
 N I,X,Y,Z,QQ,TAB,UCI
 S UCI=$$ZOSF("UCI"),TAB=$C(9),Y=0,QQ=$C(34)
 S I=0 F  S I=$O(RTN(I)) Q:'I  S Z=RTN(I) D  Q:Y=2
 .I $P(Z,TAB)="SYSTEM" S Y=1 Q
 .Q:Y'=1
 .S X=$P(Z,TAB,2) Q:X'["F VNSP="
 .I X=";F VNSP= D" S $P(Z,TAB,2)="F VNSP="_QQ_UCI_QQ_" D"
 .E  I X["F VNSP=""" D
 ..Q:$E(X,$L(X)-2,$L(Z))'=(QQ_" D")
 ..Q:X[(QQ_UCI_QQ)
 ..S $P(Z,TAB,2)=$E(X,1,$L(X)-2)_","_QQ_UCI_QQ_" D"
 ..Q
 .I X'=$P(Z,TAB,2) S RTN(I)=Z,Y=2
 .Q
 Q Y=2
 ;
ZOSF(A) ; execute zosf node
 N T,Y
 X ^%ZOSF(A) S T=$T
 Q $S(A="TEST":T,1:$P(Y,","))
