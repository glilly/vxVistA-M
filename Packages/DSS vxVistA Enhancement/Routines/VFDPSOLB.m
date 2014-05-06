VFDPSOLB ;DSS/SGM - SUPPORT FOR MODS FOR PSO LABELS ; 10/05/2012 18:14
 ;;2011.1.2;DSS,INC VXVISTA OPEN SOURCE;;28 Jan 2013;Build 153
 ;Copyright 1995-2013,Document Storage Systems Inc. All Rights Reserved
 ;
 ;This routine is invoked from various PSO label print routines.
 ;The mods in those routines check for $G(VFDPSOLB) to determine as to
 ;whether it should come to this routine or continue processing like a
 ;VA VistA routine (OSEHRA Compliance).
 ;
OUT I 1
 Q
 ;
COPAY(SRC) ; remove the display of any copay messages (COPAYVAR)
 N X,Y S SRC=$G(SRC)
 I SRC="LBLN" D  ; called from L12^PSOLBLN2
 . W !,$P(PS,U,2),?54,"Days Supply: "_$G(DAYS),?102
 . W "Tech__________RPh_________",!,$P(PS,U,7)_", "
 . W STATE_" "_$G(PSOHZIP)
 . Q
 I SRC="LLL3" D PRINT("")
 I SRC="" D  ; called from START^PSOLBLN1
 . W !?54,"Days Supply: "_$G(DAYS),?102,"Mfg "_$G(MFG)_" Lot# "_$G(LOT)
 . Q
 G OUT
 ;
