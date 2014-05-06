VFDXTPAR ;DSS/LM - Parameter Initialization ;17 Mar 2010 10:57
 ;;2011.1.2;DSS,INC VXVISTA OPEN SOURCE;;28 Jan 2013;Build 86
 ;Copyright 1995-2013,Document Storage Systems Inc. All Rights Reserved
 ;
 ;POST-INSTALL PARAMETER INITIALIZATION API
 ;Word-processing data type is not supported
 ; The following code is adapted from routine MULT^VFDREGP
 ;
EN(VFDROU,VFDOWHAT,VFDATA) ; Initialize parameters
 ; VFDOWHAT - Opt - Action to take.  Default is "ADD"
 ;                  Supported actions: ADD, CHG, DEL
 ;
 ; .VFDATA() - opt - data for this API in a local array where
 ;      VFDATA(s1,s2,s3,s4)=v1^v2^v3 where
 ;         s1 = parameter name      s3 = 0 or 1
 ;         s2 = entity              s4 = numeric incrementor 1,2,3,...
 ;                                       only for s3=1 case
 ;         v1 - opt - instance, default to 1
 ;         v2 - opt - value
 ;         v3 - opt - action to take, default to VFDOWHAT
 ;         There is only one case for s3=0
 ;           VFDATA(param,ent,0,"NDEL")=1
 ;              this deletes all instances of a parameter
 ;
 ; VFDROU - opt - ENTRYREF specifying location of DATA,
 ;      i.e. Literal or expression atom that evaluates to TAG^ROUTINE
 ;
 ; The entry reference specified by VFDATA has the following structure
 ; and is referenced by $T()
 ; First line: ;;PARAMETER^ENTITY^DELETE FLAG
 ;     PARAMETER - req
 ;        ENTITY - opt - default to SYS
 ;   DELETE FLAG - opt - Boolean, deletes all instances
 ;                       default value is 0 (NO)
 ; Second and subsequent lines: ;;INSTANCE^VALUE^OVERRIDE ACTION
 ;        INSTANCE - opt - default to 1
 ;           VALUE - opt - defaults to the null string
 ; OVERRIDE ACTION - opt - defaults to <null> - same values as for
 ;                         VFDOWHAT input parameter
 ; One blank line (;;) denotes END OF PARAMETER^ENTITY specification
 ; Two blank lines denote END OF INITIALIZATION (this call)
 ; 
 ; No data may contain the "~" character!  (meaningful to ADD^VFDCXPR)
 ; Example:
 ; DATA ;;
 ;      ;;MYPARAMETER^entity^Delete all instances flag
 ;      ;;^VALUE OF DEFAULT INSTANCE
 ;      ;;
 ;      ;;ANOTHER PARAMETER^LOC.MY CLINIC
 ;      ;;STATUS^OK TO FILE
 ;      ;;FILTERS^NONE
 ;      ;;
 ;      ;;
 I $G(VFDROU)'?1AN.E1"^"1A.E,'$D(VFDATA) Q
 S VFDOWHAT=$$QAWHAT($G(VFDOWHAT))
 ; move $TEXT references to local array
 I $G(VFDROU)'="" D PARSE
 ;
 N I,J,X,Y,Z,INST,VACT,VAL,VENT,VERR,VINC,VPARM
 S VPARM=0 F  S VPARM=$O(VFDATA(VPARM)) Q:VPARM=""  S VENT=0 D
 .F  S VENT=$O(VFDATA(VPARM,VENT)) Q:VENT=""  K VERR D
 ..I $D(VFDATA(VPARM,VENT,0,"NDEL")) D NDEL^XPAR(VENT,VPARM,.VERR)
 ..S VINC=0 F  S VINC=$O(VFDATA(VPARM,VENT,1,VINC)) Q:'VINC  D
 ...S X=VFDATA(VPARM,VENT,1,VINC)
 ...S INST=$P(X,U),VAL=$P(X,U,2),VACT=$$QAWHAT($P(X,U,3))
 ...S:INST="" INST=1
 ...I VACT="ADD" D ADD^VFDCXPR(,VENT_"~"_VPARM_"~"_INST_"~"_VAL)
 ...I VACT="CHG" D CHG^VFDCXPR(,VENT_"~"_VPARM_"~"_INST_"~"_VAL)
 ...I VACT="DEL" D DEL^VFDCXPR(,VENT_"~"_VPARM_"~"_INST_"~"_VAL)
 ...Q
 ..Q
 .Q
 Q
 ;
PARSE ; parse up the $TEXT lines and place into an array
 N I,J,X,Y,Z,ACT,CNT,DEL,ENT,INST,PARAM,ROU,TAG,VAL
 S TAG=$P(VFDROU,U),ROU=$P(VFDROU,U,2)
 S (ENT,PARAM)="",(J,CNT)=0
 F I=1:1 S X=$T(@(TAG_"+"_I_U_ROU)) Q:X=""  D  Q:CNT=2
 .I X=" ;;" S CNT=CNT+1,(ENT,PARAM)="" Q
 .S X=$P(X,";",3,99)
 .I PARAM="" D  Q
 ..S PARAM=$P(X,U),ENT=$P(X,U,2),DEL=+$P(X,U,3) S:ENT="" ENT="SYS"
 ..I PARAM="" Q
 ..I DEL S VFDATA(PARAM,ENT,0,"NDEL")=1
 ..Q
 .; should have instance line at this point
 .S INST=$P(X,U),VAL=$P(X,U,2),ACT=$$QAWHAT($P(X,U,3))
 .S:INST="" INST=1
 .S J=1+$O(VFDATA(PARAM,ENT,1," "),-1)
 .S VFDATA(PARAM,ENT,1,J)=INST_U_VAL_U_ACT
 .Q
 Q
 ;
QAWHAT(A) S A=$G(A) S:"^ADD^CHG^DEL^"'[A A="ADD" Q A
 ;
TEST ;
 ;;XUSNPI QUALIFIED IDENTIFIER^PKG.KERNEL
 ;;Individual_ID^VA(200
 ;;Organization_ID^DIC(4
 ;;
 ;;VFD MYPARAM^^1
