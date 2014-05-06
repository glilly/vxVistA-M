VFDCDUZ1 ;DSS/SGM - COMMON NEW PERSON FILE RPCS ;23 Nov 2010 10:04
 ;;2011.1.2;DSS,INC VXVISTA OPEN SOURCE;;28 Jan 2013;Build 153
 ;Copyright 1995-2013,Document Storage Systems Inc. All Rights Reserved
 ;
 ;DO NOT INVOKE THIS ROUTINE DIRECTLY, SEE VFDCDUZ ROUTINE
 ;
ACT() ; Validate that DUZ is an active user
 N X,Y,Z,VFD,VFDX
 S X=$$CK($G(XDUZ)) I X<0 Q X
 S X=$$ACTIVE^XUSER(XDUZ) I X="" Q $$ERR(3)
 I X=0 Q $$ERR(4)
 I X="0^DISUSER" Q $$ERR(5)
 I +X=0 S Y=X Q $$ERR(6)
 S X=$$SCR
 Q $S(X'=1:X,1:XDUZ)
 ;
CK(XDUZ) ; basic check for valid DUZ
 I $G(XDUZ)="" Q $$ERR(1)
 I +XDUZ'=XDUZ Q $$ERR(2)
 I XDUZ<.5 Q $$ERR(2)
 I $G(^VA(200,XDUZ,0))="" Q $$ERR(3)
 Q 1
 ;
DIV() ; Return default division for user
 N A,I,X,Y,VFD,VFDCX
 S XDUZ=$G(XDUZ) S:XDUZ="" XDUZ=DUZ
 S X=$$DIV4^XUSER(.VFDCX,XDUZ)
 I 'X,'$G(SITE) Q $$ERR(8)
 I 'X Q $$SITE^VASITE
 S (A,I,X)=0
 F  S I=$O(VFDCX(I)) Q:'I  Q:VFDCX(I)  S A=A+1 S:VFDCX(I)="" X=I
 S Y=$S(I:I,A=1&X:X,1:0) I Y Q Y_U_$$NS^XUAF4(Y)
 I $G(SITE) Q $$SITE^VASITE
 Q $$ERR(9)
 ;
ID ; return a list of IDs
 N A,B,C,I,X,Y,Z,DIERR,VFD,VFDA,VFDER,VFDX,FLD,FLDS,IENS
 S FLDS="" S:$G(XDUZ)="" XDUZ=DUZ
 S X=$$CK^VFDCDUZ(XDUZ) I X<1 S VFDC=X Q
 S FLAGS=$G(FLAGS) S:FLAGS="" FLAGS="ADNSTVv"
 I FLAGS["A",FLAGS["a" S FLAGS=$TR(FLAGS,"a")
 ; map flags to field numbers
 F I=1:1:$L(FLAGS) S X=$E(FLAGS,I) D
 .Q:"AaDNSTVv"'[X  N FLD
 .I "Aa"[X S FLD=21600,FLAGS(FLD)="OAI"
 .I X="D" S FLD=53.2,FLAGS(FLD)="DEA"
 .I X="N" S FLD=41.99,FLAGS(FLD)="NPI"
 .I X="S" S FLD=9,FLAGS(FLD)="SSN"
 .I X="T" S FLD=53.92,FLAGS(FLD)="TAX"
 .I X="V" S FLD=9000,FLAGS(FLD)="VPID"
 .I X="v" S FLD=53.3,FLAGS(FLD)="VA"
 .; verify parent field exists in file 200
 .Q:'$D(FLD)  Q:$$VFIELD^VFDCFM(,200,FLD,1)<1
 .S FLDS=FLDS_FLD_$S(FLD=21600:"*",1:"")_";"
 .Q
 I FLDS="" S VFDC=$$ERR(15) Q
 S IENS=XDUZ_","
 D GETS^DIQ(200,IENS,FLDS,"N","VFD","VFDER")
 I $D(DIERR) S VFDC="-1^"_$$MSG^VFDCFM("VE",,,,"VFDER") Q
 S (A,B,C,I)=0
 F  S I=$O(VFD(200,IENS,I)) Q:'I  I $D(FLAGS(I)) D
 .S B=B+1,VFDX(B)=FLAGS(I)_U_$G(VFD(200,IENS,I))
 .Q
 I $D(FLAGS(21600)) S I=0 F  S I=$O(VFD(200.0216,I)) Q:I=""  D
 .K Z M Z=VFD(200.0216,I)
 .S X="OAI^",Y=$G(Z(.02)) Q:Y=""  S X=X_Y
 .S X=X_U_$G(Z(.01))_U_$G(Z(.04))
 .S A=A+1,VFDA(A)=X
 .S $P(C,U)=1+C I FLAGS["a",+$G(Z(.04)) S $P(C,U,2)=A
 .Q
 I FLAGS["a",A S Y=$P(C,U,2) D  I VFDC'="" Q
 .I Y S X=VFDA(Y) K VFDA S VFDA(1)=X Q
 .I A>1 S VFDC=$$ERR(17)
 .Q
 S Z=0 I B F I=1:1:B S Z=Z+1,VFDC(Z)=VFDX(I)
 I A F I=1:1:A S Z=Z+1,VFDC(Z)=VFDA(I)
 I '$D(VFDC) S VFDC(1)=$$ERR(16)
 I $G(FUN) S VFDC="" F I=1:1 Q:'$D(VFDC(I))  S VFDC=VFDC_VFDC(I)_";"
 Q
 ;
ID1 ; called from ID1^VFDCDUZ
 I $G(VFDRSLT)="" S VFDRSLT=$NA(VFDRSLT)
 I $G(VFDDUZ)<.5 S @VFDRSLT@(1)=$$ERR(18) Q
 N I,J,X,Y,Z,VFDATA,VFDATYP,VFDC,VFDI,VFDJ,VFDNPI,VFDQ,VFDR,VFDX,VFDZ
 D ID^VFDCDUZ(.VFDC,VFDDUZ,"DN")
 S VFDNPI=0
 S VFDATYP=$$GET^XPAR("SYS","VFDP RX ALTERNATE ID TYPES")
 F I=1:1:$L(VFDATYP,";") S X=$P(VFDATYP,";",I) S:$L(X) VFDATYP(X)=""
 F I=1:1 Q:'$D(VFDC(I))  D
 .I $P(VFDC(I),U)?1"DEA".E D IDSET(VFDC(I))
 .I $P(VFDC(I),U)?1"NPI".E S VFDNPI=1 D IDSET(VFDC(I))
 .Q
 ; Augment return with ALTERNATE ID values for DPS and possibly NPI.
 D GETS^DIQ(200,+VFDDUZ,"21600*","IEN",$NA(VFDATA))
 S I="" F  S I=$O(VFDATA(200.0216,I)) Q:'I  D
 .S VFDR=$NA(VFDATA(200.0216,I))
 .I $G(@VFDR@(.03,"I")),@VFDR@(.03,"I")<$G(DT,$$DT^XLFDT) Q  ;Expire ID
 .;  LICENSE-type alternate IDs
 .S X=$G(@VFDR@(.07,"I")) I X D  Q  ;Has LICENSE TYPE
 ..S Z=$G(^VFD(21613.1,X,0)) Q:'$G(^(1))  ;Screen if not RX PRINT
 ..S X=$P(Z,U,2) S:'$L(X) X=$P(Z,U) ;Abbreviation or name
 ..S Y="LIC^"_@VFDR@(.02,"E")_U_X_U_$G(@VFDR@(.03,"E")) D IDSET(Y)
 ..Q
 .;  parameterized ID types
 .I $D(VFDATYP)>1 S VFDQ=0 D  Q:VFDQ
 ..S X=$P($G(@VFDR@(.05,"E"))," ") Q:X=""
 ..Q:'$D(VFDATYP(X))  ;Only parameterized types here
 ..I X="NPI" Q:VFDNPI  ;Use field #41.99 NPI if valued
 ..I $D(VFDATYP(X)) D
 ...S Y=X_U_@VFDR@(.02,"E")_U_$G(@VFDR@(.01,"E"))_U_$G(@VFDR@(.04,"E"))
 ...D IDSET(Y)
 ...Q
 ..S VFDQ=1
 ..Q
 .I $G(@VFDR@(.05,"E"))?1"DPS".E D
 ..S Y="DPS^"_@VFDR@(.02,"E")_U_$G(@VFDR@(.01,"E"))_U_$G(@VFDR@(.04,"E"))
 ..D IDSET(Y)
 ..Q
 .Q:VFDNPI  ;Use field #41.99 NPI if valued
 .Q:'($G(@VFDR@(.05,"E"))?1"NPI".E)
 .S Y="NPI^"_@VFDR@(.02,"E")_U_$G(@VFDR@(.01,"E"))_U_$G(@VFDR@(.04,"E"))
 .D IDSET(Y)
 .Q
 Q
 ;
IDSET(VAL) N I S I=1+$O(VFDRSLT(" "),-1),VFDRSLT(I)=VAL Q
 ;
LIST ; Return a list of active users only for a lookup value
 N I,X,Y,Z,VFD,VFDCNT,VFDCX,VFDLIST,VFDRET,VFDSCR,VFDX,ERR,INPUT
 S VFDRET=$NA(^TMP("VFDC",$J)) K @VFDRET
 S VFDLIST=$NA(^TMP("VFDCDUZ",$J)) K @VFDLIST
 I $G(VAL)="" S @VFDRET@(1)=$$ERR(10) G LOUT
 S Z=0 I $D(SCR) D  I $D(ERR) S @VFDRET@(1)=ERR G LOUT
 .S X=$G(SCR) I X'="" D OK Q
 .S I="" F  S I=$O(SCR(I)) Q:I=""  S X=SCR(I) D OK
 .Q
 S INPUT(1)="FILE^200"
 S INPUT(2)="FIELDS^.01;20.2;20.3;1;8;29"
 S INPUT(3)="VAL^"_VAL
 S INPUT(4)="SCREEN^I $$ACT^VFDCDUZ(,+Y,.VFDSCR,1)>0"
 D FIND^VFDCFM05(.VFDLIST,.INPUT)
 S (VFD,VFDCNT)=0
 I $D(@VFDLIST) F  S VFD=$O(@VFDLIST@(VFD)) Q:'VFD  D
 .S X=$G(@VFDLIST@(VFD,0)) Q:+X'>0  S X=$P(X,U,2),X=$$NAMEFMT^XLFNAME(X)
 .S Y=@VFDLIST@(VFD,0),Z=$P(Y,U,1,4),$P(Z,U,5)=X_U_$P(Y,U,5,7)
 .S VFDX=Z
 .S X=$$DIV^VFDCDUZ(,+VFDX,1,1) I X>0 S $P(VFDX,U,9)=$P(X,U,2)
 .S VFDCNT=VFDCNT+1,@VFDRET@(VFDCNT,0)=VFDX
 .Q
 I '$D(@VFDRET) S @VFDRET@(1)=$$ERR(11)
LOUT S VFDC=VFDRET K @VFDLIST
 Q
 ;
PER() ; Return a user's current active person classification for PCE
 N X
 S X=$$CK(USER) I X<1 Q X
 S:'$G(DATE) DATE=DT
 S X=$$GET^XUA4A72(USER,DATE)
 I X<1 S DATE=$$FMTE^XLFDT(DATE),X=$$ERR(13)
 Q X
 ;
PROV() ; Determine is active cprs provider
 N X,Y,Z,ACC,KEY,VISITOR
 S X=$$CK(XDUZ) I X<1 Q X
 S RDV=+$G(RDV),RDV=(RDV'=0)
 S KEY=$D(^XUSEC("XUORES",XDUZ))
 S ACC=($P(^VA(200,XDUZ,0),U,3)'="")
 S VISITOR=$D(^VA(200,"BB","VISITOR",XDUZ))
 S Y=$$PROVIDER^XUSER(XDUZ,RDV)
 I ACC,Y=1 Q 3
 I Y["0^TERMINATED" Q $$ERR(6)
 I KEY Q 2
 I VISITOR Q RDV=1
 Q $$ERR(14)
 ;
 ; --------------------  subroutines  ----------------------
ERR(A) ; return error message
 S:A=1 A="No user DUZ value received"
 S:A=2 A="Invalid user DUZ value received: "_XDUZ
 S:A=3 A="NEW PERSON record "_XDUZ_" does not exist"
 S:A=4 A="User cannot sign-on"
 S:A=5 A="User cannot sign on, Disuser set"
 S:A=6 A="User terminated on "_$$FMTE^XLFDT($P(Y,U,3))
 S:A=7 A="User does not own security key "_Y
 S:A=8 A="User has no divisions defined"
 S:A=9 A="User has division(s), none marked as default"
 S:A=10 A="No lookup value received"
 S:A=11 A="No matches found"
 S:A=12 A="Invalid screen type received"
 S:A=13 A="Person does not have an active Person Class for "_DATE
 S:A=14 A="User is not a provider"
 S:A=15 A="Either invalid flags received, or file 200 fields do not exist"
 S:A=16 A="No data found for this record"
 S:A=17 A="More than one alternate ID found with none indicated as default"
 S:A=18 A="Missing or invalid NEW PERSON IEN"
 Q "-1^"_$G(A)
 ;
OK ;  validate SCR from LIST
 S Y=$P(X,U)
 I Y?.E1L.E S Y=$$UP^XLFSTR(Y)
 I Y="KEY"!(Y="M")!(Y="PARM") S Z=1+Z,VFDSCR(Z)=X
 E  I '$D(ERR) S ERR=$$ERR(12)
 Q
 ;
SCR() ;  dic screen for users
 I '$D(VFDSCR) Q 1
 N X,Y,Z,VFD,VFDRET,VFDX
 S VFD="",VFDRET=1
 F  S VFD=$O(VFDSCR(VFD)) Q:VFD=""  D  Q:$D(VFDRET)
 .S X=$P(VFDSCR(VFD),U),Y=$P(VFDSCR(VFD),U,2),Z=$P(VFDSCR(VFD),U,3)
 .I X="KEY" S:'$D(^XUSEC(Y,XDUZ)) VFDRET=$$ERR(7) Q
 .I X="PARM" D  Q
 ..S VFDX="USR~"_Y_"~"_Z,X=$$GET1^VFDCXPR(,VFDX,1)
 ..I +X=-1 S VFDRET=X
 ..Q
 .S VFDX="-1^"_$S(Y'="":Y,1:"Input screen failed")
 .I X="M" X "N VFDX X $P(VFDSCR(VFD),U,3,99)" E  S VFDRET=VFDX Q
 .Q
 Q VFDRET