DEA ; called from START^PSOLBLN1
 ; change ?54,"*DEA or VA# to ?54,"*DEA#
 W !,?54,"*Print Name:"_ULN_"*",!
 W $S($G(PS55)=2:"***DO NOT MAIL***",1:"***CRITICAL MEDICAL SHIPMENT***")
 W ?54,"*DEA #_________________Date_____________*"
 W ?102,"Routing: "_$S("W"[$E(MW):MW,1:MW_" MAIL")
 W !,?54,"*Refills: 0 1 2 3 4 5 6 7 8 9 10 11",?99,"*"
 W ?102,"Days Supply: "_$G(DAYS)_" Cap: "_$S(PSCAP:"**NON-SFTY**",1:"SAFETY")
 ; remove ,?54,"***** To be filled in VA Pharmacies only *****"
 W !,?102,"Isd: "_ISD_" Exp: "_EXPDT,!,PNM,?54,$G(VAPA(1)),?102,"Last Fill: "_$G(PSOLASTF)
 ; remove Pat. Stat
 W !,$S($D(PSMP(1)):PSMP(1),1:VAPA(1)),?54,$G(ADDR(2)),?102,"Clinic: "_PSCLN
 G OUT
 ;
MAIL(VFDMAIL,SITE,PTECH,FORM) ;
 ; .VFDMAIL - return mailing address
 ;  SITE - req - pointer to file 59
 ; PTECH - opt - Boolean flag to include TECH on address line
 ;   return address formats
 ;  FORM - opt - addess format
 ;  FORM - 1 [default]                           | FORM = 2
 ;---------------------------------------------- | --------------------
 ;<name>                                         | <name>
 ;<street address>    PH: <phone>                | <street address>
 ;<city, state zip>    <pharmacist's initial(s)> | <city, state zip>
 ;                                               | PH: <phone>   pharm inits
 N I,J,X,Y,Z,PF,PH,VFDT K VFDMAIL
 S FORM=$G(FORM) S:'FORM FORM=1
 F I=1:1:4 S VFDMAIL(I)=""
 Q:'$G(SITE)
 K Z F I=0,21600 S Z(I)=$G(^PS(59,+SITE,I))
 ; get site name
 S X=$P(Z(0),U),Y=$P(Z(21600),U,2) S:Y'="" X=Y S VFDMAIL(1)=X
 S Y="",J=$P(Z(0),U,3) S:$L(J) Y=J_"-" S J=$P(Z(0),U,4) S:$L(J) Y=Y_J
 S PH="" I Y'="" S PH="PH: "_Y
 S VFDMAIL(2)=$P(Z(0),U,2) S:FORM=1 VFDMAIL(2)=VFDMAIL(2)_"     "_PH
 S:FORM=2 VFDMAIL(4)=PH
 ; set city, st zip
 S X=$P(Z(0),U,7),Y=$P(Z(0),U,8) S:Y Y=$G(^DIC(5,+Y,0))
 I $L(Y) S J=$P(Y,U,2) S:J="" J=$P(Y,U) S Y=J
 S:$L(X) X=X_", " S X=X_Y ; city, st
 S Y=$P(Z(0),U,5)
 I $L(Y) D ZIPOUT^PSOUTLA S:$L(X) X=X_" " S X=X_Y ; zip
 S VFDMAIL(3)=X,VFDT=""
 I $G(PTECH),$G(TECH)'="" D
 . S (I,J,X)=""
 . I TECH["/" S I=$P($P(TECH,"/"),"(",2),J=$P($P(TECH,"/",2),")")
 . I I="" S I=$P($P(TECH,"(",2),")")
 . S Y=$P($G(^VA(200,+I,0)),U,2)
 . I +J S Y=Y_"/"_$P($G(^VA(200,+J,0)),U,2)
 . I $L(Y) S VFDT="("_Y_")"
 . Q
 S I=$S(FORM=1:3,FORM=2:4,1:3)
 I $L(VFDT) S VFDMAIL(I)=VFDMAIL(I)_"    "_VFDT
 G OUT
 ;
PSTAT(SRC) ; remove printing of patient status
 ; patient status (#53) are all veteran specific
 ; usually will remove "Pat. Stat "_PATST prior to clinic
 N X,Y S SRC=$G(SRC)
 I SRC="LBLN" D  ; called from L12^PSOLBLN
 . W !,$S($D(PSMP(1)):PSMP(1),1:$G(VAPA(1)))
 . W ?54,"[ ] Permanent",?102,"Clinic: ",PSCLN
 . Q
 I SRC="LBLN1" D  ; called from NORENW^PSOLBLN1
 . W !,$S($D(PSMP(2)):PSMP(2),$D(PSMP(1)):"",1:$G(ADDR(2))),?54
 . W "*Indicate address change on back of this form"
 . W ?102," Clinic: ",PSCLN
 . Q
 I SRC="LLL2" D  ; called from L12^PSOLLL2
 . S PTEXT="Clinic: "_PSCLN D STRT^PSOLLU1("SIG2",PTEXT,.L)
 . S T=PTEXT D PRINT(T,1)
 . Q
 I SRC="LLL8"!(SRC="LLL9") D  ; called from START^PSOLLL9
 . S X="Clinic: "_PSCLN D PRINT(X)
 . Q
 G OUT
 ;
SVC(SRC) ; replace (119) with "" or Pharmacy
 ; SRC - req - last chars of calling routine
 N X,Y S SRC=$G(SRC)
 I SRC="LBL1" D  ; called from START^PSOLBL1
 . ; exactly same, except VA (119) removed prior to ?10
 . W $C(13) S $X=0 W ?10,$$FMTE^XLFDT(DT,"2Z")
 . W:('SIDE)&(PRTFL) ?40,"PLEASE REFER ONLY TO '",$S(REF:"1. REFILL REQUEST",1:"2. RENEWAL ORDER"),"'"
 . W:+$G(RXP) ?100,"(PARTIAL)" W:$D(REPRINT) ?110,"(REPRINT)"
 . Q
 I SRC="LBLN2" D  ; called from START^PSOLBLN2
 . S ^TMP($J,"PSOMAIL",$S(PRCOPAY:1,1:3))="Pharmacy Service" ; removed (119)
 . S ^($S(PRCOPAY:2,1:4))=$G(VAADDR1)
 . S ^($S(PRCOPAY:3,1:5))=$G(VASTREET)
 . S ^($S(PRCOPAY:4,1:6))=$P(PS,U,7)_", "_$G(STATE)_" "_$G(PSOHZIP)
 . Q
 I SRC="LLL1" D  ; called from WARN^PSOLLL1
 . S T=$E("Attn: Pharmacy"_BLNKLIN,1,40)_$$FMTE^XLFDT(DT) D PRINT(T,1)
 . Q
 I SRC="LLL7" D  ; called from MAIL^PSOLLL7
 . S TEXT="Attn: Pharmacy" D PRINT(TEXT,1)
 . Q
 G OUT
 ;
VAMC(SRC) ; replace VAMC chars with 1-4 char abbrev from 59,21600.01
 ; SRC - req - last chars of calling routine
 N I,J,X,Y S SRC=$G(SRC)
 ; build y = name city, state zip
 S X=$P($G(^PS(59,+$G(PSOSITE),21600)),U),X=$E(X_" ",1,5)
 S Y=X_$P(PS,U,7)_", "_STATE_" "_$G(PSOHZIP)
 I SRC="LBL2" D  ; called from REP^PSOLBL2
 . W Y,?102,"(REPRINT)" W:$G(RXP) "(PARTIAL)"
 . W !,$P(PS2,U,2)_" "_$P(PS,U,3)_"-"_$P(PS,U,4)_" "_TECH
 . Q
 I SRC="LBLN" D  ; called from L1^PSOLBLN
 . W " "_Y,?54,Y,?102
 . W:$D(REPRINT) $S($G(PSOBLALL):"(GROUP REPRINT)",1:"(REPRINT)")
 . W:$G(RXP) "(PARTIAL)"
 . Q
 I SRC="LLL1"!(SRC="LLLH") D
 . ; called from L1^PSOLLL1 or HDR^PSOLLLH
 . I SIGF!$G(FILLCONT) D PRINT(" ",1),PRINT(" ",1) Q
 . N X,VFD S X=(SRC="LLL1")
 . D MAIL(.VFD,PSOSITE,X)
 . F X="PSOFONT","PSOX" S @("VFD(0,X)="_X)
 . S PSOFONT=-999,PSOX=0
 . S VFD(-1)=$C(27)_"(10U"_$C(27)_"(s1p7v0s3b16602T"
 . S VFD(-2)=$C(27)_"(10U"_$C(27)_"(s1p7v0s0b16602T"
 . S VFD(1)=VFD(-1)_VFD(1)_VFD(-2)
 . F I=2,3,4 S VFD(I)=VFD(-2)_VFD(I)
 . F I=1:1:4 D PRINT(VFD(I))
 . F X="PSOFONT","PSOX" S @(X_"=VFD(0,X)")
 . Q
 G OUT
 ;
 ;----------------------- PRIVATE SUBROUTINES -----------------------
PRINT(T,F) ;
 I $G(F)=1 I $G(PSOIO(PSOFONT))]"" X PSOIO(PSOFONT)
 I $G(PSOIO("ST"))]"" X PSOIO("ST")
 W T,!
 I $G(PSOIO("ET"))]"" X PSOIO("ET")
 Q
