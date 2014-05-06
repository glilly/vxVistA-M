VFDCDGW ;DSS/SGM - UTILITIES FOR WARD DATA ;07/30/2003 22:21
 ;;2011.1.2;DSS,INC VXVISTA OPEN SOURCE;;28 Jan 2013;Build 153
 ;Copyright 1995-2013,Document Storage Systems Inc. All Rights Reserved
 ;
 ;
 ; DBIA#  SUPPORTED
 ; -----  ---------  ---------------------------------------
 ;  2051      x      $$FIND1^DIC
 ;  2056      x      ^DIQ: $$GET1, GETS
 ; 10039      x      direct global read of NAME from file 42
 ;                   NOT CURRENTLY SUBSCRIBED TO
 ;  1337  cont sub   direct global read of fields .01,3, file 42.4
 ;  2652             Fileman read .01 field, file 42.4 [pointer allowed]
 ;
 ;
SPEC(VFDC,WARD,FUN) ;  RPC: VFDC WARD PTF SPECIALTY
 ;  return the ptf specialty info for a ward
 ;  WARD - required - name of WARD or pointer to file 42
 ;   FUN - optional - default to 0 - Boolean
 ;         if FUN=1 then extrinsic function, else RPC
 ;  RETURN:
 ;    ptf code ^ specialty name ^ specialty service  [from file 42.4]
 ;    if problems return -1^message
 N X,Y,Z,DIERR,VFD,VFDERR,IEN,RET
 I $G(WARD)="" S RET="-1^No ward received" G OUT
 S X=$$FIND1^DIC(42,,"AQX",WARD,"B",,"VFDERR")
 I X<1,'$D(DIERR) S RET="-1^Ward '"_WARD_"' not found" G OUT
 I $D(VFDERR) S RET="-1^"_$$MSG^VFDCFM("VE",,,,"VFDERR") G OUT
 S X=$$GET1^DIQ(42,X_",",.017,"I",,"VFDERR")
 I X<1,'$D(DIERR) S RET="-1^No PTF Specialty code found for ward: "_WARD G OUT
 I $D(VFDERR) S RET="-1^"_$$MSG^VFDCFM("VE",,,,"VFDERR") G OUT
 S IEN=X_"," D GETS^DIQ(42.4,IEN,".001;.01;3",,"VFD","VFDERR")
 I $D(VFDERR) S RET="-1^"_$$MSG^VFDCFM("VE",,,,"VFDERR") G OUT
 K Z M Z=VFD(42.4,IEN)
 S RET=(+IEN)_U_$G(Z(.01))_U_$G(Z(3))
 ;
OUT I $G(VFDC)="" S VFDC=$G(RET)
 Q:$G(FUN) VFDC Q
