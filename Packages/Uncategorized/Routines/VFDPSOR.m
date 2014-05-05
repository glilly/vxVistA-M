VFDPSOR ;DSS/WLC - VXVISTA RX COMPLETE ; 6/5/2013 15:45
 ;;2011.1.2;DSS,INC VXVISTA OPEN SOURCE;;11 Jun 2013
 ;Copyright 1995-2013,Document Storage Systems Inc. All Rights Reserved
 ;
 ;This routine is called to finish and release an ordered prescription
 ;without the use of backdoor O/P Pharmacy.  The result of this routine
 ;is to create a ^XTMP global with pertinent information from the
 ;prescription to be used by the VFDPOAE routine to generate a printed
 ;prescription to be given to the patient upon leaving.
 ; 
 ;[DSS/LM] - New remote procedure VFD PS LABELS BY ORDER LIST does not
 ;use data saved in ^XTMP by this routine.  Old remote procedure
 ;VFD PS PT OUTLABEL is no longer supported and should be removed.
 ;Therefore, ^XTMP will no longer be used for storage of prescription
 ;data for subsequent use by RPC.  ^XTMP sets removed 11/2/2006
 ; 
 ;Direct sets to the Prescription global used in order to get around
 ;inconsistencies with the global and FILEMAN.  Specifically, an error
 ;occurs when trying to add a record through the database calls because
 ;a previous field is using a subsequently set field as part of a MUMPS
 ;style cross-reference.  Since the latter field has not been added to
 ;the file yet, the cross-reference errors out.  In addition, there are
 ;some inconsistencies with required identifiers in the file.  This
 ;program does use some FILEMAN database calls to do updates once the
 ;record is created.
 ; 
 ; ICR:
 ; 4821    PEN^PSO5241
 ; Add, edits, and delete to file #52 and 52.41 have NO ICR's
 ;
 Q
 ;
 ;DSS/LM 9/21/2006 - Per Steve, remove references to ^XTMP.
 ;I.e. Do not save PSOIEN list in ^XTMP.  RPC will furnish [placer]
 ;orders list.  RPC code will use File 52 "RPL" x-ref.
 ;
