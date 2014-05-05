VFDXPDJ ;DSS/SMP - PATCH UTIL AND INSTALL FILE ;12/27/2012 15:00
 ;;3.1;DSS,INC VXVISTA SUPPORTED;;10 Dec 2012;Build 58
 ;Copyright 1995-2012,Document Storage Systems Inc. All Rights Reserved
 ;
 ;This routine is only invoked via the VFDXPD routine
 ;
 ;=========================  LOAD KID BUILDS  ========================
8 ; load all .kid files found in designated folder
 N I,J,N,X,Y,Z,COM,FILE,KID,LINE,ROOT,VFDARR,VFDLIST,VFDR,VFDRPT,VROOT
 D FLIST^VFDXPD0(.VFDLIST,PATH,0,.VFDARR)
 G:'$D(VFDLIST) 81 K VFDARR
 S VROOT=$NA(^TMP("VFDXPD",$J)),ROOT=$NA(@VROOT@(1))
 S VFDARR="VFDLIST" F  S VFDARR=$Q(@VFDARR) Q:VFDARR=""  D
 .N COM,KID
 .Q:$QS(VFDARR,2)'="KID"  Q:'$D(VFDKID($QS(VFDARR,1)))
 .K @VROOT S FILE=@VFDARR
 .I '$$FTG^VFDXPD0(PATH,FILE,ROOT) D WR(FILE,1) Q
 .; check lines of HFS file up to first **INSTALL NAME** line
 .; sets COM and KID(), LINE=line# before 1st **INSTALL NAME** line
 .; KID(n)=build name   KID("NM",build name)=n
 .;    ADD line creates KID(n,0)=loaded INSTALL ien
 .S LINE=$$PREP I 'LINE D WR(FILE,2) Q
 .; get current status of the builds before loading
 .; create stub records in INSTALL file for LOADED KIDS
 .; create ^XTMP("XPDI") entry
 .D CK,ADD,XTMP M VFDRPT(FILE)=KID
 .Q
 K @VROOT D RPT
81 D DIR^VFDXPD0("CR")
 Q
 ;
 ;============  UNLOAD ALL KIDS BUILDS IN ^XTMP("XPDI")  =============
12 ; delete all loaded, queued, and started KIDS Builds which have a node
 ; in ^XTMP("XPDI",ien)
 N I,J,X,Y,Z,VFDI,VFDL,VFDX,XPDSTAT
 D GET,STATUS^VFDXPD0(.XPDSTAT)
 I '$D(VFDL) W ! D WR(4) W ! D CONT^VFDXPDA Q
 D LIST Q:$$DIR^VFDXPD0(6)<1  W ! D WR(5)
 F VFDI=0,1,2 I $D(VFDL("SB",VFDI)) D
 .D WR(6) W XPDSTAT(VFDI) S VFDX=$NA(VFDL("SB",VFDI))
 .F  S VFDX=$Q(@VFDX) Q:VFDX=""  Q:$QS(VFDX,2)'=VFDI  D
 ..S Z=$P(@VFDX,U,2),Y=$QS(VFDX,3) W:Z=Y !?10,Z W:Z'=Y !?12,">> "_Z
 ..N DA,DIK S DIK="^XPD(9.7,",DA=+@VFDX D ^DIK
 ..Q
 .Q
 ; clean up ^XTMP global
 D WR(7) W ! S I=0 F  S I=$O(VFDL(I)) Q:'I  D
 .I $D(^XTMP("XPDI",I)) K ^(I) W $J(I,10) W:$X>70 !
 .Q
 Q
 ;
 ;-----------------------  PRIVATE SUBROUTINES  -----------------------
 ;=====  COMMON  =====
WR(L,F,T) ;
 ;;Failed to retrieve file
 ;;Not a valid kids hfs file
 ;;HFS file had unexpected build 
 ;;No loaded BUILDs found
 ;;Deleting loaded installs . . .
 ;;  Deleting INSTALLs with a status of 
 ;;Checking to see if any ^XTMP("XPDI") nodes left around
 N A
 S L=$G(L),F=$G(F),T=$G(T)
 S:+L L=$P($T(WR+L),";",3) S:T'="" L=L_T
 S A="" I F'="" S A=F,$E(A,25)=" "
 S A=A_L
 W !?3,A
 Q
 ;
 ;=====  FOR UNLOAD OPTION  =====
