VFDXPDE1 ;DSS/SMP - REPORTS CONTINUED ;02/27/2013 15:50
 ;;3.1;DSS,INC VXVISTA SUPPORTED;;10 Dec 2012;Build 58
 ;Copyright 1995-2012,Document Storage Systems Inc. All Rights Reserved
 ;
 ;This routine should be only be invoked via the VFDXPD routine.
 ;
 Q
 ;
6 ;============ PRE/POST INSTALL INSTRUCTIONS FOR A BATCH =============
 ;
 ;  Field     Label
 ;   .11      PRE-INSTALL
 ;   .12      POST-INSTALL
 ;     2      PRE-INSTALL INSTRUCTIONS
 ;     3      POST-INSTALL INSTRUCTIONS
 ;
 ; PRE1 - PRE PRE
 ; PRE2 - PRE DURING
 ; POST1 - POST DURING
 ; POST2 - POST POST POST POST POST
 N X,Y,Z,I,IEN,PRE1,PRE2,POST1,POST2,NM,INST,L,VFDINST
 S (PRE1,PRE2,POST1,POST2)=0
 D VFDSORT^VFDXPDG2($NA(VFDINST),PID,0,,0)
 F I=1:1:VFDINST S NM=$P(VFDINST(I),U) D
 .I $E(NM,1,2)=">>" S NM=$P(NM,">>",2)
 .S VFDINST("B",NM,I)=""
 S IEN=0 F  S IEN=$O(BATCH(IEN)) Q:'IEN  D
 .N NA,DATA D GETS^VFDXPDA("DATA",21692,IEN_",",".11;.12;2;3","IN")
 .Q:'$D(DATA)  S NA=$NA(DATA(21692,IEN_","))
 .I $D(@NA@(2)) D  ; If PRE INSTALL INSTRUCTIONS
 ..K INST M INST=@NA@(2)
 ..I $G(@NA@(.11,"I"))=1 D ADD(.PRE1,IEN,.INST) Q
 ..I $G(@NA@(.11,"I"))=2 D ADD(.PRE2,IEN,.INST) Q
 .I $D(@NA@(3)) D  ; If POST INSTALL INSTRUCTIONS
 ..K INST M INST=@NA@(3)
 ..I $G(@NA@(.12,"I"))=1 D ADD(.POST2,IEN,.INST) Q
 ..I $G(@NA@(.12,"I"))=2 D ADD(.POST1,IEN,.INST) Q
 S L=0
 I PRE1!PRE2!POST1!POST2 D SET(PID(0))
 I PRE1 D
 .D SET(""),SET("$$PRE BATCH")
 .S X="" F  S X=$O(PRE1(X)) Q:X=""  D SET(PRE1(X))
 I PRE2 D
 .D SET(""),SET("$$PRE INSTALL")
 .S X="" F  S X=$O(PRE2(X)) Q:X=""  D SET(PRE2(X))
 I POST1 D
 .D SET(""),SET("$$POST INSTALL")
 .S X="" F  S X=$O(POST1(X)) Q:X=""  D SET(POST1(X))
 I POST2 D
 .D SET(""),SET("$$POST BATCH")
 .S X="" F  S X=$O(POST2(X)) Q:X=""  D SET(POST2(X))
 Q
 ;
ADD(RPT,IEN,INST) ;
 N I,X,NM,SEQ,STR
 S NM=$P(BATCH(IEN),U),SEQ=$P(BATCH(IEN),U,5)
 S STR=NM_" SEQ #"_SEQ_$C(9)
 F I=1:1 Q:'$D(INST(I))  S STR=STR_"$CR"_INST(I)
 I $D(VFDINST("B",NM)) S X=$O(VFDINST("B",NM,""))
 E  D
 .F I=0:1 S X="A"_I Q:$O(RPT(X))=""
 .S X="A"_(I+1)
 S RPT=RPT+1,RPT(X)=STR_"$CR"
 Q
 ;
