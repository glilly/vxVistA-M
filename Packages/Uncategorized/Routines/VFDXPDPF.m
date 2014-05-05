VFDVXPDF ;DSS/SGM - LOAD BUILD ;24 Mar 2008 10:23
 ;;3.1;DSS,INC VXVISTA SUPPORTED;;10 Dec 2012;Build 58
 ;Copyright 1995-2012,Document Storage Systems Inc. All Rights Reserved
 ;
 ;This routine is only invoked via VFDVXPD
 ; ICR#   Supported Description
 ;------  -------------------------------
 ;        ^XLFDT: $$FMADD,$$NOW
 ;        Direct global read of ^XPD(9.7)
 ;Cloned from
 ;  EN1^XPDIL
 ;  INST^XPDIL
 ;  PKG^XPDIL1
 ;
 ;=====================================================================
 ;           COMPARE BATCH KID FILE NAMES TO KIDS IN FOLDER
 ;=====================================================================
7 ;
 N I,J,L,X,Y,Z,BLD,EXT,FILE,FNM,LIST,MSG,RPT,SORT,SP
 Q:$G(PID)<1  Q:$G(PATH)=""
 S MSG=0
 ; LIST(hfs_filename)=""
 D GETFILES I MSG W !!,MSG(1) Q
 S I=0,L="" F  S I=$O(^VFDV(21692.1,PID,1,I)) Q:'I  D
 .S X=$G(^VFDV(21692,I,0)) I X="" S BATCH("ERR",I)="" Q
 .S BLD=$P(X,U),FILE=$P($G(^VFDV(21692,I,"FILE")),U) Q:FILE=""
 .S L(1)=$L(FILE),L(2)=$L(BLD)
 .S:L(1)>L $P(L,U)=L(1) S:L(2)>$P(L,U,2) $P(L,U,2)=L(2)
 .; sort(file name)= Boolean flag, 1 if in folder also
 .; sort(file name,0)=number of Builds with this file name
 .; sort(file name,build name)=""
 .;
 .S SORT(FILE)=$D(LIST(FILE))
 .S SORT(FILE,0)=1+$G(SORT(FILE,0))
 .S SORT(FILE,BLD)=""
 .I SORT(FILE) S LIST(FILE)=1+LIST(FILE)
 .Q
 S X=0 F  S X=$O(LIST(X)) Q:X=""  I 'LIST(X) D
 .S L(1)=$L(X) S:L(1)>L $P(L,U)=L(1)
 .S SORT("~",X)=""
 .Q
 I L>30 S $P(L,U)=30
 I $P(L,U,2)>30 S $P(L,U,2)=30
 S $P(SP," ",33)="",L(1)=+L,L(2)=$P(L,U,2)
 S Z=$E(" FILENAME"_SP,1,L(1))_" |"_$E(" BUILD"_SP,1,L(2))_" |"
 S Z=Z_"BatchID|Folder|",RPT(1)=Z
 S L="",$P(L,"-",35)=""
 S RPT(2)=$E(L,1,L(1)+1)_"|"_$E(L,1,L(2)+1)_"|-------|------|"
 S I=2,FILE=0 F  S FILE=$O(SORT(FILE)) Q:"~"[FILE  D
 .S BLD=0 F J=1:1 S BLD=$O(SORT(FILE,BLD)) Q:BLD=""  D
 ..S X=FILE I J>1 S X=""
 ..S Z=$E(X_SP,1,L(1))_" |"_$E(BLD_SP,1,L(2))_" |   Y   |      |"
 ..I SORT(FILE) S $E(Z,L(1)+L(2)+15)="Y"
 ..S I=I+1,RPT(I)=Z
 ..Q
 .Q
 S FILE=0 F  S FILE=$O(SORT("~",FILE)) Q:FILE=""  D
 .S Z=$E(FILE_SP,1,L(1))_" |"_$E(SP,1,L(2)+1)_"|       |  Y   |"
 .S I=I+1,RPT(I)=Z
 .Q
 S RPT=I D RPT^VFDVXPDB
 Q
 ;
 ;=====================================================================
 ;             LOAD A KIDS HFS FILE INTO THE INSTALL FILE 
 ;=====================================================================
8 ;
 ; zrpt = total number of files
 ; zrpt(filename) = 0 if no errors, 1 if errors
 ; zrpt(filename,i) = error messages
 N I,J,L,X,Y,Z,FILE,FNM,LIST,MSG,PATH,RPT,VLIST,ZRPT
 S X=$$ASK^VFDVXPD1("PATH") Q:+X=-1  Q:X=""  S PATH=X
 K Z S Z("KID")="",X=$$LIST^VFDVXPD2(.VLIST,PATH,"N",.Z)
 I X<1 W !!,$$NEWERR(8) Q
 S FNM=0 F  S FNM=$O(VLIST(FNM)) Q:FNM=""  S FILE=VLIST(FNM) D
 .D LOAD(PATH,FILE)
 ;
 ;
 S (MSG,RPT,ZRPT)=0
 ;D GETFILES I MSG W !!,MSG(1) Q
 S FILE=0 F  S FILE=$O(LIST(FILE)) Q:FILE=""  D
 .K MSG S MSG=0 D LOAD(PATH,FILE)
 .S ZRPT=1+ZRPT,ZRPT(FILE)=(MSG=0)
 .I MSG F I=1:1:MSG S ZRPT(FILE,I)=MSG(I)
 .Q
 S RPT(1)="Load  Filename <indented error messages>"
 S RPT(2)="----  ----------------------------------------------------"
 S I=2,FILE=0 F  S FILE=$O(ZRPT(FILE)) Q:FILE=""  D
 .S Y=ZRPT(FILE),I=I+1,X="      "_FILE I ZRPT(FILE) S $E(X,2,3)="ok"
 .S RPT(I)=X
 .F J=1:1 S Z=$G(ZRPT(FILE,J)) Q:Z=""  S I=I+1,RPT(I)="       "_Z
 .Q
 S RPT=I D RPT^VFDVXPDB
 Q
 ;
LOAD(PATH,FILE,FUN) ;
 ;create INSTALL file entry and corresponding ^XTMP("XPDI")
 ; FILE - opt - name of kids hfs file
 ;        if $G(FILE)="" then expect kids hfs file in ^TMP(J,3,n)
 ; PATH - req - name of folder containing KIDS file
 ;  FUN - opt - Boolean flag indicating whether called as extrinsic
 ;        function - default to 1
 ;RETURN [.]vfdload(n) = report
 ;  vfdload = -1 or p1^p2^p3^p4^... where
 ;   p1 = file 9.7 ien  if file contains multiple builds then
 ;   pn = file 9.7 ien for other builds for n=2,3,4,...
 ;NOTE: copied from load a distribution, EN1^XPDIL
 ;
 N A,I,J,K,X,Y,Z,COM,INS,KID,LINE,RET,ROOT,TDAT
 S ROOT=$NA(^TMP($J,3)) S:'$D(FUN) FUN=1
 I $G(PATH)="" Q $$NEWERR(3)
 I $G(FILE)="",'$O(@ROOT@(0)) Q $$NEWERR(2)
 S ^XTMP("XPDI",0)=$$FMADD^XLFDT(DT,7)_U_DT
 ; if kid file not already loaded, then get it
 I '$O(@ROOT@(0)) D  I X<1 Q X
 .S X=$$FTG^VFDVXPD2(PATH,FILE,$NA(@ROOT@(1)))
 .I 'X S X="-1^"_$$NEWERR(4)
 .Q
 S X=$$FILETYPE^VFDVXPD3(ROOT)
 I X=-1
 .S X=$$GETFILE^VFDVXPDC(ROOT,PATH,FILE)
 .I X'="K",X'="F" D ERR(3),KILL
 .Q
 ;
 ;check file structure up to first **INSTALL** line
 ;sets COM and KID(), LINE=line# before 1st **INSTALL** line
 S LINE=$$PREP I 'LINE D KILL Q
 ;
 ; check to see if any incomplete KIDS installs
 I '$$CK D KILL Q
 ;
 ; add all installs to file 9.7
 I '$$ADD D KILL Q
 ;
 ; create ^xtmp("xpdi",<9.7 ien>)
 I '$$XTMP D ERR(7)
 I 'TDAT D KILL
 Q
 ;
 ;=======================  PRIVATE SUBROUTINES  =======================
 ;----------------------  GET NEXT LINE OF FILE  ----------------------
L1() S Z="",I=$O(@ROOT@(I)) S:I>0 Z=$G(@ROOT@(I)) Q I>0
 ;
ADD() ;------------------  ADD BUILDS TO FILE 9.7  --------------------
 ; copied from INST^XPDIL1
 ; Extrinsic function returns 1 or -1
 ; Return: KID(I) = build name ^ 9.7_ien (2nd piece only if no errors)
 ;         S KID("NM",build name)=9.7 ien (see line XTMP)
 ; vinc is the order of builds to be installed
 N I,J,X,Y,Z,VERR,VIEN,VINC,VSTART
 S (VERR,VINC,VSTART)=0
 F  S VINC=$O(KID(VINC)) Q:'VINC  D  Q:+VERR
 .K Z S Z(.01)=KID(VINC)
 .S Z(.02)=0 ; status
 .S Z(2)=$P($$NOW^XLFDT,":",1,2) ; date loaded
 .I VINC'=1,VSTART S Z(3)=VSTART ; starting pkg ien
 .S Z(4)=VINC ; install order
 .S Z(5)="" ;   queued task number
 .S Z(6)=COM ;  file comment
 .S VIEN=$$UPDATE^VFDVFM(9.7,,,.Z) I VIEN>0 D
 ..S KID("NM",KID(VINC))=+VIEN
 ..I VINC=1 S VSTART=+VIEN
 ..S $P(KID(VINC),U,2)=+VIEN
 ..Q
 .I VIEN<1 S $P(KID(VINC),U,3)=$P(VIEN,U,2),VERR=1
 .I VINC>1!VERR Q
 .; add starting pkg to first kids in multibuild
 .K Z S Z(3)=+VIEN,X=$$FILE^VFDVFM(9.7,VIEN_",",,.Z)
 .I +X=-1 S VERR="1^"_$P(X,U,2)
 .Q
 I 'VERR Q 1
 D ERR(6)
 ; delete any Builds successfully added
 S VINC=0 F  S VINC=$O(KID(VINC)) Q:'VINC  D
 .S X=KID(VINC),Z=$P(X,U,3),Y=$P(X,U,2),X=$P(X,U),KID(VINC)=X
 .S Z="   "_X_" - INSTALL file entry deleted, "_Z D ERR(Z)
 .I Y D DEL^VFDVFM(9.7,Y)
 .Q
 Q 0
 ;
CK() ;---------  CHECK IF PREVIOUS INCOMPLETE KIDS INSTALLS  ----------
 N I,J,X,Y,Z,TMP
 S I=0 F  S I=$O(KID(I)) Q:'I  D
 .S J=0,Z=KID(I) F  S J=$O(^XPD(9.7,"B",Z,J)) Q:'J  D
 ..S X=$$STAT^VFDVXPDA(J) I X'<0,X<3,$D(^XTMP("XPDI",J)) S TMP(Z,J)=""
 ..Q
 .Q
 I '$D(TMP) Q 1
 D ERR(5) S Z=0
 F  S Z=$O(TMP(Z)) Q:Z=""  S J=0 F  S J=$O(TMP(Z,J)) Q:'J  D
 .S X="   Ien: "_$J(J,6)_" for Build "_Z D ERR(X)
 .Q
 Q 0
 ;
NEWERR(A,WR) ;
 N T
 I A=1 S T="No KIDS file found in "_PATH
 I A=2 S T="No KIDS file received"
 I A=3 S T="No path received"
 I A=4 S T="Failed to retrieve file "_PATH_FILE
 I '$G(WR) Q "-1^"_T
 W !!?3,T
 Q
 ;
ERR(A) ;----------------------  ERROR PROCESSOR  ----------------------
 ;;No PATH received
 ;;No file name received
 ;;KID file is not a proper KIDS file
 ;;This is a GLOBAL distribution - file not processed
 ;;This build contains KIDS builds that have existing incomplete installs
 ;;Errors encountered adding kids builds to INSTALL file
 ;;Problems encountered trying to create ^XTMP("XPDI") nodes
 ;;Unable to retrieve files from 
 ;;KIDS HFS file contained an unexpected Build name: 
 N T S A=$G(A)
 I +A'=A S T=$S(+A=-1:$P(A,U,2),1:A)
 I A>0 S T=$P($T(ERR+A),";",3)
 I A=8 S T=T_PATH
 I A=9 S T=T_Y
 S MSG=MSG+1,MSG(MSG)=T
 Q
 ;
GETFILES ;-----------------  GET KID HFS FILE NAMES  ------------------
 N I,X,Y,Z,FNM,ZLIST
 K LIST
 S X=$$LIST^VFDVXPDB(.ZLIST,PATH,1) I X<1 D ERR(8) Q
 S FNM=0 F  S FNM=$O(ZLIST(FNM)) Q:FNM=""  D
 .S Y=$G(ZLIST(FNM,"KID")) S:Y'="" LIST(Y)=""
 .Q
 Q
 ;
INIT ;------------------------  INITIALIZATION  -----------------------
 K MSG S MSG=0,INS="**INSTALL NAME**"
 S PATH=$G(PATH),FILE=$G(FILE),ROOT=$NA(^TMP($J,2))
 S TDAT=$O(^TMP($J,2,0)) I 'TDAT D KILL
 S ^XTMP("XPDI",0)=$$FMADD^XLFDT(DT,7)_U_DT
 Q
 ;
KILL K ^TMP($J,2) Q
 ;
PREP() ;---------------- GET INFO FROM FIRST FEW LINES ----------------
 ; file already validated as allowable kids hfs file
 ; extract file comment from beginning of file
 ; return line number of line before first "**INSTALL NAME**" line
 N A,B,K,X,Y,Z,DATE,FOIA
 S (I,J,K)=0,(COM,DATE)=""
 ;
 ; get comment from first two lines
 S B="KIDS Distribution saved on "
 S A=$$L1,Z(1)=Z I 'A D ERR(3) Q 0
 S A=$$L1,Z(2)=Z I 'A D ERR(3) Q 0
 I Z(1)'[B S COM=Z ; FOIA
 E  S COM=Z(2),DATE=$P($P(Z(1),B,2),":",1,2)
 I DATE="" S DATE=$P($$HTE^XLFDT($H),":",1,2)
 I COM="" S COM=FILE
 S COM=COM_" ;Created on "_DATE
 ;
 ; now get all build name
 F  S A=$$L1 Q:'A  I Z=INS S:'J J=I S A=$$L1 I Z'="" S K=K+1,KID(K)=Z
 I 'J!'$D(KID) D ERR(3) S J=0
 Q $S('J:0,1:J-1)
 ;
WR ;-----------------------  WRITE MESSAGES  -----------------------
 N I I $G(RPT) F I=1:1:RPT W !,RPT(I)
 Q
 ;
XTMP() ;---------------  MOVE INSTALL TO ^XTMP("XPDI")  ---------------
 N A,J,X,Y,Z,ARG,ERR,GLB,RET
 S RET="",I=LINE
 S A=$$L1 I Z'=INS!'A D ERR(3) Q 0
 S A=$$L1 I 'A D ERR(3) Q 0
 S A=+$G(KID("NM",Z)) I 'A D ERR(3) Q 0
 S GLB="^XTMP(""XPDI"","_A_","
 S ERR=0
 F  S A=$$L1,X=Z Q:X="**END**"  S A=$$L1,Y=Z S:'A ERR=1 D:A  Q:ERR
 .I X=INS D  Q
 ..S A=+$G(KID("NM",Y)) I 'A D ERR(9) S ERR=1 Q
 ..S GLB="^XTMP(""XPDI"","_A_","
 ..Q
 .S @(GLB_X_"=Y")
 .Q
 I ERR S X=0 D  Q 0
 .F  S X=$O(KID("NM",X)) Q:X=""  S J=+KID("NM",X) K ^XTMP("XPDI",J)
 .Q
 S X=0 F  S X=$O(KID("NM",X)) Q:X=""  D
 .N J,XPDIT,XPDSKPE,XPDT
 .S J=+KID("NM",X),(XPDIT,XPDSKPE)=1,XPDT(1)=U_X
 .; xpdil1 writes package name
 .N X D PKG^XPDIL1(J)
 .Q
 Q 1
 ;
DEL ; temporoary delete for bug in program
 N I,X,Y,Z,DA,DIK,DIC,ORD,VIEN
 S DIC=9.7,DIC(0)="QAEM",DIK="^XPD(9.7,"
 F  D ^DIC Q:Y<1  S VIEN=+Y D
 .I '$D(^XPD(9.7,"ASP",VIEN)) S DA=VIEN D ^DIK K ^XTMP("XPDI",DA) Q
 .S ORD=0 F  S ORD=$O(^XPD(9.7,"ASP",VIEN,ORD)) Q:'ORD  D
 ..S DA=$O(^XPD(9.7,"ASP",VIEN,ORD,0)) Q:'DA
 ..D ^DIK K ^XTMP("XPDI",DA)
 ..Q
 .Q
 Q
