VFDXPDP0 ;DSS/SGM - UTILITIES FOR PATCH PROGRAM
 ;;3.1;DSS,INC VXVISTA SUPPORTED;;10 Dec 2012;Build 58
 ;Copyright 1995-2012,Document Storage Systems Inc. All Rights Reserved
 ;
 ;This routine is only invoked via the VFDXPDP routine.
 ;
 ;ICR#  Supported Reference
 ;----  -------------------
 ;      ^DIC
 ;      ^DIE
 ;      ^DIR
 ;
ASK(TAG) ; general prompter
 ; return -2:timeout  -3:'^'-out  -4:'^^"-out  else value from DIR
 ; TAG - req - line tag for specific prompting
 ;          1 - ask if to refile data to 21692
 ;       PATH - ask for path where HFS files reside
 Q:$G(TAG)="" -1 Q:$T(@$P(TAG,"("))="" -1
 N I,X,Y,Z,EDIT,RET,SCR
 I TAG["PID" Q @("$$"_TAG)
 D @TAG
 Q $$DIR(.Z)
 ;
GKILL(N) ; kill ^TMP nodes
 K ^TMP($J) I $G(N)'="" K ^TMP(N,$J)
 Q
 ;
 ;============================ DIC SELECTOR ===========================
DIC(DIC,DLAYGO,VFDIC,DA) ;
 ; VFDIC - opt - $NA() of return array where @VFDIC@(+Y)=$P(Y,U,2)
 ;   if $G(VFDIC)="" then extrinsic function returns ien^name or -1
 N I,J,X,Y,Z,DTOUT,DUOUT
 I '$D(VFDIC) W ! D ^DIC Q $S($D(DTOUT):-2,$D(DUOUT):-3,1:Y)
 F  W ! D ^DIC Q:Y'>0!$D(DTOUT)!$D(DUOUT)  S @VFDIC@(+Y)=Y
 Q
 ;
 ;============================== DIE EDIT =============================
DIE(DIE,DA,DR) ;
 N I,J,X,Y,Z,DTOUT,DUOUT W ! D ^DIE
 Q $D(Y)=0
 ;
 ;============================ DIR PROMPTER ===========================
DIR(DIR) ;
 ; return -2:timeout  -3:'^'-out  -4:'^^"-out  else value from DIR
 N I,J,X,Y,Z,DIROUT,DIRUT,DTOUT,DUOUT
 W ! D ^DIR
 Q $S($D(DTOUT):-2,$D(DIROUT):-4,$D(DUOUT):-3,1:Y)
 ;
 ;=====================================================================
 ;                        MODULES FOR PROMPTING
 ;=====================================================================
 ; line tag is input parameter for line tag ASK
 ; sets up Z() which is equivalent to DIR()
 ;
1 ; ask if to refile the data to 21692
 ;;If you answer YES then if an entry exists in file 21692 then any
 ;;data found in these HFS files will overwrite the data in file 21692.
 ;;
 ;;If you answer NO then if an entry exists in file 21692 then any data
 ;;found in these HFS files will overwrite data in file 21692 only if
 ;;that field in 21692 has no data.
 ;;
 ;;In either case, the BUILDs found in the HFS files will  be added to
 N I,X,Y K Z
 S Z(0)="YA",Z("B")="NO",Z("?")="   "
 S Z("A")="Always update existing entries in file 21692? "
 F I=1:1:8 S Z("?",I)=$TR($T(1+I),";"," ")
 D WR("?",1)
 Q
 ;
PATH ; ask for path for HFS file
 ; Return path or null or -2,-3,-4
 ;;Enter the full path name where the HFS files reside to be processed
 N I,X,Y
 S Z(0)="FO^3:150"
 S Z("A")="   Enter path name",Z("B")=$$PATH^VFDXPDP1
 S Z("?")=$P($T(PATH+2),";",3),Z("PRE")="D PATHSCR^VFDXPDP0"
 Q
 ;
PID(EDIT,SCR) ;
 ; EDIT - opt - Boolean, default 0, if 1 edit processing group date
 ;  SCR - opt - Boolean, default 1, if 1 screen lookup
 ; Return <file 21692.1 ien>^<batch name> or -1
 N I,J,X,Y K Z
 S EDIT=+$G(EDIT),SCR=$S($D(SCR):+SCR,1:1)
 S Z=21692.1,Z(0)="QAEML" I SCR S Z("S")="I '$P(^(0),U,3)"
 S Y=$$DIC(.Z,21692.1),RET=$P(Y,U,1,2)
 I Y>0,'$P(Y,U,3),EDIT D DIE(21692.1,+Y,.02)
 Q RET
 ;
 ;-----------------------  PRIVATE SUBROUTINES  -----------------------
PATHSCR ; DIR prescreen of path input
 I X["?"!(X[U) K X Q
 I X?1P.E,$E(X)'="\" K X Q
 S X=$$PATH^VFDXPDP1(X) K:X="" X
 Q
 ;
WR(N,CLEAR) ; write out text to the screen
 ;; N - req - "?" or "A"
 ;;CLEAR - opt - Boolean, if true clear screen
 Q:$G(N)=""  Q:'$D(Z(N))
 W:$G(CLEAR) @IOF W:'$G(CLEAR) !
 N I S I=0 F  S I=$O(Z(N,I)) Q:'I  W !,Z(N,I)
 Q
