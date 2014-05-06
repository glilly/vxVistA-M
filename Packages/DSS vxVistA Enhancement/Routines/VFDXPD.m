VFDXPD ;DSS/SMP - MAIN ROUTINE FOR PATCH MANAGEMENT ;02/27/2013 15:40
 ;;3.1;DSS,INC VXVISTA SUPPORTED;;10 Dec 2012;Build 58
 ;Copyright 1995-2012,Document Storage Systems Inc. All Rights Reserved
 ;
 ; any *.DAT will be considered a Packman mailman msg
 ; any *.KID is an installable KIDS file
 ; any *.TXT is the patch description
 ; It is best if .dat,.kid, and .txt have the same file name
 ;
 ;This describes all IAs directly invoked in any VFDXPD* routines
 ;---------------------------------------------------------------------
 ;ICR # | Supported Reference          |Routine Invoking API
 ;------|------------------------------|-------------------------------
 ; 2051 |^DIC: $$FIND, $$UPDATE        |
 ; 2055 |^DILFD: $$VFIELD, $$VFILE     |VFDXPDI1
 ; 2607 |BROWSE^DDBR                   |VFDXPDE
 ;10013 |^DIK                          |VFDXPDF1
 ;10086 |^%ZIS                         |VFDXPDE
 ;10089 |^%ZISC                        |VFDXPDE
 ;10103 |^XLFDT: $$FMADD, $$FMTE, $$NOW|VFDXPDF2
 ;10104 |^XLFSTR: $$CJ, $$UP           |VFDXPD0
 ;10141 |^XPDUTL: BMES, $$PATCH        |VFDXPDG, VFDXPDI1
 ;
 ;         Fileman and direct global read of file 9.7
 ;         Use FM update and edit to file 9.7
 ;         Read B index on file 9.7
 ;         Read, set, kill ^XTMP("XPDI",ien)
 ;         PKG^XPDIL1
 ;
 ;Notes for programming changes as of 6/18/2010
 ; 1. Refences to ^TMP($J) changed to ^TMP(<namespace>,$J). As such,
 ;    the global structure is different - see line KILL
 ;
 ;EN G EN^VFDXPD09
 Q
 ;
1 ; ADD KID HFS FILES TO 21692 AND A PROCESSING BATCH
 N I,J,X,Y,Z,PATH,PID
 D KILL,PID(1,1,1),PATH:PID>0
 I PID>0,$L(PATH) D 1^VFDXPDF
 G KILL
 ;
2 ; EDIT A PATCH DESCRIPTION
 N I,J,X,Y,Z
 D KILL,2^VFDXPDD
 G KILL
 ;
3 ; CONVERT PACKMAN MESSAGES
 N I,J,X,Y,Z,PATH
 D KILL,PATH I PATH'="" D 3^VFDXPDF
 G KILL
 ;
4 ; CREATE/EDIT A PROCESSING BATCH
 N I,J,X,Y,Z,PID
 D KILL,PID(1,1,1) I PID>0 D 4^VFDXPDD
 G KILL
 ;
5 ; VFDXPD XINDEX CAPTURE
 D ^VFDINDEX
 Q
 ;
6 ; VFDXPD PRE/POST REPORT
 N I,J,X,Y,Z,BATCH,PID,RPT
 D PID(0,1,0) I PID>0 D BATCH(PID) I $D(BATCH) D 6^VFDXPDE
 Q
 ;
7 ; VFDXPD BUILDS IN BATCH REPORT
 N I,J,X,Y,Z,BATCH,PID,RPT,SCR S SCR=$$SCR Q:SCR=-1
 D PID(0,SCR,0) I PID>0 D BATCH(PID) I $D(BATCH) D 7^VFDXPDE
 Q
 ;
8 ; VFDXPD LOAD BUILDS
 N I,J,X,Y,Z,PATH,PID,RPT
 D KILL,PID(0,1,0) I PID>0 D PATH I PATH'="" D 8^VFDXPDL,KILL
 Q
 ;
