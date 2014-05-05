ECXUEC ;ALB/TJL,JAP - Event Capture Extract Unusual Volume Report ; 6/11/09 2:32pm
 ;;3.0;DSS EXTRACTS;**120**;July 1, 2003;Build 43
 ;
EN ; entry point
 N X,Y,DATE,ECRUN,ECXDESC,ECXSAVE,ECXTL,ECTHLD
 N ECSD,ECSD1,ECSTART,ECED,ECEND,ECXERR,QFLG,DIR,DTOUT,DUOUT,DIRUT,POP,ZTSK,ZTQUEUED
 S QFLG=0,ECTHLD=""
 ; get today's date
 D NOW^%DTC S DATE=X,Y=$E(%,1,12) D DD^%DT S ECRUN=$P(Y,"@") K %DT
 D BEGIN Q:QFLG
 D SELECT Q:QFLG
 S ECXDESC="ECS Extract Unusual Volume Report"
 S ECXSAVE("EC*")=""
 W !!,"This report is formatted for 132-column line width."
 W !!,"Enter 'Q' to queue report to TaskManager, then select printer."
 D EN^XUTMDEVQ("PROCESS^ECXUEC",ECXDESC,.ECXSAVE,"",1)
 I $G(POP) W !!,"No device selected...exiting.",! Q
 I IO'=IO(0) D ^%ZISC
 D HOME^%ZIS
 I $D(ZTSK) W !!,"Queued as Task #"_ZTSK_"."
 Q
 ;
BEGIN ; display report description
 W @IOF
 W !,"ECS Extract Unusual Volume Report"
 W !!,"   This report prints a listing of unusual volumes that would be"
 W !,"   generated by the Event Capture extract (ECS) as determined by"
 W !,"   a user-defined threshold value. It should be run prior to"
 W !,"   the generation of an actual extract to identify and fix, as"
 W !,"   necessary, any volumes determined to be erroneous."
 W !!,"   Unusual volumes are those in excess of the threshold value"
 W !,"   defined by the user. The threshold value is 20 by default."
 W !!,"   Note: You may set a different threshold if you opt to continue."
 W !!,"   Run times will vary depending upon the size of the EVENT CAPTURE"
 W !,"   PATIENT file (#721) and the date range selected, but may be at"
 W !,"   least several minutes. Queuing to a printer is recommended."
 W !!,"   The running of this report has no effect on the actual extracts"
 W !,"   and can be run as needed."
 W !!,"   The report is sorted by DSS Unit, then by descending Volume"
 W !,"   within DSS Unit."
 S DIR(0)="E" W ! D ^DIR K DIR I 'Y S QFLG=1 Q
 W:$Y!($E(IOST)="C") @IOF,!!
 Q
 ;
