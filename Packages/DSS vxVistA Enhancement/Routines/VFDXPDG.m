VFDXPDG ;DSS/SGM,JG - INSTALLATION ORDER REPORT ; 28 Jan 2011  12:20 AM
 ;;3.1;DSS,INC VXVISTA SUPPORTED;;10 Dec 2012;Build 58
 ;Copyright 1995-2012,Document Storage Systems Inc. All Rights Reserved
 ;
 ;
 ; This routine can only be started from the VFDXPD PATCH menu or by
 ; the API call 'GETMIO^VFDXPDG(n)'.
 ;
 ; A valid Build Group (File #21692.1) IEN must exist in the variable
 ; 'PID' when this program is called.
 ;
 ; When run from the menu, it will create a delimited report and allow
 ; the user to specify an output device, including a HFS location.
 ;
 ; When called as an API, it will create the array specified by the
 ; API's parameters and pass the array back to the caller. No report
 ; is created.
 ;
 ; The program will compile the following temporary global data at the
 ; root: ^TMP("VFDXPDG",$J,
 ;
 ;     "A",IEN) = Build Name
 ;     "B",Build Name) = IEN
 ;     "C",IEN) = "" if from the primary list of builds, or
 ;                "R" if added to list because it's a Required Build
 ;     "DATA",IEN) = NM^PKG^VER^PATCH^SEQ^STAT^MULTI^IN^PRE^POST
 ;     "IN",Multi IEN,Component IEN) = ""
 ;     "IN","B",Component IEN) = Multi IEN
 ;     "MIO",MIO #) = IEN^NM^PKG^VER^PATCH^SEQ^STAT^MULTI^IN^PRE^POST
 ;     "MIO","A",IEN) = MIO #
 ;     "MRG",INDEX) = IEN^NAME^SEQ#
 ;     "MRGA",Build Name,SEQ#,MRG INDEX) = IEN
 ;     "MRGB",PKG,VER,SEQ#,PATCH,MRG INDEX) = IEN
 ;     "REQ",Dependent IEN,Req Build IEN) = ""
 ;     "REQ","B",Req Build IEN,Dependent IEN) = ""
 ;     "SORT",1,PKG,VER,SEQ,IEN) = IEN^Build Name^Flags
 ;            Flag is a string with 0,1 or more of these codes:
 ;              p - Manual Pre-install required
 ;              P - Manual Post-install required
 ;              N - Not an installable Build
 ;              R - Added to build list if it's a required build
 ;     "SORT","ERR",1,PKG,VER,IEN) = This patch SEQ#^Previous SEQ#^Flag
 ;
 ; NOTES
 ; -----
 ; 1. The "MIO" (Master Installation Order) array is the list of Builds
 ;    arranged in the order that they must be installed. The "MIO" is
 ;    a sequential integer starting at '1'. Component Builds in a multi
 ;    Build have the same integer part of the MIO as the multi Build
 ;    plus a fractional part to sequence the components.
 ;      MIO examples:
 ;        Single Build MIO  - 10
 ;        Multi Build  MIO  - 20
 ;        Component 1 MIO   - 20.001
 ;        Component 2 MIO   - 20.002
 ;
 ; 2. The MRG INDEX is a composite identifier that is used to place a
 ;    Build in the correct position in the MRG array in relation to the
 ;    other Builds in the Build Group. The "MRG" array is then used to
 ;    populate the "MIO" array.
 ;
 ; 3. The MRG INDEX structure is composed of four pieces of "^"
 ;    delimited data.
 ;
 ;    "^" Piece 1 - Primary Index
 ;    ---------------------------
 ;    Composed of two pieces of "," delimited data, the MRG Sequence
 ;    Number and the Dependent Build Indicator.
 ;
 ;      "," Piece 1 - The MRG Sequence Number is the actual sequence
 ;                    for the MRG INDEX starting at '1001'.
 ;
 ;                    NOTE: It is also used to 'group' Builds under
 ;                    the same MRG INDEX when there are required &
 ;                    dependent Builds and when indexing Builds in the
 ;                    same Package and Version according to VA's
 ;                    Sequence #.
 ;
 ;      "," Piece 2 - The Dependent Build Indicator defaults to '0' and
 ;                    is set to '1' when a single build has a multi
 ;                    Build as its required Build. Setting it insures
 ;                    that the dependent Build will index after the
 ;                    required multi Build's last component.
 ;
 ;    "^" Piece 2 - Component Build Sequence Number
 ;    ---------------------------------------------
 ;    Used to sequence the indivicual Builds in a multi Build. Starts
 ;    at '000'and increments by '001'.
 ;
 ;    "^" Piece 3 - Required Build Sequence Number
 ;    --------------------------------------------
 ;    Used to sequence all the Builds that are required by a dependent
 ;    Build. Starts at '00' and decrements by '-01'.
 ;
 ;    "^" Piece 4 - Build SEQN Index
 ;    ---------------------------------------------
 ;    Used to sequence Builds of the same Package and Version based on
 ;    a Build's Sequence Number as released by VA. Starts at '000' and
 ;    decrements by '-001' for each Build that has a lower SEQN than
 ;    the target Build.
 ;
 ;    'MRG INDEX' examples
 ;    --------------------
 ;    "1020,0^000^00^000"    MRG sequence #20; not a multi Build;
 ;                           not a Required Build; not a dependent
 ;                           Build; no lower Build Sequence #
 ;
 ;    "1045,0^000^00^000"    MRG sequence #45; multi Build with 2
 ;    "1045,0^001^00^000"    component Builds; not a required Build;
 ;    "1045,0^002^00^000"    not a dependent Build; no lower Build
 ;                           Sequence #
 ;
 ;    "1123,0^000^-01^000"   MRG sequence #123; not a multi Build;
 ;                           1st required Build for MRG sequence #123;
 ;                           no lower Build Sequence #
 ;
 ;    "1158,0^000^-01^000"   MRG sequence #158; multi Build with 2
 ;    "1158,0^000^-02^000"   components; 2 required Builds; no lower
 ;    "1158,0^000^00^000"    Build Sequence #
 ;    "1158,0^001^00^000"
 ;    "1158,0^002^00^000"
 ;
 ;    "1270,0^000^-01^000"   MRG sequence #270; multi Build with 2
 ;    "1270,0^001^-01^000"   components; one dependent Build; no
 ;    "1270,0^002^-01^000"   lower Build Sequence #
 ;    "1270,1^000^00^000"
 ;
 ;    "1300,0^000^-01^-001"  MRG sequence #300; not a multi Build;
 ;                           1st required Build for MRG sequence #300;
 ;                           1st lower Build Sequence for MRG sequence
 ;                           #300
 ;
 ; 4. Component Builds will be inserted in the "MRG" array following
 ;    the multi Builds that contain them. They will all have the same
 ;    MERGE SEQUENCE NUMBER.
 ;
 ; 5. A required Build will be inserted into the "MRG" array immediately
 ;    before the dependent Build that requires it. If the dependent
 ;    Build is a component in a multi Build, the required Build will
 ;    be inserted before the component Build's multi Build. When a
 ;    required Build is a multi Build, the multi and its components
 ;    will be inserted before the dependent Build. A required Build
 ;    will be assigned the same MERGE SEQUENCE NUMBER as its first
 ;    dependent build.
 ;
 ; Build Type Description
 ; ----------------------
 ;      Single Build - Build that is not in a Multi-Build
 ;       Multi Build - Build containing more than 1 Single Build
 ;   Component Build - Single Build contained in a Multi-Build
 ;    Required Build - Build that must be installed before another
 ;                     Single or Multi Build
 ;   Dependent Build - Build that requires another Build be installed
 ;                     before it
 ;
 ;
 ; -------------------------------
 ; | INSTALLATION ORDER LIST API |
 ; -------------------------------
 ;
