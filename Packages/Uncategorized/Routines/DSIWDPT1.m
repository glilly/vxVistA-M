DSIWDPT1 ;DSS/SGM/LM - DESKTOP PATIENT LOOKUP
 ;;1.0;;;;
 ;
LOOKUP(DSIWDPT,DSIWA) ;[PRIVATE] Continuation of RPC: DSIW PATIENT LOOKUP
 ; See LOOKUP^DSIWDPT for details
 ; 
 N DSIWCODE,DSIWERR,DSIWMORE,I,X,Y S DSIWERR=0
 ; 
 ;Cross-reference DSIWA code-value pairs
 F I=1:1 Q:'$D(DSIWA(I))  S DSIWCODE=$P(DSIWA(I),U) D:$L(DSIWCODE)
 .S DSIWA("B",DSIWCODE)=$P(DSIWA(I),U,2,99)
 .Q
 ;
 I $G(DSIWA("B","LIEN")),$L($G(DSIWA("B","LINX"))),$L($G(DSIWA("B","LTXT"))) S DSIWMORE=1
 E  S DSIWMORE=0
 ;
 N DSIWFLGS,DSIWXSTR S DSIWFLGS="" ;Establish index(es) to use
 S X=$G(DSIWA("B","INDEX"),"DEF"),X=$TR(X,";,","^^") ;Index string
 S:$E(X)="-" DSIWFLGS=DSIWFLGS_"B",X=$E(X,2,99)
 I X="DEF" S X="B^BS^BS5^SSN"
 E  I X="PARAM" S X=$$GET^XPAR("ALL","DSIW PATIENT INDEX")
 E  F I=1:1:$L(X,"^") S Y=$P(X,U,I) D  Q:DSIWERR  S $P(X,U,I)=Y
 .I Y=""!(Y="BS")!(Y="BS5")!(Y="SSN") ;no-op
 .E  I Y="ADR" S Y="" ;Per Steve: Defer ADR index
 .E  I Y="ALTID" S Y="AVFD"
 .E  I Y="DOB" S Y="ADOB"
 .E  I Y="NAME" S Y="B"
 .E  I Y="TEL" S Y="VFDTEL"
 .; Parse additional index codes here
 .E  S DSIWERR=1
 .Q
 ;
 I DSIWERR S DSIWDPT(1)="-1^Invalid INDEX specified" K ZZIN("B") Q
 N DSIWLIEN,DSIWLINX ;Last IEN and last index name, if passed
 S DSIWLINX=$G(DSIWA("B","LINX"))
 I $L(DSIWLINX) F I=1:1:$L(X,"^") Q:DSIWLINX=$P(X,"^",I)
 E  S I=1
 S DSIWLIEN=$G(DSIWA("B","LIEN"))
 S DSIWXSTR=$P(X,"^",I,$L(X,"^")) ;Remove previously completed indexes
 ;
 N DSIWFLDS,DSIWFROM,DSIWLVAL,DSIWMAXN
 S DSIWFLDS=$G(DSIWA("B","FLDS"))
 S DSIWFROM=$G(DSIWA("B","LTXT")) ;LTXT is new name
 S DSIWLVAL=$G(DSIWA("B","VAL"))
 S DSIWMAXN=$G(DSIWA("B","MAX"),44)
 ; Parse additional input codes here
 ;
 N DSIWSPC S DSIWSPC=$E(DSIWLVAL)=" " ;Flag indicating VAL starts with space
 ; Basic validity checks
 I '$L(DSIWLVAL),'$L(DSIWFROM) D  Q  ;T5
 .S DSIWDPT(1)="-1^Either VAL or LTXT must be specified." K DSIWA("B")
 .Q
 I DSIWSPC,'$L($G(DSIWA("B","INDEX")))!(DSIWXSTR="NAME")!(DSIWXSTR="B") D  Q
 .S DSIWDPT(1)="-1^Lookup <SP>VALUE requires non-NAME index" K DSIWA("B")
 .Q
 I DSIWSPC&$L(DSIWFROM)&'($E(DSIWFROM)=" ")!('DSIWSPC&($E(DSIWFROM)=" ")) D  Q  ;T7
 .S DSIWDPT(1)="-1^<SP> syntax inconsistent in VAL and LTXT parameters" K DSIWA("B")
 .Q
 D:DSIWSPC  ;Remove leading space from DSIWFROM and DSIWLVAL
 .S DSIWFROM=$E(DSIWFROM,2,$L(DSIWFROM))
 .S DSIWLVAL=$E(DSIWLVAL,2,$L(DSIWLVAL))
 .Q
 ; If multiple index do not allow backwards traversal ->
 I DSIWFLGS["B",$L(DSIWXSTR,U)>1 S DSIWFLGS=$TR(DSIWFLGS,"B")
 N DSIWRPL S DSIWRPL=$D(DSIWA("B","RPL"))>0 ;RPL Flag
 K DSIWA("B") ;Parsing complete
 N DSIWDFLD S DSIWDFLD=0 ;If applicable, ;-piece position of ID field
 ; Default fields
 D:'$L(DSIWFLDS)
 .S $P(DSIWFLDS,";",1)=.01
 .S $P(DSIWFLDS,";",2)=.03
 .S $P(DSIWFLDS,";",3)=$S($L($$GET1^DID(2,21601,,"LABEL")):21601,1:.033)
 .S $P(DSIWFLDS,";",4)=.02
 .S DSIWDFLD=5 ;Default ID will be appended in ID^DSIWDPT(.DSIWDPT)
 .Q
 ;
 S DSIWFLDS=$$NORM(DSIWFLDS) ;Normalize field list
 ; Prep call to LIST^DSICFM
 N DSIW,DSIWCNDX,DSIWDFN,DSIWI,DSIWJ,DSIWK,DSIWNPUT,DSIWUNL
 S DSIWNPUT(1)="FILE^2"
 S DSIWNPUT(2)="FIELDS^"_DSIWFLDS
 S DSIWNPUT(3)="PART^"
 S:DSIWMORE $P(DSIWNPUT(3),U,2)=DSIWLVAL
 E  S DSIWNPUT(3)="PART^"
 N DSIWN S DSIWN=6 ; Optional parameters
 S:DSIWFLGS]"" DSIWN=DSIWN+1,DSIWNPUT(DSIWN)="FLAGS^"_DSIWFLGS ;optional
 I DSIWRPL,$G(DUZ) S DSIWRPL=$$FIND1^DIC(100.21,,"QX",DUZ,"C","I $P(^(0),U,2)=""P""") D:DSIWRPL  ;RPL
 .S DSIWN=DSIWN+1,DSIWNPUT(DSIWN)="RPL^"_DSIWRPL
 .Q
 ;
 ; Loop through indexes until return array is full
 S (DSIWJ,DSIWERR)=0
 F DSIWI=1:1:$L(DSIWXSTR,"^") Q:DSIWERR  Q:DSIWMAXN-DSIWJ<1  D
 .S DSIWCNDX=$P(DSIWXSTR,"^",DSIWI) ;Current index
 .I DSIWCNDX="B" Q:DSIWSPC  ;Skip "B" index, if VAL starts with <SPACE>
 .S DSIWNPUT(3)="PART^" E  S $P(DSIWNPUT(3),U,2)=DSIWLVAL
 .S DSIWNPUT(4)="NUMBER^"_(DSIWMAXN-DSIWJ)
 .S DSIWNPUT(5)="INDEX^"_DSIWCNDX
 .I DSIWCNDX="B",DSIWFROM="" S DSIWFROM=DSIWLVAL
 .S DSIWNPUT(6)="FROM^"_DSIWFROM_"^"_DSIWLIEN ;optional
 .D LIST(.DSIW,.DSIWNPUT)
 .F I=1:1 Q:'($D(@DSIW@(I,0))#2)!DSIWERR  D
 ..S DSIWDFN=+@DSIW@(I,0)
 ..Q:$D(DSIWUNL(DSIWDFN))  S DSIWUNL(DSIWDFN)="" ;Unique DFN
 ..S DSIWJ=DSIWJ+1,DSIWDPT(DSIWJ)=@DSIW@(I,0)
 ..S:DSIWDFN<0 DSIWERR=1
 ..Q
 .K @DSIW
 .Q
 I 'DSIWJ S DSIWJ=DSIWJ+1,DSIWDPT(DSIWJ)="-1^No match found" Q
 E  I DSIWJ>1,DSIWDPT(DSIWJ)<0 S X=DSIWDPT(DSIWJ) K DSIWDPT S DSIWDPT(1)=X
 E  D:DSIWDFLD ID(.DSIWDPT)
 Q
