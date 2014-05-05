VFDXX3 ;DSS/LM - Exception handler; 3/10/2008
 ;;2009.2;DSS,INC VXVISTA OPEN SOURCE;;01 Dec 2009
 ;Copyright 1995-2009,Document Storage Systems Inc. All Rights Reserved
 ;
 Q
EN ;[Public] Implements option VFD EXCEPTIONS REPROC BY APP
 ; Interactive option to reprocess vxVistA exceptions by calling an
 ; associated APPLICATION reprocessing routine.
 ; 
 N DIR,VFDCRLF,X,Y S VFDCRLF=$C(13,10)
 S DIR(0)="P^21603.1",DIR("A")="Select APPLICATION",DIR("S")="I $L($G(^(1)))"
 S DIR("?")="Choose an APPLICATION that has a defined exception processing routine."
 D ^DIR Q:$D(DIRUT)  N VFDAIEN,VFDANAM S VFDAIEN=+Y,VFDANAM=$P(Y,U,2)
 ; 
 I '$D(^VFD(21603,"D",VFDANAM)) D  Q
 .D MSG("No exceptions found for application: "_VFDANAM)
 .Q
 ;
 N VFDMCDE S VFDMCDE=$$GET1^DIQ(21603.1,VFDAIEN,1) ;M code to process exception
 ;
 ; Screen PROCESSED exceptions and SEVERITY > 2 (Informational and debug)
 ; 
 N VFDLIST,VFDXIEN S VFDLIST=$NA(^TMP("VFDXX",$J)) K @VFDLIST
 D FIND^DIC(21603,,"@;.01;.03;.07","X",VFDANAM,,"D","I '($P(^(0),U,6)=1),'($P(^(0),U,5)>2)",,VFDLIST)
 ;
 I +$G(@VFDLIST@("DILIST",0))<1 D  Q
 .D MSG("No unprocessed exceptions found for application: "_VFDANAM)
 .Q
 ;
 I +$G(@VFDLIST@("DILIST",0))=1 S VFDXIEN=$G(@VFDLIST@("DILIST",2,1))
 I $G(VFDXIEN) D PROCESS(VFDXIEN) Q  ;Exactly one exception selected
 ;
 D MSG("The selected application "_VFDANAM_VFDCRLF_"has more than one unprocessed exception.",1)
 ;
 ; Display selected exceptions (if 20 or fewer)
 I +$G(@VFDLIST@("DILIST",0))>20 D MSG("...too many to list.")
 E  D MSG(),DISPLAY(VFDLIST)
 ;
 ; Select PATIENT or DATE RANGE or ALL
 ; 
 ; Let user choose to process ALL, or by PATIENT or DATE/TIME
 K DIR S DIR(0)="S^1:Process ALL exceptions for the application;2:Process exception(s) to be selected by PATIENT;3:Process exceptions for a DATE range"
 S DIR("A")="Please choose 1, 2 or 3"
 S DIR("?")="If you do not choose to process ALL exceptions, additional prompts will be presented, to narrow the selection."
 D ^DIR Q:$D(DIRUT)  N VFDSEL S VFDSEL=+Y
 N VFDOUT ; Application abort flag, similar to DIRUT
 I VFDSEL=2 D SELPT(VFDLIST) Q:$G(VFDOUT)=1
 I VFDSEL=3 D SELDT(VFDLIST) Q:$G(VFDOUT)=1
 ;
 ; List is ready to process, either ALL or subset.
 ; 
 N VFDN S VFDN=+$G(@VFDLIST@("DILIST",0)) D MSG()
 D:VFDSEL>1  ;Subset - Redisplay
 .D MSG("You have selected "_VFDN_" exception"_$S('(VFDN=1):"s",1:"")_" -")
 .I VFDN>20 D MSG("...too many to list.")
 .E  I VFDN>0 D MSG(),DISPLAY(VFDLIST)
 .D MSG()
 .Q
 ;
 ; Called routine should protect VFD* variables, but take no chances...
 N VFDI4249 F VFDI4249=1:1:+$G(@VFDLIST@("DILIST",0)) D  Q:$G(VFDOUT)=1
 .S VFDXIEN=$G(@VFDLIST@("DILIST",2,VFDI4249)) D:VFDXIEN>0 PROCESS(VFDXIEN)
 .Q
 ;
 D:'($G(VFDOUT)=1) MSG("Exception processing complete",1)
 K @VFDLIST
 Q
PROCESS(VFDXIEN,VFDFLG) ; [Private] Process one exception
 ; VFDXIEN=[Required] VXVISTA EXCEPTION IEN
 ; VFDFLG=[Optional] If VFDFLG=1, ignore REPROCESSED flag
 ; 
 ; No return value
 ; 
 I $G(VFDXIEN),$G(VFDFLG)=1!'($P($G(^VFD(21603,VFDXIEN,0)),U,6)=1)
 E  Q
 Q:'$L($G(VFDMCDE))  ;Set by caller (private)
 X VFDMCDE Q:$G(VFDOUT)=1  ;Process exception
 ; Set as REPROCESSED [Removed-Application should call $$REPROC^VFDXX(VFDXIEN)]
 ;N VFDFDA S VFDFDA(21603,VFDXIEN_",",.06)=1 D FILE^DIE(,$NA(VFDFDA))
 Q
DISPLAY(VFDLIST,VFDIOF) ;[Private] Display exceptions in @VFDLIST
 ; VFDLIST=[Required] $NAME of FIND^DIC-format target array
 ; VFDIOF=[Optional] Flag, if value=1, WRITE @IOF before display
 ; 
 I $L($G(VFDLIST)) N VFDLST S VFDLST=$NA(@VFDLIST@("DILIST","ID"))
 E  Q  ;Required paramter
 ;
 I $G(VFDIOF)=1,$L($G(IOF)) W @IOF
 W !?6,"Date@Time",?35,"Exception",?70,"Patient",!,$TR($J("",$G(IOM,80))," ","-")
 N VFDI F VFDI=1:1 Q:'$D(@VFDLST@(VFDI))  D
 .W !,$G(@VFDLST@(VFDI,.01)),?22,$G(@VFDLST@(VFDI,.03)),?63,$E($G(@VFDLST@(VFDI,.07)),1,17)
 Q
MSG(VFDTEXT,VFDLINES) ;[Private] Display message text
 ; VFDTEXT=[Optional] Text to display
 ; VFDLINES=[Optional] Number of new lines to display before text
 Q:$G(VFDQUIET)
 N VFDI F VFDI=1:1:+$G(VFDLINES) W !
 ; To do: Format to IOM, breaking at space or hyphen
 W !,$G(VFDTEXT)
 Q
SELPT(VFDLIST) ;[Private] Select one patient and reduce list to selected patient only
 ; VFDLIST=[Required] $NAME of FIND^DIC-format target array
 ;
 ; On time-out or up-arrow SET VFDOUT=1
 ; 
 N DIR,X,Y S DIR(0)="P^2",DIR("A")="Select PATIENT",DIR("S")="I $D(^VFD(21603,""E"",+Y))"
 S DIR("?")="Choose a PATIENT who is associated with one or more exceptions."
 D MSG(),^DIR I $D(DIRUT) S VFDOUT=1 Q
 N VFDI,VFDJ,VFDPNAM S VFDPNAM=$P(Y,U,2),VFDJ=0
 D MSG("You have chosen to process exceptions for patient "_VFDPNAM_".",1)
 F VFDI=1:1 Q:'$D(@VFDLIST@("DILIST",2,VFDI))  D
 .I $G(@VFDLIST@("DILIST","ID",VFDI,.07))=VFDPNAM D  ;Keep
 ..S VFDJ=VFDJ+1,@VFDLIST@("DILIST",2,VFDJ)=@VFDLIST@("DILIST",2,VFDI)
 ..M @VFDLIST@("DILIST","ID",VFDJ)=@VFDLIST@("DILIST","ID",VFDI)
 ..Q
 .Q:VFDI=VFDJ
 .K @VFDLIST@("DILIST",2,VFDI),@VFDLIST@("DILIST","ID",VFDI)
 .Q
 S $P(@VFDLIST@("DILIST",0),U)=VFDJ
 Q
SELDT(VFDLIST) ;[Private] Select date range and reduce list to selected range only
 ; VFDLIST=[Required] $NAME of FIND^DIC-format target array
 ;
 ; On time-out or up-arrow SET VFDOUT=1
 ; 
 N DIR,X,Y S DIR(0)="D",DIR("A")="Select STARTING DATE"
 S DIR("?")="Select a starting date (inclusive) for range of exceptions to be processed."
 D MSG(),^DIR I $D(DIRUT) S VFDOUT=1 Q
 N VFDSDT S VFDSDT=Y
 S DIR(0)="D",DIR("A")="Select ENDING DATE"
 S DIR("?")="Select an ending date (inclusive) for range of exceptions to be processed."
 D ^DIR I $D(DIRUT) S VFDOUT=1 Q
 N VFDI,VFDJ,VFDT,VFDEDT S VFDEDT=Y,VFDJ=0
 F VFDI=1:1 Q:'$D(@VFDLIST@("DILIST",2,VFDI))  D
 .S VFDT=$P(+$G(^VFD(21603,@VFDLIST@("DILIST",2,VFDI),0)),".") ;Date only
 .I VFDT<VFDSDT!(VFDT>VFDEDT) ;Outside selection range
 .E  D  ;Keep
 ..S VFDJ=VFDJ+1,@VFDLIST@("DILIST",2,VFDJ)=@VFDLIST@("DILIST",2,VFDI)
 ..M @VFDLIST@("DILIST","ID",VFDJ)=@VFDLIST@("DILIST","ID",VFDI)
 ..Q
 .Q:VFDI=VFDJ
 .K @VFDLIST@("DILIST",2,VFDI),@VFDLIST@("DILIST","ID",VFDI)
 .Q
 S $P(@VFDLIST@("DILIST",0),U)=VFDJ
 Q