GETMIO(VFDARY,PID,VFDERR) ; Returns the Builds in Build Group <PID> in
 ;  the local or global array named in VFDARY in the order they
 ;  are to be installed
 ; -To be called only by another VFDXPD* program
 ; -Does not generate a report
 ;  (Menu Option API at tag '9' creates a report)
 ;
 ; INPUTS : VFDARY - Name of local or global array to store data
 ;             PID - IEN of Build Group (File #21692.1)
 ;
 ; OUTPUTS: VFDARY - List of Build IENs in Master Install Order
 ;          VFDERR - Error flag^Error message
 ;
 N API S API=1 D 9 Q
 ;
 ;
 ; -----------------------------
 ; | INSTALLATION ORDER REPORT |
 ; -----------------------------
 ;
 ; Must have a valid Build Group IEN
9 I '$G(PID) D ERR(1) Q
 D 9^VFDXPDG2
 Q
 ;
 ;
 N BATCH,CIEN,DLM,I,LINE,MIONDX,RPT,VFDBATCH,VFDIN,X,Y,Z
 ;
 ; Delimiter for output text line pieces
 ; Can be a character or control character <$C(nn)>
 S DLM="~"
 W:'$G(API) !!?2,"Extracting & sorting data ..."
 S X=$$BATCHNM^VFDXPD0(PID) I +X=-1 D ERR(,"   "_$P(X,U,2)) Q
 S BATCH(0)=X,Y=$$BATCH^VFDXPD0(.VFDBATCH,PID,1) I 'Y D ERR(2) Q
 I $D(VFDBATCH("BAD")) D  Q
 .S Z="",I=0 F  S I=$O(VFDBATCH("BAD",I)) Q:'I  S Z=Z_I_","
 .D ERR(3)
 .Q
 S BATCH=$NA(^TMP("VFDXPDG",$J)) K @BATCH
 ;
 ; Create the Build data & Index "C"
 D GROUP
 ;
 ; Remove any required builds already installed
 D REQCLEAN
 ;
 ; Sort alphabetically
 D SORT
 ;
 ; Check for missing Build Seq #'s
 D MISS1,MISS2
 ;
 ; Merge single, required, and multi Builds and sort into Master
 ; Install Order
 W:'$G(API) !!?2,"Creating Master Install Order list ...",!
 ;
 ; Add the Builds in the SORT list to the Merge INDEX
 D ADDSBLD
 ;
 ; Add Required Builds to the Merge INDEX
 D ADDRBLD
 ;
 ; Move any out of sequence Builds back in sequence in Merge INDEX
 D MOVSEQ
 ;
 ; Sequentially copy the Builds in the Merge INDEX to the MIO list
 D SETMIO
 ;
 ; If this is an API call, copy MIO sorted records to caller's array
 ; and return the data array without creating the report
 I $G(API) D  Q
 .S X=0 F I=0:1 S X=$O(@BATCH@("MIO",X)) Q:'X  S @(VFDARY_"("_X_")")=@BATCH@("MIO",X)
 .S @VFDARY=I
 .Q
 ;
 ; Create the report array
 S (LINE,MIO)=1,Z=""
 D RSET("INSTALLATION ORDER REPORT - Printed: "_$P($$HTE^XLFDT($H),":",1,2))
 D RSET("Build Group: "_$$BATCHNM^VFDXPD0($G(PID)))
 D RSET("INSTALL ORDER"_DLM_"PRE-INSTALL"_DLM_"BUILD NAME  SEQ#"_DLM_"POST-INSTALL"_DLM_"DONE")
 S MIONDX=0 F  S MIONDX=$O(@BATCH@("MIO",MIONDX)) Q:'MIONDX  D
 .S X=$G(@BATCH@("MIO",MIONDX)),Z=MIONDX\1=MIONDX
 .S Y=$S(Z:MIO,1:"-")_DLM_$S($P(X,U,10):"X",1:"")_DLM_$S('Z:" > ",1:"")_$P(X,U,2)
 .S Y=Y_" SEQ# "_$P(X,U,6)_DLM_$S($P(X,U,11):"X",1:"")
 .D RSET(Y) S MIO=MIO+Z
 .Q
 ;
 ; Output the report
 S X="No Master Install Order Builds found"
 D RPT^VFDXPD0(.RPT,,X)
 Q
 ;
 ;
 ; -----------------------
 ; | PRIVATE SUBROUTINES |
 ; -----------------------
 ;
ERR(A,X) ; No processing group ID received
 ;;No Builds found in processing group
 ;;Processing group has bad pointers to file 21692:
 I $G(A) S X=$TR($T(ERR+A),";"," ")_$G(X)
 W !!,X
 Q
 ;
GROUP ; Build Group datasets, convert VFDBATCH() to @BATCH@()
 ; calling SET() or RETRIEVE() will K DATA
 N I,J,K,X,Y,Z,DATA,IEN
 S (K,IEN)=0 F  S IEN=$O(VFDBATCH(IEN)) Q:'IEN  D
 .D SET(IEN) I $D(DATA) S @BATCH@("C",IEN)=""
 .K VFDBATCH(IEN)
 .Q
 K VFDBATCH
 Q
 ;
MISS1 ; Check for any missing SEQ #'s in batch group only
 N I,J,X,Y,Z,ERR,LPKG,LSEQ,LVER,PKG,SEQ,STOP,VER
 S Z=$NA(@BATCH@("SORT",1)),STOP=$TR(Z,")",",")
 S (LPKG,LVER,LSEQ)="",(A,I,J)=0
 F  S Z=$Q(@Z) Q:Z'[STOP  Q:$QS(Z,4)'=1  S X=@Z D
 .S PKG=$QS(Z,5),VER=+$QS(Z,6),SEQ=$QS(Z,7)
 .I PKG'=LPKG S LPKG=PKG,LVER=VER,LSEQ="" Q
 .I VER'=LVER S LVER=VER,LSEQ="" Q
 .; if LSEQ="" then this is first SEQ # for PKG*VER in batch group
 .I LSEQ'="",SEQ'=(LSEQ+1) S ERR(PKG,VER,SEQ)=LSEQ
 .S LSEQ=SEQ
 .Q
 I $D(ERR) M @BATCH@("SORT","ERR",1)=ERR
 Q
 ;
MISS2 ; Check for missing installs prior to earliest SEQ#
 N A,I,J,X,Y,Z,ERR,NM,PKG,SEQ,STOP,VER
 S Z=$NA(@BATCH@("SORT",1))
 S PKG=0 F  S PKG=$O(@Z@(PKG)) Q:PKG=""  D
 .S VER="" F  S VER=$O(@Z@(PKG,VER)) Q:VER=""  D
 ..N VFDTMP S VFDTMP="VFDTMP"
 ..S SEQ=$O(@Z@(PKG,VER,"")) Q:SEQ<2
 ..S J=$O(@Z@(PKG,VER,SEQ,0)) Q:'J
 ..S NM=$P(@Z@(PKG,VER,SEQ,J),U,2) Q:NM'["*"  S NM=$P(NM,"*",1,2)
 ..S Y=$$INSTLIST^VFDXPD0(VFDTMP,NM,2,"AMPQ")
 ..I Y'=(SEQ-1) S A=1+$O(ERR(NM," "),-1),ERR(NM,A)=SEQ_U_Y_U_1
 ..Q
 .Q
 Q
 ;
REQCLEAN ; Delete required Builds if already installed
 N I,J,X,Y,Z,VFDNM,REMOVE,REQ,VFDZ,DEP
 S REQ=0 F  S REQ=$O(@BATCH@("REQ","B",REQ)) Q:'REQ  D
 .S VFDNM=$P(@BATCH@("DATA",REQ),U)
 .Q:$D(@BATCH@("C",REQ))
 .;
 .; If Build is installed, remove from current install list
 .S REMOVE=0 I $$PATCH^XPDUTL(VFDNM) S REMOVE=1
 .I 'REMOVE,$$INSTLIST^VFDXPD0(.VFDZ,VFDNM,1) S REMOVE=1
 .I REMOVE S I=0 D  K @BATCH@("REQ","B",REQ)
 ..F  S I=$O(@BATCH@("REQ","B",REQ,I)) Q:'I  K @BATCH@("REQ",I,REQ)
 ..Q
 .I 'REMOVE S @BATCH@("C",REQ)="R"
 .Q
 ;
 ; Remove Builds from REQ list if:
 ; 1) required Build is the same as dependent Build
 ; 2) component Build's multi Build is component's required Build
 ; 3) two component Builds dependent on the same multi Build
 ;
 ; DEP=dependent Build; REQ=required Build
 S DEP=0 F  S DEP=$O(@BATCH@("REQ",DEP)) Q:'DEP  D
 .Q:I=J!($G(@BATCH@("IN","B",I))=J)
 .I $D(@BATCH@("IN","B",I)) Q:$G(@BATCH@("IN","B",I))=$G(@BATCH@("IN","B",J))
 .S DATA("REQ",J)="",@BATCH@("REQ",I,J)="",@BATCH@("REQ","B",J,I)=""
 .I '$D(@BATCH@("A",J)) S X=J N I,J,DATA D SET(X)
 .Q
 Q
 ;
