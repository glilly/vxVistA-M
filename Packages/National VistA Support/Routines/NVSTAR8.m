NVSTAR8 ;emc/maw-enable/disable logins ;09/01/02
 ;;6.0;EMC TEST ACCOUNT RESET UTILITIES; 01 Jun 1999;;Build 24
 ;
 ; enable logons...
 ; if this is an Cache system, first check to make sure the system-level
 ; switch is re-enabled...
 I $G(^XTMP("NVSTAR","NVSOPSYS"))["OpenM" D
 .S NVSCNSP=$ZU(5)
 .S X=$ZU(5,"%SYS")
 .I $$%swstat^SWSET(10,0)=1 S X=$$%swset^SWSET(10,0,0)
 .S X=$ZU(5,NVSCNSP)
 .K NVSCNSP
 ;
 D ENABL
 Q
 ;
ENABL ; (re-)enable logons in the volume set file...
 S NVSX=0
 F  S NVSX=$O(^%ZIS(14.5,NVSX)) Q:'NVSX  D
 .S $P(^%ZIS(14.5,NVSX,0),U,2)="N"
 .S NVSXN=$P(^%ZIS(14.5,NVSX,0),U)
 .S ^%ZIS(14.5,"LOGON",NVSXN)=0
 .K NVSXN
 K NVSX
 Q
 ;
DISABL ; disable logons in the volume set file...
 N NVSX,NVSXN
 S NVSX=0
 F  S NVSX=$O(^%ZIS(14.5,NVSX)) Q:'NVSX  D
 .S NVSXN=$P(^%ZIS(14.5,NVSX,0),"^")
 .S $P(^%ZIS(14.5,NVSX,0),"^",2)="Y"
 .S ^%ZIS(14.5,"LOGON",NVSXN)=1
 .K NVSXN
 Q
