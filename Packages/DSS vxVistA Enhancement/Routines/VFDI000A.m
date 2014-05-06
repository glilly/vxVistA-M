VFDI000A ;DSS/SGM - COMMON KIDS SUPPORT UTILITIES ; 4/3/2012 16:20
 ;;2011.1.2;DSS,INC VXVISTA OPEN SOURCE;;11 Jun 2013;Build 13
 ;Copyright 1995-2013,Document Storage Systems Inc. All Rights Reserved
 ;
 ; this routine first introduced in VFD VXVISTA UPDATE 2011.1.1 T11
 ; this routine is only invoked via VFDI0000
 ; ICR#  SUPPORTED REFERENCE
 ;-----  --------------------------------------------------------
 ;       $$FIND1^DIC
 ;       ^DIK
 ;       ^DDMOD: DELIX, DELIXN
 ;       INSTALDT^XPDUTL
 ;
 Q
 ;
 ;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>><<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
 ;
DDELIXT ; delete traditional index
 ; expects FILE, FLD, IDX, FLG, .VFDM
 N I,X,Y,Z,DIERR,VFDERR,VFDOUT
 S FILE=$G(FILE),FLD=$G(FLD),IDXN=$G(IDXN)
 S:$D(FLG)#2=0 FLG="W" S FLG=$G(FLG)
 I FILE'>0!(FLD'>0)!(IDXN'>0) Q
 D DELIX^DDMOD(FILE,FLD,IDXN,FLG,"VFDOUT","VFDERR")
 S Z=" --- Deleting traditional index "_$NA(^DD(FILE,FLD,1,IDXN))
 D D1(Z) I $D(DIERR) D
 . S X=$$MSG^VFDCFM("V",,,,"VFDERR")
 . D D1($T(1),1),D1("   "_$P(X,U,2))
 . Q
 D D2
 Q
 ;
 ;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>><<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
 ;
DDELIXN ; delete new-style index
 ; expects FILE, IDX, FLG, .VFDM
 N I,X,Y,Z,DIERR,VFDERR,VFDOUT
 S FILE=$G(FILE),IDX=$G(IDX)
 S:$D(FLG)#2=0 FLG="W" S FLG=$G(FLG)
 I FILE'>0!(IDX=0) Q
 D DELIXN^DDMOD(FILE,IDX,FLG,"VFDOUT","VFDERR")
 S Z=" --- Deleting new style index "_IDX_" on file "_FILE
 D D1(Z) I $D(DIERR) D
 . S X=$$MSG^VFDCFM("V",,,,"VFDERR")
 . D D1($T(1),1),D1("   "_$P(X,U,2))
 . Q
 D D2
 Q
 ;
 ;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>><<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
 ;
KIDINS(NM,VFDB) ; determine if a specific Build has been installed
 ; This will find all builds of a specific name which have an INSTALL
 ; COMPLETE TIME.  The return array is sorted by install complete time.
 ; test# and seq# come from fields 61,62 in file 9.7
 ; EXTRINSIC FUNCTION returns -1 or total count
 ;   NM - req - full name of Build
 ;.VFDB - opt - passed by reference
 ;              VFDB(FMdatetime)=test#^seq# (or null)
 N I,J,X,Y,Z
 S X=-1 I $G(NM)'="" D INSTALDT^XPDUTL(NM,.VFDB) S X=VFDB
 Q X
 ;
 ;-----------------------  PRIVATE SUBROUTINES  -----------------------
D1(X) N I S I=1+$O(VFDM(" "),-1),VFDM(I)=X Q
 ;
D2 ; extract compiled template
 N A,I,J,X,Y,Z
 S J=0 F  S J=$O(VFDOUT("DIEZ",J)) Q:'J  S X=VFDOUT("DIEZ",J) D
 . S A=$$T(2),Y=$P(A,"|")_$P(X,U)_$P(A,"|",2)_$P(X,U,3)_"*" D D1(Y)
 . Q
 S X=$G(VFDOUT("DIKZ")) I X'="" S Y=$$T(3)_X_"*" D D1(Y)
 I $G(VFDOUT("DDAUD")) D D1($$T(4))
 Q
 ;
DIK(FILE,IEN) ;
 N I,X,Y,Z,DA,DIK
 S DA=$G(IEN)
 S FILE=$G(FILE),DIK=$S(FILE>0:$G(^DIC(FILE,0,"GL")),1:FILE)
 I DA>0,DIK'="" D ^DIK Q 1
 Q 0
 ;
FIND1(FILE,IENS,FLG,VAL,IDX) ;
 ; called from VFDI000X
 N I,X,Y,Z,DIERR,VFDER
 S IENS=$G(IENS),FLG=$G(FLG)
 S X=$$FIND1^DIC(FILE,$G(IENS),$G(FLG),VAL,.IDX,,"VFDER")
 S:$D(DIERR) X=-1
 Q X
 ;
T(N,PAD) ;
 ;;Error trying to delete cross reference 
 ;;>>>Input Template | compiled into routine set 
 ;;>>>Cross references compiled into routine set 
 ;;>>>A data dictionary audit record was recorded
 N T S T=$T(T+N) S:'$G(PAD) T=$P(T,";",3) Q $TR(T,";"," ")