GET ; get all loaded KIDS Builds
 ; 9.7 fields   field#   node;piece
 ; STATUS        .02        0;9
 ; START PKG     3          0;4;ptr to 9.7
 ; INSTALL ORD   4          0;5
 N I,J,X,Y,Z
 S I=0 F  S I=$O(^XTMP("XPDI",I)) Q:'I  D
 .N Z,NM,ORD,PKG,STAT,VFDY
 .S Z=".01;.02;3;4",X=$$GETS^VFDXPDA("VFDY",9.7,I_",",Z,"IE")
 .Q:X<1  K Z M Z=VFDY(9.7,I_",") K VFDY
 .S NM=Z(.01,"E"),STAT=Z(.02,"I"),PAR=$G(Z(3,"I")),PAR(0)=$G(Z(3,"E"))
 .S ORD=Z(4,"I") S:'ORD ORD=1 S:'PAR PAR=I,PAR(0)=NM
 .Q:STAT=""  Q:NM=""  S VFDL(I)=NM
 .S VFDL("B",NM,I)=STAT_U_PAR(0)_U_PAR_U_ORD
 .S VFDL("SB",STAT,PAR(0),PAR,ORD)=I_U_NM
 .Q
 Q
 ;
LIST ; build RPT() of all loaded builds
 N A,B,C,I,J,K,L,X,Y,Z,RPT
 S J=0,I="" F  S I=$O(VFDL("SB",I)) Q:I=""  D
 .S Z="INSTALL status: "_XPDSTAT(I) D SET(Z)
 .S A=0 F  S A=$O(VFDL("SB",I,A)) Q:A=""  D
 ..S B=0 F  S B=$O(VFDL("SB",I,A,B)) Q:B=""  D
 ...S C=0 F  S C=$O(VFDL("SB",I,A,B,C)) Q:'C  D
 ....S Y=VFDL("SB",I,A,B,C)
 ....S Z=$P(Y,U,2) S:Z'=A Z="  >> "_Z D SET("   "_Z)
 ....Q
 ...Q
 ..Q
 .Q
 D RPT^VFDXPD0(.RPT)
 Q
 ;
SET(A) S J=J+1,RPT(J)=A Q
 ;
 ;=====  FOR LOAD OPTION  =====
ADD ;  add stub record to file 9.7 (status=loaded)
 ; copied from INST^XPDIL1
 ; Extrinsic function returns 1 or -1
 ; adds KID(i,0) = loaded INSTALL ien (#9.7)
 N I,J,X,Y,Z,NM,VFDST,VFDJ,VIEN
 S VFDST="",I=0 F  S I=$O(KID(I)) Q:'I  D
 .S VFDJ=I,NM=KID(I),VFDST=$G(KID(1,0)) D
 ..;  create stub INSTALL record
 ..N I,KID,VFD
 ..S VFD(.01)=NM                    ; install name
 ..S VFD(.02)=0                     ; status
 ..S VFD(2)=$E($$NOW^XLFDT,1,12)    ; date loaded
 ..S:VFDST VFD(3)=VFDST             ; starting pkg ien
 ..S VFD(4)=VFDJ                    ; install order
 ..S VFD(6)=COM                     ; file comment
 ..S X=$$UPDATE^VFDXPDA(9.7,,.VFD)
 ..I X>0,VFDJ=1 K VFD S VFD(3)=X,Z=$$FILE^VFDXPDA(9.7,X,.VFD)
 ..Q
 .I X>0 S KID(I,0)=X
 .Q
 Q
 ;
CK ; check if Build already installed
 N I,J,X,Y,Z,IEN,STAT
 S I=0 F  S I=$O(KID(I)) Q:'I  D
 .S X=$$LAST^VFDXPD0(,KID(I),3) S:I=1 Z=KID(I)
 .; x=install_name^install_ien^FM date;ext date^int_stat;ext_stat
 .S IEN=+$P(X,U,2),STAT=+$P(X,U,4)
 .I +X'=-1 S KID(I,"STAT",STAT)=IEN_U_$P(X,U,3)_U_$P($P(X,U,4),";",2)
 .Q
 Q
 ;
L1() ; get next line of file
 S Z="",I=$O(@VROOT@(I)) S:I>0 Z=$G(@VROOT@(I)) Q I>0
 ;
PREP() ; Get info from first few lines
 ; file already validated as allowable kids hfs file
 ; extract file comment from beginning of file
 ; return line number of line before first "**INSTALL NAME**" line
 ; Return: KID(i) = build name   KID("NM",build name)=i
 ;    i is the order of builds to be installed
 N A,B,K,X,Y,Z,DATE,FOIA,INS
 S (I,J,K)=0,(COM,DATE)=""
 ;
 ; get comment from first two lines
 S A=$$L1,Z(1)=Z I 'A D WR(2,FILE) Q
 S A=$$L1,Z(2)=Z I 'A D WR(2,FILE) Q
 S B="KIDS Distribution saved on "
 ; foia patches have no date
 I Z(1)'[B S COM=Z,DATE=$P($$HTE^XLFDT($H),":",1,2) ; FOIA
 E  S COM=Z(2),DATE=$P($P(Z(1),B,2),":",1,2)
 S:COM="" COM=FILE S COM=COM_" ;Created on "_DATE
 ;
 ; now get all build names
 S INS="**INSTALL NAME**"
 F  S A=$$L1 Q:'A  D  Q:J
 .I Z=INS S J=I-1 Q
 .S X=$P(Z,"**KIDS**:",2) Q:X=""
 .F B=1:1:$L(X,U) S Y=$P(X,U,B) S:Y'="" K=K+1,KID(K)=Y,KID("NM",Y)=K
 .Q
 I 'J!'$D(KID) S J=0 D WR(2,FILE)
 Q J
 ;
RPT ; create RPT() of KIDS loaded
 ; vfdrpt(filename,install order) = build name
 ;                              ,0) = 9.7 ien
 ;                              ,"STAT",status) = ien^fmdt;ext^extstat
 ;                              ,"NM",build name) = install order
 ;;                                          PREVIOUSLY INSTALLED
 ;;BUILD NAME                         IEN    IEN     STATUS          DATE
 ;;--------------------------------  -----  -----  --------------  ------------
 N I,J,X,Y,Z,FILE,RPT
 S RPT(1)=$TR($T(RPT+5),";"," "),RPT(2)=$TR($T(RPT+6),";"," ")
 S RPT(3)="---"_$P($T(RPT+7),";",3)
 S J=3,FILE="" F  S FILE=$O(VFDRPT(FILE)) Q:FILE=""  D
 .S I=0 F  S I=$O(VFDRPT(FILE,I)) Q:'I  D
 ..S X=$S(I=1:"",1:">>"),X=$E(X_VFDRPT(FILE,I),1,35)
 ..S $E(X,38)=$J($G(VFDRPT(FILE,I,0)),5)_"  "
 ..S Z="",Y=$O(VFDRPT(FILE,I,"STAT",""))
 ..I Y'="" S Z=VFDRPT(FILE,I,"STAT",Y) D
 ...S X=$J($P(Z,U),5)_"  "_$P(Z,U,3)
 ...S $E(X,63)=$E($P($P(Z,U,2),";",2),1,18)
 ...Q
 ..S J=J+1,RPT(J)=X
 ..Q
 .Q
 D:$D(RPT(4)) RPT^VFDXPD0(.RPT)
 Q
 ;
