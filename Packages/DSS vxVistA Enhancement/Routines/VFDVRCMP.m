VFDVRCMP ;BHM/SGM/PDW - ROUTINE COMPARE BETWEEN HFS kids TO DISK
 ;;2009.2;DSS,INC VXVISTA OPEN SOURCE;;01 Dec 2009
 ;Copyright 1995-2009,Document Storage Systems Inc. All Rights Reserved
 ; DEC 22 2005
 ;entry points
 ;LKID^  compare a loaded kid to current space
 ;HFS^   compare a host file kid to current space
 ;^UTILITY($J,0,ROU)="" ;list of routines
 ;^UTILITY($J,1,J,0) =routine lines of first routine
 ;^UTILITY($J,2,J,0) =routine lines of second routine
 ;^UTILITY($J,3,N)=differences for listing
 ;^UTILITY($J,9, =workspace for differences
 Q
HFS ;
 W @IOF
 W !,"This will compare a HFS KIDS to the current environment"
HFSLOAD ; Load a selected HFS into UTILITY($J,N,J)
 N FILE,MSG,FC,DIR,DIC,GBL,PATH,FILE,BUILD,NOFLS
HFSQ1 ;
 K DIR S DIR(0)="FO",DIR("A")="ENTER PATH" D ^DIR G:$L(Y)'>2 EXIT
 S PATH=Y
HFSQ2 ;
 W !!,"PATH is ",PATH,!
 K DIR S DIR(0)="FO",DIR("A")="ENTER FILE" D ^DIR G:$L(Y)'>0 HFSQ1
 S FILE=Y
HFSGO W !!,"LOADING ",!,"PATH: ",?10,PATH,!,"FILE:",?10,FILE,!!
 ;load hfs unto global
 S GBL=$NA(^TMP($J,"FTG",1)) K @GBL,^UTILITY($J)
 S Y=$$FTG^%ZISH(PATH,FILE,GBL,3) ;
 I Y'>0 W !,"FILE NOT LOADED" G HFSQ2
 ;
HFSPROC ;
 W !,"Loading Routines"
 ;load routine from ^TMP($j,FTG) to ^TMP($J,"RTN")
 S IGN=0,FULL=1 ;settings for compare
 S FTG=$NA(^TMP($J,"FTG")) K ^TMP($J,"RTN")
 S BUILD=@FTG@(2)
 S LLINE=$O(@FTG@("A"),-1) ;find last line of build
 S TAG="""RTN"",""" ;new routine marker in kid file text "RTN","
 ;load routines
 S XX=@FTG@(2) I $E(XX,1,6)="%RO on" D ROLOAD I 1 ; test/load %RO file
 E  F LL=1:1:LLINE S X=@FTG@(LL) I X[TAG S G2="^TMP($J,"_X,@G2=@FTG@(LL+1)
 ;^TMP(3896,"RTN","DSIHHLOE",1,0)=DSIHHLOE ;DSS/PDW - EDIT 
 ;X[TAG is of the form X="RTN","DSIHHL2T",221,0)
 ;where LL+1= N Y,I S I=$P(XX,"="),Y=$P(XX,"=",2)
HFSREDO ;
 S ROU="" F  S ROU=$O(^TMP($J,"RTN",ROU)) Q:ROU=""  S ^UTILITY($J,0,ROU)=""
 D NMSPACE
 S NOFLS=0
 K DIR S DIR(0)="Y",DIR("B")="N",DIR("A")="Do you want to see first line differences"
 D ^DIR S NOFLS=+Y
 D COMPARE ;run the compare
 W !,"The compare can be run again with a different namespace."
 K DIR S DIR(0)="YO",DIR("A")="Do you want to run again with a different namespace?"
 S DIR("B")="Y" D ^DIR
 I Y=1 G HFSGO
 G HFSQ2
 Q 
XPD(VFDRCMP,XPDIEN,VFDRTN) ;
 ; COMPARE Routines in a Kids Load to disk
 K ^UTILITY($J)
 S IGN=0,FULL=1
 S VFDRCMP="-1^XPDI or Routine not found"
 D EN0
 Q
EN0 ;Entry point for taskman
 D EN^VFDVRCMP
 M VFDRCMP=^UTILITY($J,3)
 G EXIT
EN ;
 D RTNS,INIT,RUN
 K MSGDA,MMDA,MM1DA,MM2DA,LOADD,LOAD,NODE,L,ROU,RTN,LOAM,LOADM1,LOADM,BSKDA,LOADK,ZZ,CHECK,GLO,L,DIR,DIC,DA
 Q
RTNS ;LOAD ROUTINES INTO ^UTILITY
 K ^UTILITY($J)
 S ^UTILITY($J,0,VFDRTN)="" ; VFDV
 Q
INIT ;
 ;variables executions stacked to minimize executable line lengths
 S RTN=0,STAR="",$P(STAR,"*",80)="",UL="",$P(UL,"-",80)="",^UTILITY($J,3)="XPDI or Routine not found"
 S %FR="" I $G(XPDIEN) S %FR=$P(^XPD(9.7,XPDIEN,0),U)_"|"_^(2)
 S:%FR="" %FR=$G(BUILD)_" | "_$G(FILE)
 S %TO="to DISK"
 S LOAD("I")="X LOADI S:SZ XX=SZ_U_(J-1) D:SZ SZ^VFDVRCMP"
 S LOAD("D")="X LOADD S:SZ $P(NODE,U,3,4)=SZ_U_(J-1)"
 S LOAD("KF")="X LOADKF S:SZ XX=SZ_U_(J-1) D:SZ SZ^VFDVRCMP"
 S LOAD(1)=LOAD("KF") ;HFS KID default HFS N=1
 S LOAD(2)=LOAD("D") ;DISK default N=2
 S LOAD(3)=LOAD("I") ;XPD INSTAL kid file in ^XTMP(""XPDI""
 ; load a routine from a HFS KID FTG loaded  ^TMP($J,"RTN",RTN,
 S LOADKF="K ^UTILITY($J,N) S SZ=0 F J=1:1 S L=$G(^TMP($J,""RTN"",RTN,J,0)),^UTILITY($J,N,J)=L S:L]"""" SZ=SZ+$L(L)+2 I L="""" S ^UTILITY($J,N,0)=J Q"
 ; load a routine from Disk
 S LOADD="K ^UTILITY($J,N) S SZ=0,X=RTN X ^%ZOSF(""TEST"") I  ZL @X F J=1:1 S L=$T(+J) S ^UTILITY($J,N,J)=L S:L]"""" SZ=SZ+$L(L)+2 I L="""" S ^UTILITY($J,N,0)=J Q"
 ;load a routine from an install kids global ^XTMP(""XPDI""
 S LOADI="K ^UTILITY($J,N) S SZ=0 F J=1:1 S L=$G(^XTMP(""XPDI"",XPDIEN,""RTN"",RTN,J,0)),^UTILITY($J,N,J)=L S:L]"""" SZ=SZ+$L(L)+2 I L="""" S ^UTILITY($J,N,0)=J Q"
 Q
SZ S:N=1 $P(NODE,U,1,2)=SZ_U_(J-1)
 S:N=2 $P(NODE,U,3,4)=SZ_U_(J-1)
 Q
RUN ;
 F I=0:0 S RTN=$O(^UTILITY($J,0,RTN)) Q:RTN=""  D RUNRTN(RTN)
 Q
RUNRTN(RTN) ;
 S NODE="^^^^",N=1 X LOAD(N) S N=2 X LOAD(N) D COMP,SET
 Q
COMP ;Routine compare
 K ROU,P,^UTILITY($J,9) S ^UTILITY($J,9,1)=STAR
 S ^UTILITY($J,9,2)="Routine Compare of "_RTN_" in: "
 S ^UTILITY($J,9,3)=%FR
 S ^UTILITY($J,9,4)=%TO
 S ROU=4,D=""
 Q:'+NODE!'$P(NODE,"^",3)
 S (L1,L2)=2*IGN+1
 ;clear trailing spaces from lines
 S G=$NA(^UTILITY($J,1))
 F I=1:1:$O(@G@("A"),-1) S X=@G@(I) I $E(X,$L(X))=" " D
 .F  Q:$E(X,$L(X))'=" "  S X=$E(X,1,$L(X)-1)
 .S @G@(I)=X
 S G=$NA(^UTILITY($J,2))
 F I=1:1:$O(@G@("A"),-1) S X=@G@(I) I $E(X,$L(X))=" " D
 .F  Q:$E(X,$L(X))'=" "  S X=$E(X,1,$L(X)-1)
 .S @G@(I)=X
 ;
LOOP ;
 I ^UTILITY($J,1,L1)'=^UTILITY($J,2,L2) S BL1=L1,BL2=L2 D DIFF S TOTL1=+$G(TOTL1)+L1-BL1,TOTL2=+$G(TOTL2)+L2-BL2
 Q:^UTILITY($J,1,L1)=""
 S L1=L1+1,L2=L2+1 G LOOP
DIFF S ROU=ROU+1,^UTILITY($J,9,ROU)=$E(STAR,1,IOM\2)
 S P(1)=L1,P(2)=L2,(CHECK,P)=0,D=D+1
DL S P=P+1#2,A=P+1,P(A)=P(A)+1 S:^UTILITY($J,A,0)'>P(A) P(A)=^UTILITY($J,A,0) I ^UTILITY($J,A,P(A))="" S A2=P+1#2+1,P(A2)=^UTILITY($J,A2,0) S J=P(1),K=P(2) G DONE
DL2 S J=P(1) F K=L2:1:P(2) D CHECK:^UTILITY($J,1,J)=^UTILITY($J,2,K) G:CHECK DONE
 S K=P(2) F J=L1:1:P(1) D CHECK:^UTILITY($J,1,J)=^UTILITY($J,2,K) G:CHECK DONE
 G DL
DONE S P(1)=J,P(2)=K F Z=L1:1:P(1) S LI=^UTILITY($J,1,Z) D LINE
 S ROU=ROU+1,^UTILITY($J,9,ROU)=$E(UL,1,IOM\2)
 F Z=L2:1:P(2) S LI=^UTILITY($J,2,Z) D LINE
 ;S L1=P(1),L2=P(2),ROU=ROU+1,^UTILITY($J,9,ROU)="" Q
 S L1=P(1),L2=P(2) Q
 ;
LINE S B="  "_Z_")"_$E("   ",1,4-$L(Z)),C="" I LI]"" S B=B_$P(LI," ")_$E("          ",1,10-$L($P(LI," "))),Q=$F(LI," "),C=$E(LI,Q,255) S:$L(C)<239 B=B_C I $L(C)>238 S B=B_$E(C,1,238),C=$E(C,239,255)
 S ROU=ROU+1,^UTILITY($J,9,ROU)=B S:$L(B)>255 ROU=ROU+1,^UTILITY($J,9,ROU)=C Q
 ;
CHECK ;INSURE IT IS A MATCH OF TWO LINES
 S J1=J+1,K1=K+1 S:J1>^UTILITY($J,1,0) J1=J S:K1>^UTILITY($J,2,0) K1=K S:(^UTILITY($J,1,J1)=^UTILITY($J,2,K1))!(K1=K)!(J1=J) CHECK=1
 ;I CHECK W !,^UTILITY($J,1,J),!,^UTILITY($J,2,K),!,^UTILITY($J,1,J1),!,^UTILITY($J,2,K1),!
 K J1,K1
 Q
SET ;Save differences in ^UTILITY($J,3) if FULL
 N FL S FL=$O(^UTILITY($J,9,"A"),-1) I '$G(NOFLS),+D=1,+^UTILITY($J,9,FL)<4 S D=""
 I '$G(NOFLS),+D=1,$O(^UTILITY($J,9,"A"),-1)=10,$E(^UTILITY($J,9,10),1,4)="  2)" S D=""
 I FULL,D S A=^UTILITY($J,3) F I=1:1:ROU S A=A+1,^UTILITY($J,3,A)=^UTILITY($J,9,I)
 I  S A=A+4,^UTILITY($J,3,A-3)="",^(A-2)=$E(STAR,1,80),^(A-1)="" S:+NODE&$P(NODE,"^",3) ^(A)="A total of "_+D_" differences found.",A=A+1 S ^(A)=UL,A=A+1,^(A)="",^UTILITY($J,3)=A
 S ^UTILITY($J,0,RTN)=NODE_D Q
 Q
EXIT ;
 I '$G(A3AHIST) D ^%ZISC
 K ^TMP($J,"RTN"),^TMP($J,"FTG"),^UTILITY($J)
 K %,%FR,%N,%TO,A,A2,B,C,CMP,D,FULL,I,IGN,IO("Q"),J,K,L,L1,L2,LI,LOAD,N,NODE,P,POP,Q,ROU,RTN,STAR,SZ,UL,VIO,X,Y,Z,ZTIO,TOTL1,TOTL2
 K:$D(ZTSK) ^%ZTSK(ZTSK),ZTSK K ^UTILITY($J) ;X ^%ZIS("C")
 K LOADD,LOADI,QUIT,RTNM,BL1,BL2
 Q
LKID ; SELECT A LOADED KIDS
 S DIC="^XPD(9.7,"
 S DIC(0)="QEAMZ"
 S DIC("S")="I '$P(^(0),U,9),$D(^XTMP(""XPDI"",Y))"
 D ^DIC
 S XPDIEN=+Y Q:+Y'>0
 K ^UTILITY($J)
NMSPACE W !,"Enter namespaces to scan or skip to take all namespaces"
 K DIR S DIR(0)="FO^1:8",DIR("A")="ENTER NAME SPACE: "
 K NMSPACE F I=1:1 D ^DIR Q:$L(Y)=0  S Y=$P(Y,"*"),NMSPACE(Y)=""
 S RTNM="" F  S RTNM=$O(^UTILITY($J,0,RTNM)) Q:RTNM=""  D
 .S ^UTILITY($J,0,RTNM)=""
 .I '$D(NMSPACE) Q
 .D NMSPACEX(RTNM)
 S RTNM="" F  S RTNM=$O(^UTILITY($J,0,RTNM)) Q:RTNM=""  W !,RTNM
 Q
 S IGN=0,FULL=1
COMPARE S %IS="M" D ^%ZIS G:POP EXIT
 D INIT,RUN ;LOAD(1) SET TO KidFile HFS Loaded
 ;S ZTDESC="ROUTINE COMPARE",ZTRTN="EN^A3ARCMM",ZTIO="",ZTSAVE("VIO")=ION_";"_IOST_";"_IOM_";"_IOSL F X="^UTILITY($J,","%FR","%TO","IGN","FULL","MM*" S ZTSAVE(X)=""
 ;D ^%ZTLOAD W:$D(ZTSK) !?5,"Task Queued" K ZTSK
 ;
 ;Entry point for taskman
 ;^UTILITY($J,0,X)= rtn size in uci1^#lines^rtn size in uci2^#lines
 S:$D(ZTSK) IOM=$P(VIO,";",3) ;D EN^A3ARCMM
IO I $D(ZTSK) S IOP=VIO D ^%ZIS I POP H 10 G IO
 U IO S POP=0,QUIT=0
 ;I FULL W @IOF,! F I=1:1:^UTILITY($J,3) W !,^UTILITY($J,3,I) I (IOSL-$Y)<4 D CR I POP W ! G EXIT
 I FULL W @IOF,! F I=1:1:^UTILITY($J,3) S XX=^UTILITY($J,3,I) D  G:POP EXIT
 . F K=0:1 Q:((K*80)>$L(XX))  W !,$E(XX,K*80+1,(K+1)*80) I (IOSL-$Y)<4 D CR Q:POP
 H 2 S FULL=0 W @IOF,!?15,"Routine Compare Summary - ",! D HDR
 S (A,A2,X)="" F I=0:0 S X=$O(^UTILITY($J,0,X)) Q:X=""  S Y=^(X) D WR Q:POP
 W !?22,"--------",?40,"--------",!?22,$J(A,8),?40,$J(A2,8),!
 W !,"Total Lines changed",?22,$J($G(TOTL1),8),?40,$J($G(TOTL2),8),!
 G EXIT
 Q
WR ;
 W !?13,$S($P(Y,"^",5):"=>",1:"  "),X,?25,$S(+Y>10000:"*",1:" "),$J($P(Y,"^"),4),$J($P(Y,"^",2),8),"     ",$S($P(Y,"^",3)>10000:"*",1:" "),$J($P(Y,"^",3),4),$J($P(Y,"^",4),8),$J($P(Y,"^",5),8)
 S A=A+Y,A2=A2+$P(Y,"^",3) Q:IOSL-$Y>4
CR ;I $E(IOST)="C" W *7,# R Z:60 S:Z["^"!'$T POP=1 Q
 I $E(IOST)="C" R Z:60 S:Z["^"!'$T POP=1 W @IOF Q
 Q:FULL  W @IOF,!
HDR W !,?3,%FR,!,?3,%TO,!?15,"Routine    Size  # Line      Size  # Line   Diffs",!?15,"--------   ----  ------      ----  ------   -----"
 Q
NMSPACEX(RTNM) ;
 N XX,XXX,YY S XX="",XXX=0
 ;I $E(RTNM)="D" B
 F  S XX=$O(NMSPACE(XX)) Q:XX=""  S YY=$E(RTNM,1,$L(XX)) I (XX=YY) S XXX=1 Q
 I 'XXX K ^UTILITY($J,0,RTNM) S ^UTILITY($J,"SKIP",RTNM)=""
 Q 
E S DIR(0)="EO",DIR("A")="<CONTINUE>" D ^DIR K DIR Q
ROLOAD ; Load in a %RO file
 N X,LLINE,LL,RL,ROU
 S X=@FTG@(2) I $E(X,1,6)'="%RO on" Q
 K ^TMP($J,"RTN")
 S LLINE=$O(@FTG@("A"),-1),RL=1
 F LL=3:1:LLINE D
 . S X=@FTG@(LL) I $P(X,U,2)="INT" S ROU=$P(X,U),RL=0 Q
 . Q:X=""
 . S RL=RL+1,^TMP($J,"RTN",ROU,RL,0)=X
 Q
