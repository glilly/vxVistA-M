VFDCXPR3 ;DSS/SGM - NON-GUI INTERACTIVE PARAMETER EDIT ;01/09/2005 07:59
 ;;2011.1.3;DSS,INC VXVISTA OPEN SOURCE;**16**;11 Jun 2013;Build 1
 ;Copyright 1995-2013,Document Storage Systems Inc. All Rights Reserved
 ;
 ;This is only called from VFDCXPR routine
 ;This routine encapsulates the Parameter terminal interactive tools for
 ;editing Kernel Parameters.
 ;
 ;DBIA#  Supported Reference
 ;-----  ---------------------------------------------------------------
 ; 2051  ^DIC: $$FIND1
 ; 2263  ^XPAREDIT: EDITPAR
 ; 3127  FM read access to all of file 8989.51 [controlled subscription]
 ;
 Q
 ;
EDIT ; interactive prompt to select parameter then edit 8989.5
 ; P - opt - namespace of parameter to used as a screen
 N X,Y,Z,CNT,VFDCPAR
 Q:'$D(P)  I $D(P)=1,P="" Q
 S CNT=0
 I $G(P)'="" S VFDCPAR(P)="",CNT=1+CNT
 S Y="" F  S Y=$O(P(Y)) Q:Y=""  S VFDCPAR(Y)="",CNT=1+CNT
 F  S X=$$DIC Q:X<1  D  Q:CNT<1
 .S VFDCPAR=$P(X,U,2)
 .F  D  Q:X<1
 ..W @IOF,!!,"Editing Parameter "_VFDCPAR,!
 ..D EDITPAR^XPAREDIT(VFDCPAR)
 ..S X=$$DIR
 ..Q
 .Q
 Q
 ;
 ;---------------  subroutines  ---------------
DIC(P) ; interactive DIC lookup to select a Parameter Definition
 ; P - req
 ; This can be the name or namespace of parameter to be used as a screen
 ; This can be an array of names (or namespaces) to be used as screen
 N X,Y,Z,DIERR,VFDERR
 I CNT=1 D  I $D(Z) Q Z
 .S X=$O(VFDCPAR(0))
 .S Y=$$FIND1^DIC(8989.51,,"QX",X,"B",,"VFDERR")
 .K Z Q:$D(DIERR)  S:Y>0 Z=+Y_U_^XTV(8989.51,+Y,0),CNT=0
 .Q
 S Z=8989.51,Z(0)="QAEMZ",Z("S")="D DICS^VFDCXPR3"
 S X=$$DIC^VFDCFM01(.Z),Y=+Z S:Y>0 Y=Y_U_Z(0)
 Q Y
 ;
DICS ; called from DIC("S")
 N A S A="" I 0
 F  S A=$O(VFDCPAR(A)) Q:A=""  I $E($P(^(0),U),1,$L(A))=A Q
 Q
 ;
DIR() ; continue?
 N X,Y,Z
 S Z("A")="Continue editing more entries for "_VFDCPAR_"? "
 S Z(0)="YOA"
 Q +$$DIR^VFDCFM01(.Z)
 ;
ERR(A) ;
 I A=1 S X=$$MSG^VFDCFM("VE",,,,"VFDERR")
 I A=2 S X="Lookup value not found: "_VFD
 I A=3 S X="No entry names found starting with "_VFD
 I A=4 S X="Problem with record # "_VFDEN
 I A=5 S X="No data found"
 S Y=1+$O(VFDCL("A"),-1) S:Y=1 X="-1^"_X
 S VFDCL(Y)=X
 Q
 ;
SETL(X) S Y=1+$O(VFDCL("A"),-1),VFDCL(Y)=X Q
 ;
ADDWP ;  add a new entity/parameter/instance
 ; for a word-processing type parameter
 ; INSTANCE is optional
 N I,X,Y,Z,ARR,VFDERR
 N ENT,PAR,ERR,INST,WPA
 S (ERR,VFDERR,RET)=""
 I DATA']"" S RET="-1^No Data String defined" Q
 S ENT=$S($P(DATA,"~",1)'="":$P(DATA,"~",1),1:"SYS")
 S PAR=$P(DATA,"~",2) I PAR="" S RET="-1^No parameter defined in Data string" Q
 S INST=$P(DATA,"~",3),INST=$G(INST,1)
 D INTERN^XPAR1 I ERR S RET="-1^Parameter not defined" Q
 D ADD^XPAR(ENT,PAR,INST,.VFDCLT,.WPA) I +WPA S RET="-1^"_$P(WPA,U,2) Q
 S RET="1^Parameter added successfully"
 Q
 ;
