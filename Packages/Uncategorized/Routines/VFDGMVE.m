VFDGMVE ;DSS/WLC - Edit/Update Standardized Vitals files;
 ;;2009.2;DSS,INC VXVISTA OPEN SOURCE;;01 Dec 2009
 ;Copyright 1995-2009,Document Storage Systems Inc. All Rights Reserved
 ;
 ; IA#   Supported Description
 ;-----  --------------------------------------------------------------
 ;10006  ^DIC
 ;10018  ^DIE
 ;10026  ^DIR
 ; 2052  FILE^DID
 ;       Direct global read of ^DD(file,field) for all fields and
 ;         files: 120.51, 120.52, 120.53, 120.55 - No associated IA
 ;
 Q
EN ;
 N I,J,X,Y,VFD
 D FILES(.VFD)
 S Y=2
 S VFD("A",1)="    Select File"
 S VFD("A",2)=""
 S I=0 F J=1:1 S I=$O(VFD(I))  Q:'I  D
 .S Y=Y+1,VFD("A",Y)=$J(J,2)_". "_VFD(I,"LST")
 .Q
 S VFD("CNT")=J-1
 S Y=Y+1,VFD("A",Y)="   "
 S X="",$P(X,"-",VFD("MAX")+12)="",VFD("A",2)="    "_X
 ;
FILE S Y=$$DIR Q:Y<1  D ADD(+Y) G FILE
 ;
 ;-----------------------  PRIVATE SUBROUTINES  -----------------------
ADD(FILE) ; ADD/EDIT
 N I,X,Y,Z,DA,DIC,DIE,DLAYGO,DTOUT,DUOUT,VFDR,XUMF
 S XUMF=1,X=""
 S I=0 F  S I=$O(^DD(FILE,I)) Q:'I  S X=X_I_";"
 S VFDR=X,DIC("DR")=X,DIC=FILE,DLAYGO=1,DIC(0)="QAEMLOB" D ^DIC
 I +Y,'$P(Y,U,3) S DIE=VFD(FILE,"GLOBAL NAME"),DA=+Y,DR=VFDR D ^DIE
 Q
DIR() ;
 N X,Y,DIR,DIROUT,DIRUT,DTOUT,DUOUT
 M DIR("A")=VFD("A")
 S DIR("A")="    Enter file to edit"
 S DIR(0)="NO^1:"_VFD("CNT")
 W @IOF D ^DIR I $D(DIROUT)!$D(DTOUT)!$D(DUOUT) S Y=-1
 Q Y
 ;
FILES(VFD) ; get file information
 N I,X,Y,Z,DIERR,VFDER,VFDI K VFD
 F I=120.51,120.52,120.53,120.55 S VFD(I)=""
 S VFDI=0 F  S VFDI=$O(VFD(VFDI)) Q:'VFDI  D FILE^DID(VFDI,,"NAME;GLOBAL NAME","VFD(VFDI)","VFDER")
 I $D(DIERR) K VFD Q
 S (I,Y)=0 F  S I=$O(VFD(I)) Q:'I  S X=$L(VFD(I,"NAME")) S:X>Y Y=X
 S VFD("MAX")=Y,Y=Y+3,I=0
 F  S I=$O(VFD(I)) Q:'I  S Z=VFD(I,"NAME"),$E(Z,Y)="[#"_I_"]",VFD(I,"LST")=Z
 Q
