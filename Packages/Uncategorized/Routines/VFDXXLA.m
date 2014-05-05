VFDXXLA ;DSS/LM - Exception handler User Interface Actions ; 3/10/2008
 ;;2009.2;DSS,INC VXVISTA OPEN SOURCE;;01 Dec 2009
 ;Copyright 1995-2009,Document Storage Systems Inc. All Rights Reserved
 ;
 ; ICR#  SUPPORTED DESCRIPTION
 ;-----  -------------------------------------------------------------
 ; 2051  $$FIND1^DIC
 ; 2056  GETS^DIQ
 ; 2607  BROWSE^DDBR
 ; 3244  Fileman read of field 2 on file 773 - controlled subscription
 ;         Fileman read of field 200 WP field ^HLMA(D0,"MSH",D1,0)
 ;         direct global read of "C" index
 ; 3273  Read with Fileman of .01 field on file 773 - controlled subsr
 ; 3464  Direct global read of ^HL(772,D0,"IN",D1,0) - controlled subsc
 ;         4069 - another controlled subscr
 ;        10138 - supported FM read of IN multiple
 ;10026  ^DIR
 ;10104  LJ^XLFSTR
 ;10116  CLEAR^VALM1
 ;10117  SELECT^VALM10
 ;Note: not an authorized subscriber to any controlled subscription ICR
 Q
FILTER ;[Private] Implements action FILTER
 ; List Template VFDXXLST
 ; 
 N DIR,X,Y S DIR(0)="S^1:Application;2:HL7 only;3:Patient;4:Reprocessed;5:Severity",DIR("A")="Filter by"
 S DIR("?")="Choose method for filtering exceptions.  Each method identifies a subset of the listed exceptions."
 D ^DIR Q:$D(DIRUT)  N VFDCNTXT S VFDCNTXT=$G(VFDFLTR) N VFDFLTR
 D @("S"_+Y) Q:'$L($G(VFDFLTR))  S:$L(VFDCNTXT) VFDFLTR=VFDCNTXT_" "_VFDFLTR
 D EN^VFDXXL Q  ;Re-enter LM with filter
 Q
CS ;[Private] Clear 'selected' list
 ;
 S VFDSLST=$NA(VFDXTMP("VFDXX",$J,"SEL")) K @VFDSLST
 Q
SL ;[Private] Add to 'selected' subset
 ;
 Q:'$L($G(VFDSLST))  S @VFDSLST@(0)=1+$G(@VFDSLST@(0))
 S @VFDSLST@(@VFDSLST@(0))=VFDA
 Q