XTMP ; move KIDS HFS file into the XTMP global for a build
 ; KID(install order)=build name and KID(i.o.,0)=file 9.7 ien
 ; LINE should be at line# just before first INSTALL NAME line
 N A,B,J,X,Y,Z,ARG,ERR,GLB,IEN,INS,RET
 S RET="",I=LINE,INS="**INSTALL NAME**"
 S ERR=0,IEN=0,GLB="^XTMP(""XPDI"",IEN,"
 ;  x = partial global reference   y = value of partial global ref
 ;  very first time thru loop x="**install name**"
 F  S A=$$L1,X=Z,B=$$L1,Y=Z Q:X="**END**"  D  Q:ERR
 .I 'A!'B S ERR=1 D WR(2,FILE) Q
 .I X=INS D  Q
 ..S A=0 I Y'="" S A=+$G(KID("NM",Y)) S:A A=$G(KID(A,0)) S:A IEN=A
 ..I 'A D WR(3,FILE,Y) S ERR=1 Q
 ..Q
 .S @(GLB_X_"=Y")
 .Q
 ; if errors delete all ^XTMP nodes set
 I ERR S X=0 D  Q
 .F  S X=$O(KID("NM",X)) Q:X=""  D
 ..S A=+KID("NM",X),I=$G(KID(A,0))
 ..I I K ^XTMP("XPDI",I) N X,DA,DIK S DA=I,DIK="^XPD(9.7," D ^DIK
 ..Q
 .Q
 S X=0 F  S X=$O(KID("NM",X)) Q:X=""  D
 .N A,J,Y,VFDT,XPDIT,XPDSKPE,XPDT
 .S A=+KID("NM",X),J=+$G(KID(A,0))
 .S VFDT="",Y=$O(KID(A,"STAT","")) S:Y'="" Y=KID(A,"STAT",Y)
 .I Y'="" S VFDT=$P(Y,U,3)_", "_$P($P(Y,U,2),";",2)_", ien="_(+Y)
 .S (XPDIT,XPDSKPE)=1,XPDT(1)=U_X
 .; xpdil1 writes package name
 .N X D PKG^XPDIL1(J) W ?25,$S(VFDT="":"Ok",1:VFDT)
 .Q
 Q
 ;
