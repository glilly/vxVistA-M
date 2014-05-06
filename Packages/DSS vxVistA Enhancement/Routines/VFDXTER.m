VFDXTER ;DSS/PDW - REPORT ERRORS - ; 8/10/09 12:30PM
 ;;2009.2;DSS,INC VXVISTA OPEN SOURCE;;01 Dec 2009
 ;Copyright 1995-2009,Document Storage Systems Inc. All Rights Reserved
 ;CONSILIDATED ERROR REPORTER
 ;ICR#  Supported Description
 ;----  ---------------------------------------------------------------
 ;      %ZIS
 ;      %ZISC
 ;      %ZTLOAD
 ;      DIQ     $$GET1
 ;      DIR
 ;      VALM1 $$SETSTR
 ;      XLFDT $$FMTE,$$NOW,$$HTFM
 ;      ----------  FILE ACCESSES  ----------
 ;      Direct global read of  ^%ZTER( Error Log file
EN ;
PRT ; print report to a device
 D DATEQUES(.ANS) ;gather dates FM & $H ;ANS("DTB")=DTB
 F X="DTB","DTBH","DTE","DTEH" S @X=ANS(X)
 I $G(DTBH),$G(DTEH) I 1 ; dates supplied
 E  Q
 K DIR
 D ^%ZIS Q:POP
 D ENIO
 D ^%ZISC
 Q
TASK ;task a report
 K DIR S DIR(0)="DO^NOW::AEFT",DIR("A")="Enter time for the error report to run "
 D ^DIR
 Q:Y'>0
 S PARAM("QUETIME")=Y
 D DATEQUES(.ANS) ;gather dates 
 F X="DTB=1","DTBH=2","DTE=3","DTEH=4" S @X=$G(ANS(X))
 I $G(DTBH),$G(DTEH) I 1 ; dates supplied
 E  Q
 M PARAM("DTRANGE")=ANS
 D OUTPUT(.OUTPUT) ; ask out put type hfs, MAIL, EMAIL
 I OUTPUT="" Q
 S PARAM("OUTPUT")=OUTPUT
 S ZTRTN="DEQUE^VFDZSYZE",ZTDESC="XTER SUMMARY REPORT"
 S ZTSAVE("PARAM")="" D ^%ZTLOAD
 Q
ENIO U IO
 N EN,ERN,TAG,FMDT,FMDTE,%H,EZ,T,DTC,SITE,DOM,ARR,LNC
 N ZECNT,TAGCNT,RTN,NOTE,HD,HL
 ;build ^TMP from ^%ZTER(1,$H,EN,"ZE")=<ZE>tag note
 ;TMP("ZTER",$J,FMDT)=CNT, ^(..FMDT,ZE)=CNT, ^(...ZE,TAG)=CNT
PQ K ARR,@G
 S DTH=DTBH F  S DTH=$O(^%ZTER(1,DTH)) Q:DTH>DTEH  Q:DTH'>0  D
 . S FMDT=$$HTFM^XLFDT(DTH),FMDTE=$$FMTE^XLFDT(X,2)
 . S EN=0 F  S EN=$O(^%ZTER(1,DTH,1,EN)) Q:EN'>0  D
 .. S ERN=^%ZTER(1,DTH,1,EN,"ZE"),ZE=$P(ERN,">"),ZE=$P(ZE,"<",2),DOC=$P(ERN,">",2)
 .. Q:ERN=""
 .. S TR=$P(DOC," "),NOTE=$P(DOC," ",2),TAG=$P(TR,U),ROU=$P(TR,U,2) S:TAG="" TAG=" "
 .. S:'$L(ZE) ZE=$P(ERN,":") S:'$L(DOC) (ROU,TAG,NOTE)="~" S:NOTE="" NOTE="~"
 .. S CNT=+$G(@G@(FMDT,0)),@G@(FMDT,0)=CNT+1
 .. S CNT=+$G(@G@(FMDT,ZE,0)),@G@(FMDT,ZE,0)=CNT+1
 .. S CNT=+$G(@G@(FMDT,ZE,ROU,0)),@G@(FMDT,ZE,ROU,0)=CNT+1
 .. S CNT=+$G(@G@(FMDT,ZE,ROU,TAG,0)),@G@(FMDT,ZE,ROU,TAG,0)=CNT+1
 .. S CNT=+$G(@G@(FMDT,ZE,ROU,TAG,NOTE,0)),@G@(FMDT,ZE,ROU,TAG,NOTE,0)=CNT+1
 .. S @G@(FMDT,ZE,ROU,TAG,NOTE)=ERN
 ;build result array
 S DOM=$$GET1^DIQ(4.3,"1,",.01),SITE=^DD("SITE")
 S NOW=$$FMTE^XLFDT($$NOW^XLFDT,2)
 S X="",X=$$STR(SITE,X,0),X=$$STR(DOM,X,32),X=$$STR($P(NOW,":",1,2),X,60)
 S ARR(1)=$E(X,1,80)
 S X="                    INDIVIDUAL ERROR REPORT" D TXT(X)
 S (X,HT)="  Date    # Errors  Description with Tip" D TXT(X)
 S (HD,X)="========  ========  ========================================================="
 U IO
 S DTFM=0 F  S DTFM=$O(@G@(DTFM)) Q:DTFM'>0  D ZTERDT
 D TXT(HD)
 D SUMMARY
 S LN=0 F  S LN=$O(ARR(LN)) Q:LN'>0  W !,ARR(LN)
 Q
ZTERDT ;
 D TXT(HD)
 S X=$$FMTE^XLFDT(DTFM,2) ;set date stamp
 S ZE="" F  S ZE=$O(@G@(DTFM,ZE)) Q:ZE=""  D ZTEROU
 Q
ZTEROU ;document ZE w count
 ;D TXT(HL1)
 S ROU=0 F  S ROU=$O(@G@(DTFM,ZE,ROU)) Q:ROU=""  D ZTETAG
 Q
ZTETAG ;
 S TAG=0 F  S TAG=$O(@G@(DTFM,ZE,ROU,TAG)) Q:TAG=""  D ZTERNOTE
 Q
ZTERNOTE ;
 S NOTE=0 F  S NOTE=$O(@G@(DTFM,ZE,ROU,TAG,NOTE)) Q:NOTE=""  D
 . S CNT=$J(@G@(DTFM,ZE,ROU,TAG,NOTE,0),8)
 . S X=$$STR(CNT,X,11)_"  "_@G@(DTFM,ZE,ROU,TAG,NOTE)
 . D TXT(X) S X="" ; only 1st line has a date 
 Q
ZTERTAG ;document TAG w count
 S TAGCNT=@G@(DTFM,ZE,TAG),X=$$STR(TAGCNT,X,26),X=$$STR(TAG,X,35)
 D TXT(X)  S X="" ;only 1st line of list has ZE w ZECNT
 Q
SUMMARY ;
 S X=" " D TXT(X)
 S X="                    SUMMARY REPORT " D TXT(X)
 S (X,HT)="  Date    # Errors  Description       Routine" D TXT(X)
 S HD="========  ========  ================  ======================================="
 K HL
 S $P(HL,"-",40)="",X="",HL=$$STR(HL,X,40)
 S DTFM=0 F  S DTFM=$O(@G@(DTFM)) Q:DTFM'>0  D ZTERDTS
 D TXT(HD)
 Q
ZTERDTS ;
 D TXT(HD)
 S X=$$FMTE^XLFDT(DTFM,2) ;set date stamp
 S ZE=0 F  S ZE=$O(@G@(DTFM,ZE)) Q:ZE=""  D
 . S CNT=$J(@G@(DTFM,ZE,0),8),X=$$STR(CNT,X,11),X=$$STR(ZE,X,21)
 . D ZTEROUS
 Q
ZTEROUS ;document ZE w count
 ;D TXT(HL1)
 S ROU=0 F  S ROU=$O(@G@(DTFM,ZE,ROU)) Q:ROU=""  D
 . S CNT=$J(@G@(DTFM,ZE,ROU,0),8),X=$$STR(CNT,X,11),X=$$STR(ROU,X,39)
 . D TXT(X)
 . ;I $O(@G@(DTFM,ZE,ROU))="",$O(@G@(DTFM,ZE))'="" D TXT(HL)
 . S X=""
 Q
REF ;
 S STR="" S STR=$$SETSTR^VALM1(X,STR,COL,$L(X))
 W $$HTFM^XLFDT($H) ;3090729.092234
 ;
STR(X,STR,COL) S X=$$SETSTR^VALM1(X,STR,COL,$L(X))
 Q X
TXT(X) N LN S LN=+$O(ARR("A"),-1)+1,ARR(LN)=X Q
 Q
DATEQUES(ANS) ; ask dates , return in DTB,DTBH,DTE,DTEH subscripts of ANS
 N DTB,DTBH,DTE,DTEH,X
 S ANS=""
DT1 ;
 K DIR S DIR(0)="DO^:NOW^",DIR("A")="Enter START date",DIR("B")=$$FMTE^XLFDT(DT) D ^DIR Q:Y'>0  S DTB=+Y
DT2 ;
 K DIR S DIR(0)="DO^"_DTB_":NOW",DIR("A")="Enter END date",DIR("B")=$$FMTE^XLFDT(DT)
 D ^DIR G:Y'>0 DT1
 S DTE=+Y,G=$NA(^TMP("ZTER",$J)) K @G
 I DTE<DTB W !,"START ",$$FMTE^XLFDT(DTB)," CAN NOT BE AFTER END DATE ",$$FMTE^XLFDT(DTE),! G DT2
 S DTBH=$$FMTH^XLFDT(DTB,1)-.1,DTEH=$$FMTH^XLFDT(DTE)+.1
 W !,?5,"Start:",?15,$$FMTE^XLFDT(DTB),!,?5,"Stop:",?15,$$FMTE^XLFDT(DTE)
 K DIR S DIR(0)="YO",DIR("A")="Is the above correct",DIR("B")="Y" D ^DIR
 I Y'>0 G DT1
 F X="DTB","DTBH","DTE","DTEH" S ANS(X)=@X
 Q
OUTPUT(OUTPUT) ; ask output type and paramater
OUTCNT S OUTPUT=""
 K DIR S DIR(0)="SO^P:Printer;H:Host File;M:MailMan:E:EMail" D ^DIR
 Q:Y=""
 S OUTPUT=Y
 K DIR S DIR("A")="Enter needed parameters for "_$S(Y="P":"Printer",Y="H":"Host File",Y="M":"MailMan",Y="E":"EMail")
 S DIR(0)="FO^2:60" D ^DIR
 I Y="" Q
 S $P(OUTPUT,U,2)=Y
 W !,OUTPUT
 K DIR S DIR(0)="Y",DIR("A")="Is the above Correct ",DIR("B")="Y" D ^DIR
 I Y="N" G OUTCNT
 Q
GET(REC,DLM,XX) ; where XX = VAR_"="_I  ex: XX="PATNM=1"
 ; Set VAR = piece I of REC using delimiter DLM
 N Y,I S Y=$P(XX,"="),I=$P(XX,"=",2),@Y=$P(REC,DLM,I)
 Q
SET(REC,DLM,XX) ; where XX = VAR_U_I  ex: XX="1=PATNUM"
 ; Set VAR into piece I of REC using delimiter DLM
 N Y,I S I=$P(XX,"="),Y=$P(XX,"=",2)
 I Y'=+Y,Y'="" S $P(REC,DLM,I)=$G(@Y) I 1
 E  S $P(REC,DLM,I)=YOUT ;
 Q
