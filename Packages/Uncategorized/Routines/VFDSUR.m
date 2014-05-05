VFDSUR ;DSS/LM - Surveillance HL7 Message Routers and Generators ;April 4, 2011
 ;;2011.1.2;DSS,INC VXVISTA OPEN SOURCE;;28 Jan 2013;Build 153
 ;Copyright 1995-2013,Document Storage Systems Inc. All Rights Reserved
 ;
 Q
EN(VFDEVN) ;ADT message router - Event type is VFDEVN
 I "^A01^"[U_VFDEVN_U ;Extensible list of supported events
 E  Q  ;Not a supported event
 N VFD,VFDMSG,X D COPYMSG($NA(VFDMSG("HLS"))) ;Copy the message
 ; Schedule task to complete processing
 N ZTDESC,ZTDTH,ZTIO,ZTRTN,ZTSAVE,ZTSK
 S ZTDESC="Syndromic Surveillance ADT-"_VFDEVN
 S ZTDTH=$H,ZTIO="",ZTRTN="DQ^VFDSUR"
 S (ZTSAVE("HLMTIENS"),ZTSAVE("HL("),ZTSAVE("VFD*"))=""
 F X="DFN","DGPMDA","DGPMA","DGPMP","DGPMT" S ZTSAVE(X)=""
 D ^%ZTLOAD
 Q
DQ ; Consolidated entry point for ADT event processing
 Q:'($T(@(VFDEVN_"^VFDSUR"_$E(VFDEVN,2,3)))]"")  ;Double-check
 ; Common pre-processing code here
 D @(VFDEVN_"^VFDSUR"_$E(VFDEVN,2,3))
 ; Common post processing code here
 Q
COPYMSG(R) ;Copy HL7 message
 ; R=[Required] $NAME of target array
 Q:'$L($G(R))
 F I=1:1 X HLNEXT Q:HLQUIT'>0  D  ;HL*1.6*56 9-4
 .S @R@(I)=HLNODE,J=0 ;Get first segment node ;1.8*110
 .;Get continuation nodes for long segments, if any
 .F  S J=$O(HLNODE(J)) Q:'J  S @R@(I,J)=HLNODE(J) ;1.8*110
 .Q
 Q