9 ; VFDXPD INSTALL ORDER REPORT
 N I,J,X,Y,Z,BATCH,PID,VFDIORPT
 D KILL,PID(0,1,0) I PID>0 D 9^VFDXPDG2,KILL
 Q
 ;
10 ; VFDXPD DELETE ROUTINES
 N I,J,X,Y,Z,BATCH,PID
 D PID(0,1,0) I PID>0 D BATCH(PID) I $D(BATCH) D DEL^VFDXPDH
 Q
 ;
11 ; VFDXPD RETRIEVE REPORT
 N I,J,X,Y,Z,BATCH,PID,RPT
 D PID(0,1,0) I PID>0 D BATCH(PID) I $D(BATCH) D 11^VFDXPDE
 Q
 ;
12 ; VFDXPD UNLOAD BUILDS
 G 12^VFDXPDJ
 ;
13 ; VFDXPD INSTALL BATCH
 N I,J,X,Y,Z,BATCH,PID
 D KILL,PID(0,1,0) I PID>0 D BATCH(PID) I $D(BATCH) D 13^VFDXPDY,KILL
 Q
 ;
14 ; LIST OF POST MANUAL PATCHES
 N BATCH,PID
 D KILL,PID(0,1,0) I PID>0 D POSTMAN^VFDXPDG2
 Q
15 ; LOAD REPORTS
 N PATH,PID
 D KILL,PID(0,1,0) I PID>0 D 15^VFDXPDL,KILL
 Q
 ;
16 ; ADD TO BATCH
 N PATH,PID
 D KILL,PID(0,1,1) I PID>0 D PATH I PATH'="" D 16^VFDXPDK,KILL
 Q
 ;
17 ; UPDATE VISTA STANDARDIZATION CHECKSUMS
 N PATH
 D KILL,PATH I PATH'="" D 17^VFDXPDCS,KILL
 Q
 ;
 ;=================================================================
 ;The options below need to be redone for the new structure and DSS
 ;programming standards
 ;
X7 ; COMPARE BATCH KIDS TO HFS FOLDER
 N I,J,X,Y,Z,BATCH,PATH,PID
 D KILL,PID(0,1,0),PATH:PID>0
 ;
 ; **** REPLACE 7^VFDVXPDF WITH 7^VFDXPD?
 I PID>0,$L(PATH) D BATCH(PID) I $D(BATCH) D 7^VFDVXPDF
 G KILL
 ;
H ; LIST & VALIDATE BUILDS TO INSTALL
 N I,J,X,Y,Z,PATH,PID
 ;
 ; **** REPLACE H^VFDVXPDH WITH H^VFDXPD?
 D KILL,PID(0,0,0),PATH:PID>0 I PID>0,$L(PATH) D H^VFDVXPDH
 G KILL
 ;
 ;=======================  PRIVATE SUBROUTINES  =======================
BATCH(PID) ;
 K BATCH N X S X=$$BATCH^VFDXPD0(.BATCH,PID)
 I X<1 K BATCH W !!,$P(X,U,2)
 Q
 ;
KILL K ^TMP("VFDXPD",$J)
 Q
 ;
PATH D PATH^VFDXPD0 S:'$D(PATH) PATH="" Q
 ;
PID(A,B,C) ;
 S PID=$$PID^VFDXPD0(A,B,C)
 I PID>0 S PID(0)=$P(PID,U,2),PID=+PID
 Q
 ;
SCR() ;SCREEN BATCHES?
 N DIR,X,Y
 S DIR("A")="Display only batches NOT currently installed"
 S DIR("?")="Enter ""YES"" to view batches marked as INSTALLED: NO. Otherwise, to view all batches enter ""NO""."
 S DIR(0)="Y",DIR("B")="YES"
 Q $$DIR^VFDXPDA(.DIR)
