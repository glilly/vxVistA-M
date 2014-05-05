VFDXPDB ;DSS/SGM - PATCH UTIL FM FILES ;19 Oct 2010 16:47
 ;;3.1;DSS,INC VXVISTA SUPPORTED;;10 Dec 2012;Build 58
 ;Copyright 1995-2012,Document Storage Systems Inc. All Rights Reserved
 ;
 ;This routine should only be invoked via the VFDXPD routine
 ;
 ;==============  GET KIDS BUILDS IN A PROCESSING GROUP  ==============
BATCH(VFDBATCH,PID,LISTONLY) ;
 ;      PID - req - ien to file 21692.1
 ; LISTONLY - opt - Boolean, if true return VFDBATCH(ien) and
 ;                  VFDBATCH("BAD") only
 ;Extrinsic function
 ;  RETURNS: total# builds or -1^message
 ; .VFDBATCH - Return VFDBATCH = total# builds in group
 ;  VFDBATCH(ien)=val for ien=file 21692 ien
 ;  VFDBATCH("B",buildname)=ien
 ;  VFDBATCH("C",pkg,ver,seq)=ien
 ;  VFDBATCH("D",pkg,ver,patch)=ien
 ;  VFDBATCH("BAD",ien)="" for broken pointer in batch
 ;    where val = build name^pkg^ver^patch#^seq#^description^int stat
 ;                    1       2   3    4     5     6            7
 ;
 N I,J,N,W,X,Y,Z,DESC,NM,PATCH,PKG,SEQ,STAT,TMP,VER,VFDZ
 I $G(PID)<1 Q "-1^No processing group received"
 S LISTONLY=$G(LISTONLY)
 ; batch multiple is dinum'd
 S I=0 F  S I=$O(^VFDV(21692.1,PID,1,I)) Q:'I  D
 .K VFDZ D GETREC(I,"VFDZ") I '$D(VFDZ) S VFDBATCH("BAD",I)="" Q
 .S TMP(VFDZ("PKG"),+VFDZ("VER"),+VFDZ("PATCH"),+VFDZ("SEQ"),I)=VFDZ(0)
 .Q
 S J=0,Z="TMP" F  S Z=$Q(@Z) Q:Z=""  S X=@Z D
 .S J=J+1,VFDBATCH(+X)=$P(X,U,2,99) Q:LISTONLY
 .S NM=$P(X,U,2),PKG=$P(X,U,3),VER=$P(X,U,4),PATCH=$P(X,U,5)
 .S SEQ=+$P(X,U,6)
 .S VFDBATCH("B",NM)=+X
 .S VFDBATCH("C",PKG,VER,SEQ)=+X
 .S VFDBATCH("D",PKG,VER,PATCH)=+X
 .Q
 S VFDBATCH=J
 Q J
 ;
 ;=========================== NAME OF BATCH ===========================
BATCHNM(A) ; A - req - pointer to 21692.1
 ; Extrinsic function returns batch name^batch date or -1^msg
 N I,J,X,Y,Z,IENS,VFDTMP
 I $G(A)<1 Q "-1^No batch record number received"
 S IENS=A_",",X=$$GETS^VFDXPDA("VFDTMP",21692.1,IENS,".01;.02")
 S Y="" K Z M Z=VFDTMP(21692.1,IENS)
 I X>0 S Y=Z(.01,"E")_" ["_Z(.02,"E")_"]"
 Q $S(+X=-1:X,1:Y)
 ;
 ;===================== GET DATA FROM FILE 21692 ======================
