APCDDVD ; IHS/CMI/TUCSON - VISIT REVIEW DRIVER ; [ 01/20/04  8:11 AM ]
 ;;2.0;IHS RPMS/PCC Data Entry;**5,7**;MAR 09, 1999
ZERO ;EP; for zero dependent entry report
 S APCDT="ZERO" G RDPV
PPPV ;EP; for no primary provider/pov report
 S APCDT="PPPV" G RDPV
MRG ;EP; for Merge Report
 S APCDT="MRG" G RDPV
TXER ;EP; for Transaction error Report
 S APCDT="TXER" G RDPV
INPT ;EP; for Inpatient review
 S APCDT="INPT" G RDPV
ALL ;EP;to run all Visit Error Reports
 S APCDT="ALL" G RDPV
RDPV ; Determine to run by Posting date or Visit date
 S APCDBEEP=$C(7)_$C(7),APCDSITE="" S:$D(DUZ(2)) APCDSITE=DUZ(2)
 I '$D(DUZ(2)) S APCDSITE=+^AUTTSITE(1,0)
 S DIR(0)="S^1:Posting Date;2:Visit Date",DIR("A")="Run Report by",DIR("B")="P" D ^DIR K DIR S:$D(DUOUT) DIRUT=1
 I $D(DIRUT) G XIT
 S Y=$E(Y),APCDPROC=$S(Y=1:"P",Y=2:"V",1:Y)
GETDATES ;
BD ;get beginning date
 W ! S DIR(0)="D^:DT:EP",DIR("A")="Enter beginning "_$S(APCDPROC="P":"Posting",APCDPROC="V":"Visit",1:"Posting")_" Date for Search" D ^DIR K DIR S:$D(DUOUT) DIRUT=1
 I $D(DIRUT) G XIT
 S APCDBD=Y
ED ;get ending date
 W ! S DIR(0)="D^"_APCDBD_":DT:EP",DIR("A")="Enter ending "_$S(APCDPROC="P":"Posting",APCDPROC="V":"Visit",1:"Posting")_" Date for Search" S Y=APCDBD D DD^%DT S DIR("B")=Y,Y="" D ^DIR K DIR S:$D(DUOUT) DIRUT=1
 I $D(DIRUT) G BD
 S APCDED=Y
 S X1=APCDBD,X2=-1 D C^%DTC S APCDSD=X
 ;
LOC ;
 S APCDLOCT=""
 S DIR(0)="S^A:ALL Locations/Facilities;S:One SERVICE UNIT'S Locations/Facilities;O:ONE Location/Facility",DIR("A")="Include Visits to Which Location/Facilities",DIR("B")="A"
 S DIR("A")="Enter a code indicating what LOCATIONS/FACILITIES are of interest",DIR("B")="O" K DA D ^DIR K DIR,DA
 G:$D(DIRUT) GETDATES
 S APCDLOCT=Y
 I APCDLOCT="A" G ALLV
 D @APCDLOCT
 G:$D(APCDQUIT) LOC
ALLV ;
 S DIR(0)="S^1:ALL Visits in Date Range Specified;2:Only those Visits flagged to be Transmitted to DPSB",DIR("A")="Review which set of visits",DIR("B")="2" D ^DIR K DIR
 I $D(DIRUT) G BD
 S APCDVSET=+Y
SORT ;
 S APCDSORT=""
 K DIR S DIR(0)="S^H:Health Record Number;C:Clinic",DIR("A")="Sort the report by",DIR("B")="H" KILL DA D ^DIR KILL DIR
 I $D(DIRUT) G ALLV
 S APCDSORT=Y
 I APCDSORT="C" S APCDCSRT="T" G PPT
 W !!,"This report will be sorted by Patient Health Record Number."
 S APCDCSRT=""
 S DIR(0)="S^T:Terminal Digit Order;H:Health Record Number Order",DIR("A")="Sort the report by",DIR("B")="T" D ^DIR K DIR S:$D(DUOUT) DIRUT=1
 I $D(DIRUT) G SORT
 S APCDCSRT=Y
PPT ;
 I APCDT'="PPPV" S APCDRTYP="" G ZIS
 W !!,"You have chosen to run the report of visits with No Primary Provider or Purpose",!,"of visit.  You can list only those visits with certain ancillary visits",!,"attached to them.",!
 S APCDRTYP=""
 S DIR(0)="S^R:Radiology (visits with V Radiology and no PP/PV);L:Lab (visits w/V LAB and no PP/PV);P:Pharmacy (visits w/V Medication and no PP/PV)"
 S DIR(0)=DIR(0)_";I:Immunization (visits w/V Immunization and no PP/PV);A:ALL visits with no PP/PV",DIR("A")="Which Incomplete Visits do you wish to list",DIR("B")="A" KILL DA D ^DIR KILL DIR
 G:$D(DIRUT) SORT
 S APCDRTYP=Y
ZIS ;call xbdbque
 S XBRC="DRIVER^APCDDVD",XBRP="PRINT^APCDDVD",XBRX="XIT^APCDDVD",XBNS="APCD"
 D ^XBDBQUE
 D XIT
 Q
DRIVER ;EP entry point for taskman
 S APCDBT=$H,APCDJOB=$J
 K ^XTMP("APCDDV",APCDJOB,APCDBT)
 D ^APCDDVD1
 S APCDET=$H
 Q
PRINT ;EP
 D ^APCDDVW
 K ^XTMP("APCDDV",APCDJOB,APCDBT)
 Q
XIT ;EP
 K APCDBEEP,APCDX,APCDBD,APCDT,APCDED,APCDSD,APCDODAT,APCDVSIT,%,APCDL,X,X1,X2,IO("Q"),APCDDT,APCDSITE,APCDLC,APCDPAGE,APCDCAT,APCDTYPE,APCPTX,APCDADM,APCDPS,APCDPVP,APCDFILE,APCDEC,APCDBT,APCDET,APCDQIO,APCDJOB,APCDPROC,APCD
 K APCDDV("VREC"),APCDVSET,APCDBDFN,APCDDEMM,APCDDEM,APCDCLN,APCDCL,APCDH,APCDCLOC,APCDCSRT,APCDDCHS,APCDHRN,APCDLOC,APCDLOCT,APCDQUIT
 D EN2^APCDEKL
 K X,X1,X2,IO("Q"),%DT,%ZIS,%,DUOUT,DLOUT,Y
 Q
ERR W APCDBEEP,!,"Must be a valid date and be Today or earlier. Time not allowed!" Q
O ;one community
 S DIC="^AUTTLOC(",DIC(0)="AEMQ",DIC("A")="Which LOCATION: " D ^DIC K DIC
 I Y=-1 S APCDQUIT="" Q
 S APCDLOCT("ONE")=+Y
 Q
S ;all communities within APCDSU su
 S DIC="^AUTTSU(",DIC("B")=$$VAL^XBDIQ1(9999999.06,DUZ(2),.05),DIC(0)="AEMQ",DIC("A")="Which SERVICE UNIT: " D ^DIC K DIC
 I Y=-1 S APCDQUIT="" Q
 S APCDLOCT("SU")=+Y
 Q
 ;
