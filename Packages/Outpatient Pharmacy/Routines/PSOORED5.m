PSOORED5 ;BIR/SAB-Rxs without dosing info ;07/20/00
 ;;7.0;OUTPATIENT PHARMACY;**46,75,78,100,99,117,133**;DEC 1997
 ;^PS(51.2 - DBIA 2226
 ;^PS(50.7 - DBIA 2223
 ;^PSDRUG - DBIA 221
 ;^PS(55 - DBIA 2228
 ;called by psoored2 and psodir
 ;pre-poe rxs and new backdoor rxs
DOSE1(PSORXED) ;for new rxs
DOSE ;pre-poe rx
 D KV K ROU,STRE,FIELD,DOSEOR,DUPD,X,Y,UNITS S ENT=1,OLENT=ENT
ASK S ROU="PSOORED5" D ASK^PSOBKDED K ROU G:$D(DIRUT) EX
 I $G(JUMP) K JUMP G JUMP
 I $G(QUIT)]"" K QUIT,ROU Q
 ;
 I $G(VERB)]"" S PSORXED("VERB",ENT)=VERB G DUPD
 I $G(PSORX("EDIT"))']"" W:$G(PSORXED("VERB",ENT))]"" !,"VERB: "_PSORXED("VERB",ENT) G DUPD
VER D VER^PSOOREDX
 I X[U,$L(X)>1 S FIELD="VER" G JUMP
 G:$D(DTOUT)!($D(DUOUT)) EX I X="@" K PSORXED("VERB",ENT),VERB G DUPD
 S:X'="" (PSORXED("VERB",ENT),VERB)=X
DUPD ;
 I $G(PSORXED("DOSE",ENT))'?.N&($G(PSORXED("DOSE",ENT))'?.N1".".N)!'DOSE("LD") K PSORXED("DOSE ORDERED",ENT),DUPD G NOU1
 D KV S DIR(0)="52.0113,1",DIR("A")="DISPENSE UNITS PER DOSE"_$S($G(PSORXED("NOUN",ENT))]"":"("_PSORXED("NOUN",ENT)_")",1:"")
 I '$G(PSORXED("DOSE",ENT)),$G(PSORXED("DOSE",ENT-1)) S PSORXED("DOSE",ENT)=PSORXED("DOSE",ENT-1)
 S DIR("B")=$S($G(PSORXED("DOSE ORDERED",ENT))]"":PSORXED("DOSE ORDERED",ENT),$G(DUPD)]"":DUPD,1:"") S:$E($G(DIR("B")),1)="." DIR("B")="0"_$G(DIR("B")) K:DIR("B")="" DIR("B")
 D ^DIR I X[U,$L(X)>1 S FIELD="DUPD" G JUMP
 G:$D(DTOUT)!($D(DUOUT)) EX
 I X="@"!(X=0) W !,"Dispense Units Per Dose is Required!!",! G DUPD
 D STR^PSOOREDX
 ;
NOU1 G:'$D(DUPD) RTE D CNON^PSOORED3 N PSONDEF
 I $G(NOUN)]"",$G(PSORX("EDIT"))']"" S PSORXED("NOUN",ENT)=NOUN W !,"NOUN: "_$G(NOUN) G RTE
 I $G(PSORX("EDIT"))']"",$G(PSORXED("NOUN",ENT))]"" W !,"NOUN: "_PSORXED("NOUN",ENT) G RTE
