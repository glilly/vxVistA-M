VFDPSS ;DSS/LM - Utilities supporting vxVistA pharmacy data management
 ;;2009.2;DSS,INC VXVISTA OPEN SOURCE;;01 Dec 2009
 ;Copyright 1995-2009,Document Storage Systems Inc. All Rights Reserved
 ;
 Q
UPDSYN(RESULT,VFDNIEN,VFDFIEN) ;;Copy trade names of NDF to synonym
 ; multiple of File 50 or File 50.7 or File 101.43.
 ; 
 ; RESULT=RPC return [optional] by reference
 ; 
 ; VFDNIEN=File 50.68 IEN
 ; VFDFIEN=FILE NUMBER^ENTRY NUMBER, where
 ;   FILE NUMBER=50 or 50.7 or 101.43 and
 ;   ENTRY NUMBER=IEN in the given file
 ; 
 ; In each case the target of update is the SYNONYM[S] multiple.
 ; TRADE NAME values will be added to the multiple if they do
 ; not exist.  Duplicates will not be added.
 ;
 I '$G(VFDNIEN) S RESULT="-1^VA PRODUCT File 50.68 IEN required" Q
 N VFDCHK,X S VFDCHK=0 F X=50,50.7,101.43 I $P($G(VFDFIEN),U)=X S VFDCHK=1 Q
 I 'VFDCHK S RESULT="-1^Target File must be 50, 50.7 or 101.43" Q
 N VFDFIL,VFDIEN S VFDFIL=X,VFDIEN=$P($G(VFDFIEN),U,2)
 I 'VFDIEN S RESULT="-1^Target File IEN required" Q
 N VFDLEN,VFDSFIL
 S VFDLEN=$S(VFDFIL=50:40,VFDFIL=50.7:30,VFDFIL=101.43:63,1:255)
 S VFDSFIL=$S(VFDFIL=50:50.1,VFDFIL=50.7:50.72,VFDFIL=101.43:101.432,1:"")
 ;N VFDROOT D FIND^DIC(50.67,,"IX","QX",VFDNIEN,,"ANDC",,,$NA(VFDROOT))
 N VFDTNAM,VFDX
 S VFDX="" F  S VFDX=$O(^PSNDF(50.68,"ANDC",VFDNIEN,VFDX)) Q:'VFDX  D
 .S VFDTNAM=$$TRIM^XLFSTR($$GET1^DIQ(50.67,+VFDX,4))
 .S:VFDTNAM]"" VFDTNAM($E(VFDTNAM,1,VFDLEN))="",VFDTNAM=""
 .Q
 Q:'($D(VFDTNAM)>1)  D SELSYN($NA(VFDTNAM)) ;Cull list
 Q:'($D(VFDTNAM)>1)  N VFDFDA,VFDI,VFDR,VFDRR
 S VFDI=0,VFDR=$NA(VFDFDA(VFDSFIL))
 S VFDX="" F  S VFDX=$O(VFDTNAM(VFDX)) Q:'$L(VFDX)  D
 .Q:VFDFIL=50&$D(^PSDRUG("C",$E(VFDX,1,40)))  ;File 50 SYNONYM has no "B" x-ref
 .S VFDI=1+VFDI,VFDRR=$NA(@VFDR@("?+"_VFDI_","_VFDIEN_","))
 .S @VFDRR@(.01)=VFDX
 .S:VFDFIL=50 @VFDRR@(1)=0 ;INTENDED USE=0:TRADE NAME
 .Q
 D:$D(VFDFDA) UPDATE^DIE(,$NA(VFDFDA))
 Q
