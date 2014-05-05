VFDCHFS2 ;DSS/SGM - HOST FILE UTILITIES - CONT ;03/04/2004 15:17
 ;;2009.2;DSS,INC VXVISTA OPEN SOURCE;;01 Dec 2009
 ;Copyright 1995-2009,Document Storage Systems Inc. All Rights Reserved
 ;
 ;  This routine is not directly invokable.
 ;  Please use the entry points in the VFDCHFS routine.
 ;  This routine should only be invoked from VFDCHFS1
 ;  All input parameters are defined in VFDCHFS routine
 ;
DIP ;  run routine that issues its own OPEN call (e.g., EN1^DIP)
 N X,Y,Z,%ZIS,IOP
 Q:$G(RTN)=""
 ;N:$G(VRM)="" VRM N:$G(VPG)="" VPG N:$G(FILE)="" FILE N:$G(PATH)="" PATH
 D SET("VRM^VPG^FILE^PATH")
 S %ZIS("HFSNAME")=PATH_FILE,%ZIS("HFSMODE")="W"
 S IOP="OR WORKSTATION;"_VRM_";"_VPG
 D @RTN,^%ZISC
 Q
 ;
GET(VFD) ;  get report from HFS file and return it GUI
 ;  return 1 if successful, else retrun -1^message
 N X,Y,Z,VFDERR,VFDROOT,VAL
 S VFDROOT=$NA(^TMP("VFDCHFS1",$J))
 K @VFDROOT
 N $ET,$ES S $ET="D ETRAP^VFDCHFS1 Q $G(VFDERR,-1)"
 ;N:'$D(FILE) FILE N:'$D(PATH) PATH N:'$D(DEL) DEL
 D SET("FILE^PATH^DEL")
 S Z("FILE")=FILE,Z("PATH")=PATH
 S VAL=$$FTG^VFDCHFS1($NA(^TMP("VFDCHFS1",$J,1)),.Z) I VAL<0 Q VAL
 I DEL=2!(DEL=1&VAL) S X=$$DEL^VFDCHFS1(PATH,FILE)
 I $G(CTRL) D STRIP^VFDCHFS1(VFDROOT)
 M @VFD=@VFDROOT
 I VFD'=VFDROOT K @VFDROOT
 S X=1 S:'$D(@VFD) X="-1^Either no report generated or unexpected problem encountered"
 I X'=1 S @VFD@(1)=X
 Q X
 ;
RUN(PATH,FILE,MODE,VRM,VPG) ;
 ;  open hfs file, run routine to write to file, close hfs file
 ;  return 1 if succesful, else return -1^message
 N X,Y,Z,%ZIS,IOP
 ;N:$G(VRM)="" VRM N:$G(VPG)="" VPG N:$G(FILE)="" FILE N:$G(PATH)="" PATH N:$G(MODE) MODE
 D SET("VRM^VPG^FILE^PATH^MODE")
 I $G(RTN)="" Q "-1^No program received to run [no RTN]"
 S X=$$OPEN^VFDCHFS1(PATH,FILE,MODE,VRM,VPG)
 I X=-1 Q "-1^Failed to open file"
 S FILE=X D @RTN,CLOSE^VFDCHFS1
 Q 1
 ;
SET(X) ;  initialize any variable just in case not defined
 I X["VRM",'$G(VRM) S VRM=80
 I X["VPG",'$G(VPG) S VPG=66
 I X["FILE",$G(FILE)="" S FILE=$$FILE^VFDCHFS1
 I X["PATH",$G(PATH)="" S PATH=$$PATH^VFDCHFS1
 I X["MODE",$G(MODE)="" S MODE="W"
 I X["DEL",'$G(DEL) S DEL=2
 Q
