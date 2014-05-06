VFDXXPID ;DSS/LM - Exception handler - HL7 PID segment ; 3/10/2008
 ;;2009.2;DSS,INC VXVISTA OPEN SOURCE;;01 Dec 2009
 ;Copyright 1995-2009,Document Storage Systems Inc. All Rights Reserved
 ;
 ;
 Q
EN1 ;[Public] Patient ID Edit for Exception
 ; Use this entry to edit patient ID, based on PID.2 or PID.3
 ; 
 ; For existing patient, add/change ID
 ; For new patient call VFD ScreenMan registration
 ; 
 ; VFDXIEN=[Required] Exception IEN
 ; 
 I $$FIND1^DIC(.403,,"X","VFDV SPR DETAIL","B") ;Environment check
 E  D ERR("Invalid context - Required patient edit form is missing.") Q
 I $G(VFDXIEN)>0
 E  D ERR("Invalid context - No exception found.") Q
 ; To do: Display exception summary here
 N VFDZ,VFD1 S VFDZ=$G(^VFD(21603,VFDXIEN,0)),VFD1=$G(^VFD(21603,VFDXIEN,1))
 I $P(VFD1,U,3) D ERR("HLO not supported in this version.") Q
 N VFDMIEN S VFDMIEN=$P(VFD1,U,2) S:'VFDMIEN VFDMIEN=$$IEN773^VFDXXLU($P(VFDZ,U,4))
 I 'VFDMIEN D ERR("Could not resolve message IEN from available data.") Q
 ;
 N VFDTIEN S VFDTIEN=$$GET1^DIQ(773,VFDMIEN_",",.01,"I")
 N VFDPID S VFDPID=$$PID(VFDTIEN) ; Extract PID segment from message
 I '$L(VFDPID) D ERR("PID segment not found for HL7 message.") Q
 N VFDHLFS S VFDHLFS=$E(VFDPID,4)
 I '$L(VFDHLFS) D ERR("Invalid PID segment.") Q
 D LISTSEG(VFDPID,"2,3,5,7,8")
 ;
 D EDITPT D PAUSE Q  ;Bypass the following
 ;
 W !!,"If patient is already registered in the system, answer 'Y'[es] to the following"
 W !,"question.  If patient is not previously registered (i.e. is NEW patient),"
 W !,"answer 'N'[o].",!
 N DIR,X,Y S DIR(0)="Y",DIR("A")="Edit existing patient" D ^DIR Q:$D(DIRUT)
 ; Y=0 -> Register new patient, Y=1 -> Edit existing patient
 ; 
 ; Consider calling [VFDV SPR DETAIL] for all edits, as this form is suited
 ; to both new and existing patients.
 ; 
 Q
EDITPT ;[Private] Continuation of EN1, Patient ID exception processing
 ; Edit PATIENT
 ; Optionally reprocess HL7 message
 ; Optionally mark exception as processed
 ; 
 W !!,"Please make note of values that may be needed for patient edit."
 D PAUSE
 N DIC,X,Y S DIC="^DPT(",DIC(0)="AEMQ" W ! D ^DIC
 Q:'($G(Y)>0)  D PAUSE
 N DA,DR,DDSFILE,DDSPAGE,DDSPARM
 S DA=+Y,DR="[VFDV SPR DETAIL]",DDSFILE=2 D ^DDS
 W @$S($G(IOF)]"":$G(IOF),1:"#") ;Clear ScreenMan form
 N DIR S DIR(0)="Y",DIR("A")="Reprocess HL7 message"
 S DIR("?")="Enter 'Y'[es] to request reprocessing the HL7 message"
 D ^DIR Q:$D(DIRUT)  Q:'(Y=1)  N VFDRSLT
 ; VFDXIEN is guaranteed in this context
 S VFDRSLT=$$HL7^VFDXX2(VFDXIEN) I VFDRSLT D  Q
 .W !!,"Request to reprocess exception returned an error:"
 .W !,$P(VFDRSLT,U,2)
 K DIR S DIR(0)="Y"
 S DIR("A")="Do you wish to mark the exception as processed.",DIR("B")="YES"
 D ^DIR Q:$D(DIRUT)  Q:'(Y=1)
 D REPROC^VFDXX(VFDXIEN)
 Q
PID(VFDTIEN) ;[Private] PID segment from File 772 IEN
 ; VFDTIEN=[Required] Message Text IEN
 ;
 Q:'$G(VFDTIEN)  N VFDI,VFDP,VFDQ,VFDX,VFDY
 S (VFDP,VFDQ)=0,VFDY=""
 F VFDI=1:1 Q:VFDQ!'$D(^HL(772,VFDTIEN,"IN",VFDI,0))  D
 .I VFDP,^(0)="" S VFDQ=1 Q
 .I ^(0)?1"PID".E S VFDP=1
 .S:VFDP VFDY=VFDY_^(0)
 .Q
 Q VFDY
PAUSE ;[Private]
 ;
 N X R !,"Press ENTER to continue: ",X:$G(DTIME,300)
 Q
 ;
ERR(VFDTXT) ;[Private] Display error and pause
 ;
 W !,$G(VFDTXT) D PAUSE
 Q
LISTSEG(VFDSEG,VFDSEQ) ;[Private] List fields in segment
 ; VFDSEG=HL7 segment
 ; VFDSEQ=Field list in FOR argument format
 ; 
 I $L(VFDSEG),$L(VFDSEQ) N VFDI,VFDHLFS,VFDTYP
 E  Q
 S VFDHLFS=$E(VFDSEG,4) Q:'$L(VFDHLFS)  S VFDTYP=$E(VFDSEG,1,3)
 W !,"Info:" ;Note that piece# is sequence ID + 1
 X "F VFDI="_VFDSEQ_" W !?10,VFDTYP_"".""_VFDI_"":"",?20,$P(VFDSEG,VFDHLFS,VFDI+1)"
 Q
