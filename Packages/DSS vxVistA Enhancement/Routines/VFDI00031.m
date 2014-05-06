VFDI00031 ;DSS/LM - POST-INSTALL (CONT.) ; 09/21/2012 11:43
 ;;2011.1.2;DSS,INC VXVISTA OPEN SOURCE;;28 Jan 2013;Build 153
 ;Copyright 1995-2013,Document Storage Systems Inc. All Rights Reserved
 ;
 ; ICR#  Supported Description
 ; ----  ---------------------------------------------------
 ;       ^DIK, IX^DIK
 ;       MES^XPDUTL
 ;       Unsupported References
 ;       ---------------------------------------------------
 ;       Direct global read of ^ORD(101.41)
 ;
 ; The OR GTX ROUTING dialog may have been deleted from the PSO OERR
 ; dialog.  If this is the case, then the existing PSO OERR dialog will
 ; be deleted and the original FOIA dialog entry will be imported.
 ; This should have to be done only once per system.
 Q
 ;
POST ; Replace edited ORDER DIALOG entry
 ; called from POST^VFDI0003
 ; Check context, delete record, manually set record, reindex record
 Q:$P($G(^ORD(101.41,147,0)),U)'="PSO OERR"
 Q:$P($G(^ORD(101.41,147,10,9,0)),U,2)=148
 Q:$P($G(^ORD(101.41,148,0)),U)'="OR GTX ROUTING"
 Q:$O(^ORD(101.41,147,10,21))>21
 ;
 N I,X,Y,Z,DA,DIK
 L +^ORD(101.41):10 E  D MES(1,5) Q
 S DA=147,DIK="^ORD(101.41," D ^DIK
 F I=1:1 S X=$P($T(DATA+I),";;",2,99) Q:X=""  S @X
 D IX^DIK S X=1+$P(^ORD(101.41,0),U,4),$P(^(0),U,4)=X
 L -^ORD(101.41)
 D MES(6,6)
 Q
 ;
MES(J,K) ;
 ;;----- Unable to LOCK global ^ORD(101.41) ---------------------------
 ;;..... Order Dialog PSO OERR was not updated                    .....
 ;;..... Manually perform the following after this installation   .....
 ;;.....   has completed.                                         .....
 ;;----- >D POST^VFDI00031 --------------------------------------------
 ;;----- Order Dialog PSO OERR restored back to its original state -----
 N A,I,VFD S A=1,VFD(1)="  "
 F I=J:1:K S A=A+1,VFD(A)=$TR($T(MES+I),";"," ")
 D MES^XPDUTL(.VFD)
 Q
 ;
