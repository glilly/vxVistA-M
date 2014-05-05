VFDXPDF ;DSS/SMP - PROCESS HFS FILES/ADD TO BATCH ; 02/06/2013 16:30
 ;;3.1;DSS,INC VXVISTA SUPPORTED;;10 Dec 2012;Build 58
 ;Copyright 1995-2012,Document Storage Systems Inc. All Rights Reserved
 ;
 ;This routine should only be invoked via the VFDXPD routine
 ;
 ;Description of ^TMP($J)
 ;^TMP("VFDXPD",$J,0,n) = dat file
 ;^TMP("VFDXPD",$J,1,n) = txt file
 ;^TMP("VFDXPD",$J,2,n) = kid file
 ;^TMP("VFDXPD",$J,"CNVT",i) = conversion report of .DAT files
 ;^TMP("VFDXPD",$J,"ERR",n,i) = Error reports
 ;   n = number representing the type of error or text
 ;   i = contains formatted text of the errors
 ;^TMP("VFDXPD",$J,"DATA",<kids build name>,subscript) = value
 ;   data extracted from HFS files
 ;   subscript     description of node value
 ;---------------  ----------------------------------------------------
 ; BATCH           ien to file 21692.1 - only entries derived from a
 ;                 hfs file will have this set.  Some records may exist
 ;                 as 21692_iens needed for IN/Req_builds
 ; BLD             build name
 ; DATE            date of Mailman message
 ; ENV             environmental routine
 ; FOIA KID        name of KID HFS file (FOIA release)
 ; FOIA TXT        name of TXT HFS file (FOIA release)
 ; IEN             ien to file 21692
 ; IN              name of Build which contains this Build
 ; IN,0            file 21692 ien
 ; KID             name of KID HFS file
 ; MES             subject of mailman message (or KIDS HFS descript)
 ; MSGID           Forum Mailman message number
 ; MULT,order#     Build names contained in this multi-Build
 ; ORD             Build installation order# if part of a multi-Build
 ; PATCH           patch number or null
 ; PKG             Build name portion or namespace
 ; POST            post-install
 ; PRE             pre-install
 ; REL             date patch was released
 ; REQ,build_name  file 21692_ien or "" if name not converted to ien
 ; SEQ             sequence number or null
 ; STAT            New or Updated or Problems
 ; SUBJ            subject of the patch
 ; TXT             name of TXT HFS file
 ; VER             Build version number with at least one decimal
 ;
1 ;============  PROCESS KID HFS FILES TO ADD TO A BATCH  =============
 Q:$G(PATH)=""
 N I,J,X,Y,Z,VCNT,VFADD,VFDCNVT,VFDDATA,VFDERR,VFDFILE,VFDL,VFDLIST
 N VFDLOC,VTOT
 ;
 N I,J,X,Y,Z,LOC,FILE,KID,OUT,VCNT,VCNVT,VEXT,VFADD,VFDATA,VFDN
 N VTOT,VFDX,VFDY,VFDLIST,VRPT
 S VFADD=$$DIR^VFDXPD0(7) Q:VFADD<0
 ; set up local variable names for common global roots
 ; get list of of kids HFS files (.DAT, .TXT, .KID)
 ; convert .DAT files to .TXT and .KID
 ; extract data from .DAT files for filing to 21692
 D CNVT Q:'$D(VFDLIST)  D FLIST^VFDXPDF0
 ; VTOT = total number of roots of filenames
 ; following calls will extract data from files for filing to 21692
 D TXT ;              extract data from .TXT files
 D KIDS ;             extract data from .KID files
 ; file data to files 21692, call resets VTOT
 D FILE^VFDXPDF3(VFADD,VFDDATA)
 D EXIT^VFDXPD0
 ; add builds to processing batch
 S X=$$FILEBAT^VFDXPDF1(PID,VFDDATA)
OUT D RPT
 G KILL^VFDXPD
 ;
 ;============= CONVERT ALL DAT FILES FOUND IN DIRECTORY ==============
3 ; independent option entry point
 N I,X,Y,Z,VCNT,VFDCNVT,VFDDATA,VFDERR,VFDFILE,VFDL,VFDLIST,VFDLOC
 I $D(PATH)  D CNVT,EXIT^VFDXPDU
 Q
 ;
 ;-----------------------  PRIVATE SUBROUTINES  -----------------------
