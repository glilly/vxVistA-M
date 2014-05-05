NVSPDS6 ;emc/maw-set DISUSER flag on selected New Person file records ;09/01/02
 ;;6.0;EMC TEST ACCOUNT RESET UTILITIES; 01 Jun 1999;;Build 24
 ;
 K ^TMP("NVSPDS6",$J)
 S ^TMP("NVSPDS6",$J,.5)=""
 S ^TMP("NVSPDS6",$J,"B","POSTMASTER")=.5
 I $G(IOF)'="" W @IOF
 W !!,"Set DISUSER Flag on New Person Records"
 W !!,"Note:  setting this flag will DISABLE access for"
 W !,"all selected users.  To re-enable access, simply"
 W !,"use File Manager to edit field 7 of the New Person"
 W !,"file (#200) and remove the flag."
 W !!,"POSTMASTER's ACCOUNT WILL NOT BE DISABLED."
 I +$G(DUZ)="" D
 .W $C(7)
 .W !!,"NO DUZ IS DEFINED IN THIS SESSION!"
 .S DIR(0)="PA^200:QEFMZ"
 .S DIR("A")="Please enter YOUR NAME: "
 .D ^DIR K DIR
 .I $D(DIRUT) Q
 .S DUZ=+Y
 .S ^TMP("NVSPDS6",$J,DUZ)=""
 .S ^TMP("NVSPDS6",$J,"B",$P(^VA(200,+DUZ,0),"^"))=+DUZ
 .D DT^DICRW
 .W !!,"The account for ",$P(^VA(200,+DUZ,0),"^")
 .W !,"will NOT be disabled."
 ;
 I +$G(DUZ)=0&($D(DIRUT)) D  Q
 .W !!,"ABORTED"
 .K DIRUT,DTOUT,X,Y
 ;
 ; get any exclusions...
 W !!,"EXCLUSIONS"
 W !,"You may select user accounts that will NOT be disabled."
 W !,"You may do this by either selecting each user individually"
 W !,"or by using a mail group whose members' user accounts will"
 W !,"not be disabled."
 S DIR(0)="YA"
 S DIR("A")="Do you wish to exclude any user accounts? "
 S DIR("B")="NO"
 W !
 D ^DIR K DIR
 I $D(DIRUT) D  Q
 .W !!,"ABORTED!"
 .K DIRUT,DTOUT,X,Y
 .K ^TMP("NVSPDS6",$J)
 S NVSEXCL=+Y
 I NVSEXCL D EXCLUD
 ;
 ; do it...
 W !!,"Okay, I'm ready to begin.  I will disable user access for"
 W !,"all records in the New Person file except for those accounts"
 W !,"that have been excluded."
 S DIR(0)="YA"
 S DIR("A")="Okay to continue? "
 S DIR("B")="NO"
 W !
 D ^DIR K DIR
 I +Y'=1!($D(DIRUT)) W !!,"ABORTED!  NO ACTION TAKEN."
 I +Y=1 D
 .W !!,"Job starting ",$$HTE^XLFDT($H)
 .W !,"There are ",+$P(^VA(200,0),"^",4)," records to process."
 .S NVSUDUZ=.9
 .F  S NVSUDUZ=$O(^VA(200,NVSUDUZ)) Q:'NVSUDUZ  D
 ..;DSS/SGM - BEGIN MODS - check for bad patient record
 ..Q:'$D(^VA(200,NVSUDUZ,0))
 ..;DSS.SGM - END MODS
 ..W !?2,$P(^VA(200,NVSUDUZ,0),"^")
 ..I $D(^TMP("NVSPDS6",$J,NVSUDUZ)) W ?34,"account NOT disabled" Q
 ..S DA=NVSUDUZ
 ..S DIE="^VA(200,"
 ..S DR="7///S X=""YES"""
 ..;D ^DIE
 ..K DA,DIE,DR
 ..W ?34,"account disabled"
 .K NVSUDUZ
 Q
 ;
