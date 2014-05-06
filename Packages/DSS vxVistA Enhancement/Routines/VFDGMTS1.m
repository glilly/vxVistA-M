VFDGMTS1 ;TPA/SGM - ROUTINE TO CREATE CONTINGENCY HEALTH SUM ;10/24/2003 17:16
 ;;2009.2;DSS,INC VXVISTA OPEN SOURCE;;01 Dec 2009
 ;Copyright 1995-2009,Document Storage Systems Inc. All Rights Reserved
 ;
 ; Adapted from routine ^GMTSZHS1 (Tampa)
 ;;2.7;;;
 ;  this routine is for printing health summaries for contingency
 ;  planning purposes.
 Q
EN ;  Main entry point from TI^, TO^, and B^VFDGMTS
 N:'$D(OUT) OUT N ASLDIV,ASLED,ASLSD,BATCH,COM,DEF,HS,ND,PGM,PLOG,UNL
 N I,J,X,Y,Z,ASL,CNT,DFN,DIV,HS,LOCN,NAME,NEXT,NT,PATH,PUN,ROOT,SDT,STOP
 D INIT Q:OPT=""  Q:DEF(0,"HFS")=""
 S (CNT,NEXT,STOP)=0
 ;
 N VFDNXT,VFDXIT S VFDXIT=0
 F  D LOC Q:VFDXIT
 D EXIT
 Q
 ;
