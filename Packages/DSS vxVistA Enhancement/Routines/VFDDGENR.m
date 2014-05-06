VFDDGENR ;DSS/LM - VFD ENROLLMENT remote procedures ; 12/01/2011 16:10
 ;;2011.1.2;DSS,INC VXVISTA OPEN SOURCE;;28 Jan 2013;Build 153
 ;Copyright 1995-2013,Document Storage Systems Inc. All Rights Reserved
 ;
 Q
 ;
FILE(VFDRSLT,VFDNPUT) ;Implements remote procedure: VFD DG ENROLLMENT FILE
 ;VFDNPUT=[Required] List of keyword^value pairs.  See REMOTE PROCEDURE file
 ;                   entry for detailed specification.
 ;
 N VFDNDX D NDX(.VFDNDX,.VFDNPUT)
 I $G(VFDNDX("REC"))>0 ;File 21630.001 IEN 
 I  N VFDFDA,VFDI,VFDR S VFDR=$NA(VFDFDA(21630.001,VFDNDX("REC")_","))
 E  S VFDRSLT="-1^Invalid or missing value for keyword REC" Q
 I $D(VFDNDX("PAT")),VFDNDX("PAT")=$$GET1^DIQ(21630.001,VFDNDX("REC"),.02,"I")
 E  S VFDRSLT="-1^Invalid value for keyword PAT" Q
 I $D(VFDNDX("LOC")),VFDNDX("LOC")=$$GET1^DIQ(21630.001,VFDNDX("REC"),.03,"I")
 E  S VFDRSLT="-1^Invalid value for keyword LOC" Q
 ; End QA section - OK to file...
 I $D(VFDNDX("DX","PRI")) S @VFDR@(.05)=$$DX(VFDNDX("DX","PRI"))
 I $D(VFDNDX("DX","ADM")) S @VFDR@(.14)=$$DX(VFDNDX("DX","ADM"))
 I $D(VFDNDX("PROV")),VFDNDX("PROV")>0 S @VFDR@(.15)=VFDNDX("PROV")
 I $D(VFDNDX("VISIT")),VFDNDX("VISIT")>0 S @VFDR@(.16)=VFDNDX("VISIT")
 F VFDI=1:1:8 I $D(VFDNDX("DX",VFDI)) S @VFDR@(VFDI/100+.05)=$$DX(VFDNDX("DX",VFDI))
 F VFDI=.05:.01:.14 I $G(@VFDR@(VFDI))=-1 K @VFDR@(VFDI)
 N VFDERR D FILE^DIE(,$NA(VFDFDA),$NA(VFDERR))
 I $D(VFDERR("DIERR")) D  Q
 .S VFDRSLT="-1^FILE~DIE Error: "_$G(VFDERR("DIERR",1,"TEXT",1))
 .Q
 S VFDRSLT=0
 Q
 ;
