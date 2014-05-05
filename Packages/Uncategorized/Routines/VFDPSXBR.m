VFDPSXBR ;DSS/WLM/SGM - Pharmacy Billing Reports ; 05/08/2013 17:06
 ;;2011.1.2;DSS,INC VXVISTA OPEN SOURCE;;11 Jun 2013;Build 7
 ;Copyright 1995-2013,Document Storage Systems Inc. All Rights Reserved
 ;
 ;  p1 = visit ID         p2 = charge date     p3 = charge code
 ;  p4 = dispense qty     p5 = physician NPI
 ;  p6 = location (or program) name            p7 = physician name
 ;  p8 = iens string for either file 52 or 55
 ;  p9 = patient DFN      p6 = physician duz
 ; p10 = file 44 ien     p11 = drug ien
 ; p12 = med order start date
 ; Report data is stored in @G = ^TMP("VFDPSXBR",$J)
 ;  ----- CHARGE REPORT -----
 ;    @G@(1,j) = p1^p2^p3^p4^p5 ; good records
 ;    @G@(2,j) = p1^p2^p3^p4^p5 ; defective records
 ;    If $G(VFDEBUG) then
 ;      @G@(2,j) = p1^p2^p3^p4^p5^p6^p7 ; defective records
 ;  ----- INDIVIDUAL MEDICATION DISPENSED REPORT -----
 ;  Individual Medications - one record for every entry that is in
 ;  either the good or bad report
 ;    @G@(20,3,j,n) = s1^s2^s3^s4^s5
 ;        j = 0 (for date in good rpt), else 1 (for data in bad rpt)
 ;        n = node in either @G@(1,n) or @G@(2,n)
 ;       s1 = visit ID        s2 = med name    s3 = pgm name
 ;       s4 = qty dispenses   s5 = dispense date
 ;    @G@(3,n) = s1^s2^s3^s4^s5^s6  for n=1,2,3,4,...  where
 ;       move data into this node from @G@(20,3,j,n), first j=0, then
 ;       j=1.  s2...s6 will the the same as s1...s5 @G@(20,3,j,n).
 ;       s1 = "G"_j where j corresponds to the row in the good report
 ;            "D"_j where j corresponds to the row in the defective rpt
 ;  ----- TOTAL DISPENSED MEDICATION REPORT -----
 ;    @G@(4,j) = s1^s2^s3^s4  for j=2,3,4,5  where
 ;       for j=1, s1...s4 are column header names
 ;                Drug^Total Dispensed^Program Name^Program Total
 ;       for j>1, data under the appropriate column
 ;                For each new drug name, the Total Dispensed column
 ;                  will be valued.  For each additional row for that
 ;                  drug name, only columns 1,3,4 will be valued
 ;  ----- IF $G(VFDEBUG) then -----
 ;    @G@(20,1,j) = @G@(1,j)
 ;    @G@(20,1.1,j) = p8^p2^p9^p6^p10^p11^p4^p12^p6^p7
 ;    @G@(20,2,j) = @G@(2,j)
 ;    @G@(20,2.1,j) = p8^p2^p9^p6^p10^p11^p4^p12^p6^p7
 ;    @G@(20,3,j) = @G@(3,j)
 ;    @G@(20,4,j) = @G@(4,j)
 ;  ----- TEMPORARY STORAGE -----
 ;    @G@(99) = temporary storage of Fileman lookups
 ;    @G@(100) = med dispense totals
 ;
 ; @G@(1)   = good charge data
 ; @G@(2)   = defective charge data
 ; @G@(3)   = individual medication dispense report
 ; @G@(4)   = medication dispensed totals report
 ; @G@(1.1) = source data for good charge data
 ; @G@(2.1) = source data for defective charge data
 ; @G@(20)  = debug log if VFDEBUG set or if HFS files not created
 ;            @VFDR@(20,i) = copy of @VFDR@(i) for i = 1,2,3,4,1.1,2.1
 ; @G@(99)  = temp storage for fileman lookup values
 ; @G@(100) = temp storage for totals for med dispense report
 ;