SELSYN(VFDLIST) ;;Select synonyms from list
 ; VFDLIST=$NAME of list, subscripted by synonyms
 ; Return selected synonyms in same list
 ; 
 N VFDI,VFDCNT,VFDR,VFDX S (VFDI,VFDCNT,VFDX)="",VFDR=$NA(^TMP("VFDPSS",$J))
 K @VFDR F VFDI=1:1 S VFDX=$O(@VFDLIST@(VFDX)) Q:'$L(VFDX)  D
 .S @VFDR@(VFDI)=VFDX,VFDCNT=VFDI ;Create numbered list in ^TMP
 .Q
 N DIR,VFDKEEP,VFDLINES,VFDSTRT,X,Y S DIR("A")="Use as SYNONYM"
 S VFDLINES=20 ;Display/select in blocks of VFDLINES
 N VFDB,VFDSCNT S VFDSCNT=0 F VFDB=0:1:VFDCNT\VFDLINES D  Q:$D(DTOUT)!$D(DUOUT)
 .S VFDSTRT=VFDB*VFDLINES+1
 .F VFDI=VFDSTRT:1:VFDB+1*VFDLINES Q:'$D(@VFDR@(VFDI))  D
 ..W !,$J(VFDI,$L(VFDCNT)),?5,@VFDR@(VFDI) S VFDSCNT=VFDI
 ..Q
 .S DIR(0)="LO^"_VFDSTRT_":"_VFDSCNT_":0" ;,DIR("B")=VFDSTRT_"-"_VFDSCNT
 .W ! D ^DIR Q:$D(DIRUT)  S VFDKEEP(VFDB)=$E(Y,1,$L(Y)-1)
 .Q
 I $D(DTOUT)!$D(DUOUT) K @VFDR Q  ;Abort on timeout or up-arrow
 ; Mark values to keep
 S VFDB="" F  S VFDB=$O(VFDKEEP(VFDB)) Q:VFDB=""  D
 .X "F VFDI="_VFDKEEP(VFDB)_" S $P(@VFDR@(VFDI),U,2)=1"
 .Q
 F VFDI=1:1 Q:'$D(@VFDR@(VFDI))  D  ;Remove unselected elements
 .Q:$P(@VFDR@(VFDI),U,2)  ;Keep
 .K @VFDLIST@(@VFDR@(VFDI))
 .Q
 K @VFDR
 Q
CPYSYN(RESULT,VFDIEN,VFDFIEN) ;;Copy SYNONYM(s) of local DRUG to synonym
 ; multiple of File 50.7 or File 101.43.
 ; 
 ; RESULT=RPC return [optional] by reference
 ; 
 ; VFDIEN=File 50 IEN
 ; VFDFIEN=FILE NUMBER^ENTRY NUMBER, where
 ;   FILE NUMBER=50.7 or 101.43 and
 ;   ENTRY NUMBER=IEN in the given file
 ; 
 ; In each case the target of update is the SYNONYM[S] multiple.
 ; DRUG synonym values will be added to the multiple if they do
 ; not exist.  Duplicates will not be added.
 ;
 I '$G(VFDIEN) S RESULT="-1^DRUG File 50 IEN required" Q
 N VFDCHK,X S VFDCHK=0 F X=50.7,101.43 I $P($G(VFDFIEN),U)=X S VFDCHK=1 Q
 I 'VFDCHK S RESULT="-1^Target File must be 50.7 or 101.43" Q
 N VFDFIL,VFDTIEN S VFDFIL=X,VFDTIEN=$P($G(VFDFIEN),U,2)
 I 'VFDTIEN S RESULT="-1^Target File IEN required" Q
 N VFDGETS D GETS^DIQ(50,+VFDIEN,"9*",,"VFDGETS")
 I '($D(VFDGETS)>1) S RESULT="-1^No synonyms found for DRUG IEN="_VFDIEN Q
 N VFDLEN,VFDSFIL ;Synonym length and target subfile number
 S VFDLEN=$S(VFDFIL=50.7:30,VFDFIL=101.43:63,1:255)
 S VFDSFIL=$S(VFDFIL=50.7:50.72,VFDFIL=101.43:101.432,1:"")
 N VFDTNAM,VFDX ;Synonym name list and source IENS subscript
 S VFDX="" F  S VFDX=$O(VFDGETS(50.1,VFDX)) Q:'VFDX  D
 .S VFDTNAM=$$TRIM^XLFSTR($G(VFDGETS(50.1,VFDX,.01)))
 .S:VFDTNAM]"" VFDTNAM($E(VFDTNAM,1,VFDLEN))="",VFDTNAM=""
 .Q
 Q:'($D(VFDTNAM)>1)  N VFDFDA,VFDI,VFDR,VFDRR
 S VFDI=0,VFDR=$NA(VFDFDA(VFDSFIL))
 S VFDX="" F  S VFDX=$O(VFDTNAM(VFDX)) Q:'$L(VFDX)  D
 .S VFDI=1+VFDI,VFDRR=$NA(@VFDR@("?+"_VFDI_","_VFDTIEN_","))
 .S @VFDRR@(.01)=VFDX
 .Q
 D:$D(VFDFDA) UPDATE^DIE(,$NA(VFDFDA))
 Q