NOU D NOU^PSOOREDX I X[U,$L(X)>1 S FIELD="NOU" G JUMP
 G:$D(DTOUT)!($D(DUOUT)) EX I X="@" K PSORXED("NOUN",ENT),NOUN G RTE
 I X'="",$G(PSONDEF)="" S NOUN=X
 I X'="",$G(PSONDEF)'=X S NOUN=X
 S:X'="" PSORXED("NOUN",ENT)=X
 ;
RTE I $G(ENT)>1,$G(PSORX("EDIT"))']"",$G(PSORXED("ROUTE",ENT-1)),$G(PSORXED("ROUTE",ENT))']"" S PSORXED("ROUTE",ENT)=PSORXED("ROUTE",ENT-1) G SCH
 I '$G(DRET),'$G(PSORXED("ROUTE",ENT)),$P(^PS(50.7,PSODRUG("OI"),0),"^",6) S PSORXED("ROUTE",ENT)=$P(^PS(50.7,PSODRUG("OI"),0),"^",6)
 I $G(DRET) S PSORXED("ROUTE",ENT)=""
 I $G(RTE) K RTE
 D KV S DIR(0)="FO^2:45",DIR("A")="ROUTE",DIR("?")="^D HLP^PSOORED4"
 S DIR("B")=$S($G(PSORXED("ROUTE",ENT)):$P(^PS(51.2,PSORXED("ROUTE",ENT),0),"^"),$G(RTE)]"":RTE,$G(DRET):"",1:"PO") K:DIR("B")="" DIR("B")
 D ^DIR I X[U,$L(X)>1 S FIELD="RTE" G JUMP
 I $D(DTOUT)!($D(DUOUT)) S PSODIR("DFLG")=1 Q
 I X="@"!(X="") K RTE,ERTE S DRET=1,PSORXED("ROUTE",ENT)="" G SCH
 K DRET I X=$P($G(^PS(51.2,+$G(PSORXED("ROUTE",ENT)),0)),"^") S RTE=$P(^PS(51.2,PSORXED("ROUTE",ENT),0),"^") W X_" "_$G(ERTE) G SCH
 S DIC=51.2,DIC(0)="QEZM",DIC("S")="I $P(^(0),""^"",4)" D ^DIC Q:X[U  G:Y=-1 RTE W "  "_$P(Y(0),"^",2)
 S:X'="" PSORXED("ROUTE",ENT)=+Y,RTE=Y(0,0),ERTE=$P(Y(0),"^",2)
 ;
SCH D SCH^PSOBKDED I X[U,$L(X)>1 S FIELD="SCH" G JUMP
 G:$D(DTOUT)!($D(DUOUT)) EX S SCH=Y D SCH^PSOSIG I $G(SCH)']"" G SCH
 S PSORXED("SCHEDULE",ENT)=SCH W " ("_SCHEX_")" K SCH,SCHEX,X,Y,PSOSCH
 S:$G(PSORXED("ENT"))<ENT PSORXED("ENT")=ENT
 ;
DUR D KV K EXP S DIR(0)="52.0113,4",DIR("A")="LIMITED DURATION (IN DAYS, HOURS OR MINUTES)"
 S DIR("B")=$S($D(DUR):DUR,$G(PSORXED("DURATION",ENT))]"":PSORXED("DURATION",ENT),1:"") K:DIR("B")="" DIR("B")
 D ^DIR I X[U,$L(X)>1 S FIELD="DUR" G JUMP
 G:$D(DTOUT)!($D(DUOUT)) EX
 D DUR1^PSOOREDX
 ;
CON D CON^PSOOREDX I X[U,$L(X)>1 S FIELD="CON" G JUMP
 G:$D(DTOUT)!($D(DUOUT)) EX
 I X="@",$G(PSORXED("CONJUNCTION",ENT))="" W !,?10,"Invalid Entry - nothing to delete!!" G CON
 S:X'=""&(X'="@") PSORXED("CONJUNCTION",ENT)=Y
 I X="@" D CON1^PSOOREDX G:$D(DIRUT) EX G:'Y CON S:'$G(COPY) PSOSIGFL=1 D UPD^PSOOREDX G CON
 I $G(PSORXED("CONJUNCTION",ENT))]"" S ENT=ENT+1 K DIR G ASK
 S X=$G(PSORXED("INS")) D SIG^PSOHELP S:$G(INS1)]"" PSORXED("SIG")=$E(INS1,2,9999999)
 D EN^PSOFSIG(.PSORXED) I $O(SIG(0)) S PSORXED("ENT")=ENT,SIGOK=1
 Q:$G(PSOREEDT)!($G(PSOORRNW))
 K QTYHLD S:$G(PSORXED("QTY")) QTYHLD=PSORXED("QTY") D QTY^PSOSIG(.PSORXED) I $G(PSORXED("QTY")) S QTY=1
 I $G(QTYHLD),'$G(PSORXED("QTY")) S PSORXED("QTY")=QTYHLD
 K QTYHLD Q:$G(PSOFROM)="NEW"!($G(COPY))!($G(PSOFROM))!($G(PSOREEDT))
 Q:$G(PSOSIGFL)  D
 .S D=0 F  S D=$O(SIG(D)) Q:'D  S ^PSRX(PSORXED("IRXN"),"SIG1",D,0)=SIG(D),$P(^PSRX(PSORXED("IRXN"),"SIG1",0),"^",3)=+$P($G(^PSRX(PSORXED("IRXN"),"SIG1",0)),"^",3)+1,$P(^(0),"^",4)=+$P($G(^(0)),"^",4)+1 Q:'$O(SIG(D))
 .S (A,I)=0 F  S I=$O(^PSRX(PSORXED("IRXN"),"A",I)) Q:'I  S A=A+1
 .S:'$D(^PSRX(PSORXED("IRXN"),"A",0)) ^PSRX(PSORXED("IRXN"),"A",0)="^52.3DA^"
 .S $P(^PSRX(PSORXED("IRXN"),"A",0),"^",3)=$P($G(^PSRX(PSORXED("IRXN"),"A",0)),"^",3)+1,$P(^(0),"^",4)=$P($G(^(0)),"^",4)+1
 .D NOW^%DTC S A=A+1,^PSRX(PSORXED("IRXN"),"A",A,0)=%_"^E^"_DUZ_"^0^New Dosing Instructions Added",^PSRX(PSORXED("IRXN"),"A",A,1)="ORIGINAL SIG^" D
 ..I '$P(^PSRX(PSORXED("IRXN"),"SIG"),"^",2) S $P(^PSRX(PSORXED("IRXN"),"A",A,1),"^",2)=$P(^PSRX(PSORXED("IRXN"),"SIG"),"^") Q
 ..F I=0:0 S I=$O(^PSRX(PSORXED("IRXN"),"SIG1",I)) Q:'I  S ^PSRX(PSORXED("IRXN"),"A",A,2,I,0)=^PSRX(PSORXED("IRXN"),"SIG1",I,0),^PSRX(PSORXED("IRXN"),"A",A,2,0)="^52.34A^"_I_"^"_I
 .S ^PSRX(PSORXED("IRXN"),"SIG")="^1" K SIG,A,I
 S ^PSRX(PSORXED("IRXN"),6,0)="^52.0113^"_ENT_"^"_ENT
 F I=1:1:ENT S ^PSRX(PSORXED("IRXN"),6,I,0)=PSORXED("DOSE",I)_"^"_$G(PSORXED("DOSE ORDERED",I))_"^"_$G(PSORXED("UNITS",I))_"^"_$G(PSORXED("NOUN",I))_"^" D
 .S ^PSRX(PSORXED("IRXN"),6,I,0)=^PSRX(PSORXED("IRXN"),6,I,0)_$G(PSORXED("DURATION",I))_"^"_$G(PSORXED("CONJUNCTION",I))_"^"_$G(PSORXED("ROUTE",I))_"^"_$G(PSORXED("SCHEDULE",I))_"^"_$G(PSORXED("VERB",I))
 .I $G(PSORXED("DOSE",I))]"" S ^PSRX(PSORXED("IRXN"),6,I,1)=PSORXED("DOSE",I)
 S ^PSRX(PSORXED("IRXN"),"POE")=1 G EX
 Q
