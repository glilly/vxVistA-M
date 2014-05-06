VFDXX ;DSS/LM - Exception handler; 3/6/2008
 ;;2009.2;DSS,INC VXVISTA OPEN SOURCE;;01 Dec 2009
 ;Copyright 1995-2009,Document Storage Systems Inc. All Rights Reserved
 ;
 ;This application uses with permission modified code and concepts from:
 ;     Sea Island Systems ADT Filer.
 ;
 Q
XCPT(VXDT,APPL,DESC,HLID,SVER,DATA,VFDXVARS) ;;Record exception
 ;VXDT=[Optional] date.time of exception (FileMan internal format)
 ;APPL=[Optional] Application name
 ;DESC=[Optional] Short description
 ;HLID=[Optional] Associated HL7 message control ID
 ;SVER=[Optional] Severity code -
 ;                     1:FATAL
 ;                     2:WARNING
 ;                     3:INFORMATIONAL
 ;                     4:DEBUG ONLY
 ;                     5:VERBOSE DEBUG
 ;                     6:VERY VERBOSE
 ;                     9:OTHER
 ;DATA=[Optional] Summary data, up to 80 characters
 ;VFDXVARS=[Optional] Array (by reference) =or= $NAME(Array),
 ;     subscripted 1, 2, 3, ... where each value names a variable
 ;     to be saved.  Alternatively, ARRAY(1)="*" to save ALL.
 ;
 S VXDT=$G(VXDT,$$NOW^XLFDT) Q:'$L(VXDT)
 N VFDXFDA,VFDIENR,VFDIENS,R S R=$NA(VFDXFDA(21603,"+1,")),@R@(.01)=VXDT
 I $L($G(APPL)) S @R@(.02)=APPL
 ; If application is registered AND if severity is fatal (or not specified),
 ; then hard-set new exception to NOT reprocessed (T3)
 I $T,$D(^VFD(21603.1,"B",APPL)),'($G(SVER)>1) S @R@(.06)=2
 I $L($G(DESC)) S @R@(.03)=$TR(DESC,"^","~")
 I $L($G(HLID)) S @R@(.04)=HLID
 I $L($G(SVER)) S @R@(.05)=SVER
 I $G(DFN) S @R@(.07)=DFN ;(T2) From symbol table
 I $G(DUZ) S @R@(.08)=DUZ ;(T2) From symbol table
 I $L($G(DATA)) S @R@(1.01)=$TR(DATA,"^","~")
 I $G(HLMTIENS) S @R@(1.02)=HLMTIENS ;(T2) From symbol table
 I $G(HLSMGIEN) S @R@(1.03)=HLSMGIEN ;(T2) From symbol table
 D UPDATE^DIE(,$NA(VFDXFDA),$NA(VFDIENR))
 S VFDIENS=$G(VFDIENR(1))_"," Q:'VFDIENS
 ; File VFDXVARS [either an array (by reference) or the name of an array]
 N VFDWP I $D(VFDXVARS)>1 S VFDWP=$NA(VFDXVARS)
 E  I $L($G(VFDXVARS)) S VFDWP=$NA(@VFDXVARS)
 E  Q  ;No VARS
 ;
 N VFDADD,VFDI,VFDLEN,VFDTMP,VFDQ,VFDX,X,Y
 S VFDQ=0,VFDTMP=$NA(^TMP("VFDXXX",$J)),VFDADD=$NA(^TMP("VFDXXY",$J))
 K @VFDADD
 F VFDI=1:1 S VFDX=$G(@VFDWP@(VFDI)) Q:VFDQ!'$L(VFDX)  D
 .K @VFDTMP S X=VFDTMP,$E(X,$L(X))=","
 .I VFDX="*" S VFDQ=1 D DOLRO^%ZOSV,APPEND(VFDADD,VFDTMP) Q
 .S Y=VFDX D ORDER^%ZOSV,APPEND(VFDADD,VFDTMP)
 .Q
 ;
 D WP^DIE(21603,VFDIENS,10,,VFDADD)
 K @VFDTMP,@VFDADD
 Q
APPEND(Y,X) ;[Private] Append array X to Y
 ; Y $NAME, subscripted 1, 2, 3...
 ; X $NAME, any variable or subtree
 ; Assume parameters are well-formed
 ; 
 N VFDI,VFDL,VFDNAM,VFDORG
 S VFDI=$O(@Y@(" "),-1),VFDL=$L(X),VFDORG=$E(X,1,VFDL-1)
 F  S X=$Q(@X) Q:'($E(X,1,VFDL-1)=VFDORG)  D
 .S VFDNAM=$$VARNAME(X)
 .S VFDI=VFDI+1,@Y@(VFDI,0)=VFDNAM_"="_$$QUOTE(@X)
 .Q
 Q
