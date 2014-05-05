VFDWDPT1 ;DSS/SGM/LM - DESKTOP PATIENT LOOKUP
 ;;2009.2;DSS,INC VXVISTA OPEN SOURCE;;01 Dec 2009
 ;Copyright 1995-2009,Document Storage Systems Inc. All Rights Reserved
 ;
LOOKUP(VFDWDPT,VFDWA) ;[PRIVATE] Continuation of RPC: VFDW PATIENT LOOKUP
 ; See LOOKUP^VFDWDPT for details
 ; 
 N VFDWCODE,VFDWERR,VFDWMORE,I,X,Y S VFDWERR=0
 ; 
 ;Cross-reference VFDWA code-value pairs
 F I=1:1 Q:'$D(VFDWA(I))  S VFDWCODE=$P(VFDWA(I),U) D:$L(VFDWCODE)
 .S VFDWA("B",VFDWCODE)=$P(VFDWA(I),U,2,99)
 .Q
 ;
 I $G(VFDWA("B","LIEN")),$L($G(VFDWA("B","LINX"))),$L($G(VFDWA("B","LTXT"))) S VFDWMORE=1
 E  S VFDWMORE=0
 ;
 N VFDWFLGS,VFDWXSTR S VFDWFLGS="" ;Establish index(es) to use
 S X=$G(VFDWA("B","INDEX"),"DEF"),X=$TR(X,";,","^^") ;Index string
 S:$E(X)="-" VFDWFLGS=VFDWFLGS_"B",X=$E(X,2,99)
 I X="DEF" S X="B^BS^BS5^SSN"
 E  I X="PARAM" S X=$$GET^XPAR("ALL","VFDW PATIENT INDEX")
 E  F I=1:1:$L(X,"^") S Y=$P(X,U,I) D  Q:VFDWERR  S $P(X,U,I)=Y
 .I Y=""!(Y="BS")!(Y="BS5")!(Y="SSN") ;no-op
 .E  I Y="ADR" S Y="" ;Per Steve: Defer ADR index
 .E  I Y="ALTID" S Y="AVFD"
 .E  I Y="DOB" S Y="ADOB"
 .E  I Y="NAME" S Y="B"
 .E  I Y="TEL" S Y="VFDTEL"
 .; Parse additional index codes here
 .E  S VFDWERR=1
 .Q
 ;
 I VFDWERR S VFDWDPT(1)="-1^Invalid INDEX specified" K ZZIN("B") Q
 N VFDWLIEN,VFDWLINX ;Last IEN and last index name, if passed
 S VFDWLINX=$G(VFDWA("B","LINX"))
 I $L(VFDWLINX) F I=1:1:$L(X,"^") Q:VFDWLINX=$P(X,"^",I)
 E  S I=1
 S VFDWLIEN=$G(VFDWA("B","LIEN"))
 S VFDWXSTR=$P(X,"^",I,$L(X,"^")) ;Remove previously completed indexes
 ;
 N VFDWFLDS,VFDWFROM,VFDWLVAL,VFDWMAXN
 S VFDWFLDS=$G(VFDWA("B","FLDS"))
 S VFDWFROM=$G(VFDWA("B","LTXT")) ;LTXT is new name
 S VFDWLVAL=$G(VFDWA("B","VAL"))
 S VFDWMAXN=$G(VFDWA("B","MAX"),44)
 ; Parse additional input codes here
 ;
 N VFDWSPC S VFDWSPC=$E(VFDWLVAL)=" " ;Flag indicating VAL starts with space
 ; Basic validity checks
 I '$L(VFDWLVAL),'$L(VFDWFROM) D  Q  ;T5
 .S VFDWDPT(1)="-1^Either VAL or LTXT must be specified." K VFDWA("B")
 .Q
 I VFDWSPC,'$L($G(VFDWA("B","INDEX")))!(VFDWXSTR="NAME")!(VFDWXSTR="B") D  Q
 .S VFDWDPT(1)="-1^Lookup <SP>VALUE requires non-NAME index" K VFDWA("B")
 .Q
 I VFDWSPC&$L(VFDWFROM)&'($E(VFDWFROM)=" ")!('VFDWSPC&($E(VFDWFROM)=" ")) D  Q  ;T7
 .S VFDWDPT(1)="-1^<SP> syntax inconsistent in VAL and LTXT parameters" K VFDWA("B")
 .Q
 D:VFDWSPC  ;Remove leading space from VFDWFROM and VFDWLVAL
 .S VFDWFROM=$E(VFDWFROM,2,$L(VFDWFROM))
 .S VFDWLVAL=$E(VFDWLVAL,2,$L(VFDWLVAL))
 .Q
 ; If multiple index do not allow backwards traversal ->
 I VFDWFLGS["B",$L(VFDWXSTR,U)>1 S VFDWFLGS=$TR(VFDWFLGS,"B")
 N VFDWRPL S VFDWRPL=$D(VFDWA("B","RPL"))>0 ;RPL Flag
 K VFDWA("B") ;Parsing complete
 N VFDWDFLD S VFDWDFLD=0 ;If applicable, ;-piece position of ID field
 ; Default fields
 D:'$L(VFDWFLDS)
 .S $P(VFDWFLDS,";",1)=.01
 .S $P(VFDWFLDS,";",2)=.03
 .S $P(VFDWFLDS,";",3)=$S($L($$GET1^DID(2,21601,,"LABEL")):21601,1:.033)
 .S $P(VFDWFLDS,";",4)=.02
 .S VFDWDFLD=5 ;Default ID will be appended in ID^VFDWDPT(.VFDWDPT)
 .Q
 ;
 S VFDWFLDS=$$NORM(VFDWFLDS) ;Normalize field list
 ; Prep call to LIST^VFDCFM
 N VFDW,VFDWCNDX,VFDWDFN,VFDWI,VFDWJ,VFDWK,VFDWNPUT,VFDWUNL
 S VFDWNPUT(1)="FILE^2"
 S VFDWNPUT(2)="FIELDS^"_VFDWFLDS
 S VFDWNPUT(3)="PART^"
 S:VFDWMORE $P(VFDWNPUT(3),U,2)=VFDWLVAL
 E  S VFDWNPUT(3)="PART^"
 N VFDWN S VFDWN=6 ; Optional parameters
 S:VFDWFLGS]"" VFDWN=VFDWN+1,VFDWNPUT(VFDWN)="FLAGS^"_VFDWFLGS ;optional
 I VFDWRPL,$G(DUZ) S VFDWRPL=$$FIND1^DIC(100.21,,"QX",DUZ,"C","I $P(^(0),U,2)=""P""") D:VFDWRPL  ;RPL
 .S VFDWN=VFDWN+1,VFDWNPUT(VFDWN)="RPL^"_VFDWRPL
 .Q
 ;
 ; Loop through indexes until return array is full
 S (VFDWJ,VFDWERR)=0
 F VFDWI=1:1:$L(VFDWXSTR,"^") Q:VFDWERR  Q:VFDWMAXN-VFDWJ<1  D
 .S VFDWCNDX=$P(VFDWXSTR,"^",VFDWI) ;Current index
 .I VFDWCNDX="B" Q:VFDWSPC  ;Skip "B" index, if VAL starts with <SPACE>
 .S VFDWNPUT(3)="PART^" E  S $P(VFDWNPUT(3),U,2)=VFDWLVAL
 .S VFDWNPUT(4)="NUMBER^"_(VFDWMAXN-VFDWJ)
 .S VFDWNPUT(5)="INDEX^"_VFDWCNDX
 .I VFDWCNDX="B",VFDWFROM="" S VFDWFROM=VFDWLVAL
 .S VFDWNPUT(6)="FROM^"_VFDWFROM_"^"_VFDWLIEN ;optional
 .D LIST(.VFDW,.VFDWNPUT)
 .F I=1:1 Q:'($D(@VFDW@(I,0))#2)!VFDWERR  D
 ..S VFDWDFN=+@VFDW@(I,0)
 ..Q:$D(VFDWUNL(VFDWDFN))  S VFDWUNL(VFDWDFN)="" ;Unique DFN
 ..S VFDWJ=VFDWJ+1,VFDWDPT(VFDWJ)=@VFDW@(I,0)
 ..S:VFDWDFN<0 VFDWERR=1
 ..Q
 .K @VFDW
 .Q
 I 'VFDWJ S VFDWJ=VFDWJ+1,VFDWDPT(VFDWJ)="-1^No match found" Q
 E  I VFDWJ>1,VFDWDPT(VFDWJ)<0 S X=VFDWDPT(VFDWJ) K VFDWDPT S VFDWDPT(1)=X
 E  D:VFDWDFLD ID(.VFDWDPT)
 Q
