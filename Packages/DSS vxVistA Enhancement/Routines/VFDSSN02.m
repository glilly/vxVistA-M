VFDSSN02 ;DSS/SGM - FIX RECORDS MISSING SSNs ; 02/02/2012 14:30
 ;;2011.1.2;DSS,INC VXVISTA OPEN SOURCE;;28 Jan 2013;Build 153
 ;Copyright 1995-2013,Document Storage Systems Inc. All Rights Reserved
 ;
 ; This routine should only be invoked via the VFDSSN routine
 ; ICR#  Supported Description
 ;-----  ----------------------------------------------------------
 ;       Direct global read of ^DPT(DFN,0)
 ;       Update of field 9, file 2
 ;
 ;DESCRIPTION OF KEY LOCAL VARIABLES FOR FIXSSN
 ; Return array  @VFDLIST@("B",name,dfn) = new pseudo-ssn value^old ssn
 ;               @VFDLIST@("RPT",n)      = report of ssn changes
 ;               @VFDLIST@("ERR",n)      = error report
 ; Input parameters
 ;   VFDMODE [ 1 - actually update SSNs
 ;           [ R - replace existing non-vxVistA compliant SSN values
 ;                 with one that is compliant where compliant vxVistA
 ;                 pseudo-SSN formats are:
 ;                   800000000+DFN, 900000000+DFN, 666000000+DFN
 ;   VFDWR - Boolean flag indicating whether or not to do screen writes
 ;           Default to 0:no screen writes
 ;  VFDERR - private variable
 ;    @VFDERR@("NULL"," ",DFN)="" -      no ^DPT(DFN,0)
 ;    @VFDERR@("NOLOCK",name,DFN)="" -   no Lock of ^DPT(DFN,0)
 ;    @VFDERR@("ERRFILE",name,DFN)=msg - unsuccessful update of SSN
 ;
 ;-----------------------------  Fix SSNs  ----------------------------
FIXSSN(VFDLIST,VFDMODE,VFDWR) ;
 ; VFDLIST - opt - named return array of patient SSN changes
 ; VFDMODE - opt - multivalued parameter
 ;   VFDWR - opt - Boolean write flag
 ;
 N I,J,X,X0,Y,Z,CNT,DFN,NAME,PSSN,SSN,TIME,TOT,VFDA,VFDERR
 S VFDERR=$NA(^TMP("VFDSSN02",$J))
 S:'$D(@VFDLIST) VFDLIST=$NA(^TMP("VFDSSN02",$J_"R"))
 K @VFDERR,@VFDLIST
 S TIME=$P($H,",",2),(CNT,TOT)=0,VFDMODE=$G(VFDMODE),VFDWR=+$G(VFDWR)
 S I=0 F  S I=$O(^DPT(I)) Q:'I  S TOT=TOT+1
 Q:'TOT  D F3
 D F4,F5 Q:'VFDWR
 F Z="RPT","ERR" I $D(@VFDLIST@(Z)) D F2("   ") D
 .S I=0 F  S I=$O(@VFDLIST@(Z,I)) Q:'I  D F2(@VFDLIST@(Z,I))
 .Q
 K @VFDERR I $QS(VFDLIST,2)=($J_"R") K @VFDLIST
 Q
 ;
F1 ; count number of records
 N T,Y S CNT=CNT+1,T=100*CNT/TOT
 S Y=$J(T,8,1)_"% of total patients checked" D F2(.Y)
 Q
 ;
F2(X,BLANK) ; write out input array using XPDUTL
 I $D(X),$G(VFDWR)=1 D MES^XPDUTL("   "):$G(BLANK),MES^XPDUTL(.X)
 Q
 ;
F3 ; generate SSNs for patients
 N X,Y,DFN,NAME,PSSN,SSN,VFDA,X0
 S DFN=0 F  S DFN=$O(^DPT(DFN)) Q:'DFN  S X0=$G(^(DFN,0)) D
 . I VFDWR,$$TIMECK D F1
 . I X0="" S @VFDERR@("NULL"," ",DFN)="" Q
 . S SSN=$P(X0,U,9),NAME=$P(X0,U)
 . S PSSN=$$GSSN^VFDSSN(DFN)
 . I SSN'="",SSN=PSSN Q
 . ; ssn valued and value is vxvista gen'd
 . I SSN'="",$$ISGEN^VFDSSN(DFN,SSN)=1 Q
 . ; ssn valued and flag indicates no replace with vxvista gen'd
 . I SSN'="",VFDMODE'["R" Q
 . ; SSN="" or SSN'="" & not vxvista gen'd & flag says replace
 . S @VFDLIST@("B",NAME,DFN)=PSSN_U_SSN
 . Q:VFDMODE'[1 ; in test mode only
 . L +^DPT(DFN,0):2 E  S @VFDERR@("NOLOCK",NAME,DFN)="" Q
 . K VFDA S VFDA(2,DFN_",",.09)=PSSN,X=$$FILE^VFDSSN(.VFDA)
 . L -^DPT(DFN,0)
 . I +X=-1 S @VFDERR@("ERRFILE",NAME,DFN)=$P(X,U,2)
 . Q
 Q
 ;
F4 ; formatted display of records which changed
 ; returns the @VFDLIST@("RPT")
 N I,L,X,Y,Z,DFN,NAME,SSNEW,SSNOLD,VFDR
 I '$D(VFDMODE) N VFDMODE S VFDMODE=""
 S Y=1 S:VFDMODE'[1 Y=2 S VFDR(1)=$$FT(Y)
 S VFDR(2)=$$FT(3),VFDR(3)=$$FT(4)
 S L=3,Z=$NA(@VFDLIST@("B"))
 F  S Z=$Q(@Z) Q:Z=""  Q:$QS(Z,3)'="B"  D
 .S NAME=$QS(Z,4),DFN=$QS(Z,5),Y=@Z,SSNEW=$P(Y,U),SSNOLD=$P(Y,U,2)
 .S Y="   "_$J(DFN,7)_"   "_NAME
 .S $E(Y,46)=$J(SSNOLD,9)_$J(SSNEW,11)
 .S L=L+1,VFDR(L)=Y
 .Q
 I L>3,VFDMODE'[1 S L=L+1,VFDR(L)=$$FT(5)
 I L=3 S VFDR(4)=$$FT(6)
 M @VFDLIST@("RPT")=VFDR
 Q
 ;
F5 ; formatted display of errors encountered
 ; returns @vfdlist@("err")
 ;   processes @vfderr@(x) for x = errfile, nolock, null
 Q:'$D(@VFDERR)
 N I,L,X,Y,Z,ZX,DFN,NAME,NODE,VAL,VFDR
 S L=0
 F NODE="ERRFILE","NOLOCK","NULL" S ZX=$NA(@VFDERR@(NODE)) D
 .Q:'$D(@ZX)
 .S I=$S(NODE="ERRFILE":7,NODE="NOLOCK":9,1:10)
 .S L=L+1,VFDR(L)=$$FT(I),L=L+2,VFDR(L)=$$FT(8)
 .F  S ZX=$Q(@ZX) Q:ZX=""  Q:$QS(ZX,1)'=NODE  D
 ..S NAME=$QS(Z,2),DFN=$QS(Z,3),VAL=@Z
 ..S X=NAME_" [#"_DFN_"]",L=L+1,VFDR(L)=X
 ..I VAL'="" S L=L+1,VFDR(L)="     "_VAL
 ..Q
 .S L=L+1,VFDR(L)=""
 .Q
 M @VFDLIST@("ERR")=VFDR
 Q
 ;
TIMECK() ;
 N A,T S T=$P($H,",",2) S:T<TIME T=T+86400 Q:(T-TIME)<180 0
 S TIME=$P($H,",",2) Q 1
 ;
FT(A) ; text for reports
 ;;Report of Patient Records Whose SSN Value Was Changed
 ;;Report of Patient Records Whose SSN Value Would Be Changed
 ;;  DFN          NAME                        OLD SSN    NEW SSN
 ;;--------  ------------------------------  ---------  ---------
 ;;Updates to SSN were not actually performed!
 ;;No records found requiring an SSN update
 ;;Errors: Unsuccessful updates of new pseudo-SSN values
 ;;--------------------------------------------------------------------
 ;;Errros: No update done as was unsuccessful in locking patient record
 ;;Errors: These DFN patient records have no ^DPT(DFN,0) node
 Q $TR($T(FT+A),";"," ")
