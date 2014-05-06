VFDPTIX ;DSS/SGM - NEW STYLE INDEX CALL FROM FILE 2 ; 06/26/2012 14:55
 ;;2011.1.2;DSS,INC VXVISTA OPEN SOURCE;;28 Jan 2013;Build 153
 ;Copyright 1995-2013,Document Storage Systems Inc. All Rights Reserved
 ;
 ;ICR #  SUPPORTED DESCRIPTION
 ;-----  --------------------------------------------------------------
 ;10063  ^%ZTLOAD - queue a task
 ;         $$TM - is taskman running
 ;
 ;This routine can be called from either a new style or classic cross
 ;reference.  The lines FIELDS and FIELDK are called with a single
 ;field number value.  Then this routine is modified to do whatever is
 ;desired to be done when that one field value changes.  This way if
 ;additional action changes are required for a field, you edit this
 ;routine without having to make changes to data dictionary for file 2.
 ;
 ;If coming from a classic Fileman cross reference then DA* and X will
 ;be defined accordingly.
 ;
 ;If coming from a new style Fileman cross reference, then DA*, X, X(,
 ;X1(, X2( will be defined accordingly.
 ;
 ;If your module M code in this routine sets the variable NOQUE=1 then
 ;this M routine will run in the foreground.  If $G(NOQUE)=0 then the
 ;actual job will be scheduled to run as a Taskman job.
 ;
 ;---------------------------------------------------------------------
 ; Logic for indexes on any top level field in the PATIENT file
 ;   VFLD will be defined and equals field number that was invoked
 ;   VFDATA("RTN",#) = tag^routine to be run
 ;   VFDATA("EX",#)  = executable M code
 ;   VFDATA("VAR",local_variable_name) = value
 ;      where S @(local_variable_name) = value
 ;   VFDATA("FILE",dd#,iens,fld#) = value ; calls FILE^DIE
 ;   VFDATA("UPD",dd#,iens,fld#)  = value ; calls UPDATE^DIE
 ;   VFDATA("INPUT",file) = name of INPUT TEMPLATE for file# ;call ^DIE
 ;   Variables DA*, X, X(, X1(, X2( are always saved for taskman call
 ;*********************************************************************
 ;*      Examples of setting up M code calls in cross references      *
 ;*********************************************************************
 ;  For .01 field set logic:  D FIELDS^VFDPTIX(.01)
 ;  For .01 field kill logic: D FIELDK^VFDPTIX(.01)
 ;
FIELDS(VFLD) ; set logic
 ; VFLD - req - field number for ^DD(2,VFLD)
 Q:$G(VFLD)'>0
 N I,J,Y,Z,NOQUE,VFDATA
 N ZTDESC,ZTDTH,ZTIO,ZTQUEUED,ZTREQ,ZTRTN,ZTSAVE,ZTSK
 D COMMON
 I VFLD=.01 D S01
 D ENQ
 Q
 ;
FIELDK(VFLD) ; kill logic
 ; VFLD - req - field number for ^DD(2,VFLD)
 Q:$G(VFLD)'>0
 N I,Y,Z,NOQUE,VFDATA
 N ZTDESC,ZTDTH,ZTIO,ZTQUEUED,ZTREQ,ZTRTN,ZTSAVE,ZTSK
 D COMMON
 I VFLD=.351 D K351 ; date of death deleted
 D ENQ
 Q
 ;
 ;-----------------------  private subroutines  -----------------------
ENQ ;
 ; save copies of important variables
 N VFDDA,VFDX,VFDX1,VFDX2
 ; save local Fileman variables
 M VFDDA=DA
 M VFDX=X
 M VFDX1=X1
 M VFDX2=X2
 ;
 I $G(NOQUE) G DEQUE
 I '$$TM^%ZTLOAD G DEQUE ; taskman is not running
 ;
QUE ; queue up request to taskman
 N I,Y,Z
 I $G(ZTRTN)="" N ZTRTN S ZTRTN="DEQUE^VFDPTIX"
 I $G(ZTDTH)="" N ZTDTH S ZTDTH=$H
 I '($D(ZTIO)#2) N ZTIO S ZTIO=""
 I $G(ZTDESC)="" N ZTDESC
 I  S ZTDESC="vxVistA Patient File Index for Field "_VFLD
 F I="DA*","VFDATA(","VFLD","X*","X1(","X2(" S ZTSAVE(I)=""
 F I="VFDDA","VFDX","VFDX1","VFDX2" S ZTSAVE(I_"*")=""
 D ^%ZTLOAD
 Q
 ;
DEQUE ; taskman entry point
 N I,J,R,Y,Z,FILE,IENS,TMPL,VAL,VAR,VFDI
 N X,X1,X2,DA
 D RESET ;             restore variables if previously saved
 I $D(VFDATA("RTN")) D  ; run any tag^routines
 . S VFDI=0 F  S VFDI=$O(VFDATA("RTN",VFDI)) Q:'VFDI  D
 . . S R=VFDATA("RTN",VFDI) D DOIT(R),RESET
 . . Q
 . Q
 I $D(VFDATA("EX")) D  ;  execute any M code
 . S VFDI=0 F  S VFDI=$O(VFDATA("EX",VFDI)) Q:'VFDI  D
 . . S R=VFDATA("EX",VFDI) D DOIT(,R),RESET
 . . Q
 . Q
 I $D(VFDATA("FILE")) D  ; perform any Fileman updates to fields
 . S FILE=0 F  S FILE=$O(VFDATA("FILE",FILE)) Q:'FILE  D  S IENS=0
 . . F  S IENS=$O(VFDATA("FILE",FILE,IENS)) Q:IENS=""  D FILE,RESET
 . . Q
 . Q
 I $D(VFDATA("INPUT")) D  ; perform any classic FM edit calls
 . S FILE=0 F  S FILE=$O(VFDATA("INPUT",FILE)) Q:'FILE  D INPUT,RESET
 . Q
 ;
 S:$D(ZTQUEUED) ZTREQ="@"
 Q
 ;
COMMON ;
 S VFDATA("VAR","VFLD")=VFLD
 I VFLD'=.01 S NOQUE=1
 Q
 ;
DOIT(R,EX) ;
 N VFDATA,VFDDA,VFDI,VFDNEW,VFDVAR,VFDX,VFDX1,VFDX2,VFLD
 I $G(R)'="" D @R I 0
 E  X EX
 Q
 ;
FILE ;
 N X,Y,Z,DIERR,VFD,VFDER
 M VFD(FILE,IENS)=VFDATA("FILE",FILE,IENS)
 N FILE,IENS,VFDATA,VFDDA,VFDI,VFDNEW,VFDVAR,VFDX,VFDX1,VFDX2,VFLD
 I $D(VFD) D FILE^DIE(,"VFD","VFDER")
 Q
 ;
INPUT ;
 N X,Y,Z,D0,D1,DIC,DIE,DR,DTOUT,DUOUT
 S TMPL=VFDATA("INPUT",FILE) Q:TMPL=""
 S:$E(TMPL)'="[" TMPL="["_TMPL_"]"
 S DIE=FILE,DR=TMPL D ^DIE
 Q
 ;
RESET ;
 N Y,Z,VAR
 K X,X1,X2,DA
 M X=VFDX,X1=VFDX1,X2=VFDX2,DA=VFDDA
 S VAR="" F  S VAR=$O(VFDATA("VAR",VAR)) Q:VAR=""  D
 . S Y=VFDATA("VAR",VAR) I Y'=+Y,$E(Y)'=$C(34) S Y=$C(34)_Y_$C(34)
 . S @(VAR_"="_Y)
 . Q
 Q
 ;
SET(SUB,VAL,VAR) ;
 N J I $G(VAR)'="" S VFDATA(SUB,VAR)=VAL
 E  S J=1+$O(VFDATA(SUB," "),-1),VFDATA(SUB,J)=VAL
 Q
 ;
S01 ; .01 field entered or changed
 ; last changed VXVISTA 2011.1.1 T29
 ; delay for 3 minutes to allow for parent process to full complete
 ; VFDPTIX input template has executable code in it to do:
 ;   call xref^vfdssn to create pseudo-SSN and MRN
 ;   call setssn^pxxdpt to create 9000001 record
 ;   call ICNLC^MPIF001 to create local ICN
 S VFDATA("INPUT",2)="VFDPTIX"
 S ZTDTH=$$HADD^XLFDT($H,,,,180)
 Q
 ;
K351 ; date of death field deleted
 F I=21601.03,21601.04 S VFDATA(2,DA_",",I)="@"
 Q
