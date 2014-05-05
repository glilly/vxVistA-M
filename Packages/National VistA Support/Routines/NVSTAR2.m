NVSTAR2 ;emc/maw-close all mailman domains; 09/01/02
 ;;6.0;EMC TEST ACCOUNT RESET UTILITIES; 01 Jun 1999;;Build 24
 ;
 W !!,"CLOSE ALL MAILMAN DOMAINS"
 W !?2
 S NVSXDA=0
 F  S NVSXDA=$O(^DIC(4.2,NVSXDA)) Q:'NVSXDA  D
 .I $X>(IOM-10) W !?2
 .S DIE="^DIC(4.2,"
 .S DA=NVSXDA
 .S DR="1///^S X=""C"";1.7///^S X=""y"";2////@"
 .D ^DIE
 .K DA,DIE,DR
 .W "."
 W !,"Done."
 K NVSXDA
 Q
