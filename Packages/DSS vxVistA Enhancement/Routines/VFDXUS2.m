VFDXUS2 ;DSS/SGM - TO CHECK OR RETURN USER ATTRIBUTES ; 08/25/2011 13:27
 ;;2011.1.2;DSS,INC VXVISTA OPEN SOURCE;;28 Jan 2013;Build 86
 ;Copyright 1995-2013,Document Storage Systems Inc. All Rights Reserved
 ;
XUS2 ;SF/RWF - TO CHECK OR RETURN USER ATTRIBUTES ;05/15/2006
 ;;8.0;KERNEL;**59,180,313,419**;Jul 10, 1995;Build 5
 Q
 ;
ACCED    ; ACCESS CODE EDIT from DD
 I "Nn"[$E(X,1) S X="" Q
 I "Yy"'[$E(X,1) K X Q
 N DIR,DIR0,XUAUTO,XUK
 S XUAUTO=($P($G(^XTV(8989.3,1,3)),U,1)="y"),XUH=""
AC1 ;
 D CLR,AAUTO:XUAUTO,AASK:'XUAUTO G OUT:$D(DIRUT)
 D REASK G OUT:$D(DIRUT),AC1:'XUK D CLR,AST(XUH)
 G OUT
 ;
BRCVC(XV1,XV2) ;Broker change VC, return 0 if good, '1^msg' if bad.
 N XUU,XUH
 Q:$G(DUZ)'>0 "1^Bad DUZ" S DA=DUZ,XUH=$$CONVERT(XV2,,1)
 I $P($G(^VA(200,DUZ,.1)),"^",2)'=$$CONVERT(XV1,,1) Q "1^"_$$T(1)
 S Y=$$VCHK(3,XV2,XUH)
 I +Y Q:Y'[$C(34) Y N A,Z S Z=$P(Y,U,2,9) S @("A="_Z) Q (+Y)_U_A
 D VST(XUH,0),CALL^XUSERP(DA,2)
 Q 0
 ;
CVC ;From XUS1
 N DA,X S DA=DUZ,X="Y" W !,$$T(2)
 ;Fall into next code
VERED ; VERIFY CODE EDIT From DD
 N DIR,DIR0,XUAUTO
 I "Nn"[$E(X,1) S X="" Q
 I "Yy"'[$E(X,1) K X Q
 N VFD S VFD="V" ;LM: Added here
 S XUH="",XUAUTO=($P($G(^XTV(8989.3,1,3)),U,3)="y")
 S:DUZ=DA XUAUTO="n" ;Auto only for admin
VC1 ;
 D CLR,VASK:'XUAUTO,VAUTO:XUAUTO G OUT:$D(DIRUT)
 D REASK G OUT:$D(DIRUT),VC1:'XUK D CLR,VST(.XUH,1)
 D CALL^XUSERP(DA,2)
 G OUT
 ;
 ;--------------------  PRIVATE SUBROUTINES  --------------------
AASK ;Ask for Access code
 N X,XUU,XUEX X ^%ZOSF("EOFF") S XUEX=0
 F  D AASK1 Q:XUEX!($D(DIRUT))  W !
 Q
 ;
AASK1 ;
 N I,Z,VFDTXT
 W $$T(9) D GET Q:$D(DIRUT)
 I X="@" D DEL D:Y'=1 DIRUT S XUH="",XUEX=1 Q
 S Z=$$VCHK(12,X)
 S XUU=X,X=$$CONVERT(X,,1),XUH=X
 I +Z=0 S XUEX=1 Q  ; good AC
 ; if +Z>0 then unacceptable code enter, z = ##^text
 ; send mail bulletin only if active AC is someone else's
 D CLR,SENDBULL:+Z=3
 ;D AHELP
 S Z=$P(Z,U,2,9) W $C(7) W:Z'[$C(34) Z W:Z[$C(34) @Z
 Q
 ;
AAUTO D AAUTO^XUS2 Q
 ;
AGEN D AGEN^XUS2 Q
 ;
AHELP D AHELP^XUS2 Q
 ;
AST(XUH) ;Change ACCESS CODE and index.
 D AST^XUS2(XUH) Q
 ;
AVHLPTXT(%) ;
 Q "Enter "_$S($G(%):"6-20",1:"8-20")_" characters mixed alphanumeric and punctuation (except '^', ';', ':')."
 ;
CLR N Z D CLR^XUS2 Q
 ;
CHKCUR() ;Check user knows current code, Return 1 if OK to continue
 Q:DA'=DUZ 1 ;Only ask user
 Q:$P($G(^VA(200,DA,.1)),U,2)="" 1 ;Must have an old one
 S XUK=0 D CLR
CHK1 ;
 N VFD S VFD="V"
 W $$T(3) D GET Q:$D(DIRUT) 0
 I $P(^VA(200,DA,.1),U,2)=$$CONVERT(X,,1) Q 1
 D CLR W $$T(4),!
 S XUK=XUK+1 G:XUK<3 CHK1
 Q 0
 ;
DEL D DEL^XUS2 Q
 ;
DIRUT S DIRUT=1 Q
 ;
GET ;Get the user input and convert case
 ; param - VFD CASE-SENSITIVE VERIFY CODE
 S X=$$ACCEPT^XUS I (X["^")!('$L(X)) D DIRUT
 I $S($G(VFD)'="V":1,1:$$GETXPAR^VFDXUS2A(,,,1)=0) S X=$$CONVERT(X,1)
 Q
 ;
NEWCODE D REASK I XUK W !,$$T(5)
 G OUT
 ;
OUT G OUT^XUS2
 ;
REASK ;
 N Z S XUK=1 Q:XUH=""  D CLR X ^%ZOSF("EOFF")
 F XUK=3:-1:1 W $$T(6) D GET G:$D(DIRUT) DIRUT D ^XUSHSH Q:(XUH=X)  D CLR W $$T(7),!,$C(7)
 S:XUH'=X XUK=0
 Q
 ;
T(T) ;
 ;;Sorry that isn't the correct current code
 ;;You must change your VERIFY CODE at this time.
 ;;Please enter your CURRENT verify code: 
 ;;Sorry that is not correct!
 ;;OK, remember this code for next time!
 ;;Please re-type the new code to show that I have it right: 
 ;;This doesn't match. Try again!
 ;;Enter a new VERIFY CODE: 
 ;;Enter a new ACCESS CODE <Hidden>: 
 Q $P($T(T+T),";",3)
 ;
VASK ;Ask for Verify Code
 N X,XUU X ^%ZOSF("EOFF") G:'$$CHKCUR() DIRUT D CLR
VASK1 ;
 W $$T(8) D GET Q:$D(DIRUT)
 I '$D(XUNC),(X="@") D DEL G:Y'=1 DIRUT S XUH="" Q
 D CLR S XUU=X,X=$$CONVERT(X,,1),XUH=X,Y=$$VCHK(3,XUU,XUH)
 I 'Y S XUH(216)=$$CONVERT(XUU,1,1) Q
 S Z=$P(Y,U,2,9) W $C(7) W:Z'[$C(34) Z W:Z[$C(34) @Z W !
 ;D:+Y=1 VHELP
 G VASK1
 Q
 ;
VAUTO ;Auto-get Access codes
 N XUK
 X ^%ZOSF("EON") F XUK=1:1:3 D VGEN Q:(Y=1)!($D(DIRUT))
 Q
 ;
VCHK(N,S,EC) ;
 ; N - req
 ; N=1 - pattern match access code
 ; N=2 - check access code for uniqueness
 ; N=3 - pattern match verify code and check for prior use
 ; S - req - unencrypted code string
 ; EC - opt - hashed a/v code string
 ; Parameter VFD VERIFY CODE PATTERN determines the
 ; rule that applies.  Default is CCHIT.
 ; 
 N VFDVCP S VFDVCP=$$GETXPAR^VFDXUS2A(,,,2)
 I "cf"[VFDVCP Q $$CKAV^VFDXUS2A(N,$G(S),$G(EC),VFDVCP)
 I "o"=VFDVCP,$D(^VFD(21614.1)) N VFDAVOK D  Q $G(VFDAVOK)
 .D X^VFDXTX("AV CHECK PATTERN OR UNIQUENESS")
 .Q
 Q 0
 ;
VGEN D VGEN^XUS2 Q
 ;
VHELP D VHELP^XUS2 Q
 ;
VST(XUH,%) ;
 ;as of 8/16/2007 VST^XUS2 did not NEW DIERR
 N X,DIERR
 D VST^XUS2(XUH,%)
 ;I '$D(DIERR) S X=$G(XUH(216)) S:X'="" $P(^VA(200,DA,.1),U,20)=X
 K XUH(216)
 Q
 ;
YN D YN^XUS2 Q
 ;
CONVERT(T,UP,HASH) Q $$CONVERT^VFDXUS2A(T,$G(UP),$G(HASH))
 ;
SENDBULL ; send bulletin that someone tried to assign another's AC
 N X,Y,Z,XMB,XMDUN
 S X=$O(^VA(200,"A",XUH,0)) Q:'X!(X=DA)
 S XMB="XUS ACCESS CODE VIOLATION"
 S XMB(1)=$P(^VA(200,X,0),U),XMDUN="Security" D ^XMB
 Q
