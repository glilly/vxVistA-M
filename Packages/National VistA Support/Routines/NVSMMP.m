NVSMMP ;nvsiss/maw-test account mail messages/baskets purge; 06 Oct 2000  3:57 PM ; 09/01/02
 ;;6.0;EMC TEST ACCOUNT RESET UTILITIES; 01 Jun 1999;;Build 24
 ;
 D HOME^%ZIS
 I $G(IOF)'="" W @IOF
 I '$D(DUZ) S DUZ=.5,DUZ(0)="@"
 D DT^DICRW
 ;
 W !,$$CJ^XLFSTR("ENTERPRISE MANAGEMENT CENTER :: TEST ACCOUNT RESET UTILITIES v6.0",80)
 W !,$$CJ^XLFSTR("MAIL MESSAGE AND BASKET PURGE UTILITY",80)
 I '$D(NVSUCI) S NVSQUIT=0 D  I NVSQUIT'=0 K NVSOPSYS,NVSQUIT,NVSUCI Q
 .I $D(^%ZOSF("UCI")) X ^%ZOSF("UCI")
 .I '$D(Y) D  Q
 ..W $C(7)
 ..W !!,"ERROR:  UCI COULD NOT BE DETERMINED!  ABORTING!"
 ..S NVSQUIT=1
 .S NVSUCI=Y
 .S NVSOPSYS=$P($G(^%ZOSF("OS"),"undefined"),U)
 .;
 W !!,"Current UCI: ",NVSUCI
 I NVSUCI'["TST"&(NVSUCI'["TOU") D
 .W $C(7)
 .W !!,"WARNING:  THIS ACCOUNT DOESN'T APPEAR TO BE YOUR TEST SYSTEM!"
 .W !,"MAKE SURE YOU'RE RUNNING THIS UTILITY IN YOUR TEST SYSTEM!"
 S DIR(0)="YA"
 S DIR("A")="Okay to continue? "
 S DIR("B")="NO"
 W ! D ^DIR K DIR
 I Y'=1!($D(DIRUT)) D  Q
 .S NVSQUIT=1
 .W !!,"Mail Message and Basket Purge Utility aborted!"
 .K DIRUT,DTOUT,X,Y
 D PURGE
 Q
 ;
 ; the following portion of this routine is under development...
 W !!,"This utility will do one of the following things based upon your choice:"
 W !!,"  -delete all messages in the MESSAGE file (^XMB(3.9,...), and then"
 W !,"    (obviously required) clean out all users' mail baskets.  Note that"
 W !,"    the baskets themselves are not deleted.  The end result is NO messages"
 W !,"    remaining in the MESSAGE file."
 W !!,"  -delete all messages EXCEPT for those owned by selected users and/or"
 W !,"    members of selected mail groups.  This obviously takes longer, but"
 W !,"    will leave messages for specified users (for example, members of the"
 W !,"    IRM mail group) untouched.  This could be useful if certain users'"
 W !,"    messages need to be available in the Test account."
 ;
 ; user selects options...
 W !!,"Options for Purging Mail"
 S DIR(0)="NA^1:2"
 S DIR("A")="Select OPTION (1 or 2): "
 S DIR("A",1)="  Option 1:  Purge All Messages"
 S DIR("A",2)="  Option 2:  Select User/Mail Group(s) Message NOT to Purge"
 S DIR("A",3)=" "
 S DIR("?",1)="To delete all messages and clean out all baskets, select Option 1"
 S DIR("?",2)="To select users or mail groups whose messages you DO NOT want to"
 S DIR("?")="delete, select Option 2"
 W ! D ^DIR K DIR
 I $D(DIRUT) K DTOUT,DIRUT,X,Y Q
 S NVSOPT=+Y
 W !,"NVSOPT=",NVSOPT
 I NVSOPT=2 D USEL
 Q
 ;
