VFDGMTS ;DSS/LM - Health Summary Utilities ;October 16, 2008
 ;;2009.2;DSS,INC VXVISTA OPEN SOURCE;;01 Dec 2009
 ;Copyright 1995-2009,Document Storage Systems Inc. All Rights Reserved
 Q
DQ ;From scheduled task VFD GMTS CONTINGENCY TASK
 ; Controlled by parameter settings
 ; 
 N VFDLI,VFDLST D:'$D(DUZ) DUZ
 D GETLST^XPAR(.VFDLLST,"SYS","VFD GMTS CONTINGENCY LOC","I")
 S VFDLI=0 F  S VFDLI=$O(VFDLLST(VFDLI)) Q:'VFDLI  D LOC(VFDLLST(VFDLI))
 Q
LOC(GMTSSC) ;[Private] Each location - Interface to MAIN^GMTSPL
 ; VFDLOC=Required Hospital Location IEN
 ; 
 Q:'$G(GMTSSC)  N GMTSTYP S GMTSTYP=$$TYPE(GMTSSC) Q:'GMTSTYP
 S GMTSSC=GMTSSC_U_$$GET1^DIQ(44,+GMTSSC,.01)_U_$$GET1^DIQ(44,+GMTSSC,2,"I")
 N VFDFILE,VFDLIM,VFDPATH
 S VFDPATH=$$GET^XPAR("SYS","VFD GMTS CONTINGENCY PATH")
 S:'$L(VFDPATH) VFDPATH=$$PWD^%ZISH
 S VFDLIM=$$DLIM I $E(VFDPATH,$L(VFDPATH))=VFDLIM
 E  S VFDPATH=VFDPATH_VFDLIM
 S VFDFILE="VFDGMTS-working-"_$TR($$NOW^XLFDT,".","_")_"-"_$R(100000)_".dat"
 N %ZIS,IO,IOP,POP
 S IOP="HFS",%ZIS("HFSMODE")="W",%ZIS("HFSNAME")=VFDPATH_VFDFILE D ^%ZIS Q:POP
 U IO D MAIN^GMTSPL,^%ZISC
 D PARSE(VFDPATH,VFDFILE)
 Q
PARSE(VFDPATH,VFDFILE) ;[Private] Parse working file. Generate contingency files.
 ; VFDPATH=[Required] HFS path for both input and output
 ; VFDFILE=[Required] HFS file for INPUT
 ; 
 N VFDR S VFDR=$NA(^TMP("VFDGMTS",$J)) K @VFDR
 I $$FTG^%ZISH(VFDPATH,VFDFILE,$NA(@VFDR@(1)),3)
 E  Q
 N VFDATA,VFDELETE,VFDBEGP,VFDENDP,VFDI,VFDINP,VFDJ,VFDX
 S VFDBEGP=$$GET^XPAR("SYS","VFD GMTS BEGIN PATIENT PATTERN")
 S VFDENDP=$$GET^XPAR("SYS","VFD GMTS END PATIENT PATTERN")
 S:'$L(VFDBEGP) VFDBEGP="1""Location: "".E1""Printed: "".E"
 S:'$L(VFDENDP) VFDENDP="1""*** END ***"".E1""pg."".E1""*"".E"
 S VFDINP=0 ;Patient data context flag
 F VFDI=1:1 Q:'$D(@VFDR@(VFDI))  S VFDX=@VFDR@(VFDI)  D
 .S:VFDX?@VFDBEGP VFDINP=1,VFDJ=0 Q:'VFDINP  K:'VFDJ VFDATA
 .S VFDJ=VFDJ+1,VFDATA(VFDJ)=VFDX
 .I VFDX?@VFDENDP D OUT S VFDINP=0
 .Q
 K VFDELETE S VFDELETE(VFDFILE)="" I $$DEL^%ZISH(VFDPATH,$NA(VFDELETE))
 E  D XCPT(,"VFDGMTS","$$DEL~%ZISH failed",,3,VFDFILE)
 H 1 ;Wait one second
 Q
