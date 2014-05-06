VFDDUZ1 ;DSS/LM - Utilities supporting NEW PERSON LOOKUP ; 1/7/09 2:49pm
 ;;2009.2;DSS,INC VXVISTA OPEN SOURCE;;01 Dec 2009
 ;Copyright 1995-2009,Document Storage Systems Inc. All Rights Reserved
 ;
 Q
FIND1(VFDVAL,VFDTYP,VFDLOC) ;[Private] - Continuation of $$FIND1^VFDUZ(...)
 ;
 ; See routine ^VFDUZ for parameter definitions
 ;
 I $L($G(VFDVAL)) S VFDTYP=$G(VFDTYP),VFDLOC=$G(VFDLOC)
 E  Q ""
 N VFDA,VFDB,VFDL,VFDSCR,VFDY S VFDSCR="",VFDY=0
 I $L(VFDTYP) S VFDSCR="I $P($G(^VA(200,VFDA,21600,VFDB,0)),U,5)=VFDTYP"
 S VFDL="" F  S VFDL=$O(^VA(200,"AVFD",VFDL)) Q:'VFDL!(VFDY>1)  I VFDL=VFDLOC!'$L(VFDLOC) D
 .S VFDA="" F  S VFDA=$O(^VA(200,"AVFD",VFDL,VFDVAL,VFDA)) Q:'VFDA!(VFDY>1)  D
 ..S VFDB="" F  S VFDB=$O(^VA(200,"AVFD",VFDL,VFDVAL,VFDA,VFDB)) Q:'VFDB!(VFDY>1)  D
 ...I '$L(VFDSCR) S VFDY=VFDY+1,VFDY(VFDY)=VFDA Q
 ...X VFDSCR I  S VFDY=VFDY+1,VFDY(VFDY)=VFDA
 ...Q
 ..Q
 .Q
 Q $S(VFDY=1:VFDY(1),1:"")
 ;
ID(VFDRSLT,VFDDUZ) ;[Private] - Continuation of ID^VFDDUZ
 ; Implements remote procedure VFD USER ID
 ; 
 ; See ID^VFDDUZ for calling and return details
 ; 
 I '($G(VFDDUZ)>0) S @VFDRSLT@(1)="-1^Missing or invalid NEW PERSON IEN" Q
 E  N DSIC D ID^VFDCDUZ(.DSIC,VFDDUZ,"DN")
 N VFDI,VFDJ,VFDNPI,VFDATYP,VFDQ,VFDR,VFDX,VFDZ S (VFDJ,VFDNPI)=0
 S VFDATYP=$$GET^XPAR("SYS","VFDP RX ALTERNATE ID TYPES")
 F VFDI=1:1:$L(VFDATYP,";") S VFDX=$P(VFDATYP,";",VFDI) S:$L(VFDX) VFDATYP(VFDX)=""
 F VFDI=1:1 Q:'$D(DSIC(VFDI))  D
 .I $P(DSIC(VFDI),U)?1"DEA".E S VFDJ=VFDJ+1,VFDRSLT(VFDJ)=DSIC(VFDI)
 .I $P(DSIC(VFDI),U)?1"NPI".E S VFDJ=VFDJ+1,VFDRSLT(VFDJ)=DSIC(VFDI),VFDNPI=1
 .Q
 ; Augment return with ALTERNATE ID values for DPS and possibly NPI.
 N VFDATA D GETS^DIQ(200,+VFDDUZ,"21600*","IEN",$NA(VFDATA))
 S VFDI="" F  S VFDI=$O(VFDATA(200.0216,VFDI)) Q:'VFDI  D
 .S VFDR=$NA(VFDATA(200.0216,VFDI))
 .I $G(@VFDR@(.03,"I")),@VFDR@(.03,"I")<$G(DT,$$DT^XLFDT) Q  ;Expired ID
 .; DSS/LM Add LICENSE-type alternate IDs
 .S VFDX=$G(@VFDR@(.07,"I")) I VFDX D  Q  ;Has LICENSE TYPE
 ..S VFDZ=$G(^VFD(21613.1,VFDX,0)) Q:'$G(^(1))  ;Screen if not RX PRINT
 ..S VFDX=$P(VFDZ,U,2) S:'$L(VFDX) VFDX=$P(VFDZ,U) ;Abbreviation or name
 ..S VFDJ=VFDJ+1,VFDRSLT(VFDJ)="LIC^"_@VFDR@(.02,"E")_U_VFDX_U_$G(@VFDR@(.03,"E"))
 ..Q
 .; DSS/LM End insert
 .; DSS/LM Add parameterized ID types 1/6/2009
 .I $D(VFDATYP)>1 D  Q:VFDQ
 ..S VFDX=$P($G(@VFDR@(.05,"E"))," ") Q:VFDX=""
 ..S VFDQ=0 Q:'$D(VFDATYP(VFDX))  ;Only parameterized types here
 ..I VFDX="NPI" Q:VFDNPI  ;Use field #41.99 NPI if valued
 ..I $D(VFDATYP(VFDX)) S VFDJ=VFDJ+1,VFDRSLT(VFDJ)=VFDX_U_@VFDR@(.02,"E")
 ..I  S VFDRSLT(VFDJ)=VFDRSLT(VFDJ)_U_$G(@VFDR@(.01,"E"))_U_$G(@VFDR@(.04,"E"))
 ..S VFDQ=1
 ..Q
 .; DSS/LM End insert
 .I $G(@VFDR@(.05,"E"))?1"DPS".E S VFDJ=VFDJ+1,VFDRSLT(VFDJ)="DPS^"_@VFDR@(.02,"E")
 .I  S VFDRSLT(VFDJ)=VFDRSLT(VFDJ)_U_$G(@VFDR@(.01,"E"))_U_$G(@VFDR@(.04,"E"))
 .Q:VFDNPI  ;Use field #41.99 NPI if valued
 .I $G(@VFDR@(.05,"E"))?1"NPI".E S VFDJ=VFDJ+1,VFDRSLT(VFDJ)="NPI^"_@VFDR@(.02,"E")
 .I  S VFDRSLT(VFDJ)=VFDRSLT(VFDJ)_U_$G(@VFDR@(.01,"E"))_U_$G(@VFDR@(.04,"E"))
 .Q
 ;
 Q
