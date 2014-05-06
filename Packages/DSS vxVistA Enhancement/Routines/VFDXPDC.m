VFDXPDC ;DSS/SGM - PATCH UTIL HFS ;14 Sep 2010
 ;;3.1;DSS,INC VXVISTA SUPPORTED;;10 Dec 2012;Build 58
 ;Copyright 1995-2012,Document Storage Systems Inc. All Rights Reserved
 ;
 ;
 ;This routine should only be invoked via the ^VFDXPD routine
 ;
 ;ICR #  SUPPORTED REFERENCES
 ;-----  --------------------------------------------------------------
 ; 2320  ^%ZISH: CLOSE, $$DEL, $$FTG, $$GTF, $$LIST, OPEN, $$PWD
 ;
ASKFILE() ;
 ;------------------------  ASK FOR FILENAME  -------------------------
 N X,Z
 S Z(0)="FO^3:80",Z("A")="Enter file name"
 Q $$DIR^VFDXPDA(.Z)
 ;
ASKPATH(DEF) ;
 ;------------------  ASK FOR A PATH OR A DIRECTORY  ------------------
 N I,X,Y,Z
 S Z(0)="FO^3:255",Z("A")="Enter directory name or path"
 S Z("A",1)="Format of path name is not verified as valid"
 S Z("A",2)="Examples:  c:\hfs\   SPL$:[SPOOL]"
 S Z("A",3)="",Z("B")=$S($G(DEF)'="":DEF,1:$$DEF)
 Q $$DIR^VFDXPDA(.Z)
 ;
CLOSE(HANDLE) ;
 ;------------------------  CLOSE A HFS FILE  -------------------------
 S HANDLE=$G(HANDLE) I HANDLE'="" D CLOSE^%ZISH(HANDLE)
 Q HANDLE'=""
 ;
 ;--------------------  VXVISTA DEFAULT HFS PATH  ---------------------
DEF() Q $$PWD^%ZISH
 ;
DEL(PATH,VXFLES) ;
 ;-----------------------  DELETE HFS FILE(S)  ------------------------
 ; .VXFLES - req - list of files to be deleted, must be full filename
 I $G(PATH)=""!($O(VXFLES(0))="") Q -1
 Q $$DEL^%ZISH(PATH,"VXFLES")
 ;
FILELIST(VFDRTN,PATH,VFDEXT,FLAGS,VFDFILES,VFDERR) ;
 ;--------  GET LIST OF HFS FILES WITH FILTERING AND SORTING  ---------
 ;Extrinsic function returns total number of files found
 ; .VFDRTN - return array if no errors encountered
 ;    return array format affected by value(s) in FLAGS
 ;    If FLAGS["S" then VFDRTN(full_filename)=upper case filename where
 ;         full_filename is case sensitive
 ;    Else VFDRTN(filename_stub,file_extension)=actual filename where
 ;         filename_stub - name portion of file w/o extension (UC)
 ;         file_extension - UC file extension
 ;
 ; .VFDERR - return array if errors encountered VFDERR(n) = message
 ;
 ;   PATH - opt - default to vxVistA HFS default
 ;
 ;  .VFDEXT - opt - list of file extensions - filter files based upon
 ;                  the UC extension is found in this list
 ;
 ;  FLAGS - opt - string of codes that will affect the behavior and the
 ;                format of the output array
 ;                Default to a value of DM
 ;  FLAGS["D" - if .DAT file exists, then no .TXT or .KID file allowed
 ;        "M" - no multiple file names allowed (case insensitive)
 ;        "S" - see .VFDRTN
 ;
 ; .VFDFILES - opt - list of allowable filenames to be retrieved
 ;                FLIST(name)="" - if name ends in "*" then only those
 ;                files found whose name matches that first portion
 ;                will be returned.
 Q $$FILELIST^VFDXPDC1
 ;
FTG(PATH,FILE,ROOT) ;
 ;-----------------------  RETRIEVE A HFS FILE  -----------------------
 ; ROOT - req = $NAME value of variable to place file in
 ; subscript will be calculated, assumes inc last subscript
 N X,Y,Z,INC
 S X="Missing required input parameter(s)"
 I $G(PATH)=""!($G(FILE)="")!($G(ROOT)="") Q X
 S INC=$QL(ROOT),X=$$FTG^%ZISH(PATH,FILE,ROOT,INC)
 I 'X S X="Failed to retrieve file"
 Q X
 ;
GTF(PATH,FILE,ROOT) ;
 ;-------------------  SAVE AN ARRAY AS A HFS FILE  -------------------
 ; ROOT - req - $NAME value of variable to place file in
 ; subscript will be calculated, assumes inc last subscript
 N X,Y,Z,INC
 S X="Missing required input parameter(s)"
 I $G(PATH)=""!($G(FILE)="")!($G(ROOT)="") Q X
 S INC=$QL(ROOT),X=$$GTF^%ZISH(ROOT,INC,PATH,FILE)
 I 'X S X="Failed create HFS file"
 Q X
 ;
LIST(PATH,LIST,VFDR) ;
 ;------------------  GET LIST OF HFS FILES IN PATH  ------------------
 ; PATH - req
 ; LIST - opt - %ZISH param for files to get [$NAME value]
 ;   if $G(LIST)="" then LIST() can be passed by reference for list of
 ;      files to get.
 ;   if $G(LIST)="",$O(LIST(""))="" then get all files whose name
 ;      starts with a alpha character.
 ; VFDR - if passed by named reference, then return @VFDR@()
 ;        if passed by reference (i.e, .VFDR), then return .VFDR()
 ;
 N I,X,Y,Z,VFDRET
 I $G(PATH)="" Q -1
 ;S LIST("*")="",LIST="LIST"
 I $G(LIST)="" S LIST="LIST" D
 .F I=65:1:96 S LIST($C(I)_"*")="",LIST($C(I+32)_"*")=""
 .Q
 S X=$$LIST^%ZISH(PATH,LIST,"VFDRET")
 I $G(VFDR)="" M VFDR=VFDRET
 I $G(VFDR)'="" M @VFDR=VFDRET
 Q X
 ;
OPEN(PATH,FILE,HANDLE,MODE) ;
 ;-------------------  OPEN A HFS FILE WITH HANDLE  -------------------
 ; return 1 if file successfully opened, else return 0
 ;        -1^msg if problems
 ; HANDLE - req - unique name you identify for this file
 ;   MODE - opt - mode to open the file - default to W
 ;                (W)rite, (R)ead, (A)ppend, (B)lock
 N I,X,Y,Z,POP
 S HANDLE=$G(HANDLE),MODE=$G(MODE) I MODE="" S MODE="W"
 I $G(FILE)="" Q "-1^No file name received"
 I HANDLE="" Q "-1^A device handle name is required"
 D OPEN^%ZISH(HANDLE,PATH,FILE,MODE)
 Q POP
 ;
 ;---------------------------------------------------------------------
ERR(A) ;
 Q "-1^"_$P($T(ERR+A),";",3)
 ;
PATH S:$G(PATH)="" PATH=$$DEF Q
UP(X) Q $$UP^XLFSTR(X)
