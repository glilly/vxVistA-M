VFDCONT0 ;DSS/SGM - CONTINGENCY COMMON UTILITIES; 02/02/2001 14:55
 ;;2011.1.2;DSS,INC VXVISTA OPEN SOURCE;;28 Jan 2013;Build 153
 ;Copyright 1995-2013,Document Storage Systems Inc. All Rights Reserved
 ;;Copyright 1995-2010,Document Storage Systems Inc.,All Rights Reserved
 ;
 ;This routine is ONLY to be invoked from VFDCONT* routines.
 ;
 ;ICR #  SUPPORTED DESCRIPTION
 ;-----  ------------------------------------------------------
 ; 2263  ^XPAR: ENVAL, $$GET
 ; 2320  $$DEFDIR^%ZISH
 ; 2541  $$KSP^XUPARAM
 ; 3546  File 40.8 - controlled subscription - not a subscriber
 ;         Direct global read of field .07 and AD index
 ; 4129  DUZ^XUP - controlled subscription - not a subscriber
 ;10006  ^DIC
 ;10039  File 42, direct global read of fields .01,.015,44
 ;10040  File 44, direct global read of certain fields
 ;10063  $$S^%ZTLOAD
 ;10086  ^%ZIS
 ;10097  GETENV^%ZOSV
 ;10103  ^XLFDT: $$FMADD, $$FMTE, $$NOW
 ;10104  $$UP^XLFSTR
 ;10114  FM read of .01 field, file 3.5
 ;
DEFDIR(P) ; use kernel utility to validate path
 ; if p="" then get default HFS directory from Kernel System Params
 Q $$DEFDIR^%ZISH($G(P))
 ;