NORM(X) ;;[Private] Normalize field list
 ; Make .01 first and remove duplicates
 ; 
 N I,Y,Z
 F I=1:1:$L(X,";") S:$P(X,";",I)]"" Z($P(X,";",I))=""
 S Y=".01",Z="" F  S Z=$O(Z(Z)) Q:Z=""  S:'(Z=.01) Y=Y_";"_Z
 Q Y
LIST(DSIW,DSIWNPUT) ;[Private] Wrap LIST^DIC
 ; Replaces call to LIST^DSICFM to avoid forced packing
 ; DSIW=Name of return array
 ; DSIWNPUT=Same as LIST^DSICFM input array
 ;
 S DSIW=$NA(^TMP("DSIW",$J)) K @DSIW S DSIW=$NA(@DSIW@("DILIST"))
 I $D(DSIWNPUT(1))#2 N DSIWX,DSIWY,I,J,K,X,Y
 E  D  Q
 .S @DSIW@(1,0)="-1^Invalid input to LIST^DSIWDPT"
 .Q
 F I=1:1 Q:'$D(DSIWNPUT(I))  D
 .S X=$G(DSIWNPUT(I)) S:$L($P(X,U)) DSIWX($P(X,U))=$P(X,U,2,99)
 .Q
 I $G(DSIWX("FILE")),$L($G(DSIWX("FIELDS"))),$L($G(DSIWX("INDEX"))),$D(DSIWX("PART")) ;T5
 E  D  Q
 .S @DSIW@(1,0)="-1^Missing required parameter in LIST^DSIWDPT"
 .Q
 N DSIWFROM S DSIWFROM=$P($G(DSIWX("FROM")),U)
 I DSIWX("INDEX")="AVFD",DSIWFROM]"" D
 .S DSIWFROM(1)=0
 .S DSIWFROM(2)=DSIWFROM
 .S DSIWFROM=""
 .Q
 I $L($P($G(DSIWX("FROM")),U,2)) S DSIWFROM("IEN")=$P(DSIWX("FROM"),U,2)
 N DSIWPART S DSIWPART=$G(DSIWX("PART"))
 I DSIWX("INDEX")="AVFD",DSIWPART]"" D
 .S DSIWPART(2)=DSIWPART
 .S DSIWPART=""
 .Q
 N DSIWSCR
 I $G(DSIWX("RPL")) S DSIWSCR="I $D(^OR(100.21,""AB"",Y_"";DPT("","_DSIWX("RPL")_"))"
 N DIQUIET,DSIWFM S DIQUIET=1,DSIWFM=$NA(^TMP("DSIWFM",$J)) K @DSIWFM
 S DSIWX("FIELDS")=$G(DSIWX("FIELDS"))_$S($L($G(DSIWX("FIELDS"))):";",1:"")_"IX"
 D LIST^DIC(+DSIWX("FILE"),,DSIWX("FIELDS"),$G(DSIWX("FLAGS")),$G(DSIWX("NUMBER")),.DSIWFROM,.DSIWPART,DSIWX("INDEX"),.DSIWSCR,,DSIWFM,DSIWFM)
 I $D(@DSIWFM@("DIERR")) S @DSIW@(1,0)="-1^LIST~DIC~"_$G(@DSIWFM@("DIERR",1))_"~"_$G(@DSIWFM@("DIERR",1,"TEXT",1)) Q
 ;
 S (I,K)=0 F  S I=$O(@DSIWFM@("DILIST",2,I))  Q:'I  D  ;Transfer results
 .S DSIWY=$G(@DSIWFM@("DILIST",2,I)) ;IEN=DFN
 .S $P(DSIWY,U,2)=$G(@DSIWFM@("DILIST","ID",I,.01)) ;NAME
 .; ^-piece 3 intentionally left blank
 .; ^-piece 4 special for "AVFD" index ->
 .S $P(DSIWY,U,4)=$S($G(DSIWSPC):" ",1:"")_$S(DSIWX("INDEX")="AVFD":$G(@DSIWFM@("DILIST",1,I,1))_"~"_$G(@DSIWFM@("DILIST",1,I,2)),1:$G(@DSIWFM@("DILIST",1,I)))
 .S $P(DSIWY,U,5)=DSIWX("INDEX") ;Index name
 .F J=1:1:$L(DSIWX("FIELDS"),";") S Y=$P(DSIWX("FIELDS"),";",J) D:Y
 ..S $P(DSIWY,U,5+J)=$G(@DSIWFM@("DILIST","ID",I,Y))
 ..Q
 .S K=K+1,@DSIW@(K,0)=DSIWY
 .Q
 K @DSIWFM
 Q
