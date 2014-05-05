VFDVUTL1 ;DSS/SGM - INTERFACE TO %ZOSF GLOBAL; 2/26/2013 18:30
 ;;2011.1.2;DSS,INC VXVISTA OPEN SOURCE;;11 Jun 2013;Build 13
 ;Copyright 1995-2013,Document Storage Systems Inc. All Rights Reserved
 ;
 ;This routine is only called by VFDVUTL
 ;
 ;DBIA# Supported Reference
 ;----- ---------------------------------------------------------
 ;10096 All ^%ZOSF() nodes are useable
 ;10141 $$VER^XPDUTL
 ;10097 %ZOSV: GETENV, $$OS, $$VERSION
 ;      Unsupported References
 ;      ----------------------
 ; 3127 FM read of all fields in file 8989.51
 ;10052 supported KILL^XUSCLEAN (which falls into KILL1^XUSCLEAN)
 ;      Direct global read of "B" index on file 19
 ;      M^XQ
 ;      INIT^XQ12
 ;
OS() ; return M^M-version^OS
 Q $$VERSION^%ZOSV(1)_"^"_$$VERSION^%ZOSV_"^"_$$OS^%ZOSV
 ;
CNVT ;  api to check input string for certain characters only
 ;  INPUT - required - string to be checked to see if it
 ;          contains certain characters
 ;    STR - required - string of characters that represent the
 ;          only valid characters allowed in the INPUT string
 ;  FLAGS - optional - convert INPUT and STR prior to check
 ;          if FLAGS="U" convert any lower case to upper case
 ;          if FLAGS="L" convert any upper case to lower case
 ;  Return INPUT value stripped of any no valid characters
 ;    if all INPUT characters invalid, return <null>
 N I,J,X,Y,Z
 I $G(INPUT)="" Q ""
 I $G(STR)="" Q INPUT
 S FLAGS=$G(FLAGS) S:FLAGS="" FLAGS=" "
 I "Uu"[FLAGS D
 .I INPUT?.E1L.E S INPUT=$$UP^VFDVUTL(INPUT)
 .I STR?.E1L.E S STR=$$UP^VFDVUTL(STR)
 .Q
 I "Ll"[FLAGS D
 .I INPUT?.E1U.E S INPUT=$$LOW^VFDVUTL(INPUT)
 .I STR?.E1U.E S STR=$$LOW^VFDVUTL(STR)
 .Q
 S X="" F I=1:1:$L(INPUT) S Y=$E(INPUT,I) S:STR[Y X=X_Y
 Q X
 ;
FILENAME ; extrinsic function to return unique HFS filename
 ; FNM - opt - path or filename or both
 ;             default to VFD.TXT
 ; DPATH - opt - If +DPATH=DPATH then extract filename and append
 ;                  filename to vxVistA system default path
 ;               Else if DPATH'="" use that path
 ; if FNM is a fully resolved name (ie. path_filename) then assume:
 ;    path name contains \ for Win, / for Linux/Unix, ]: for VMS
 ; <filename stub>SEP<initials+duz>SEP<date_time><R#>.ext
 N I,J,L,X,Y,Z,EXT,FILE,INIT,NM,NUM,PATH,SEP
 S (EXT,FILE,PATH)="",FNM=$G(FNM),DPATH=$G(DPATH)
 S SEP="_"
 I FNM["]:" D  ; VMS
 .S PATH=$P(FNM,"]:")_"]:"
 .S FILE=$P(FNM,"]:",2)
 .Q
 E  I FNM["\" D  ; Win
 .S J=$L(FNM,"\"),PATH=$P(FNM,"\",1,J-1)_"\"
 .S FILE=$P(FNM,"\",J)
 .Q
 E  I FNM["/" D  ; Linux/Unix
 .S J=$L(FNM,"/"),PATH=$P(FNM,"/",1,J-1)_"/"
 .S FILE=$P(FNM,"/",J)
 .Q
 E  S FILE=FNM
 I FILE="" S FILE="VFD.TXT"
 I FILE["." S J=$L(FILE,"."),EXT=$P(FILE,".",J),FILE=$P(FILE,".",1,J-1)
 E  S EXT="TXT"
 I DPATH'="",DPATH'=+DPATH S PATH=$$DEFDIR^%ZISH(DPATH)
 I DPATH=+DPATH S PATH=$$PWD^%ZISH
 ; at this point we have name parsed into path, file, ext
 ; get user initials, default to "zZ"
 S X=+$G(DUZ),X(0)=$G(^VA(200,X,0)),INIT=$P(X(0),U,2),NM=$P(X(0),U)
 S Y=INIT I Y="" S Y=$E(NM)_$E($P(NM,",",2)) I Y="" S Y="zZ"
 S FILE=FILE_SEP_Y_$TR(X,".","_")
 ; add date/time
 S FILE=FILE_SEP_$P($$FMTHL7^XLFDT($$NOW^XLFDT),"-")
 ; add a random number
 S FILE=FILE_"R"_$R(100000)
 S FILE=PATH_FILE S:EXT'="" FILE=FILE_"."_EXT
 Q FILE
 ;
GETENV ; return value from GETENV^%ZOSV
 N I,Y D GETENV^%ZOSV
 F I=1:1:4 S VFDR(I)=$P(Y,U,I)
 S VFDR=Y
 Q
 ;
GETROU(RET,PURGE) ; get list of routines
 ;   RET - opt - $NAME value of array to hold routine names
 ;       @RET@(routine)="" - default to ^UTILITY($J)
 ; PURGE - opt - Boolean - default to 1 - if 1 K return array before starting
 ; Return # of routines selected
 N I,X,Y,Z,DIFF,UTL
 S RET=$G(RET),UTL=$NA(^UTILITY($J)) S:RET="" RET=UTL
 S DIFF=$NA(@RET)=UTL S:'$D(PURGE) PURGE=1
 I PURGE!'DIFF K @UTL
 X ^%ZOSF("RSEL")
 S X=0 F I=0:1 S X=$O(@UTL@(X)) Q:X=""  S:'DIFF @RET@(X)=""
 K:'DIFF @UTL
 Q I
 ;
OPT ; run option=NM
 N I,X,Y,Z,XQDIC,XQXFLG,XQY,XQY0
 Q:$G(NM)=""
 S X=$O(^DIC(19,"B",NM,0)) Q:X=""
 S (XQDIC,XQY)=X,$P(XQXFLG,U,3)="XUP"
 D INIT^XQ12,M^XQ,KILL1^XUSCLEAN
 Q
