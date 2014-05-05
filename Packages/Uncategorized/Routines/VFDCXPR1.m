VFDCXPR1 ;DSS/SGM - RPCs/APIs FOR PARAMETERS ; 1/30/2013 14:00
 ;;2011.1.3;DSS,INC VXVISTA OPEN SOURCE;**16**;11 Jun 2013;Build 1
 ;Copyright 1995-2013,Document Storage Systems Inc. All Rights Reserved
 ;
 ;this routine is not directly invokable
 ;see corresponding line labels in ^VFDCXPR
 ;^VFDCXPR also documents the input parameters for each call
 ;EXCEPTIONS: subroutine line tags ENT, MULT, NM may be called  
 ;
 ; DBIA#  Supported - Description
 ; -----  --------------------------------------------------
 ;  2051  $$FIND1^DIC
 ;  2052  $$GET1^DID
 ;  2056  $$GET1^DIQ
 ;  2263  ^XPAR: ADD,CHG,DEL,NDEL,GET,GETLST,GETWP,ENVAL,REP
 ;  2336  BLDLST^XPAREDIT
 ;  2263  ADDWP^XPAR
 ;  3127  FM read of all fields in file 8989.51 [control sub IA]
 ;
 ; Following modules have .VFDRET as the return array
 ;   ADD, CHG, CHGWP, DEL, GET, GET1, GETALL, GETWP, REPL
 ; Use of FUN input parameter deprecated in favor of $QUIT 1/30/2013
 ;   ADD, CHG, DEL, GET1, REPL
 Q
 ;