GET(VFDRSLT,VFDNPUT) ; RPC: VFD DG ENROLLMENT GET
 ;VFDNPUT=[Required] List of keyword^value pairs.
 ; See REMOTE PROCEDURE file entry for detailed specification
 ; 09/20/2011 - sgm - mod'd to use VFD index on "DE" and other changes
 N I,J,X,Y,Z
 N DATE,DISCH,DFN,DTONLY,LOC,RG,VFDA,VFDLST,VFDNDX,VFDR,VFDS,VFDT
 D NDX(.VFDNDX,.VFDNPUT)
 S DFN=$G(VFDNDX("PAT")),LOC=$G(VFDNDX("LOC")),DATE=$G(VFDNDX("DT"))
 S DTONLY=$G(VFDNDX("DTONLY"))
 S X="-1^Invalid or missing value for keyword PAT or LOC or DT"
 I DFN<1!'LOC!'DATE S VFDRSLT(1)=X Q
 ;
 ; input of data ensures that the combination of dfn,clinic,program_id
 ; is unique for a patient.
 ; Set VFDA=record match and Set DISCH to -1 or null or FMdate
 S (VFDT,VFDA)=0,DISCH=-1,RG=$NA(^VFD(21630.001,"AC",DFN,LOC))
 F  S VFDT=$O(@RG@(VFDT)) Q:'VFDT!(VFDT>DATE)  D  Q:VFDA
 .S I=0 F  S I=$O(@RG@(VFDT,I)) Q:'I  D  Q:VFDA
 ..S DISCH=$$DDT(I)
 ..I $S(DISCH<1:1,1:DISCH'<DATE) S VFDA=I
 ..E  S DISCH=-1
 ..Q
 .Q
 ;
 ; if no record found above, if DTONLY then look for matches
 ; there must be one and only one enrollment for that date for a hit
 I 'VFDA,DTONLY?7N D
 .S J=0,X=DTONLY-.1,X=$O(@RG@(X)) Q:'X  Q:X\1'=DTONLY
 .S I=$O(@RG@(X,0)) Q:'I  I $O(@RG@(X,I)) Q
 .S J=I,X=$O(@RG@(X)) I X\1=DTONLY Q
 .S VFDA=J,DISCH=$$DDT(J)
 .Q
 I 'VFDA S VFDRSLT(1)="-1^No qualified enrollment found" Q
 ;
 ; Get data for entry
 D GETS^DIQ(21630.001,VFDA_",",".01:.16","I",$NA(VFDS))
 S VFDR=$NA(VFDS(21630.001,VFDA_","))
 S VFDRSLT(1)="REC^"_VFDA_U_@VFDR@(.01,"I")
 S VFDRSLT(2)="PAT^"_@VFDR@(.02,"I")
 S VFDRSLT(3)="LOC^"_@VFDR@(.03,"I")
 I DISCH>0 S VFDRSLT(4)="STAT^D^"_DISCH
 E  S VFDRSLT(4)="STAT^A^"_@VFDR@(.04,"I")
 S VFDRSLT(5)="PROV^"_@VFDR@(.15,"I")
 S VFDRSLT(6)="VISIT^"_@VFDR@(.16,"I")
 ; $$XDX will append ICD9 code and short description to each diagnosis
 F I=.05:.01:.14 D
 .S X=@VFDR@(I,"I") I X S X=$$XDX(X)
 .I I=.14 S VFDRSLT(7)="DX^ADM^"_X Q
 .I I=.05 S VFDRSLT(8)="DX^PRI^"_X Q
 .S Y=I*100-5,VFDRSLT(8+Y)="DX^"_Y_U_X
 .Q
 Q
 ;
DDT(VFDREC) ; Return discharge date.time (if valued)
 ; for qualifying VFD PATIENT ENROLLMENT entry.
 ; VFDREC - req - File 21630.001 IEN
 ; Return discharge date or the empty string (no error return)
 ;
 I $G(VFDREC)<1 Q ""
 N I,J,X,Y,Z,DFN,LOC
 ; use same logic as in computed field 21630.001,9.01
 S Z=$G(^VFD(21630.001,VFDREC,0)),DFN=$P(Z,U,2),LOC=$P(Z,U,3)
 ; dfn,clinic,pgmid should be a unique combination
 S (I,Y)=0 F  S I=$O(^DPT(DFN,"DE","AVFDPGM",LOC,VFDREC,I)) Q:'I  D
 .S J=$O(^DPT(DFN,"DE","AVFDPGM",LOC,VFDREC,I,0)) Q:'J
 .S Y=$P(^DPT(DFN,"DE",I,1,J,0),U,3)
 .Q
 Q Y
 ;
DX(VFDDX) ; Convert to ICD DIAGNOSIS IEN
 ; VFDDX - req - Either ICD DIAGNOSIS IEN or EXPRESSIONS IEN_"X"
 ;
 S VFDDX=$$UP^XLFSTR($G(VFDDX))
 Q $S(VFDDX?.E1"X":+$$ICDDX^ICDCODE($$ICDONE^LEXU($TR(VFDDX,"X"),DT)),1:VFDDX)
 ;
XDX(VFDDX) ; Append diagnosis code and short description to DX IEN
 ; VFDDX - req - ICD DIAGNOSIS IEN
 ;
 N I,X,VFDZ S VFDZ=$$ICDDX^ICDCODE($G(VFDDX))
 Q VFDDX_U_$P(VFDZ,U,2)_U_$P(VFDZ,U,4)
 ;
NDX(VFDNDX,VFDSRC) ; Construct index from source
 ;VFDSRC - req - passed by reference [.VFDSRC]
 ;  List of keyword^value pairs to be indexed
 ;  Source format is defined in the VFD DG ENROLLMENT remote procedures
 ;  returns      VFDSRC(keyword)=value
 ;               VFDSRC(
 ;    for diags, VFDSRC("DX",xxx)=yyy
 ;
 N I,T,X S I=0 F  S I=$O(VFDSRC(I)) Q:'I  D
 .S X=$P(VFDSRC(I),U) Q:'$L(X)
 .I X="DX" S T=$P(VFDSRC(I),U,2) Q:'$L(T)  S VFDNDX(X,T)=$P(VFDSRC(I),U,3) Q
 .S VFDNDX(X)=$P(VFDSRC(I),U,2)
 .Q
 Q
 ;
 ; For ATSET and ATKILL always return
 ;  VFDATA(n) = p1^p2^p3  where n=1,2,3,4,...
 ;     p1 = key word:  IEN or DATE or DUZ or field number .01 - .16
 ;     p2 = for IEN, pointer value to file 21630.001
 ;          for DATE, FM date.time when data was filed
 ;          for DUZ, user id who filed the data
 ;          for field number, old internal value
 ;     p3 = only defined for field number and is new internal value
 ;
 ; The AT index only records the fields whose values changed during a
 ; filing event.  Interactive DIE does not group all fields edited
 ; under a single node since it will file data as it goes along.
 ; The actual changes will be recorded in the AUDIT file.
 ;
ATSET ; called from SET logic on AT new style xref on file 21630.001
 N I,J,Y,Z,NOW,STR,VFDATA
 S VFDATA(1)="IEN^"_DA
 S VFDATA(2)="DUZ^"_$G(DUZ)
 S J=3,STR="DUZ;"_DUZ
 F I=1:1:16 I $G(X1(I))'=$G(X2(I)) D
 .S Z=(I/100)_U_$G(X1(I))_U_$G(X2(I))
 .S VFDATA(I/100)=Z,STR=STR_U_$TR(Z,U,";")
 .Q
 Q:$P(STR,U,2)=""
 S Z=$NA(^VFD(21630.001,"AT",DA))
 L +@Z
 F  S NOW=$$NOW^XLFDT I '$D(@Z@("A",NOW)) S ^(NOW)=STR Q
 L -@Z
 S VFDATA(3)="DATE^"_NOW
 D X^VFDXTX("FILE 21630.001 UPDATE")
 Q
 ;
ATKILL ; called from KILL logic on AT new style xref on file 21630.001
 Q
