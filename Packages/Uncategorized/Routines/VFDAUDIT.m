VFDAUDIT ;DSS/LM - Custom reports from AUDIT file ;01 Dec 2009 10:57
 ;;2009.2;DSS,INC VXVISTA OPEN SOURCE;;01 Dec 2009
 ;Copyright 1995-2009,Document Storage Systems Inc. All Rights Reserved
 ;
PATIENT ; Option - VFD AUDIT PT ACCESS REPORT
 N I,X,Y,Z,VFDAT,VFDFN,VFDUZ
 W @IOF,?30,"PATIENT AUDIT REPORT"
 W !?3,"You may enter a '?' at any prompt for more detailed help"
 S X=$$REPORT Q:X<1  S VFDAT("RPT")=X
 I 23[X D PAT Q:'$G(VFDFN)
 I 13[X D USER Q:'$G(VFDUZ)
 D DATE I '$G(VFDAT("ED")) Q
 S X=$$TYPE Q:X<1  S VFDAT("TYPE")=X
 S X=$$SORT Q:"PU"'[X!(X="")  S VFDAT("SORT")=X
 D PRINT(2,.VFDAT,.VFDFN,.VFDUZ)
 ;
 ;-----------------------  PRIVATE SUBROUTINES  -----------------------
PRINT(VFDFILE,VFDAT,VFDFN,VFDUZ) ; captioned print from AUDIT file
 ; VFDFILE - req - file number of records audited
 ; VFDAT(subscript) = value for subscripts:
 ;   "RPT" - req - report type
 ;    "SD" - req - start date
 ;    "ED" - req - end date
 ;  "TYPE" - req - accessed or file edits or both
 ;  "SORT" - req - sort by patient or user
 N L,T,X,Y,BY,DHD,DIC,DIOEND,DIQ,DIS,FLDS,FR,IEN,NAME,TO
 S L="",DIC="^DIA("_VFDFILE_",",FLDS="[CAPTIONED]"
 S DIOBEG="S DIQ(0)=""C""",DIOEND="D PRTEND^VFDAUDIT"
 S DHD="Patient Audit Report"
 D PRTBY
 D PRTFMTO
 I $D(VFDFN)!$D(VFDUZ)!($G(VFDAT("TYPE"))<3) D PRTDIS
 D EN1^DIP
 Q
 ;
PRTBY ; set up BY variable for patient file
 N Y S Y=($G(VFDFN)=1)
 I $G(VFDAT("SORT"))="U" S BY=".04;S2,"_$S(Y:.01,1:1)_";S2,-@.02"
 E  S BY=$S(Y:.01,1:1)_";S2,.04;S2,-@.02"
 Q
 ;
PRTDIS ; set up the DIS(0) variable
 ;;N ACC,NODE,USER S NODE=^DIA(VFDFILE,D0,0),USER=+$P(NODE,U,4),ACC=($P(NODE,U,6)="i")
 N T S T=$P($T(PRTDIS+1),";",3)
 I $G(VFDFN) S T=T_" I $D(VFDFN(+NODE))"
 I $G(VFDUZ) S T=T_$S($G(VFDFN):",",1:" I ")_"$D(VFDUZ(USER))"
 I VFDAT("TYPE")<3 D
 .S T=T_$S($G(VFDFN)!$G(VFDUZ):",",1:" I ")
 .S T=T_$S(VFDAT("TYPE")=1:"ACC",1:"'ACC")
 .Q
 S DIS(0)=T
 Q
 ;
PRTFMTO ; set up FR,TO variables for patient file
 N T,Y,Z S (Y,Z)=0
 I $G(VFDFN)=1 S Y=$O(VFDFN(0))
 I $G(VFDUZ)=1 S Z=$O(VFDUZ(0))
 S T=($G(VFDAT("SORT"))="U") ; t=1 if sort by user
 I T S FR(1)=$S(Z:VFDUZ(Z),1:"A"),TO(1)=$S(Z:VFDUZ(Z)_" ",1:"ZZ")
 E  S FR(1)=$S(Y:Y,1:"A"),TO(1)=$S(Y:Y,1:"ZZ")
 I T S FR(2)=$S(Y:Y,1:"A"),TO(2)=$S(Y:Y,1:"ZZ")
 E  S FR(2)=$S(Z:VFDUZ(Z),1:"A"),TO(2)=$S(Z:VFDUZ(Z)_" ",1:"ZZ")
 S FR(3)=VFDAT("SD"),TO(3)=VFDAT("ED")
 Q
 ;
PRTEND ; called from DIOEND from PRINT
 N I,J,X,Y,Z
 W !!,"Sort and filter criteria for this report:"
 W !,"          Start date: "_$$FMTE^XLFDT(VFDAT("SD"))
 W ?42,"End Date: "_$$FMTE^XLFDT(VFDAT("ED"))
 S X="            Patients: "
 S X=X_$S('$D(VFDFN):"ALL",1:"Selected patients")
 S $E(X,46)="Users: "
 S X=X_$S('$D(VFDUZ):"ALL",1:"Selected users") W !,X
 S J=$G(VFDAT("TYPE")),X=""
 I J=1 S X="Patient file access only"
 I J=2 S X="Patient file field audits"
 I J=3 S X="Patient file access and field audits"
 W !,"Type of Audit Report: "_X
 I $G(VFDFN),VFDFN<21 D
 .W !,"Selected Patients:"
 .F I=1:1 Q:'$D(VFDFN("L",I))  W !?3,VFDFN("L",I)
 .W !
 .Q
 I $G(VFDUZ),VFDUZ<21 D
 .W !,"Selected Users:"
 .F I=1:1 Q:'$D(VFDUZ("L",I))  W !?3,VFDUZ("L",I)
 .Q
 Q
 ;
DATE ; select starting and ending dates
 N X,Y,Z
 D WR("ENTER STARTING AND ENDING DATES")
 S Z(0)="DO^:"_DT_":E",Z("A")="Starting DATE",Z("B")="T-60"
 S Y=$$DIR(.Z) Q:Y<1  S VFDAT("SD")=Y K Z
 S Z(0)="DO^"_Y_":"_DT_":E",Z("A")="Ending DATE",Z("B")="T"
 S Y=$$DIR(.Z) Q:Y<1  S VFDAT("ED")=$$FMADD^XLFDT(Y,1)
 Q
 ;
DIC(DIC) ; select entries from a file
 N I,X,Y,Z,DTOUT,DUOUT
 W ! D ^DIC I $D(DTOUT) S Y=-2
 I $D(DUOUT) S Y=0
 Q Y
 ;
DIR(DIR) ; call DIR return Y or -1
 N X,Y,DIROUT,DIRUT,DTOUT,DUOUT
 W ! D ^DIR I $D(DTOUT)!$D(DUOUT)!$D(DIRUT) S Y=-1
 Q Y
 ;
PAT ; select patients
 N X,Y,Z
 D WR("SELECT PATIENTS")
 S Z=2,Z(0)="QAEM",Z("S")="I $E(^(0),1,2)'=""ZZ"""
 F  S X=$$DIC(.Z) Q:X<1  S VFDFN(+X)=$P(X,U,2),VFDFN=1+$G(VFDFN)
 I X'=-2 D SET(.VFDFN)
 I X=-2 K VFDFN
 Q
 ;
REPORT() ; select report type
 ;;1:All patients, selected users
 ;;2:All users, selected patients
 ;;3:Select patients and users
 ;;4:All patients, all users
 ;;      For all reports, you will select starting and ending dates
 ;;[1] - Audit report for all patients for a date range.  You select
 ;;      one or more users
 ;;[2] - Audit report for all users for a date range,  You select one
 ;;      or more patients
 ;;[3] - Audit report for a date range where you select one or or users
 ;;      and one or more patients
 ;;[4] - Audit report for a date range for all patients and all users
 N I,X,Y,Z
 D WR("SELECT REPORT TYPE")
 S Z(0)="SO^" F I=1:1:4 S Z(0)=Z(0)_$P($T(REPORT+I),";",3)_";"
 F I=5:1:12 S Z("?",I-4)=$TR($T(REPORT+I),";"," ")
 S Z("?")="   ",Z("A")="Select Report Type"
 Q $$DIR(.Z)
 ;
SORT() ; select sort by patient or user
 ;;[P] - PATIENT: sort the report by patient name
 ;;[U] - USER:    sort the report by user name
 N X,Y,Z
 D WR("SELECT SORT BY CRITERIA")
 S Z(0)="SO^P:Patient Name;U:User Name",Z("B")="P"
 S Z("A")="Select Sort By Criteria",Z("?")="   "
 F I=1,2 S Z("?",I)=$TR($T(SORT+I),";"," ")
 Q $$DIR(.Z)
 ;
SET(DAT) ; create 2 column list of names
 N I,J,X,Y,Z
 I '$G(DAT)!($G(DAT)>20) Q
 S J=(DAT\2)+(DAT#2)
 S I=0 F  S I=$O(DAT(I)) Q:'I  S Z(DAT(I),I)=""
 S X="Z",I=0 F  S X=$Q(@X) Q:X=""  S I=I+1,DAT("L",I)=$QS(X,1) Q:I=J
 I X'="" S I=0 F  S X=$Q(@X) Q:X=""  S I=I+1,$E(DAT("L",I),41)=$QS(X,1)
 Q
 ;
TYPE() ; select audit record types
 ;;      Select the type of audit records you wish to view
 ;;[1] - ACCESSED: audit records for a patient where the user had
 ;;      selected that patient in some vxVistA application
 ;;[2] - OTHER: audit records for a patient where the user edited a
 ;;      field in the PATIENT file.  This does not include patient
 ;;      accessed audit log records
 ;;[3] - BOTH: audit records for a patient included in both ACCESSED
 ;;      and OTHER
 N I,X,Y,Z
 D WR("SELECT AUDIT TYPE")
 S Z(0)="SO^1:Accessed;2:Other, not accessed;3:Both"
 F I=1:1:8 S Z("?",I)=$TR($T(TYPE+I),";"," ")
 S Z("?")="   ",Z("A")="Select Audit Type",Z("B")="Accessed"
 Q $$DIR(.Z)
 ;
USER ; select users
 N X,Y,Z
 D WR("SELECT USERS")
 S Z=200,Z(0)="QAEM",Z("S")="I $E(^(0),1,2)'=""ZZ"""
 F  S X=$$DIC(.Z) Q:X<1  S VFDUZ(+X)=$P(X,U,2),VFDUZ=1+$G(VFDUZ)
 I X'=-2 D SET(.VFDUZ)
 I X=-2 K VFDUZ
 Q
 ;
WR(X) W !!,$$CJ^XLFSTR("  "_X_"  ",80,"-") Q
