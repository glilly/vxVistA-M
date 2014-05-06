VFDXXLU ;DSS/LM - Exception handler User Interface Utilities ; 3/10/2008
 ;;2009.2;DSS,INC VXVISTA OPEN SOURCE;;01 Dec 2009
 ;Copyright 1995-2009,Document Storage Systems Inc. All Rights Reserved
 ;
 ;
 Q
PRE ;[Private] Select start date for exceptions list
 ; Called by option VFD EXCEPTIONS LMUI 'ENTRY ACTION'
 ; 
 N DIR,X,Y
 S DIR(0)="D",DIR("A")="Select START DATE" D ^DIR Q:$D(DIRUT)
 S VFDSDT=+Y,VFDXSDT=$$FMTE^XLFDT(VFDSDT)
 Q
INIT  ;[Private] Populate unfiltered list.
 ;
 N VFDA,VFDL,VFDT,VFDX,VFDZ
 S VFDL=0,VFDT=$G(VFDSDT)-.0000001
 I $G(VALMEVL),$L($G(VALMAR)) K @VALMAR ;For recursive filter
 F  S VFDT=$O(^VFD(21603,"B",VFDT)) Q:'VFDT  D
 .S VFDA=0 F  S VFDA=$O(^VFD(21603,"B",VFDT,VFDA)) Q:'VFDA  D
 ..S VFDZ=$G(^VFD(21603,VFDA,0)) Q:'$L(VFDZ)
 ..I $L($G(VFDFLTR)) X VFDFLTR E  Q  ;Filter
 ..S VFDL=VFDL+1,VFDX=$$FORMAT
 ..D SET^VALM10(VFDL,VFDX,VFDA)
 ..Q
 .Q
 S VALMCNT=VFDL
 Q
FORMAT() ;[Private] Construct a single list record
 ; Assumes VFDA=Exceptions IEN
 ;         VFDZ=Exceptions record 0-node
 ; Returns formated list entry
 ; 
 S VFDX="" Q:'$L($G(VFDZ)) $G(VFDL)  ;Redundant check on VFDZ
 S VFDX=$$SETFLD^VALM1(VFDL,VFDX,"LINE#")
 S VFDX=$$SETFLD^VALM1($$FMTDT($P(VFDZ,U)),VFDX,"DATE/TIME")
 S VFDX=$$SETFLD^VALM1($$CLIP($P(VFDZ,U,3),30),VFDX,"DESCRIPTION")
 S VFDX=$$SETFLD^VALM1($$EPNAM($P(VFDZ,U,7)),VFDX,"PATIENT")
 S VFDX=$$SETFLD^VALM1($$FCLIP($P(VFDZ,U,4),6),VFDX,"HLMID")
 S VFDX=$$SETFLD^VALM1($S($P(VFDZ,U,6)=1:"YES",1:""),VFDX,"REPROCESSED")
 Q VFDX
 ;
FMTDT(VFDFMDT,VFDFLGS) ;[Private] Formate date/time for list
 ; 
 ; VFDFMDT=[Required] FileMan date/time
 ; VFDFLGS=[Reserved] Format instruction flags
 ;
 Q:'$G(VFDFMDT) "" N VFDY
 S VFDY=$P($$FMTE^XLFDT(VFDFMDT,2),":",1,2) ;Short numdate format
 S VFDY=$P(VFDY,"/",1,2)_" "_$P(VFDY,"@",2)
 Q VFDY
 ;
 ; Next was original display format, requiring 18 columns
 Q $TR($E($$FMTE^XLFDT(VFDFMDT),1,18),"@"," ") ;Placeholder format
 ; 
EPNAM(VFDFN,VFDLEN) ;[Private] Format patient name to length specified
 ; VFDFN=[Required] PATIENT IEN
 ; VFDLEN=[Optional] Length
 ; 
 Q:'$G(VFDFN) ""
 N VFDNAM S VFDNAM=$$GET1^DIQ(2,VFDFN,.01) Q:'$L(VFDNAM) ""
 Q $$CLIP(VFDNAM,.VFDLEN)
 ;
