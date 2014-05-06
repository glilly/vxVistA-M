VFDXPD0 ;DSS/SGM - COMMON APIS FOR VFDXPD ; 10/19/2011 16:20
 ;;3.1;DSS,INC VXVISTA SUPPORTED;;10 Dec 2012;Build 58
 ;Copyright 1995-2012,Document Storage Systems Inc. All Rights Reserved
 ;
 ;This routine should only be invoked via the VFDXPD routine.
 ;It contains abbreviated entry points for common modules called more
 ;than once from various options.  Thus one only has to come to this
 ;routine rather than searching for the API in the other VFDXPD*
 ;routines.  The detailed explanation of the input params will be in
 ;those other routines.
 ;
 ;===================================
 ;   % Z I S H   U T I L I T I E S
 ;===================================
 ; root - array holding file content where last subscript increments
 ; PATH    - prompt user for path where the files reside
 ; DEL     - delete list of files in VXFLES()
 ; FTG     - move HFS file contents to an array
 ; GTF     - moves array contents to a HFS file
 ; PATHDEF - sets PATH = vxVistA default path
DEL(PATH,VXFLES) Q $$DEL^VFDXPDC($G(PATH),.VXFLES)
FTG(PATH,FILE,ROOT) Q $$FTG^VFDXPDC($G(PATH),$G(FILE),$G(ROOT))>0
GTF(PATH,FILE,ROOT) Q $$GTF^VFDXPDC($G(PATH),$G(FILE),$G(ROOT))>0
PATH S PATH=$$ASKPATH^VFDXPDC K:PATH=""!+PATH PATH Q
PATHDEF S:$G(PATH)="" PATH=$$PWD^%ZISH Q
 ;
 ;====================================================
 ;   H A N D L I N G   K I D S   H F S   F I L E S
 ;====================================================
 ;   
FILETYPE(LOC,VFDRT) ; Determine Type of KIDS HFS File
 ; @loc@(n) contains the content of the HFS file
 Q $$FILETYPE^VFDXPDF1($G(LOC),.VFDRT)
 ;
FLIST(VFDLIST,PATH,DATONLY,VFDXERR) ; Get List of KIDS HFS Files
 ; Based upon specific file extensions
 ; Return .VFDLIST(filename_root,file_extension)=full filename
 ;  Or errors in VFDXERR()
 D FLIST^VFDXPD01 Q
 ;
 ;===================================
 ;   X P D I D   U T I L I T I E S
 ;===================================
 ;   allows you to invoke the KIDS progress bar outside of KIDS
 ;     DSP - initializes progress screen and writes Title
 ; DSPEXIT - invoke at end to clean up and reset screen
 ;  DSPUPD - update the progress bar % complete and do writes to screen
INIT(T) W @IOF D INIT^VFDXPDU,TITLE^VFDXPDU(T) W ! Q
EXIT D EXIT^VFDXPDU() Q
UPD(TXT,CNT,TOT,TAB) ;
 I $G(TXT)'=""  W:'$G(TAB) ! W:$G(TAB) ?TAB W TXT
 D UPDATE^VFDXPDU(CNT,TOT) Q
 ;
 ;===================================================
 ;   F I L E S   2 1 6 9 2 *   P R O C E S S I N G
 ;===================================================
BATCH(VFDBATCH,PID,LISTONLY) ; Get KIDS Builds in a Processing Group
 Q $$BATCH^VFDXPDB(.VFDBATCH,$G(PID),$G(LISTONLY))
 ;
BATCHNM(PID) ; get batch name ^ batch date OR -1^msg
 Q $$BATCHNM^VFDXPDB($G(PID))
 ;
FINDBLD(VFDNAME) ; Find/Add Stub Record in File 21692
 ;extrinsic function returns
 ;  ien if file exists  OR  ien^name if file added  OR  error msg
 Q $$FINDBLD^VFDXPD01
 ;
GETREC(IEN,VFDRR) ; Get build data from file 21692
 I $G(VFDRR)="" Q $$GETREC^VFDXPDB($G(IEN))
 D GETREC^VFDXPDB($G(IEN),VFDRR)
 Q
 ;
PID(EDIT,SCR,VNEW) ; Find/Add a Batch Processing Group
 Q $$PID^VFDXPD01(EDIT,SCR,VNEW)
 ;
STAT(IEN,VAL) ; get build status, return single letter status
 Q $$STAT^VFDXPD01($G(IEN),$G(VAL))
 ;
 ;==================================================================
 ; U T I L I T I E S   D E A L I N G   W I T H   B U I L D S (#9.7)
 ;==================================================================
INSTLIST(VFDAX,VFDNM,ACT,FLGS,FILT) ; FIND INSTALLS FOR A BUILD NAME
 Q $$INSTLIST^VFDXPD01()
 ;
LAST(VFDBLD,VFDNM,LAST) ; GET LAST INSTALL FOR A BUILD
 ; VFDNM = Build name or INSTALL ien
 ; .VFDBLD return array
 G LAST^VFDXPD01
 ;
PARSENM(VFDNM,FLG) ; PARSE A BUILD NAME INTO ITS COMPONENTS
 ; may be called as extrinsic function or a D w/param .VFDNM
 ; FLG - opt - 10/19/2011/sgm - flg changed, implemented $QUIT
 G PARSENM^VFDXPD01
 ;
STATUS(VFDSTAT) ; get meaning of Install STATUS
 D STATUS^VFDXPD01(.VFDSTAT)
 Q
 ;
 ;===============================
 ;   M I S C E L L A N E O U S
 ;===============================
DIR(LINE) ; calls the DIR prompter
 S LINE=$G(LINE) G DIR^VFDXPD2
 ;
HTFM(DATE) Q $$HTFM^VFDXPD01(DATE)
 ;
OUT() Q $$OUT^VFDXPD01
 ;
RPT(RPT,OUT,TXT) ; ask for output device and write RPT
 ; choose between browser, terminal, or hfs
 ; .RPT - req - RPT(n)=text
 ; .OUT - opt - 1:browser; 2:terminal; 3:hfs
 ;              both an input and output param
 ;  TXT - opt - text to display if there is no data in RPT()
 G ASKRPT^VFDXPD01
 ;
TAG(TAG,SP,WR,VFDTXT) ; return text in vfdtxt()
 ; TAG - req - line label in VFDXPD1 that holds the text
 ;  SP - opt - Boolean to determine is 3 spaces added to start of text
 ;  WR - opt - Boolean, if true then write and do not return .VFDTXT
 ;.VFDTXT(n)=text  for n=1,2,3,4,...
 I $G(TAG)'="" S SP=$G(SP),WR=$G(WR) D EN^VFDXPD1
 Q
 ;
UP(X) Q $S(X'?.E1L.E:X,1:$$UP^XLFSTR(X))
