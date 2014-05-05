NVSTAR5 ;emc/maw-reset task manager parameters and data ;09/01/02
 ;;6.0;EMC TEST ACCOUNT RESET UTILITIES; 01 Jun 1999;;Build 24
 ;
 ; reference: NAME^ZTMGRSET:
 ; if the OS is Cache, make sure certain nodes in ^%ZOSF are correct (note
 ; that these are the cookbook settings for the namespaces on the test system)...
 W !!,"RESET KERNEL AND TASK MANAGER PARAMETERS AND DATA"
 I NVSOPSYS["OpenM" D
 .I ^%ZOSF("MGR")'="TST" S ^%ZOSF("MGR")="TST"
 .W !?2,"Set ^%ZOSF(""MGR"")=",^%ZOSF("MGR"),"...done."
 .I ^%ZOSF("PROD")'="TST" S ^%ZOSF("PROD")="TST"
 .W !?2,"Set ^%ZOSF(""PROD"")=",^%ZOSF("PROD"),"...done."
 .I ^%ZOSF("VOL")'="ROU" S ^%ZOSF("VOL")="ROU"
 .W !?2,"Set ^%ZOSF(""VOL"")=",^%ZOSF("VOL"),"...done."
 .;
 .; allow unsubscripted global kills...
 .S X=$ZU(68,28,0)
 .;
 .; reference: GLOBALS^ZTMGRSET:
 .; reset task list...
 .W !!?2,"Delete TASKS (^%ZTSK(...))..."
 .K ^%ZTSK
 .S ^%ZTSK(-1)=100
 .S ^%ZTSK(0)="TASK'S^14.4^100"
 .W "done."
 .;
 .; delete and reset the schedule file...
 .W !?2,"Delete SCHEDULED TASKS (^%ZTSCH(...))..."
 .K ^%ZTSCH
 .S ^%ZTSCH=""
 .W "done."
 ;
 ; for DSM, we have to handle the KILL and SET of the TaskMan globals
 ; a little more carefully...
 I NVSOPSYS["DSM" D
 .W !!?2,"Delete TASKS (^%ZTSK(...))..."
 .S NVSX=0
 .F  S NVSX=$O(^%ZTSK(NVSX)) Q:'NVSX  K ^%ZTSK(NVSX)
 .S ^%ZTSK(-1)=100
 .S ^%ZTSK(0)="TASK'S^14.4^100"
 .K NVSX
 .W "done."
 .;
 .W !?2,"Delete SCHEDULED TASKS (^%ZTSCH(...))..."
 .S NVSX=""
 .F  S NVSX=$O(^%ZTSCH(NVSX)) Q:NVSX=""  K ^%ZTSCH(NVSX)
 .K NVSX
 .W "done."
 ;
 ; remove TASK ID data for all previously-scheduled options in the
 ; OPTION SCHEDULING file (#19.2)...
 W !?2,"Remove any TASKS pointers from OPTION SCHEDULING file (#19.2)..."
 N NVSDATA,NVSIEN
 S NVSIEN=0
 F  S NVSIEN=$O(^DIC(19.2,NVSIEN)) Q:'NVSIEN  D
 .S NVSDATA=$G(^DIC(19.2,NVSIEN,1))
 .I $P(NVSDATA,"^")="" Q
 .S $P(^DIC(19.2,NVSIEN,1),"^")=""
 K NVSDATA,NVSIEN
 W "done."
 ;
 ; if account is post patch XU*8.0*142, set DNS IP field in file
 ; 8989.3 (KERNEL SYSTEM PARAMETERS) to 0.0.0.0 (per HL7 Development)...
 I $D(^DD(8989.3,51)) D
 .W !?2,"Set DNS IP (field 51) in KERNEL SYSTEM PARAMETERS file (#8989.3)"
 .W !?4,"to 0.0.0.0 ..."
 .S NVSDNS="0.0.0.0"
 .S DIE="^XTV(8989.3,"
 .S DA=1
 .S DR="51////^S X=NVSDNS"
 .D ^DIE
 .K DA,DIE,DR,NVSDNS
 .W "done."
 ;
 ; reset failed access attempts log...
 W !?2,"Reset FAILED ACCESS ATTEMPTS LOG file (#3.05)..."
 S NVSX=""
 F  S NVSX=$O(^%ZUA(3.05,NVSX)) Q:NVSX=""  K ^%ZUA(3.05,NVSX)
 S ^%ZUA(3.05,0)="FAILED ACCESS ATTEMPTS LOG^3.05^^"
 K NVSX
 W "done."
 ;
 ; reset programmer mode access log...
 W !?2,"Reset PROGRAMMER MODE LOG file (#3.07)..."
 S NVSX=""
 F  S NVSX=$O(^%ZUA(3.07,NVSX)) Q:NVSX=""  K ^%ZUA(3.07,NVSX)
 S ^%ZUA(3.07,0)="PROGRAMMER MODE LOG^3.07^^"
 K NVSX
 W "done."
 Q