CNVT ; convert .DAT files to .TXT and .KID
 D GLBNAME^VFDXPDF0
 D FLIST^VFDXPDF0
 I '$D(VFDLIST) D KILL^VFDXPD Q
 D DATCNVT^VFDXPDF2
 Q
 ;
FCOMMON(TYPE) ; called from DATCNVT, TXT, KID
 ; defines VFDL and FILE, Kills VFDY and @VFDFILE
 S VFDL=$NA(VFDLIST(VFDX))
 S FILE=$G(@VFDL@(TYPE)),X=1+(FILE="")
 S:FILE[U FILE=$P(FILE,U)
 D XDSP^VFDXPDF0(VFDX,,X) I FILE'="" K VFDY,@VFDFILE
 Q
 ;
FCOMMON2(TYPE) ; called from TXT and KIDS
 ; defines VFDLOC
 N A,B,X,Y,Z,FNM,VFDY
 K VFDY
 S VFDLOC=$NA(@VFDFILE@(TYPE))
 S X=$$FTG^VFDXPD0(PATH,FILE,$NA(@VFDLOC@(1)))
 I X<1 D ERR^VFDXPDF0(2,FILE,1) Q
 S Z=$S(TYPE=1:"T",1:"FK"),Y=$$FILETYPE^VFDXPD0(VFDLOC,.VFDY)
 I Z[Y,$D(VFDY),TYPE=1 D
 .S B=$S($$UP^XLFSTR(FILE)["_SEQ":"FOIA TXT",1:"TXT")
 .S X=$O(VFDY(0)) S:X'="" VFDY(X,B)=FILE
 I Z[Y,$D(VFDY),TYPE=2 D
 .S A=0 F  S A=$O(VFDY(A)) Q:A=""  D
 ..S B=$S($$UP^XLFSTR(FILE)["_SEQ":"FOIA KID",1:"KID")
 ..S:$G(VFDY(A,"ORD"))'>1 VFDY(A,B)=FILE
 ..Q
 I Z[Y,$D(VFDY) M @VFDDATA=VFDY
 E  D ERR^VFDXPDF0(TYPE+2,FILE,1) K @VFDLOC Q
 Q
 ;
KID() N A S A=$O(VFDY(" ")) S:A'="" A=$G(VFDY(A,"BLD")) Q A
 ;
KIDS ;;Process *.KID HFS Files
 N I,X,Y,Z,FILE,VFDL,VFDLOC,VFDN,VFDX,VFDY
 D XINIT^VFDXPDF0(,4)
 S VFDX=0 F  S VFDX=$O(VFDLIST(VFDX)) Q:VFDX=""  D
 .D FCOMMON("KID") Q:FILE=""  Q:$D(@VFDL@("DAT"))
 .D FCOMMON2(2) Q:'$D(@VFDLOC)
 .D MINEKID^VFDXPDF1(VFDLOC,.VFDY)
 .I $D(VFDY) M @VFDDATA=VFDY
 .Q
 Q
 ;
NXT ;
 S X=-1,I=$O(@VFDLOC@(I)) Q:'I
 S X=$G(@VFDLOC@(I)) I '$D(@VFDLOC@(I)) S X=-1
 Q
 ;
TXT ;;Process *.TXT HFS Files
 N I,X,Y,Z,FILE,VFDL,VFDN,VFDX,VFDY
 D XINIT^VFDXPDF0(,3)
 S VFDX=0 F  S VFDX=$O(VFDLIST(VFDX)) Q:VFDX=""  D
 .D FCOMMON("TXT") Q:FILE=""  Q:$D(@VFDL@("DAT"))
 .D FCOMMON2(1)
 .Q
 Q
 ;
RPT ; write reports
 N I,J,X,Y,Z,OUT
 S OUT=$$OUT^VFDXPD0 Q:OUT<0
 D RPTCNVT,RPTDATA,RPTERR
 Q
 ;
RPTCNVT ; report conversion of .DAT files
 ; Expects that @VFDCNVT@(n) = p1^p2^p3^p4^p5 where
 ;  p1 = packman filename
 ;  p2 = patch description filename (.txt)
 ;  p3 = kid hfs filename (.kid)
 ;  p4 = Boolean, 1 if packman file successfully deleted
 ;  p5 = error message
 ;  if p5'="" then p2,p3,p4 are null
 N A,I,L,N,X,Y,Z,RPT
 S (L,N)=0,T=+$G(@VFDCNVT@(0))
 I T D
 .F I=1:1:T S X=$G(@VFDCNVT@(I)),Y=$L($P(X,U)) S:Y>L L=Y
 .S:L<17 L=17 S L=L+2
 .S X=" PACKMAN FILENAME",$E(X,L)="|TXT|KID|DEL| Error Messages"
 .D SET(X)
 .S Y="",$P(Y,"-",L)="|---|---|---|",$P(Y,"-",76)="" D SET(Y)
 .I T F I=1:1:T S Z=$G(@VFDCNVT@(I)) I Z'="" D
 ..F Y=1:1:5 S Z(Y)=$P(Z,U,Y)
 ..S X=Z(1),$E(X,L)="|"
 ..S A="   |" S:Z(2)'="" $E(A,2)="Y" S X=X_A
 ..S A="   |" S:Z(3)'="" $E(A,2)="Y" S X=X_A
 ..S A="   |" S:Z(4) $E(A,2)="Y" S X=X_A
 ..S:Z(5)'="" X=X_Z(5)
 ..D SET(X)
 ..Q
 .I T D SET("   Total number of Builds: "_T)
 .Q
 D RPT^VFDXPD0(.RPT,OUT,"No DAT files found")
 Q
 ;
RPTDATA ; report of records added to file 21692
 N A,N,P,X,Y,Z,CNT,RPT,SORT,STAT,STR,UL
 S (L,N)=0
 S $P(UL,"-",71)=""
 S A(" ")="   No Updates Performed"
 S A("N")="   New Records Added to File 21692"
 S A("P")="   Problems Encountered"
 S A("U")="   Updated Existing 21692 Records"
 I $O(@VFDDATA@(0))'="" D
 .S Z="   KIDS Builds added/updated to file 21692" D SET(Z)
 .D SET($TR(UL,"-","="))
 .S X=0 F  S X=$O(@VFDDATA@(X)) Q:X=""  S Y=$G(@VFDDATA@(X,"STAT")) D
 ..S A=$E(Y) S:A="" A=" " S SORT(A,X)=""
 ..Q
 .S A="" F  S A=$O(SORT(A)) Q:A=""  D
 ..D SET(A(A)),SET(UL)
 ..S (X,Y,CNT)=0,STR="" F  S X=$O(SORT(A,X)) Q:X=""  D
 ...S CNT=1+CNT
 ...S Y=$L(STR) I Y S P=$S(Y<18:17,Y<35:34,1:51),$E(STR,P)=" "
 ...I $L(STR)>51 D SET(STR) S STR=X Q
 ...I ($L(X)+$L(STR)+1)>80 D SET(STR) S STR=X Q
 ...S STR=STR_X
 ...Q
 ..I $L(STR) D SET(STR)
 ..Q
 .D SET("   Total number of builds: "_CNT)
 .Q
 D RPT^VFDXPD0(.RPT,OUT,"No add/updates to file 21692")
 Q
 ;
RPTERR ; report on errors encountered
 ; @vfderr@(num)   = title of this section
 ; @vfderr@(num,0) = total number of lines
 ; @vfderr@(num,i) = text
 N I,J,N,T,X,Y,Z,RPT,UL
 S N=0,T=$G(@VFDERR@(0)),$P(UL,"-",73)=""
 I T D
 .D SET("   ERROR MESSAGES")
 .D SET($TR(UL,"-","="))
 .S I=0 F  S I=$O(@VFDERR@(I))  Q:'I  D
 ..S X=@VFDERR@(I) D SET(X),SET(UL)
 ..S J=0 F  S J=$O(@VFDERR@(I,J)) Q:'J  D SET(@VFDERR@(I,J))
 ..Q
 .Q
 D RPT^VFDXPD0(.RPT,OUT,"   < No errors encountered >")
 Q
 ;
 ;---------------------------------------------------------------------
SET(B) S N=N+1,RPT(N)=B Q
 ;
STRIP(X) ; strip leading and trailing spaces and control chars
 I $L(X) F  Q:$E(X)'?1(1C,1" ")  S X=$E(X,2,$L(X)) Q:'$L(X)
 I $L(X) F  Q:$E(X,$L(X))'?1(1C,1" ")  S X=$E(X,1,$L(X)-1) Q:'$L(X)
 Q
