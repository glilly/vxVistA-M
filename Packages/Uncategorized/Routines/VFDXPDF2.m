VFDXPDF2 ;DSS/SGM - PATCH UTIL CONVERT MM TO KIDS ;01/23/2013 15:45
 ;;3.1;DSS,INC VXVISTA SUPPORTED;;10 Dec 2012;Build 58
 ;Copyright 1995-2012,Document Storage Systems Inc. All Rights Reserved
 ;
 ;This routine should only be invoked via the VFDXPD routine
 ;
 ; @VFDCNVT@(n) - p1^p2^p3^p4^p5 where
 ;   p1 = packman filename  p4 = Boolean, dat file successfully deleted
 ;   p2 = txt file created  p5 = error message
 ;   p3 - kid file created  p6 = not used
 ;
DATCNVT ;;Converting HFS *.DAT Files To *.TXT and *.KID Files
 ; expects PATH, VCNT, VFDCNVT, VFDFILE, VFDLIST, VTOT
 Q:$G(PATH)=""
 N I,X,Y,Z,FILE,VFDL,VFDN,VFDX,VFDY
 D XINIT^VFDXPDF0(,2)
 S VFDX=0 F  S VFDX=$O(VFDLIST(VFDX)) Q:VFDX=""  D
 .D FCOMMON^VFDXPDF("DAT") Q:FILE=""  ; vfdl,file defined here
 .S Z=$$CNVTONE(PATH,FILE,1,1,1,.VFDY)
 .D RPTSET^VFDXPDF0(VFDCNVT,Z)
 .S Y=$P(Z,U,2) S:Y'="" @VFDL@("TXT")=Y_U_$$UP^VFDXPD0(Y)
 .S Y=$P(Z,U,3) S:Y'="" @VFDL@("KID")=Y_U_$$UP^VFDXPD0(Y)
 .S X=$G(VFDY("BLD")) I X'="" M @VFDDATA@(X)=VFDY
 .Q
 Q
 ;
 ;========== CONVERT MAILMAN PACKMAN FILES TO TXT & KID FILES ==========
CNVTONE(PATH,FILE,DEL,QUIET,KEEP,VFD) ;
 ; PATH - req
 ; FILE - req - hfs file to be processed
 ;  DEL - opt - if DEL, delete .DAT file if TXT and KID files
 ;              successfully created
 ;QUIET - opt - if QUIET then extrinsic function, return message
 ;              else DO w/params and write message
 ; KEEP - opt - default to 0, if 1 do not kill @VFDFILE on exit
 ; VFD - return array containing data in file
 ;       see FILETYPE^VFDXPDF1
 ; @VFDFILE@(n) contains HFS file contents [n=0:DAT, n=1:TXT, n=2:KID]
 ;Return: p1^p2^p3^p4^p5^p6  see above for description
 ;  if p5'="" then p2,p3,p4 are null
 N I,J,R,X,Y,Z,DATE,FEX,FN,FNM,KID,MSGID,SUBJ,VFDAT,VFDLOC
 F I=1:1:6 S VFDAT(I)=""
 I $G(VFDFILE)="" N VFDFILE S VFDFILE=$NA(^TMP("VFDXPDF2",$J)),KEEP=0
 S X=$S($G(PATH)="":1,$G(FILE)="":2,1:0)
 I X D  G CVOUT
 .I X=1 S Y="No path recevied"
 .I X=2 S Y="No filename received"
 .S VFDAT(5)=Y
 .Q
 S FN=$$UP^VFDXPD0(FILE),J=$L(FN,".")
 S FEX=$P(FN,".",J),FN=$P(FN,".",1,J-1),VFDAT(1)=FILE
 S VFDLOC=$NA(@VFDFILE@(0)) K @VFDLOC
 ;
 ; get the hfs file
 S X=$$FTG^VFDXPD0(PATH,FILE,$NA(@VFDLOC@(1)))
 I X'=1 S VFDAT(5)=X,VFDAT(6)=2 G CVOUT
 ;
 ; determine if dat file is a packman message
 S X=$$FILETYPE^VFDXPD0(VFDLOC,.VFD)
 I X'="M" S VFDAT(5)="Not a Packman mail message",VFDAT(6)=5 G CVOUT
 S KID=$O(VFD(0))
 ;
 ; create patch description and kids files
 D DESC,KID,DEL
 K:'$G(KEEP) @VFDFILE
 ;
CVOUT S X="" F I=1:1:6 S $P(X,U,I)=VFDAT(I)
 Q:$G(QUIET) X
 W !!?3,FN_".TXT " W:VFDAT(2)="" "not " W "created"
 W !?3,FN_".KID " W:VFDAT(3)="" "not " W "created"
 W !?3,FILE_" " W:'VFDAT(4) "not " W "deleted"
 Q
 ;
 ;-----------------------  PRIVATE SUBROUTINES  -----------------------
DEL ; delete DAT file
 N Z K Z S Z(FILE)=""
 I '$G(DEL)!(VFDAT(2)="")!(VFDAT(3)) Q
 I $$DEL^VFDXPD0(PATH,.Z) S VFDAT(4)=1
 Q
 ;
DESC ; extract text portion for creating HFS TXT file
 ; previous check assures us that this is a Packman Mail Message
 N I,J,L,FNM
 S J=$G(VFD(KID,5))
 F I=1:1:J S @VFDFILE@(1,I)=@VFDFILE@(0,I)
 S FNM=FN_".TXT",X=$NA(@VFDFILE@(1,1))
 Q:'$$GTF^VFDXPD0(PATH,FNM,X)
 S VFDAT(2)=FNM,VFD(KID,"TXT")=FNM
 Q
 ;
KID ; extract KIDS portion for creating HFS KIDS file
 N I,J,L,R,X,Y,Z,FNM,TO
 S TO=$NA(@VFDFILE@(2))
 S L=0,X=$G(VFD(KID,"DATE")) I X="" D
 .S X=$E($$NOW^XLFDT,1,12),X=$$FMTE^XLFDT(X)
 .Q
 S L=L+1,@TO@(L)="VFD KIDS Distribution saved on "_X
 S L=L+1,@TO@(L)=$G(VFD(KID,"MES"))
 S L=L+1,@TO@(L)="**KIDS**:"_KID_U
 S L=L+1,@TO@(L)=""
 S Y=0,Z="$END KID"
 S I=VFD(KID,5)+1,J=0
 F  D NXT(1) Q:'I!(X="")  S:$E(X,1,8)=Z J=1 Q:J  D
 .S L=L+1,@TO@(L)=X,L=L+1,@TO@(L)=Y
 I 'J K @TO
 E  S X="**END**",L=L+1,@TO@(L)=X,L=L+1,@TO@(L)=X
 S FNM=FN_".KID",X=$NA(@TO@(1))
 Q:'$$GTF^VFDXPD0(PATH,FNM,X)
 S VFDAT(3)=FNM,VFD(KID,"KID")=FNM
 Q
 ;
NXT(FLAG) ;
 S I=$O(@VFDFILE@(0,I)),X=$G(@VFDFILE@(0,I))
 S:'$D(@VFDFILE@(0,I)) X=""
 Q:'$G(FLAG)
 S I=$O(@VFDFILE@(0,I)),Y=$G(@VFDFILE@(0,I))
 Q