RETRIEVE(I) ; Get data from @BATCH@("DATA")
 N A,B,C,J,X,Y,Z
 K DATA
 ; X lists the order in which the values are stored
 S X="NM^PKG^VER^PATCH^SEQ^STAT^MULTI^IN^PRE^POST"
 S Z=$G(@BATCH@("DATA",I)) I Z'="" D  Q
 .F J=1:1:10 S Y=$P(X,U,J),DATA(Y)=$P(Z,U,J)
 .I $D(@BATCH@("IN",I)) M DATA("IN")=@BATCH@("IN",I)
 .I $D(@BATCH@("REQ",I)) M DATA("REQ")=@BATCH@("REQ",I)
 .Q
 Q
 ;
SET(I) ; Get specific field values and save to @BATCH@(<xref>)
 N A,B,C,J,X,Y,Z
 K DATA
 I $G(@BATCH@("A",I))'="" D RETRIEVE(I) Q
 S Z=$G(^VFDV(21692,I,0)) Q:Z=""  S A=""
 S X="NM^PKG^VER^PATCH^SEQ^STAT^MULTI^IN^PRE^POST"
 S X(0)="1^5^6^9^7^10^14^15^11^12"
 F J=1:1:10 D
 .S B=$P(X,U,J),C=$P(X(0),U,J),DATA(B)=$P(Z,U,C)
 .S:B="SEQ" DATA(B)=+DATA(B) S A=A_DATA(B)_U
 .Q
 S @BATCH@("A",I)=DATA("NM")
 S @BATCH@("B",DATA("NM"))=I
 S @BATCH@("DATA",I)=A
 S J=DATA("IN") I J>0 D
 .I J'=I S @BATCH@("IN",J,I)="",@BATCH@("IN","B",I)=J Q
 .;
 .; Recursive loop for all components of a multi-Build
 .S J=0 F  S J=$O(^VFDV(21692,"AIN",I,J)) Q:'J  D
 ..S X=J N I,J,DATA D SET(X)
 ..Q
 .Q
 ;
 ; Create the required & dependent Build lists
 ; Do not add a Build to REQ list if:
 ; I=dependent Build; J=required Build
 B:I=142 ;****
 S J=0 F  S J=$O(^VFDV(21692,I,6,J)) Q:'J  D
 .Q:I=J!($G(@BATCH@("IN","B",I))=J)
 .I $D(@BATCH@("IN","B",I)) Q:$G(@BATCH@("IN","B",I))=$G(@BATCH@("IN","B",J))
 .S DATA("REQ",J)="",@BATCH@("REQ",I,J)="",@BATCH@("REQ","B",J,I)=""
 .I '$D(@BATCH@("A",J)) S X=J N I,J,DATA D SET(X)
 .Q
 Q
 ;