EXCLUD ; exclude user accounts...
 F  D  Q:$D(DIRUT)
 .W !!,"EXCLUDE USER ACCOUNTS"
 .S DIR(0)="SA^1:USER;2:MAIL GROUP;3:VIEW;4:EDIT;5:QUIT"
 .S DIR("A")="Select OPTION (1-5): "
 .S DIR("A",1)="  [1] Select Users Individually"
 .S DIR("A",2)="  [2] Select Users by Mail Group"
 .S DIR("A",3)="  [3] View List of Excluded Accounts"
 .S DIR("A",4)="  [4] Remove Accounts from the Exclusion List"
 .S DIR("A",5)="  [5] QUIT"
 .S DIR("A",6)=" "
 .S DIR("B")="5"
 .W !
 .D ^DIR K DIR
 .I +Y=5 S DIRUT=1
 .I $D(DIRUT) Q
 .S NVSOPT=+Y
 .I NVSOPT=1 D  Q
 ..D USER
 ..K NVSOPT
 .I NVSOPT=2 D  Q
 ..D MGRP
 ..K NVSOPT
 .I NVSOPT=3 D  Q
 ..D VIEW
 ..K NVSOPT
 .I NVSOPT=4 D
 ..D EDIT
 ..K NVSOPT
 K DIRUT,DTOUT,X,Y
 Q
 ;
USER ; select users individually...
 F  D  Q:$D(DIRUT)
 .S DIR(0)="PO^200:QEFMZ"
 .W !
 .D ^DIR K DIR
 .I $D(DIRUT) Q
 .S NVSUDUZ=+Y
 .S NVSUNAM=Y(0,0)
 .S ^TMP("NVSPDS6",$J,NVSUDUZ)=""
 .S ^TMP("NVSPDS6",$J,"B",NVSUNAM)=NVSUDUZ
 .W !?2,NVSUNAM," excluded."
 .K NVSUDUZ,NVSUNAM
 K DIRUT,DTOUT,X,Y
 Q
 ;
MGRP ; select users by mail group...
 F  D  Q:$D(DIRUT)
 .S DIR(0)="PO^3.8:QEFMZ"
 .W !
 .D ^DIR K DIR
 .I $D(DIRUT) Q
 .S NVSMGRP=+Y
 .S NVSMGNM=Y(0,0)
 .S NVSX=0
 .F  S NVSX=$O(^XMB(3.8,NVSMGRP,1,NVSX)) Q:'NVSX  D
 ..S NVSUDUZ=+^XMB(3.8,NVSMGRP,1,NVSX,0)
 ..S NVSUNAM=$P(^VA(200,NVSUDUZ,0),"^")
 ..S ^TMP("NVSPDS6",$J,NVSUDUZ)=""
 ..S ^TMP("NVSPDS6",$J,"B",NVSUNAM)=NVSUDUZ
 ..W !?2,NVSUNAM," excluded."
 ..K NVSUDUZ,NVSUNAM
 .K NVSMGNM,NVSMGRP,NVSX
 K DIRUT,DTOUT,X,Y
 Q
 ;
VIEW ; view the list of selected users...
 I $G(IOF)'="" W @IOF
 W !!,"User Accounts that WILL NOT be disabled:"
 W !
 S NVSUNAM=""
 F  S NVSUNAM=$O(^TMP("NVSPDS6",$J,"B",NVSUNAM)) Q:NVSUNAM=""  D
 .I $X>1&($X<40) W ?40
 .W NVSUNAM
 .I $X>40 W !
 S DIR(0)="EA"
 S DIR("A")="Press <enter> to continue..."
 W !
 D ^DIR K DIR
 K DIRUT,DTOUT,X,Y
 Q
 ;
EDIT ; edit the exclusion list...
 F  D  Q:$D(DIRUT)
 .S DIR(0)="PA^200:QEFMZ"
 .S DIR("A")="Select USER NAME TO REMOVE FROM EXCLUSION LIST: "
 .S DIR("?")="^D VIEW^NVSPDS6"
 .W !
 .D ^DIR K DIR
 .I $D(DIRUT) Q
 .S NVSUDUZ=+Y
 .S NVSUNAM=Y(0,0)
 .I NVSUDUZ=.5 D  Q
 ..W !?2,"POSTMASTER's account WILL NOT BE DISABLED."
 .I '$D(^TMP("NVSPDS6",$J,NVSUDUZ)) D  Q
 ..W !?2,NVSUNAM," is NOT in the current exclusion list."
 ..K NVSUDUZ,NVSUNAM
 .K ^TMP("NVSPDS6",$J,NVSUDUZ)
 .K ^TMP("NVSPDS6",$J,"B",NVSUNAM)
 .W !?2,NVSUNAM," removed from exclusion list."
 .K NVSUDUZ,NVSUNAM
 K DIRUT,DTOUT,X,Y
 Q
