VFDXTRU2 ;DSS/SGM - ROUTINE UTILITIES ; 06/21/2011 18:25
 ;;2.0;DSS,INC VXVISTA OPEN SOURCE;;29 Jul 2011;Build 92
 ;Copyright 1995-2011,Document Storage Systems Inc. All Rights Reserved
 ;
 ;THIS ROUTINE SHOULD ONLY BE INVOKED VIA THE VFDXTRU ROUTINE
 ;
 ; ICR#  Supported References
 ;-----  -----------------------------------
 ; 2320  ^%ZISH: $$FTG, $$GTF, $$LIST, $$PWD
 ;10104  $$UP^XLFSTR
 ;---------------------------------------------------------------------
 ;                            %ZISH Wrapper
 ;---------------------------------------------------------------------
FTG(PATH,FILE,ROOT,INC) ; move HFS file to a global
 ; ROOT - opt - $NAME value to place file in
 ;              default to ^TMP("VFDXTR",$J,1) and initialize it
 ;  INC - opt - node in ROOT to be incremented; default to $QL(ROOT)
 ;Return 1 if successful, 0 if not successful, or -1^message
 N I,X,Y,Z
 S X=$$ZINIT(12) I X<0 Q X
 Q $$FTG^%ZISH(PATH,FILE,ROOT,INC)
 ;
GTF(PATH,FILE,ROOT,INC) ; move array to HFS file
 ; ROOT - req - $NAME value which holds data for file
 ;  INC - opt - the node in ROOT to be incremented
 ;              default to $QL(ROOT)
 ;Return 1 if successful, 0 if not successful, or -1^message
 N I,X,Y,Z
 S X=$$ZINIT(123) I X<0 Q X
 Q $$GTF^%ZISH(ROOT,INC,PATH,FILE)
 ;
LIST(PATH,VFLIST,VFRET) ; call list^%zish
 ;
 ; Get list of files or just check for the existence of a single file
 ; .vflist - opt - list of hfs files to get.  vflist(name)="" where
 ;           name is any acceptable value for list^%zish
 ;           name=full_hfs_filename
 ;           name=<char(s))_"*" eg. vflist("C*")
 ;           if vflist=filename, then look for that filename only
 ;              in this case, vfret need not be passed in
 ;           default to vflist("*") if no value passed in
 ;  vfret - opt - $name of array in which to return files found
 ;
 ;Extrinsic function returns
 ;   1 if file(s) found, else 0 or 0^msg or -1^msg
 ;
 N I,X,Y,Z,VLIST,VFDZ
 S X=$$ZINIT(1) I X<0 Q X
 I $G(VFLIST)'="" S VLIST(VFLIST)=""
 E  M VLIST=VFLIST
 I '$D(VLIST) S VLIST("*")=""
 I $G(VFRET)="" S VFDRET="VFDZ"
 S X=$$LIST^%ZISH(PATH,"VLIST",VFDRET)
 I $G(VFLIST)'="",$D(@VFDRET@(VFLIST)) S X=1
 Q X
 ;