ASKND ;;Adaptor for ASKND^PSSDEE from [PSSCOMMON] input template
 ;
 Q  ;Disable pending study
 N DIE,DG,FLGMTH
 S FLGMTH=0 D ASKND^PSSDEE
 Q
VAPPN ;;Obtain VA Product Print Name before editing DRUG
 ; Save as variable VFDPPN.  Also save VA PRODUCT IEN as VFDNDA.
 ; These are application-wide variables, not NEWed or KILLed
 ; in this code.
 ;
 D:'$G(VFDNDA)  ;Usual context - VA PRODUCT IEN not defined
 .N DIC,X,Y S DIC=50.68,DIC(0)="AEQM" D ^DIC
 .S:Y>0 VFDNDA=+Y
 .Q
 Q:'$G(VFDNDA)  S VFDPPN=$$GET1^DIQ(50.68,VFDNDA,5)
 Q
FILEVAPP(VFDA,VFDNDA) ;;File VA PRODUCT pointer (File 50, field 22)
 ; VFDA=File 50 IEN
 ; VFDNDA=File 50.68 IEN
 ; 
 I $G(VFDA),$G(VFDNDA) N VFDFDA S VFDFDA(50,VFDA_",",22)=VFDNDA
 E  Q
 D UPDATE^DIE(,"VFDFDA")
 Q
FILEVAGN(VFDA,VFDNDA) ;;File VA GENERIC pointer (File 50, field 20)
 ; VFDA=File 50 IEN
 ; VFDNDA=File 50.68 IEN
 ; 
 I $G(VFDA),$G(VFDNDA) N VFDGIEN D  I VFDGIEN
 .S VFDGIEN=$$GET1^DIQ(50.68,VFDNDA,.05,"I")
 .Q
 E  Q
 N VFDFDA S VFDFDA(50,VFDA_",",20)=VFDGIEN
 D UPDATE^DIE(,"VFDFDA")
 Q
FILEVA(VFDA,VFDNDA) ;;File both VA PRODUCT and VA GENERIC fields
 ; VFDA=File 50 IEN
 ; VFDNDA=File 50.68 IEN
 ; 
 D FILEVAPP(.VFDA,.VFDNDA),FILEVAGN(.VFDA,.VFDNDA)
 Q
POSTPOI ;;Post synonyms to Pharmacy Orderable Item on return from -
 ; COMMON^PSSDEE => COMMON1^PSSDEE => ORDITM^PSSDEE1
 ; 
 ; VFDA=File 50 IEN
 ; 
 I $G(VFDA) N VFDPOI S VFDPOI=$P($G(^PSDRUG(VFDA,2)),U) I VFDPOI
 E  Q
 N DIR,X,Y S DIR(0)="Y",DIR("A")="Copy DRUG synonyms to PHARMACY ORDERABLE ITEM",DIR("B")="YES"
 D ^DIR Q:$D(DIRUT)  D:Y CPYSYN(,VFDA,"50.7^"_VFDPOI)
 Q
KILL ;;Cleanup variables that are not NEW'ed
 ;
 K VFDA,VFDNDA
 Q
