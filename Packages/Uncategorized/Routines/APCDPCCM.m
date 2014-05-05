APCDPCCM ; IHS/CMI/LAB - UPDATE PCC MASTER CONTROL PCC LINK [ 10/28/03  9:11 AM ]
 ;;2.0;IHS RPMS/PCC Data Entry;**7**;MAR 09, 1999
 ;
 W:$D(IOF) @IOF
 W !,$$CTR("PCC DATA ENTRY SUPERVISOR MENU",80)
 W !!,$$CTR("UPDATE PCC MASTER CONTROL FILE - ANCILLARY TO PCC LINK",80)
 W !,"This option is used to update the Ancillary to PCC link control file.",!,"You should be very careful when using this option.  This option should be used"
 W !,"to either turn ON or turn OFF an ancillary to PCC link.  For example, if you"
 W !,"want data to pass from LAB to PCC then the link for the LABORATORY PACKAGE"
 W !,"should be set to YES."
 W !
 ;continue or NOT
 S DIR(0)="Y",DIR("A")="Do you want to continue",DIR("B")="N" KILL DA D ^DIR KILL DIR
 I $D(DIRUT) D XIT Q
 I 'Y D XIT Q
 ;get site
 S APCDSITE=""
 S DIC=9001000,DIC(0)="AEMQL",DIC("A")="Enter your SITE Name: " D ^DIC
 I Y=-1 D XIT Q
 S (DA,APCDSITE)=+Y,DDSFILE=9001000,DR="[APCD LINKAGE UPDATE]" D ^DDS
 I $D(DIMSG) W !!,"ERROR IN SCREENMAN FORM!!  ***NOTIFY PROGRAMMER***" K DIMSG H 3 D XIT Q
 D XIT
 Q
XIT ;
 K DIADD,DLAYGO
 D EN^XBVK("APCD")
 D ^XBFMK
 Q
CTR(X,Y) ;EP - Center X in a field Y wide.
 Q $J("",$S($D(Y):Y,1:IOM)-$L(X)\2)_X
 ;----------
