XPDKRN ;SFISC/RSD - Kernel Install program ;07/02/2003  12:59
 ;;3.1;DSS,INC VXVISTA SUPPORTED;;10 Dec 2012;Build 58
 ;Copyright 1995-2012,Document Storage Systems Inc. All Rights Reserved
 ;
EN ;
 N X,Y,VFDTITLE
 Q:'$$TITLE
 F  Q:Y<0
 .W @IOF,!,VFDTITLE,!
 .N DIC S DIC="^DOPT(""VFDXPD"",",DIC(0)="AEQZ"
 .D ^DIC I Y>0 S X=$P(Y(0),U,2,99) D @X
 .Q
 Q
 ;
SETUP ;
 N I,X
 K ^DOPT("VFDXPD")
 F I=1:1 S X=$E($T(OPT+I),4,99) Q:X=""  D
 .S ^DOPT("VFDXPD",I,0)=X
 .S ^DOPT("VFDXPD","B",$$UP^XLFSTR(X),I)=""
 .Q
 S I=I-1
 S ^DOPT("VFDXPD",0)="VFD PATCH MANAGEMENT^1N^"_I_U_I
 Q
 ;
TITLE() ;
 ;;You must be properly signed on as an active user!!
 ;;VFD PATCH UTILITY MENU 
 I $G(DUZ)<1 W !!,$TR($T(TITLE+1),";"," "),!! Q 0
 D HOME^%ZIS,DT^DICRW:'$G(DT)
 I $O(^DOPT("VFDXPD","B"),-1)'=5 D SETUP
 S VFDTITLE=$$CJ^XLFSTR($E($T(TITLE+2),4,99)_$P(V,";",3),80)
 Q 1
 ;
OPT ;
 ;;Add KIDS HFS Files to a Processing Batch^1^VFDXPD
 ;;Capture Routine Size/Invoked By from XINDEX^5^VFDXPD
 ;;Convert Packman Messages to Installable KIDS^3^VFDXPD
 ;;Create/Edit a Batch Processing Group^4^VFDXPD
 ;;Edit Data Associated With a Build^2^VFDXPD