DATA ;;
 ;;^ORD(101.41,147,0)="PSO OERR^Outpatient Medications^^D^4^2^60^1^2"
 ;;^ORD(101.41,147,3)="D PROVIDER^ORCDPSIV Q:$G(ORQUIT)  D EN^ORCDPS1(""O"")"
 ;;^ORD(101.41,147,3.1)="D EN1^ORCDPS1"
 ;;^ORD(101.41,147,4)="D EXIT^ORCDPS1"
 ;;^ORD(101.41,147,5)="^^^Meds, Outpatient^140"
 ;;^ORD(101.41,147,7)="D SC^ORCDPS3"
 ;;^ORD(101.41,147,10,0)="^101.412IA^21^21"
 ;;^ORD(101.41,147,10,1,0)="1^4^^Medication: ^^1^^^^S.O RX"
 ;;^ORD(101.41,147,10,1,1)="Enter the medication you wish to order for this patient."
 ;;^ORD(101.41,147,10,1,2)="1^@1350"
 ;;^ORD(101.41,147,10,1,4)="I '$G(^(.1))!($G(^(.1))>$$NOW^XLFDT)"
 ;;^ORD(101.41,147,10,1,5)="D DEA^ORCDPS1 Q:'$G(DONE)  I $G(ORESET)'=+Y D CHANGED^ORCDPS1(""OI"")"
 ;;^ORD(101.41,147,10,1,6)="N IDX,SCR S IDX=$G(ORDIALOG(PROMPT,""D"")),SCR=$G(ORDIALOG(PROMPT,""S"")) D XHELP^ORDD43(IDX,SCR)"
 ;;^ORD(101.41,147,10,1,9)="D ENOI^ORCDPS1"
 ;;^ORD(101.41,147,10,1,10)="S OROI=+$G(ORDIALOG(PROMPT,INST)) D ORDITM^ORCDPS1(OROI),NFI^ORCDPS1(OROI)"
 ;;^ORD(101.41,147,10,2,0)="2^136^^Dose: ^^1^1^^C^^^^Instructions: "
 ;;^ORD(101.41,147,10,2,1)="Enter the dosage instructions for this order, as an amount and units."
 ;;^ORD(101.41,147,10,2,5)="D CHDOSE^ORCDPS2 Q:'$G(DONE)  D DEFCONJ^ORCDPS1"
 ;;^ORD(101.41,147,10,2,6)="D LIST^ORCD:$G(ORDIALOG(PROMPT,""LIST"")),F^ORCDLGH:'$G(ORDIALOG(PROMPT,""LIST""))"
 ;;^ORD(101.41,147,10,2,9)="D DOSES^ORCDPS2 I $G(ORDIALOG(PROMPT,""LIST"")),'$O(ORDIALOG(PROMPT,0)),'$G(ORENEW) D LIST^ORCD"
 ;;^ORD(101.41,147,10,2,10)="D EXDOSE^ORCDPS2"
 ;;^ORD(101.41,147,10,3,0)="2.1^137^^^^1^^^C^^136"
 ;;^ORD(101.41,147,10,3,1)="Enter the route of administration for this drug."
 ;;^ORD(101.41,147,10,3,2)="^1~3"
 ;;^ORD(101.41,147,10,3,4)="I $P(^(0),U,4)"
 ;;^ORD(101.41,147,10,3,6)="D LIST^ORCD:$G(ORDIALOG(PROMPT,""LIST""))&(X=""?""),P^ORCDLGH:'$G(ORDIALOG(PROMPT,""LIST""))!(X'=""?"")"
 ;;^ORD(101.41,147,10,3,7)="D DEFRTE^ORCDPS1"
 ;;^ORD(101.41,147,10,3,9)="D ROUTES^ORCDPS1"
 ;;^ORD(101.41,147,10,3,10)="S OROUTE=+$G(ORDIALOG(PROMPT,INST))"
 ;;^ORD(101.41,147,10,4,0)="2.2^170^^^^1^^^C^^136"
 ;;^ORD(101.41,147,10,4,1)="Enter a standard schedule for administering this medication."
 ;;^ORD(101.41,147,10,4,5)="D CKSCH^ORCDPS1"
 ;;^ORD(101.41,147,10,4,6)="N DIC,D,DZ S DIC=""^PS(51.1,"",DIC(0)=""EQS"",D=""APPSJ"",DZ=""??"" D MIX^PSSDI(51.1,""PSJ"",.DIC,D,.X)"
 ;;^ORD(101.41,147,10,4,7)="S:$L($G(^TMP(""PSJSCH"",$J))) Y=^($J)"
 ;;^ORD(101.41,147,10,4,9)="S:ORCAT=""I"" REQD=$$SCHREQ^PSJORPOE(OROUTE,OROI,$G(ORDRUG))"
 ;;^ORD(101.41,147,10,4,10)="S ORSCH=$G(ORDIALOG(PROMPT,INST))"
 ;;^ORD(101.41,147,10,5,0)="8^7^^Priority: ^^1^^^C^S.PSO"
 ;;^ORD(101.41,147,10,5,1)="Enter the urgency of this order."
 ;;^ORD(101.41,147,10,5,2)="6^^ROUTINE DONE"
 ;;^ORD(101.41,147,10,5,7)="S Y=+$$RECALL^ORCD(PROMPT) S:Y EDITONLY=1 S:'Y Y=9"
 ;;^ORD(101.41,147,10,5,9)="S ORDIALOG(PROMPT,""D"")=$S(ORCAT=""I"":""S.PSJ"",1:""S.PSO"")"
 ;;^ORD(101.41,147,10,6,0)="10^15^^Comments: ^^^^^C"
 ;;^ORD(101.41,147,10,6,1)="Enter any additional instructions for this order."
 ;;^ORD(101.41,147,10,6,2)=7
 ;;^ORD(101.41,147,10,6,3)="I '$G(PSJNOPC)!($G(ORTYPE)=""Z"")"
 ;;^ORD(101.41,147,10,7,0)="1.1^384^^^^^^^^^4"
 ;;^ORD(101.41,147,10,7,2)="^@1350"
 ;;^ORD(101.41,147,10,7,3)="I 0 ;stuffed in via Instructions"
 ;;^ORD(101.41,147,10,8,0)="5.5^149^^^^^^^C"
 ;;^ORD(101.41,147,10,8,1)="Enter the amount (number of tablets, e.g.) to be dispensed."
 ;;^ORD(101.41,147,10,8,2)="8^^^Quantity:^^1"
 ;;^ORD(101.41,147,10,8,3)="I ORCAT=""O"""
 ;;^ORD(101.41,147,10,8,7)="I $G(ORCAT)=""O"",$G(ORTYPE)'=""Z"" S Y=$$QTY^ORCDPS1 K:Y'>0 Y"
 ;;^ORD(101.41,147,10,8,9)="I ORCAT=""O"" W:$L($G(ORQTY)) !,ORQTY S ORDIALOG(PROMPT,""A"")=""Quantity""_$S($L($G(ORQTYUNT)):"" (""_ORQTYUNT_""): "",1:"": "")"
 ;;^ORD(101.41,147,10,9,0)="7^148^^Pick Up: ^^1^^^RC"
 ;;^ORD(101.41,147,10,9,1)="Enter if the patient is to receive this medication by mail, at the window, or in the clinic."
 ;;^ORD(101.41,147,10,9,3)="I ORCAT=""O"""
 ;;^ORD(101.41,147,10,9,6)="D SETLIST^ORCD"
 ;;^ORD(101.41,147,10,9,7)="I ORCAT=""O"",$G(ORTYPE)'=""Z"" S Y=$S($G(OREVENT):""W"",$D(^PSX(550,""C"")):""M"",1:""W"") I $D(^TMP(""ORECALL"",$J,ORDIALOG,PROMPT,INST)) S Y=^(INST),EDITONLY=1"
 ;;^ORD(101.41,147,10,10,0)="6^150^^Refills: ^^1^^^RC"
 ;;^ORD(101.41,147,10,10,1)="Enter the number of refills to allow for this order."
 ;;^ORD(101.41,147,10,10,2)="9^^^Refills:"
 ;;^ORD(101.41,147,10,10,3)="I ORCAT=""O"",$G(OREFILLS)>0"
 ;;^ORD(101.41,147,10,10,9)="I ORCAT=""O"",'$G(OREFILLS) D MAXREFS^ORCDPS1"
 ;;^ORD(101.41,147,10,11,0)="9^151^^Is this medication for a SC condition? ^^^^^CW^^^^SC: "
 ;;^ORD(101.41,147,10,11,1)="If this medication is for treatment of a service-connected condition, enter YES."
 ;;^ORD(101.41,147,10,11,3)="I ORCAT=""O"",$G(ORCOPAY),$G(ORSC)"
 ;;^ORD(101.41,147,10,11,6)="N DFN S DFN=+ORVP D DIS^DGRPDB"
 ;;^ORD(101.41,147,10,11,7)="I $G(ORTYPE)'=""Z"",ORCAT=""O"",$G(ORCOPAY),$G(ORSC) S Y=$S($P(ORSC,U,2)>50:1,1:0)"
 ;;^ORD(101.41,147,10,11,9)="I ORCAT=""O"" S ORCOPAY=$$ASKSC^ORCDPS1 I ORCOPAY,$G(ORSC),'$D(ORDIALOG(PROMPT,INST)) N DFN S DFN=+ORVP D:$P(ORSC,U,2)'>50 DIS^DGRPDB S:$P(ORSC,U,2)>50 $P(ORDIALOG(PROMPT,0),U)=""YA"",EDITONLY=1 ; Req'd"
 ;;^ORD(101.41,147,10,12,0)="2.3^153^^How long: ^^^^^C^^136"
 ;;^ORD(101.41,147,10,12,1)="Enter the length of time over which this dose is to be administered as '4 HOURS', '7 DAYS', '2 WEEKS', or '1 MONTH'."
 ;;^ORD(101.41,147,10,12,2)="^^^FOR"
 ;;^ORD(101.41,147,10,12,3)="I $$ASKDUR^ORCDPS3"
 ;;^ORD(101.41,147,10,12,5)="D DUR^ORCDPS3"
 ;;^ORD(101.41,147,10,12,7)="Q  I $G(ORTYPE)'=""Z"",$G(ORCAT)=""I"",$G(ORCOMPLX),$P($G(ORSD),U,3) S Y=+$P(ORSD,U,3)_"" DAYS"""
 ;;^ORD(101.41,147,10,13,0)="4^6^^Start: ^^^^1^C"
 ;;^ORD(101.41,147,10,13,1)="Enter the date this order should begin."
 ;;^ORD(101.41,147,10,13,3)="I $G(ORCAT)=""O"",$G(OREVENT) ;discharge orders only"
 ;;^ORD(101.41,147,10,13,7)="Q  I $G(ORTYPE)'=""Z"",ORCAT'=""O"" S Y=$P($G(ORSD),U) K:'$L(Y) Y"
 ;;^ORD(101.41,147,10,13,9)="D START^ORCDPS3 ;I 'FIRST,$G(ORDIALOG(PROMPT,""LIST"")),'$O(ORDIALOG(PROMPT,0)) D LIST^ORCD ;editonly"
 ;;^ORD(101.41,147,10,14,0)="3^385"
 ;;^ORD(101.41,147,10,14,2)="2^^^^^1^0"
 ;;^ORD(101.41,147,10,14,3)="I 0 ;created by Instructions, if Outpt order"
 ;;^ORD(101.41,147,10,15,0)="2.5^386^^^^^^^*^^136"
 ;;^ORD(101.41,147,10,15,2)="^@"
 ;;^ORD(101.41,147,10,15,3)="I 0 ;created by Instructions"
 ;;^ORD(101.41,147,10,15,7)="S Y=$$ID^ORCDPS K:'$L(Y) Y"
 ;;^ORD(101.41,147,10,16,0)="2.6^138^^^^^^^*"
 ;;^ORD(101.41,147,10,16,3)="I 0 ;created by Instructions"
 ;;^ORD(101.41,147,10,17,0)="5^387^^^^1^^^C"
 ;;^ORD(101.41,147,10,17,1)="Enter the number of days for which the patient needs this medication."
 ;;^ORD(101.41,147,10,17,3)="I $G(ORCAT)=""O"""
 ;;^ORD(101.41,147,10,17,5)="I $G(ORESET),+ORESET'=+Y D CHANGED^ORCDPS1(""DS"")"
 ;;^ORD(101.41,147,10,17,9)="I $G(ORCAT)=""O"" D DSUP^ORCDPS1"
 ;;^ORD(101.41,147,10,17,10)="S:$G(ORCAT)=""O"" ORDSUP=+$G(ORDIALOG(PROMPT,INST))"
 ;;^ORD(101.41,147,10,18,0)="1.5^1350"
 ;;^ORD(101.41,147,10,18,2)=1.5
 ;;^ORD(101.41,147,10,18,3)="I 0 ;stuffed in via Instructions"
 ;;^ORD(101.41,147,10,19,0)="2.4^388^^^^^^^C^^136"
 ;;^ORD(101.41,147,10,19,1)="Enter AND if the next dose is to be administered concurrently with this one, or THEN if it is to follow after."
 ;;^ORD(101.41,147,10,19,3)="I $G(ORCOMPLX)"
 ;;^ORD(101.41,147,10,19,5)="I $G(ORESET)'=$P(Y,U) D CHANGED^ORCDPS1(""QUANTITY"")"
 ;;^ORD(101.41,147,10,19,9)="D ENCONJ^ORCDPS1"
 ;;^ORD(101.41,147,10,19,10)="I $G(ORCOMPLX),'$L($G(ORDIALOG(PROMPT,INST))),FIRST S MAX=1 ;stop prompting dose multiple"
 ;;^ORD(101.41,147,10,20,0)="3.5^1358^^^^^^^C"
 ;;^ORD(101.41,147,10,20,2)=3
 ;;^ORD(101.41,147,10,20,3)="I 0 ;text stuffed via Entry Action"
 ;;^ORD(101.41,147,10,20,9)="D PI^ORCDPS2"
 ;;^ORD(101.41,147,10,21,0)="4.5^1359"
 ;;^ORD(101.41,147,10,21,2)="10^^^First Dose^^1"
 ;;^ORD(101.41,147,10,21,3)="I 0 ;set via Entry Action"
 ;;^ORD(101.41,147,10,21,9)="D NOW^ORCDPS3"
 ;;^ORD(101.41,147,99)="61468,51809"
 ;;
