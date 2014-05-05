VFDVZSTB ;DSS/SGM - CLEAN UP ROUTINE ;16 Sep 2009 21:26
 ;;2.0;DSS,INC VXVISTA OPEN SOURCE;;29 Jul 2011;Build 92
 ;Copyright 1995-2011,Document Storage Systems Inc. All Rights Reserved
 ;
 ;This routine should only be invoked via VFDVZST
 ;
ASK() ; prompt for which option to run
 ;;Start Taskman
 ;;Stop Taskman (and all tasked jobs)
 ;;Start Broker on this node
 ;;Stop Broker on this node
 ;;Initialize Scheduled Tasks
 ;;Create Cache %ZSTART and %ZSTOP routines
 N A,I,J,X,Y,Z
 S Z(0)="SO^" F I=1:1:5 S Z(0)=Z(0)_I_":"_$P($T(ASK+I),";",3)_";"
 I CACHE S Z(0)=Z(0)_"6:"_$P($T(ASK+6),";",3)_";"
 S Z("A")="   Select Option",Z("?")="^D H1^VFDVZSTB"
 Q $$DIR(.Z)
 ;
H1 ; display help for ASK
 N I,X,Y,Z
 W @IOF,!,"   Current Node: "_VFDENV,!
 F I=1:1 S X=$T(A1+I) Q:X=" ;"  W !,$TR(X,";"," ")
 I $G(CACHE) W ! D
 .F I=1:1 S X=$T(A2+I) Q:X=" ;"  W !,$TR(X,";"," ")
 .Q
 R !!?3,"Press any key to continue ",X:DTIME
 Q
 ;
H2() ; display help for %ZSTART and %ZSTOP option
 N I,X,Y,Z
 W @IOF,!,"    Current Node: "_VFDENV,!
 F I=1:1 S X=$T(T1+I) Q:X=" ;"  W !,$TR(X,";"," ")
 R !!?3,"Press any key to continue ",X:DTIME
 W @IOF
 F I=1:1 S X=$T(T2+I) Q:X=" ;"  W !,$TR(X,";"," ")
 Q $$DIR(,2)
 ;
ROU(L) ; return %ZSTART or %ZSTOP routine in ROU()
 N I,R,X K ROU
 S ROU=$S(L=1:"%ZSTART",1:"%ZSTOP"),R="R"_L
 F I=1:1 S X=$P($T(@R+I),";",3,99) Q:X=""  S ROU(I)=X
 S ROU(2)=$T(+2),ROU(3)=$T(+3)
 Q
 ;
 ;-----------------------  PRIVATE SUBROUTINES  -----------------------
DIR(DIR,CH) ;
 N X,Y,DIROUT,DIRUT,DTOUT,DUOUT
 I $G(CH)>0 D
 .I CH=1 S DIR(0)="E" Q
 .S DIR(0)="YOA",DIR("A")="   Do you wish to continue? ",DIR("B")="NO"
 .Q
 I '$D(DIR) Q -3
 W ! D ^DIR
 Q $S($D(DTOUT):-2,$D(DUOUT):-1,1:Y)
 ;
A1 ;
 ;;Start Taskman - Startup Taskman on this node.  Depending upon the
 ;;   setup of the Scheduled Tasks file.  If the Broker Startup Option
 ;;   is scheduled, then Taskman should start up the Broker.  The same
 ;;   is true for HL7 and VistALink.
 ;;
 ;;Stop Taskman - this will shut down Taskman as well as the Broker,
 ;;   HL7, and VistALink
 ;;
 ;;Start Broker - this option will start a Broker on this node
 ;;
 ;;Stop Broker - this option will stop a Broker on this node
 ;;
 ;;Initialize Scheduled Tasks - this will schedule a default list of
 ;;   Options.
 ;
A2 ;
 ;;Create - this will create the Cache system routines %ZSTART and
 ;;   %ZSTOP.  These routines are invoked by Cache upon system startup
 ;;   and system shutdown to run user specific tasks.  By creating
 ;;   these routines, Taskman and the Broker should startup
 ;;   automatically when you start Cache.
 ;
T1 ;
 ;;****************** WARNING!  WARNING!  WARNING! *****************
 ;;Running this routine will change the way Cache starts and stops.
 ;;Cache will invoke the %ZSTART and %ZSTOP routine if it finds them
 ;;in the %SYS namespace.  This program will install a new copy of
 ;;both %ZSTART and %ZSTOP into your %SYS namespace.
 ;;
 ;;     IT PERFORMS CACHE SPECIFIC M CODE
 ;;     IT IS NOT COMPATIBLE WITH NON-CACHE SYSTEMS
 ;;*****************************************************************
 ;;
 ;;It will perform the following steps:
 ;;  1. Issue Cache specific $Z functions
 ;;  2. Delete the following routines from the current account:
 ;;     VFDVZSTU, VFDVZST1, ZSTU
 ;;  3. Swap to the %SYS namespace
 ;;     a. Delete the routine ZSTU
 ;;     b. Install the routines %ZSTART and %ZSTOP
 ;
