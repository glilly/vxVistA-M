APCDAEDU ;IHS/CMI/LAB - education topic lookup [ 10/22/03  3:41 PM ]
 ;;2.0;IHS RPMS/PCC Data Entry;**4,7**;MAR 09, 1999
 ;
 ;
EP ;
 D EN^XBNEW("EP1^APCDAEDU","APCDT12;APCDT04;APCDTSKI;APCDLOOK,APCDTERR,APCDPEDP,APCDPEDV")
 Q
EP1 ;
 S APCDTSKI="",APCDLOOK="",APCDPEDC=0
 W !!,"You can enter education topics in 2 ways:",!?3,"- using the name of the topic (e.g. DM-DIET)",!?3,"- using an ICD Diagnosis for the topic diagnosis and enter a topic category",!
 ;S DIR(0)="F^1:30",DIR("A")="Enter EDUCATION Topic" KILL DA D ^DIR KILL DIR
 S DIR(0)="S^T:EDUCATION TOPIC;D:DIAGNOSIS",DIR("A")="Do you wish to enter a",DIR("B")="T" KILL DA D ^DIR KILL DIR
 I $D(DIRUT) S APCDTSKI=1 Q
 I Y="T" D OLD Q
 I Y="D" D ICD S APCDTSKI=1 Q
 Q
ICD ;
 S APCDT04=""
 ;lookup in ICD file
 S DIC="^ICD9(",DIC(0)="AMEQ" D ^DIC K DIC
 I X="" S APCDLOOK="",APCDTSKI=1,APCDT04="" Q
 I $D(DUOUT) S APCDTSKI=1,APCDLOOK="",APCDT04="",APCDT12="" Q
 I Y=-1 G EP1
 S APCDT04="`"_+Y
TOPIC ;
 W !
 S APCDT12=""
 S DIR(0)="9000010.16,.12",DIR("A")="Enter "_$S(APCDPEDC:"another ",1:"")_"Category" KILL DA D ^DIR KILL DIR
 I $D(DIRUT),APCDPEDC=0 S (APCDLOOK,APCDT04,APCDT12)="" W !,"No education topic entered." G EP1
 Q:$D(DIRUT)
 Q:Y=""
 S APCDT12="`"_+Y
 ;
P01 ;get .01 value by concatenating topic and dx
 NEW APCDY,APCDM
 S APCDY=$P(^ICD9($P(APCDT04,"`",2),0),U)_"-"_$P(^APCDEDCV($P(APCDT12,"`",2),0),U),APCDM=$P(APCDY,"-")_"-"_$P(^APCDEDCV($P(APCDT12,"`",2),0),U,2)
 S Z=$O(^AUTTEDT("B",APCDY,0)) I Z S APCDLOOK="`"_Z D ADDVPED G TOPIC
 ;add to educ topics file
 D ^XBFMK S X=APCDY,DIC(0)="L",DIC="^AUTTEDT(",DLAYGO=9999999.09,DIADD=1,DIC("DR")="1///"_APCDM_";.04///"_APCDT04 K DD,D0,DO D FILE^DICN
 I Y=-1 W !!,"error adding new education topic, notify supervisor." S APCDTSKI=1,APCDLOOK="",APCDT04="",APCDT12="" Q
 S APCDLOOK="`"_+Y D ADDVPED G TOPIC
 Q
 ;add to education topics file
OLD ;
 S (APCDTSKI,APCDLOOK)=""
 ;do DIC lookup into education topics file
 X:$D(^DD(9000010.16,.01,12.1)) ^DD(9000010.16,.01,12.1) S DIC="^AUTTEDT(",DIC(0)="AEMQ",DIC("A")="Enter EDUCATION Topic: " D ^DIC K DIC
 I Y=""  S APCDTSKI=1,APCDLOOK="" Q
 I Y=-1,X=""!(X="^") S APCDTSKI=1,APCDLOOK="" Q
 I Y=-1 S APCDTERR=1,APCDLOOK="" Q
 S APCDLOOK="`"_+Y
 S APCDT04=$P(^AUTTEDT(+Y,0),U,4) I APCDT04 S APCDT04="`"_APCDT04
 Q
ADDVPED ;add v patient education entry
 D ^XBFMK
 S DIC="^AUPNVPED(",X=$P(APCDLOOK,"`",2),DIC(0)="L",DIADD=1,DLAYGO=9000010.16 K DD,D0,DO D FILE^DICN
 K DIADD,DLAYGO,DIC,DA,DD,DO
 I Y=-1 W !!,"Creating V Patient Education failed!  Notify programmer." D ^XBFMK Q
 S DA=+Y,DIE="^AUPNVPED(",DR=".02////"_APCDPEDP_";.03////"_APCDPEDV_";.04///"_APCDT04_";.12///"_APCDT12_";.14;.06;.07;.08;.05;.13;.09;1101;.11" D ^DIE
 I $D(Y) W !!,"Creating V patient ed failed!  Notify programmer." D ^XBFMK Q
 D ^XBFMK
 S APCDPEDC=APCDPEDC+1
 Q
 ;following code, leave for now
 S APCDLOOK="`"_+Y
 ;lookup in conversion file
 S X=$O(^APCDEDCV("B",APCDTX,0))
 I 'X S X=$O(^APCDEDCV("C",APCDTX,0))
 I 'X Q
 S D=$P(^APCDEDCV(X,0),U,3),D=$O(^ICD9("AB",D,0))
 I 'D Q
 S APCDT04="`"_D
 S T=$P(^APCDEDCV(X,0),U,5),T=$O(^AUTTEDT("C",T,0))
 I 'T Q
 S APCDT01="`"_T
 Q