OUT ;[Private] Write one output file (one patient) - Called by PARSE
 ; Assumes PARSE context
 ; VFDPATH and VFDATA must exist
 ; 
 N VFDPFILE,VFDID,VFDNAME
 S VFDID=$$SSN($G(VFDATA(3))),VFDNAME=$$NAME($G(VFDATA(3)))
 Q:'($L(VFDID)+$L(VFDNAME))
 S VFDPFILE="VFDGMTS-"_$TR(VFDNAME,", ","__")_"-"_VFDID_"-"_$J_".txt"
 I $$GTF^%ZISH($NA(VFDATA(1)),1,VFDPATH,VFDPFILE)
 E  D XCPT(,"VFDGMTS","$$GTF~%ZISH failed",,3,VFDPFILE)
 Q
NAME(X) ;[Private] Extract NAME from X - Called by ONE
 ; To do: parameter definition (extract from any format record)
 ; 
 N I,L,Y S Y=$P($G(X)," ",1,3)
 F I=1:1:3 S L=$L(Y) Q:'($E(Y,L)=" ")  S Y=$E(Y,1,$L(Y)-1)
 Q Y
 ; 
SSN(X) ;[Private] Extract SSN from X - Called by ONE
 ; To do: See note under NAME (above)
 ;
 N I F I=1:1:$L(X) Q:$E(X,I)=" "
 F I=I:1:$L(X) Q:$E(X,I)?1N
 Q $TR($E(X,I,I+10),"-")
 ;
TYPE(VFDLOC) ;[Private] Return location-specific type
 ; or default to SYSTEM type
 ; VFDLOC=[Required] HOSPITAL LOCATION IEN
 ; 
 N VFDTYPE S VFDTYPE="" Q:'$G(VFDLOC) VFDTYPE
 S VFDTYPE=$$GET^XPAR("LOC.`"_+VFDLOC,"VFD GMTS CONTINGENCY TYPE")
 Q $S(VFDTYPE:VFDTYPE,1:$$GET^XPAR("SYS","VFD GMTS CONTINGENCY TYPE"))
 ;
DLIM() ;[Private] Return path delimiter for this OS
 ;
 N VFDOS S VFDOS=$$OS^%ZOSV
 Q $S(VFDOS="NT":"\",VFDOS="VMS":"]",VFDOS["IX"!(VFDOS["UX"):"/",1:"\")
 ;
DUZ ;[Private] If called from outside M, set DUZ
 S U="^" D DUZ^XUP(.5)
 Q
XCPT(VXDT,APPL,DESC,HLID,SVER,DATA,VFDXVARS) ;;[Private] Record exception
 ; Wraps vxVistA exception handler
 I $T(XCPT^VFDXX)]"" D XCPT^VFDXX(.VXDT,.APPL,.DESC,.HLID,.SVER,.DATA,.VFDXVARS)
 Q
 ;
 ; ** The following entry points are adapted from routine GMTSZHS by Steve McPhelan  **
 ; 
GMTSZHS ;TPA/SGM - PROGRAMMER MENU DRIVER FOR CONTIN HS PKG ;04/08/2001 19:42
 ;;2.1;Tampa's Electronic Agreements;;Jan 14, 2001;
 ; . . .
 ; . . .
TI ;  scheduled task entry point for inpatient extracts
 N %ZIS,OPT,OUT S %ZIS=0,OPT="I"
 D TIO
 Q
TO ;  scheduled task entry point for outpatient extracts
 N %ZIS,OPT,OUT S %ZIS=0,OPT="O"
 D TIO
 Q
TIO ;
 S OUT=2
 I $G(DUZ)<.5 N DUZ,U S U="^" D DUZ^XUP(.5)
 D EN^VFDGMTS1
 Q
B ;  do both inpatient/outpatient
 D TI,TO
 Q
