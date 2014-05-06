VFDPSORR ;DSS/WLC - VXVISTA RX COMPLETE/RENEWALS ; 4/5/2013 18:40
 ;;2011.1.2;DSS,INC VXVISTA OPEN SOURCE;;11 Jun 2013
 ;Copyright 1995-2013,Document Storage Systems Inc. All Rights Reserved
 ; This routine is only invoked from VFDPSOR
 ; Pharmacy Renewals
 ;
 Q
 ;
 ; INPUT:
 ;   VFDORD = New Order Number (File #100 IEN)
 ;
EN ; Mark old Rx as Discontinued, generate new Rx Number for Renewal
 N PSOGEN,PSONNUM,PSOX,VFDORG
 I '+$G(VFDORD) Q
 I '$D(^OR(100,VFDORD)) Q
 ; Retrieve original Prescription number (PSONNUM)
 S VFDORG=$$GET1^DIQ(100,VFDORD_",",9)  ; get Original Order #
 Q:'VFDORG  ;  not a renew order
 I '$D(^OR(100,+VFDORG)) Q  ; No IEN defined - nothing left to do
 S $P(^OR(100,VFDORG,3),U,3)=1  ; discontinue original order
 S PSOORG=$G(^OR(100,VFDORG,4))
 I 'PSOORG!(PSOORG'=+PSOORG)!($G(^PSRX(+PSOORG,0))="") K PSOORG S VFDMSG="Unable to RENEW from original order" Q
 S PSONNUM=$P(^PSRX(PSOORG,0),U,1)
EN1 ;
 S PSOX=$E(PSONNUM,$L(PSONNUM))
 ; save off new RX # to override auto-generate
 S PSOGEN=$S(PSOX?1N:PSONNUM_"A",1:PSONNUM_$C($A(PSOX)+1)),PSONRXN=PSOGEN
 ; check to see if already entered, need new suffix
 I $D(^PSRX("B",PSOGEN)) S PSONNUM=PSOGEN G EN1
 ;
 ; Begin Update entries to old prescription
 ;
 L +^PSRX(PSOORG):3 Q:'$T
 S ^PSRX(PSOORG,"STA")=12  ; Discontinued Status
 N I,CNT,NOW S NOW=$$NOW^XLFDT
 ; Cancel date and Last Dispensed Date Holder
 F I=5,10 S $P(^PSRX(PSOORG,3),U,I)=NOW
 ; update Activity Log
 S CNT=$P($G(^PSRX(PSOORG,"A",0)),U,3)+1,NOW=$$NOW^XLFDT
 S ^PSRX(PSOORG,"A",CNT,0)=NOW_U_"L"_U_+DUZ_U_"0"_U_"Renewed from CPRS"
 L -^PSRX(PSOORG)
 Q
