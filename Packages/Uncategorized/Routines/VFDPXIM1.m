VFDPXIM1 ;DSS/WLC - MAIN ENTRY TO VFDPXIM ROUTINES ; 08 Nov 2013  9:28 AM
 ;;2011.1.2;DSS,INC VXVISTA OPEN SOURCE;**11**;11 Jun 2013;Build 2
 ;Copyright 1995-2013,Document Storage Systems Inc. All Rights Reserved
 ;
 ;All Integration Agreements for VFDPXIM*
 ;DBIA#  Supported Reference
 ;-----  ----------------------------------------------------
 ;APP    AGET^ORWORR
 ;2056   GET1^DIQ,GETS^DIQ
 ;10103  NOW^XLFDT
 ;1889   $$DATA2PCE^PXAPI
 ;1894   ENCEVENT^PXKENC
 ;       $$FIND1^DIC
 ;       FILE^DIE
 ;
GETIMM(VFDIM)  ;  RPC:  VFD PXIM GET ORDERABLE
 N CNT,I,ITEM,J,K,X,Y,Z
 S (CNT,X)=0 F  S X=$O(^PSDRUG("AOC",X)) Q:'X  D
 .S Y="" F  S Y=$O(^PSDRUG("AOC",X,Y)) Q:Y=""  D
 ..I Y'="IM100",Y'="IM105",Y'="IM109" Q  ; Immunizations only
 ..S Z=0 F  S Z=$O(^PSDRUG("AOC",X,Y,Z)) Q:'Z  D
 ...Q:$D(^PSDRUG(Z,"I"))  ; Inactive item
 ...S I=+$G(^PSDRUG(Z,2)) Q:'I
 ...S ITEM=$O(^ORD(101.43,"ID",I_";99PSP",0)) Q:+$G(^ORD(101.43,ITEM,.1)) 
 ...S VFDIM(CNT)=ITEM_U_$P(^ORD(101.43,ITEM,0),U,1) S CNT=CNT+1
 ..S VFDIM(0)=CNT-1
 Q
 ;