SELECT ; user inputs for threshold volume and date range
 N DONE,OUT
 ; allow user to set threshold volume
 S ECTHLD=20
 W !!,"The default threshold volume for unusual volumes in Event Capture is "_ECTHLD_"."
 S DIR(0)="Y",DIR("A")="Would you like to change the threshold?",DIR("B")="NO"
 D ^DIR K DIR I X["^" S QFLG=1 Q
 I Y D
 .W !!,"Volume > threshold"
 .S DIR(0)="N^0:99",DIR("A")="Enter the new threshold volume"
 .D ^DIR K DIR S ECTHLD=Y I X["^" S QFLG=1
 ; get date range from user
 Q:QFLG
 W !!,"Enter the date range for which you would like to scan the"
 W !,"Event Capture records.",!
 S DONE=0 F  S (ECED,ECSD)="" D  Q:QFLG!DONE
 .K %DT S %DT="AEX",%DT("A")="Starting with Date: ",%DT(0)=-DATE D ^%DT
 .I Y<0 S QFLG=1 Q
 .S ECSD=Y,ECSD1=ECSD-.1
 .D DD^%DT S ECSTART=Y
 .K %DT S %DT="AEX",%DT("A")="Ending with Date: ",%DT(0)=-DATE D ^%DT
 .I Y<0 S QFLG=1 Q
 .I Y<ECSD D  Q
 ..W !!,"The ending date cannot be earlier than the starting date."
 ..W !,"Please try again.",!!
 .I $E(Y,1,5)'=$E(ECSD,1,5) D  Q
 ..W !!,"Beginning and ending dates must be in the same month and year"
 ..W !,"Please try again.",!!
 .S ECED=Y
 .D DD^%DT S ECEND=Y
 .S DONE=1
 Q
 ;
PROCESS ; entry point for queued report
 N QFLG
 S ZTREQ="@"
 S ECXERR=0 D START Q:ECXERR
 S QFLG=0 D PRINT
 K ^TMP("ECUV",$J) D ^ECXKILL
 Q
 ;
START ;find EC records in date range
 N X,Y,ECLL,ECDA,ECD,COUNT
 S ECED=ECED+.3,ECLL=0,COUNT=0
 K ^TMP("ECUV",$J)
 F  S ECLL=$O(^ECH("AC1",ECLL)),ECD=ECSD-.1 Q:'ECLL  D
 .F  S ECD=$O(^ECH("AC1",ECLL,ECD)),ECDA=0 Q:(ECD>ECED)!('ECD)  D
 ..F  S ECDA=$O(^ECH("AC1",ECLL,ECD,ECDA)) Q:'ECDA  D GETREC
 Q
 ;
GETREC ;get data for report
 N ECCH,ECL,ECXDFN,ECXSSN,ECXPDIV,ECDT,ECDU,ECV,ECP,ECXPROV,ECXPRV,ECXDATE,ECXUNIT
 N ECXDOB,ECXETH,ECXMAR,ECXMPI,ECXPNM,ECXPRIME,ECXRACE,ECXRC1,ECXREL,ECXSEX,N1,N2,VA
 S ECCH=^ECH(ECDA,0),ECV=$P(ECCH,U,10)
 Q:(ECV<ECTHLD)
 S ECL=$P(ECCH,U,4),ECXDFN=$P(ECCH,U,2)
 S ECXPDIV=$$RADDIV^ECXDEPT(ECL)  ;Get production division from file 4
 S ECDT=$P(ECCH,U,3),ECDU=$P(ECCH,U,7),ECP=$P(ECCH,U,9)
 Q:(ECP']"")
 Q:('$$PATDEM^ECXUTL2(ECXDFN,ECDT,"1;","12"))
 S ECXDATE=$$FMTE^XLFDT(ECDT,5)
 K ECXPRV S X=$$GETPPRV^ECPRVMUT(ECDA,.ECXPRV),ECXPROV=$E($P(ECXPRV,U,2),1,30)
 I ECXPROV]"" D
 .S N1=$$TITLE^XLFSTR($P(ECXPROV,",")),N2=$$TITLE^XLFSTR($P(ECXPROV,",",2))
 .S ECXPROV=(N1_","_N2)
 I ECP[";" D
 .S ECP=$S(ECP["ICPT":$P(^ICPT(+ECP,0),U)_"01",ECP<90000:$P(^EC(725,+ECP,0),U,2)_"N",1:$P(^EC(725,+ECP,0),U,2)_"L")
 S ECXUNIT=$P($G(^ECD(ECDU,0)),U)
 S COUNT=COUNT+1
 S ^TMP("ECUV",$J,ECXUNIT,(100-ECV),COUNT)=ECXSSN_U_ECXPDIV_U_ECXDATE_U_ECP_U_ECXPROV_U_ECV
 Q
 ;
PRINT ; process temp file and print report
 N PG,QFLG,LN,COUNT,REC,CC,SS,JJ,ZTSTOP
 N ECXUNIT,ECV,ECVV,ECXSSN,ECXPDIV,ECXDATE,ECXUNIT,ECP,ECXPROV
 U IO
 I $D(ZTQUEUED),$$S^%ZTLOAD S ZTSTOP=1 K ZTREQ Q
 S (PG,QFLG,COUNT)=0,$P(LN,"-",130)=""
 D HEADER Q:QFLG
 S ECXUNIT="" F  S ECXUNIT=$O(^TMP("ECUV",$J,ECXUNIT)) Q:ECXUNIT=""  D  Q:QFLG
 .I COUNT>0 W !,?1,LN
 .S ECVV=0 F  S ECVV=$O(^TMP("ECUV",$J,ECXUNIT,ECVV)) Q:'ECVV  D  Q:QFLG
 ..S CC=0 F  S CC=$O(^TMP("ECUV",$J,ECXUNIT,ECVV,CC)) Q:'CC  D  Q:QFLG
 ...S REC=^TMP("ECUV",$J,ECXUNIT,ECVV,CC),COUNT=COUNT+1
 ...S ECXSSN=$P(REC,U),ECXPDIV=$P(REC,U,2),ECXDATE=$P(REC,U,3),ECP=$P(REC,U,4),ECXPROV=$P(REC,U,5),ECV=$P(REC,U,6)
 ...W !,?1,ECXSSN,?13,ECXPDIV,?24,ECXUNIT,?55,ECXDATE,?75,ECP,?86,ECV,?94,ECXPROV
 ...I $Y+4>IOSL D HEADER Q:QFLG
 Q:QFLG
 I COUNT=0 W !!,?8,"No unusual Event Capture volumes to report for the date range.",!!
 D SS
 Q
 ;
HEADER ;header and page control
 D:PG SS Q:QFLG
 Q:QFLG
 W:$Y!($E(IOST)="C") @IOF S PG=PG+1
 W !,ECXDESC,?103,"Page: "_PG
 W !,"Start Date: ",ECSTART,?92,"Report Run Date: "_ECRUN
 W !,"  End Date: ",ECEND,?92,"Threshold Value: ",ECTHLD
 W !!,?1,"SSN",?13,"FACILITY",?24,"DSS UNIT",?55,"DATE/TIME",?75,"PROCEDURE",?86,"VOLUME",?94,"PROVIDER"
 W !,LN,!
 Q
 ;
SS ;SCROLL STOPS
 N JJ,SS
 I $E(IOST)="C" S SS=21-$Y F JJ=1:1:SS W !
 I $E(IOST)="C",PG>0 S DIR(0)="E" W ! D ^DIR K DIR I 'Y S QFLG=1 Q
 Q