SORT ; Alphabetical sort by PKG,VER,SEQ
 N I,J,X,Y,Z,DATA,REQ
 S I=0 F  S I=$O(@BATCH@("C",I)) Q:'I  D
 .S REQ=@BATCH@("C",I)="R"
 .D RETRIEVE(I) S Z=""
 .S:DATA("PRE") Z="p"
 .S:DATA("POST")!(DATA("STAT")=3) Z=Z_$S(DATA("POST")=2:"S",1:"P")
 .S:'DATA("STAT") Z=Z_"N" S:REQ Z=Z_"R"
 .S X=I_U_DATA("NM")_U_Z
 .S @BATCH@("SORT",1,DATA("PKG"),+DATA("VER"),+DATA("SEQ"),I)=X
 .Q
 Q
 ;
ADDSBLD ; Add Builds to merge array in alphabetic order
 N BLDNAM,CIEN,CSEQN,PIEN,PKG,MRGNDX,SEQN,SORT,SORTNODE,VER
 S SORT=$NA(@BATCH@("SORT",1)),SORTNODE=SORT
 F  S SORTNODE=$Q(@SORTNODE) Q:$QS(SORTNODE,4)'=1  D
 .S PIEN=$QS(SORTNODE,8),BLDNAM=$P(@SORTNODE,U,2)
 .S PKG=$QS(SORTNODE,5),VER=$QS(SORTNODE,6),SEQN=$QS(SORTNODE,7)
 .;
 .; Don't add if already in merge array
 .Q:$D(@BATCH@("MRGA",BLDNAM,SEQN))
 .;
 .; Don't add component Builds of a Multi-Build yet
 .Q:$D(@BATCH@("IN","B",PIEN))
 .;
 .; Add Build to merge array and x-refs
 .S MRGNDX=$$MRGGET(2,"") D MRGSAV(MRGNDX,PIEN)
 .;
 .; If Build is a multi-Build, add its component Builds
 .S CIEN=0,CSEQN=1
 .F  S CIEN=$O(@BATCH@("IN",PIEN,CIEN)) Q:'CIEN  D
 ..S X=@BATCH@("DATA",CIEN),BLDNAM=$P(X,U)
 ..S PKG=$P(X,U,2),VER=+$P(X,U,3),SEQN=$P(X,U,5)
 ..;
 ..; Add Build to merge array and x-refs
 ..S MRGNDX=$$MRGIN($P(MRGNDX,U),CSEQN,0,0)
 ..D MRGSAV(MRGNDX,CIEN)
 ..S CSEQN=CSEQN+1
 ..Q
 .Q
 Q
 ;
