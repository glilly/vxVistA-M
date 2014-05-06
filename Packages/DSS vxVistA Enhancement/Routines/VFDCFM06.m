VFDCFM06 ;DSS/SGM - FILEMAN DD UTILITIES ; 1/30/2013 14:05
 ;;2011.1.2;DSS,INC VXVISTA OPEN SOURCE;;11 Jun 2013;Build 13
 ;Copyright 1995-2013,Document Storage Systems Inc. All Rights Reserved
 ;
 ;Fileman utilites for accessing the DD structure
 ;
 ;DBIA#  Supported References
 ;-----  -----------------------------------------------------
 ; 2051  $$FIND1^DIC
 ; 2052  ^DID: FIELD, FIELDLST
 ; 2054  ^DILF: CLEAN, DA
 ; 2055  ^DILFD: $$VFILE, $$VFIELD, FLDNUM, $$EXTERNAL, $$ROOT
 ;10104  $$UP^XLFSTR
 ;
 ;Common input parameters
 ;---------------------------------------------------------
 ;  FILE - req - file (or subfile) number or full file name
 ;   FUN - opt - if $G(FUN) then extrinsic function
 ;               use deprecated 1/30/2013 - changed to using $Q
 ; FIELD - req - field number or full field name
 ;
OUT Q:$Q VFDC Q
 ;
EXTERNAL(VFDC,FILE,FIELD,VALUE,FUN) ; RPC: VFDC FM EXTERNAL
 ; convert data from internal to external format
 ; does not require ien to file
 ; VALUE - req - internal value to be converted to external
 N X,Y,DIERR,FLAG,TYPE
 D INIT("FILE^FIELD^VALUE")
 I VALUE="" D ERM(1) G OUT
 S FILE=$$VFILE(,FILE,1) I +FILE=-1 S VFDC=FILE G OUT
 S FIELD=$$VFIELD(,FILE,FIELD,1) I +FIELD=+1 S VFDC=FIELD G OUT
 S X=$$EXTERNAL^DILFD(FILE,FIELD,,VALUE)
 I '$D(DIERR) S VFDC=X
 E  S VFDC=$$ERR
 G OUT
 ;