ID(DSIW) ;;[Private] Append ID to default fields
 ; DSIW=Populated return array (by reference)
 ; From specification -
 ; 
 ;                  VFDID = computed:
 ;                          If default Alternate ID exists, then this
 ;                          Else if 1 & only 1 Alt ID exists, then this
 ;                          Else if more than 1 Alt ID exists, then null
 ;                          Else if SSN (.09) exists, then SSN
 ;
 N DFN,I,J,VFDID,X
 S VFDID="" F I=1:1 Q:'$D(DSIW(I))  D
 .S X=$G(DSIW(I)),DFN=+X Q:'(DFN>0)
 .S J=$O(^DPT(DFN,21600,"AX",1,0))
 .I J S VFDID=$P($G(^DPT(DFN,21600,J,0)),U,2) ;DEFAULT Alternate ID
 .; Next is Exactly one Alternate ID -
 .E  I $P($G(^DPT(DFN,21600,0)),U,4)=1 S J=$P(^(0),U,3),VFDID=$P($G(^(J,0)),U,2)
 .E  I $P($G(^DPT(DFN,21600,0)),U,4)>1 S VFDID="" ;More than one Alternate ID
 .E  S VFDID=$P($G(^DPT(DFN,0)),U,9) ;SSN
 .S $P(X,U,DSIWDFLD+5)=VFDID,DSIW(I)=X
 .Q
 Q
