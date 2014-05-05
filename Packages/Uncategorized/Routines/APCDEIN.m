APCDEIN ; IHS/CMI/TUCSON - INITIALIZE VARS ;
 ;;2.0;IHS RPMS/PCC Data Entry;;MAR 09, 1999
 ;
 ;
EN ;PEP - set up PCC Data Entry environment vars
 I DUZ("AG")="I" K APCDDUZ S:$D(DUZ(0))#2 APCDDUZ=DUZ(0) S DUZ(0)="@"
 I $G(DUZ("AG"))="" W !,$C(7),$C(7),"DUZ(""AG"") not defined..Use Kernel or Fix Kernel Site Parameters File!!" S APCDFLG=1 Q
 S AUPNLK("INAC")="" ;per Diana 11-17-92 include inactive pats in lookups
SITE ;
 S APCDEIN=""
 I $E(DUZ("AG"))="I" S:$D(DUZ(2))#2 APCDDUZ2=DUZ(2)
 K ^TMP("APCD",$J)
 K AUPNTALK
PARAM ;
 I '$D(APCDPARM) D ^APCDVAR
 S APCDBEEP=$C(7)_$C(7),APCDFLG=0,APCDMODE="A",APCDOVRR=1,AICDHLIM=20,XTLKHLIM=20
 S X="",APCDFILE="9000010",APCDFLD=".01" S:$D(^DD(APCDFILE,APCDFLD,0)) X=^(0)
 I X=""!(X]""&($P(X,U,2)'["D")) D DICERR G XIT
 S X=$P(X,U,5,99) S:X[" X D:" X=$E(X,1,$F(X," X D:")-3) S ^TMP("APCD",$J,"APCDDATE")=X
 ;
XIT ; KILL VARIABLES AND QUIT
 ;
 K %DT,X,Y,DIC,DIRUT,DIR
 K APCDFILE,APCDFLD,APCDI,APCDN,APCDSTR,APCDY
 Q
DICERR ; DICTIONARY OUT OF SYNC WITH PROGRAM
 W !!,"Dictionary error for file,field ",APCDFILE,",",APCDFLD,". Notify programmer."
 S APCDFLG=1
 Q
 ;