GETREC(I,VFDRR) ;
 ;   I - req - ien to file 21692 or .01 field value
 ; VFDRR - opt - named reference to return data
 ;               if <null> then extrinsic function call
 ;                  return ien^name^pkg^ver^patch^seq^desc^stat
 ;               if not null then D w/params, return @VFDRR@(sub)=value
 ;                  where sub = DESC, NM, PATCH, PKG, STAT, SEQ, VER
 ;                  and @VFDRR@(0)=extrinsic function value
 ;
 N X,Y,Z,DESC,FLDS,IENS,NM,PATCH,PKG,SEQ,STAT,VER,VFDNM,VFDTMP
 S Y="",I=$G(I),VFDRR=$G(VFDRR) I I="" G GOUT
 I '$D(^VFDV(21692,I)) S I=$O(^VFDV(21692,"B",I,0)) G:'I GOUT
 S IENS=I_",",FLDS=".01;.05;.06;.061;.07;.1;.9"
 S X=$$GETS^VFDXPDA("VFDTMP",21692,IENS,FLDS,"IE"),Y="" G:X<1 GOUT
 K Z M Z=VFDTMP(21692,IENS)
 S NM=Z(.01,"E"),PKG=Z(.05,"E"),VER=Z(.06,"E"),PATCH=Z(.061,"E")
 S SEQ=+Z(.07,"E"),STAT=Z(.1,"I"),DESC=Z(.9,"E")
 S Y=+IENS_U_NM_U_PKG_U_VER_U_PATCH_U_SEQ_U_DESC_U_STAT
 I VFDRR'="" S @VFDRR@(0)=Y D
 .F X="DESC","NM","PATCH","PKG","SEQ","STAT","VER" S @VFDRR@(X)=@X
 .Q
GOUT Q:VFDRR="" Y  Q
 ;
 ;================= PARSE A BUILD NAME INTO COMPONENTS ================
PARSENM(VFDNM,FLG) ; 6/18/2010 - retired do not call this line
 I $G(FLG) Q "-1^Please use PARSENM in routine VFDXPD0"
 Q
 ;
 ;================  CREATE OR EDIT A PROCESSING GROUP  ================
PID(EDIT,SCR,VNEW) ;
 ;INPUT PARAMS:
 ; edit - opt - Boolean, default to 0, if 1 edit processing group date
 ;  scr - opt - Boolean, if +SCR, filter out completed batches
 ; vnew - opt - Boolean, if +VNEW allow creation of a new batch
 ;Return file 21692.1 ien or -1
 N I,J,X,Y,Z,DIC,VFDX
 S DIC=21692.1,DIC(0)="QAEM"
 S VNEW=$G(VNEW) I $G(VNEW) S DIC(0)="QAEML",VNEW=21692.1
 I $G(SCR) S DIC("S")="I '$P(^(0),U,3)"
 I $G(EDIT) S DIC("DR")=.02
 S VFDX=$$DIC^VFDXPDA(.DIC,VNEW)
 I $G(EDIT),'$P(VFDX,U,3) S X=$$DIE^VFDXPDA(21692.1,+VFDX,.02)
 Q $P(VFDX,U,1,2)
 ;
 ;========== ASK IF OUTPUT FORMAT IS DELIMITED OR FORMATTED ===========
EXCEL() ; Boolean return 1 if output delimited
 Q $$EXCEL^VFDXPDA
 ;
 ;===============  ADD KIDS BUILD TO A PROCESSING GROUP  ==============
FILE(PID,REC,VFDARR) ;
 ; PID - req - file 21692.1 ien
 ; REC - opt - file 21692 ien
 ;.ARR - opt - list of file 21692 iens
 N I,J,X,Y,Z,DA,DIERR,VERR,VFDA,VIEN
 Q:$G(PID)<1 0
 I $G(REC)>0 S VFDARR(REC)=""
 S (I,J)=0 F  S I=$O(VFDARR(I)) Q:'I  D
 .Q:$D(^VFDV(21692.1,PID,1,I))
 .S J=J+1,VFDA(21692.11,"+"_J_","_PID_",",.01)=I,VIEN(J)=I
 .Q
 Q:'$D(VFDA) 0
 D UPDATE^DIE(,"VFDA","VIEN","VERR")
 Q:$D(DIERR) -1
 Q 1
 ;
 ;======================= PRIVATE SUBROUTINES =========================
ERR(A,WR) ;
 N T S A=$G(A)
 I A=1 S T="No path or directory received"
 I A=2 S T="No files found"
 I A=3 S T="Filename has a DAT file plus other files"
 I A=4 S T="Filename has multiple files with the same extension: "
 I A=5 S T="No processing group received"
 I A=6 S T="No entries found for the processing group"
 I '$G(WR) Q "-1^"_T
 W !?3,T
 Q
