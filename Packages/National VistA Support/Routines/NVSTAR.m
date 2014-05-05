NVSTAR ;emc/maw-Test Account Reset Utilities main routine ;09/01/02
 ;;6.0;EMC TEST ACCOUNT RESET UTILITIES; 01 Jun 1999;;Build 24
 ;
 D HOME^%ZIS
 I $G(IOF)'="" W @IOF
 W !!,$$CJ^XLFSTR("ENTERPRISE MANAGEMENT CENTER :: TEST ACCOUNT RESET UTILITIES",80)
 W !,$$CJ^XLFSTR("VERSION 6.0 :: September 1, 2002",80)
 ;
 W !!,"CAUTION:  IT IS IMPORTANT TO USE UP TO DATE SOFTWARE!"
 W !!,"If you did not retrieve this software from the documented source site"
 W !,"today (or within the past couple of days), you may be using out-of-date"
 W !,"software.  If this isn't a recent download, it is highly recommended that"
 W !,"you abort this and retrieve the latest software from the source site."
 S DIR(0)="YA"
 S DIR("A")="Are you sure it is OK to continue? "
 S DIR("?")="If you aren't sure, then you should abort, log a NOIS and get some assistance."
 S DIR("B")="NO"
 W ! D ^DIR K DIR
 I Y'=1 D  Q
 .W !,"ABORTED."
 .K DIRUT,DTOUT,X,Y
 ;
 W !!,"If you encounter any problems using this software, please log a NOIS"
 W !,"with your technical support team."
 ;
 W !!,"There is some documentation that describes what this software is about to do."
 S DIR(0)="YA"
 S DIR("A")="Would you like to see it? "
 S DIR("B")="YES"
 D ^DIR K DIR
 I Y=1 D ^NVSTARH
 K DIRUT,DTOUT,X,Y
 ;
 I '$D(DUZ) D
 .S DUZ=.5
 .S DUZ(0)="@"
 .D DT^DICRW
 .W "okay."
 ;
 ; get initial values...
 K ^XTMP("NVSTAR")
 S X1=$$DT^XLFDT()
 S X2=+7
 D C^%DTC
 S NVSPDT=X
 S ^XTMP("NVSTAR",0)=NVSPDT_"^"_$$DT^XLFDT()_"^EMC TEST ACCOUNT RESET UTILITIES"
 K NVSPDT,X,X1,X2,Y
 ;
 I $G(^%ZOSF("UCI"))="" Q
 X ^%ZOSF("UCI")
 S ^XTMP("NVSTAR","NVSUCI")=Y
 S ^XTMP("NVSTAR","NVSOPSYS")=$P($G(^%ZOSF("OS")),"^")
 ;
 ; ask user to select NULL DEVICE...
 I $G(^XTMP("NVSTAR","NULL DEVICE"))="" D
 .W !!,"I need to make sure I have the right $I for the NULL device."
 .W !,"Please assist me by selecting the NULL device from the Device file"
 .W !,"prompt below..."
 .S DIR(0)="PA^3.5:QEFMZ"
 .S DIR("A")="Select DEVICE: "
 .W ! D ^DIR K DIR
 .I $D(DIRUT) D  K DTOUT,DIRUT,^XTMP("NVSTAR","NULL DEVICE") Q
 ..W !!,"Sorry, but you can't bypass this...aborting the reset."
 ..W !,"Please take a look in your Device file (#3.5) and decide how to"
 ..W !,"answer this prompt, and try again.  Thanks."
 .W !!,"Thank you.  I'll use ",$P(Y(0),U,2)," for disabled print devices."
 .S ^XTMP("NVSTAR","NULL DEVICE")=+Y_"^"_$P(Y(0),"^",2)
 ;
 I $G(^XTMP("NVSTAR","NULL DEVICE"))="" D  Q
 .W $C(7)
 .W !!,"NULL DEVICE was not selected.  This value is required."
 .W !,"Process aborted."
 .K ^XTMP("NVSTAR")
 ;
 S NVSUCI=$G(^XTMP("NVSTAR","NVSUCI"))
 I NVSUCI="" D  Q
 .W $C(7)
 .W !!,"Error:  namespace/UCI is undefined."
 .W !,"Process aborted."
 S NVSOPSYS=$G(^XTMP("NVSTAR","NVSOPSYS"))
 I NVSOPSYS="" D  Q
 .W $C(7)
 .W !!,"Error:  Operating system is undefined."
 .W !,"Process aborted."
 ;
 W !!,"The current account is: ",NVSUCI
 W !,"The operating system is: ",NVSOPSYS
 ;
 ; make sure we're in the right place to run this utility.  we'll use Kernel
 ; to make the initial determination so that we cover both ISM and DSM systems.
 ; we'll check the uci to see if it contains VAH...
 S NVSUCIOK=0
 I NVSOPSYS["DSM" S NVSUCIOK=$S($P(NVSUCI,",",2)'="ROU":1,1:0)
 I NVSOPSYS["OpenM" S NVSUCIOK=$S($P(NVSUCI,",")'="VAH":1,1:0)
 I NVSUCIOK'=1 D  I $D(DIRUT) K DTOUT,DIRUT Q
 .W $C(7)
 .W !!,"** WARNING :: WARNING :: WARNING **"
 .W !!,"This account/namespace (",NVSUCI,") does NOT appear to be your Test system!!"
 .W !,"Running ANY of the reset procedures on your production account WILL DEFINITELY"
 .W !,"CAUSE YOU MAJOR PROBLEMS."
 .S DIR(0)="YA"
 .S DIR("A")="Are you ABSOLUTELY SURE you wish to continue? "
 .S DIR("B")="NO"
 .W ! D ^DIR K DIR
 .I Y'=1 S DIRUT=1 W !,"Aborted!" Q
 .W !,"Okay, continuing..."
 K NVSUCIOK
 ;
 ; get user choice on completion tasks...
 I $G(^XTMP("NVSTAR","LOGINS"))'="YES" D
 .W !!,"When the Reset Utility starts, logins will be disabled in the Volume"
 .W !,"Set file (#14.5).  Logins will NOT be automatically re-enabled unless"
 .W !,"you say so..."
 .S DIR(0)="YA"
 .S DIR("A")="Okay to re-enable logins when the Utility finishes? "
 .S DIR("B")="NO"
 .W ! D ^DIR K DIR
 .I Y'=1 W !?2,"Logins will NOT be re-enabled."
 .I Y=1 D
 ..S ^XTMP("NVSTAR","LOGINS")="YES"
 ..W !?2,"Logins will be re-enabled when reset is complete."
 .K DIRUT,DTOUT,X,Y
 ;
 ; warn DSM site user regarding the deletion and reset of the ^%Z* globals...
 I NVSOPSYS["DSM" D
 .W !!,"Note to DSM sites regarding ^%Z* global deletion and reset:"
 .W !!,"In Part 5 of this Utility (routine ^NVSTAR5), the Task Manager globals"
 .W !,"^%ZTSK and ^%ZTSCH will be completely deleted and their top-level nodes"
 .W !,"reset.  Additionally, the error trap global ^%ZTER(1) is deleted in routine"
 .W !,"^NVSTAR0.  Finally, the FAILED ACCESS ATTEMPTS global ^%ZUA(3.05), and the"
 .W !,"PROGRAMMER MODE LOG global ^%ZUA(3.07) will all be cleaned out and reset."
 .W !!,"You should check the protection settings on all these globals and temporarily"
 .W !,"set them such that this procedure can succeed.  Without this temporary"
 .W !,"change, you will get protection errors when the Utility tries to KILL"
 .W !,"and/or reset these globals."
 .W !!,"Please refer to the AXP Team's document on mirror account reset for"
 .W !,"further information.  If you have any questions about this, please log"
 .W !,"a NOIS and request clarification."
 ;
 ; okay to go?...
 S DIR(0)="YA"
 S DIR("A")="I'm all set...okay to continue? "
 W !
 D ^DIR K DIR
 I Y'=1 D  Q
 .W !!,"ABORTED!"
 .K NVSOPSYS,NVSUCI,^XTMP("NVSTAR")
 ;
 ; is TaskMan running?...
 I $$TM^%ZTLOAD() D
 .W !!,"TaskMan is running...stopping him now..."
 .S NVSX=0
 .F  S NVSX=$O(^%ZTSCH("STATUS",NVSX)) Q:'NVSX  D
 ..S NODE=$P(^%ZTSCH("STATUS",NVSX),"^",3)
 ..D GROUP^ZTMKU("SMAN(NODE)")
 ..D GROUP^ZTMKU("SSUB(NODE)")
 .K ^%ZTSCH("UPDATE"),NODE,NVSX
 .W "done."
 ;
 S ^XTMP("NVSTAR","START")=$$NOW^XLFDT()
 W @IOF
 W !!,"-TEST ACCOUNT RESET UTILITIES-"
 W !," Started ",$$FMTE^XLFDT(^XTMP("NVSTAR","START"))
 ;
 ; disable logins...
 W !!,"DISABLE LOGINS..."
 D DISABL^NVSTAR8
 W "done."
 ;
 ; clean out the existing error trap...
 D CETRAP^NVSTAR0
 ;
 ; check for existence of ^XMB("TIMEDIFF").  if undefined, ask user to fix it...
 D TZ^NVSTAR0
 ;
 ; patient file x-refs...
 D PXREF^NVSTAR0
 ;
 ; Kernel system parameters...
 D ^NVSTAR1
 ;
 ; Close all mailman domains...
 D ^NVSTAR2
 ;
 ; disable printers...
 D ^NVSTAR3
 ;
 ; Clean up HL7, CIRN and MPI data and parameters...
 D RAIMDS^NVSTAR4
 D HL7^NVSTAR4
 D HLCS^NVSTAR4
 D HLL^NVSTAR4
 D HLMA^NVSTAR4
 D DELMPI^NVSTAR4
 ;
 ; reset kernel and taskman data and parameters...
 D ^NVSTAR5
 ;
 ; reset rpc broker parameters...
 D BROKER^NVSTAR6
 ;
 ; clear alerts from the alert file...
 D ALERTS^NVSTAR6
 ;
 ; clean up network mail...
 D ^NVSTAR7
 ;
 ; re-enable logins if appropriate...
 I $G(^XTMP("NVSTAR","LOGINS"))'="YES" D
 .W !!,"**LOGINS NOT RE-ENABLED**"
 I $G(^XTMP("NVSTAR","LOGINS"))="YES" D
 .D ^NVSTAR8
 .W !!,"LOGINS RE-ENABLED"
 ;
 K NVSOPSYS,NVSUCI
 S ^XTMP("NVSTAR","END")=$$NOW^XLFDT()
 W !!,"-TEST ACCOUNT RESET UTILITIES-"
 W !," Started:   ",$$FMTE^XLFDT(^XTMP("NVSTAR","START"))
 W !," Completed: ",$$FMTE^XLFDT(^XTMP("NVSTAR","END"))
 K ^XTMP("NVSTAR")
 ;
 S DIR(0)="YA"
 S DIR("A")="Would you like to run the Mail Message Purge procedure? "
 S DIR("B")="NO"
 W !
 D ^DIR K DIR
 I +Y'=1 D
 .W !!,"You can run this separately later if you wish."
 .W !,"The routine name is ^NVSMMP."
 I +Y=1 D ^NVSMMP
 K DIRUT,DTOUT,X,Y
 Q