HFS(NM) ; return DEVICE file ien for the HFS device or others
 N I,X,Y,Z,DIC,DTOUT,DUOUT
 S X=$S($G(NM)'="":NM,1:"HFS"),DIC=3.5,DIC(0)="" D ^DIC
 Q +Y
 ;
HS(CL) ; return the HS associated with this HOSPITAL LOCATION
 ; if no clinic passed, then return SYS HS_ien
 ; sets up the ^XTMP("VFDCONT",node,"HS",44,clinic_ien)=HS_ien
 ;             ^XTMP("VFDCONT",node,"HS",4,division_ien)=HS_ien
 ;             ^XTMP("VFDCONT",node,"HS","SYS")=HS_ien
 N I,R,X,Y,Z,ENT,FN,INST,MCD,RET,VRET
 S CL=+$G(CL)
 S R=$NA(^XTMP("VFDCONT",NODE,"HS")) I '$D(@R) D
 .; set up division and system defaults
 .D ENVAL^XPAR(.RET,"VFD CONTING HEALTH SUMMARY")
 .; RET(entity,instance)=value
 .S X="RET" F  S X=$Q(@X) Q:X=""  D
 ..S Y=$QS(X,1),ENT=+Y,Y=U_$P(Y,";",2)_"0)",FN=+$P($G(@Y),U,2)
 ..I FN=4.2 S @R@("SYS")=@X
 ..I FN=4 S @R@(4,ENT)=@X
 ..I FN=44 S @R@(44,ENT)=@X
 ..Q
 .Q
 ; if no clinic, return system
 ; if clinic and has health summary, return it
 ; if not, then get division or system default HS
 I 'CL!'$D(^SC(CL,0)) S X=+$G(@R@("SYS")) S:X @R@(44,CL)=X Q X
 S X=$G(@R@(44,CL)) I X>0 Q X
 S Z=^SC(CL,0),INST=$P(Z,U,4),MCD=$P(Z,U,15)
 I 'INST,MCD S INST=$P($G(^DG(40.8,Y,0)),U,7)
 S X=+$G(@R@("SYS")) I INST S Y=+$G(@R@(4,CL)) S:Y X=Y
 I X,CL,'$D(@R@(44,CL)) S ^(CL)=X
 Q X
 ;
HSINP(WARD) ; get HS ien for a ward name
 N I,R,X,Y,Z
 S R=$NA(^XTMP("VFDCONT",NODE,"HS"))
 S Y=$O(^SC("B",WARD,0)) I Y>0 Q $$HS(Y)
 S Y=$O(^DIC(42,"B",WARD,0)) I Y<1 Q 0
 S Z=+$G(^DIC(42,Y,44)) I Z>0 Q $$HS(Z)
 S Z=+$P($G(^DIC(42,Y,0)),U,11)
 S X=+$G(@R@(4,Z)) I 'X S X=+$G(@R@("SYS"))
 Q X
 ;
HSAPPT() ; return the end date for health summaries from appts
 N I,X,Y,Z
 S X=$$XPARGET1("SYS","VFD CONTING DAYS FOR OUTPAT HS","A")
 S:X<1 X=3
 S Y=$$FMADD^XLFDT(DT,X)_".24"
 Q Y
 ;
HSVST() ; return the start date for health summaries from visits
 ; if not explicitly set, then do not get HS from VISIT file
 N I,X,Y,Z
 S X=$$XPARGET1("SYS","VFD CONTING DAYS FOR OUTPAT HS","P")
 I 0[X!(X<0) Q 0
 S Y=$$FMADD^XLFDT(DT,-X)-.000001
 Q Y
 ;
INITGLB(NODE) ; initialize tracking node for multi-threaded jobs
 ; This should only be called from the very first contingency job for
 ; a single contingency report generation cycle.  If you need to start
 ; multi-threads to generate all the reports within this reporting cycle
 ; then those 2nd, 3rd, etc. jobs MUST not call this tag.
 ;
 N X,Y,R,ND,SDT,SYS
 S NODE=$G(NODE),ND="VFDCONT",SDT=$$NOW("T")
 ; check for acceptable contingency report option
 I "^HSI^HSO^MAH^MAR^"'[(U_NODE_U) Q $$ERR(1)
 S R=$NA(^XTMP(ND,0)) L +@R:3 E  Q $$ERR(2)
 S Y=$$FMADD^XLFDT(DT,7)_U_SDT_U_NODE,@R=Y
 L -@R
 S R=$NA(^XTMP(ND,NODE)) L +@R:3 E  Q $$ERR(2)
 K @R S @R@(0,"START")=SDT_U_$$JOBSYS
 I NODE'="HSO" S @R@(0,"LAST")=$NA(^DPT("CN"))
 I NODE="HSO" S @R@(0,"LAST")=0
 L -@R
 Q 1
 ;
INITOS ; initialize partition if called-in from an OS-script
 S U="^"
 N %ZIS,IOP S IOP="NULL" D ^%ZIS
 S DT=$$NOW("D")
 S DTIME=1
 D DUZ^XUP(.5)
 I $G(DUZ(2))="" S DUZ(2)=$$KSP^XUPARAM("INST")
 Q
 ;
JOB ; if additional processors are started call this to set JOB node
 N X S X=$$JOBSYS
 S ^XTMP("VFDCONT",NODE,0,"JOB",$P(X,U),$P(X,U,2))=$$NOW("T")
 Q
 ;
JOBSYS() ; return computer name and $j value
 N Y D GETENV^%ZOSV Q $P(Y,U,3)_U_$J
 ;
NOW(F) ; return the current date.time
 ; F - opt - default to FM date.time, no seconds (T)
 ;           F [ "E" - return %DT compatible external form
 ;           F [ "e" - return external form with space in place of @
 ;           F [ "S" - return date.time w/ seconds
 ;           F [ "T" - return date.time w/o seconds
 ;           F [ "D" - return date only
 N X,Y S F=$G(F) S:F="" F="T"
 S X=$$NOW^XLFDT
 I F'["S" S X=$E(X,1,12) I F'["T" S X=$P(X,".")
 I F'["E",F'["e" Q X
 S X=$$FMTE^XLFDT(X) I F["e" S X=$TR(X,"@"," ")
 Q X
 ;
UP(T) Q $$UP^XLFSTR(T)
 ;
ERR(N) ; error messages
 N X S N=$G(N)
 I N=1 S X="Unregistered contingency report"
 I N=2 S X="Unable to lock global node: "_R
 I N=3 S X="Entity is a required input parameter"
 I N=4 S X="Parameter name is a required input parameter"
 Q "-1^"_X
 ;
 ;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
 ; The following refers to all XPAR* line tags
 ; Input ENT - entity           INST - value of instance
 ;      PARM - parameter name   FORM - format, default to "Q"
GETPARMS(NODE) ; get parameters for contingency report
 N I,J,X,Y,Z,RET
 S PATH=$$XPARGET1("SYS","VFD CONTING PATH",NODE)
 I NODE="MAR" D
 .S MARTYPE=$$XPARGET1("SYS","VFD CONTING MAR DAYS")
 .S:MARTYPE<1 MARTYPE=7
 .Q
 Q
 ;
XPARFORM(F) ; QA XPAR Format input
 S F=$G(F) S:F="" F="Q" S:F?.E1L.E F=$$UP(F)
 Q $S($L(F)'=1:"Q","QEB"'[F:"Q",1:F)
 ;
XPARGET1(ENT,PARM,INST,FORM) ; get a single instance value
 I $G(ENT)="" Q $$ERR(3)
 I $G(PARM)="" Q $$ERR(4)
 I $G(INST)="" S INST=1
 S FORM=$$XPARFORM($G(FORM))
 Q $$GET^XPAR(ENT,PARM,INST,FORM)