NORM(X) ;;[Private] Normalize field list
 ; Make .01 first and remove duplicates
 ; 
 N I,Y,Z
 F I=1:1:$L(X,";") S:$P(X,";",I)]"" Z($P(X,";",I))=""
 S Y=".01",Z="" F  S Z=$O(Z(Z)) Q:Z=""  S:'(Z=.01) Y=Y_";"_Z
 Q Y
LIST(VFDW,VFDWNPUT) ;[Private] Wrap LIST^DIC
 ; Replaces call to LIST^VFDCFM to avoid forced packing
 ; VFDW=Name of return array
 ; VFDWNPUT=Same as LIST^VFDCFM input array
 ;
 S VFDW=$NA(^TMP("VFDW",$J)) K @VFDW S VFDW=$NA(@VFDW@("DILIST"))
 I $D(VFDWNPUT(1))#2 N VFDWX,VFDWY,I,J,K,X,Y
 E  D  Q
 .S @VFDW@(1,0)="-1^Invalid input to LIST^VFDWDPT"
 .Q
 F I=1:1 Q:'$D(VFDWNPUT(I))  D
 .S X=$G(VFDWNPUT(I)) S:$L($P(X,U)) VFDWX($P(X,U))=$P(X,U,2,99)
 .Q
 I $G(VFDWX("FILE")),$L($G(VFDWX("FIELDS"))),$L($G(VFDWX("INDEX"))),$D(VFDWX("PART")) ;T5
 E  D  Q
 .S @VFDW@(1,0)="-1^Missing required parameter in LIST^VFDWDPT"
 .Q
 N VFDWFROM S VFDWFROM=$P($G(VFDWX("FROM")),U)
 I VFDWX("INDEX")="AVFD",VFDWFROM]"" D
 .S VFDWFROM(1)=0
 .S VFDWFROM(2)=VFDWFROM
 .S VFDWFROM=""
 .Q
 I $L($P($G(VFDWX("FROM")),U,2)) S VFDWFROM("IEN")=$P(VFDWX("FROM"),U,2)
 N VFDWPART S VFDWPART=$G(VFDWX("PART"))
 I VFDWX("INDEX")="AVFD",VFDWPART]"" D
 .S VFDWPART(2)=VFDWPART
 .S VFDWPART=""
 .Q
 N VFDWSCR
 I $G(VFDWX("RPL")) S VFDWSCR="I $D(^OR(100.21,""AB"",Y_"";DPT("","_VFDWX("RPL")_"))"
 N DIQUIET,VFDWFM S DIQUIET=1,VFDWFM=$NA(^TMP("VFDWFM",$J)) K @VFDWFM
 S VFDWX("FIELDS")=$G(VFDWX("FIELDS"))_$S($L($G(VFDWX("FIELDS"))):";",1:"")_"IX"
 D LIST^DIC(+VFDWX("FILE"),,VFDWX("FIELDS"),$G(VFDWX("FLAGS")),$G(VFDWX("NUMBER")),.VFDWFROM,.VFDWPART,VFDWX("INDEX"),.VFDWSCR,,VFDWFM,VFDWFM)
 I $D(@VFDWFM@("DIERR")) S @VFDW@(1,0)="-1^LIST~DIC~"_$G(@VFDWFM@("DIERR",1))_"~"_$G(@VFDWFM@("DIERR",1,"TEXT",1)) Q
 ;
 S (I,K)=0 F  S I=$O(@VFDWFM@("DILIST",2,I))  Q:'I  D  ;Transfer results
 .S VFDWY=$G(@VFDWFM@("DILIST",2,I)) ;IEN=DFN
 .S $P(VFDWY,U,2)=$G(@VFDWFM@("DILIST","ID",I,.01)) ;NAME
 .; ^-piece 3 intentionally left blank
 .; ^-piece 4 special for "AVFD" index ->
 .S $P(VFDWY,U,4)=$S($G(VFDWSPC):" ",1:"")_$S(VFDWX("INDEX")="AVFD":$G(@VFDWFM@("DILIST",1,I,1))_"~"_$G(@VFDWFM@("DILIST",1,I,2)),1:$G(@VFDWFM@("DILIST",1,I)))
 .S $P(VFDWY,U,5)=VFDWX("INDEX") ;Index name
 .F J=1:1:$L(VFDWX("FIELDS"),";") S Y=$P(VFDWX("FIELDS"),";",J) D:Y
 ..S $P(VFDWY,U,5+J)=$G(@VFDWFM@("DILIST","ID",I,Y))
 ..Q
 .S K=K+1,@VFDW@(K,0)=VFDWY
 .Q
 K @VFDWFM
 Q