ADDRBLD ; Insert required Builds in merge array before dependent Builds
 N BLDNAM,DBLDS,DIEN,XDP,MRGNDX,MRGNDXDP,MRGNDXRQ,MRGPRV,NUM,RIEN,RSEQ,SEQN
 S MRG="1029," F  S MRG=$O(@BATCH@("MRG",MRG)) Q:+MRG>1031  W !,MRG ;****
 S RIEN=0 F  S RIEN=$O(@BATCH@("REQ","B",RIEN)) Q:'RIEN  D
 .S X=@BATCH@("DATA",RIEN),BLDNAM=$P(X,U),SEQN=$P(X,U,5)
 .S PKG=$P(X,U,2),VER=+$P(X,U,3),NUM=$P(X,U,4)
 .S MRGNDXRQ=$O(@BATCH@("MRGB",PKG,VER,SEQN,NUM,""))
 .;
 .; Collect the required Build's dependent Builds
 .K DBLDS S (DIEN,I)=0
 .F  S DIEN=$O(@BATCH@("REQ","B",RIEN,DIEN)) Q:'DIEN  D:DIEN'=RIEN
 ..S DBLDS($I(I))=@BATCH@("DATA",DIEN),X=DBLDS(I)
 ..S DBLDS("A",$O(@BATCH@("MRGB",$P(X,U,2),+$P(X,U,3),$P(X,U,5),$P(X,U,4),"")))=I
 ..Q
 .;
 .; Get dependent Build with lowest MRG INDEX
 .S MRGNDX=$O(DBLDS("A","")),MRGNDXDP=MRGNDX,XDP=DBLDS(DBLDS("A",MRGNDX))
 .;
 .; Quit if required Build has lower MRG INDEX than dependent Build
 .Q:$O(@BATCH@("MRGA",BLDNAM,SEQN,0))<MRGNDX
 .;
 .; If dependent Build has other required Builds, increment
 .; required Build seq #
 .S MRGPRV=MRGNDX,$P(MRGPRV,U,3)="00"
 .F RSEQ=0:1 S MRGPRV=$$MRGGET(2,MRGPRV) Q:+MRGPRV'=+MRGNDX
 .;
 .; Create new MRG INDEX for required Build and add to
 .; MRG array & xrefs
 .S MRGNDX=$$MRGIN($P(MRGNDX,U),$P(MRGNDX,U,2),RSEQ,0)
 .D MRGSAV(MRGNDX,RIEN)
 .;
 .; Delete the required Build's original MRG INDEX
 .D MRGDEL(MRGNDXRQ,1)
 .;
 .; If required Build is a multi-Build,insert its component Builds
 .Q:'$D(@BATCH@("IN",RIEN))
 .S CIEN=0,CSEQN=1
 .F  S CIEN=$O(@BATCH@("IN",RIEN,CIEN)) Q:'CIEN  D
 ..S X=@BATCH@("DATA",CIEN),BLDNAM=$P(X,U)
 ..S PKG=$P(X,U,2),VER=+$P(X,U,3),SEQN=$P(X,U,5)
 ..S MRGNDX=$$MRGIN($P(MRGNDX,U),CSEQN,-$P(MRGNDX,U,3),0)
 ..D MRGSAV(MRGNDX,CIEN)
 ..S CSEQN=CSEQN+1
 ..Q
 .;
 .; Set the dependent Build flag in the dependent Build INDEX
 .S MRGNDX=MRGNDXDP,X=$P(MRGNDX,U),$P(X,",",2)=1,$P(MRGNDX,U)=X
 .S DIEN=$P(@BATCH@("MRG",MRGNDXDP),U)
 .D MRGSAV(MRGNDX,DIEN)
 .;
 .; Kill the original MRGNDX
 .D MRGDEL(MRGNDXDP,1)
 .Q
 Q
 ;