7 ;====================  LIST OF BUILDS IN A BATCH  ===================
 ; excel=1 for delimited, 0 for formatted
 Q:$G(PID)<1
 N I,J,L,X,Y,Z,CNT,DASH,DESC,EXCEL,IEN,IN,LEN,NM,NMS,PATCH,PKG,SEQ,STAT
 N TAB,TITLE,TMP,VER,VX
 S Y=$$BATCHNM^VFDXPD0(PID)
 S TITLE="BUILDs Contained in Processing Group "_Y
 ;build name^pkg^ver^patch#^seq#^description^int stat^in multi
 ;    1       2   3    4     5     6            7        8
 ; get field 15 IN MULTI
 S VX=0 F  S VX=$O(BATCH(VX)) Q:'VX  D
 .S X=$$GET1^VFDXPDA(21692,VX_",",.15,"I")
 .S $P(BATCH(VX),U,8)=X I X,X'=VX S BATCH("IN",X,VX)=""
 .Q
 S (J,L,CNT)=0,TAB=$C(9),$P(DASH,"-",201)=""
 D SET(TITLE),SET("")
 S X="Build Name"_TAB_"Seq#"_TAB_"Stat"_TAB_"Patch Subject"
 D SET(X)
 ; d seta() sets NM,PKG,VER,PKG,SEQ,DESC,STAT,IN,NMS
 S VX=$NA(BATCH("C")) F  S VX=$Q(@VX)  Q:VX=""  Q:$QS(VX,1)'="C"  D
 .S IEN=@VX D SETA(IEN) I IN,IN'=IEN Q
 .I STAT?1N S STAT=$S(STAT=1:"K",STAT=2:"M",STAT=3:"P",1:"N")
 .S J=J+1,Y=NM_TAB_SEQ_TAB_STAT_TAB_DESC D SET(Y)
 .I $D(BATCH("IN",IEN)) S I=0 F  S I=$O(BATCH("IN",IEN,I)) Q:'I  D
 ..D SETA(I)
 ..I STAT?1N S STAT=$S(STAT=1:"K",STAT=2:"M",STAT=3:"P",1:"N")
 ..S J=J+1,Y=">>"_NM_TAB_SEQ_TAB_STAT_TAB_DESC D SET(Y)
 ..Q
 .Q
 S X="Word Table: 5 columns, "_(J+1)_" rows" S RPT(2)=X
 Q
 ;
11 ;===========  LIST OF PATCHES AND FILES TO BE RETRIEVED  ===========
 ;
 Q:$G(PID)<1
 N I,J,L,X,Y,Z,LEN,LIST,TAB,VFDCH,VX
 ; All, Only, Files only
 S VFDCH=$$DIR^VFDXPD0(4) Q:VFDCH=""  Q:"AFO"'[VFDCH
 S (VX,LEN)=0,TAB=$C(9)
 S VX=0 F  S VX=$O(BATCH(VX)) Q:'VX  D
 .N AUTO,FILE,NM,RET,STAT,VFDRX,VIEN
 .S VIEN=VX_","
 .D GETS^VFDXPDA("VFDRX",21692,VIEN,".01;.1;.17;.18;1*","I")
 .K Z M Z=VFDRX(21692,VIEN)
 .S NM=Z(.01,"I"),STAT=Z(.1,"I"),RET=Z(.17,"I"),AUTO=Z(.18,"I")
 .S:STAT>0 STAT=$E("KMP",STAT) S:AUTO STAT=STAT_"A"
 .; +FILE tells whether files are outstanding
 .S (I,J,FILE)=0 F  S J=$O(VFDRX(21692.01,J)) Q:J=""  D
 ..S X=VFDRX(21692.01,J,.01,"I"),Y=VFDRX(21692.01,J,.02,"I")
 ..S FILE(X)=$E("Y",Y) S:Y FILE=FILE+1
 ..Q
 .I VFDCH="F" S X=0 F  S X=$O(FILE(X)) Q:X=""  S:FILE(X)'="" LIST(X)=""
 .I VFDCH="A" S X=RET_U_STAT_U_NM_U,Y=0 D
 ..S:LEN<$L(NM) LEN=$L(NM) I $D(FILE)<10 S LIST(NM_VX)=X Q
 ..F  S Y=$O(FILE(Y)) Q:Y=""  S LIST(NM_VX_Y)=X_FILE(Y)_U_Y,X="^^^"
 ..Q
 .I VFDCH="O",RET'=""!FILE S X=RET_U_STAT_U_NM_U,Y=0 D
 ..S:LEN<$L(NM) LEN=$L(NM) I 'FILE S LIST(NM_VX)=X Q
 ..F  S Y=$O(FILE(Y)) Q:Y=""  S:FILE(Y)'="" LIST(NM_VX_Y)=X_"Y^"_Y,X="^^^"
 ..Q
 .Q
 I LEN<10 S LEN=10
 S L=0 I VFDCH'="F" D
 .S X="Get |Stat| Build Name",$E(X,LEN+13)="|Ret| File Names" D SET(X)
 .S X="",$P(X,"-",80)="",$E(X,5)="|",$E(X,10)="|",$E(X,LEN+13)="|"
 .S $E(X,LEN+17)="|" D SET(X)
 .Q
 S X=0 F  S X=$O(LIST(X)) Q:X=""   K Z S Z=LIST(X) D
 .I VFDCH="F" D SET(X) Q
 .F I=1:1:5 S Z(I)=$P(Z,U,I)
 .S Y=Z(1),$E(Y,5)="| "_Z(2),$E(Y,10)="| "_Z(3),$E(Y,LEN+13)="| "_Z(4)
 .S $E(Y,LEN+17)="| "_Z(5) D SET(Y)
 .Q
 Q
 ;
 ;-----------------------  PRIVATE SUBROUTINES  -----------------------
SET(X) S L=L+1,RPT(L)=X Q
 ;
SETA(A) ;
 S X=BATCH(A),NM=$P(X,U),PKG=$P(X,U,2),VER=$P(X,U,3)
 S PATCH=$P(X,U,4),SEQ=$P(X,U,5),DESC=$P(X,U,6),STAT=$P(X,U,7)
 S NMS=NM_" SEQ #"_SEQ,IN=$P(X,U,8)
 Q
