NVSTAR1 ;emc/maw-reset various kernel system parameters ;09/01/02
 ;;6.0;EMC TEST ACCOUNT RESET UTILITIES; 01 Jun 1999;;Build 24
 ;
 W !!,"RESET KERNEL SYSTEM PARAMETERS"
 ; check the integrity of the Kernel Site Parameters file...repair if needed...
 W !?2,"Integrity of Kernel Site Parameters file..."
 S NVSX=$O(^XMB(1,0))
 I NVSX'=1 D
 .S %X="^XMB(1,"_NVSX_","
 .S %Y="^XMB(1,1,"
 .D %XY^%RCR
 .S DA=NVSX
 .S DIK="^XMB(1,"
 .D ^DIK
 .K %X,%Y,DA,DIK,X,Y
 W "okay."
 K NVSX
 ;
 ; get data about the current domain set up...
 S NVSDATA=$G(^XMB(1,1,0))
 I NVSDATA="" D  Q
 .W $C(7)
 .W !,"ERROR: There is no usable or existing Kernel Site Parameters file!"
 .W !,"ABORTED!"
 .K NVSDATA
 ;
 ; the variable NVSTHISY will equal the pointer (record number) of the
 ; *current* domain name from the DOMAIN file...
 S NVSTHISY=+NVSDATA
 S NVSTHIS=$P($G(^DIC(4.2,NVSTHISY,0)),U)
 W !?2,"Checking/resetting this system's domain name..."
 I NVSTHIS="" D  Q
 .W $C(7)
 .W !?4,"ERROR: Domain file entry for this domain is missing!!"
 .W !?4,"**DOMAIN NAME RESET ABORTED**"
 .K NVSDATA,NVSTHIS,NVSTHISY
 ;
 W !?4,"The Domain file record number pointer at $P(^XMB(1,1,0),""^"",1) = ",NVSTHISY
 W !?4,"The NAME field for this record = ",NVSTHIS
 I $P(NVSTHIS,".")="TEST"!($P(NVSTHIS,".")="TST") W !?4,"This is correct -- no changes will be made."
 ;
 ; if the *current* domain name isn't already TEST.domain OR TST.domain, then we'll need to
 ; make sure we have one (i.e., one called TEST.domain) in the Domain file.  We'll
 ; then need to swap that created TEST.domain with the *current* domain record in
 ; order to create a domain that is TEST.domain.  If, however, the *current* domain
 ; already contains TEST.domain, then we do nothing (everything is already done)...
 I $P(NVSTHIS,".")'="TEST"&($P(NVSTHIS,".")'="TST") D
 .S (NVSTEST,X)="TEST."_NVSTHIS
 .S X=NVSTEST
 .S DIC="^DIC(4.2,"
 .S DIC(0)="MZ"
 .D ^DIC
 .K DIC
 .S NVSTESTY=+Y
 .;
 .; if NVSTESTY'>0 then the first ^DIC lookup failed.  Let's try it with "TST."...
 .I NVSTESTY'>0 D
 ..S (NVSTEST,X)="TST."_NVSTHIS
 ..S DIC="^DIC(4.2,"
 ..S DIC(0)="MZ"
 ..D ^DIC
 ..K DIC
 ..S NVSTESTY=+Y
 .;
 .; if NVSTESTY'>0 then both ^DIC lookups failed.  We need to create a stub TEST.domain
 .; record entry...
 .I NVSTESTY'>0 D
 ..L +^DIC(4.2,0):5
 ..I '$T D  Q
 ...W $C(7)
 ...W !!?4,"ERROR: Unable to create an entry in the Domain file for"
 ...W !?4,"TEST.",NVSTHIS,"!"
 ..S NVSTESTY=+$P(^DIC(4.2,0),U,3)+1
 ..S NVSX=+$P(^DIC(4.2,0),U,4)+1
 ..S $P(^DIC(4.2,0),U,3)=NVSTESTY
 ..S $P(^DIC(4.2,0),U,4)=NVSX
 ..S $P(^DIC(4.2,NVSTESTY,0),U)="TEST."_NVSTHIS_"^C"
 ..S ^DIC(4.2,"B","TEST."_NVSTHIS,NVSTESTY)=""
 ..K NVSX
 ..L -^DIC(4.2,0)
 .;
 .; we now have both the domains we need.  next, swap their entire records...
 .K NVSTHIS1,NVSTEST1
 .; merge the current domain record into NVSTHIS1...
 .M NVSTHIS1=^DIC(4.2,NVSTHISY)
 .; merge the test domain record into NVSTEST1...
 .M NVSTEST1=^DIC(4.2,NVSTESTY)
 .; delete the current and test domain file records...
 .F NVSX=NVSTHISY,NVSTESTY D
 ..S DA=NVSX
 ..S DIK="^DIC(4.2,"
 ..D ^DIK
 .; merge the test domain into the current domain record number...
 .M ^DIC(4.2,NVSTHISY)=NVSTEST1
 .; merge the current domain into the test domain record number...
 .M ^DIC(4.2,NVSTESTY)=NVSTHIS1
 .; re-index just these two records...
 .F NVSX=NVSTHISY,NVSTESTY D
 ..S DA=NVSX
 ..S DIK="^DIC(4.2,"
 ..D IX1^DIK
 .;
 .; reset domain names so: NVSTHIS now = TEST.domain,
 .;                    and NVSTEST now = production.domain...
 .S NVSTHIS=$P(^DIC(4.2,NVSTHISY,0),U)
 .S NVSTEST=$P(^DIC(4.2,NVSTESTY,0),U)
 .;
 .; edit ^XMB("NAME") and ^XMB("NETNAME") to our *new* TEST.domain name...
 .; reference: KSP^XMYPOST2...
 .S (^XMB("NAME"),^XMB("NETNAME"))=NVSTHIS
 .;
 .W !?4,"Renamed the Domain file record ",NVSTHISY," NAME field to ",NVSTHIS
 .;
 .S DIE="^XMB(1,"
 .S DA=1
 .S DR="3///^S X=NVSTEST"
 .D ^DIE
 .K DA,DIE,DR,X,Y
 .;
 .; remove any relay domain for production domain (NVSTEST)...
 .W !!?2,"Removing any relay domains..."
 .I $P(^DIC(4.2,NVSTESTY,0),U,2)="" W !?2,"None found."
 .I $P(^DIC(4.2,NVSTESTY,0),U,2)'="" D
 ..S DIE=4.2
 ..S DA=NVSTESTY
 ..S DR="2///@"
 ..D ^DIE
 ..K DA,DIE,DR,X,Y
 ..W !?4,"Relay domain entry in ",NVSTEST," deleted."
 .;
 .; remove any synonyms for the TEST.sitename record...
 .W !!?2,"Removing any synonyms..."
 .I '$O(^DIC(4.2,NVSTESTY,2,0)) W !?2,"None found."
 .I $O(^DIC(4.2,NVSTESTY,2,0)) D
 ..S NVSX=0
 ..F  S NVSX=$O(^DIC(4.2,NVSTESTY,2,NVSX)) Q:'NVSX  D
 ...W !?4,$G(^DIC(4.2,NVSTESTY,2,NVSX,0))
 ...S DA=NVSX
 ...S DA(1)=NVSTESTY
 ...S DIK="^DIC(4.2,"_DA(1)_",2,"
 ...D ^DIK
 ...W "...deleted."
 ..K DA,DIK,NVSX
 ; 
 ; Cache system-specific changes to ^XMB(1,1,0), and Taskman files 14.5 and 14.7...
 ; Note:  changes are made to DSM systems later in this routine.
 I NVSOPSYS["OpenM" D
 .I $P(^XMB(1,1,0),U,12)="TST" Q
 .S DIE="^XMB(1,"
 .S DA=1
 .S DR="7.5///^S X=""TST"""
 .D ^DIE
 .K DA,DIE,DR,X,Y
 .;
 .W !?2,"MailMan's ""CPU (UCI,VOL) FOR FILER TO RUN"" field reset to ""TST""."
 .;
 .; reset TaskMan Files UCI field in file 14.5 (OpenM/Cache only)...
 .S NVSX=+$O(^%ZIS(14.5,"B","ROU",0))
 .I 'NVSX D
 ..W $C(7)
 ..S (DIC,DLAYGO)=14.5
 ..S DIC(0)="L"
 ..S X="ROU"
 ..D ^DIC
 ..K DIC,DLAYGO
 ..S NVSX=+Y
 ..I NVSX'>0 D
 ...W $C(7)
 ...W !,"ERROR: No ""ROU"" entry found nor could be added to Volume Set file"
 ...K X,Y,NVSX
 ..K X,Y
 .I NVSX>0 D
 ..S $P(^%ZIS(14.5,NVSX,0),U,6)="TST"
 ..W !?2,"File 14.5, ""TaskMan Files UCI"" field reset to ""TST""."
 .K NVSX
 .;
 .; delete BOX-VOLUME PAIR file (14.7) entries and rebuild it
 .; with Test system configuration.  use the first entry found in
 .; 14.7, edit the name, kill off the file, rebuild it with using the
 .; original IEN for the first entry...
 .W !?2,"Rebulding BOX-VOLUME PAIR entries in file 14.7..."
 .S NVSBOXVN=$O(^%ZIS(14.7,"B",""))
 .S NVSBOXFN=0
 .I NVSBOXVN'="" S NVSBOXFN=+$O(^%ZIS(14.7,"B",NVSBOXVN,0))
 .I NVSBOXFN'>0 D  Q
 ..; error! no BOX-VOLUME PAIR in file 14.7...
 ..W !?2,"ERROR: No BOX-VOLUME PAIR entry in file 14.7!"
 .S NVSDATA=$G(^%ZIS(14.7,NVSBOXFN,0))
 .S NVSCFG="ROU:"
 .S NVSVER=$ZV
 .I NVSVER["2.1." S NVSCFG=NVSCFG_$P($ZU(86),"*",3)
 .I NVSVER["3.2" S NVSCFG=NVSCFG_$P($ZU(86),"*",2)
 .I NVSVER["OpenVMS" S NVSCFG=NVSCFG_$P($ZU(86),"*",2)
 .K NVSVER
 .S $P(NVSDATA,"^")=NVSCFG
 .K ^%ZIS(14.7)
 .S ^%ZIS(14.7,0)="TASKMAN SITE PARAMETERS^14.7^"_NVSBOXFN_"^1"
 .S ^%ZIS(14.7,NVSBOXFN,0)=NVSDATA
 .S ^%ZIS(14.7,"B",NVSCFG,NVSBOXFN)=""
 .W !?4,NVSCFG,"...done."
 ;
 ; remove any "required" entries for volumes in the volume set file...
 W !?2,"Removing any ""required"" entries for volumes in file 14.5..."
 S NVSX=0
 F  S NVSX=$O(^%ZIS(14.5,NVSX)) Q:'NVSX  D
 .W !?4,"Volume ",$P(^%ZIS(14.5,NVSX,0),"^")
 .I $P($G(^%ZIS(14.5,NVSX,0)),U,5)'="Y" W "...OK." Q
 .S $P(^%ZIS(14.5,NVSX,0),U,5)="N"
 .W "...reset to ""NO""."
 K NVSX
 ;
 ; reset ^DD("SITE")...
 W !?2,"^DD(""SITE"") reset to ",NVSTHIS
 S ^DD("SITE")=NVSTHIS
 ;
 ; for DSM system, reset ^%ZOSF("VOL")="TOU"
 I NVSOPSYS["DSM" D 
 .W $C(7)
 .W !?2,">>DSM SITE << **NOTE FOLLOWING CHANGE** >> DSM SITE<<"
 .S ^%ZOSF("VOL")="TOU"
 .W !?2,"^%ZOSF(""VOL"") reset to ""TOU""."
 .W !?2,"This is the ""cookbook"" setting for the VOL name."
 .W !?2,"If this is not what you are using, you will need"
 .W !?2,"to manually edit this global node after the Reset"
 .W !?2,"utility finishes."
 ;        
 ; replacing intro (logon) text...
 S NVSX=+$O(^XTV(8989.3,0))
 I NVSX D
 .W !?2,"Replacing the introductory (logon) text at"
 .W !?4,"^XTV(8989.2,",NVSX,",""INTRO"")"
 .K ^XTV(8989.3,NVSX,"INTRO")
 .S ^XTV(8989.3,NVSX,"INTRO",0)="^^^^"_DT
 .F NVSY=1:1 Q:$P($T(INTRO+NVSY^NVSTAR1),";;",2)["@@"  D
 ..S NVSTEXT=$P($T(INTRO+NVSY^NVSTAR1),";;",2)
 ..S ^XTV(8989.3,NVSX,"INTRO",NVSY,0)=NVSTEXT
 .W "...done."
 .I $D(^XTV(8989.3,NVSX,"POST")) D
 ..W !?2,"Deleting the POST-LOGON text from"
 ..W !?4,"^XTV(8989.3,",NVSX,",""POST"")"
 ..K ^XTV(8989.3,NVSX,"POST")
 .K NVSTEXT,NVSY
 .W "...done."
 ;
 K NVSBOXFN,NVSBOXVN,NVSCFG,NVSDATA,NVSTEST,NVSTESTY,NVSTHIS,NVSTHISY
 Q
 ;       
INTRO ;; introductory text replacement...
 ;;
 ;;            **********     **********     **********     **********
 ;;            **********     **********     **********     **********
 ;;               ****        ****           ****              ****
 ;;               ****        ****           ****              ****
 ;;               ****        *******        **********        ****
 ;;               ****        *******        **********        ****
 ;;               ****        ****                 ****        ****
 ;;               ****        ****                 ****        ****
 ;;               ****        **********     **********        ****
 ;;               ****        **********     **********        ****
 ;;
 ;;                              >>>>> NOTICE <<<<<
 ;;   This account is established for software demonstration, testing and user
 ;;                                 training only.
 ;;    The data in this TEST system is protected by the same confidentiality
 ;;     regulations, statutes, and penalties for unauthorized disclosure as
 ;;                             the production system.
 ;;@@