LIST1(VFDV,PATH,EXT,FILES,CASE) ; get list of files
 ;
 ;  PATH - req - folder or directory where hfs files reside
 ;  .EXT - opt - passed by reference, filter return values by filename
 ;               extension where EXT(filename_extension)=""
 ;.FILES - opt - list of specific filenames to check for.  If this is
 ;               passed in, then ignore .EXT.  FILES(filename)=""
 ;  CASE - opt - Boolean flag indicating whether or not to treat the
 ;               hfs filenames as case sensitive or not.  1 means case
 ;               sensitive.  0 means case insensitive.  Default is 0
 ;RETURN:
 ; Extrinsic function returns total number of files found or -1^msg
 ; @VFDV@(<upper_filename_stub>,<upper_filename_ext>,filename)=1 or ""
 ;   equals 1 if filename matched case sensitive input criteria, else
 ;   equals "" if filename matched case insensitive input criteria
 ;   $QS(,3) = actual filename
 ;   filename stub is that portion of filename w/o the file extension
 ;   extension will be " " if filename has no extension
 ;
 N A,B,I,L,X,Y,Z,EX,FX,RETX,TMP,TOT,VTMP,VFDZ
 S X=$$ZINIT(1) I X<0 Q X
 I $G(VFDV)="" Q 0
 S RETX=$NA(^TMP("VFDXTRU2",$J)) K @RETX
 S VFDZ("*")="",X=$$LIST(PATH,"VFDZ",$NA(@RETX@(1)))
 S TOT=0,X="",CASE=$G(CASE)
 I $D(FILES) S X="" D
 .F  S X=$O(FILES(X)) Q:X=""  S TMP(1,X)="" S:'CASE TMP(2,$$UP(X))=""
 .Q
 I $D(EXT) S X="" D
 .F  S X=$O(EXT(X)) Q:X=""  S TMP(3,X)="" S:'CASE TMP(4,$$UP(X))=""
 .Q
 S X="" F  S X=$O(@RETX@(X)) Q:X=""  D
 .S L=$L(X,".")
 .I L=1 S FX=X,FX(0)=$$UP(X),EX=" ",EX(0)=" "
 .E  S FX=$P(X,".",1,L-1),EX=$P(X,".",L),FX(0)=$$UP(FX),EX(0)=$$UP(EX)
 .S FX(1)=FX(0)_"."_EX(0),FX(2)=FX(0)_U_EX(0)
 .I '$D(TMP(1)),'$D(TMP(3)) S @RETX@(2,X)=FX(2) Q
 .I $D(TMP(1,X))!$D(TMP(2,FX(1))) D  Q
 ..I $D(TMP(1,X)) S @RETX@(2,X)=FX(2)  ; exact match on filename
 ..E  S @RETX@(3,X)=FX(2)  ; uppercase filename matches
 ..Q
 .I $D(TMP(3,EX))!$D(TMP(4,EX(0))) D
 ..I $D(TMP(3,EX)) S @RETX@(2,X)=FX(2)
 ..E  S @RETX@(3,X)=FX(2)
 ..Q
 .Q
 S X="" F  S X=@O(@RETX@(2,X)) Q:X=""  S Y=^(X) D LISTSET(X,Y,1)
 S X="" F  S X=$O(@RETX@(3,X)) Q:X=""  S Y=^(X) D
 .Q:$D(@RETX@(2,X))  Q:$D(@VFDV@($P(Y,U),$P(Y,U,2),X))
 .D LISTSET(X,Y,"")
 .Q
 Q TOT
 ;
PATH() Q $$PWD^%ZISH
 ;
 ;-----------------------  PRIVATE SUBROUTINES  -----------------------
 ;
ERR(A) ;
 N T
 I A=1 S T="KIDS Build file with ien "_SOURCE_" not found"
 I A=2 S T="Error getting data from Build record number "_SOURCE
 I A=3 S T="No routines found in KIDS Build IEN: "_SOURCE
 I A=4 S T="No value for path received"
 I A=5 S T="No host files server (HFS) name received"
 I A=6 S T="No value for the ROOT parameter received"
 I A=7 S T="No return variable name received"
 I A=8 S T="No filename received to validate it existence in folder"
 Q "-1^"_T
 ;
LISTSET(X,Y,A) S @VFDV@($P(Y,U),$P(Y,U,2),X)=A,TOT=TOT+1 Q
 ;
UP(A) S A=$G(A) S:A?.E1L.E A=$$UP^XLFSTR(A) Q A
 ;
ZINIT(A) ;
 S A=$G(A)
 I A[1,$G(PATH)="" Q $$ERR(4)
 I A[2,$G(FILE)="" Q $$ERR(5)
 I A'[3,$G(ROOT)="" S ROOT=$NA(^TMP("VFDXTR",$J,1)),INC=3 K @ROOT
 I A[3,$G(ROOT)="" Q $$ERR(6)
 I $G(INC)="" S INC=$QL(ROOT)
 Q 1
