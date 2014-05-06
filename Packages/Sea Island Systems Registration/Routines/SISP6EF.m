SISP6EF ;SIS/LM - Clone and optionally modify routine DGRP6EF
 ;;1.0;NON-VA REGISTRATION;;;Build 15
 ;Copyright 2008 - 2009, Sea Island Systems, Inc.  Rights are granted as follows:
 ;Sea Island Systems, Inc. conveys this modified VistA routine to the PUBLIC DOMAIN.
 ;This software comes with NO warranty whatsoever.  Sea Island Systems, Inc. will NOT be
 ;liable for any damages that may result from either the use or misuse of this software.
 ;
DGRP6EF ;ALB/TMK,EG - REGISTRATION SCREEN 6 FIELDS FOR EXPOSURE FACTORS; 07/20/2006
 ;;5.3;Registration;**689,659,737**;Aug 13, 1993;Build 8
 ;
EN(DFN,QUIT) ; Display Environmental exposure factors/allow to edit
 N I,IND,DG321,DG322,DGCT,DIR,Z,X,Y,DIE,DR,DA,DGNONT
 ; Returns QUIT=1 if ^ entered
 ;
EN1 D CLEAR^VALM1
 N DTOUT,DUOUT
 S DG321=$G(^DPT(DFN,.321)),DG322=$G(^DPT(DFN,.322))
 ;
 S DIR(0)="SA^",DGCT=0
 S DGCT=DGCT+1,DIR("A",DGCT)=$$SSNNM^DGRPU(DFN)
 S DGCT=DGCT+1,DIR("A",DGCT)="",$P(DIR("A",DGCT),"=",81)=""
 S DGCT=DGCT+1,DIR("A",DGCT)=$J("",23)_"**** ENVIRONMENTAL FACTORS ****",DGCT=DGCT+1,DIR("A",DGCT)=" "
 S IND=$S('$G(DGRPV):"[]",1:"<>")
 S DGCT=DGCT+1
 S Z=$E(IND)_"1"_$E(IND,2)
 S DIR("A",DGCT)=$J("",2)_Z_"   A/O Exp.: "_$$YN^SISP6CL(DG321,2)_$S($P(DG321,U,13)="K":" (DMZ) ",$P(DG321,U,13)="V":" (VIET)",1:$J("",7))_" Reg: "_$$DAT^SISP6CL(DG321,7,12)_"  Exam: "_$$DAT^SISP6CL(DG321,9,12)_"A/O#: "_$P(DG321,U,10)
 S Z=$E(IND)_"2"_$E(IND,2)
 S DGCT=DGCT+1,DIR("A",DGCT)=$J("",2)_Z_"   ION Rad.: "_$$YN^SISP6CL(DG321,3)_$J("",8)_"Reg: "_$$DAT^SISP6CL(DG321,11,12)_"Method: "
 S:$P(DG321,U,12)>7 $P(DG321,U,12)="" S DIR("A",DGCT)=DIR("A",DGCT)_$P($T(SELTBL+$P(DG321,U,12)),";;",2)
 S Z=$E(IND)_"3"_$E(IND,2)
 S DGCT=DGCT+1,DIR("A",DGCT)=$J("",2)_Z_" Env Contam: "_$$YN^SISP6CL(DG322,13)_$J("",8)_"Reg: "_$$DAT^SISP6CL(DG322,14,12)_"  Exam: "_$$DAT^SISP6CL(DG322,15,11)
 S DGNONT=0 I $$GETSTAT^DGNTAPI1(DFN)>2,'$D(^XUSEC("DGNT VERIFY",DUZ)) S DGNONT=1
 I $G(DGRPV) S DGNONT=1
 S DGCT=DGCT+1,DIR("A",DGCT)=$J("",2)_$S(DGNONT:"<",1:"[")_"4"_$S(DGNONT:">",1:"]")_" N/T Radium: " N DGNT S DGRPX=$$GETCUR^DGNTAPI(DFN,"DGNT") S DIR("A",DGCT)=DIR("A",DGCT)_$G(DGNT("INTRP"))
 ;
 S DGCT=DGCT+1,DIR("A",DGCT)=" "
 S DIR("A")=$S('$G(DGRPV):"SELECT AN ENVIRONMENTAL FACTOR (1-"_(4-DGNONT)_") OR (Q)UIT: ",1:"PRESS RETURN TO CONTINUE ")
 S DIR(0)=$S('$G(DGRPV):"SA^1:A/O Exp;2:ION Rad;3:Env Contam;"_$S(DGNONT:"",1:"4:N/T Radium;")_"Q:QUIT",1:"EA")
 I '$G(DGRPV) S DIR("B")="QUIT"
 D ^DIR K DIR
 I $G(DGRPV)!$D(DUOUT)!$D(DTOUT)!(Y="Q") S:Y'="Q" QUIT=1 G QUIT
 S Z="603"_$E("0",2-$L(+Y))_+Y
 S DIE=2,DA=DFN,DR=$P($T(@Z),";;",2) D:DR'="" ^DIE
 K DIE,DA,DR
 G EN1
 ;
QUIT Q
 ;
EF(DFN,LIN) ;
 N DG321,DG322,LENGTH,Z,SEQ
 K LIN S (LENGTH,LIN)=0
 S DG321=$G(^DPT(DFN,.321)),DG322=$G(^(.322))
 I $P(DG321,U,2)="Y" D
 . S Z="A/O Exp.",SEQ=1
 . ;S:'$P(DG321,U,7)!'$P(DG321,U,9)!($P(DG321,U,10)="") Z=Z_"(Incomplete)"
 . S:'$P(DG321,U,7)!('$P(DG321,U,9))="" Z=Z_"(Incomplete)"
 . D SETLNEX^SISP6(Z,SEQ,.LIN,.LENGTH)
 ;
 I $P(DG321,U,3)="Y" D
 . S Z="Ion Rad.",SEQ=2
 . S:'$P(DG321,U,11)!($P(DG321,U,12)="") Z=Z_"(Incomplete)"
 . D SETLNEX^SISP6(Z,SEQ,.LIN,.LENGTH)
 ;
 I $P(DG322,U,13)="Y" D
 . I 'LIN S LIN=LIN+1,LIN(LIN)=""
 . S Z="Env Contam.",SEQ=3
 . S:'$P(DG322,U,14)!'$P(DG322,U,15) Z=Z_"(Incomplete)"
 . D SETLNEX^SISP6(Z,SEQ,.LIN,.LENGTH)
 ; N/T Radium Exposure
 N DGNT,DGRPX S DGRPX=$$GETCUR^DGNTAPI(DFN,"DGNT")
 I "NO"'[$G(DGNT("INTRP")) D
 . I 'LIN S LIN=LIN+1,LIN(LIN)=""
 . S SEQ=4 D SETLNEX^SISP6("N/T Radium ("_$P(DGNT("INTRP"),"YES,",2)_")",SEQ,.LIN,.LENGTH)
  Q
  ; The following tag is a table of values.  Do not change location of values including null at SELTBL+0
SELTBL ;;
 ;;NO VALUE
 ;;HIROSHIMA/NAGASAKI
 ;;ATMOSPHERIC NUCLEAR TEST
 ;;H/N AND ATMOSPHERIC TEST
 ;;UNDERGROUND NUCLEAR TEST
 ;;EXP. AT NUCLEAR FACILITY
 ;;OTHER
60301 ;;.32102//NO;S:X'="Y" Y="@65";.3213;.32107;.32109;.3211;@65;
60302 ;;.32103//NO;S:X'="Y" Y="@66";.3212;.32111;@66;
60303 ;;.322013//NO;S:X'="Y" Y="@612";.322014;Q;.322015;@612;
60304 ;;D REG^DGNTQ(DFN)
 ;;
