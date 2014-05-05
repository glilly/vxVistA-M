VFDSUR01 ;DSS/LM - Surveillance HL7 Message Routers and Generators ;April 4, 2011
 ;;2011.1.2;DSS,INC VXVISTA OPEN SOURCE;;28 Jan 2013;Build 153
 ;Copyright 1995-2013,Document Storage Systems Inc. All Rights Reserved
 ;
 Q
A01 ; From protocol VFD ADT-A01 SYN SUR ROUTER
 ; HL variables are defined in context
 ;
 S VFD("EID")=$$FIND1^DIC(101,,"X","VFD ADT-A01 SYN SUR SERVER","B")
 Q:VFD("EID")<0  D INIT^HLFNC2(VFD("EID"),.VFD)
 ;
 N VFDPHI S VFDPHI=$$SUPHI^VFDSURU(VFD("EID")) ;Suppress PHI?
 ; Modifications to message
 N R S R=$NA(VFDMSG("HLS")) F  S R=$Q(@R) Q:R=""  D  ;Translate FS and EC
 .S @R=$TR(@R,HL("FS")_HL("ECH"),VFD("FS")_VFD("ECH"))
 .Q
 ; Remove Z* segments ;5/3/2011 Remove orphan ROL segments
 N VFDCPY,VFDI,VFDJ S VFDJ=0 M VFDCPY=VFDMSG K VFDMSG
 S R=$NA(VFDCPY("HLS")) F VFDI=1:1 Q:'$D(@R@(VFDI))  D
 .Q:@R@(VFDI)?1"Z".E  ;Skip Z*-segment
 .Q:@R@(VFDI)?1"ROL".E  ;Skip ROL-Segment
 .S VFDJ=VFDJ+1 M VFDMSG("HLS",VFDJ)=@R@(VFDI)
 .Q
 ; Insert SFT (optional segment)
 ; Substitute modified PID - Requires vxVistA PID generator
 I $T(^VFDHLPID)]"" S R=$NA(VFDMSG("HLS")) F VFDI=1:1 Q:'$D(@R@(VFDI))  D
 .Q:'(@R@(VFDI)?1"PID".E)  ;Select PID segment
 .S DFN=$G(DFN,+$P(@R@(VFDI),VFD("FS"),4)) ;Movement context or PID.3
 .N VFDX D EN^VFDHLPID(.VFDX,DFN,VFD("FS"),VFD("ECH"),1,,$S(VFDPHI:"P",1:""))
 .I $L($G(VFDX)) K @R@(VFDI) M @R@(VFDI)=VFDX
 .Q
 ; Patch VistA DG1 and read Set ID
 N VFDSETID S VFDSETID=0
 S R=$NA(VFDMSG("HLS")) F VFDI=1:1 Q:'$D(@R@(VFDI))  D
 .Q:'(@R@(VFDI)?1"DG1".E)  ;Select DG1 segment
 .S VFDSETID=$$MAX^VFDSURU(VFDSETID,$P(@R@(VFDI),VFD("FS"),2))
 .I $P(@R@(VFDI),VFD("FS"),7)="" S $P(@R@(VFDI),VFD("FS"),7)="W" ;Type=Working
 .Q
 ; Create DG1 for vxVistA DIAGNOSIS [ICD] field
 S VFDSETID=VFDSETID+1
 N VFDICD,VFDCDE,VFDESC,VFDSEQ3
 I $G(DGPMDA)>0 D  ;DIAGNOSIS [ICD]
 .S VFDICD=$$GET1^DIQ(405,+DGPMDA,21600.01,"I") Q:'(VFDICD>0)
 .K VFDX S VFDX="DG1"_VFD("FS")_VFDSETID
 .S VFDCDE=$$GET1^DIQ(80,VFDICD,.01) ;Code
 .S VFDESC=$$GET1^DIQ(80,VFDICD,3) ;Description
 .S VFDSEQ3=VFDCDE_$E(VFD("ECH"))_VFDESC_$E(VFD("ECH"))_"ICD9"
 .S $P(VFDX,VFD("FS"),4)=VFDSEQ3
 .S $P(VFDX,VFD("FS"),7)="A" ;Type=Admitting
 .Q
 ; Constructed DG1 segment is <245 characters (no continuation frames)
 I $L($G(VFDX)) S @R@($O(@R@(" "),-1)+1)=VFDX ;Append to message ;4/21/2011 - Check VFDX
 ; Generate / serve message
 N VFDRSLT D GENERATE^VFDSURU(.VFD,.VFDMSG,.VFDRSLT)
 ; File message ID, as appropriate here
 Q