MOVSEQ ; Move out-of-sequence Builds back in sequence by creating
 ; a new MRG INDEX for the out-of-sequence Build.
 ;
 ; Important Variables: MRGXRF1,MRGXRF2,MRGNDX1,MRGNDX2,MRGNDXNU
 ;
 ; Before a Build is re-INDEXED:
 ;   MRGXRF1 = Low SEQN; High MRG INDEX Build
 ;   MRGXRF2 = High SEQN; Low MRG INDEX Build
 ;   MRGNDX1 = High MRG INDEX
 ;   MRGNDX2 = Low MRG INDEX
 ;
 ; Move Build with low SEQN to before Build with high SEQN
 ; by creating a new MRG INDEX for the low SEQN Build.
 ;
 ; If Build with lower SEQN is a component Build in a multi Build,
 ; move the component's entire multi Build to before the Build with
 ; higher SEQN.
 ;
 ; If Build with lower SEQN is a multi Build, move the multi Build
 ; and its components to before the Build with the higher SEQN.
 ;
 N BLDNAM,IEN,MRGNDX,MRGNDX1,MRGNDX2,MRGNDXNU,MRGXRF1,MRGXRF2,MULTCOMP,NUM
 N PKG,SEQN,VER,X,Y,Z
 S (MRGXRF1,MRGXRF2)=$NA(@BATCH@("MRGB"))
 F  S MRGXRF1=$Q(@MRGXRF1) Q:$QS(MRGXRF1,3)'="MRGB"  D
 .S MRGXRF2=$Q(@MRGXRF1) Q:$QS(MRGXRF2,3)'="MRGB"
 .;
 .; Quit if Package Prefixes or Versions are different
 .I $QS(MRGXRF1,4)'=$QS(MRGXRF2,4)!($QS(MRGXRF1,5)'=$QS(MRGXRF2,5)) S MRGXRF1=MRGXRF2 Q
 .;
 .; Quit if Build with lower SEQN already has a lower MRG INDEX
 .I $QS(MRGXRF2,8)]$QS(MRGXRF1,8) S MRGXRF1=MRGXRF2 Q
 .;
 .; Set current high (MRGNDX1) & low (MRGNDX2) MRG INDEXES
 .S MRGNDX1=$QS(MRGXRF1,8),MRGNDX2=$QS(MRGXRF2,8),IEN=+@BATCH@("MRG",MRGNDX1)
 .S Y=$D(@BATCH@("IN",IEN)),Z=$D(@BATCH@("IN","B",IEN))
 .;
 .; High SEQN is a single Build
 .I 'Y&'Z D SEQNDX(MRGNDX2,MRGNDX1) S MRGXRF1=MRGXRF2 Q
 .;
 .; High SEQN is a multi Build or a component of a
 .; Multi Build so compile the multi & component Builds
 .; Y = Build to be re-indexed is a multi Build
 .; Z = Build to be re-indexed is a component Build
 .K MULTCOMP
 .I Y S MULTCOMP(1)=IEN_U_$P(@BATCH@("DATA",IEN),U)_U_MRGNDX1
 .E  D
 ..S IEN=@BATCH@("IN","B",IEN),X=@BATCH@("DATA",IEN)
 ..S MULTCOMP(1)=IEN_U_$P(X,U)_U_$QS($Q(@BATCH@("MRGA",$P(X,U))),6)
 ..Q
 .S X=0 F I=2:1 S X=$O(@BATCH@("IN",IEN,X)) Q:'X  D
 ..S MULTCOMP(I)=X_U_$P(@BATCH@("DATA",X),U)
 ..S MRGNDX=$QS($Q(@BATCH@("MRGA",$P(MULTCOMP(I),U,2))),6)
 ..S $P(MULTCOMP(I),U,3)=MRGNDX
 ..Q
 .;
 .; Re-index the multi & comp Builds
 .F I=1:1 Q:'$D(MULTCOMP(I))  D SEQNDX(MRGNDX2,$P(MULTCOMP(I),U,3,6))
 .;
 .; If target Build is a multi, set Dependent Build Indicator in its
 .; component Builds.
 .S IEN=+@BATCH@("MRG",MRGNDX2) I $D(@BATCH@("IN",IEN)) D
 ..K MULTCOMP
 ..S MULTCOMP(1)=IEN_U_$P(@BATCH@("DATA",IEN),U)_U_MRGNDX2
 ..S X=0 F I=2:1 S X=$O(@BATCH@("IN",IEN,X)) Q:'X  D
 ...S MULTCOMP(I)=X_U_$P(@BATCH@("DATA",X),U)
 ...S MRGNDX=$QS($Q(@BATCH@("MRGA",$P(MULTCOMP(I),U,2))),6)
 ...S $P(MULTCOMP(I),U,3)=MRGNDX
 ...Q
 ..F I=1:1 Q:'$D(MULTCOMP(I))  D
 ...S MRGNDX=$P(MULTCOMP(I),U,3,6),X=@BATCH@("MRG",MRGNDX)
 ...D MRGDEL(MRGNDX,"")
 ...S MRGSEQ=$P(MRGNDX,U),$P(MRGSEQ,",",2)=1,$P(MRGNDX,U)=MRGSEQ
 ...D MRGSAV(MRGNDX,+X)
 ...Q
 ..Q
 .Q
 S MRGXRF1=MRGXRF2
 Q
 ;