PURGE ;
 W !!,"Beginning ",$$FMTE^XLFDT($$NOW^XLFDT)
 ;
 ; if Option 2 was selected, search selected users' mail baskets for messages
 ; that will not be deleted...
 ;I $D(^TMP("NVSMMP",$J)) D ^NVSMMP1
 ;
 ; purge messages from ^XMB(3.9)...
 W !!,"Purging MESSAGE file..."
 I '$D(^TMP("NVSMMP",$J,"MESSAGES")) D
 .K ^XMB(3.9)
 .S ^XMB(3.9,0)="MESSAGE^3.9s^^"
 ;I $D(^TMP("NVSMMP",$J,"MESSAGES")) D
 ;.W "(this may take a while)..."
 ;.S NVSMSG=0
 ;.F  S NVSMSG=$O(^XMB(3.9,NVSMSG)) Q:'NVSMSG  D
 ;..I $D(^TMP("NVSMMP",$J,"MESSAGES",NVSMSG)) Q
 ;..S DA=NVSMSG
 ;..S DIK="^XMB(3.9,"
 ;..D ^DIK
 W "done."
 ;
 W !!,"Cleaning out mail baskets in ^XMB(3.7) "
 S NVSCOUNT=0
 ; remove some mail box file xrefs...
 K ^XMB(3.7,"AC")
 K ^XMB(3.7,"AD")
 K ^XMB(3.7,"M")
 ;
 ; purge mail boxes...
 S NVSMBOX=0
 F  S NVSMBOX=$O(^XMB(3.7,NVSMBOX)) Q:'NVSMBOX  D
 .I $D(^TMP("NVSMMP",$J,"USERS",NVSMBOX)) Q
 .S NVSCOUNT=NVSCOUNT+1
 .I '(NVSCOUNT#100) W "."
 .;
 .; remove forwarding address and make sure local delivery flag is on...
 .S $P(^XMB(3.7,NVSMBOX,0),U,2)=""
 .S $P(^XMB(3.7,NVSMBOX,0),U,8)=1
 .;
 .; reset message edited and message responded fields...
 .S NVSDATA=$G(^XMB(3.7,NVSMBOX,"T"))
 .I NVSDATA'="" D
 ..S $P(NVSDATA,U)=""
 ..S $P(NVSDATA,U,3)=""
 ..S ^XMB(3.7,NVSMBOX,"T")=NVSDATA
 .K NVSDATA
 .;
 .; delete new message and priority message nodes...
 .K ^XMB(3.7,NVSMBOX,"N")
 .K ^XMB(3.7,NVSMBOX,"N0")
 .;
 .; reset new message count and MESSAGE @ REINSTATEMENT fields...
 .S $P(^XMB(3.7,NVSMBOX,0),U,6)=0
 .S $P(^XMB(3.7,NVSMBOX,0),U,7)=0
 .;
 .S NVSMBSKT=0
 .F  S NVSMBSKT=$O(^XMB(3.7,NVSMBOX,2,NVSMBSKT)) Q:'NVSMBSKT  D
 ..S NVSDATA=$G(^XMB(3.7,NVSMBOX,2,NVSMBSKT,0))
 ..F NVSX=2:1:5 S $P(NVSDATA,U,NVSX)=""
 ..S ^XMB(3.7,NVSMBOX,2,NVSMBSKT,0)=NVSDATA
 ..K NVSDATA,NVSX
 ..S ^XMB(3.7,NVSMBOX,2,NVSMBSKT,1,0)="^3.702P^^"
 ..S NVSMSG=""
 ..F  S NVSMSG=$O(^XMB(3.7,NVSMBOX,2,NVSMBSKT,1,NVSMSG)) Q:NVSMSG=""  D
 ...K ^XMB(3.7,NVSMBOX,2,NVSMBSKT,1,NVSMSG)
 W "done."
 ;
 ; clean up ^XMBPOST...
 W !!,"Cleaning up ^XMBPOST"
 S NVSX=""
 F  S NVSX=$O(^XMBPOST(NVSX)) Q:NVSX=""  K ^XMBPOST(NVSX)
 S ^XMBPOST("LINES_READ",0)=0
 S ^XMBPOST("PGROUPM",1)=""
 S ^XMBPOST("PGROUPR",1)=""
 S ^XMBPOST("POST")=0
 S ^XMBPOST("STATS","M")=0
 S ^XMBPOST("STATS","R")=0
 K NVSX
 W " -- done."
 ;
 ; finally, delete the network mail file...
 W !!,"Deleting network mail file ^XMBX(3.9,""AI"")"
 K ^XMBX(3.9,"AI")
 W " -- done."
 ;
 W !!,"All processing done ",$$FMTE^XLFDT($$NOW^XLFDT)
 K NVSCOUNT,NVSDATA,NVSMBOX,NVSMBSKT,NVSMSG,NVSOPSYS,NVSUCI,NVSQUIT
 Q
 ;
USEL ; select user(s) and/or member(s) of mail group(s) whose messages will NOT be deleted..
 K ^TMP("NVSMMP",$J)
 F  D  Q:$D(DIRUT)
 .S DIR(0)="SAO^U:User;M:Mail Group"
 .S DIR("A")=" Select a [U]ser or a [M]ail Group? "
 .W ! D ^DIR K DIR
 .I $D(DIRUT) Q
 .S NVSSEL=Y
 .I NVSSEL="U" D
 ..F  D  I $D(DIRUT) K DTOUT,DIRUT,X,Y Q
 ...S DIR(0)="PAO^3.7:QEFMZ"
 ...S DIR("A")="Select USER: "
 ...D ^DIR K DIR
 ...I $D(DIRUT) Q
 ...S NVSUSER=+Y
 ...S ^TMP("NVSMMP",$J,"USERS",NVSUSER)=""
 ..K NVSUSER
 .K DIRUT,DTOUT,X,Y
 .I NVSSEL="M" D
 ..F  D  I $D(DIRUT) K DTOUT,DIRUT,X,Y Q
 ...S DIR(0)="PAO^3.8:QEFMZ"
 ...S DIR("A")="Select MAIL GROUP: "
 ...W ! D ^DIR K DIR
 ...I $D(DIRUT) Q
 ...S NVSGROUP=+Y
 ...W !,"  Extracting member(s)..."
 ...S NVSUSER=0
 ...F  S NVSUSER=$O(^XMB(3.8,NVSGROUP,1,"B",NVSUSER)) Q:'NVSUSER  D
 ....I $G(^VA(200,+NVSUSER,0))="" Q
 ....W !,"    ",$P($G(^VA(200,NVSUSER,0)),U)
 ....S ^TMP("NVSMMP",$J,"USERS",NVSUSER)=""
 ...K NVSGROUP,NVSUSER
 .K DIRUT,DTOUT,X,Y
 I '$D(^TMP("NVSMMP",$J)) W !!,"No user(s) and/or mail group(s) were selected."
 K DTOUT,DIRUT,X,Y
 Q