RELEASE ; Finish and Release the order from PS(52.41 & OR(100)
 N %,I,X,X1,X2,Y,Z,DA,DIE,DIK,DOSE,DOSE1,DR,ERR,FDAX,II,OR0,ORVP,PEND
 N PSOANSQ,PSOCOM,PSOCOU,PSOCOUU,PSOCS,PSODAT,PSODATE,PSODFN,PSODRG
 N PSODRUG,PSOIEN,PSOINS1,PSOL,PSOM,PSONEW,PSONRXN,PSOORG,PSOPEN,PSOPI
 N PSOPRC,PSOREC0,PSORET,PSORSTAT,PSORX,PSORXN,PSOSCP,PSOSIG,PSOSITE
 N PSOTN,PSOY,PTRF,REC,ROUTE,SIGOK,SITE,UNITS,VFDXX
 S X=+$G(VFDORD) N VFDORD S VFDORD=X
 ; Ignore order if Pick Up field is set to "C" (Clinic) 6/5/2013
 N VFDPUI,VFDPU
 S VFDPUI=$O(^OR(100,VFDORD,4.5,"ID","PICKUP",""))
 I VFDPUI S VFDPU=$G(^OR(100,VFDORD,4.5,VFDPUI,1)) I VFDPU="C" Q
 S VFDMSG=""
 S (PSOINS1,PSOPI,PSOPRC,PSOSIG,PSOSITE)=0
 ;LM, Replace ^XMB(1.1) with reference with patient location specific
 ;    OUTPATIENT SITE computation.
 I VFDORD S PSOSITE=$$SITE^VFDPSUTL(VFDORD)
 I 'PSOSITE D  I 'PSOSITE Q
 . S X=$P($G(^XMB(1,1,"XUS")),U,17) S:X PSOSITE=$O(^PS(59,"D",X,""))
 . S:'PSOSITE VFDMSG="-1^Could not identify OUTPATIENT SITE"
 . Q
 ; DSS/LM: End substitution
 I VFDORD="" S VFDMSG="-1^No Order number sent" Q
 I $G(^OR(100,VFDORD,0))="" S VFDMSG="-1^Order file entry not found" Q
 ; DSS/WLC - Mods for Discontinuing previous Prescription on Renewal
 S VFDORG=$$GET1^DIQ(100,VFDORD_",",9)
 ;S PSOORG=$$GET1^DIQ(100,VFDORG_",",33)
 I VFDORG D EN^VFDPSORR Q:'$D(PSOORG)  ; no renew as orig script (#52) not found 
 ; End Mods - WLC
 K FDAX
 S PSODFN=+$$GET1^DIQ(100,VFDORD_",",.02,"I")  ; patient DFN
 S PSOCOM=$O(^VA(200,"B","COMMERCIAL,PHARMACY",""))
 I PSOCOM="" S VFDMSG="-1^COMMERCIAL,PHARMACY not setup in NEW PERSON (#200) File." Q
 ; DSS/LM: Comment-out PSOSITE set here
 ;         PSOSITE has been defined in $$SITE^VFDPSUTL call above
 K PEND,ERR
 S PSOPEN=$O(^PS(52.41,"B",VFDORD,""))
 D GETS^DIQ(52.41,PSOPEN_",","**","I","PEND","ERR")
 I $D(ERR) S VFDMSG="-1^Error retrieving Pending Order" Q
 S PSODRG=+PEND(52.41,PSOPEN_",",11,"I")
 I 'PSODRG S VFDMSG="-1^Unidentified DRUG" Q  ;DSS/LM
 S PSODRUG("IEN")=PSODRG,PSODRUG("DEA")=$$GET1^DIQ(50,PSODRG_",",3)
 D AUTO^PSONRXN S PSORXN=PSONEW("RX #") ;auto-numbering of prescription
 ;
 S PSODATE=$$NOW^XLFDT,PSODAT=$P(PSODATE,".",1)
 ; DSS/LM - Per Steve, revise PSOIEN computation and lock 0-node
 S PSOIEN=$$PSRXIEN^VFDPSUTL Q:'PSOIEN  L +^PSRX(PSOIEN):2 E  Q
 ;
 ; DSS/WLC  Begin Mods for Renewals
 I $G(PSONRXN)'="" D  ; PSONRXN is from VFDPSORR, only set on renewal
 . S PSORXN=PSONRXN   ; replace auto-generated number with renewal number
 . S $P(^PSRX(PSOIEN,"OR1"),U,3)=$G(PSOORG)  ; Same as source for PSONRXN
 . S $P(^PSRX(PSOORG,"OR1"),U,4)=PSOIEN      ; Forward Order #
 ; End Mods
 ;
 S VFDXX=$G(^PSRX(PSOIEN,0))
 S $P(VFDXX,U,1)=PSORXN                         ; RX #
 S $P(VFDXX,U,13)=PSODAT                        ; ISSUE DATE
 S $P(VFDXX,U,2)=PSODFN                         ; PATIENT
 S $P(VFDXX,U,3)=20                             ; PATIENT STATUS = NON-VA
 S $P(VFDXX,U,4)=PEND(52.41,PSOPEN_",",5,"I")   ; PROVIDER
 S $P(VFDXX,U,5)=PEND(52.41,PSOPEN_",",1.1,"I") ; CLINIC
 S $P(VFDXX,U,6)=PSODRG                         ; DRUG
 S $P(VFDXX,U,7)=PEND(52.41,PSOPEN_",",12,"I")  ; QTY
 S $P(VFDXX,U,8)=PEND(52.41,PSOPEN_",",101,"I") ; DAYS SUPPLY
 S $P(VFDXX,U,9)=PEND(52.41,PSOPEN_",",13,"I")  ; NUM OF REFILLS
 S $P(VFDXX,U,11)="W"                           ; MAIL/WINDOW
 S $P(VFDXX,U,16)=+DUZ                          ; ENTERED BY
 S $P(VFDXX,U,17)=$$GET1^DIQ(50,PSODRG_",",404) ; UNIT PRICE OF DRUG
 S $P(VFDXX,U,18)=1
 S ^PSRX(PSOIEN,0)=VFDXX                        ; COPIES
 S $P(^PSRX(PSOIEN,"STA"),U,1)=0                ; STATUS
 S VFDXX=$G(^PSRX(PSOIEN,2))
 S $P(VFDXX,U,1)=PSODATE                        ; LOGIN DATE
 S $P(VFDXX,U,2)=PSODATE                        ; FILL DATE
 S $P(VFDXX,U,3)=PSOCOM                         ; PHARMACIST
 S X1=PSODAT
 S X2=PEND(52.41,PSOPEN_",",101,"I")*(PEND(52.41,PSOPEN_",",13,"I")+1)\1
 S:X2=0 X2=PEND(52.41,PSOPEN_",",101,"I")
 S $P(VFDXX,U,6)=$$FMADD^XLFDT(X1,X2) K X1,X2   ; STOP DATE
 S $P(VFDXX,U,9)=PSOSITE                        ; DIVISION
 S $P(VFDXX,U,13)=PSODATE                       ; RELEASED DATE/TIME
 S ^PSRX(PSOIEN,2)=VFDXX
 S $P(^PSRX(PSOIEN,3),U,1)=PSODATE              ; LAST DISPENSED DATE
 ; SIG
 S PSOM=+$P($G(^PS(52.41,+PSOPEN,"SIG",0)),U,4)
 I +PSOM>0 D
 . F PSOL=1:1:PSOM D
 . . N X,Y,Z
 . . S Y=PEND(52.4124,PSOL_","_PSOPEN_",",.01,"I"),Z=Y
 . . S X=$F(Y,"BY BY") I X>0 S Z=$E(Y,1,X-4)_$E(Y,X,99)
 . . S ^PSRX(PSOIEN,"SIG1",PSOL,0)=Z
 . S ($P(^PSRX(PSOIEN,"SIG1",0),U,3,4),PSOSIG)=PSOM
 ;
 ; EXPANDED PATIENT INSTRUCTIONS
 ;
 S PSOM=+$P($G(^PS(52.41,PSOPEN,"INS1",0)),U,4)
 I +PSOM>0 D
 . F PSOL=1:1:PSOM D
 . . N X,Y,Z
 . . S Y=$G(^PS(52.41,PSOPEN,"INS1",PSOL,0)) Q:Y=""
 . . S Z=Y
 . . S X=$F(Y,"BY BY") I X>0 S Z=$E(Y,1,X-4)_$E(Y,X,99)
 . . S ^PSRX(PSOIEN,"INS1",PSOL,0)=Z
 . S ($P(^PSRX(PSOIEN,"INS1",0),U,3,4),PSOINS1)=PSOM
 ; 
 ; SIG
 ;
 S PSOM=+$P($G(^PS(52.41,+PSOPEN,"SIG",0)),U,4)
 I +PSOM>0 D
 . F PSOL=1:1:PSOM D
 . . N X,Y,Z
 . . S Y=PEND(52.4124,PSOL_","_PSOPEN_",",.01,"I"),Z=Y
 . . S X=$F(Y,"BY BY") I X>0 S Z=$E(Y,1,X-4)_$E(Y,X,99)
 . . S ^PSRX(PSOIEN,"SIG1",PSOL,0)=Z
 . S ($P(^PSRX(PSOIEN,"SIG1",0),U,3,4),PSOSIG)=PSOM
 ;
 ;
 ; SCHEDULE/ROUTE
 ; 
 F PSOL=1:1 Q:'$D(^PS(52.41,PSOPEN,1,PSOL,0))  D
 . N PSARR,PS1,PS2 S PSARR=$NA(^PSRX(PSOIEN,6,PSOL,0))
 . S PS1=$G(^PS(52.41,PSOPEN,1,PSOL,1))
 . S PS2=$G(^PS(52.41,PSOPEN,1,PSOL,2))
 . S $P(@PSARR,U,1)=$P(PS2,U,1)
 . S $P(@PSARR,U,2)=$P(PS2,U,2)
 . S $P(@PSARR,U,3)=$P(PS1,U,9)
 . S $P(@PSARR,U,4)=$P(PS1,U,5)
 . S $P(@PSARR,U,5)=$P(PS1,U,2)
 . S $P(@PSARR,U,6)=$P(PS1,U,6)
 . S $P(@PSARR,U,7)=$P(PS1,U,8)
 . S $P(@PSARR,U,8)=$P(PS1,U,10)
 . S ^PSRX(PSOIEN,6,0)="^52.0113^"_PSOL_U_PSOL
 ;
 ; PHARMACY INSTRUCTIONS
 ; 
 F PSOL=1:1 Q:'$D(^PS(52.41,PSOPEN,2,PSOL,0))  D
 .S ^PSRX(PSOIEN,"PI",PSOL,0)=^PS(52.41,PSOPEN,2,PSOL,0)
 .S ^PSRX(PSOIEN,"PI",0)="^52.02^"_PSOL_U_PSOL,PSOPI=PSOL
 .Q
 ;
 ; PROVIDER COMMENTS
 ;
 F PSOL=1:1 Q:'$D(^PS(52.41,PSOPEN,3,PSOL,0))  D
 .S ^PSRX(PSOIEN,"PRC",PSOL,0)=^PS(52.41,PSOPEN,3,PSOL,0)
 .S ^PSRX(PSOIEN,"PRC",0)="^52.039^"_PSOL_U_PSOL,PSOPRC=PSOL
 .Q
 ;
 ; DSS/WLC - copy patient instructions into SIG field
 ; code for SIG cloned from PSOORFI4
 I $$GET^XPAR("SYS","VFD PSO PROVIDER COMMENTS")=1 D
 . N I,PSONEW,NC,NI,X
 . F I=1:1:PSOSIG S PSONEW("SIG",I)=$G(^PS(52.41,PSOPEN,"SIG",I,0))
 . I PSOPRC>0 D
 . . F I=1:1:PSOPRC S PRC(I)=$G(^PSRX(PSOIEN,"PRC",I,0))
 . . S NI=PSOSIG
 . . ;CLONED & MODIFIED FOR VARIABLE NAMES CODE
 . . I PSOSIG'>1,PSOPRC'>1,($L($G(PSONEW("SIG",1)))+$L(PRC(1)))'>250 D  Q 
 . . . S X=PRC(1) D SIGONE^PSOHELP
 . . . S PSONEW("SIG",1)=$G(PSONEW("SIG",NI))_INS1 K INS1,X
 . . . S:$E(PSONEW("SIG",1))=" " PSONEW("SIG",1)=$E(PSONEW("SIG",1),2,250) S PSONEW("INS")=PSONEW("SIG",1) D EN^PSOFSIG(.PSONEW,1)
 . . . S ^PSRX(PSOIEN,"SIG1",1,0)=PSONEW("SIG",1),^PSRX(PSOIEN,"INS1",1,0)=PRC(1)
 . . F I=0:0 S I=$O(PRC(I)) Q:'I  S NI=NI+1,(PSONEW("SIG",NI),X)=PRC(I) D SIGONE^PSOHELP S PSONEW("SIG",NI)=INS1 K INS1
 . . I $E(PSONEW("SIG",1))=" " S PSONEW("SIG",1)=$E(PSONEW("SIG",1),2,250)
 . . D EN^PSOFSIG(.PSONEW,1)
 . . ;END CLONED CODE
 . . N SIGCNT S (PSOL,SIGCNT)=0 F  S PSOL=$O(PSONEW("SIG",PSOL)) Q:'PSOL  S ^PSRX(PSOIEN,"SIG1",PSOL,0)=PSONEW("SIG",PSOL),SIGCNT=SIGCNT+1
 . . ;B  F PSOL=1:1:PSOPRC D
 . . ;S ^PSRX(PSOIEN,"SIG1",(PSOL+PSOSIG),0)=PSONEW("SIG",(1+PSOL))
 . . ;S X=PSOSIG+NI
 . . S ^PSRX(PSOIEN,"SIG1",0)="^52.04A^"_SIGCNT_U_SIGCNT
 . . F PSOL=1:1:PSOPRC D
 . . . S ^PSRX(PSOIEN,"INS1",(PSOL+PSOINS1),0)=PRC(PSOL)
 . . . S X=(PSOL+PSOINS1)
 . . S ^PSRX(PSOIEN,"INS1",0)="^52.0115^"_X_U_X
 ; DSS/WLC - End Mods 08/09/2011
 ;
 ; DSS/LM - moved to before re-index entry, for placer order index
 ; store placer number and pharmacist
 S $P(^PSRX(PSOIEN,"OR1"),U,2)=VFDORD
 S $P(^PSRX(PSOIEN,"OR1"),U,5,6)=$P(^PSRX(PSOIEN,0),U,4)
 ; kill extra node for active orders
 K ^PS(55,PSODFN,"P","A",$P(^PSRX(PSOIEN,2),U,6),PSOIEN)
 L -^PSRX(PSOIEN),-^PSRX("B",PSORXN)
 S DA=PSOIEN,DIK="^PSRX(" D IX1^DIK  ; re-index this entry
 ; update finishing, filling person, and checking pharmacist
 N I,VFDFDA,VFDMSG
 K VFDFDA,VFDMSG
 S VFDFDA(52,PSOIEN_",",31)=$$NOW^XLFDT
 F I=38:.1:38.2,104,23 S VFDFDA(52,PSOIEN_",",I)=PSOCOM
 ; LM 1/31/2007 - Remove field 4 and 30 (provider fields)
 ;S VFDFDA(52,PSOIEN_",",30)="COMMERCIAL,PHARMACY"
 S VFDFDA(52,PSOIEN_",",10.1)=1 ;OERR SIG
 ; End change 1/24/2007
 D FILE^DIE("","VFDFDA","VFDMSG")
 D PS55
 ;
 ; ***** End Prescription file updates *****
 D EN^PSOHLSN1(PSOIEN,"ZD")
 ;
 ; ORDER (#100) FILE updates
 ; update status of order
 S X=$O(^ORD(100.01,"B","WRITTEN","")),PSORSTAT=$S(X>0:X,1:6)
 S ORVP=$$GET1^DIQ(100,VFDORD_",",.02)
 ; DSS/LM - Remove set of ^PSRX(0) in next -- Already set
 S X=$G(^PSRX(0)),Y=$P(X,U,3)+1,Z=$P(X,U,4)+1,$P(X,U,3)=Y,$P(X,U,4)=Z
 D STATUS^ORCSAVE2(VFDORD,PSORSTAT)
 ; mark order as released
 D RELEASE^ORCSAVE2(VFDORD,1,,$P(^PSRX(PSOIEN,0),U,4),9)
 ; update start and stop dates in ORDERS file
 K VFDFDA,VFDMSG
 S VFDFDA(100,VFDORD_",",21)=$P(^PSRX(PSOIEN,2),U,2)
 S VFDFDA(100,VFDORD_",",22)=$P(^PSRX(PSOIEN,2),U,6)
 S VFDFDA(100,VFDORD_",",1)=PSOCOM
 S VFDFDA(100.008,"1,"_VFDORD_",",17)=PSOCOM
 S VFDFDA(100,VFDORD_",",33)=PSOIEN
 S VFDFDA(100,VFDORD_",",66)=$$NOW^XLFDT
 S VFDFDA(100,VFDORD_",",67)=PSOCOM
 S VFDFDA(100.008,"1,"_VFDORD_",",16)=$$NOW^XLFDT
 D FILE^DIE("","VFDFDA","VFDMSG")
 ; DSS/WLC Begin Mods
 ; Modification to ORDERS (#100) file for Patient Instructions.
 ;
 I $$GET^XPAR("SYS","VFD PSO PROVIDER COMMENTS")=1 D
 . N OFF,X,XREC
 . ; Patient Instructions
 . I PSOPRC>0 D
 . . F I=1:1:PSOPRC S PRC(I)=$G(^PSRX(PSOIEN,"PRC",I,0))
 . S XREC=$$FIND("PI")  ; get rec # to update
 . S OFF=$O(^OR(100,VFDORD,4.5,XREC,2,"A"),-1)
 . F PSOL=1:1:PSOPRC D
 . . S X=PRC(PSOL)
 . . S ^OR(100,VFDORD,4.5,XREC,2,(PSOL+OFF),0)=PRC(PSOL)_" "
 . S X=OFF+PSOL
 . I X>0 D
 . . S ^OR(100,VFDORD,4.5,XREC,0)="20^1358^1^PI"
 . . S ^OR(100,VFDORD,4.5,XREC,2,0)="^^"_X_U_X_U_$P(DT,".",1)_U
 . . S:'$D(^OR(100,VFDORD,4.5,"ID","PI")) ^OR(100,VFDORD,4.5,"ID","PI",XREC)=""
 . ; SIG
 . S XREC=$$FIND("SIG")  ; get rec # to update
 . S OFF=$O(^OR(100,VFDORD,4.5,XREC,2,"A"),-1)
 . F PSOL=1:1:PSOPRC D
 . . S X=PRC(PSOL)
 . . S ^OR(100,VFDORD,4.5,XREC,2,(PSOL+OFF),0)=PRC(PSOL)
 . S X=OFF+PSOL
 . I X>0 D
 . . S ^OR(100,VFDORD,4.5,XREC,0)="14^385^1^SIG"
 . . S ^OR(100,VFDORD,4.5,XREC,2,0)="^^"_X_U_X_U_$P(DT,".",1)_U
 . . S:'$D(^OR(100,VFDORD,4.5,"ID","SIG")) ^OR(100,VFDORD,4.5,"ID","SIG",XREC)=""
 ; DSS/WLC End Mods
 ;
 ; ******************** End Order file updates ************************
 ;
 S VFDMSG="1"_U_PSOIEN_U_"PS"
 ; DSS/LM - Set ^XTMP(...) removed
EX Q:'$G(PSOPEN)  S DA=+PSOPEN,DIK="^PS(52.41," D ^DIK
 Q
PS55 ;; DSS/LM - Wrap call to PS55^PSON52
 ; to set PRESCRIPTION PROFILE entry in File 55
 Q:'$G(PSODFN)!'$G(PSOIEN)  N PSOX S PSOX("IRXN")=+PSOIEN
 N PSONEW S PSONEW("STOP DATE")=$P(^PSRX(PSOIEN,2),U,6)
 D PS55^PSON52
 Q
 ; DSS/WLC Begin Mods
FIND(X)  ; find record to update in ORDERS (#100) file subfile 4.5
 Q $S('$D(^OR(100,VFDORD,4.5,"ID",X)):$O(^OR(100,VFDORD,4.5,"A"),-1)+1,1:$O(^OR(100,VFDORD,4.5,"ID",X,0)))
 ; DSS/WLC End Mods
