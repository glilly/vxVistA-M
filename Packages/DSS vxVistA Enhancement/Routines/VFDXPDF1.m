VFDXPDF1 ;DSS/SMP - PATCH UTIL ADD TO BATCH CONT ; 01/24/2013 12:00
 ;;3.1;DSS,INC VXVISTA SUPPORTED;;10 Dec 2012;Build 58
 ;Copyright 1995-2012,Document Storage Systems Inc. All Rights Reserved
 ;
 ;This routine is only invoked from ^VFDXPDF
 ;
 ;-----------------  Create/Update Batch File Record  -----------------
FILEBAT(PID,VFDLOC,KILL) ; usually called from VFDVXPDF
 ;   PID - req - ien to file 21692.1
 ;  KILL - opt - Boolean, default to 0, don't kill off old batch entry
 ;VFDLOC - opt - named reference to where the list of builds to add to
 ;  batch processing group.  Expects @VFDLOC@(build_name) as defined in
 ;  ^VFDXPDF.  Default to ^TMP("VFDXPD-DATA",$J)
 N I,J,X,Y,Z,VFDZ
 S PID=$G(PID),KILL=$G(KILL)
 S VFDLOC=$G(VFDLOC) S:VFDLOC="" VFDLOC=$NA(^TMP("VFDXPD",$J,"DATA"))
 I PID<1!'$D(^VFDV(21692.1,+PID,0))!'$D(@VFDLOC) Q -1
 S X=0
 F  S X=$O(@VFDLOC@(X)) Q:X=""  S Y=$G(@VFDLOC@(X,"IEN")) S:Y VFDZ(X,.01)=Y
 I '$D(VFDZ) Q -1
 I $G(KILL) D
 .N DA,DIK S DA(1)=PID,DIK="^VFDV(21692.1,PID,1,"
 .S DA=0 F  S DA=$O(^VFDV(21692.1,PID,1,DA)) Q:'DA  D ^DIK
 .Q
 S X=$$UPDDINUM^VFDXPDA(21692.11,","_PID_",",.VFDZ)
 Q X
 ;
 ;---------------  DETERMINE WHAT TYPE IS THE HFS FILE  ---------------
