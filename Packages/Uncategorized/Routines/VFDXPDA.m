VFDXPDA ;DSS/SMP - PATCH UTIL FM ;02/02/2012 15:45
 ;;3.1;DSS,INC VXVISTA SUPPORTED;;10 Dec 2012;Build 58
 ;Copyright 1995-2012,Document Storage Systems Inc. All Rights Reserved
 ;
 ;This routine should only be invoked via the VFDXPD routine
 ;ICR #  SUPPORTED REFERENCE
 ;-----  -------------------------------------------------
 ; 2050  MSG^DIALOG
 ;10006  ^DIC
 ; 2051  ^DIC: FIND,$$FIND1,LIST
 ;10018  ^DIE
 ; 2053  ^DIE: FILE,UPDATE
 ; 2054  $$IENS^DILF
 ; 2055  $$ROOT^DILFD
 ;10026  ^DIR
 ; 2056  ^DIQ: $$GET1,GETS
 ;
 ;====================== PRESS ENTER TO CONTINUE ======================
CONT ;
 N I,X,Y,Z
 R !!?5,"Press any key to continue ",X:10
 Q
 ;
 ;============================ RUN DDS FORM ===========================
DDS(FILE,DR,DA) ; interactive tool to edit an entry using screenman
 ; file - req
 ; dr - req - name of screenman form
 ; da - opt - ien of record to edit
 N X,Y,Z,DIC,IEN
 N DDSCHANG,DDSFILE,DDSPAGE,DDSPARM,DIMSG,DTOUT
 I '$G(FILE) W !!?3,"No file number received" Q
 S X=$$ROOT(FILE) I +X<-1 W !!?3,$P(X,U,2) Q
 I $G(DR)="" W !!?3,"No screenman form received" Q
 S:$E(DR)'="[" DR="["_DR S:$E(DR,$L(DR))'="]" DR=DR_"]"
 S DDSFILE=FILE S:$G(DA) IEN=DA
 ;
DDSX K X,Y,Z,DA,DIC
 I $D(IEN) S DA=IEN
 ; select record to edit
 E  S Z=DDSFILE,Z(0)="QAEML",X=$$DIC(.Z) Q:X'>0  S DA=+X
 S DIC=DDSFILE D ^DDS Q:$D(IEN)
 G DDSX
 ;
 ;======================== DIC CLASSIC SELECTOR =======================
