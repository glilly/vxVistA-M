NVSTAR6 ;emc/maw-reset rpc broker parameters and clear alerts ;09/01/02
 ;;6.0;EMC TEST ACCOUNT RESET UTILITIES; 01 Jun 1999;;Build 24
 ;
BROKER ; reset rpc broker parameters...
 ; rpc broker parameters file exists?...
 W !,"RESET RPC BROKER PARAMETERS file"
 I '$D(^XWB(8994.1,0)) D  Q
 .W !?2,"No RPC BROKER PARAMETERS file exists here!" Q
 ;
 S NVSCKFLG=1
 ;
 ; a BOX-VOLUME pair exists in ^%ZIS(14.7,...)?  If NVSOPSYS["OpenM" we're
 ; looking for 'ROU:'_Cache configuration name (e.g., ROU:TEST).
 ; If NVSOPSYS["DSM" we're looking for [at least] 'TOU'.
 ; NOTE: NVSBOXFN *may* be used later in this routine to set up at least one
 ; BOX-VOLUME PAIR (if no PAIR(s) exist at all)...
 I NVSOPSYS["OpenM" D
 .S NVSCFG="ROU:"
 .S NVSVER=$ZV
 .I NVSVER["2.1." S NVSCFG=NVSCFG_$P($ZU(86),"*",3)
 .I NVSVER["3.2" S NVSCFG=NVSCFG_$P($ZU(86),"*",2)
 .I NVSVER["OpenVMS" S NVSCFG=NVSCFG_$P($ZU(86),"*",2)
 .I NVSVER["4.1." S NVSCFG=NVSCFG_$P($ZU(86),"*",2)
 .K NVSVER
 .W !?2,"Edit TASKMAN SITE PARAMETERS file (#14.7) for"
 .W !?2,"this Cache configuration name: ",NVSCFG
 .W !?2,"This procedure looks for the first BOX-VOLUME PAIR record"
 .W !?2,"in file 14.7 and changes the NAME field of that record..."
 .S NVSBOXFN=+$O(^%ZIS(14.7,"B",NVSCFG,0))
 .; if NVSBOXFN=0 then we don't have a good BOX-VOLUME PAIR.  so, let's
 .; see if there is an entry and if so, let's rename it for this account...
 .I NVSBOXFN=0 D
 ..S NVSX=+$O(^%ZIS(14.7,0))
 ..I NVSX=0 K NVSX Q
 ..W !?4,"Record #",NVSX
 ..W "  NAME field = ",$P($G(^%ZIS(14.7,NVSX,0)),"^")
 ..S NVSBOXFN=NVSX
 ..S DIE="^%ZIS(14.7,"
 ..S DA=NVSX
 ..S DR=".01///^S X=NVSCFG"
 ..D ^DIE
 ..K DA,DIE,DR,NVSX
 .I NVSBOXFN=0 D
 ..S NVSCKFLG=0
 ..W $C(7)
 ..W !?2,"Error editing TASKMAN SITE PARAMETERS file!"
 ..W !?2,"I could not find a record in file 14.7."
 .I NVSBOXFN'=0 W !?4,"Changed to ",NVSCFG
 ;
 ; DSM operating system...
 I NVSOPSYS["DSM" D
 .D GETENV^%ZOSV
 .S NVSCFG=$P(Y,"^",4)
 .S NVSBOXFN=+$O(^%ZIS(14.7,"B",NVSCFG,0))
 .I NVSBOXFN'>0 D
 ..S NVSCKFLG=0
 ..W !?4,"Error finding BOX-VOLUME PAIR in TASKMAN SITE PARAMETERS file (#14.7)."
 ..W !?4,"There should be an entry for ",NVSCFG," in file 14.7 but there is not."
 ..W !?4,"This particular procedure is abandoned, but you should check this out"
 ..W !?4,"because Task Manager may not run in this account without the correct"
 ..W !?4,"BOX-VOLUME PAIR entry for ",NVSCFG," in that file."
 ;
 ; a domain name exists at ^XMB(1,1,0)?  NOTE:  NVSDOMFN will be used later in
 ; this routine...
 I NVSCKFLG D
 .S NVSDOMFN=+^XMB(1,1,0)
 .S NVSDOMNM=$P($G(^DIC(4.2,NVSDOMFN,0)),U)
 .I NVSDOMNM="" D
 ..S NVSCKFLG=0
 ..W !?2,"No DOMAIN name exits in the Domain file (^XMB(1,1,0)!"
 ;
 ; at this point, if any checks failed, we abort our reset attempt...
 I 'NVSCKFLG D  Q
 .W !,"Reset of RPC BROKER PARAMETERS file aborted."
 .K NVSBOXFN,NVSCKFLG,NVSDOMFN,NVSDOMNM
 ;
 ; we're ready to set/reset what've we've got...
 K NVSCKFLG,NVSX
 ;
 ; reset domain name (if needed)...
 W !?4,"Edit domain name in RPC BROKER PARAMETERS file (#8994.1)..."
 S NVSCURDM=+$G(^XWB(8994.1,1,0))
 S NVSCURDM=$P($G(^DIC(4.2,NVSCURDM,0)),U)
 S NVSDOMF=$S(NVSCURDM=NVSDOMNM:1,1:0)
 I 'NVSDOMF D
 .K ^XWB(8994.1,"B")
 .S $P(^XWB(8994.1,1,0),U)=NVSDOMFN
 .S ^XWB(8994.1,"B",NVSDOMFN,1)=""
 .I NVSCURDM="" D
 ..S $P(^XWB(8994.1,0),U,3)=1
 ..S $P(^XWB(8994.1,0),U,4)=1
 W "done."
 ;
 ; if no box-volume pair, enter one (from the taskman parameters file) found
 ; in the module above.  enter tcp port 9200 as well...
 I '+$O(^XWB(8994.1,1,7,0)) D
 .S ^XWB(8994.1,1,7,0)="^8994.17P^1^1"
 .S ^XWB(8994.1,1,7,1,0)=NVSBOXFN
 .S ^XWB(8994.1,1,7,"B",NVSBOXFN,1)=""
 .S ^XWB(8994.1,1,7,1,1,0)="^8994.171^1^1"
 .S ^XWB(8994.1,1,7,1,1,1,0)="9200^^^"
 .S ^XWB(8994.1,1,7,1,1,"B","9200",1)=""
 ;
 ; reset status to STOPPED for any ports found in all BOX-VOLUME pairs...
 W !?4,"Reset STATUS field to ""STOPPED"" for any ports found..."
 S NVSX=0
 F  S NVSX=$O(^XWB(8994.1,1,7,NVSX)) Q:'NVSX  D
 .S NVSY=0
 .F  S NVSY=$O(^XWB(8994.1,1,7,NVSX,1,NVSY)) Q:'NVSY  D
 ..S NVSDATA=^XWB(8994.1,1,7,NVSX,1,NVSY,0)
 ..S $P(NVSDATA,U,2)=6
 ..S $P(NVSDATA,U,4)=1
 ..S ^XWB(8994.1,1,7,NVSX,1,NVSY,0)=NVSDATA
 ..K NVSDATA
 W "done."
 ;
 K NVSBOX,NVSBOXFN,NVSBVF,NVSCFG,NVSCURDM,NVSDOMF,NVSDOMFN,NVSDOMNM,NVSPORTF,NVSX,NVSY
 Q
 ;
ALERTS ; clear all alerts from the ALERT file (^XTV(8992,...))...
 W !!,"CLEAR ALERTS FROM THE ALERT FILE (^XTV(8992,...)"
 W !?2,"Records processed = "
 W ?22,$J("0",10)
 N DA,DIK,NVSC,NVSCOUNT,NVSX,X,Y
 S NVSC="F ZZ=1:1:10 W $C(8)"
 S (NVSCOUNT,NVSX)=0
 F  S NVSX=$O(^XTV(8992,NVSX)) Q:'NVSX  D
 .S NVSCOUNT=NVSCOUNT+1
 .X NVSC
 .W $J(NVSCOUNT,10)
 .S DIK="^XTV(8992,"
 .S DA=NVSX
 .D ^DIK
 .K DA,DIK,X,Y
 W !,"Done."
 Q
