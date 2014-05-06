APCDPL ; IHS/CMI/TUCSON - PROBLEM LIST UPDATE ; [ 09/02/02  9:47 PM ]
 ;;2.0;IHS RPMS/PCC Data Entry;**2,5**;MAR 09, 1999
 ;; ;
START ;
 W:$D(IOF) @IOF
 F J=1:1:5 S X=$P($T(TEXT+J),";;",2) W !?80-$L(X)\2,X
 K X,J
 W !!
 S APCDPLPT="" F  D GETPAT Q:APCDPLPT=""  S DFN=APCDPLPT D EN1,FULL^VALM1,EXIT K APCDPLPT
 D EOJ
 Q
GETPAT ;get patient
 K ^TMP($J,"APCDPL")
 K APCDPLPT,APCDLOC,APCDPAT,APCDDATE,APCDPIEN,APCDAF,APCDPRB,APCDOVRR,APCDLOOK,APCDPDFN
 D KILL^AUPNPAT
 S APCDPLPT=""
 W !
 S DIC="^AUPNPAT(",DIC(0)="AEMQ" D ^DIC K DIC
 Q:Y<0
 S APCDPLPT=+Y
 Q
GETLOC ;
 S APCDLOC="",DIC="^AUTTLOC(",DIC(0)="AEMQ",DIC("B")=$P(^DIC(4,$S($G(APCDLOC):APCDLOC,1:DUZ(2)),0),U),DIC("A")="Location where Problem List update occurred: " D ^DIC K DIC
 Q:Y<0
 S APCDLOC=+Y
 Q
GETDATE ;
 S APCDDATE=""
 W !!,"Date Problem List Updated: " R X:$S($D(DTIME):DTIME,1:300) S:'$T X=""
 Q:X=""!(X="^")
 S %DT="ET" D ^%DT G:Y<0 GETDATE
 I Y>DT W "  <Future dates not allowed>",$C(7),$C(7) K X G GETDATE
 S APCDDATE=Y
 Q
EOJ ;End of job cleanup
 D:$D(VALMWD) CLEAR^VALM1 ;clears out all list man stuff
 K ^TMP($J,"APCDPL")
 K XQORNEST,VALMKEY,VALM,VALMAR,VALMBCK,VALMBG,VALMCAP,VALMCNT,VALMOFF,VALMMCON,VALMDN,VALMEVL,VALMIOXY,VALMKEY,VALMLFT,VALMLST,VALMMENU,VALMSGR,VALMUP,VALMWD,VALMY,XQORS,XQORSPEW
 K APCDPLPT,APCDLOC,APCDPAT,APCDDATE,APCDPIEN,APCDAF,APCDPRB,APCDOVRR,APCDLOOK,APCDPDFN
 D KILL^AUPNPAT
 Q
EN1 ;PEP - requires DFN to be set to patient
 K ^TMP($J,"APCDPL")
 Q:'$G(DFN)
 S APCDPLPT=DFN
 Q:'$G(APCDPLPT)
 Q:'$D(^AUPNPAT(APCDPLPT))
 Q:'$D(^DPT(APCDPLPT))
 S Y=APCDPLPT D ^AUPNPAT
 D GETLOC
 I '$G(APCDLOC) D EXIT Q
 D GETDATE
 I '$G(APCDDATE) D EXIT Q
 S APCDOVRR=1
 D EN
 K APCDPLPT
 D FULL^VALM1
 D EXIT
 Q
EN2 ;PEP
 D GETPAT
 D EN
 D FULL^VALM1
 D EXIT
 Q
ENDE ;EP - for data entry PL call
 Q:'$G(DFN)
 S APCDPLPT=DFN
 Q:'$G(APCDPLPT)
 Q:'$D(^AUPNPAT(APCDPLPT))
 Q:'$D(^DPT(APCDPLPT))
 S Y=APCDPLPT D ^AUPNPAT
 S APCDLOC=APCDPLL
 I '$G(APCDLOC) D EXIT Q
 S APCDDATE=APCDPLD
 I '$G(APCDDATE) D EXIT Q
 S APCDOVRR=1
 D EN
 K APCDPLPT
 D FULL^VALM1
 D EXIT
 Q
EN ;PEP  main entry point for APCD PL PROBLEM LIST
 S VALMCC=1 ;1 means screen mode, 0 means scrolling mode
 D EN^VALM("APCD PL PROBLEM LIST")
 D CLEAR^VALM1
 Q
 ;
HDR ;EP -- header code
 S VALMHDR(1)=$TR($J(" ",80)," ","-")
 S VALMHDR(2)="Patient Name: "_IORVON_$P(^DPT(APCDPLPT,0),U)_IOINORM_"   DOB: "_$$FTIME^VALM1(AUPNDOB)_"   Sex: "_$P(^DPT(APCDPLPT,0),U,2)_"   HRN: "_$S($D(^AUPNPAT(APCDPLPT,41,DUZ(2),0)):$P(^AUPNPAT(APCDPLPT,41,DUZ(2),0),U,2),1:"????")
 S VALMHDR(3)=$TR($J(" ",80)," ","-")
 Q
 ;
INIT ; -- init variables and list array
 D GATHER ;gather up all problems
 S VALMCNT=APCDLINE ;this variable must be the total number of lines in list
 S APCDOVRR="" ;for provider narrative lookup
 Q
 ;
GATHER ;EP
 ;set up array containing list of problems
 ;**** see page 7 of List Manager Manual for info on how to
 ;**** set up the array that contains the list
 K ^TMP($J,"APCDPL")
 K APCDQUIT,APCDPL S APCDRCNT=0,APCDLINE=0
 I '$D(^AUPNPROB("AC",APCDPLPT)) S ^TMP($J,"APCDPL",1,0)="No Problems currently on file",^TMP($J,"APCDPL","IDX",1,1)="" S APCDRCNT=1 Q
 S APCDAF="A" D GATHER1 S APCDAF="I" D GATHER1
 Q
