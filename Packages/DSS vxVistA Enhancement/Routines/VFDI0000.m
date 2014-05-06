VFDI0000 ;DSS/SGM - COMMON KIDS SUPPORT UTILITIES ; 5/13/2013 14:05
 ;;2011.1.2;DSS,INC VXVISTA OPEN SOURCE;;11 Jun 2013;Build 4
 ;Copyright 1995-2013,Document Storage Systems Inc. All Rights Reserved
 ;
 ; this routine first introduced in VFD VXVISTA UPDATE 2011.1.1 T4
 ;
 ; ICR#  SUPPORTED DESCRIPTION
 ;-----  ---------------------------------------------------------
 ;       ^DID: FILE
 ;       ^DILFD: $$VFIELD, $$VFILE
 ;       EN^DIU2
 ;       MES^XPDUTL
 ;       Reference the %ZOSF global
 Q
 ;
 ;------------ ADD RPCs TO AN EXISTING OPTION MENU CONTEXT ------------
ADDRPC(VFDRET,VFDOPT,VFDRPC,VFDATA) ; RPC: 
 I $$RTNTEST("VFDI000X","RPC") D RPC^VFDI000X
 Q
 ; If you only have one option and one RPC to add to that menu, then
 ;    VFDOPT = option name     VFDRPC = remote procedure name
 ; Else   .VFDATA(option_name,rpc_name)=""
 ; .VFDRET - opt - return result messages
 ;    If $G(VFDRET)'="" then VFDRET = $name value of return array AND
 ;                      no screen writes will be done.
 ;    If $G(VFDRET)="" then passed by reference AND return messages AND
 ;                     write messages via MES^XPDUTL
 ;
 ;------------------ BOOLEAN CHECK IF SYSTEM IS CACHE -----------------
