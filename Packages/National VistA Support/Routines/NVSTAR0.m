NVSTAR0 ;emc/maw-clean up Patient file x-refs ;09/01/02
 ;;6.0;EMC TEST ACCOUNT RESET UTILITIES; 01 Jun 1999;;Build 24
 ;
CETRAP ; clean out/reset the existing error global...
 W !!,"DELETING AND RESETTING ERROR GLOBAL ^%ZTER(1,...)..."
 K ^%ZTER(1)
 S ^%ZTER(1,0)="ERROR LOG^3.075^^"
 W "done."
 Q
 ;
PXREF ; clean up Patient file x-refs that contain triggers in the event edits
 ; are made to various patient file fields...
 W !!,"DELETING SELECTED TRIGGER CROSS REFERENCES IN THE PATIENT FILE"
 N NVSCHK,NVSFLD,X,Y
 W !?2,"NAME field (.01), xref 301..."
 I '$D(^DD(2,.01,1,301)) W "already deleted."
 I $D(^DD(2,.01,1,301)) D
 .D DELIX^DDMOD(2,.01,301,"W")
 .W !?2,"Done."
 W !?2,"NAME field (.01), xref 991..."
 I '$D(^DD(2,.01,1,991)) W "already deleted."
 I $D(^DD(2,.01,1,991)) D
 .D DELIX^DDMOD(2,.01,991,"W")
 .W !?2,"Done."
 W !?2,"NAME field (.01), xref 992..."
 I '$D(^DD(2,.01,1,992)) W "already deleted."
 I $D(^DD(2,.01,1,992)) D
 .D DELIX^DDMOD(2,.01,992,"W")
 .W !?2,"Done."
 W !?2,"NAME field (.01), xref 993..."
 I '$D(^DD(2,.01,1,993)) W "already deleted."
 I $D(^DD(2,.01,1,993)) D
 .D DELIX^DDMOD(2,.01,993,"W")
 .W !?2,"Done."
 W !?2,"SSN field (.09), xref 9..."
 I '$D(^DD(2,.01,1,9)) W "already deleted."
 I $D(^DD(2,.01,1,9)) D
 .D DELIX^DDMOD(2,.09,9,"W")
 .W !?2,"Done."
 W !?2,"SSN field (.09), xref 301..."
 I '$D(^DD(2,.09,1,301)) W "already deleted."
 I $D(^DD(2,.09,1,301)) D
 .D DELIX^DDMOD(2,.09,301,"W")
 .W !?2,"Done."
 W !?2,"SSN field (.09), xref 991..."
 I '$D(^DD(2,.09,1,991)) W "already deleted."
 I $D(^DD(2,.09,1,991)) D
 .D DELIX^DDMOD(2,.09,991,"W")
 .W !?2,"Done."
 W !?2,"SSN field (.09), xref 992..."
 I '$D(^DD(2,.09,1,992)) W "already deleted."
 I $D(^DD(2,.09,1,992)) D
 .D DELIX^DDMOD(2,.09,992,"W")
 .W !?2,"Done."
 W !?2,"Now, searching Patient file DD to delete"
 W !?4,"any other AVAF* (#991) x-refs..."
 S (NVSCHK,NVSFLD)=0
 F  S NVSFLD=$O(^DD(2,NVSFLD)) Q:'NVSFLD  D
 .I '$D(^DD(2,NVSFLD,1,991)) Q
 .W !?2,$P(^DD(2,NVSFLD,0),"^")," field (",NVSFLD,")..."
 .D DELIX^DDMOD(2,NVSFLD,991,"W")
 .W !?2,"Done."
 .S NVSCHK=NVSCHK+1
 I NVSCHK=0 W "already deleted."
 Q
 ;
TZ ; if ^XMB("TIMEDIFF") is undefined, come here to fix...
 W !!,"CHECK/VERIFY TIME ZONE AND TIME DIFFERENTIAL SETTINGS"
 N DA,DIE,DIR,DIRUT,DR,DTOUT,NVSOK,NVSTZ,NVSTZN,X,Y
 ; if TIME ZONE is defined, use it to reset ^XMB("TIMEDIFF") and quit...
 S NVSTZ=$G(^XMB("TIMEZONE"))
 W !,"Current time zone is ",NVSTZ
 S DIR(0)="YA"
 S DIR("A")="Is this correct? "
 S DIR("B")="YES"
 D ^DIR K DIR
 K DIRUT,DTOUT
 S NVSOK=Y
 I NVSOK=1 D TZEDIT(NVSTZ)
 I NVSOK'=1 D
 .S DIR(0)="PA^4.4:QEFMZ"
 .S DIR("A")="Select CURRENT TIME ZONE: "
 .W ! D ^DIR K DIR
 .I $D(DIRUT) K DIRUT,DTOUT,X,Y Q
 .S NVSTZN=Y(0,0)
 .D TZEDIT(NVSTZN)
 W !?2,"Time Zone: ",$G(^XMB("TIMEZONE"),"**UNDEFINED**")
 W !?2,"Time Diff: ",$G(^XMB("TIMEDIFF"),"**UNDEFINED**")
 Q
 ;
TZEDIT(ZONE) ; edit time zone and time differential...
 N DA,DIE,DR,NVSTZN
 S NVSTZN=ZONE
 S DIE="^XMB(1,"
 S DA=+^XMB(1,1,0)
 S DR="1///^S X=NVSTZN"
 D ^DIE
 Q