GATHER1 ;
 S APCDF=0 F  S APCDF=$O(^AUPNPROB("AA",APCDPLPT,APCDF)) Q:APCDF'=+APCDF  D
 .S APCDPRB="" F  S APCDPRB=$O(^AUPNPROB("AA",APCDPLPT,APCDF,APCDPRB)) Q:APCDPRB=""  S APCDPIEN=$O(^(APCDPRB,"")),APCDP0=^AUPNPROB(APCDPIEN,0) I $P(^AUPNPROB(APCDPIEN,0),U,12)=APCDAF D
 ..S APCDRCNT=APCDRCNT+1,APCDLINE=APCDLINE+1,^TMP($J,"APCDPL","IDX",APCDLINE,APCDRCNT)=APCDPIEN,APCDX=""
 ..S APCDX=$$SETSTR^VALM1($J(APCDRCNT,2),APCDX,3,2),APCDX=$$SETSTR^VALM1(") Problem ID:",APCDX,5,14),X=$S($P(^AUTTLOC(APCDF,0),U,7)]"":$J($P(^(0),U,7),4),1:"??")_$P(APCDP0,U,7),APCDX=$$SETSTR^VALM1(X,APCDX,19,8)
 ..S APCDX=$$SETSTR^VALM1("DX:",APCDX,28,3),APCDX=$$SETSTR^VALM1($P(^ICD9($P(APCDP0,U),0),U),APCDX,32,6),X="Status: "_IOUON_$$EXTSET^XBFUNC(9000011,.12,$P(APCDP0,U,12))_IOUOFF,APCDX=$$SETSTR^VALM1(X,APCDX,40,25)
 ..S APCDX=$$SETSTR^VALM1("Onset:",APCDX,64,6) I $P(APCDP0,U,13)]"" S APCDX=$$SETSTR^VALM1($$FMTE^XLFDT($P(APCDP0,U,13),"5D"),APCDX,71,17)
 ..S ^TMP($J,"APCDPL",APCDLINE,0)=APCDX,APCDX="",^TMP($J,"APCDPL","IDX",APCDLINE,APCDRCNT)=APCDPIEN
 ..S APCDLINE=APCDLINE+1,APCDX=$P($G(^AUTNPOV(+$P(APCDP0,U,5),0)),U),^TMP($J,"APCDPL",APCDLINE,0)="      Provider Narrative:  "_IOINHI_APCDX_IOINORM,^TMP($J,"APCDPL","IDX",APCDLINE,APCDRCNT)=APCDPIEN
 ..;S APCDLINE=APCDLINE+1,^TMP($J,"APCDPL",APCDLINE,0)=IOINORM_"  ",^TMP($J,"APCDPL","IDX",APCDLINE,APCDRCNT)=APCDPIEN
NOTE ..S APCDC=0 I $O(^AUPNPROB(APCDPIEN,11,0)) D
 ...S (APCDC,APCDL)=0 F  S APCDL=$O(^AUPNPROB(APCDPIEN,11,APCDL)) Q:APCDL'=+APCDL  I $O(^AUPNPROB(APCDPIEN,11,APCDL,11,0)) S APCDLR=$P(^AUTTLOC($P(^AUPNPROB(APCDPIEN,11,APCDL,0),U),0),U,7) D
 ....S APCDX=0 F  S APCDX=$O(^AUPNPROB(APCDPIEN,11,APCDL,11,APCDX)) Q:APCDX'=+APCDX  D
 .....S APCDC=APCDC+1 I APCDC=1 S X=IOINORM_"        "_IORVON_"Notes:"_IORVOFF S APCDLINE=APCDLINE+1,^TMP($J,"APCDPL",APCDLINE,0)=X,^TMP($J,"APCDPL","IDX",APCDLINE,APCDRCNT)=APCDPIEN
 .....S X="           "_APCDLR_" Note#"_$P(^AUPNPROB(APCDPIEN,11,APCDL,11,APCDX,0),U)_" "_$S($P(^(0),U,5)]"":$$FMTE^XLFDT($P(^(0),U,5),5),1:"        ")_"  "_$P(^AUPNPROB(APCDPIEN,11,APCDL,11,APCDX,0),U,3)
 .....S APCDLINE=APCDLINE+1,^TMP($J,"APCDPL",APCDLINE,0)=X,^TMP($J,"APCDPL","IDX",APCDLINE,APCDRCNT)=APCDPIEN
 ..S APCDLINE=APCDLINE+1,^TMP($J,"APCDPL",APCDLINE,0)=IOINORM_"  ",^TMP($J,"APCDPL","IDX",APCDLINE,APCDRCNT)=APCDPIEN
 ..Q
 .Q
 K APCDLR,APCDL,APCDX,APCDF
 Q
TEXT ;
 ;;Patient Care Component (PCC)
 ;;
 ;;***********************************
 ;;* Update PCC Patient Problem List *
 ;;***********************************
 ;;
 Q
HELP ; -- help code
 S X="?" D DISP^XQORM1 W !!
 Q
 ;
EXIT ; -- exit code
 K ^TMP($J,"APCDPL")
 K APCDRCNT,APCDPL,APCDLINE,APCDX,APCDP0,APCDC,APCDL,APCDLR,APCDPIEN,APCDAF,APCDPRB,APCDOVRR,APCDLOOK,APCDPDFN,APCDLOC,APCDDATE
 K X,Y
 K VALMHDR
 Q
 ;
EXPND ; -- expand code
 Q
 ;