T2 ;
 ;;Both the %ZSTART and %ZSTOP routines may need some modifications:
 ;;1. The line tag UCI contains a '^' delimited list of namespaces in
 ;;   which the startup and shutdown code will run.  Edit this line to
 ;;   correspond to those namespaces you wish this action to occur.
 ;;
 ;;2. If you wish other startup and shutdown actions to occur, then
 ;;   you will need to set the Kernel Parameter VFD ZSTU USER with the
 ;;   executable M code to be run.
 ;;
 ;;3. If the %ZSTART and %ZSTOP routines exist in %SYS, then review
 ;;   the UCI line tag to make sure the namespaces listed there are to
 ;;   be included in the new %ZSTART and %ZSTOP to be installed.
 ;;
 ;;4. This program will automatically edit the UCI line tag in both the
 ;;   the %ZSTART and %ZSTOP routines to include the current namespace
 ;;   from which you are running this program.  If the current UCI tag
 ;;   contains other namespaces besides the current one, those will be
 ;;   preserved in the new %ZTART and %ZSTOP routine.
 ;
R1 ;
 ;;%ZSTART ;DSS/SGM - CACHE STARTUP;03/08/2006 23:55pm
 ;; ;;
 ;; ;;
 ;; ;
 ;; ;This routine was written by Document Storage Systems, Inc
 ;; ;This routine invoked at shutdown if
 ;; ;  1. It resides in the %SYS namespace
 ;; ;  2. The individual line tags enabled (depends upon Cache version)
 ;; ;Enter %ZSTOP in Cache Documentation search window for more details
 ;; ;
 ;; ;The line UCI should contain a '^'-delimited list of namespaces
 ;; ;for which you want to start processes in that namespace.  The
 ;; ;VFDVZST routine must reside in those namespaces for anything to
 ;; ;be done.
 ;; ;
 ;;CALLIN ; An external program begins or completes a CALLIN
 ;; Q
 ;; ;
 ;;JOB ; JOB begins or ends
 ;; Q
 ;; ;
 ;;LOGIN ; User performs a login or logout
 ;; Q
 ;; ;
 ;;SYSTEM ; System startup
 ;; N CODE,VFROM,VINC,VROU,VTO,VUCI
 ;; S VFROM=$ZU(5),VROU="START^VFDVZST"
 ;; S VUCI=$P($T(UCI),";",3) Q:VUCI=""
 ;; S CODE="N X,CODE S X=$ZU(5,VTO) D:$T(@VROU)'="""" @VROU S X=$ZU(5,VFROM)"
 ;; F VINC=1:1:$L(VUCI) S VTO=$P(VUCI,"^",VINC) I VTO'="" X CODE
 ;; Q
 ;; ;
 ;;UCI ;;
 ;
R2 ;
 ;;%ZSTOP ;DSS/SGM - CACHE SHUTDOWN;03/08/2006 23:55pm
 ;; ;;
 ;; ;;
 ;; ;
 ;; ;This routine was written by Document Storage Systems, Inc
 ;; ;This routine invoked at shutdown if
 ;; ;  1. It resides in the %SYS namespace
 ;; ;  2. The individual line tags enabled (depends upon Cache version)
 ;; ;Enter %ZSTOP in Cache Documentation search window for more details
 ;; ;
 ;; ;The line UCI should contain a '^'-delimited list of namespaces
 ;; ;for which you want to stop processes in that namespace.  The
 ;; ;VFDVZST routine must reside in those namespaces for anything to
 ;; ;be done.
 ;; ;
 ;;CALLIN ; An external program begins or completes a CALLIN
 ;; Q
 ;; ;
 ;;JOB ; JOB begins or ends
 ;; Q
 ;; ;
 ;;LOGIN ; User performs a login or logout
 ;; Q
 ;; ;
 ;;SYSTEM ; System shutdown
 ;; N CODE,VFROM,VROU,VTO
 ;; S VFROM=$ZU(5),VROU="STOP^VFDVZST"
 ;; S VUCI=$P($T(UCI),";",3) Q:VUCI=""
 ;; S CODE="N X,CODE S X=$ZU(5,VTO) D:$T(@VROU)'="""" @VROU S X=$ZU(5,VFROM)"
 ;; F VINC=1:1:$L(VUCI) S VTO=$P(VUCI,"^",VINC) I VTO'="" X CODE
 ;; Q
 ;; ;
 ;;UCI ;;