DIC(DIC,DLAYGO,DA,VFDDA,MAX) ;
 ;INPUT PARAMS
 ; da()   - opt - passed by reference
 ; dic()  - req - passed by reference
 ; dlaygo - opt
 ; max    - opt - max # of records to retrieve if DO w/params call
 ; I '$D(VFDDA) then extrinsic function call which returns Y
 ; E  DO w/param call returns
 ;       @VFDDA@(ien) = ien^name[^1 if a new record]
 ;       if DIC(0)["Z" then also return @VFDDA@(ien,0)=Y(0)
 ;       Only return up to MAX number of records
 ;
 N I,J,X,Y,Z,DTOUT,DUOUT,VFDT
 I '$G(DLAYGO) K DLAYGO
 I '$D(VFDDA) W ! D ^DIC S:$D(DTOUT)!$D(DUOUT) Y=-2 Q Y
 S VFDT=0,MAX=+$G(MAX)
 F  W ! D ^DIC Q:Y'>0!$D(DTOUT)!$D(DUOUT)  D  I MAX,VFDT'<MAX Q
 .S @VFDDA@(+Y)=Y I DIC(0)["Z",$G(Y(0))'="" S @VFDDA@(+Y,0)=Y(0)
 .S VFDT=1+VFDT
 .Q
 Q
 ;
 ;============================== DIE EDIT =============================
DIE(DIE,DA,DR) ;
 ;INPUT PARAMS - all are required
 ;Return - extrinsic function return 1 if successful, 0 if ^-out
 N I,J,X,Y,Z,DTOUT,DUOUT W ! D ^DIE S:$D(DUOUT)!$D(DTOUT) Y=0
 Q $D(Y)=0
 ;
 ;============================ DIR PROMPTER ===========================
DIR(DIR) ;
 ;INPUT PARAM - dir() required
 ;Extrinsic function returns value of Y
 N I,J,X,Y,Z,DIROUT,DIRUT,DTOUT,DUOUT
 W ! D ^DIR I $D(DTOUT)!$D(DUOUT)!$D(DIROUT) S Y=-1
 Q Y
 ;
 ;========== ASK IF OUTPUT FORMAT IS DELIMITED OR FORMATTED ===========
EXCEL() ; Boolean return 1 if output delimited
 N I,X,Y,Z
 D TAG^VFDXPD0(3,1,0,.Y) M Z("A")=Y K Y
 S Z(0)="SO^1:Delimited;0:Formatted",Z("A")="   Report Format",Z("B")=0
 Q $$DIR(.Z)
 ;
 ;============================= FILE^DIE ==============================
FILE(FILE,IEN,ARRAY) ;
 ; FILE - req - file or subfile number
 ;  IEN - req - standard FM DBS iens
 ;.ARRAY - req - list of fields to update - array(field#)=internal val
 I '$G(FILE)!'$G(IEN)!'$O(ARRAY(0)) Q -2
 N I,J,X,Y,Z,DIERR,VFD,VFDER
 I $E(IEN,$L(IEN))'="," S IEN=IEN_","
 M VFD(FILE,IEN)=ARRAY
 D FILE^DIE(,"VFD","VFDER")
 I $D(DIERR) Q $$MSG("VFDER")
 Q +IEN
 ;
 ;============================== FIND^DIC =============================
FIND(VFDRET,FILE,IENS,FLDS,FLAGS,VFDVAL,NUM,VFDINDX,VFDSCR,ID) ;
 ; see FM documentation for meaning of input params
 ; Default values: FLAGS="AMQ", NUM=100
 ; If problems encountered, only return error message in VFDRET
 ; Extrinsic function: 1:# recs found; 0:no data found; -1^msg:errors
 ;   FIND^DIC returns @VFDRET@("DILIST",...), this will remove the
 ;   DILIST node from the return array
 N I,J,X,Y,Z,DIERR,VFDER,VFDX
 I '$G(FILE)!'$D(VFDVAL)!$G(VFDRET)="" Q -1
 S FLDS=$G(FLDS) I FLDS="" S FLDS="@;.01"
 S FLAGS=$G(FLAGS) S:FLAGS="" FLAGS="AMPQ"
 S NUM=$G(NUM) I 0[NUM S NUM=100
 S VFDX=$NA(^TMP("VFDXPDA",$J))
 K @VFDX,@VFDRET
 D FIND^DIC(FILE,$G(IENS),FLDS,FLAGS,.VFDVAL,NUM,.VFDINDX,.VFDSCR,$G(ID),VFDX,"VFDER")
 M @VFDRET=@VFDX@("DILIST") K @VFDX K:$D(DIERR) @VFDRET
 I '$D(DIERR) Q +@VFDRET@(0)
 Q $$MSG("VFDER")
 ;
 ;============================= FIND1^DIC =============================
FIND1(FILE,IENS,FLAGS,VFDINDX,VFDSCR,VFDVAL) ;
 ; Extrinsic function returns ien or 0 if no matches or -1 if error
 ; see FM documentation for meaning of input params
 ; FLAGS - opt - default to "AMQ"
 N I,J,X,Y,Z,DIERR,VFDER
 I '$G(FILE)!($G(VFDVAL)="") Q -1
 S FLAGS=$G(FLAGS) S:FLAGS="" FLAGS="AMQ"
 S X=$$FIND1^DIC(FILE,$G(IENS),FLAGS,.VFDVAL,.VFDINDX,.VFDSCR,"VFDER")
 Q $S(X'="":X,1:-1)
 ;
 ;============================= GET1^DIQ ==============================
GET1(FILE,IENS,FLD,FLAGS) ;
 ;INPUT PARAMS
 ; Required - file, iens, fld
 ; flags - opt - default to "E"
 ;Extrinsic funtion - return value of field or -1^msg 
 N I,J,X,Y,Z,DIERR,VFDER
 I '$G(FILE) Q "-1^no file param received"
 I $G(FLD)="" Q "-1^no field value received"
 S FLAGS=$G(FLAGS) S:FLAGS="" FLAGS="E"
 I $E(IENS)'="," S IENS=IENS_","
 S X=$$GET1^DIQ(FILE,IENS,FLD,FLAGS,,"VFDER")
 I $D(DIERR) Q $$MSG("VFDER")
 Q X
 ;
 ;============================= GETS^DIQ ==============================
GETS(VFDR,FILE,IENS,FLDS,FLAGS) ;
 ;INPUT PARAMS
 ;  Required: file, iens
 ;  flds - opt - default to "**"
 ;  flags - opt - default to "E"
 ;RETURN: extrinsic function 1:successful, else -1^msg
 ; VFDR - passed by name reference
 ;        @vfdr@(file,iens,field#,"E")=value
 ; extrinsic function returns 1 or -1^msg
 N I,J,X,Y,Z,DIERR,VFDER,VFDRET
 I '$G(FILE) Q "-1^No file number received"
 I $G(IENS)="" Q "-1^No iens received"
 I $E(IENS,$L(IENS))'="," S IENS=IENS_","
 I $G(FLDS)="" S FLDS="**"
 I $G(FLAGS)="" S FLAGS="E"
 D GETS^DIQ(FILE,IENS,FLDS,FLAGS,"VFDRET","VFDER")
 I $D(DIERR) Q $$MSG("VFDER")
 M @VFDR=VFDRET
 Q 1
 ;
 ;======================= RETURN IENS FROM DA() =======================
IENS(VFDDA) ;
 I '$D(VFDDA) Q "-1^No DA() array received"
 N I,X,Y,Z S X=$$IENS^DILF(.VFDDA) S:X="" X="-1^No DA() array"
 Q X
 ;
 ;============================= MSG^DIALOG =============================
MSG(VFDARR,WR) ; process FM message array
 ;INPUT PARAM:
 ;vfdarr - req - named reference holding FM error
 ;    wr - opt - if WR then write error to screen
 ;Return values:
 ;  if WR then return "", else return -1^error
 ;Since FLG'["S" then this K DIERR,DIHELP,DIMSG
 N A,I,J,K,L,X,Y,Z,FLG,VFDOUT
 S WR=$G(WR),FLG="ABE" S:WR FLG="ABEW"
 D MSG^DIALOG("ABE",.VFDOUT,72,0,VFDARR) I WR W ! Q ""
 S X="",I=0 F  S I=$O(VFDOUT(I)) Q:'I  S Y=VFDOUT(I)_" " D  Q:$L(X)>508
 .S Z=$L(X)+$L(Y) I Z<510 S X=X_Y_" - " Q
 .S X=X_Y,X=$E(X,1,506)_"..."
 .Q
 Q "-1^"_X
 ;
 ;============================= ROOT^DILFD ============================
ROOT(FILE,IENS,FLAGS,VFDDA) ;
 ;Return open/closed global root or -1^message
 ; If FILE is the top level, then neither IENS nor [.]DA required
 ; Else, either IENS or [.]DA must be passed
 ; FLAGS: 1:closed root; 0:open root [default to OPEN]
 N I,X,Y,Z,DIERR
 K ^TMP("DIERR",$J)
 I '$G(FILE) Q "-1^No file number received"
 S FLAGS=+$G(FLAGS) S:+FLAGS FLAGS=1
 I $G(IENS)="",$D(VFDDA) S IENS=$$IENS(.VFDDA) I +IENS=-1 Q IENS
 S X=$$ROOT^DILFD(FILE,$G(IENS),FLAGS,1)
 I $D(DIERR) S X="-1^"_X
 K ^TMP("DIERR",$J)
 Q X
 ;
 ;============================= UPDATE^DIE ============================
UPDATE(FILE,IENS,VFDARR,VFDA) ;
 ; FILE - req - file or subfile number
 ; IENS - opt - standard FM DBS iens, default to "+1,"
 ;.VFDARR - req - list of fields to update - array(field#)=internal val
 ; .VFDA - opt - standard FDA arry, if $D(VFDA) ignore file,ien, array
 N I,J,X,Y,Z,DIERR,VFDER,VFDIEN,VFDIENS
 I '$D(VFDA),'$G(FILE)!'$O(VFDARR(0)) Q -2
 I '$D(VFDA) S:$G(IENS)="" IENS="+1," M VFDA(FILE,IENS)=VFDARR
 S Z="VFDA",Z=$Q(@Z),VFDIENS=+$TR($QS(Z,2),"+?"),VFDIEN(VFDIENS)=""
 D UPDATE^DIE(,"VFDA","VFDIEN","VFDER")
 S Y=+VFDIEN(VFDIENS)
 Q $S(Y>0:Y,$D(DIERR):$$MSG("VFDER"),1:-3)
 ;
UPDDINUM(FILE,IEN,VFDARR) ; update^die with dinuming
 ; FILE - req - file or subfile number
 ;  IEN - opt - required for subfile, 1st ',' is null (eg. ,3,)
 ; .VFDARR - req - list of fields at this level only and their values
 ;    .vfdarr(incrementor,field#) = value
 ;       if field=.01 the vfdarr(inc,field#) = value [^dinum value]
 ;       second '^'-piece optional, if not pass then dinum to value
 ;       incrementor is arbitrary, used only to separate multiple recs
 ;       must have at a minimum a .01 field value
 ;Extrinsic function returns 1 or -1^message
 N F,I,J,R,V,X,Y,Z,DIERR,ERR,VFDA,VFDERR,VFDIEN,VIEN
 S Z="-1^Invalid input parameter(s) received"
 I $G(FILE)'>0!($O(VFDARR(0))="") Q Z
 S IEN=$G(IEN) S:$E(IEN)'="," IEN=","_IEN
 I IEN'=",",IEN'?1","1.N1",".E Q Z
 S J=0,(I,ERR)=""
 F  S I=$O(VFDARR(I)) Q:I=""  D  Q:ERR
 .I '$D(VFDARR(I,.01)) S ERR=1 Q
 .S J=J+1,VIEN="?+"_J_IEN,R=$NA(VFDA(FILE,VIEN))
 .S V=VFDARR(I,.01),X=$P(V,U,2) S:X'>0 X=+V I X'>0 S ERR=1 Q
 .S VFDIEN(J)=X,@R@(.01)=$P(V,U)
 .S F=0 F  S F=$O(VFDARR(I,F)) Q:'F  S:F'=.01 V=VFDARR(I,F),@R@(F)=V
 .Q
 I ERR'="" Q "-1^Record(s) received with invalid .01 field values"
 I '$D(VFDA) Q "-1^Unexpected problems encountered"
 D UPDATE^DIE(,"VFDA","VFDIEN","VFDERR")
 I $D(DIERR) Q $$MSG("VFDERR")
 Q 1
 ;
 ;---------------------------------------------------------------------
TNEW(TAG) ; totally new all chars matching 1U or 1U1N or 1"%" or 1"%"1N
 N INC,INCX,INCY,STR
 S STR="" F INC=65:1:90,"%" D
 .S:'INC INCX=INC S:INC INCX=$C(INC)
 .S STR=STR_INCX_"," F INCY=0:1:9 S STR=STR_INCX_INCY_","
 .Q
 S STR=$E(STR,1,$L(STR)-1)
 N @STR
 G @TAG