LOC ;
 ; next = inpat or outpat location
 S NEXT=$$INXT I 'NEXT!STOP S VFDXIT=1 Q
 S ROOT=$P(NEXT,U,2),LOCN=$P(NEXT,U,3),NEXT=$P(NEXT,U)
 D HS Q:'HS
 I LOCN?.E1P.E S LOCN=$TR(LOCN,PUN,UNL)
 S VFDNXT=$P($G(^SC($P(NEXT,U),0)),U) ;DSS/LM External location for "CN" cross-reference
 I OPT["I",ROOT=2 S DFN=0 I VFDNXT]"",VFDNXT'="STATE_NH" D
 .F  S DFN=$O(^DPT("CN",VFDNXT,DFN)) Q:STOP!'DFN  D
 ..D GEN(DFN,HS,LOCN),SETP("I"),STOP
 ..Q
 .Q
 I OPT["O",ROOT=44 S SDT=ASLSD D
 .F  S SDT=$O(^SC(NEXT,"S",SDT)) Q:SDT>ASLED!'SDT!STOP  S ASL=0 D
 ..F  S ASL=$O(^SC(NEXT,"S",SDT,1,ASL)) Q:'ASL  S DFN=+^(ASL,0) D
 ...Q:+$G(^DPT(DFN,"S",SDT,0))'=NEXT  Q:"I"'[$P(^(0),U,2)
 ...D GEN(DFN,HS,LOCN),SETP("O"),STOP
 ...Q
 ..Q
 .Q
 Q
 ;
EXIT ;DSS/LM - Move code to next line
 I OPT="A" K ^XTMP(ND,0,"JOB",$J) Q
 I OPT["I" K ^XTMP(ND,"I","JOB")
 I OPT["O" K ^XTMP(ND,"O","JOB")
 S X=$H*86400+$P($H,",",2),Y=$$HTE^XLFDT($H)
 S ROOT=$TR(17000000+$$NOW^XLFDT,".","_")_".LOG"
 I STOP D  Q
 .I $D(^XTMP(ND,"I")),'$D(^("I","END")) S ^("END")=X
 .I $D(^XTMP(ND,"O")),'$D(^("O","END")) S ^("END")=X
 .Q
 I 'STOP,OPT["I" D
 .N NT,PATH
 .S PATH=DEF(0,"I","PATH"),NT=DEF(0,"I","NT")
 .D EX1("I")
 .Q
 I 'STOP,OPT["O" D
 .N NT,PATH
 .S PATH=DEF(0,"O","PATH"),NT=DEF(0,"O","NT")
 .D EX1("O") S Z=""
 .I $G(DEF(0,"NTDEST"))="" S DEF(0,"NTDEST")=DEF(0,"O","PATH")
 .Q
 K ^TMP($J)
 Q
 ;
EX1(NODE) ;  create log file, delete global for NODE = "I" or "O"
 N J,Z,CMD,FILE
 S ^XTMP(ND,NODE,"END")=X
 S J=1+$O(^XTMP(ND,NODE,"LOG","A"),-1)
 S Z="Extracts finished at "_Y
 S ^XTMP(ND,NODE,"LOG",J)=Z
 S FILE="_"_$S(NODE="I":"IN",1:"OUT")_ROOT
 S X=$$GTF^%ZISH($NA(^XTMP(ND,NODE,"LOG",1)),4,PATH,FILE)
 K ^XTMP(ND,NODE,"LOG") K:NODE="O" ^("PAT")
 Q
 ; 
GEN(DFN,TYPE,LOC,BEG,END) ;  call HS to generate health summary
 ;  TYPE = ien to health summary type file
 ;  LOC = name of ward or clinic
 ;  BEG/END - optional - fileman dates - beginning and ending dates
 N I,J,X,X0,Y,Z,FILE,FLG,IOP,LSSN,NAME,NODE,POP,SEP,TAG,%ZIS
 S FILE=$P($$CRFN^VFDGMTS0($S(ROOT=2:LOC,1:""),DFN),".")
 S NODE=$S(ROOT=2:"I",1:"O"),FLG=1
 ;DSS/LM - Replace .htm extension with .txt (contents are not HTML)
 I FILE'="" S FILE=FILE_".txt"
 E  G G1
 I ROOT=44 D
 .I $D(^XTMP(ND,"O","PAT",DFN,HS)) S FILE=^(HS) S FLG=0 Q
 .S Y=1+$G(^XTMP(ND,"O","PAT",DFN),63),^(DFN)=Y
 .S FILE=$P(FILE,".")_$S(Y=64:"",1:$C(Y))_".txt"
 .S ^XTMP(ND,"O","PAT",DFN,HS)=FILE
 .Q
 I FLG D
 .N %ZIS,IOP K POP
 .S %ZIS="",%ZIS("HFSNAME")=PATH_FILE,IOP=DEF(0,"HFS")
 .Q:$$EXISTS(PATH,FILE)   ;DSS/LM - Do not overwrite the same file
 .D ^%ZIS Q:POP  K POP U IO D
 ..N DIV,NAME,PGM,PATH,ND,DEF,HS,RTN
 ..I $G(BEG) S RTN="ENX^GMTSDVR(DFN,TYPE,BEG,END)"
 ..E  S RTN="ENX^GMTSDVR(DFN,TYPE)"
 ..D @RTN,^%ZISC
 ..Q
 .Q
G1 S Y=DIV_U_PATH_U_FILE_U_NT_U_$$HTE^XLFDT($H)_U_$G(POP)
 ;DSS/LM - Add ASL and SDT to outpatient log record
 L +^XTMP(ND,NODE,"LOG") S X=1+$O(^XTMP(ND,NODE,"LOG","A"),-1),^(X)=Y_U_$G(ASL)_U_$G(SDT)
 L -^XTMP(ND,NODE,"LOG")
 Q 
 ;
HS ;  set   HS = health summary type ien for location
 ; PATH = hfs path
 ;   NT = subdirectory path on NT
 ;  DIV = pointer to file 40.8
 N X,Y,Z,HLOC,MCD,NTX,WARD
 S (DIV,HS,HLOC)=0,(NT,PATH)=""
 ;DSS/LM - Insert for OPT="O" case
 I OPT="O" D
 .S HLOC=$$FIND1^DIC(44,,"X",$P(NEXT,U),"B")
 .S Z=$G(^SC(HLOC,0)) I Z]"" S DIV=$P(Z,U,15)
 .Q
 ;DSS/LM - End insert
 I 'HLOC,ROOT=2 D
 .S MCD=+$O(^DIC(42,"B",NEXT,0)) Q:'MCD  S Z=$G(^DIC(42,MCD,0))
 .I Z]"" S DIV=$P(Z,U,11),HLOC=+$G(^DIC(42,MCD,44))
 .Q
 E  I 'HLOC S HLOC=+NEXT,Z=$G(^SC(HLOC,0)) I Z]"" S DIV=$P(Z,U,15)
 S PATH=DEF(0,"O","PATH"),HS=DEF(0,"O"),NT=""
 S PATH=DEF(0,$S(OPT="I":"I",1:"O"),"PATH"),HS=DEF(0,"O"),NT=""
 ;DSS/LM - Parameter-based HS
 S HS=$$GET^XPAR("LOC.`"_HLOC,"VFD GMTS CONTINGENCY TYPE",$S(OPT="I":1,1:2)) Q:HS>0
 N VFDINST S VFDINST=$$GET1^DIQ(44,HLOC,3,"I")
 I VFDINST S HS=$$GET^XPAR("DIV.`"_VFDINST,"VFD GMTS CONTINGENCY TYPE",$S(OPT="I":1,1:2)) Q:HS>0
 S HS=$$GET^XPAR("SYS","VFD GMTS CONTINGENCY TYPE",$S(OPT="I":1,1:2))
 ;DSS/LM - End insert
 Q
 ;end TTUEP temp mods
 ;
INIT ;  initialize variables
 N X,Y,BEG,END,ENV,NOW,START,STR
 S ND="ASLGMTS"
 S NOW=$$NOW^XLFDT
 S BEG=($H-1)*86400+$P($H,",",2) ;  yesterday at current time
 S PUN=$C(34)_"`~!@#$%^&*()-=+[{]}\|;:',<.>/?"
 S UNL="_______________________________"
 S STR="DIVISION^PATH^FILENAME^DESTINATION^TIME^POP"
 D GETENV^%ZOSV S ENV=$P(Y,U,3)
 D DEF^VFDGMTS0
 ;S PLOG=$P(DEF(0,"O","PATH"),".")_".log]"
 L +^XTMP(ND,0)
 S ASLSD=$$FMADD^XLFDT(DT),ASLED=$$FMADD^XLFDT(DT+3)_".25"
 S ^XTMP(ND,0)=$$FMADD^XLFDT(DT,7)_U_DT
 I OPT["I" D
 .S START=$G(^XTMP(ND,"I","START")),END=$G(^("END"))
 .I 'START K ^XTMP(ND,"I")
 .E  I END K ^XTMP(ND,"I")
 .E  I START<BEG K ^XTMP(ND,"I") ;  last extract started >24 hrs ago
 .E  S OPT=$TR(OPT,"I") Q  ; do not allow inpatient to continue
 .S ^XTMP(ND,"I")="",^("I","START")=BEG,^("JOB")=$J_U_ENV
 .S:'$O(^XTMP(ND,"I","LOG",0)) ^(1)=STR
 .Q
 I OPT["O" D
 .S START=$G(^XTMP(ND,"O","START")),END=$G(^("END"))
 .I 'START K ^XTMP(ND,"O")
 .E  I END K ^XTMP(ND,"O")
 .E  I START<BEG K ^XTMP(ND,"O") ;  last extract started >24 hrs ago
 .E  S OPT=$TR(OPT,"O") Q  ; do not allow inpatient to continue
 .S ^XTMP(ND,"O")=0,^("O","START")=BEG,^("JOB")=$J_U_ENV
 .S:'$O(^XTMP(ND,"O","LOG",0)) ^(1)=STR
 .Q
 I OPT="A" S ^XTMP(ND,0,"JOB",$J)=ENV
 ;DSS/LM Construct location list from parameter
 N VFDLI,VFDLIO,VFDLLST,VFDX
 D GETLST^XPAR(.VFDLLST,"SYS","VFD GMTS CONTINGENCY LOC","I")
 S VFDLI=0 F  S VFDLI=$O(VFDLLST(VFDLI)) Q:'VFDLI  D
 .S VFDLIO=$S($P($G(^SC(+VFDLLST(VFDLI),0)),U,3)="W":"I",1:"O")
 .I VFDLIO=OPT S VFDX=$P($G(^SC(+VFDLLST(VFDLI),0)),U)
 .E  Q  ;Populate nodes only for selected patient class
 .S ^XTMP(ND,VFDLIO,+VFDLLST(VFDLI))=VFDX
 .Q
 ;DSS/LM End Insert/modification
 L -^XTMP(ND,0)
 Q
 ;
INXT() ;  called by loops - get next location to be processed
 ;  return LOC_U_FILE_U_LOCNAME or <null> if no more
 L +^XTMP(ND,0) N LOC,X,X0,Y,Z S LOC=""
 I "IA"[OPT,$D(^XTMP(ND,"I")) S (X,X0)=^("I") I '$D(^("I","END")) D
 .S Y=$P(X,U),LOC=$O(^XTMP(ND,"I",Y)) ;S:LOC="" STOP=1
 .I LOC]"" S $P(X0,U)=LOC,$P(X0,U,2)=1+$P(X0,U,2),LOC=LOC_"^2^"_LOC
 .S:X'=X0 ^XTMP(ND,"I")=X0
 .Q
 I LOC]"" G INXT1
 I "OA"[OPT,$D(^XTMP(ND,"O")) S (X,X0)=^("O") I '$D(^("O","END")) D
 .S (LOC,X0)=$O(^XTMP(ND,"O",X0)) ;S:LOC="" STOP=1
 .S:LOC]"" LOC=LOC_"^44^"_LOC
 .S:X'=X0 ^XTMP(ND,"O")=X0
 .Q
INXT1 L -^XTMP(ND,0)
 Q LOC
 ;
SETP(N) ;  increment patient counter in xtmp global
 L +^XTMP(ND,N) S $P(^(N),U,3)=1+$P(^XTMP(ND,N),U,3) L -^XTMP(ND,N)
 Q
 ;
STOP ;  stop check - see if process asked to be stopped every 10 loops
 S CNT=CNT+1 Q:CNT#10
 N X S X=$D(^XTMP(ND,0,"STOP"))
 I 'X,$D(ZTQUEUED) S X=$$S^%ZTLOAD S:X ZTSTOP=1
 S:X STOP=1
 Q
 ;
EXISTS(PATH,FILE) ;;Return 1 (true) if and only if PATH+FILE exists
 ; DSS/LM - Adapted from EXISTS^VFDVCURL
 ; 
 Q:'$L($G(FILE)) 0 N VFDVIN,VFDVOUT,Y
 S VFDVIN(FILE_"*")="",Y=$$LIST^%ZISH($G(PATH),$NA(VFDVIN),$NA(VFDVOUT))
 Q $D(VFDVOUT(FILE))#2
 ;
DESC ;  description of the ^XTMP("ASLGMTS") global where ND="ASLGMTS"
 ;  NODE = "I" or "O" for inpatient or outpatient extracts
 ;  ^xtmp(nd,0) = t+7 ^ dt
 ;  ^xtmp(nd,0,"job",$j) = node this additional extract is running
 ;  ^xtmp(nd,0,"stop") = ""
 ;  ^xtmp(nd,node) = current location^# locs processed^# pats processed
 ;  ^xtmp(nd,node,"job") = $j ^ node extract is running
 ;  ^xtmp(nd,node,"end") = time extract job finished
 ;  ^xtmp(nd,node,"start") = time extract started
 ;  ^xtmp(nd,node,"log",#,0) = log of extracts - see GEN module
 ;  ^xtmp(nd,"o","pat",dfn) = last file extension
 ;  ^xtmp(nd,"o","pat",dfn,hs) = filename for this patient for this
 ;     health summary (avoid regenerating for multiple divisions)