CACHE() Q $G(^%ZOSF("OS"))["OpenM"&($ZV["Cache")
 ;
 ;=====================================================================
 ;                         FILEMAN API WRAPPERS
 ;=====================================================================
 ;----------------------- DELETE NEW STYLE INDEX ----------------------
DDELIXN(FILE,IDX,FLG,VFDM) ;
 I $$RTNTEST("VFDI000A","DDELIXN") D DDELIXN^VFDI000A
 Q
 ; FILE=number  IDX=index name  FLG=see FM docs   .VFDM=message return
 ;
 ;---------------------- DELETE TRADITIONAL INDEX ---------------------
DDELIXT(FILE,FLD,IDXN,IDX,FLG,VFDM) ;
 I $$RTNTEST("VFDI000A","DDELIXT") D DDELIXT^VFDI000A
 Q
 ; FILE=number       FLD=field#           IDX=index name    IDXN=index#
 ; FLG=see FM docs   .VFDM=message return
 ;
 ;------------------ DOES DATA DICTIONARY FIELD EXIST -----------------
DDFIELD(FILE,FLD) ;
 N I,J,X,Y,Z,DIERR
 S X=0 I $G(FLD)>0,$$DDFILE($G(FILE)) S X=$$VFIELD^DILFD(FILE,FLD)
 Q X
 ;
 ;------------------ DOES DATA DICTIONARY FILE EXIST ------------------
DDFILE(FILE) ; Boolean indicates success
 N I,J,X,Y,Z,DIERR
 S X=0 S:$G(FILE)>0 X=$$VFILE^DILFD(FILE)
 Q X
 ;
 ;------------------- DELETE A FILE-DATA-TEMPLATES --------------------
DELFILE(FILE,FLG) ;
 N I,J,X,Y,Z,D0,DA,DIU
 S DIU=$G(DIU),FLG=$G(FLG)
 I FLG'="" S DIU(0)="" F X="D","E","S","T" S:FLG[X DIU(0)=DIU(0)_X
 E  S DIU(0)="DET"
 I DIU=+DIU,$$DDFILE(DIU) D EN^DIU2
 Q
 ;
 ;---------------- RETURN GLOBAL ROOT FOR PARENT FILE -----------------
GLOBROOT(FILE) ; return file's global root or -1 or null
 N I,J,X,Y,Z,DIERR,VFD,VFDER
 D FILE^DID(+$G(FILE),,"GLOBAL NAME","VFD","VFDER")
 S X=$G(VFD("GLOBAL NAME")) S:$D(VFDERR) X=-1
 Q X
 ;
 ;------------- CREATE DD FIELD KIDS EXPORT IN PARENT FILE ------------
KEXPORT(FILE,VFDLIST) ;
 ; Return - Boolean - 1:field created; 0:if not
 ;   if .VFDLIST is passed in then Boolean return indicates total # of
 ;   files updated
 ; 2011.1.2T7 - added support for VFDLIST
 N X I '$$RTNTEST("VFDI000R","KEXPORT") Q 0
 I $G(FILE)>0,'$$DDFILE(FILE) Q 0
 Q $$KEXPORT^VFDI000R(FILE,.VFDLIST)
 ;
 ;=====================================================================
 ;                       KIDS (XPD) WRAPPERS
 ;=====================================================================
 ;-------- LIST OF KIDS INSTALL COMPLETE DATES FOR BUILD NAME ---------
KIDINS(NM,VFDB) ;
 I $$RTNTEST("VFDI000A","KIDINS") Q $$KIDINS^VFDI000A($G(NM),.VFDB)
 Q -1
 ;
 ;------------------ DOES PACKAGE FILE ENTRY EXIST? -------------------
KIDPKIS(NM) ; NM = namespace or package file name; return file 9.4 ien
 Q $$LKPKG^XPDUTL($G(NM))
 ;
 ;----------------- DISPLAY KIDS INSTALLATION MESSAGE -----------------
MSG(VFDM) N I,J,X,Y,Z D MES^XPDUTL(.VFDM) Q
 ;
 ;--------------- ADD OPTION TO MENU OR EXTENDED ACTION ---------------
OPTADD(MENU,OPT,SYN,ORD) ;
 I '$$RTNTEST("VFDI000X","ADD") G NOTVX
 Q $$ADD^VFDI000X($G(MENU),$G(OPT),$G(SYN),$G(ORD))
 ;
 ;------------- DELETE OPTION FROM MENU OR EXTENDED ACTION ------------
OPTDEL(MENU,OPT) ;
 I '$$RTNTEST("VFDI000X","DELETE") G NOTVX
 Q $$DELETE^VFDI000X($G(MENU),$G(OPT))
 ;
 ;---------------------- LOOKUP AN OPTION BY NAME ---------------------
OPTLK(OPT) ;
 I '$$RTNTEST("VFDI000X","LKOPT") G NOTVX
 Q $$LKOPT^VFDI000X($G(OPT))
 ;
 ;--------------- OPTION SET/REMOVE OUT OF ORDER MESSAGE --------------
OPTOOO(OPT,TXT) ;
 I $$RTNTEST("VFDI000X","OUT") D OUT^VFDI000X($G(OPT),$G(TXT))
 Q
 ;
 ;-------------------------- RENAME AN OPTION -------------------------
OPTRENAM(OLD,NEW) ;
 I $$RTNTEST("VFDI000X","RENAME") D RENAME^VFDI000X($G(OLD),$G(NEW))
 Q
 ;
 ;------------------------ CHECK TYPE OF OPTION -----------------------
OPTTYPE(IEN,VAL) ;
 I $$RTNTEST("VFDI000X","TYPE") Q $$TYPE^VFDI000X($G(IEN),$G(VAL))
 Q ""
 ;
 ;=====================================================================
 ;                     APIS FOR HANDLING M ROUTINES
 ;=====================================================================
 ;-------------------- RENAME A ROUTINE AND SAVE IT -------------------
RTNCOPY(FR,TO) ;
 I '$$RTNTEST("VFDI000R","COPYRTN") Q 0
 Q $$COPYRTN^VFDI000R($G(FR),$G(TO))
 ;
 ;------------------ LOAD A ROUTINE USING %ZOSF(LOAD) -----------------
RTNLOAD(ROU,ARR) ;
 I '$$RTNTEST("VFDI000R","LOADRTN") Q 0
 Q $$LOADRTN^VFDI000R($G(ROU),$G(ARR))
 ;
 ;------------------ SAVE A ROUTINE UNDER A NEW NAME ------------------
RTNSAVE(ROU,ARR) ;
 I '$$RTNTEST("VFDI000R","SAVERTN") Q 0
 Q $$SAVERTN^VFDI000R($G(ROU),$G(ARR))
 ;
 ;--------------------- TEST EXISTENCE OF ROUTINE ---------------------
RTNTEST(RTN,TAG) ; Boolean test if routine or tag^routine exists
 Q:$G(RTN)="" 0 N X,Y,Z
 S X=RTN X ^%ZOSF("TEST") E  Q 0
 I $G(TAG)'="",$T(@(TAG_U_RTN))="" Q 0
 Q 1
 ;
 ;=====================================================================
 ;                        VXVISTA SPECIFIC APIS
 ;=====================================================================
 ;-------------  VALIDATE VXVISTA VERSION NUMBER FORMAT  --------------
VALID(V) ; called from input transform on DD(9.6,.01)
 Q $$VALID^VFDI000V
 ;
 ;-----------------  RETURN CURRENT VXVISTA VERSION  ------------------
VER(MAJ) ;
 ; if $G(MAJ) then return only the current system's major version
 ; else return the entire current system's vxVistA version number
 ; or -1^message
 Q $$VER^VFDI000V
 ;
 ;------------------ CHECK FOR VXVISTA VERSION NUMBER -----------------
VERCK(VFDRT,MIN,MAX,WR,MAJ) ;
 Q $$VERCK^VFDI000V
 ;
 ;----------------------  TYPE OF VXVISTA SYSTEM  ---------------------
VX(VAPI,NUM) ; return what type of system this is
 Q $$VX^VFDI000V
 ;
 ;=======================  PRIVATE SUBROUTINES  =======================
NOTVX ; called from several places as exit for an extrinsic function
 Q "-1^vxVistA Open Source not installed"