IEN773(VFDMID) ;[Private] Return File 773 IEN for Message Control ID
 ; VFDMID=[Required] HL7 Message Control ID
 ; 
 ; 
 Q:'$L($G(VFDMID)) "" N VFDMIEN
 S VFDMIEN=$$FIND1^DIC(773,,"QX",VFDMID,"C","I $P(^(0),U,2)="_""""_VFDMID_"""")
 Q:VFDMIEN>0 VFDMIEN
 Q $O(^HLMA("C",VFDMIEN,""),-1) ;LAST entry with given control ID
 ;
CLIP(VFDX,VFDLEN) ;[Private] Format (shorten) VFDX to length VFDLEN with ".."
 ; VFDX=[Required] String
 ; VFDLEN=[Optional] Length
 ; 
 Q:'$L($G(VFDX)) ""
 Q:'$G(VFDLEN) VFDX
 Q:'($L(VFDX)>VFDLEN) VFDX
 Q $E(VFDX,1,VFDLEN-2)_".."
 ;
FCLIP(VFDX,VFDLEN) ;[Private] Format (shorten) VFDX to length VFDLEN with ".."
 ; VFDX=[Required] String
 ; VFDLEN=[Optional] Length
 ; 
 Q:'$L($G(VFDX)) ""
 Q:'$G(VFDLEN) VFDX
 Q:'($L(VFDX)>VFDLEN) VFDX
 Q ".."_$E(VFDX,$L(VFDX)-VFDLEN+3,$L(VFDX))
 ;
IDSP(VFDA) ;[Private] Display Exception ID data
 ; VFDA=[Required] Exception (File 21603) IEN
 ; 
 ; Called by PROCESS^VFDXXLA
 ;
 Q:'$G(VFDA)  N VFDGETS,VFDIENS,VFDPNAM
 D GETS^DIQ(21603,VFDA,".01;.03;.07",,$NA(VFDGETS))
 S VFDIENS=$O(VFDGETS(21603,"")) Q:'VFDIENS
 S VFDPNAM=VFDGETS(21603,VFDIENS,.07) S:VFDPNAM="" VFDPNAM="UNKNOWN"
 W !!,"You are processing an exception for patient "_VFDPNAM
 W !,"recorded on "_VFDGETS(21603,VFDIENS,.01)
 S VFDESC=VFDGETS(21603,VFDIENS,.03) Q:'$L(VFDESC)
 W " with description -",!?9,VFDESC,!
 Q
LISTLINE(VFDA) ;[Private] Return List line# for exception IEN
 ; VFDA=[Required] Exception (File 21603) IEN
 ; 
 Q:'$G(VFDA)!'$L($G(VALMAR)) "" N VFDI,VFDY S VFDY=""
 S VFDI=0 F  S VFDI=$O(@VALMAR@("IDX",VFDI)) I $D(@VALMAR@("IDX",VFDI,VFDA)) S VFDY=VFDI Q
 Q VFDY
 ;
UPROC(VFDA) ;[Private] Update PROCESSED column for selected exception
 ; VFDA=[Required] Exception (File 21603) IEN
 ;
 Q:'$G(VFDA)  N VFDLINE S VFDLINE=$$LISTLINE(VFDA) Q:'VFDLINE
 N VFDP S VFDP=$$GET1^DIQ(21603,VFDA,.06)
 D FLDTEXT^VALM10(VFDLINE,"REPROCESSED",VFDP)
 Q
POST ;[Private] Clean up
 ; Called by option VFD EXCEPTIONS LMUI 'EXIT ACTION'
 ; 
 K VFDSDT,VFDXSDT
 I $L($G(VFDSLST)) K @VFDSLST,VFDSLST
 Q
PAUSE ;[Private] Wrap PAUSE^VALM1
 ; Note: PAUSE^VALM1 does not NEW variable DIR
 ;       Thus, display can inherit DIR("A") prompt
 ;       
 N DIR D PAUSE^VALM1
 Q