OUT ;  common exit - if '$D(VFDRET) then expects VFDERR to be defined
 N X I '$D(VFDRET) D
 . S X=$G(VFDERR,"Unexpected problem encountered")
 . S:X[U X=$P(X,U,2) S VFDRET=$S(X=0:1,1:"-1^"_X)
 . Q
 Q:$Q VFDRET
 Q
 ;       ;
ADD ;  add a new entity/parameter/instance
 ;  INSTANCE is optional even for multiple
 N I,X,Y,Z,ARR,VFDERR
 D COMMON(1) I $D(VFDERR) G OUT
 I ARR(4)="@" S VFDERR="Deletion is not allowed in the ADD RPC" G OUT
 ;  in multiple instance, instance="", then get next numeric value
 I ARR(3)="",$$MULT(X) D  G:$D(VFDERR) OUT
 .N TMP D GET(.TMP,$P(DATA,"~",1,2))
 .I +TMP(1)=-1 S VFDERR=TMP(1) Q
 .S X=0 F I=1:1 Q:'$D(TMP(I))  S:+TMP(I)>X X=+TMP(I)
 .S ARR(3)=X+1
 .Q
 D ADD^XPAR(ARR(1),ARR(2),ARR(3),ARR(4),.VFDERR)
 G OUT
 ;
CHG ;  edit a Value for existing parameter/entity/instance
 ; INSTANCE is optional
 ; DBIA #2263 - CHG^XPAR
 N X,Y,Z,ARR,VFDERR
 D COMMON(1) I $D(VFDERR) G OUT
 I ARR(3)="" D CHG^XPAR(ARR(1),ARR(2),,ARR(4),.VFDERR)
 I ARR(3)'="" D CHG^XPAR(ARR(1),ARR(2),ARR(3),ARR(4),.VFDERR)
 G OUT
 ;
CHGWP ;
 ;Change a word-processing type parameter value
 ; DBIA #2263 - CHG^XPAR
 N ENT,PAR,ERR,INST,WPA
 S ERR="" K VFDRET
 I DATA']"" S VFDRET(0)="-1^No Data string defined" Q
 S ENT=$S($P(DATA,"~",1)'="":$P(DATA,"~",1),1:"SYS")
 S PAR=$P(DATA,"~",2)
 I PAR="" S VFDRET(0)="-1^No parameter defined in Data string" Q
 S INST=+$P(DATA,"~",3) S:'INST INST=1
 D INTERN^XPAR1 I ERR S VFDRET(0)="-1^Parameter not defined" Q
 D CHG^XPAR(ENT,PAR,INST,.VFDCLT,.WPA)
 I +WPA S VFDRET(0)="-1^"_$P(WPA,U,2) Q
 S VFDRET(0)="1^Parameter changed successfully"
 Q
 ;
DEL ;  delete existing parameter/entity/instance
 ;  VALUE is not expected
 ;  DBIA #2263 - DEL^XPAR
 N X,Y,Z,ARR,VFDERR
 D COMMON(13) I $D(VFDERR) G OUT
 I ARR(3)="" S VFDERR="No Instance received"
 E  D DEL^XPAR(ARR(1),ARR(2),ARR(3),.VFDERR)
 G OUT
 ;
DELALL ;  delete all instances for entity/parameter
 ;  neither INSTANCE nor VALUE expected
 N X,Y,Z,ARR,VFDERR
 D COMMON(13) I '$D(VFDERR) D NDEL^XPAR(ARR(1),ARR(2),.VFDERR)
 G OUT
 ;
GET ;  return values for all instances of an entity/param
 ;  Expects only ENTITY, PARAMETER
 ;               FORMAT is optional - default to B
 ;               FORMAT input is ignored and always set to B
 ;  ARR(6) = Q - return list(#)=iI^iV
 ;           E - return list(#)=eI^eV
 ;           B - return list(#,"N")=iI^eI
 ;                      list(#,"V")=iV^eV
 ;           N - return list(#,"N")=iV^eI
 ;  Return VFDRET(#) = iI^eI^iV^eV
 ;     some of those pieces may be <null> depends upon ARR(6)
 ;     On error, return VFDRET(1)=-1^error message
 N I,P,X,Y,Z,ARR,VFDERR,VFDLIST
 D COMMON(234) I $D(VFDERR) S VFDRET(1)=VFDERR K VFDERR G OUT
 D GETLST^XPAR(.VFDLIST,ARR(1),ARR(2),ARR(6),.VFDERR)
 I $G(VFDERR)'=0 S VFDRET(1)="-1^"_$P(VFDERR,U,2) K VFDERR G OUT
 I '$G(VFDLIST) S VFDRET(1)="-1^No data found" G OUT
 ;  following FOR loop intentional.  Kill off return array element
 ;  after it has been processed.  Help to avoid <alloc> errors
 S Z=0,Y=ARR(6) F  S I=$O(VFDLIST(0)) Q:'I  S Z=Z+1 D
 . K P F X=1:1:4 S P(X)=""
 . I Y="Q" S P(1)=$P(VFDLIST(I),U),P(3)=$P(VFDLIST(I),U,2)
 . I Y="E" S P(2)=$P(VFDLIST(I),U),P(4)=$P(VFDLIST(I),U,2)
 . I Y="N" S P(3)=$P(VFDLIST(I,"N"),U),P(2)=$P(VFDLIST(I),U,2)
 . I Y'="B" S VFDRET(Z)=P(1)_U_P(2)_U_P(3)_U_P(4)
 . E  S VFDRET(Z)=VFDLIST(I,"N")_U_VFDLIST(I,"V")
 . K VFDLIST(I)
 . Q
 Q
 ;
GET1 ;  return value of a single entity/param/instance combo
 ;  Format codes [ARR(6)] = [Q]uick    - return iV
 ;                          [E]xternal - return eV
 ;                          [B]oth     - return iV^eV
 N X,Y,Z,ARR,VFDERR
 D COMMON(34) I $D(VFDERR) G OUT
 I "N"[ARR(6) S VFDERR="Invalid format parameter received" G OUT
 I ARR(3)="" S X=$$GET^XPAR(ARR(1),ARR(2),,ARR(6))
 I ARR(3)'="" S X=$$GET^XPAR(ARR(1),ARR(2),ARR(3),ARR(6))
 I X="" S VFDERR="No value found"
 E  S VFDRET=X
 G OUT
 ;
GETALL ;  Return all entity/parameter combinations for an instance
 ;  Expects only PARAMETER, INSTANCE
 ;  RETURN:  VFDRET = ^TMP("VFDC",$J,3-char entity,file_ien)=value
 ;  Return: if problems return @VFDRET@(1) = -1^error message
 ;    else return @VFDRET@(#) = 3-char entity code ^ entity ien ^ value
 ;    return array will be sorted by 3-char , ien
 N X,Y,Z,ARR,VFDERR,VFDLST,ENT,IEN,LST,PARM,ROOT,SEQ,STOP,TMP,VAL
 S VFDRET=$NA(^TMP("VFDC",$J))
 S TMP=$NA(^TMP("VFDCX",$J))
 K @VFDRET,@TMP
 S PARM=$$PARSE(3) I PARM<1 S @VFDRET@(1)=PARM Q
 D ENVAL^XPAR(TMP,ARR(2),ARR(3),.VFDERR,1)
 ;  @TMP@(entity-variable-pointer,iI)=iV
 I $G(VFDERR)>0 S @VFDRET@(1)="-1^"_$P(VFDERR,U,2) K @TMP Q
 D ENT(.LST,PARM) S ROOT=TMP,STOP=$P(TMP,")")
 F  S ROOT=$Q(@ROOT) Q:ROOT=""  Q:ROOT'[STOP  D
 .S VAL=@ROOT,X=$QS(ROOT,3),IEN=+X,X=$P(X,";",2) Q:X=""
 .S SEQ=$G(LST(X)) Q:'SEQ  S ENT=$P(LST(SEQ),U,2)
 .S @VFDRET@(ENT,IEN)=ENT_U_IEN_U_VAL
 .Q
 I '$D(@VFDRET) S @VFDRET@(1)="-1^No data found"
 Q
 ;
GETWP ;  Retrieve a word-processing type parameter value
 N I,X,Y,Z,ARR,VFDERR,VFDLST
 D COMMON(34) I $D(VFDERR) G OUT
 S:ARR(3)="" ARR(3)=1
 D GETWP^XPAR(.VFDLST,ARR(1),ARR(2),ARR(3),.VFDERR)
 I $G(VFDERR)>0 G OUT
 I '$D(VFDLST) K VFDERR G OUT
 S X=0,Y=0,VFDRET(1)=VFDLST
 F  S X=$O(VFDLST(X)) Q:X=""  S Y=Y+1,VFDRET(Y)=VFDLST(X,0)
 Q
 ;
NMALL ; 9/20/2005 - do not call this line directly
 ; use $$NMALL^VFDCXPR() instead
 N A,I,Y,Z,VFD,VFDVAL,VFDX,RET
 S Y=$G(FLDS),VFDVAL=$G(X),EXACT=$G(EXACT)
 I $E(Y,1,2)="@;" S Y=$E(Y,3,$L(Y))
 S Z=0 F I=1:1:$L(Y,";") I +$P(Y,";",I)=.01 S Z=I Q
 I 'Z S Y=".01;"_Y
 I Z>1 S A=$P(Y,";",Z),$P(Y,";",Z)="",Z=Y,Y=A D
 .F  Q:Z'[";;"  S Z=$P(Z,";;")_";"_$P(Z,";;",2,999)
 .S Y=Y_";"_Z
 .Q
 S VFD(1)="FILE^8989.51"
 S VFD(2)="FIELDS^@;"_Y
 S VFD(3)="FLAGS^APQ"
 S VFD(4)="INDEX^B"
 S VFD(5)="VAL^"_VFDVAL
 D FIND^VFDCFM05(.VFDX,.VFD)
 S (A,I,RET)=0,X=$G(@VFDX@(1,0))
 I +X=-1 S RET=X F  S I=$O(@VFDX@(I)) Q:'I  S A=A+1,VFDC(A)=@VFDX@(I,0)
 I +X>0 D
 .F  S I=$O(@VFDX@(I)) Q:'I  S X=@VFDX@(I,0) D
 ..I EXACT,$P(X,U,2)'=VFDVAL Q
 ..S A=A+1,VFDC(A)=X,RET=1
 ..Q
 .Q
 I A=1,EXACT S RET=VFDC(1)
 I 'RET S (RET,VFDC(1))="-1^No matches found for "_VFDVAL
 Q RET
 ;
REPL ;  Change an instance value for an existing entry
 N I,P,X,Y,Z,ARR,VFDERR
 D COMMON(13) I $D(VFDERR) G OUT
 I ARR(5)="" S VFDERR="No replacement instance value received"
 E  D REP^XPAR(ARR(1),ARR(2),ARR(3),ARR(5),.VFDERR)
 G OUT
 ;
 ;--------------------  subroutines  -----------------------
COMMON(CODE) ; called from most modules above
 S X=$$PARSE(CODE) S:X<1 VFDERR=X
 Q
 ;
ENT(VFDCX,PARM,UNCH) ;  API
 ;  return all allowable entities for parameter PARM
 ;  PARM - req - full name of the parameter or the pointer (IEN) to
 ;               the PARAMETER DEFINITION
 ;  UNCH - opt - I $G(UNCH) then return results of BLDLST^XPAREDIT
 ;               unchanged.
 ;  RETURN:
 ;   VFDCX = # entities in parameter definition
 ;   VFDCX(seq#) = p1^p2^p3^p4  where
 ;                 p1 = file# of entity class
 ;                 p2 = entity class 3 char code
 ;                 p3 = global name of entity class
 ;                 p4 = default entity (e.g., for PKG, SYS)
 ;   VFDCX(entity class 3 char code) = seq#
 ;   VFDCX(entity class global name) = seq#
 ;     global name = root of entity file without ^ - [e.g., VA(200,]
 ;
 ;   If problems, return VFDCX = -1^message
 ;
 N I,X,Y,Z,CHAR,DEF,DIERR,VFD,VFDERR,FILE,GLB,SEQ
 I $G(PARM)="" S VFDCX="-1^No parameter received" Q
 I PARM'=+PARM D  Q:$D(VFDCX)
 .S X=$$NM(PARM) I 'X S VFDCX="-1^Parameter "_PARM_" not found"
 .E  S PARM=+X
 .Q
 D BLDLST^XPAREDIT(.VFD,PARM) S VFDCX=0
 I $G(UNCH) M VFDCX=VFD
 E  F SEQ=0:0 S SEQ=$O(VFD(SEQ)) Q:'SEQ  D
 .K DIERR,VFDERR
 .S GLB=$P($$GET1^DID(+VFD(SEQ),,,"GLOBAL NAME",,"VFDERR"),U,2)
 .S X=VFD(SEQ),FILE=+X,CHAR=$P(X,U,4),DEF=$P(X,U,5)
 .S VFDCX(SEQ)=FILE_U_CHAR_U_GLB_U_DEF,VFDCX=1+VFDCX
 .S:GLB'="" VFDCX(GLB)=SEQ S:CHAR'="" VFDCX(CHAR)=SEQ
 .Q
 I VFDCX=0 S VFDCX="-1^Parameter (ien="_PARM_") not found"
 Q
 ;
MULT(IEN) ;  return 1 if parameter is multi-instance
 N X,DIERR,VFDERR Q $$GET1^DIQ(8989.51,$G(IEN)_",",.03,"I",,"VFDERR")
 ;
NM(P) ;  return the ien for a parameter definition P (#8989.51)
 N DIERR,VFDERR Q $$FIND1^DIC(8989.51,,"QX",$G(P),"B",,"VFDERR")
 ;
PARSE(FLG) ;  parse up DATA string and set up ARR() array
 ;  FLG - optional
 ;    If FLG[1 then explicit entity required - default to USR
 ;    If FLG[4 then explicit entity required - default to ALL
 ;    If FLG[2 then set GET format to B
 ;    If FLG[3 then value not needed
 ;  Return: PARAMETER DEFINITION ien
 ;     else return -1^error message
 ;
 ;  ARR(1) = entity     ARR(2) = param name    ARR(3) = instance
 ;  ARR(4) = value      ARR(5) = new instance value
 ;  ARR(6) = format for GET1
 ;
 N I,X,Y,Z,RTN K ARR S FLG=$G(FLG)
 F I=1:1:6 S ARR(I)=$P($G(DATA),"~",I)
 I FLG[1,ARR(1)="" S ARR(1)="USR"
 I FLG[4,ARR(1)="" S ARR(1)="ALL"
 I ARR(6)="" S ARR(6)=$S(FLG[2:"B",1:"Q")
 I FLG[2 S ARR(6)="B"
 I "QEBN"'[ARR(6)!(ARR(6)'?1U) S ARR(6)=""
 I ARR(2)="" Q "-1^No parameter name received"
 S RTN=$$NM(ARR(2))
 I 'RTN S RTN="-1^Parameter Definition "_ARR(2)_" not found"
 I RTN>0,FLG'[3,ARR(4)="" S RTN="-1^No value received"
 Q RTN