FILETYPE(VFDLOC,VFDRET) ;
 ;VFDLOC - req - $NAME value of where the file is loaded where it
 ;   expects that @VFDLOC@(n) contains the contents of the file
 ; Extrinsic function returns F or K for a KIDS HFS file (F:FOIA)
 ;                            M:packman mail message
 ;                            T:patch description text file
 ;                            0:KIDS HFS file - global transport
 ;                           -1:not a valid file type
 ;.VFDRET - returns some date from the file if appropriate
 ; VFDRET(KID,BLD) =   build name
 ;           ,DATE) =  date of Mailman message
 ;           ,MES) =   subject of mailman message
 ;           ,MSGID) = Forum Mailman message number
 ;           ,IN) =    primary multi-build name (FT)
 ;           ,ORD) =   install order number in a multi-build
 ;           ,PATCH) = patch number
 ;           ,PKG) =   Build name portion or namespace
 ;           ,REL) =   date patch was released
 ;           ,SEQ) =   sequence number
 ;           ,SUBJ) =  patch description subject line
 ;           ,VER) =   Build ver num
 ; For multi-builds there would be several KID subscripts but only the
 ; main build will have all of those second subscipts.
 N I,J,L,X,Y,Z,EQ,EQCNT,L1,L2,L3,RET,STOP,VTMP
 S RET=-1,(EQCNT,STOP)=0 S $P(EQ,"=",78)=""
 Q:$G(VFDLOC)="" RET
 Q:$O(@VFDLOC@(0))="" RET
 S L1=$G(@VFDLOC@(1)),L2=$G(@VFDLOC@(2)),L3=$G(@VFDLOC@(3))
 ;
 ; first process a KIDS HFS file export
 ; VFDRET = -1 or 0 or K or F
 I $E(L3,1,8)="**KIDS**" D F1,F6 Q RET
 ;
 ; at this point we should only have a patch desc or packman file
 ; both file types expected to begin with a patch description
 ; check for start of Packman message which must have $TXT line
 S I=0 F  D NXT D  Q:STOP!(RET'=-1)
 .I X=EQ S EQCNT=1+EQCNT,VTMP("~",EQCNT)=I
 .I 'EQCNT D  Q 
 ..I $E(X,1,5)="$TXT ",(X'["(KIDS)")!($G(@VFDLOC@(I+1))'=EQ) S STOP=1
 ..Q
 .; extract data from patch description header
 .; between "=" lines can be 3 or 4 lines
 .I EQCNT=1 D:X=EQ F2 Q
 .I EQCNT=2 S:X?1"Subject: ".E VTMP("~","SUBJ")=$P(X,": ",2,9) Q
 .I EQCNT=3 D:X=EQ F3 Q
 .Q:EQCNT<4
 .; FOIA and DSS create text description files differently
 .; may be a packman mail message HFS file
 .D:X="$END TXT" F4
 .Q
 ; could still have a valid patch description
 I RET=-1,EQCNT=4 S RET="T"
 Q:"MT"'[RET RET
 D F5,F6
 Q RET
 ;
F1 ; validate the file is a KIDS HFS file
 N A,J,L,X,Y,Z,KID,TXT,VFDT,I
 S X=$P(L3,"**KIDS**",2,99) Q:X=""
 I $P(X,":")="GLOBALS" S RET=0 Q
 ; get list of all kids in file, may have multiple lines
 S L=0,X=$P(X,":",2)
 F J=1:1:$L(X,U) S Z=$P(X,U,J) S:Z'="" L=L+1,Y(L)=Z
 S I=3 F  D NXT Q:X=""!STOP  D  Q:STOP
 .I $E(X,1,8)'="**KIDS**" S STOP=1 Q
 .S X=$P(X,":",2)
 .F J=1:1:$L(X,U) S Z=$P(X,U,J) S:Z'="" L=L+1,Y(L)=Z
 .Q
 Q:STOP
 ;
 F J=1:1:L S Z=Y(J) D
 .K VFDT S VFDT=Z D PARSENM^VFDXPD0(.VFDT)
 .S A=$G(VFDT("BLD")) Q:A=""  I J=1 S KID=A
 .S X=0 F  S X=$O(VFDT(X)) Q:X=""  S:X'="SEQ" VTMP(A,X)=VFDT(X)
 .I L>1 S VTMP(A,"ORD")=J,VTMP(A,"IN")=KID
 .Q
 ; next line should contain *INSTALL NAME*
 D NXT I X'["**INSTALL NAME**" S STOP=1 Q
 ; now check the end of the file for proper context
 ; may have control chars at end of file
 S (Y,Z)=" ",TXT="**END**"
 F J=1:1:10 S Y=$O(@VFDLOC@(Y),-1) Q:Y=""  S X=$G(^(Y)) D  I Z=2!STOP Q
 .I X=TXT S Z=Z+1,Y=$O(@VFDLOC@(Y),-1),X="" S:Y'="" X=^(Y) S:X=TXT Z=Z+1
 .I  S:Z'=2 STOP=1 Q
 .I X?.E1A.E S STOP=1 Q
 .Q
 Q:STOP
 I L1["KIDS Distribution saved on " S RET="K",VTMP(KID,"MES")=L2
 I L2["Extracted from mail message" S RET="F",VTMP(KID,"MES")=L1
 Q
 ;
F2 ; extract data from patch header
 N A,Y,Z,VFDT
 S Z(1)=X F Z=2:1:5 D NXT S Z(Z)=X
 Q:STOP
 I Z(5)=EQ S Z(6)=Z(5),Z(5)=""
 E  D NXT S Z(6)=X
 I Z(6)=EQ S EQCNT=1+EQCNT,VTMP("~",EQCNT)=I
 I EQCNT'=2 S STOP=1 Q
 I $P(Z(2),":")'="Run Date" S STOP=1 Q
 I $P(Z(2),":",2)'["Designation" S STOP=1 Q
 I $P(Z(3)," :")'="Package" S STOP=1 Q
 I $P(Z(3),":",2)'["Priority" S STOP=1 Q
 I $P(Z(4)," :")'="Version" S STOP=1 Q
 I $P(Z(4),":",2)'["Status" S STOP=1 Q
 I Z(6)'=EQ S STOP=1 Q
 S Y=$P(Z(2),": ",3) Q:Y=""
 S VFDT=Y D PARSENM^VFDXPD0(.VFDT)
 S A=$G(VFDT("BLD")) Q:A=""
 S Y=0 F  S Y=$O(VFDT(Y)) Q:Y=""  S VTMP(A,Y)=VFDT(Y)
 S Y=+$P(Z(4),": ",2) I Y,'$G(VTMP(A,"VER")) S VTMP(A,"VER")=Y
 S Y=+$P(Z(4),"SEQ #",2) I Y,'$G(VTMP(A,"SEQ")) S VTMP(A,"SEQ")=Y
 Q
 ;
F3 ; check in case someone put a 77"=" in their patch description
 ; eqcnt=3
 N Y,Z
 I $$UP^XLFSTR(FILE)[".TXT" D  Q
 .D ROLLUP
 S Y=$G(@VFDLOC@(I+1))
 I $E(Y,1,17)'="User Information:" K VTMP(EQCNT) S EQCNT=EQCNT-1 Q
 F Z=1:1:5 D NXT S Z(Z)=X
 I Z(5)'=EQ S STOP=1 Q
 S Z="Date Released : "
 I Z(4)'[Z S STOP=1 Q
 S EQCNT=EQCNT+1,VTMP("~",EQCNT)=I
 S Y=$P(Z(4),Z,2) S:Y'="" VTMP("~","REL")=Y
 Q
 ;
F4 ; $END TXT line encountered
 N J,Y,Z
 S VTMP("~",5)=I
 D NXT I X'?1"$KID ".E S RET="T",STOP=0 Q
 D NXT I X'="**INSTALL NAME**" S RET="T",STOP=0 Q
 ; check PACKMAN end of file, may have control char at end of file
 S Z=0,Y=" "
 F J=1:1:10 S Y=$O(@VFDLOC@(Y),-1) Q:Y=""  S X=$G(^(Y)) D  I Z!STOP Q
 .I 'Z,Y?.E1A.E S STOP=1 Q
 .I $E(X,1,9)="$END KID " S Z=1,RET="M"
 .Q
 Q
 ;
F5 ; get additional data
 N X,Y
 S X=$$UP^VFDXPD0(L1)
 I X?1"SUBJECT: ".E S VTMP("~","MES")=$P(L1,": ",2,9)
 S X=$$UP^VFDXPD0(L2),Y=$P($P(X," ",2,9),":",1,2)
 I (X?1"DATE: ".E)!(X?1"SENT: ".E) S VTMP("~","DATE")=Y
 S X=$$UP^VFDXPD0(L3)
 I X?1"MESSAGE-ID: ".E S VTMP("~","MSGID")=$P($P(L3,"<",2),".")
 Q
 ;
F6 ; moved VTMP() => VFDRET(KIDS)
 ; vtmp() may contain multiple KIDS builds
 N A,B,I,J,R,X,Y,Z,KID,KIDX,TMP
 I $D(VTMP("~")) D
 .S X=$O(VTMP(0)) I "~"[X K VTMP Q
 .S Z="" F  S Z=$O(VTMP("~",Z)) Q:Z=""  S VTMP(X,Z)=VTMP("~",Z)
 .K VTMP("~")
 .Q
 S X=0 F  S X=$O(VTMP(X)) Q:X=""  D
 .F Z="PATCH","SEQ","VER" S:$D(VTMP(X,Z)) VTMP(X,Z)=+VTMP(X,Z)
 .Q
 M VFDRET=VTMP
 Q
 ;
ROLLUP ;
 N J,X,Y,Z,LAST,CNT S Z="Date Released : "
 S LAST=$O(@VFDLOC@(""),-1)
 F J=LAST:-1:LAST-10 S X=$G(@VFDLOC@(J)) D  Q:$D(Y)
 .I X=EQ S EQCNT=EQCNT+1,VTMP("~",EQCNT)=J
 .I X[Z S Y=$P(X,Z,2)
 I (J-5)>I K VTMP("~",EQCNT),VTMP("~",EQCNT-1) S EQCNT=EQCNT-2
 Q:EQCNT'=4
 S:Y'="" VTMP("~","REL")=Y S I=VTMP("~",4) ;,EQCNT=3
 Q
 ;
 ;==================== MINE KIDS HFS FILE FOR DATA ====================
MINEKID(VFDLOC,VFDTMP) ; get req builds, install routines
 ; VFDLOC - opt - named ref where file resides
 ;                Default to ^TMP("VFDXPD",$J,2)
 ; .VFDTMP(kids,sub) - both an input and output parameter passed by
 N A,I,J,Q,X,Y,Z,KID,KID1,ORD,STOP,TINS
 S (I,ORD,STOP)=0
 I $G(VFDLOC)="" N VFDLOC S VFDLOC=$NA(^TMP("VFDXPD",$J,2))
 S TINS="**INSTALL NAME**"
 S Q=$C(34) ; a double quote char
 ; find the first TINS line
 F  D NXT Q:STOP  I X=TINS S I=I-1 Q
 Q:STOP
 ; now need to get lines in pairs
 ; name of builds in a multi-build gotten in FILETYPE above
 F  D NXT Q:STOP  D  Q:STOP
 .I X="**END**" S STOP=1 Q
 .I X=TINS D NXT S KID=X Q
 .K Y S Y=X D NXT
 .; y=partial global reference
 .; x=value of the global
 .; need to translate U to ~ for install routines to file to 21692
 .S X=$TR(X,U,"~")
 .K A,Z S Z="A("_Y F J=1:1:$QL(Z) S Z(J)=$QS(Z,J)
 .Q:"^BLD^INI^INIT^PRE^"'[(U_Z(1)_U)
 .I "^INI^INIT^PRE^"[(U_Z(1)_U) D:X'=""  Q
 ..S Z(9)=$S(Z(1)="INI":"PRE",Z(1)="INIT":"POST",1:"ENV")
 ..S VFDTMP(KID,Z(9))=X
 ..Q
 .Q:Z(1)'="BLD"  Q:"^INI^INIT^PRE^REQB^"'[(U_Z(3)_U)
 .I $QL(Z)=3 D:X'=""  Q
 ..S Z(9)=$S(Z(3)="INI":"PRE",Z(3)="INIT":"POST",1:"ENV")
 ..S VFDTMP(KID,Z(9))=X
 ..Q
 .I $QL(Z)=5,X'="" S X=$P(X,"~") S:X'="" VFDTMP(KID,"REQ",X)=""
 .Q
 Q
 ;
 ;---------------------------------------------------------------------
NXT S I=I+1,X=$G(@VFDLOC@(I)) S STOP='$D(@VFDLOC@(I)) Q
 ;
 ;
FX ; programmer's test utility - only accessible from programmer mode
 N I,X,Y,Z,FILE,PATH,RET,VFDR,VFDY
 S VFDR=$NA(^TMP("VFDXPD",$J,0))
 S PATH="\\vxdev64v2k8\e$\Development\Patches\Dssapps\"
 F  W !,"Enter filename: " R FILE:300 Q:FILE=""  D
 .W !,"PATH = ",PATH,!,"FILE = ",FILE,!
 .K @VFDR S Y=$$FTG^VFDXPD0(PATH,FILE,$NA(@VFDR@(1)))
 .I Y K VFDY S X=$$FILETYPE(VFDR,.VFDY) X "W !,X,! ZW VFDY"
 .K @VFDR Q
 Q
