VFDXPDC1 ;DSS/SGM - PATCH UTIL HFS SUPPLEMENTAL ;14 Sep 2010
 ;;3.1;DSS,INC VXVISTA SUPPORTED;;10 Dec 2012;Build 58
 ;Copyright 1995-2012,Document Storage Systems Inc. All Rights Reserved
 ;
 ;This routine should only be called from ^VFDXPDC
 ;
FILELIST() ; GET LIST OF HFS FILES WITH FILTERING AND SORTING
 ;Extrinsic function returns total number of files found
 ; .VFDRTN - return array if no errors encountered
 ;    return array format affected by value(s) in FLAGS
 ;    If FLAGS["S" then VFDRTN(full_filename)=upper case filename where
 ;         full_filename is case sensitive
 ;    Else VFDRTN(filename_stub,file_extension)=actual filename where
 ;         filename_stub - name portion of file w/o extension (UC)
 ;         file_extension - UC file extension
 ;
 N A,B,I,J,L,X,Y,Z,EX,NM,VFILES,VLIST
 S FLAGS=$G(FLAGS) I FLAGS="" S FLAGS="DM"
 I $G(PATH)="" N PATH D PATH^VFDXPDC
 ; get files passing in file list filter
 S X=$$LIST^VFDXPDC(PATH,.VFDFILES,.VLIST) I 'X Q 0
 ; filter list of files based upon extension
 I $O(VFDEXT(""))'="" I '$$FILT1(.VLIST,.VFDEXT) Q 0
 ;
 ; create VLIST(0,FILENAME,EXT)=count^actname1;actname2;...
 S X=0 F  S X=$O(VLIST(X)) Q:X=""  D
 .S (Y,NM)=$$UP(X),L=$L(Y,"."),EX=" ",VLIST(X)=Y
 .I L>1 S EX=$P(Y,".",L),NM=$P(Y,".",1,L-1)
 .S A=$G(VLIST(0,NM,EX)),B=$P(A,U,2),B=$S(B="":X,1:X_"+"_B)
 .S VLIST(0,NM,EX)=(1+A)_U_B
 .Q
 ;
 ; apply other filters based upon flags
 I FLAGS["M" D FILT2(.VLIST)
 I FLAGS["D" D FILT3(.VLIST)
 I $D(VFDERR) Q 0
 I $O(VLIST(0))="" Q 0
 ;
 ; set up return array
 S (X,L)=0
 I FLAGS'["S" S Z="VLIST(0)" F  S Z=$Q(@Z) Q:Z=""  Q:$QS(Z,1)'=0  D
 .S L=L+1,VFDRTN($QS(Z,2),$QS(Z,3))=$P(@Z,U,2)
 .Q
 E  F  S X=$O(VLIST(X)) Q:X=""  S L=L+1,VFDRTN(X)=VLIST(X)
 Q L
 ;
FERROR(B) ;
 ;;Multiple HFS files found with the same name
 ;;One of more .DAT files found with existing .TXT or .KID files
 S N=N+1 S:B'=+B B="   "_B
 S:B=+B B=$P($T(FERROR+B),";",3) S VFDERR(N)=B
 Q
 ;
FILT1(LIST,EXT) ; filter list of filenames based upon extension
 ;Extrinsic function return Boolean, file list still exist or not
 ; if extension passed, then K LIST(file) if it has invalid extension
 ; .LIST - list(filename)
 ;  .EXT - ext(name)="" - extension_name case insensitive 
 N I,L,X,Y,Z,EX
 S X="" F  S X=$O(EXT(X)) Q:X=""  S EX($$UP(X))=""
 I $D(EX) S X=0 F  S X=$O(VLIST(X)) Q:X=""  D
 .S Y=$$UP(X) S L=$L(Y,"."),EX=" " S:L>1 EX=$P(Y,".",L)
 .I '$D(EX(EX)) K VLIST(X)
 .Q
 Q $O(LIST(""))'=""
 ;
FILT2(LIST) ; filter list of duplicate case insensitive filenames
 ;Extrinsic function return Boolean, file list still exist or not
 ;This will set the VFDERR() for any errors found
 ; .LIST - expects LIST(0) - see FILELIST
 N A,I,N,T,X,Y,Z
 S N=+$O(VFDERR(0)),(T,X)=0
 F  S X=$O(LIST(0,X)) Q:X=""  S Y=0 D
 .F  S Y=$O(LIST(0,X,Y)) Q:Y=""  I LIST(0,X,Y)>1 D
 ..S T=T+1 D:T=1 FERROR(1) S Z=X_"."_Y D FERROR(Z)
 ..S Z=$P(LIST(0,X,Y),U,2)
 ..F I=1:1:$L(Z,"+") S A=$P(Z,"+",I) K:A'="" LIST(A)
 ..Q
 .Q
 Q
 ;
FILT3(LIST) ; filter list - if DAT file exists, then no TXT/KID files
 ;Extrinsic function return Boolean, file list still exist or not
 ;This will set the VFDERR() for any errors found
 ; .LIST - expects LIST(0) - see FILELIST
 N A,I,N,T,X,Y,Z
 S N=+$O(VFDERR(0)),(T,X)=0
 F  S X=$O(LIST(0,X)) Q:X=""  I $D(LIST(0,X,"DAT")) D
 .I '$D(LIST(0,X,"TXT")),'$D(LIST(0,X,"KID")) Q
 .S T=T+1 D:T=1 FERROR(2) D FERROR(X)
 .F Y="DAT","KID","TXT" S Z=$P($G(LIST(0,X,Y)),"+",2) I Z'="" D
 ..F I=1:1:$L(Z,"+") S A=$P(Z,"+",I) K:A'="" LIST(A)
 ..Q
 .Q
 Q
 ;
UP(Q) ;
 Q:Q'?.E1L.E Q
 Q $$UP^XLFSTR(Q)
