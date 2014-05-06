VFDVFOI2 ;DSS/SGM - TEXT FOR VFDVFOIA ;24AUG2009
 ;;2009.2;DSS,INC VXVISTA OPEN SOURCE;;01 Dec 2009
 ;Copyright 1995-2009,Document Storage Systems Inc. All Rights Reserved
 ;
 ;This routine was written by Document Storage Systems, Inc for the VSA
 ; called from VFDVFOIA
 ;
 ;DBIA# Supported Reference
 ;----- -------------------
 ;10104 $$CJ^XLFSTR
 ;
GET N I,S,X,Y,Z K VFDTAB
 S S="___",X=$P($T(1),";",3)
 S VFDTAB(1)=$$CJ(X)
 F I=2:1:30 S X=$P($T(@I),";",3,4) D:X]""
 .S Y=$P(X,";"),Z=$P(X,";",2)
 .S VFDTAB(I)=S_Y S:$L(Z) $P(VFDTAB(I),";",2)=S_Z
 .Q
 Q
 ;
BEG() ; opening screen
 ;;FOIA VistA Cache.dat Initialization Tool
 ;;This initialization program is intended to take the VA's FOIA
 ;;cache.dat and do a minimal setup so that vital Kernel programs
 ;;may start up.
 ;;
 ;;This program does not completely configure the Kernel environment.
 ;;Nor does it configure any individual VistA application.  You should
 ;;still do that prior to exercising any individual application.
 ;;
 ;;After running this initialization, "AA12345" will be the sign-on 
 ;;("Access Code") for the first user.
 ;;
 ;;You should be able to launch CPRS.  How much you can do in
 ;;CPRS depends upon how much work you did in configuring CPRS.
 ;;
 ;;Taskman, Mailman, HL7, and Broker will be minimally configured and
 ;;should be able to be started with no further work required.  Several
 ;;Kernel-type options are placed in the OPTION SCHEDULING file so that
 ;;all you have to do is start up Taskman which will then start a Broker
 ;;listener, Mailman, and HL7 filers and manager.
 ;;
 ;;You need to minimally configure your Cache configuration before
 ;;running this program.  These instructions presume you have not
 ;;performed these steps previously.
 ;;
 ;;1. Right click the Cache cube and select Configuration Manager
 ;;2. In the Namespaces tab, double click your namespace
 ;;3. Right click Global Mapping and select Add [add the following]
 ;;        %Z*   TMP   UTILITY
 ;;   Expand the name of the global [double click the global name]
 ;;     a. When added it should have automatically been expanded
 ;;     b. Cache defaults the Data Location to your database
 ;;     c. For %Z* you want the global translated to your database
 ;;     d. For TMP and UTILITY, right click Data Location and select
 ;;        CACHETEMP
 ;;4. Collapse Global Mapping by clicking the [-]
 ;;5. Right Click Routine Mapping and select Add [add the following]
 ;;    %DT*   %RCR   %XU*   %ZIS*   %ZO*   %ZT*   %ZU*   %ZV*
 ;;   Again, Cache should default the Location to your database.
 ;;   Do not change that value
 ;;
 N I,X,Y,Z,LINE,TITLE
 S TITLE=$$CJ^XLFSTR($P($T(BEG+1),";",3),80)
 S $P(LINE,"-",80)=""
 ;
 W @IOF,TITLE,!,LINE
 F I=2:1:19 W !,$TR($T(BEG+I),";"," ")
 Q:$$YN^VFDVFOI3<1 0
 ;
 W !!,TITLE,!,LINE
 F I=21:1:39 W !,$TR($T(BEG+I),";"," ")
 Q:$$YN^VFDVFOI3<1 0
 ;
 W !!,TITLE,!,LINE
 W !,"I can either ask you two simple questions (institution name and time zone)",!,"or a fuller list of technical questions."
 S X=$$YN^VFDVFOI3("Do you want to be asked the complete list of questions? ",0) I X S VFDVMODE="A"
 Q:X<0 X
 ;W !! F I=41:1:46 W !,$TR($T(BEG+I),";"," ")
 ;S X=$$YN^VFDVFOI3
 Q 1
 ;