EX I $D(DUOUT)!($D(DTOUT)) S PSONEW("DFLG")=1
 ;I $D(DUOUT)!($D(DTOUT)) S:'$G(PSORX("EDIT")) PSONEW("DFLG")=1
 G:$G(PSOSIGFL)!($G(PSORX("EDIT")))!($G(PSORXED))!($G(PSOREEDT)) EX1
 K PSORXED("DOSE"),PSORXED("NOUN"),PSORXED("VERB"),PSORXED("DOSE ORDERED"),PSORXED("ROUTE"),SIG,PSORXED("SCHEDULE"),PSORXED("DURATION"),PSORXED("CONJUNCTION"),PSORXED("ODOSE")
EX1 K UNITN,STRE,DOSE,DUPD,SCH,VERB,NOUN,DOSEOR,RTE,DUR,X,Y,ENTS,PSOSCH,ENT,PSORTE,DURA,ERTE,ROU
KV K DIR,DIRUT,DTOUT,DUOUT
 Q
UPD ;updates dosing array
 D UPD^PSOORED6
 Q
JUMP ;
 I $G(PSORXED("SCHEDULE",1))']"" W $C(7),!!,"All Dosing Instructions must be entered before Jumping to other Fields!",!! G @FIELD
 I $L($E(X,2,99))<3 W !,"Field Name Must Be At Least 3 Characters in Length",! G @FIELD
 D FNM^PSOOREDX
 I FLDNM']"" K X,NM,FLDNM W !,"INVALID FIELD NAME.  PLEASE TRY AGAIN!",! G @FIELD
 F AR=1:1:PSORXED("ENT") W !,AR_". "_$P(FLDNM,"^",2)_": "_$S(NM="ROU"&($G(PSORXED($P(FLDNM,"^"),AR))):$P(^PS(51.2,PSORXED($P(FLDNM,"^"),AR),0),"^"),1:$G(PSORXED($P(FLDNM,"^"),AR))) S AR1=AR
 D KV
 I $G(PSOFROM)'="NEW",'$G(COPY) S DIR("A",1)="* Indicates which fields will create a New Order"
 S DIR("A")="Select Field by number",DIR(0)="NO^1:"_AR1 D ^DIR G:$D(DIRUT) @FIELD
 D JFN^PSOOREDX G:FLDNM="" @FIELD G @FLDNM
 G EX
 Q