FIELD(VFDC,FILE,FIELD,FLAG,ATT,TYPE) ; RPC: VFDC FM GET FIELD ATTRIB
 ; this will return the inputed field attributes for a file
 ; FILE, FIELD - req - see above
 ; FLAG - opt - default value = ""
 ;       [ N - attribute not returned if the attribute is null
 ;       [ Z - WP attributes include zero (0) nodes with text
 ; TYPE - opt - default = 1
 ;        if TYPE=1, then return VFDC(attribute name)=value
 ;           for wp fields, return VFDC(att name,#)=text
 ;        else return VFDC(#)=attribute name^value  [from RPC]
 ;           for wp fields, return VFDC(#)=att name^text
 ;  ATT - req - list OR ';'-delimied string of attributes to return
 ;        from M routine you can pass att(attrib name)=""
 ;        from RPC, pass ATT(n) = attribute name
 ;        To get all field attributes, pass
 ;           ATT("*")=""  or  ATT(1) = "*"
 ; Return VFDC() - see TYPE definition
 ; Errors/problems - return VFDC(1)=-1^msg
 ;
 N A,I,X,Y,Z,DIERR,VFDCX,FLGZ,VAL
 D INIT("FILE^FIELD^FLAG^TYPE"),FLDCK Q:$D(VFDC)
 I FLAG["Z",$$BROKER^VFDVUTL S FLAG=$TR(FLAG,"Z")
 S FLGZ=FLAG["Z",FLAG=$TR(FLAG,"Z")
 D ATT Q:$D(VFDC)
 D FIELD^DID(FILE,FIELD,FLAG,ATT,"VFDCX")
 I $D(DIERR) S VFDC(1)=$$ERR Q
 F A="DESCRIPTION","TECHNICAL DESCRIPTION" D
 .K Y,Z M Z=VFDCX(A) K VFDCX(A)
 .S X="Z",Y="VFDCX(A,I"_$S(FLGZ:",0)",1:")")
 .F I=1:1 S X=$Q(@X) Q:X=""  S @Y=@X
 .Q
 I TYPE M VFDC=VFDCX
 I 'TYPE S Z=0,X="" F  S X=$O(VFDCX(X)) Q:X=""  D:$D(ATT(X))#2
 .I ATT(X)'="WP" S Z=Z+1,VFDC(Z)=X_U_VFDCX(X) Q
 .F I=0:0 S I=$O(VFDCX(X,I)) Q:I=""  D
 ..S Z=Z+1,VFDC(Z)=X_U_$S(FLGZ:VFDCX(X,I,0),1:VFDCX(X,I))
 ..Q
 .Q
 I '$D(VFDC) D ERM(2,1)
 Q
 ;
FIELDLST(VFDCX,INPUT) ;  api - return list of field attributes
 ; INPUT - opt - pass by reference OR as a string
 ;    if INPUT(attrib name)="" then only return in VFDCX those names
 ;    which are valid
 ;    if INPUT=string then string must be a ';'-delimited list of field
 ;    attributes
 ; Return: VFDCX(attribute) = "" or WP (if attrib a word processing fld)
 ;
 N I,X,Y,Z,ATT,VFDCA
 I $G(INPUT)'="" D
 .F I=1:1:$L(INPUT,";") S X=$P(INPUT,";",I) S:X'="" INPUT(X)=""
 .Q
 S X="" F  S X=$O(INPUT(X)) Q:X=""  Q:X'?.E1L.E  D
 .K INPUT(X) S X=$$UP^XLFSTR(X),INPUT(X)=""
 .Q
 D FIELDLST^DID("VFDCA")
 S X="" F  S X=$O(VFDCA(X)) Q:X=""  D
 .S Y="" I $D(VFDCA(X,"#(word-processing)")) S Y="WP"
 .I '$D(INPUT)!$D(INPUT(X)) S VFDCX(X)=Y
 .Q
 Q
 ;
MULT(VFDCM,VFDN) ; rpc: VFDC FM GET FIELD ATTRIB MULT
 ; Return requested attributes for one or more fields in a file.
 ; VFDN(n) = label^value  [required]  for n=0,1,2,3,4,...  where
 ; Label  Req  Value
 ; -----  ---  ------------------------------------
 ; FILE    y   see above
 ; FIELD   y   see above - multiple input forms allowed
 ;               VFDN(i) = FIELD^fld#1;fld#2;fld#3;...
 ;               VFDN(i) = FIELD^fld#
 ;               VFDN(i) = FIELD^fld1;fld2:fld3;fld4;fld5:fld6;...
 ;                 where ':' indicates all field numbers inclusive
 ; FLAG    n   default value = ""
 ;             if FLAG["N" - att not returned if the att value is null
 ;                    ["Z" - WP att include zero (0) nodes with text
 ; TYPE    n   default = 1
 ;             if TYPE=1, then return VFDCM(fld#,attrib_name)=value
 ;               for wp fields, return VFDCM(fld#,att name,#)=text
 ;               else return VFDCM(#)=field#^attrib_name^value  [for RPC]
 ;               for wp fields, return VFDCM(#)=fld#^att name^text
 ; ATT     y   list of attributes to return
 ;             ';'-delimiter string of attrib names
 ;             or it can be a single attrib name
 ;             for all attributes, pass VFDN(i) = ATT^*
 ;
 ; Return VFDCM() - see TYPE definition
 ; Any errors or problems will be returned in VFDC(1)=-1^err msg
 N A,I,J,X,Y,Z,ATT,VFDA,VFDC,VFDFLD,FIELD,FILE,FLAG,FLD,TYPE
 S I="" F  S I=$O(VFDN(I)) Q:I=""  S Z=VFDN(I) D
 .S Y=$P(Z,U),X=$P(Z,U,2)
 .I Y?.E1L.E S Y=$$UP^XLFSTR(Y)
 .I "^FILE^FLAG^TYPE^"[(U_Y_U) S @Y=X Q
 .I Y="ATT" S J=1+$O(ATT("A"),-1),ATT(J)=X
 .I Y="FIELD" S J=1+$O(FLD("A"),-1),FLD(J)=X
 .Q
 D INIT("FILE^FLAG^TYPE"),FLDCK
 I $D(VFDC) M VFDCM=VFDC Q
 D ATT I $D(VFDC) M VFDCM=VFDC Q
 M VFDA=ATT
 F I=0:0 S I=$O(FLD(I)) Q:'I  S X=FLD(I) D  Q:$$MT
 .F J=1:1:$L(X,";") S A=$P(X,";",J) D:+A  Q:$$MT
 ..I A'[":" S FLD=A D M1 Q
 ..I $D(^DD(FILE,+A)) S FLD=+A D M1 Q:$$MT
 ..S Y=+A
 ..F  S Y=$O(^DD(FILE,Y)) Q:'Y  Q:Y>+$P(A,":",2)  S FLD=Y D M1 Q:$$MT
 ..Q
 .Q
 I '$D(VFDCM) D ERM(3,1)
 Q
 ;
M1 ;
 N A,I,J,X,Y,Z,ATT,VFDC
 M ATT=VFDA
 D FIELD(.VFDC,FILE,FLD,FLAG,.ATT,TYPE)
 I +$G(VFDC(1))=-1 K VFDCM M VFDCM=VFDC Q
 I TYPE M VFDCM(FLD)=VFDC Q
 S J=$O(VFDCM("A"),-1)
 F I=0:0 S I=$O(VFDC(I)) Q:'I  S J=J+1,VFDCM(J)=FLD_U_VFDC(I)
 Q
 ;
MT() Q +$G(VFDCM(1))=-1
 ;
ROOT(VFDC,FILE,IENS,FLAG,FUN) ; RPC: 
 ; Return global root (open or closed) for a file or subfile
 ; On error return -1^message
 ;   IENS - opt - needed if passing subfile
 ;   FLAG - opt - default to 0 - 1:closed root; 0:open root
 ;
 I $G(FILE)="" D ERM(4) G OUT
 N X,Y,Z,DIERR,VFDER,TYPE
 D INIT("FILE^IENS^FLAG")
 S FLAG=(FLAG'=0)
 I IENS'="" S X=$$VIENS(,IENS,1) I X<1 S VFDC=X G OUT
 S VFDC=$$ROOT^DILFD(FILE,IENS,FLAG,1) I VFDC?1"^".E G OUT
 I $D(DIERR) S VFDC=$$ERR
 I '$D(DIERR) D ERM(2)
 D CLEAN^DILF
 G OUT
 ;
VFILE(VFDC,FILE,FUN) ; RPC: VFDC FM VERIFY FILE
 ; verify whether or not a file or subfile exists
 ; Return - file number if file exists
 ;          -1^message if problem
 N X,Y,DIERR,VFD,FLAG,TYPE
 D INIT("FILE") S VFD=FILE
 I FILE="" D ERM(4) G OUT
 I FILE'=+FILE D  G:$D(VFDC) OUT
 .S X=$$FIND1^DIC(1,,"QX",FILE,"B")
 .I '$D(DIERR),X>0 S FILE=X
 .I $D(DIERR) S VFDC=$$ERR
 .Q
 S X=$$VFILE^DILFD(FILE) S:X VFDC=FILE D:'X ERM(5)
 G OUT
 ;
VFIELD(VFDC,FILE,FIELD,FUN) ; RPC: VFDC FM VERIFY FIELD
 ; verify whether or not a field exists
 ; Return - field number if file and field exist
 ;          -1^message if problem
 N X,Y,DIERR,FLAG,TYPE
 D INIT("FILE^FIELD")
 I FILE'=+FILE!(FILE'>0) D ERM(4) G OUT
 I FIELD="" D ERM(6) G OUT
 S X=$$VFIELD^DILFD(FILE,FIELD) I X S VFDC=FIELD G OUT
 S X=$$FLDNUM^DILFD(FILE,FIELD)
 I $D(DIERR) S VFDC=$$ERR I 1
 E  S VFDC=X
 G OUT
 ;
VIENS(VFDC,IENS,FUN) ; RPC:
 ; validate that IENS is a proper iens string
 ;   IENS - req
 ; RETURN - 1:valid iens string; -1^msg
 ;
 N X,Y,Z,DA,FLAG,TYPE
 D INIT("IENS")
 I IENS="" D ERM(7) G OUT
 D DA^DILF(IENS,.DA)
 S:$D(DA) VFDC=1 I '$D(DA) D ERM(8)
 G OUT
 ;
 ;--------------  subroutines  ---------------
ATT ; expects ATT=';' delimited string OR
 ; OR ATT(i)=attribute name or ""
 ; OR ATT(i)=1 or * [ get all attributes]
 ; If ATT(i)="" then assume i=attribute name or 1 or *
 ; Reset ATT - S ATT=';' delimited string of attribs to get
 ;             S ATT(attrib name) = "" or WP
 N A,I,J,X,Y,Z,ARR,VFD,ERR
 S X=$G(ATT)
 I X'="" F I=1:1:$L(X,";") S Y=$P(X,";",I) S:Y'="" ARR(Y)=""
 S X=""
 F  S X=$O(ATT(X)) Q:X=""  S Y=ATT(X) D
 .I Y="" S ARR(X)=""
 .I Y'="" S ARR(Y)=""
 .Q
 I $D(ARR(1))!$D(ARR("*")) K ARR S ARR("*")=""
 I $O(ARR(""))="" D ERM(9,1) Q
 K ATT D FIELDLST(.VFD)
 S (X,ATT,ERR)=""
 F  S X=$O(ARR(X)) Q:X=""  I X'="*",'$D(VFD(X)) S ERR=ERR_X_";"
 I ERR'="" D ERM(10,1) Q
 S X="" F  S X=$O(VFD(X)) Q:X=""  D
 .I $D(ARR("*")) S ATT=ATT_X_";",ATT(X)=VFD(X) Q
 .I $D(ARR(X)) S ATT=ATT_X_";",ATT(X)=VFD(X)
 .Q
 I $E(ATT,$L(ATT))=";" S ATT=$E(ATT,1,$L(ATT)-1)
 Q
 ;
ERM(A,B) ;
 N X
 I A=1 S X="No internal value received"
 I A=2 S X="Unexpected problem encountered"
 I A=3 S X="No data found"
 I A=4 S X="No file received"
 I A=5 S X="File '"_VFD_"' does not exist"
 I A=6 S X="No field value received"
 I A=7 S X="No IENS string received"
 I A=8 S X="'"_IENS_"' is not a valid iens string"
 I A=9 S X="No attributes received"
 I A=10 S X="Invalid attribute name(s) received: "_ERR
 S X="-1^"_X S:'$G(B) VFDC=X S:$G(B) VFDC(B)=X
 Q
 ;
ERR() ; if $D(DIERR) return "-1^"_error msg from VFDER or ^TMP("DIERR",$J)
 N VFDX,INPUT
 S INPUT=$S($D(VFDER):"VFDER",1:"")
 S VFDX="-1^"_$$MSG^VFDCFM("E",,,,INPUT) D CLEAN^DILF
 Q VFDX
 ;
FLDCK ; check for valid file/fld
 S FILE=$$VFILE(,FILE,1) I +FILE=-1 S VFDC(1)=FILE Q
 I $D(FIELD) D  Q:$D(VFDC)
 .S FIELD=$$VFIELD(,FILE,FIELD,1)
 .I +FIELD=-1 S VFDC(1)=FIELD
 .Q
 Q
 ;
INIT(STR) ; str - ^-delimited string of variable names to initialize
 N I,X
 F I=1:1:$L(STR,U) S X=$P(STR,U,I) I X'="" S @X=$G(@X)
 I STR["FLAG",$G(FLAG)'="" S FLAG=$$CNVT^VFDVUTL(FLAG,"10NZ","U")
 I STR["TYPE" S TYPE=$S(TYPE=1:1,$$BROKER^VFDVUTL:0,TYPE="":1,1:TYPE)
 Q