SETMIO ; Move merged records into Master Install Order sequence
 ; Insert component Builds in a multi-Build after the multi-Build
 N I,MIO,X
 S (MIO,I)=0
 F  S I=$O(@BATCH@("MRG",I)) Q:'I  D
 .S MIO=MIO+($S('+$P(I,U,2):1,1:0))
 .S X=$P(@BATCH@("MRG",I),U)_U_@BATCH@("DATA",$P(@BATCH@("MRG",I),U))
 .S @BATCH@("MIO",MIO_$S(+$P(I,U,2):"."_$P(I,U,2),1:""))=X
 .S @BATCH@("MIO","A",$P(X,U))=MIO_$S(+$P(I,U,2):"."_$P(I,U,2),1:"")
 .Q
 Q
 ;
RSET(X) ; Put report line into array
 S RPT(LINE)=X,LINE=LINE+1 Q
 ;
 ;
 ; ---------------------------
 ; | 'MRG INDEX' Subroutines |
 ; ---------------------------
 ;
SEQNDX(A,B) ; Create new MRG INDEX from MRG INDEX of target Build
 ; with the high SEQN
 ;
 ; A = MRG INDEX of target Build (MRGNDX2)
 ; B = MRG INDEX of Build to be moved before target Build (MRGNDX1)
 ;
 ; Get the lowest iteration of the target Build's MRG INDEX and
 ; decrement the Build SEQN Index
 N IEN,MOVNDX,OLDNDX,TARNDX,X
 S TARNDX=A,OLDNDX=B,X=$$MRGGET(3,TARNDX)
 S MOVNDX=$$MRGIN($P(X,U),$P(X,U,2),-$P(X,U,3),-$P(X,U,4)+1)
 ;
 ; Preserve the component sequence number
 S $P(MOVNDX,U,2)=$P(OLDNDX,U,2)
 ;
 ; Get data for Build to be re-indexed and save new MRG INDEX
 S IEN=+@BATCH@("MRG",OLDNDX)
 S X=@BATCH@("DATA",IEN),PKG=$P(X,U,2),VER=$P(X,U,3)
 S SEQN=$P(X,U,5),BLDNAM=$P(X,U)
 D MRGSAV(MOVNDX,IEN)
 ;
 ; Delete old MRG INDEX and x-refs of Build that was re-indexed.
 D MRGDEL(OLDNDX,"")
 Q
 ;
MRGIN(A,B,C,D) ; Function: Create MRG INDEX from MRG components
 ; INPUTS: A  - MRG INDEX seq #  (max 9999)
 ;         A1 - Dependent Build Indicator
 ;         B  - Component Build seq #  (max 999)
 ;         C  - Required Build seq #  (max 99)
 ;         D  - Patch SEQN Placer #  (max 99)
 ;
 ; OUTPUT: MRG INDEX
 ;        Note: MRG INDEX Dependent Build Indicator initially set
 ;              to "0" (not a Dependent Build).
 ;              Patch SEQN Placer # initially set to "00"
 ;
 ;        Example: If A=1,A1=0,B=1,C=1,D="" output = "1001,0^001^-01^00"
 ;
 N A1
 S A1=$P(A,",",2),A=+A,B=+B,C=+C,D=+D
 S:A<1000 A=A+1000 S:'A1 A1=0 S:'B B="000" S:'C C="00" S:'D D="00"
 S B=$E("000",1,3-$L(B))_B,C=$E("00",1,2-$L(C))_C,D=$E("00",1,2-$L(D))_D
 Q A_","_A1_U_B_U_$S(C>0:"-",1:"")_C_U_$S(D>0:"-",1:"")_D
 ;
MRGOUT(A) ; Function: Convert MRG INDEX to MRG components
 ; INPUT : A - MRG INDEX
 ; OUTPUT: MRG seq #s delimited by "/"
 ;         Example: If A="1001,0^001^-01^00", output = "1001,0/1/1/0"
 N B,C,SLH,X S SLH="/",X=A
 S A=$P(X,U),$P(A,",",2)=+$P(A,",",2),B=+$P(X,U,2),C=-$P(X,U,3),D=-$P(X,U,4)
 Q A_SLH_B_SLH_C_SLH_D
 ;
MRGGET(A,B) ; Function: Get a MRG INDEX
 ; INPUTS: A - Function flag (1,2 or 3)
 ;             1=Get the next MRG INDEX
 ;             2=Get the previous MRG INDEX
 ;             3=Get the lowest MRG INDEX for a MRG Sequence #
 ;         B - a MRG INDEX or null
 ;             If A is 1 and B is valued, get the MRG INDEX that follows
 ;             the value in B.
 ;             If A is 2 and B is valued, get the MRG INDEX that
 ;             precedes the value in B.
 ;             If A is 2 and B is null, get the next unused MRG INDEX
 ;             in the MRG array.
 ;             If A is 3, get lowest MRG INDEX with same MRG Sequence #
 ;             as value in B.
 ;
 ;
 ; OUTPUT: MRG INDEX or null if nothing to return
 ;
 I 'A Q ""
 N X,MRGSEQ
 I A=1!(A=2) S X=B,X=$O(@BATCH@("MRG",X),$S(A=2:-1,1:1)) Q:B'="" X
 I A'=3 Q $$MRGIN($P(X,U)+1,0,0,0)
 S MRGSEQ=+B,X=B
 F  S X=$O(@BATCH@("MRG",X),-1) Q:X=""  I +X'=MRGSEQ S X=$O(@BATCH@("MRG",X)) Q
 Q X
 ;
MRGDEL(A,B) ; Delete MRG INDEX record from MRG array and X-refs
 ;
 ; INPUT: A - MRG INDEX
 ;        B - Delete component Build flag (1=Kill components)
 ;
 N MRGNDX,MRGSEQ,DELCMP,IEN
 S MRGNDX=A,MRGSEQ=$P(MRGNDX,U),DELCMP=+B,IEN=+@BATCH@("MRG",MRGNDX)
 ;
 ; Delete MRG INDEX sent in 'A'. Quit if not a multi Build.
 D MRGKIL(MRGNDX) Q:'$D(@BATCH@("IN",IEN))
 ;
 ; MRG INDEX is for a multi Build, kill component Builds
 Q:'DELCMP
 S MRGNDX=MRGSEQ
 F  S MRGNDX=$O(@BATCH@("MRG",MRGNDX)) Q:+MRGNDX'=+MRGSEQ  D MRGKIL(MRGNDX)
 Q
 ;
 ; Kill MRG record
 ; This subroutine should only be called only by MRGDEL.
MRGKIL(MRGNDX) N BLDNAM,NUM,PKG,SEQN,VER,X
 S X=@BATCH@("MRG",MRGNDX),SEQN=$P(X,U,3)
 S BLDNAM=$P(X,U,2)
 S PKG=$P(BLDNAM,"*"),VER=+$P(BLDNAM,"*",2),NUM=+$P(BLDNAM,"*",3)
 K @BATCH@("MRG",MRGNDX)
 K @BATCH@("MRGA",BLDNAM,SEQN,MRGNDX)
 K @BATCH@("MRGB",PKG,VER,SEQN,+NUM,MRGNDX)
 Q
 ;
MRGSAV(A,B) ; Save a MRG INDEX record and set the "A" & "B" X-refs.
 ;
 ; INPUTS: A - MRG INDEX
 ;         B - IEN of Build
 ;
 N BLDNAM,IEN,MRGNDX,NUM,PKG,SEQN,VER,X
 S MRGNDX=A,IEN=B,X=@BATCH@("DATA",IEN)
 S BLDNAM=$P(X,U),PKG=$P(X,U,2),VER=+$P(X,U,3),SEQN=$P(X,U,5),NUM=$P(X,U,4)
 S @BATCH@("MRG",MRGNDX)=IEN_U_BLDNAM_U_SEQN
 S @BATCH@("MRGA",BLDNAM,SEQN,MRGNDX)=IEN
 S @BATCH@("MRGB",PKG,VER,SEQN,NUM,MRGNDX)=IEN
 Q
