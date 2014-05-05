VFDXPDP1 ;DSS/SGM - FILE UTILITIES FOR PATCH PROGRAM
 ;;3.1;DSS,INC VXVISTA SUPPORTED;;10 Dec 2012;Build 58
 ;Copyright 1995-2012,Document Storage Systems Inc. All Rights Reserved
 ;
 ;This routine is invoked only via the VFDXPDP routine
 ;ICR#  Supported References
 ;----  ---------------------------------------
 ;      UP^XLFSTR
 ;      %ZISH: DEFDIR, $$FTG, $$GTF,$$LIST
 ;
 ;=========================  GET FILE  =================================
FTG(PATH,FILE,TARG) ;
 ; PATH - req - path where the file resides
 ; FILE - req - filename to get
 ; TARG - req - $NA() of target array to place the file
 ; Return 1 if successful, else return 0
 Q:$G(FILE)="" 0
 Q:$G(FILE)="" 0
 Q:$G(TARG)="" 0
 N I,X,Y,Z
 ; target in form array(s1,s2,...,sn) where ^(sn)=line from file
 Q $$FTG^%ZISH(PATH,FILE,TARG,$QL(TARG))
 ;
GTF(PATH,FILE,ARR) ;
 ; see FTG for input params, ARR = array where data resides to file
 ; Return 1 if successful, else return 0
 Q:$G(FILE)="" 0
 Q:$G(FILE)="" 0
 Q:$G(ARR)="" 0
 N I,X,Y,Z
 Q $$GTF^%ZISH(ARR,$QL(ARR),PATH,FILE)
 ;
 ;============  GET LIST OF DAT,KID,TXT HFS FILES IN PATH  =============
LIST(VLIST,PATH,SORTBY,FILT) ;
 ; Return: extrinsic function - # total files found or -1^message
 ;   PATH - req - Directory where HFS files are to be found
 ; SORTBY - opt - N:entire filename  F:filename,extension
 ;                E:extension,filename - default to F
 ;  [.]FILT - opt - FILT(extension)=""
 ;   filter HFS file list to only return files with those extensions
 ;   if FILT'="" then S FILT(FILT)=""
 ; VLIST() - return array format determined by SORTBY
 ;   VLIST(p1,p2) where both p1 and p1 will be uppercase
 ;   If N then return VLIST(full filename)=actual filename
 ;   If F then VLIST(filename,extension)=actual filename^upper filename
 ;   If E then VLIST(extension,filename)=actual filename^upper filename
 ;
 ; NOTE: If two filenames found exactly the same (e.g., lower case name
 ;          and uppercase name) then error condition
 ;       If SORTBY'="N" and then there is no file extension, then use
 ;          " " (space) as the extension subscript in VLIST()
 ;
 N I,J,X,Y,Z,CNT,ERR,EXT,FNM,TMP,VTMP
 I $G(PATH)="" Q "-1^No path received"
 I $G(FILT)'="" S FILT(FILT)=""
 S X="" F  S X=$O(FILT(X)) Q:X=""  I X?.E1L.E K FILT(X) S X=$$UP(X),FILT(X)=""
 S X=$E($G(SORTBY)) S:X="" X="F" S:X?1L X=$$UP(X)
 I "EFN"'[X Q "-1^Invalid sortby input parameter received"
 S SORTBY=X,X=""
 F  S X=$O(FILT(X)) Q:X=""  I X?.E1L.E K FILT(X) S FILT($$UP(X))=""
 S TMP("*")="",X=$$LIST^%ZISH(PATH,"TMP","VTMP")
 I 'X Q 0
 S CNT=0,(X,ERR)="" F  S X=$O(VTMP(X)) Q:X=""  D  Q:ERR'=""
 .S Y=X I X?.E1L.E S Y=$$UP(X)
 .S J=$L(Y,".") S:J=1 J=2
 .S FNM=$P(Y,".",1,J-1),EXT=$P(Y,".",J) S:EXT="" EXT=" "
 .I $O(FILT(""))'="" Q:'$D(FILT(EXT))
 .I $D(VLIST(Y))!$D(VLIST(FNM,EXT)) D  Q
 ..K VLIST S ERR="-1^Duplicate file names found"
 ..Q
 .S CNT=CNT+1
 .I SORTBY="N" S VLIST(Y)=X
 .I SORTBY="F" S VLIST(FNM,EXT)=X_U_Y
 .I SORTBY="E" S VLIST(EXT,FNM)=X_U_Y
 .Q
 Q $S(ERR'="":ERR,1:CNT)
 ;
 ;=================== RETURN PATH - PROVIDE DEFAULT ===================
PATH(P) ; default path for HFS files OR validate path
 ; P - opt - path to be validated, if null ask for path
 ; return path or null
 Q $$DEFDIR^%ZISH($G(P))
 ;
 ;-----------------------  PRIVATE SUBROUTINES  -----------------------
UP(T) Q $$UP^XLFSTR(T)
