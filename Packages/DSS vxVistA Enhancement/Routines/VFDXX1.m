VFDXX1 ;DSS/LM - Exception handler; 5/10/07 9:00am
 ;;2009.2;DSS,INC VXVISTA OPEN SOURCE;;01 Dec 2009
 ;Copyright 1995-2009,Document Storage Systems Inc. All Rights Reserved
 ;
 Q
EN ;;[Public] Option VFD REPROCESS VX EXCEPTION
 ; OPTION MENU TEXT: Reprocess vxVistA Exception
 ; 
 N VFDX S VFDX=$$SELX I VFDX<0 W !,"No exception selected." Q
 N VFDMID S VFDMID=$$GET1^DIQ(21603,+VFDX,.04) I $L(VFDMID)
 E  W !,"No HL7 message found for selected exception." Q
 I $$GET1^DIQ(21603,+VFDX,.06,"I")=1 D
 .W !!,"Warning: An HL7 message for this exception has been reprocessed previously.",!
 .Q
 ; Generate list from message control ID - Could be File 773 or File 778
 N VFD773,VFDIEN,VFDLIST,VFDRTN,VFDRSLT S (VFD773,VFDRSLT)=0
 S VFDLIST=$NA(^TMP("VFDXX LIST",$J)) K @VFDLIST N DIRUT,DTOUT,DUOUT
 W !,"Searching for HL7 1.6 messages matching control ID "_VFDMID
 D LIST(VFDMID,VFDLIST,773) ;HL7 1.6
 I $G(@VFDLIST@("DILIST",0))>0 D CONT(773) K @VFDLIST Q:VFD773
 ; Exit if timeout or up=arrow, but continue if user entered a null response
 Q:$D(DTOUT)!$D(DUOUT)
 W !,"Searching for HLO messages matching control ID "_VFDMID
 D LIST(VFDMID,VFDLIST,778) ;HLO
 I $G(@VFDLIST@("DILIST",0))>0 D CONT(778) K @VFDLIST Q
 W !,"No HL7 message reprocessed for control ID='"_VFDMID_"'" ;E.g. Purged message
 K @VFDLIST
 Q