LAN ;
 Q:'$G(PSODRUG("IEN"))
 I $G(OR0),'$G(PSONEW("DOSE ORDERED",II)),$P($G(^PS(55,PSODFN,"LAN")),"^") D  K QI,QII Q
 .Q:$G(OTHDOS(II))
 .F QI=0:0 S QI=$O(^PSDRUG(PSODRUG("IEN"),"DOS2",QI)) Q:'QI  D  Q:$G(QII)
 ..Q:$G(PSONEW("DOSE",II))']""
 ..I PSONEW("DOSE",II)=$P(^PSDRUG(PSODRUG("IEN"),"DOS2",QI,0),"^") S PSONEW("ODOSE",II)=$P(^PSDRUG(PSODRUG("IEN"),"DOS2",QI,0),"^",4),QII=1
 I $G(Y),$P($G(DOSE(Y)),"^",13)]"" S PSORXED("ODOSE",ENT)=$P(DOSE(Y),"^",13) Q
 K QII F I=0:0 S I=$O(^PSDRUG(PSODRUG("IEN"),"DOS2",I)) Q:'I  I DOSE=$P(^PSDRUG(PSODRUG("IEN"),"DOS2",I,0),"^") D  Q:$G(QII)
 .S PSORXED("ODOSE",ENT)=$P(^PSDRUG(PSODRUG("IEN"),"DOS2",I,0),"^",4),QII=1
 K QII,I Q