VFDTIUD ;DSS/JLG - vxVistA Disable Encounter RPC ; 1/30/2013 13:50
 ;;2011.1.2;DSS,INC VXVISTA OPEN SOURCE;;28 Jan 2013;Build 7
 ;Copyright 1995-2013,Document Storage Systems Inc. All Rights Reserved
 ;
 Q
 ;
GET(VFDRSLT,VFDTIUIE) ; RPC: VFD TIU PCEDRW DIS INQ
 ; Determine if encounter is disabled
 ; VFDTIUIE - req - pointer to TIU document tile (#8925.1)
 ; VFDRSULT - return string  1:disable; 0:allow  or -1^msg
 ;
 N X,Y,Z
 I $G(VFDTIUIE)>0 D FIND
 I $G(VFDRSLT)="" D ER(1)
 Q
 ;
 ;-----------------------  PRIVATE SUBROUTINES  -----------------------
ER(N,T) ;
 ;;No IEN received
 ;;TIU Document Definition ien | not found in file 8925.95
 ;;TIU Document Definition ien | found more than once in file 8925.95
 ;
 N A S A=$P($T(ER+N),";",3)
 S:A["|" A=$P(A,"|")_T_$P(A,"|",2)
 S VFDRSLT="-1^"_A
 Q
 ;
FIND ;
 ; vfdt("dilist",#,0) = 8925.95_ien ^ 8925.1_ien ^ 21600.01_int_value
 N I,X,Y,Z,DIERR,FLDS,TOT,VFDER,VFDT
 S FLDS="@;.01I;21600.01I"
 D FIND^DIC(8925.95,,FLDS,"ABPQX",VFDTIUIE,,,,,"VFDT","VFDER")
 S (I,TOT)=0 I '$D(DIERR) F  S I=$O(VFDT("DILIST",I)) Q:'I  D
 . S X=VFDT("DILIST",I,0)
 . I $P(X,U,2)=VFDTIUIE S TOT=TOT+1,TOT(I)=+$P(X,U,3)
 . Q
 I $D(DIERR) S VFDRSLT="-1^"_$$MSG^VFDCFM("E",,,,"VFDER"),TOT=-1
 I TOT=0 D ER(2,VFDTIUIE)
 I TOT>1 D ER(3,VFDTIUIE)
 I TOT=1 S I=$O(TOT(0)),VFDRSLT=TOT(I)
 Q