VARNAME(X) ;[Private] Extracts variable name from subscripts of X
 ; X in form returned by ORDER^%ZOSV when target is ^TMP(NMSP,$J) -
 ; For example. ^TMP("VFDXXX",$J,"DUZ","AUTO") => DUZ("AUTO")
 ; Result reconstructs variable name (with subscripts)
 ;
 N VFDARY,VFDI,VFDL,VFDNAM S VFDL=$QL(X)
 F VFDI=1:1:VFDL S VFDARY(VFDI)=$QS(X,VFDI)
 S VFDNAM=$TR(VFDARY(3),"""") Q:VFDL=3 VFDNAM
 S VFDNAM=VFDNAM_"(" F VFDI=4:1:VFDL D
 .S VFDC=VFDARY(VFDI)=+VFDARY(VFDI)
 .S VFDNAM=VFDNAM_$S(VFDC:"",1:"""")_VFDARY(VFDI)_$S(VFDC:"",1:"""")_","
 .Q
 S $E(VFDNAM,$L(VFDNAM))=")" Q VFDNAM
 ;
QUOTE(X) ;[Private] Quotes X if and only if non-canonic
 ; Assume that X is defined, possibly null
 Q $S(X=+X:X,1:""""_X_"""")
 ;
PURGE(VFDKEEP) ;Purge exceptions [Based on ADT Filer PURGE^VFDAUTL]
 ; VFDKEEP=[Optional] Number of days to VFDKEEP [0 days requires explicit value]
 ;         Default=parameter value or '7' if parameter not valued.
 ;
 N X,Y,%DT
 S VFDKEEP=+$G(VFDKEEP,$$GET1^VFDCXPR(,"SYS~VFD DAYS TO KEEP EXCEPTIONS",1))
 S:VFDKEEP="" VFDKEEP=7 S X="T"_$S(VFDKEEP>0:"-"_VFDKEEP,1:"") D ^%DT Q:Y<0
 N DA,DIK,VFDDT,VFDX S VFDX="",DIK="^VFD(21603,",VFDDT=Y_".24"
 F  S VFDX=$O(^VFD(21603,"B",VFDX)) Q:VFDX=""!(VFDX>VFDDT)  D
 .S DA="" F  S DA=$O(^VFD(21603,"B",VFDX,DA)) Q:'DA  D ^DIK
 .Q
 Q
ASKPURGE ;User interface to PURGE(VFDKEEP)
 ;[Based on ADT Filer PURGE^VFDAUTL]
 N DIR,X,Y
 S DIR(0)="Y",DIR("A")="Purge exceptions - Are you sure",DIR("B")="YES"
 D ^DIR Q:$D(DIRUT)  Q:'(Y=1)
 S DIR(0)="N",DIR("A")="Days to keep",DIR("B")=1
 D ^DIR Q:$D(DIRUT)  S:Y<0 Y=0 D PURGE(Y)
 Q
ABBR ;Abbreviated exceptions listing
 ; Option VFD EXCEPTIONS ABBR LIST
 ; 
 N DIC,FLDS,FR,L,TO
 N DHD,DIASKHD,DIPCRIT,PG,DHIT,DIOEND,DIOBEG,DCOPIES,IOP,DOTIME,DIS,DISUPNO,DISTOP
 S BY=".02,20.1",DIC=21603,FLDS="[VFD ABBREVIATED EXCEPTIONS]",L=0
 D EN1^DIP
 Q
DETAIL ;Detailed exceptions listing
 ; Option VFD EXCEPTIONS DETAIL LIST
 ; 
 N DIC,FLDS,FR,L,TO
 N DHD,DIASKHD,DIPCRIT,PG,DHIT,DIOEND,DIOBEG,DCOPIES,IOP,DOTIME,DIS,DISUPNO,DISTOP
 S BY=".02,20.1",DIC=21603,FLDS="[CAPTIONED]",L=0
 D EN1^DIP
 Q
REPROC(VFDXIEN,VFDVALUE) ;[Private] Set REPROCESSED flag to 1=YES (default) or
 ; VFDXIEN=[Required] File 21603 IEN
 ; VFDVALUE=[Optional] 1 or 2 (YES or NO)
 ;
 I $G(VFDXIEN) S VFDVALUE=$G(VFDVALUE,1) I "^1^2^"[(U_VFDVALUE_U)
 E  Q  ;Exception IEN and valid value required
 N VFDFDA S VFDFDA(21603,+VFDXIEN_",",.06)=VFDVALUE
 D FILE^DIE(,$NA(VFDFDA))
 Q
