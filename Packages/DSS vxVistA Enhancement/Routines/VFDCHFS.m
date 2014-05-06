VFDCHFS ;DSS/SGM - HOST FILE UTILITIES ;05/03/2007 22:26
 ;;2009.2;DSS,INC VXVISTA OPEN SOURCE;;01 Dec 2009
 ;Copyright 1995-2009,Document Storage Systems Inc. All Rights Reserved
 ;
 ;ATTENTION: the only supported entry points for the VFDCHFS*
 ;routines are in this routine only.
 ;
 ;This routine contains various entry points for handling HFS files.
 ;It can accomodate calling a VistA option that expects to write to a
 ;printer or device.
 ;=================================================================
 ;Most APIs in this routine must be called as an extrinsic function
 ;=================================================================
 ;DESCRIPTION OF INPUT PARAMETERS:  see INIT^VFDCHFS0 subroutine
 ;VFDCHFS return parameter described:
 ;  This is the $NAME value of the variable (global or local) that
 ;  the results will be returned if appropriate.
 ;  @VFDCHFS@(#)=value
 ;=================================================================
 ;WARNING: every call, except the ASK calls, will set VFDCMSG. Some
 ;calls will call one or more of the other calls.
 ;=================================================================
 ;Edit History
 ; 2/22/2006
 ;  1. change ext fun calls to VFDCHFS1 to a DO call
 ;  2. Use of VFDCMSG - change made to make troubleshooting easier
 ;     when errors occur.
 ;  3. Error trap set only once to avoid infinite looping in error
 ;     trap
 ; 3/17/2006
 ;  1. Change input return array name in FTG and GET - always pass
 ;     named root in VFDCHFS such that @vfdchfs@(n) will be returned
 ;  2. INC input parameter no longer recognized
 ;
 ;This routine documents all IAs referenced in all VFDCHFS* routines
 ;DBIA#  Supported Reference
 ;-----  ------------------------------------------------------------
 ; 1621  ^%ZTER, UNWIND^%ZTER
 ; 2119  ^%ZISUTL: CLOSE, OPEN, USE
 ; 2320  ^%ZISH: CLOSE, DEL, FTG, LIST, OPEN, PWD
 ; 3156  $$CRC32^XLFCRC
 ;10010  EN1^DIP
 ;10026  ^DIR
 ;10089  ^%ZISC
 ;10104  $$UP^XLFSTR
 ;10097  $$EC^%ZOSV
 ;
ASKFILE() ;  interactive entry to prompt for file name
 ; file not verified as to whether it exists or not
 ; return user input or <null>
 N VFDCMSG D ASKFILE^VFDCHFS1
 Q VFDCMSG
 ;
ASKPATH() ;  interactive entry to prompt for path name
 ; syntax of path is not verified
 ; return user input or <null>
 N VFDCMSG D ASKPATH^VFDCHFS1
 Q VFDCMSG
 ;
CLOSE ;  assumes you opened a HFS file using OPEN subroutine
 ; for backward compatibility, the variable HANDLE can be set prior
 ; to calling this line tag CLOSE.
 N VFDCMSG,HANDLE
 D INIT("HANDLE","CLOSE")
 D CLOSE^VFDCHFS1
 Q
 ;
DEL(PATH,VFDDEL,FUN) ;  delete file(s)
 ; Return 1 if file(s) deleted, 0 if one or more files not deleted
 ; [.]VFDDEL - file or list of files to be deleted
 ; VFDDEL=file_name or VFDDEL(file_name)="" or
 ; VFDDEL(file_name_stub_"*")=""
 ;
 ;Need to call $$LIST for VMS systems to avoid an error.
 ;If you pass $$LIST^%ZISH an exact filename then it wlll return all
 ;the versions of that filename, i.e., filename.ext;v.  Otherwise,
 ;without the version number, the delete file call fails
 ;
 N VFDCMSG
 D INIT("FUN^PATH","DEL")
 I $G(VFDDEL)'="" S VFDDEL(VFDDEL)=""
 I $O(VFDDEL(""))="" D ERR(1)
 I 'VFDCMSG D DEL^VFDCHFS1
 Q:$G(FUN) VFDCMSG
 Q
 ;
DELALL(PATH) ;  delete all files starting with VFDC
 ;  PATH - opt
 ;  Return 1 if file(s) deleted, 0 if at least one failure
 N VFDCMSG
 D INIT("PATH","DELALL")
 D DELALL^VFDCHFS1
 Q VFDCMSG
 ;
FTG(VFDCHFS,INPUT) ; get HFS file
 ; Return 1 if successful
 ;        0 if data returned in VFDCHFS but file not deleted
 ;       -1^msg if problem
 ; NOTE: it is the calling program's responsibility to kill the
 ; return array of data prior to calling this API.
 N CTRL,DEL,VFDCMSG,FILE,INC,PATH
 D INIT(.INPUT,"FTG",1,1)
 I +VFDCMSG D SET Q VFDCMSG
 D FTG^VFDCHFS1
 Q VFDCMSG
 ;
GET(VFDCHFS,INPUT) ; multifunction API
 ; OPEN file, run a M routine, CLOSE file, MOVE file to @VFDCHFS
 ; Return file_name if process successful, else return -1^msg
 ; Note: if RTN="EN1^DIP" then ^DIP will do its own OPEN command.  So
 ;   set up %ZIS(),IOP.  It is the calling program's responsibility
 ;   to set up all the Fileman input local variables except for IOP
 N CTRL,DEL,VFDCMSG,FILE,MODE,PATH,RTN,VPG,VRM
 D INIT(.INPUT,"GET",1)
 I +VFDCMSG D SET Q VFDCMSG
 I $G(RTN)="" D ERR(2),SET Q VFDCMSG
 D GET^VFDCHFS1
 Q VFDCMSG
 ;
LIST(PATH,FILE,VFDCIN,VFDCOUT) ; return file names or verify file exists
 ; Return 1 if successful, 0 if unsuccessful, -1 or -1^msg for error
 ; INPUT DEFINITIONS
 ;   If FILE is <null> then VFDCIN or .VFDCIN() must be passed
 ;   If $D(VFDCIN)=0 then FILE must be defined
 ;   FILE or VFDCIN or subscripts of VFDCIN() must be full file names
 ;    or file_name_stub_"*"
 ; RETURN DEFINITIONS
 ;   .VFDCOUT() - opt - passed by reference - return array of file
 ;                names found in directory defined in PATH
 N VFDCMSG
 I $G(FILE)'="" S VFDCIN(FILE)="" K FILE
 I $G(VFDCIN)'="" S VFDCIN(VFDCIN)=""
 D INIT("PATH","LIST")
 I $O(VFDCIN(""))="" D ERR(5)
 I 'VFDCMSG D LIST^VFDCHFS1
 Q VFDCMSG
 ;
OPEN(PATH,FILE,MODE,VRM,VPG) ;  open a HFS file and USE it
 ;Return File_name (without path attached) if successfully open file,
 ;   else return -1 or -1^message
 N VFDCMSG
 D INIT("FILE^HANDLE^MODE^PATH^VPG^VRM","OPEN")
 D OPEN^VFDCHFS1
 Q VFDCMSG
 ;
STRIP(ROOT) ;  strip control characters from data in ROOT
 ; ROOT - req - $NAME of array where data is stored
 ; If data contains <TAB>, replace with 1-8 spaces
 ; Not an extrinsic function call
 D STRIP^VFDCHFS1($G(ROOT))
 Q
 ;
VER(PATH,FILE) ;  verify that file exists in path
 ;RETURN: 1 if file exists; 0 if it does not; -1^error message
 N VFDCMSG
 D INIT("FILE^PATH","VER",,1)
 I 'VFDCMSG D VER^VFDCHFS1
 Q VFDCMSG
 ;
 ;---------- private subroutines ----------
ERR(A) ; error messages
 ;;No list of file(s) to delete received
 ;;No routine name to run was received
 ;;No file name received
 ;;No return array name received
 ;;No file name or list of files received
 ;;Expected a file name, but file not found
 S VFDCMSG="-1^"_$P($T(ERR+A),";",3)
 Q
 ;
INIT(ARR,TAG,RETREQ,FILEREQ) ; parse input params and initialize
 D INIT^VFDCHFS0
 Q
 ;
SET S:$G(VFDCHFS)'="" @VFDCHFS@(1)=VFDCMSG Q