LIST(VFDMID,VFDLIST,VFDFILE,VFDFROM) ;[Private] Wraps LIST^DIC
 ; VFDMID=[Required] Message control ID
 ; VFDLIST=[Optional] $NAME of target root
 ; VFDFILE=[Optional] File to search (773 or 778)
 ; VFDFROM=[Optional] [By reference] Starting value (not included)
 ; 
 Q:'$L($G(VFDMID))  S VFDLIST=$G(VFDLIST,$NA(^TMP("VFDXX LIST",$J))) K @VFDLIST
 S VFDFILE=$G(VFDFILE,773) I "^773^778^"[(U_VFDFILE_U) S VFDVROM=$G(VFDFROM)
 E  Q
 N VFDFLDS S VFDFLDS=$S(VFDFILE=773:".01;15;16",1:".01;.03;.04")
 N VFDNDS S VFDNDX=$S(VFDFILE=773:"C",1:"B")
 D LIST^DIC(VFDFILE,,VFDFLDS,"BP",,.VFDFROM,VFDMID,VFDNDX,,,VFDLIST)
 Q
SELX() ;[Private] Select VXVISTA EXCEPTION entry
 ; Returns IEN^DATE@TIME (same as ^DIC lookup)
 N DIC,X,Y S DIC=21603,DIC(0)="AEQM" D ^DIC
 Q Y
 ;
CONT(VFDFILE) ;[Private] Select/reprocess message for File=VFDFILE
 ; VFDFILE=[Required] 773 or 778
 ; 
 ; Continue...
 ; 
 I "^773^778^"[(U_$G(VFDFILE)_U)
 E  Q  ;File parameter is required
 N VFDTXT S VFDTXT=$S(VFDFILE=773:"HL7 1.6",1:"HLO")
 S VFDIEN=$$PICK() I 'VFDIEN W !,"No "_VFDTXT_" message selected." Q
 I VFDFILE=773 S VFDRTN=$$RTN773(VFDIEN) I '$L(VFDRTN) W !,"Reprocessing aborted." Q
 ; Next ** ARE YOU SURE ** and then REPROC
 W !,"HL7 message "_VFDMID_" will now be reprocessed."
 N DIR K DIRUT S DIR(0)="YA",DIR("A")="Are you sure? " D ^DIR
 I '$D(DIRUT) D:+Y=1 REPROC(VFDIEN,.VFDRTN,VFDFILE)
 Q
PICK() ;[Private] Select from among messages with the same control ID
 I +@VFDLIST@("DILIST",0)=1 Q +$G(@VFDLIST@("DILIST",1,0))
 I +@VFDLIST@("DILIST",0)>20 W !,"Too many messages matching control ID '"_VFDMID_"'" Q 0
 W !!,"Choose from:"
 N VFDI,VFDY F VFDI=1:1:+@VFDLIST@("DILIST",0) D
 .S VFDY=$G(@VFDLIST@("DILIST",VFDI,0))
 .W !,$J(VFDI,3),?5,$P(VFDY,U,3),?30,$P(VFDY,U,4),?35,$P(VFDY,U,5)
 .Q
 N DIR,X,Y K DIRUT
 S DIR(0)="NAO^1:"_+@VFDLIST@("DILIST",0)_":0",DIR("A")="Which message? "
 W ! D ^DIR W ! Q:$D(DIRUT) 0
 Q +$G(@VFDLIST@("DILIST",+Y,0))
 ;
VER773(VFDIEN) ;[Private] HL7 version IEN
 ; VFDIEN=File 773 IEN
 ; 
 Q:'$G(VFDIEN) "" N VFDMSH,VFDFS,VFDXVER
 S VFDMSH=$G(^HLMA(+VFDIEN,"MSH",1,0))
 I '$L(VFDMSH) W !,"MSH segment not found." Q ""
 S VFDFS=$E(VFDMSH,4) Q:'$L(VFDFS) ""
 I '$L(VFDFS) W !,"Could not parse field separator." Q ""
 S VFDXVER=$P(VFDMSH,VFDFS,12)
 I '$L(VFDXVER) W !,"MSH.12 Version ID not found." Q ""
 Q $$FIND1^DIC(771.5,,"X",VFDXVER)
 ;
RTN773(VFDIEN) ;[Private] Processing routine MUMPS code for a File 773 message
 ; VFDIEN=File 773 IEN
 ; 
 ; (T2) Respect variable VFDQUIET
 ; 
 Q:'$G(VFDIEN) "" N VFDSA,VFDMS,VFDEV,VFDVER,VFDPROT,VFDRTN
 S VFDSA=$$GET1^DIQ(773,+VFDIEN,13,"I")
 I 'VFDSA W:'$G(VFDQUIET) !,"Could not identify sending application." Q ""
 S VFDMS=$$GET1^DIQ(773,+VFDIEN,15,"I")
 I 'VFDMS W:'$G(VFDQUIET) !,"Could not identify message type." Q ""
 S VFDEV=$$GET1^DIQ(773,+VFDIEN,16,"I")
 I 'VFDEV W:'$G(VFDQUIET) !,"Could not identify event type." Q ""
 S VFDVER=$$VER773(VFDIEN)
 I 'VFDVER W:'$G(VFDQUIET) !,"Could not identify HL7 version." Q ""
 I VFDSA,VFDMS,VFDEV,VFDVER S VFDPROT=$O(^ORD(101,"AHL1",VFDSA,VFDMS,VFDEV,VFDVER,0))
 E  W:'$G(VFDQUIET) !,"Could not identify the event driver protocol." Q ""
 N VFDIENS,VFDSUB
 D GETS^DIQ(101,VFDPROT,"775*","I",$NA(VFDSUB))
 S VFDIENS=$O(VFDSUB(101.0775,0))
 I 'VFDIENS W:'$G(VFDQUIET) !,"Event driver protocol has no subscribers." Q ""
 I $O(VFDSUB(101.0775,VFDIENS)) W:'$G(VFDQUIET) !,"Event driver protocol has more than one subscriber." Q ""
 S VFDPROT=$G(VFDSUB(101.0775,VFDIENS,.01,"I"))
 I 'VFDPROT W:'$G(VFDQUIET) !,"Could not resolve subscriber protocol IEN." Q ""
 S VFDRTN=$$GET1^DIQ(101,VFDPROT,771) ;(T2) Replace global read
 I '$L(VFDRTN) W:'$G(VFDQUIET) !,"Processing routine not found." Q ""
 Q VFDRTN
 ;
REPROC(VFDIEN,VFDRTN,VFDFILE) ;[Private] Wrap REPROC^HLUTIL and REPROC^HLOAPI3
 ;
 ;VFDIEN=[Required] File 773 or 778 IEN
 ;VFDRTN=[Required for File 773] Processing routine
 ;VFDFILE=[Required] File 773 or 778
 ;
 ;From REPROC^HLUTIL:
 ;
 ;REPROC(IEN,RTN) ; reprocessing message
 ;109      ; IEN- the message IEN in file 773
 ;110      ; RTN- the routine, to be Xecuted for processing the message
 ;111      ; return value:  0 for success, -1 for failure
 ;
 ;From REPROC^HLOAPI3
 ;
 ;Description: This message will re-process an incoming message by placing it on the appropriate incoming queue. If successful the message is set to be purged.
 ;
 ;Input:
 ;  MSGIEN - the ien (file #778) of the message that is to be processed
 ;Output:
 ;  Function returns 1 on success, 0 on failure
 ;  ERROR (pass by reference, optional) - on failure, will contain an error message
 ;
 I "^773^778^"[(U_$G(VFDFILE)_U)
 E  Q  ;File parameter is required
 ;
 I VFDFILE=773 S VFD773=1 D  Q  ;File 773 reprocessing reached
 .I $$REPROC^HLUTIL(VFDIEN,VFDRTN) W !,"Reprocessing attempt failed." Q
 .E  S VFDRSLT=1 W !,"HL7 1.6 Message reprocessed." D REPROC^VFDXX(VFDX)
 .Q
 ; File 778 (Note opposite sense of return, 1=success)
 N VFDERR I $$REPROC^HLOAPI3(VFDIEN,.VFDERR) D  Q
 .S VFDRSLT=1 W !,"HLO Message reprocessed."
 .D REPROC^VFDXX(VFDX)
 .Q
 E  W !,"Error reprocessing HLO message: "_$G(VFDERR)
 Q