GETORD(VFDIM,DFN)  ;  RPC:  VFD PXIM GET IMM ORDERS
 ; RPC to retrieve active Immunization orders for patient
 ; INPUT:
 ;    DFN = Pointer to PATIENT (#2) file.
 ; OUTPUT:
 ;   VFDIM(n) where:
 ;    VFDIM(0)=Total number of active Immunization orders
 ;    VFDIM(n)=Order # ^ Orderable Item description
 ;
 N ACT,ARR,CNT,MAX,OR,ORN,PDRG,VFDIM1,TYP,X,Y,Z
 S DFN=$G(DFN) K VFDIM I '$D(^DPT(DFN)) S VFDIM(0)="-1^Invalid DFN sent" Q
 D AGET^ORWORR(.VFDIM1,DFN,1)  ; get list of all orders
 S CNT=1
 S X="" F  S X=$O(^TMP("ORR",$J,X)) Q:X=""  S MAX=$P(^TMP("ORR",$J,X,.1),U,1) D
 .F Y=1:1:MAX S ORN=+^TMP("ORR",$J,X,Y) D
 ..;Not ACTIVE or WRITTEN status
 ..N X,Y
 ..S ACT=$$GET1^DIQ(100,ORN,5,"I") Q:"^6^100^"'[(U_ACT_U)
 ..F Z=1:1 Q:'$D(^OR(100,ORN,4.5,Z))  D
 ...I $P(^OR(100,ORN,4.5,Z,0),U,4)="ORDERABLE" S OR=+^OR(100,ORN,4.5,Z,1) D:OR
 ....S TYP="",PDRG=+$$GET1^DIQ(101.43,OR_",",2),TYP=$O(^PSDRUG("AOC",PDRG,TYP))
 ....I TYP'="IM100",TYP'="IM105",TYP'="IM109" Q  ; not immunization
 ....D GETS^DIQ(100,ORN_",","**",,"ARR")
 ....S VFDIM(CNT)=ORN_U_ARR(100.001,"1,"_ORN_",",.01),CNT=CNT+1
 .S VFDIM(0)=CNT-1
 Q
 ;
GETLOTS(VFDIM,ORN)  ; RPC:  VFD PXIM GET LOTS
 ; RPC to return associated lOT #'S FOR Vaccines
 ; Each lot number indicates a separate quantity of vaccine.
 ; These could be by Vial, ml, mcl, etc.
 ; INPUT:
 ;    ORN = Internal CPRS Order number
 ; OUTPUT:
 ;    LIST(n) where:
 ;    LIST(0) = Count of Active Lots
 ;    LIST(n) = IEN # ^ LOT NUMBER ^ MANUFACTURER ^ PRODUCT NAME ^
 ;               CVX CODE ^ MVX CODE ^ START DATE ^ EXPIRATION DATE ^
 ;               OVERRIDE EXPIRATION DATE ^ OUT OF STOCK? ^ QUANTITY ^
 ;               UNIT ^ IMMUNIZATION
 ;
 N I,J,X,Y,CNT,ERR,ID,LOTAR,ORBLE,PHID,VFDIEN
 S ORN=$G(ORN),VFDIM(0)=0 I 'ORN S VFDIM(0)="-1^Invalid Order number sent." Q
 I '$D(^OR(100,ORN)) S VFDIM(0)="-1^Order NOT on file." Q
 S CNT=1 F I=1:1 Q:'$D(^OR(100,ORN,.1,I))  S X=+^OR(100,ORN,.1,I,0) D
 . S PHID=+$P(^ORD(101.43,X,0),U,2)
 . S ID="",ID=$O(^PSDRUG("AOC",PHID,ID)) Q:$E(ID,1,2)'="IM"
 . S ORBLE(X)=""
 S X=0 F  S X=$O(ORBLE(X)) Q:'X  D
 . S Y=0 F  S Y=$O(^VFD(21630.01,"B",X,Y)) Q:'Y  D
 . . S VFDIEN=Y_"," N X,Y
 . . D GETS^DIQ(21630.01,VFDIEN,"*","IE","LOTAR","ERR")
 . . N FLE S FLE=$NA(LOTAR(21630.01,VFDIEN))
 . . Q:$G(@FLE@(2.3,"I")) ; Out of Stock
 . . Q:$G(@FLE@(2,"I"))>DT ; Not active yet
 . . I $G(@FLE@(2.1,"I"))<DT,'$G(@FLE@(2.2,"I")) Q  ; past expiration and no override
 . . S VFDIM(CNT)=(+VFDIEN)_U
 . . F I=.02,.03,.04,1,1.1,2,2.1,2.2,2.3,3,3.1,4 S VFDIM(CNT)=VFDIM(CNT)_@FLE@(I,"E")_U
 . . S CNT=CNT+1
 S VFDIM(0)=(CNT-1)
 Q
 ;
STORLOT(VFDIM,VFDRAY)  ; RPC:  VFD PXIM STORE LOT
 ; This RPC will set a drug order as administered by setting the STOP or
 ; EXPIRATION DATE to NOW.  This will in effect expire the order when
 ; Outpatient or Inpatient Pharmacy normally does so.
 ;  INPUT:
 ;    ARRAY is a LIST Variable of values and pointers to store, where
 ;    ARRAY(0)= "A" for Add, "E" for Edit ^ IEN to edit (blank for ADD)
 ;    ARRAY(1-n)=Field # ^ VALUE  (i.e.  ARRAY(1) = ".02^32-A-456" to 
 ;               store lot #32-A-456
 ;  OUTPUT:
 ;    VFDIM=-1^Error Text
 ;    or
 ;    VFDIM=1^Success
 ;
 N ADDED,I,IEN,J,FDA,ERR
 S VFDRAY=$G(VFDRAY) I '$O(VFDRAY(0)) S VFDIM="-1^No data sent." Q
 S ADDED=$S(VFDRAY(0)="A":1,1:0),IEN=$P(VFDRAY(0),U,2)
 S I=0 F  S I=$O(VFDRAY(I)) Q:'I  D
 .S J=VFDRAY(I),FDA(21630.01,$S(ADDED="A":"+1,",1:IEN_","),$P(J,U,1))=$P(J,U,2)
 D UPDATE^DIE(,"FDA",,"ERR")
 I $D(ERR) S VFDIM="-1^"_$G(ERR("DIERR",1,"TEXT",1))
 E  S VFDIM="1^Success"
 Q