ID(VFDW) ;;[Private] Append ID to default fields
 ; VFDW=Populated return array (by reference)
 ; From specification -
 ; 
 ;                  VFDID = computed:
 ;                          If default Alternate ID exists, then this
 ;                          Else if 1 & only 1 Alt ID exists, then this
 ;                          Else if more than 1 Alt ID exists, then null
 ;                          Else if SSN (.09) exists, then SSN
 ;
 N DFN,I,J,VFDID,X
 S VFDID="" F I=1:1 Q:'$D(VFDW(I))  D
 .S X=$G(VFDW(I)),DFN=+X Q:'(DFN>0)
 .S J=$O(^DPT(DFN,21600,"AX",1,0))
 .I J S VFDID=$P($G(^DPT(DFN,21600,J,0)),U,2) ;DEFAULT Alternate ID
 .; Next is Exactly one Alternate ID -
 .E  I $P($G(^DPT(DFN,21600,0)),U,4)=1 S J=$P(^(0),U,3),VFDID=$P($G(^(J,0)),U,2)
 .E  I $P($G(^DPT(DFN,21600,0)),U,4)>1 S VFDID="" ;More than one Alternate ID
 .E  S VFDID=$P($G(^DPT(DFN,0)),U,9) ;SSN
 .S $P(X,U,VFDWDFLD+5)=VFDID,VFDW(I)=X
 .Q
 Q
