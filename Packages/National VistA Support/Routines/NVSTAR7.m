NVSTAR7 ;emc/maw-clean out network mail ;09/01/02
 ;;6.0;EMC TEST ACCOUNT RESET UTILITIES; 01 Jun 1999;;Build 24
 ;
 W !!,"CLEAN OUT POSTMASTER'S NETWORK MAIL BASKETS"
 W !,"This module loops through Postmaster's network mail baskets"
 W !,"(i.e., those baskets containing pointers to messages to be"
 W !,"sent to other sites) and deletes references to messages to"
 W !,"other domains.  It also deletes the actual messages from the"
 W !,"Message file (#3.9)."
 ; get current domain name (should be TEST.domain.yada...)...
 S NVSDOM=+^XMB(1,1,0)
 S NVSDOM=$P(^DIC(4.2,NVSDOM,0),"^")
 ;
 ; clean out Postmaster's network mail baskets (basket record number
 ; increment taken from example in ENT^XMS5)...
 W !?2,"Cleaning out POSTMASTER's network mail baskets"
 S NVSBSKT=999
 F  S NVSBSKT=$O(^XMB(3.7,.5,2,NVSBSKT)) Q:'NVSBSKT!(NVSBSKT>9999)  D
 .S NVSBSKTN=$P(^XMB(3.7,.5,2,NVSBSKT,0),"^")
 .S NVSMSG=0
 .F  S NVSMSG=$O(^XMB(3.7,.5,2,NVSBSKT,1,NVSMSG)) Q:'NVSMSG  D
 ..S NVSMSGN=+$G(^XMB(3.7,.5,2,NVSBSKT,1,NVSMSG,0))
 ..; delete the message entry in this basket...
 ..S DA=NVSMSGN
 ..S DA(1)=NVSBSKT
 ..S DA(2)=.5
 ..S DIK="^XMB(3.7,"_DA(2)_",2,"_DA(1)_",1,"
 ..D ^DIK
 ..K DA,DIK
 ..; delete the message from the message file...
 ..S DA=NVSMSGN
 ..S DIK="^XMB(3.9,"
 ..D ^DIK
 ..K DA,DIK,NVSMSGN
 .;
 .; if this basket happens to be the TEST.domain.yada basket, delete it...
 .I NVSBSKTN=NVSDOM D
 ..S DA=NVSBSKT
 ..S DA(1)=.5
 ..S DIK="^XMB(3.7,"_DA(1)_",2,"
 ..D ^DIK
 ..K DA,DIK
 K NVSBSKT,NVSBSKTN,NVSMSG
 ;
 ; delete the network mail file...
 W !?2,"Deleting the ^XMB(3.9,""AI"") cross reference..."
 K ^XMBX(3.9,"AI")
 W "done."
 ;
 ; remove any remote users from the MAIL GROUP file...
 W !?2,"Removing any remote users from the MAIL GROUP file (#3.8)..."
 S NVSGRP=0
 F  S NVSGRP=$O(^XMB(3.8,NVSGRP)) Q:'NVSGRP  D
 .S NVSREM=0
 .F  S NVSREM=$O(^XMB(3.8,NVSGRP,6,NVSREM)) Q:'NVSREM  D
 ..S DA=NVSREM
 ..S DA(1)=NVSGRP
 ..S DIK="^XMB(3.8,"_DA(1)_",6,"
 ..D ^DIK
 W "done."
 K NVSDOM,NVSGRP,NVSREM
 Q
