VFDORP ;DSS/LM - RPC wrapper orders print data ;23 Nov 2010 10:04
 ;;2011.1.2;DSS,INC VXVISTA OPEN SOURCE;;28 Jan 2013;Build 153
 ;Copyright 1995-2013,Document Storage Systems Inc. All Rights Reserved
 ;
 ;         Support for multiple package references
 ;         Other modifications as noted
 ;
DATA(VFDRSLT,VFDORLST,VFDCMT,VFDPKG,VFDPRINT,VFDLREF) ;RPC: VFD ORDER PRINT DATA
 ; Replaces RPC: VFD PS LABELS BY ORDER LIST
 ; 
 ; VFDRSLT=[name of] Global Array containing print data.
 ; VFDORLST=Array of order numbers to process
 ;          VFDORLST[1]=[Placer] order IEN
 ;          VFDORLST[2]=[Placer] order IEN
 ;          Etc.
 ; VFDCMT=[Optional] Comment indicating reason for reprinting
 ; VFDPKG=[Optional] ';'-delimited string listing package(s) to include
 ; VFDPRINT=[Optional] Print mode: Added 11/24/09.  Redefined 3/17/2010 as follows:
 ;          ^-piece 1 = 1=reserved for VFDLR... internal call, 2=reprint, 3=print
 ;          ^-piece 2 = 1=print override.  The value 1 has the following effects:
 ;                      a) Do not make associated orders check.
 ;                      b) Create order group.
 ;                      c) Add order numbers to ORM queue.
 ;                      d) Pass print data to caller for associated orders.
 ;           If the VFDPRINT parameter is not defined, the default action
 ;           is the same as passing the value 3=print.
 ; VFDLREF=[Optional] IEN pointer to reference lab - Added 11/24/09 for LAB
 ;
 N VFDLOC,VFDGLB ;Lab uses local array return. Pharm uses global.
 N VFDLR,VFDPSO,VFDFTRX S (VFDLR,VFDPSO,VFDFTRX)=0 ;Process respective package orders iff TRUE
 ; T7 - Default PACKAGE -
 I '$L($G(VFDPKG)) S VFDPKG=$$GET^XPAR("ALL","VFD ORDERS PRINT PACKAGES")
 I $L(VFDPKG) S VFDPKG=";"_VFDPKG_";" D
 .S:VFDPKG[";LR;"&($T(LAB^VFDLRLST)]"") VFDLR=1 ;T10
 .S:VFDPKG[";PSO;" VFDPSO=1
 .S:VFDPKG[";VFDFTRX;"&($T(ONE^VFDORP1)]"") VFDFTRX=1
 .Q
 ;10/23/2008 - If no PKG specified, default to NONE
 ;
 S VFDRSLT=$NA(^TMP("VFDORP",$J)) K @VFDRSLT
 N VFDSORT D SORT(.VFDSORT,.VFDORLST) ;7/16/2007 - Sort orders by package prefix
 N VFDLRSLT,VFDPRSLT,VFDORPKG
 D:VFDLR  ;LR - Laboratory
 .K VFDORPKG M VFDORPKG=VFDSORT("LR") Q:'$D(VFDORPKG)
 .D LAB^VFDLRLST(.VFDLRSLT,.VFDORPKG,.VFDPRINT,.VFDLREF)
 .D APPEND(VFDRSLT,$NA(VFDLRSLT))
 .Q
 K VFDLRSLT
 D:VFDPSO  ;PSO - Outpatient pharmacy
 .K VFDORPKG M VFDORPKG=VFDSORT("PSO") Q:'$D(VFDORPKG)
 .D LBLS^VFDPOAF1(.VFDPRSLT,.VFDORPKG,.VFDCMT)
 .D APPEND(VFDRSLT,VFDPRSLT)
 .Q
 N VFDI,VFDVRSLT ;Free Text Prescriptions
 D:VFDFTRX  ;vxVistA - Free Text Prescription
 .F VFDI=1:1 Q:'$D(VFDORLST(VFDI))  D  ;Select from ALL orders
 ..D ONE^VFDORP1($NA(VFDVRSLT),+$G(VFDORLST(VFDI)))
 ..D APPEND(VFDRSLT,$NA(VFDVRSLT)) K VFDVRSLT
 .Q
 ;
 I '$D(@(VFDRSLT)) S @VFDRSLT@(1)="-1^No data found"
 Q:@VFDRSLT@(1)<0  I $D(VFDPRSLT) K @VFDPRSLT
 D FORMAT(VFDRSLT)
 Q
APPEND(VFDTO,VFDFM) ;[Private] Append data
 ; VFDTO=Target array root $NAME
 ; VFDFM=Source array root $NAME
 ;
 N VFDI,VFDLST S VFDLST=$O(@VFDTO@(" "),-1)
 I $D(@VFDFM@(0)) S @VFDTO@(1+VFDLST)=@VFDFM@(0) Q  ;Error return
 F VFDI=1:1 Q:'$D(@VFDFM@(VFDI))  S @VFDTO@(VFDI+VFDLST)=@VFDFM@(VFDI)
 Q
SORT(VFDOUT,VFDIN) ;[Private] Sort orders by package prefix
 ;VFDOUT=[By reference] output array
 ;VFDIN=[By reference] input array
 ;
 N VFDI,VFDJ,VFDOIEN,VFDNMSP
 F VFDI=1:1 Q:'$D(VFDIN(VFDI))  D
 .S VFDOIEN=+VFDIN(VFDI) Q:'VFDOIEN
 .S VFDNMSP=$$GET1^DIQ(100,VFDOIEN,"12:1") S:'$L(VFDNMSP) VFDNMSP="UNK"
 .S VFDJ(VFDNMSP)=1+$G(VFDJ(VFDNMSP)),VFDOUT(VFDNMSP,VFDJ(VFDNMSP))=VFDOIEN
 .Q
 Q
FORMAT(VFDPRSLT) ;[Private] Format results array, placing package-specific
 ; error messages in separate block at end.
 ; 
 ; VFDPRSLT=$NAME of results (input and output)
 ;
 I $L($G(VFDPRSLT)) N VFDI,VFDJ,VFDTMP,VFDX
 E  Q  ;Invalid or missing results array name
 S VFDTMP=$NA(^TMP("VFDORPTMP",$J)) K @VFDTMP
 F VFDI=1:1 Q:'$D(@VFDPRSLT@(VFDI))  D
 .S VFDX=@VFDPRSLT@(VFDI)
 .I VFDX?1"-1".E S VFDJ("ER")=1+$G(VFDJ("ER")),@VFDTMP@("ER",VFDJ("ER"))=VFDX Q
 .S VFDJ("OK")=1+$G(VFDJ("OK")),@VFDTMP@("OK",VFDJ("OK"))=VFDX
 .Q
 I '$D(@VFDTMP@("ER")) K @VFDTMP Q  ;No errors - Return unchanged
 K @VFDPRSLT M @VFDPRSLT=@VFDTMP@("OK") ;Good results, if any
 S VFDI=1+$O(@VFDPRSLT@(" "),-1),@VFDPRSLT@(VFDI)="$START ERRORS"
 F VFDJ=1:1 Q:'$D(@VFDTMP@("ER",VFDJ))  S @VFDPRSLT@(VFDI+VFDJ)=@VFDTMP@("ER",VFDJ)
 S @VFDPRSLT@(VFDI+VFDJ)="$END ERRORS" K @VFDTMP
 Q
