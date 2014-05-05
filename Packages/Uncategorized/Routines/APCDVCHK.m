APCDVCHK ; IHS/CMI/TUCSON - CHECK VISIT ; [ 01/16/01  1:12 PM ]
 ;;2.0;IHS RPMS/PCC Data Entry;**2,4**;MAR 09, 1999
 ;
 ; APCDVSIT must equal the VISIT DFN to be checked.
 ; U must exist and be equal to "^".
 ;
START ;
 ;D EN1^APCDKMM ;for future use with X Linkage
 Q:'$D(^AUPNVSIT(APCDVSIT))
 S APCDVREC=^AUPNVSIT(APCDVSIT,0)
 Q:"EX"[$P(APCDVREC,U,7)
 S APCDVCLC=$P(APCDVREC,U,6)
 Q:APCDVCLC=""
 S APCDVCLC=$E($P(^AUTTLOC(APCDVCLC,0),U,10),5,6)
 I '$D(^AUPNVPOV("AD",APCDVSIT)) W !,"WARNING:  No purpose of visit entered for this visit!",!,$C(7)
 I '$D(^AUPNVPRV("AD",APCDVSIT)) W !,"WARNING:  No provider of service entered for this VISIT!",!,$C(7)
 I $P(APCDVREC,U,8)="",$P(APCDVREC,U,7)="A","I6TP"[$P(APCDVREC,U,3),APCDVCLC>0,APCDVCLC<50 W !,"WARNING:  No Clinic Type entered for this visit!",!,$C(7) S APCDNOCL=""
 I $P(APCDVREC,U,7)="H",$P(APCDVREC,U,3)'="C",'$D(^AUPNVINP("AD",APCDVSIT)) W !,"WARNING:  No V Hospitalization record has been created!",$C(7)
 I $P(APCDVREC,U,3)="C",'$D(^AUPNVCHS("AD",APCDVSIT)) W !,"WARNING:  No V CHS record has been created!",$C(7)
 I $P(APCDVREC,U,7)="H",$P(APCDVREC,U,3)'["CV" D ^APCDVCH
 S (APCDVC1,APCDVC2)=0 F APCDVCL=0:0 S APCDVC2=$O(^AUPNVPRV("AD",APCDVSIT,APCDVC2)) Q:APCDVC2=""  I $P(^AUPNVPRV(APCDVC2,0),U,4)="P" S APCDVC1=APCDVC1+1
 I APCDVC1=0 W !,"WARNING:  No primary provider entered for this visit!",!,$C(7)
 E  I APCDVC1>1 W !,"WARNING:  Multiple primary providers were entered for this visit!",!,$C(7) S APCDMPQ=0
 I $D(^AUPNVPRC("AD",APCDVSIT)),$P(APCDVREC,U,7)'="H" D CHKPRC
 I $$CLINIC^APCLV(APCDVSIT,"C")=30 D CHKER   ;IHS/CMI/GRL
CHKH ;
 I $P(APCDVREC,U,7)="H",$P(APCDVREC,U,3)'="C" D CHKH1
 D CHKCHA
 K APCDVC1,APCDVC2,APCDVCL,APCDVCLC,APCDERR,APCD1,APCD2,APCDVCPV,APCDTS,APCDDS,APCDVREC,APCDDX,APCDOPDX,APCDDXP,APCDFOUN,APCDPX
 Q
 ;
CHKPRC ;check outpatient procedures vs. dx for priv. billing
 K APCDDXP S APCDDX=0 F  S APCDDX=$O(^AUPNVPOV("AD",APCDVSIT,APCDDX)) Q:APCDDX=""  S APCDDXP($P(^AUPNVPOV(APCDDX,0),U))=""
 K APCDOPDX S APCDPX=0 F  S APCDPX=$O(^AUPNVPRC("AD",APCDVSIT,APCDPX)) Q:APCDPX=""  S APCDOPDX=$P(^AUPNVPRC(APCDPX,0),U,5) I APCDOPDX]"" D CHKDXOP2
 Q
CHKDXOP2 ;
 K APCDFOUN F  S APCDDX=$O(APCDDXP(APCDDX)) Q:APCDDX=""  I APCDDX=APCDOPDX S APCDFOUN=1
 I '$D(APCDFOUN) W !,$C(7),"WARNING: Operation ",$P(^ICD0($P(^AUPNVPRC(APCDPX,0),U),0),U)," Not for Diagnosis in V POV file!",!,"Notify your Supervisor or Correct!",!
 Q
 ;
CHKH1 ;
 Q:'$D(^AUPNVINP("AD",APCDVSIT))
 Q:'$D(^AUPNVPRV("AD",APCDVSIT))
 Q:'$D(^AUPNVPOV("AD",APCDVSIT))
 K DIR,DIRUT,DUOUT,DTOUT,X,Y
 S DIR(0)="Y",DIR("A")="Is this Hospitalization visit ready for export to Headquarters (coding complete)",DIR("B")="Y" D ^DIR K DIR S:$D(DUOUT) DIRUT=1
 Q:$D(DIRUT)
 I Y=0 W !,"Don't forget to finalize the coding so this Hospitalization visit ",!,"can be exported.",! Q
 W !,"This Hospitalization Visit will now be considered complete and will be",!,"exported to Headquarters with your next regular PCC export!",!
 S DIE="^AUPNVINP(",DA=$O(^AUPNVINP("AD",APCDVSIT,"")),DR=".15///@" D ^DIE
 Q
CHKCHA ;
CHA ;
 Q:DUZ("AG")'="I"
 Q:"ETC"[$P(APCDVREC,U,7)
 Q:"V"[$P(APCDVREC,U,3)
 Q:'$D(^AUPNVPRV("AD",APCDVSIT))
 Q:'$D(^AUPNVPOV("AD",APCDVSIT))
 S APCDRV("CHA")=0
 S (APCDRV(1),APCDRV(2))=0
 F  S APCDRV(2)=$O(^AUPNVPRV("AD",APCDVSIT,APCDRV(2))) Q:APCDRV(2)=""   D DISC
 ;check secondary providers
CHA2 ;
 Q:APCDRV("CHA")=0
 I '$D(^AUPNVTM("AD",APCDVSIT)) W !!,"WARNING:  COMMUNITY HEALTH NURSE RECORD - NO ACTIVITY TIME ENTERED",$C(7)
 K APCDRV
 Q
DISC ;
 I $P(^DD(9000010.06,.01,0),U,2)[200 D DISC200 Q
 S APCDRV("AP")=$P(^AUPNVPRV(APCDRV(2),0),U,1),APCDRV("DISC")=""
 Q:'$D(^DIC(6,APCDRV("AP")))
 S APCDRV("Y")=$P(^DIC(6,APCDRV("AP"),0),U,4)
 Q:APCDRV("Y")=""
 Q:'$D(^DIC(7,APCDRV("Y"),9999999))
 S APCDRV("CHA DISC")=$P(^DIC(7,APCDRV("Y"),9999999),U,1) I APCDRV("CHA DISC")="" Q
 Q:APCDRV("CHA DISC")'=13&(APCDRV("CHA DISC")'=32)
 S APCDRV("CHA")=APCDRV("CHA")+1
 ;
 Q
DISC200 ;
 S APCDRV("AP")=$P(^AUPNVPRV(APCDRV(2),0),U,1),APCDRV("DISC")=""
 Q:'$D(^VA(200,APCDRV("AP")))
 S APCDRV("CHA DISC")=$$PROVCLSC^XBFUNC1(APCDRV("AP"))
 Q:APCDRV("CHA DISC")'=13&(APCDRV("CHA DISC")'=32)
 S APCDRV("CHA")=APCDRV("CHA")+1
 Q
CHKER ;IHS/CMI/GRL  Check for ER visit w/o V ER record
 K DIR,DA,X,Y
 Q:$D(^AUPNVER("AD",APCDVSIT))
 W !!,"WARNING ... Emergency Clinic visit with NO ER record!",$C(7),!
 S DIR(0)="Y",DIR("A")="Quit without entering ER Record"
 S DIR("A",1)="ER record with a minimum of Disposition and Departure date and time recommended."
 S DIR("A",2)=""
 S DIR("B")="N"
 D ^DIR K DIR
 I Y=1 Q
 I Y=0 S APCDMPQ=0 Q