EN ;[Option] - VFD PS BILLING REPORT
 ; Main interactive entry point for generating and exporting
 ; a pharmacy billing report
 ; Scheduled Task entry point also
 ;
 ; Asks date range (default T-1)
 ; Asks inpatient, outpatient, both (default both)
 ; Asks HFS directory if not specified by parameter value
 ; Asks file name (default PSXBR_<xxxxx>_.TXT)
 ; Asks field delimiter (default "^")
 ;
 N X,Y,Z,R,VFDCP,VFDEDT,VFDFILE,VFDHLNOW,VFDK,VFDLIM,VFDLIN,VFDNOW
 N VFDORDT,VFDPATH,VFDR,VFDSDT,VFDSRC,VFDY
 D INIT G:$D(ZTQUEUED) EN2
 ; Date range
 K Z S Z(0)="D",Z("A")="Begin at Date" D  Q:X<1
 . S Z("B")="T-1",X=$$DIR(.Z) S VFDSDT=0 S:X>0 VFDSDT=X
 . Q
 K Z S Z(0)="D",Z("A")="Through Date" D  Q:X<1
 . S Z("B")="T-1",X=$$DIR(.Z) S VFDEDT=0 S:X>0 VFDEDT=X
 . Q
 ; Source
 K Z D  Q:X=-1
 . S Z(0)="S^O:Outpatient only;I:Inpatient only;B:Both"
 . S Z("A")="Include",Z("B")=VFDSRC
 . S X=$$DIR(.Z) S:X="" X=-1 I X'=-1 S VFDSRC=X
 . Q
 ; HFS Directory
 K Z D  Q:X=""
 . S X=$$ASKPATH^VFDXTR(VFDPATH) S:X<0 X="" I X'="" S VFDPATH=X
 . Q
 ; File name
 K Z D  Q:X=""
 . S Z(0)="F^1:245",Z("A")="File name",Z("B")=VFDFILE
 . S X=$$DIR(.Z) S:X<0 X="" I X'="" S VFDFILE=X
 . Q
 ; Delimiter
 K Z D  Q:X=-1
 . S Z(0)="S^U:up-arrow;C:comma;T:tab;O:other"
 . S Z("A")="Field delimiter",Z("B")=VFDLIM
 . S X=$$DIR(.Z) I $S(X="":1,X'?1U:1,1:"UCTO"'[X) S X=-1 Q
 . I "UCT"[X S Y="^,"_$C(9),VFDLIM=$E(Y,$F("UCT",X)-1) Q
 . K Z S Z("A")="ASCII value of delimiter { p[,q] }"
 . S Y="K:X<1!(X>127) X I $D(X) N P S P=$P(X,"","",2) K:P<1!(P>127) X"
 . S Z(0)="F^1:7^K:'(X?1.N.(1"",""1.N) X I $D(X) "_Y
 . S X=$$DIR(.Z) I X'=-1,$L(X) S @("VFDLIM=$C("_X_")")
 . Q
 ; Continue
 W !
EN2 D EN1(VFDSDT,VFDEDT,VFDPATH,VFDFILE,VFDSRC,VFDLIM)
 Q
 ;
DEBUG N VFDEBUG S VFDEBUG=1 G EN
 ;
EN1(VFDSDT,VFDEDT,VFDPATH,VFDFILE,VFDSRC,VFDLIM) ; Non-interactive
 ; Entry point for generating and exporting a pharmacy billing report
 ; All input variables optional
 ; VFDSDT  = Start date (Fileman format) (default = T-1)
 ; VFDEDT  = End date (Fileman format)   (default = T-1)
 ; VFDPATH = HFS Directory for export file (default = parameter)
 ; VFDFILE = File name for export file (See INIT)
 ; VFDSRC  = Code indicating source of data (default = "B")
 ; VFDLIM  = Field delimiter of export file (default = "^")
 N I,J,X,Y,Z,VFDG,VFDMSG,VEXT,VFDR
 N:'$D(VFDEBUG) VFDEBUG S VFDEBUG=$G(VFDEBUG)
 N HDAT S HDAT=$$NOW^XLFDT
 D INIT
 D:"OB"[VFDSRC 52
 D:"IB"[VFDSRC 55
 D MEDTOT
 ;
 ; create HFS files
 S X=VFDFILE I X'["." S VEXT="TXT"
 E  S J=$L(X,"."),VEXT=$P(X,".",J),VFDFILE=$P(X,".",1,J-1)
 S Y=-1 F I=1,2,3,4 I $D(@VFDR@(I)) D
 . I I>1,'VFDEBUG Q
 . S X=VFDFILE S:I>1 X=X_"_"_$P("^Bad^Med^MedTot",U,I) S X=X_"."_VEXT
 . S Y=$$GTF(,X,$NA(@VFDR@(I))) I 'Y D MSG(11):'$D(VFDMSG),MSG(11,I)
 . Q
 ;
 ;M ^SGM(HDAT,"DATA")=@VFDR S ^SGM(HDAT,"OPEN")=Y_U_VFDFILE_"."_VEXT
 ;
 S Z=1 I '$D(VFDMSG),'$G(VFDEBUG) S Z=0 ; controls what is displayed
 K VFDG S I=0 F  S I=$O(@VFDR@(I)) Q:'I  I I'=20 D
 . I I<5 S X=$O(@VFDR@(I,"A"),-1),VFDG(I)=X
 . I I<5,Z K @VFDR@(20,I) M @VFDR@(20,I)=@VFDR@(I)
 . K @VFDR@(I)
 . Q
 ;
 ; totals
 F I=2:1:10 I $S(I>3:1,1:Z) D MSG(I)
 I $D(VFDMSG) W !! S I=0 F  S I=$O(VFDMSG(I)) Q:'I  W !,VFDMSG(I)
 Q
 ;
 ;-----------------------  PRIVATE SUBROUTINES  -----------------------
 ;
52 ;Extract data from File 52
 ; Assume that application variables are pre-validated
 N I,J,X,DATE,IEN,VFDI,VFDT,VFDLST
 ; RELEASE DATE/TIME
 S DATE=VFDSDT-.000001
 F  S DATE=$O(^PSRX("AL",DATE)) Q:DATE>VFDEDT!'DATE  S IEN=0 D
 . F  S IEN=$O(^PSRX("AL",DATE,IEN)) Q:'IEN  S REF="" D
 . . F  S REF=$O(^PSRX("AL",DATE,IEN,REF)) Q:REF=""  D
 . . . D ONERX(DATE,IEN,REF)
 . . . Q
 . . Q
 . Q
 Q
 ;
55 ;Extract data from File 55
 ; Extract data from sub-file 55.0611 DISPENSE LOG
 ; Assume that application variables are pre-validated
 ;
 ; Pharmacy uses direct sets to file data to the DISPENSE LOG and
 ; no whole-file index exists for this multiple.  This subroutine
 ; will read the ^PS(55) global directly.
 ;
 N I,R,X,Y,Z,DATE,DFN,DRUG,HL,ORIEN,QTY,VFDA,VFDAT,VFDDUZ,VFDUD,VFDZ
 ; file is dinum'd to the PATIENT file
 S DFN=0 F  S DFN=$O(^PS(55,DFN)) Q:'DFN  D
 . ; unit dose multiple
 . S VFDUD=0 F  S VFDUD=$O(^PS(55,DFN,5,VFDUD)) Q:'VFDUD  D
 . . S R=$NA(^PS(55,DFN,5,VFDUD)),DATE=VFDSDT-.0000001
 . . ; dispense log multiple
 . . F  S DATE=$O(@R@(11,"B",DATE)) Q:DATE>VFDEDT!'DATE  D
 . . . S VFDA=0 F  S VFDA=$O(@R@(11,"B",DATE,VFDA)) Q:'VFDA  D
 . . . . ; Extract data from DISPENSE LOG sub-entry VFDA
 . . . . S VFDZ=$G(@R@(11,VFDA,0)) Q:'$L(VFDZ)  N R
 . . . . S DRUG=$P(VFDZ,U,2),QTY=$P(VFDZ,U,3),VFDDUZ=$P(VFDZ,U,8)
 . . . . ; convert ward location (42) to hospital location (44)
 . . . . S HL=$$GETX(42,$P(VFDZ,U,7),44,"I")
 . . . . S ORIEN=$$GET1(55.06,VFDUD_","_DFN_",",21,"I")
 . . . . K VFDAT
 . . . . S VFDAT(1)=VFDA_","_VFDUD_","_DFN
 . . . . S VFDAT(2)=DATE,VFDAT(3)=DFN,VFDAT(4)=VFDDUZ,VFDAT(5)=HL
 . . . . S VFDAT(6)=DRUG,VFDAT(7)=QTY,VFDAT(8)=ORIEN
 . . . . D NAMES
 . . . . D ADDREC(.VFDAT)
 . . . . Q
 . . . Q
 . . Q
 . Q
 Q
 ;
 ; add one record or row to the return file
ADDREC(VFDAT) ; add one record or row to the return file
 ; .VFDAT - input values for file
 ;  VFDAT(1) =   iens string for either file 52 or 55
 ;               if original Rx fill then 52 ien
 ;               if refill Rx then refill_ien,52_ien
 ;               if inpat admin, then dispense_ien,u.d.ien,dfn
 ;  VFDAT(2) =   dispense date for drug
 ;  VFDAT(3) =   patient DFN
 ;  VFDAT(4) =   user DUZ who filled drug
 ;  VFDAT(4,0) = user name
 ;  VFDAT(5) =   hospital location
 ;  VFDAT(5,0) = location name
 ;  VFDAT(6) =   drug
 ;  VFDAT(6,0) = drug name
 ;  VFDAT(7) =   quantity dispensed
 ;  VFDAT(8) =   pharmacy order start date
 ; Data into HFS - see notes at top of routine
 ;
 N I,J,R,X,Y,Z,MISS,VFDA
 ; visit number
 S VFDA(1)=$$ENR ;                      visit_id
 S VFDA(2)=$$FMTHLDT(VFDAT(2),1) ;      charge date
 S VFDA(3)=$$GETX(50,VFDAT(6),6) ;      charge code (FSN)
 S VFDA(4)=VFDAT(7) ;                   dispense quantity
 D PROV(VFDAT(4)) ;                     NPI
 ; notes A02, A03
 ; ----- charge reports -----
 S VFDA="",MISS=0
 F I=1:1:5 S X=VFDA(I),$P(VFDA,VFDLIM,I)=X S:X="" MISS=1
 S X="" F I=1:1:8 S $P(X,VFDLIM,I)=VFDAT(I)
 S $P(X,U,9)=VFDAT(5,0)_VFDLIM_VFDAT(4,0)_VFDLIM_VFDAT(6,0)
 I 'MISS D ADD1
 I MISS D ADD2
 ; ----- med dispensed -----
 D ADD3
 S VFDK=1+VFDK I '$D(ZTQUEUED),'(VFDK#100) W "."
 Q
 ;
ADD1 ; good charge report
 S Z=VFDA,J=$$NEXT(1) S @VFDR@(1,J)=Z
 I $G(VFDEBUG) S @VFDR@(1.1,J)=X
 Q
 ;
ADD2 ; bad charge report
 S Z=VFDA I $G(VFDEBUG) S Z=Z_VFDLIM_VFDAT(5,0)_VFDLIM_VFDAT(4,0)
 S J=$$NEXT(2) S @VFDR@(2,J)=Z
 I $G(VFDEBUG) S @VFDR@(2.1,J)=X
 Q
 ;
ADD3 ; pharmacy dispense report
 ; MISS defined in ADDREC
 ; J defined in either ADD1 or ADD2
 N X,Z S Z=VFDLIM
 S X=VFDA(1)_Z_VFDAT(6,0)_Z_VFDAT(5,0)_Z_VFDAT(7)_Z_VFDAT(2)
 S @VFDR@(20,3,MISS,J)=X
 Q
 ;
DIR(DIR) ;
 N X,Y,DIROUT,DIRUT,DTOUT,DUOUT
 W ! D ^DIR I $D(DTOUT)!$D(DUOUT) S Y=-1
 Q Y
 ;
ENR() ; Wrap GET Enrollment RPC call
 ; expects VFDAT()
 N VFDNPUT,VFDRSLT
 S VFDNPUT(1)="PAT^"_VFDAT(3)
 S VFDNPUT(2)="LOC^"_VFDAT(5)
 S VFDNPUT(3)="DT^"_VFDAT(2)
 D GET^VFDDGENR(.VFDRSLT,.VFDNPUT)
 ; If successful, first return record has "REC" keyword
 I $G(VFDRSLT(1))'?1"REC".E,VFDAT(8) D
 . K VFDRSLT S VFDNPUT(3)="DT^"_VFDAT(8)
 . D GET^VFDDGENR(.VFDRSLT,.VFDNPUT)
 . Q
 I $G(VFDRSLT(1))?1"REC".E Q $P(VFDRSLT(1),U,3)
 Q ""
 ;
FMTHLDT(DATE,NOTIME) ;
 I $G(NOTIME) S DATE=$P(DATE,".")
 Q $P($$FMTHL7^XLFDT(DATE),"-")
 ;
GET1(FILE,IENS,FLD,FLG) ; wrapper for $$GET1^DIQ
 N I,J,R,X,Y,Z,DATE,DIERR,DRUG,HL,ORIEN,QTY,VFDER
 Q $$GET1^DIQ(FILE,IENS,FLD,$G(FLG),,"VFDER")
 ;
GETX(VFILE,VIEN,VFLD,VFLG) ;
 ; once get info from FM, store value in tmp global for efficiency
 N I,J,R,X,Y,Z,GNM
 S VFILE=$G(VFILE),VIEN=$G(VIEN),VFLD=$G(VFLD),VFLG=$G(VFLG)
 I '$L(VFILE)!'$L(VIEN)!'$L(VFLD) Q ""
 S GNM=$NA(@VFDR@(99,VFILE,VIEN,VFLD))
 S:'$D(@GNM) @GNM=$$GET1(VFILE,VIEN,VFLD,VFLG)
 Q @GNM
 ;
GTF(PATH,FILE,VFDTX) ; copy data to an export file
 ;  PATH - opt - UNC server-directory name
 ;  FILE - opt - name of file to be created
 ; VFDTX - req - named reference for data @vfdtx@(i)
 ; Return: Boolean 1 or 0
 N I,J,R,X,Y,Z,SUB
 S PATH=$G(PATH),FILE=$G(FILE),VFDTX=$G(VFDTX)
 S:PATH="" PATH=$G(VFDPATH) S:FILE="" FILE=$G(VFDFILE)
 I PATH=""!(FILE="")!(VFDTX="") Q 0
 S SUB=1+$QL(VFDTX)
 Q $$GTF^%ZISH($NA(@VFDTX@(1)),SUB,PATH,FILE)
 ;
MEDTOT ; compute med dispense totals
 ; @VFDR@(100,med_name) = qty dispensed
 ; @VFDR@(100,med_name,pgm_name) = qty dispensed
 N I,J,L,X,Y,Z,LOC,MED,QTY
 K @VFDR@(100)
 ; move data for individual meds dispensed
 S L=0 F J=0,1 S I=0 F  S I=$O(@VFDR@(20,3,J,I)) Q:'I  S X=^(I) D
 . S L=L+1,@VFDR@(3,L)=$E("GD",J+1)_J_U_X
 . Q
 K @VFDR@(20,3)
 ;
 F I=1:1 S X=$G(@VFDR@(3,I)) Q:X=""  D
 . S MED=$P(X,U,3) Q:MED=""
 . S QTY=$P(X,U,5) Q:'QTY
 . S LOC=$P(X,U,4)
 . S @VFDR@(100,MED)=QTY+$G(@VFDR@(100,MED))
 . I $L(LOC) S @VFDR@(100,MED,LOC)=QTY+$G(@VFDR@(100,MED,LOC))
 . Q
 I $D(@VFDR@(100)) D
 . S @VFDR@(4,1)=$$MSG(1),J=1
 . S MED=0 F  S MED=$O(@VFDR@(100,MED)) Q:MED=""  S QTY(0)=^(MED) D
 . . S (Z,LOC)=0
 . . F  S LOC=$O(@VFDR@(100,MED,LOC)) Q:LOC=""  S QTY=^(LOC) D
 . . . S Y=MED_VFDLIM S:'Z Y=Y_QTY(0) S Z=Z+1
 . . . S Y=Y_VFDLIM_LOC_VFDLIM_QTY,J=J+1,@VFDR@(4,J)=Y
 . . . Q
 . . Q
 . Q
 Q
 ;
MSG(N,T) ;
 ;;Drug^Total Dispensed^Program Name^Program Total
 ;;----- The various categories of data can be found at -----
 ;;^TMP("VFDPSXBR",$J,20,n,j) where n=1, 1.1, 2, 2.1, 3, 4
 ;; NODE   # ROWS   DESCRIPTION
 ;;1^Good charge data
 ;;2^Defective charge data
 ;;3^Individual Drugs dispensed
 ;;4^Drug Dispensed Totals
 ;;1.1^Originating data for good charge
 ;;2.1^Originating data for defective charge
 ;;***** Error(s) - Failed To Create Export File(s) *****
 ;;
 N A,X,Y,Z S X=$T(MSG+N),Y=$O(VFDMSG(" "),-1)
 I $Q Q $P(X,";",3)
 S X=$TR(X,";"," ")
 I N>4,N<11 S A=$E(X,4,$L(X)) D
 . S Z=$J($G(VFDG(+A)),6),X="   "_(+A),$E(X,12)=Z_"   "_$P(A,U,2)
 . Q
 I N=11,$G(T) S X="   "_$P($T(MSG+I+4),U,2)
 S Y=Y+1,VFDMSG(Y)=X
 Q
 ;
NAMES ; get .01 field values for certain data
 N X,Y
 S X="",Y=$G(VFDAT(4)) S:Y X=$$GETX(200,Y,.01) S VFDAT(4,0)=X
 S X="",Y=$G(VFDAT(5)) S:Y X=$$GETX(44,Y,.01) S VFDAT(5,0)=X
 S X="",Y=$G(VFDAT(6)) S:Y X=$$GETX(50,Y,.01) S VFDAT(6,0)=X
 Q
 ;
NEXT(N) Q 1+$O(@VFDR@(N," "),-1)
 ;
ONERX(VDT,VIEN,VREF) ;
 ; Extract data from one PRESCRIPTION entry or refill
 N I,X,Y,Z,DATE,DFN,DIERR,DRUG,FLDS,HL,IEN,QTY,VDUZ,VFDAT,VFDER,VFDRX
 N VTMP
 ;
 ; first get info for original fill
 S FLDS="2;4;5;6;7;23;31;32.1;32.2;38;38.1;38.2;39.3;100"
 D GETS^DIQ(52,VIEN_",",FLDS,"I","VTMP","VFDER")
 K X S I=0 M X=VTMP(52,VIEN_",") K VTMP
 F  S I=$O(X(I)) Q:'I  S VFDRX(0,I)=$G(X(I,"I"))
 ;
 ; if refill, get relevant refill info
 I VREF D
 . K DIERR,VFDER
 . S FLDS="1;4;14;15;17;19;20"
 . S I=VREF_","_VIEN_","
 . D GETS^DIQ(52.1,I,FLDS,"I","VTMP","VFDER")
 . K X S I=0 M X=VTMP(52.1,VREF_","_VIEN_",") K VTMP
 . F  S I=$O(X(I)) Q:'I  S VFDRX(VREF,I)=$G(X(I,"I"))
 . Q
 ;
 ; check to see if Rx was released/dispensed
 ; logic extracted from PSODISP1 [PSO RELEASE REPORT]
 ; Rx not released
 I '$S(VREF:VFDRX(VREF,17),1:VFDRX(0,31)) Q
 ; Refill returned to stock
 I VREF,VFDRX(0,14) Q
 ; Original Rx returned to stock and no label reprinted
 I 'VREF,VFDRX(0,32.1),'VFDRX(0,32.2) Q
 ; releasing pharmacist cannot be commercial pharmacy
 S X=VFDRX(0,23) I X,X=VFDCP Q
 I VREF S X=VFDRX(VREF,4) I X,X=VFDCP Q
 ;
 ;   1          2        3       4          5       6     7       8
 ; iens - release d/t - dfn - provider - clinic - drug - qty - CPRSien
 S X=VIEN I VREF S X=VREF_","_X
 S VFDAT(1)=X
 S VFDAT(2)=VDT
 S VFDAT(3)=VFDRX(0,2)
 S Y="",X=VFDRX(0,4) S:VREF Y=VFDRX(VREF,15) S VFDAT(4)=$S('Y:X,1:Y)
 S VFDAT(5)=VFDRX(0,5)
 S VFDAT(6)=VFDRX(0,6)
 S Y="",X=VFDRX(0,7) S:VREF Y=VFDRX(VREF,1) S VFDAT(7)=$S('Y:X,1:Y)
 S VFDAT(8)=$S(VFDRX(0,39.3):VFDRX(0,39.3),1:"")
 D NAMES
 D ADDREC(.VFDAT)
 Q
 ;
PROV(VDUZ) ; get provider ID
 N I,X,Y,Z,DIERR,VFD,VFDER
 S VFDA(5)=$$GETX(200,VDUZ,41.99) ; NPI
 I $P($$SITE^VASITE,U,3)=107 D  ;   UBHC PRV ALT ID
 . ; 11/29/2011 - per Chris Farley
 . I $G(VDUZ)<1 Q
 . S X=$G(@VFDR@(99,200,VDUZ,21600)) I X'="" S VFDA(5)=X Q
 . D GETS^DIQ(200,VDUZ,"21600*",,"VFD","VFDER")
 . S (I,Y)="" K X M X=VFD(200.0216)
 . F  S I=$O(X(I)) Q:'I!Y  I X(I,.05)="PRV",X(I,.02) S Y=X(I,.02) Q
 . S @VFDR@(99,200,VDUZ,21600)=Y
 . S VFDA(5)=Y
 . Q
 Q
 ;
INIT ; initialize variables
 N X,Y,Z,VFDAT,VTMP
 S VFDR=$NA(^TMP("VFDPSXBR",$J)) K @VFDR
 ; get DUZ of vxvista auto-complete pharm
 S VFDCP=+$O(^VA(200,"B","COMMERCIAL,PHARMACY",0))
 S VFDK=0
 S X=$$FMADD^XLFDT(DT,-1)
 S VTMP("ST")=X,VTMP("ET")=X
 S VTMP("P")=$$PWD^%ZISH
 S VTMP("F")=$$FILENAME^VFDVUTL("PSXBR")
 S VTMP("S")="B"
 S VTMP("D")="^"
 ;
 ; start/end dates
 I '$G(VFDSDT)!'$G(VFDEDT) D
 . D GETLST^XPAR(.VFDAT,"SYS","VFD PS BILLING REPORT DATE","I")
 . S X=$G(VFDAT("E")) I '$G(VFDEDT) S VFDEDT=$S(X:X,1:VTMP("ET"))
 . S X=$G(VFDAT("S")) I '$G(VFDSDT) S VFDSDT=$S(X:X,1:VTMP("ST"))
 . Q
 I VFDEDT'["." S VFDEDT=VFDEDT+.25
 ; filename/path
 K VFDAT I '$L($G(VFDPATH))!'$L($G(VFDFILE)) D
 . D GETLST^XPAR(.VFDAT,"SYS","VFD PS BILLING REPORT HFS","I")
 . I $G(VFDPATH)="" S X=$G(VFDAT("D")),VFDPATH=$S(X'="":X,1:VTMP("P"))
 . S X=$G(VFDFILE) I X="",$G(VFDAT("F"))="" S X=VTMP("F")
 . S:X="" X=$$FILENAME^VFDVUTL(VFDAT("F")) S VFDFILE=X
 . Q
 ; type of report
 I '$L($G(VFDSRC)) D
 . S X=$$GET^XPAR("SYS","VFD PS BILLING REPORT INCLUDE")
 . S VFDSRC=$S(X'="":X,1:VTMP("S"))
 . Q
 ; delimiter
 I '$L($G(VFDLIM)) D
 . S X=$$GET^XPAR("SYS","VFD PS BILLING REPORT DELIM")
 . I X'="" S X=$S(X="U":"^",X="C":",",X="T":$C(9),1:"^")
 . S VFDLIM=$S(X'="":X,1:VTMP("D"))
 . Q
 Q
 ;
 ;Change Notes for ADDREC module
 ;A02;11/29/2011;sgm
 ;  sort output by records with good and bad records in separate files
 ;A03;11/29/2011;Chris Farley;Reorder fields as
 ;  Visit_Number  Charge_Date  Charge_Code  Quantity  Physician_ID
 ;A04;4/5/2012;sgm
 ;  added check for enrollment based upon order date if fill date fails
 ;  substantial rewrite to bring routine within DSS programming stds