S1 ;[Private] Filter by Application
 ;
 S DIR(0)="P^21603.1",DIR("A")="Select APPLICATION",DIR("S")="I $L($G(^(1)))"
 S DIR("?")="Choose an APPLICATION that has a defined exception processing routine."
 D ^DIR Q:$D(DIRUT)
 S VFDFLTR="I $P(VFDZ,U,2)="""_$P(Y,U,2)_""""
 Q
S2 ;[Private] Filter by HL7 only
 ;
 S DIR(0)="Y",DIR("A")="List only exceptions relating to HL7 messages - OK"
 D ^DIR Q:$D(DIRUT)    Q:'(Y=1)
 S VFDFLTR="I $L($P(VFDZ,U,4))!$P($G(^(1)),U,2)!$P($G(^(1)),U,3)"
 Q
S3 ;[Private] Filter by Patient
 ;
 S DIR(0)="P^2",DIR("A")="Select PATIENT",DIR("S")="I $D(^VFD(21603,""E"",Y))"
 S DIR("?")="Choose a PATIENT who has exceptions listed."
 D ^DIR Q:$D(DIRUT)
 S VFDFLTR="I $P(VFDZ,U,7)="_+Y
 Q
S4 ;[Private] Filter by Reprocessed
 ;
 S DIR(0)="Y",DIR("A")="Include only exceptions NOT previously 'processed' - OK"
 D ^DIR Q:$D(DIRUT)    Q:'(Y=1)
 S VFDFLTR="I $P(VFDZ,U,6)'=1"
 Q
S5 ;[Private] Filter by Severity
 ;
 S DIR(0)="S^1:FATAL;2:WARNING;3:INFORMATIONAL;4:DEBUG;5:VERBOSE;6:VERY VERBOSE;9:OTHER",DIR("A")="Exclude SEVERITY"
 S DIR("?")="Include exceptions up to the given severity level."
 D ^DIR Q:$D(DIRUT)
 S VFDFLTR="I $P(VFDZ,U,5)<"_+Y
 Q
SELECT ;[Private] Implements action SELECT
 ; List Template VFDXXLST
 ;
 N DIR,X,Y I VALMCNT=1 D  Q  ;One exception, Select it
 .W !,"You have requested to select exactly one exception."
 .S DIR(0)="Y",DIR("A")="Are you sure" D ^DIR Q:$D(DIRUT)
 .Q:'(+Y=1)
 .N VFDA S VFDA=$O(@VALMAR@("IDX",1,0)) Q:'VFDA
 .D SELECT^VALM10(1,1),CS,SL
 .Q
 ; Replace next with custom ^DIR call
 ;D EN^VALM2(XQORNOD(0)) Q:'($D(VALMY)>1)  D CS
 N VALMY D DIRSEL Q:'($D(VALMY)>1)  D CS
 N VFDA,VFDI,VFDJ,VFDS F VFDI=1:1:VALMCNT  D
 .S (VFDJ,VFDS)=0 F  S VFDJ=$O(VALMY(VFDJ)) Q:'VFDJ!VFDS  D
 ..D SELECT^VALM10(VFDI,0) Q:'(VFDI=VFDJ)  S VFDS=1
 ..S VFDA=$O(@VALMAR@("IDX",VFDI,"")) Q:'VFDA
 ..D SL,SELECT^VALM10(VFDI,1)
 ..Q
 .Q
 Q
CLRSEL ;[Private] Implements action 'Clear all'
 ;
 N DIR,X,Y S DIR(0)="Y",DIR("A")="Clear selected exceptions"
 S DIR("?")="Answer 'Y' to clear the selection list (deselect exceptions)."
 D ^DIR Q:$D(DIRUT)  Q:'(+Y=1)
 D CS Q:'$G(VALMCNT)  ;Empty list
 N VFDI F VFDI=1:1:VALMCNT D SELECT^VALM10(VFDI,0) ;Un-highlight
 Q
DIRSEL ;[Private] Select entries using ^DIR
 ; Substitute this call for EN^VALM2
 ;
 N DIR,X,VFDI,Y
 S DIR(0)="L^1:"_+$G(VALMCNT)_":0"
 D ^DIR Q:$D(DIRUT)
 F VFDI=1:1 S X=$P(Y(0),",",VFDI) Q:'(X?1.N)  S VALMY(X)=""
 Q
DETAILS ;[Private] Implements action DETAILS
 ;
 I '$$ISXLST W !,"No exception(s) selected." D PAUSE^VFDXXLU Q
 N VFDI,VFDFLD,VFDGETS,VFDIENS,VFDK,VFDTXT
 S VFDK=0,VFDTXT=$NA(^TMP("VFDXX",$J,"DETAILS"))
 F VFDI=1:1 S VFDA=$G(@VFDSLST@(VFDI)) Q:'VFDA  D
 .S VFDK=VFDK+1,@VFDTXT@(VFDK,0)=" "
 .K VFDGETS D GETS^DIQ(21603,VFDA,"**","NR",$NA(VFDGETS))
 .S VFDIENS="" F  S VFDIENS=$O(VFDGETS(21603,VFDIENS)) Q:'VFDIENS  D
 ..S VFDK=VFDK+1
 ..S @VFDTXT@(VFDK,0)=$$LJ^XLFSTR(VFDI_".",4)
 ..S VFDFLD="" F  S VFDFLD=$O(VFDGETS(21603,VFDIENS,VFDFLD)) Q:VFDFLD=""  D
 ...S VFDK=VFDK+1
 ...S @VFDTXT@(VFDK,0)="    "_$$LJ^XLFSTR(VFDFLD_":",20)
 ...S @VFDTXT@(VFDK,0)=@VFDTXT@(VFDK,0)_VFDGETS(21603,VFDIENS,VFDFLD)
 ...Q
 ..Q
 .Q
 ;
 D BROWSE(VFDTXT,"Exception details") K @VFDTXT
 Q
DSPLHL7 ;[Private] Implements action HL7 DISPLAY
 ;
 I '$$ISXLST W !,"No exception(s) selected." D PAUSE^VFDXXLU Q
 N X,Y,Z,VFD1,VFDA,VFDHLST,VFDI,VFDJ,VFDMIEN,VFDOK,VFDX,VFDZ
 S VFDJ=0
 F VFDI=1:1 S VFDA=$G(@VFDSLST@(VFDI)) Q:'VFDA  D
 .S VFDZ=$G(^VFD(21603,VFDA,0)) Q:'VFDZ
 .S VFD1=$G(^VFD(21603,VFDA,1))
 .S X(1)=$P(VFDZ,U,4),X(2)=$P(VFD1,U,2),X(3)=$P(VFD1,U,3)
 .I $L(X(1))!X(2)!X(3) S VFDJ=VFDJ+1,VFDHLST(VFDJ)=X(1)_U_X(2)_U_X(3)
 .Q
 I 'VFDJ W !,"No HL7 data recorded for selected exceptions." D PAUSE^VFDXXLU Q
 ; Attempt to resolve missing IENs as pre-HLO HL7 message
 F VFDI=1:1 Q:'$D(VFDHLST(VFDI))  I '$P(VFDHLST(VFDI),U,2) D
 .S VFDX=$P(VFDHLST(VFDI),U)
 .; To do: Call $$IEN773^VFDXXLU for next
 .S VFDMIEN=$$FIND1^DIC(773,,"QX",VFDX,"C","I $P(^(0),U,2)="_""""_VFDX_"""")
 .I VFDMIEN S $P(VFDHLST(VFDI),U,2)=VFDMIEN ;ONLY (Exact match)
 .E  S $P(VFDHLST(VFDI),U,2)=$O(^HLMA("C",VFDX,""),-1) ;LAST
 .Q
 ; Have pre-HLO HL7 message IEN values
 S VFDOK=0 F VFDI=1:1 Q:'$D(VFDHLST(VFDI))!VFDOK  D
 .I $P(VFDHLST(VFDI),U,2) S VFDOK=1
 .Q
 I 'VFDOK W !,"Could not resolve HL7 message IEN(s)." D PAUSE^VFDXXLU Q
 ; Have at least one HL7 pre-HLO message to display
 ; Create formatted aray
 ; 
 N VFDK,VFDSPL S VFDSPL=$NA(^TMP("VFDXX",$J,"HL7MSG")),VFDK=0 K @VFDSPL ;Display array
 F VFDI=1:1 Q:'$D(VFDHLST(VFDI))  D
 .F VFDJ=1,2 S X(VFDJ)=$P(VFDHLST(VFDI),U,VFDJ)
 .S:X(2) X(3)=$$GET1^DIQ(773,X(2)_",",.01,"I")
 .S VFDK=VFDK+1,@VFDSPL@(VFDK,0)=" "
 .S VFDK=VFDK+1,@VFDSPL@(VFDK,0)="HL7 Message "
 .I $L(X(1)) S @VFDSPL@(VFDK,0)=@VFDSPL@(VFDK,0)_"Control ID "_X(1)_" "
 .I 'X(2)!'X(3) S @VFDSPL@(VFDK,0)=@VFDSPL@(VFDK,0)_"not found." Q
 .E  S @VFDSPL@(VFDK,0)=@VFDSPL@(VFDK,0)_"(HLMTIENS "_X(2)_")"
 .S VFDK=VFDK+1,@VFDSPL@(VFDK,0)=" " ;Blank line
 .S VFDK=VFDK+1,@VFDSPL@(VFDK,0)=$G(^HLMA(X(2),"MSH",1,0))
 .S VFDK=VFDK+1,@VFDSPL@(VFDK,0)=""
 .F VFDJ=1:1 Q:'$D(^HL(772,X(3),"IN",VFDJ,0))  S Y=^(0) D
 ..S:'$L(Y) VFDK=VFDK+1
 ..S @VFDSPL@(VFDK,0)=$G(@VFDSPL@(VFDK,0))_Y
 ..Q
 .Q
 D BROWSE(VFDSPL,"HL7 Message Display") K @VFDSPL
 ;
 Q
BROWSE(VFDREF,VFDTITLE) ;[Private] Browse text in $NA(VFDREF)
 ; VFDREF=[Required] $NA(source array containing text)
 ; VFDTITLE=[Optional] Title
 ;
 I $T(BROWSE^DDBR)]"" N IOIL ;Required for browser!
 E  W !,"Message browser is not configured." D PAUSE^VFDXXLU Q 
 D CLEAR^VALM1,BROWSE^DDBR(.VFDREF,,.VFDTITLE),PAUSE^VFDXXLU
 ;
 Q
ISXLST() ;[Private] 1=TRUE if and only if selection list is not empty
 ; If selection list is undefined or if list contains no entries, return 0
 ; 
 Q:'$L($G(VFDSLST)) 0
 Q:'($D(@VFDSLST)>1) 0
 Q 1
 ;
PROCESS ;[Private] Implements action PROCESS
 ; List Template VFDXXLST
 ;
 N DIR,X,Y I '$L($G(VFDSLST)) W !,"No exceptions selected." D PAUSE^VFDXXLU Q
 E  I '$G(@VFDSLST@(0)) W !,"No exceptions selected." D PAUSE^VFDXXLU Q
 W !,"You have requested to process "_@VFDSLST@(0)_" exception"_$S(@VFDSLST@(0)=1:"",1:"s")_"."
 S DIR(0)="Y",DIR("A")="Are you sure" D ^DIR Q:$D(DIRUT)
 Q:'(+Y=1)
 ;
 D CLEAR^VALM1 ; Prepare screen for non List-Manager code
 N VFD21603,VFDMCDE S VFD21603=0 F  S VFD21603=$O(@VFDSLST@(VFD21603)) Q:'VFD21603  D
 .S VFDMCDE=$$MCODE($G(@VFDSLST@(VFD21603))) Q:'$L(VFDMCDE)  ;Application PROCESSING ROUTINE
 .D IDSP^VFDXXLU($G(@VFDSLST@(VFD21603))) ;Display exception ID data
 .D PROCESS^VFDXX3(@VFDSLST@(VFD21603),1) ;Call PROCESS - Ignore REPROCESSED flag
 .D UPROC^VFDXXLU($G(@VFDSLST@(VFD21603))) ;Update 'processed' column
 .Q
 ; List Manager context will be restored by EXIT ACTION code
 ; 
 Q
MCODE(VFDXIEN) ;[Private] PROCESSING ROUTINE for exception's associated APPLICATION
 ; VFDXIEN=[Required] Exception IEN
 ; 
 Q:'$G(VFDXIEN) "" N VFDANM S VFDANM=$$GET1^DIQ(21603,+VFDXIEN,.02)
 Q:'$L(VFDANM) "" N VFDAIEN S VFDAIEN=$$FIND1^DIC(21603.1,,"X",VFDANM,"B")
 Q:'(VFDAIEN>0) "" Q $$GET1^DIQ(21603.1,+VFDAIEN,1)
 ;