CJ(X) Q $$CJ^XLFSTR(" "_X_" ",80,"-")
 ;
 ;
DSP N A,I,S,X,Y,Z
 W @IOF,VFDTAB(1)
 F I=1.9:0 S I=$O(VFDTAB(I)) Q:'I  S X=VFDTAB(I) I X]"" W !,$P(X,";"),?40,$P(X,";",2)
 Q
 ;
 ;
 ;
 ;
 ;
 ;
 ;
 ;
ODSP ; display scheduled options
 ;;SETTING SOME SCHEDULED TASKS
 ;;                                 Scheduled
 ;;         OPTION NAME             Frequency     Scheduled Time
 ;;------------------------------   ---------   ------------------
 N I
 W @IOF,$$CJ($P($T(ODSP+1),";",3)),!
 F I=2:1:4 W !,$TR($T(ODSP+I),";"," ")
 Q
 ;
OPT ; display individual option
 N X,Y,Z
 W !?3,VOPT(2),?39,$J(VOPT(4),2),?48 Q:'VOPT
 S Y=VOPT(3),Z="" I +Y S Z=$E($P(Y,".",2)_"0000",1,4)
 I 'Y S Z="Startup" S:Y="SP" Z=Z_" Persistent"
 W Z
 Q
 ;
TASK ; msg about starting taskman
 ;;I am ready to start Taskman.
 ;;
 ;;Taskman will hang for 90 seconds before it attempts to start up any
 ;; tasked jobs.  These will be those scheduled Options displayed above.
 ;;If everything is set up properly, Mailman should start.  The Broker
 ;; should start.  HL processes should start.
 ;; 
 N I,X,Y,Z S Y=0
 W ! F I=1:1:7 D
 .S X=$P($T(TASK+I),";",3),Z=$E(X)'=" " S:Z Y=Y+1
 .W !?3,X
 .Q
 Q
 ;
S(L,P) Q:$G(DSS)!'$D(VFDTAB(L))
 N X S X=$P(VFDTAB(L),";",P),$E(X,2)="x",$P(VFDTAB(L),";",P)=X
 Q
 ;
TABLE ;
1 ;;STATUS OF FOIA CACHE.DAT INITIALIZATION
2 ;;Get System variables;Delete unnecessary Domains
3 ;;Get VOLUME name;Close remaining Domains
4 ;;Get DOMAIN name;Create new primary Domain
 ;5 ;;Get NULL device;Configure NULL device for Windows
 ;6 ;;Get TELNET device;Configure TELNET device for Windows
 ;7 ;;Get HFS device;Configure HFS device for Windows
8 ;;Get default HFS directory;Get Time Zone
9 ;;Set ^%ZOSF("PROD") & ^("MGR");Configure Mailman Site Parameters
10 ;;Set ^%ZOSF("VOL");Get Broker port number
11 ;;Clean up ^%ZTSK & ^%ZTSCH;Configure RPC Broker Site Parameters
12 ;;Delete existing Volume entries;Create VFDV SYS MGMT mail group
13 ;;Configure Volume file;Add mail group to bulletin(s)
14 ;;Delete Taskman Site Parameters;Config HL COMM SVR PARAMS (#869.3)
15 ;;Create new Taskman Site Params;Clean up HL7 MESSAGE TEXT (#772)
16 ;;Reinitialize Fileman;Clean up HL7 MESSAGE ADMIN (#773)
17 ;;Reinitialize Kernel/Taskman;Clean up HL LOGICAL LINK (#870)
18 ;;Get DNS IP Address;Create/Enable Log Link LL999CIVH
19 ;;Get default Institution name;Add ACCESS CODE to User #1
20 ;;Create new Institution entry;Configure Kernel System Parameters
 ;21 ;;Configure Kernel System Parameters;Save %ZSTOP in %SYS
22 ;;Set ^DD("SITE");Start Audits on key Files
