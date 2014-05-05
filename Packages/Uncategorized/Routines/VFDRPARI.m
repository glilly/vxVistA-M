VFDRPARI ;DSS\MBS - CPOE Utilities ; May 30, 2011 22:30
 ;;2011.1.2;DSS,INC VXVISTA OPEN SOURCE;;28 Jan 2013;Build 153
 ;Copyright 1995-2013,Document Storage Systems Inc. All Rights Reserved
 Q
 ;
CHLEN ;Entry point for LDL/Total Cholesterol report
 N A,I,L,N,P,S,T,EDT,RTN,SP,STDT
 S (N,A,S,L,T,P)="",SP=" "
 D GETDATE^VFDRPARC K DIR Q:$D(DIRUT)
 S RTN=$$CHLSRPT(STDT,EDT)
 D CSVOUT("ArraChlRpt.csv",RTN,U)
 S $P(BLNK," ",80)=""
 S FMT="!,$E(N_BLNK,1,20)_SP_$E(A_BLNK,1,3)_SP_$E(S_BLNK,1,6)_SP_$E(P_BLNK,1,7)_SP_$E(L_BLNK,1,3)_SP_$E(T_BLNK,1,3)"
 W !!
 S I=""  F  S I=$O(@RTN@(I)) Q:I=""  D
 . S N=$P(@RTN@(I),U,1),A=$P(@RTN@(I),U,2),S=$P(@RTN@(I),U,3)
 . S P=$P(@RTN@(I),U,4),L=$P(@RTN@(I),U,5),T=$P(@RTN@(I),U,6)
 . W @FMT
 Q
 ;
ASTHEN ;Entry point for Asthma/Advair Report
 N A,I,M,N,P,S,EDT,RTN,SP,STDT
 S (N,A,S,P,M)="",SP=" "
 D GETDATE^VFDRPARC K DIR Q:$D(DIRUT)
 S RTN=$$ASTHRPT(STDT,EDT)
 D CSVOUT("ArraAsthAdvRpt.csv",RTN,U)
 S $P(BLNK," ",80)=""
 S FMT="!,$E(N_BLNK,1,20)_SP_$E(A_BLNK,1,3)_SP_$E(S_BLNK,1,6)_SP_$E(P_BLNK,1,7)_SP_$E(M_BLNK,1,30)"
 W !!
 S I=""  F  S I=$O(@RTN@(I)) Q:I=""  D
 . S N=$P(@RTN@(I),U,1),A=$P(@RTN@(I),U,2),S=$P(@RTN@(I),U,3)
 . S P=$P(@RTN@(I),U,4),M=$P(@RTN@(I),U,5)
 . W @FMT
 Q
 ;
CHLSRPT(STDT,EDT) ; 179.302 (i) LDL/total Cholesterol report
 N DFNS,I,NAME,AGE,SEX,LDL,TOTAL,PRBLM,IEN,RET,ICDLST
 S (DFNS,I,IEN)=""
 S RET=$NA(^TMP("VFDRPARI",$J))
 K @RET
 S @RET@(0)="Name^Age^Sex^Problem^LDL^Total Cholesterol"
 ;Get list of ICDs to look for
 S ICDLST=$$GETICDS("401.0","405.99")
 S DFNS=$$PATPBLMS(ICDLST)
 S I=0 F  S I=$O(@DFNS@(I)) Q:'I  D
 . S (NAME,AGE,SEX,PRBLM,LDL,TOTAL)=""
 . S NAME=$$GET1^DIQ(2,I_",",.01)
 . S AGE=$$GET1^DIQ(2,I_",",.033)
 . S SEX=$$GET1^DIQ(2,I_",",.02)
 . S PRBLM=$G(@DFNS@(I))
 . S LDL=$$GETLDL(I,STDT,EDT)
 . S TOTAL=$$GETTOT(I,STDT,EDT)
 . I AGE'<18,+PRBLM,+LDL,+TOTAL D
 . . S $P(@RET@(I),U,1)=NAME
 . . S $P(@RET@(I),U,2)=AGE
 . . S $P(@RET@(I),U,3)=SEX
 . . S $P(@RET@(I),U,4)=$$GET1^DIQ(80,PRBLM_",",.01)
 . . S $P(@RET@(I),U,5)=LDL
 . . S $P(@RET@(I),U,6)=TOTAL
 K @DFNS,@ICDLST
 Q RET
 ;
LSTDFN(OUT) ; Get a list of patients for the report
 ;INPUT
 ; OUT - output variable, passed by reference (will store name of
 ;       array data is in)
 N LSTIFN,RAW,I,PIECE
 S OUT=$NA(^TMP("VFDRPARI",$J,"LSTDFN"))
 S RAW=$NA(^TMP("VFDRPARI",$J,"LSTDFNRAW"))
 K @OUT,@RAW
 S LSTIFN=$$FIND1^DIC(810.5,,"QX","OVER 18 HEART FAILURE AVANDIA ABN LIPIDS")
 I '+LSTIFN S @OUT@(0)="-1^Error finding list" Q
 D LIST^DIC(810.53,","_LSTIFN_",","@;.01","IQP",,,,,,,RAW)
 S RAW=$NA(@RAW@("DILIST"))
 S @OUT@(0)=+$G(@RAW@(0))
 I '@OUT@(0) K @RAW Q
 S PIECE=0
 F I=1:1:$L(@RAW@(0,"MAP"),U) D  Q:+PIECE
 . I $P(@RAW@(0,"MAP"),U,I)=".01I" S PIECE=I
 F I=1:1:+@OUT@(0) D
 . S @OUT@(I)=$P(@RAW@(I,0),U,PIECE)
 K @RAW
 Q
GETPRBLM(DFN,FLTR) ;Returns the first active problem for the patient
 N PRBLST,PRI,ICD,FND
 Q:$G(DFN)="" 0
 S FLTR=$G(FLTR),FND=0
 S PRBLST=$NA(^PXRMINDX(9000011,"PSPI",DFN,"A"))
 S PRI="" F  S PRI=$O(@PRBLST@(PRI)) Q:PRI=""  D  Q:FND
 . I FLTR="" S ICD=$O(@PRBLST@(PRI,"")),FND=1 Q
 . S ICD=""
 . F  S ICD=$O(@PRBLST@(PRI,ICD)) Q:ICD=""  I $D(@FLTR@(ICD))>0 S FND=1 Q
 Q $S(ICD'="":$$GET1^DIQ(80,ICD_",",.01),1:"")
 ;
GETLDL(DFN,STDT,EDT) ;Returns the first lab test result in date range for patient with LDL>100
 N LRLST,CUR,LRSUBS,LRREF,LDLVAL
 ;Start and end dates are inclusive
 S STDT=STDT-.1,EDT=EDT+.9
 S LRLST=$NA(^PXRMINDX(63,"PI",DFN,901)),CUR=$NA(@LRLST@(EDT))
 S LDLVAL=0
 F  S CUR=$Q(@CUR,-1) Q:CUR=""  Q:$QS(CUR,4)'=LRLST  Q:$QS(CUR,5)<STDT  D  Q:LDLVAL>100
 . S LRSUBS=$QS(CUR,6) Q:LRSUBS=""
 . S LRSUBS=$TR(LRSUBS,";",",")
 . S $P(LRSUBS,",",2)=""""_$P(LRSUBS,",",2)_""""
 . S LRREF="^LR("_LRSUBS_")"
 . S LDLVAL=+$G(@LRREF)
 I LDLVAL'>100 S LDLVAL=0
 Q LDLVAL
 ;
GETTOT(DFN,STDT,EDT) ;Returns the first lab test result in date range for patient with total cholesterol > 200
 ; This is pretty much an exact copy of GETLDL; should be reworked to be generic
 N LRLST,CUR,LRSUBS,LRREF,VAL
 ;Start and end dates are inclusive
 S STDT=STDT-.1,EDT=EDT+.9
 S LRLST=$NA(^PXRMINDX(63,"PI",DFN,183)),CUR=$NA(@LRLST@(EDT))
 S VAL=0
 F  S CUR=$Q(@CUR,-1) Q:CUR=""  Q:$QS(CUR,4)'=LRLST  Q:$QS(CUR,5)<STDT  D  Q:VAL>200
 . S LRSUBS=$QS(CUR,6) Q:LRSUBS=""
 . S LRSUBS=$TR(LRSUBS,";",",")
 . S $P(LRSUBS,",",2)=""""_$P(LRSUBS,",",2)_""""
 . S LRREF="^LR("_LRSUBS_")"
 . S VAL=+$G(@LRREF)
 I VAL'>200 S VAL=0
 Q VAL
 ;
CSVOUT(FILEN,DATA,DEL,OUTDEL,DTS,PATH) ;Write data to CSV file
 N NPIECES,I,J,OUTSTR
 S NPIECES=$L($G(@DATA@(0)),DEL)
 I $G(OUTDEL)="" S OUTDEL=","
 I $G(PATH)="" S PATH=$$DEFDIR^%ZISH("")
 D OPEN^%ZISH("OUTFILE",PATH,FILEN,"W")
 I POP W !,"Error opening host file "_PATH_FILEN Q
 U IO S I="" F  S I=$O(@DATA@(I)) Q:I=""  D
 . S OUTSTR=$G(@DATA@(I))
 . I $D(DTS),I>0 S OUTSTR=$$CVTDTS(OUTSTR,DEL,.DTS)
 . I OUTDEL="," F J=1:1:$L(OUTSTR,DEL) I $P(OUTSTR,DEL,J)["," S $P(OUTSTR,DEL,J)=""""_$P(OUTSTR,DEL,J)_""""
 . S OUTSTR=$TR(OUTSTR,DEL,OUTDEL)
 . W OUTSTR,!
 D CLOSE^%ZISH("OUTFILE")
 Q
 ;
CVTDTS(STR,DEL,DTS) ;Convert the date pieces defined by DTS array into Delphi
 N I,DLPHIDT,INDT
 I $D(DTS)<10 Q "ERR: $$CVTDTS Requires DTS Parameter"
 I STR="" Q ""
 I $G(DEL)="" S DEL=U
 S I="" F  S I=$O(DTS(I))  Q:I=""  D
 . S INDT=$P(STR,DEL,DTS(I)) Q:'INDT
 . K DLPHIDT D CNVT^VFDCDT(.DLPHIDT,$P(STR,DEL,DTS(I)),"F","D",,"S")
 . S $P(STR,DEL,DTS(I))=DLPHIDT
 Q STR
 ;
GETICDS(START,END) ;Get list of IENs for all ICDs in a range
 N INDX,I,RET,IFN
 S RET=$NA(^TMP("VFDRPARI",$J,"GETICDS"))
 S INDX=$NA(^ICD9("AB")),END=END_" "
 S I=START F  S I=$O(@INDX@(I)) Q:I]]END  D
 . S IFN="" F  S IFN=$O(@INDX@(I,IFN)) Q:IFN=""  D
 . . S @RET@(IFN)=""
 Q RET
 ;
ASTHRPT(STDT,EDT) ;Asthma Med Report
 N ICDLST,MEDDFNS,PRBDFNS,I,PBLM,RET,DFN
 S RET=$NA(^TMP("VFDRPARI",$J)) K @RET
 S @RET@(0)="Name^Age^Sex^Problem^Medicine"
 ;Get list of ICDs to look for
 S ICDLST=$$GETICDS("493.00","493.91")
 ;Get patients with the med we're looking for
 S MEDDFNS=$$PATMEDS(STDT,EDT)
 ;Get patients with one of the problems we're looking for
 S PRBDFNS=$$PATPBLMS(ICDLST,STDT,EDT)
 ;For each patient in the med list...
 S DFN="" F  S DFN=$O(@MEDDFNS@(DFN)) Q:DFN=""  D
 . ;Add to result list
 . S $P(@RET@(DFN),U,1)=$$GET1^DIQ(2,DFN_",",.01)  ;NAME
 . S $P(@RET@(DFN),U,2)=$$GET1^DIQ(2,DFN_",",.033) ;AGE
 . S $P(@RET@(DFN),U,3)=$$GET1^DIQ(2,DFN_",",.02)  ;SEX
 . S $P(@RET@(DFN),U,5)=@MEDDFNS@(DFN)             ;MEDICINE
 ;For each patient in the problem list...
 S DFN="" F  S DFN=$O(@PRBDFNS@(DFN)) Q:DFN=""  D
 . ;Add/update to result list
 . I '$D(@RET@(DFN)) D
 . . S $P(@RET@(DFN),U,1)=$$GET1^DIQ(2,DFN_",",.01)           ;NAME
 . . S $P(@RET@(DFN),U,2)=$$GET1^DIQ(2,DFN_",",.033)          ;AGE
 . . S $P(@RET@(DFN),U,3)=$$GET1^DIQ(2,DFN_",",.02)           ;SEX
 . S $P(@RET@(DFN),U,4)=$$GET1^DIQ(80,@PRBDFNS@(DFN)_",",.01) ;PROBLEM
 K @ICDLST,@MEDDFNS,@PRBDFNS
 Q RET
 ;
PATMEDS(STDT,EDT) ;Get a list of patients with specified medication
 N INDX,RET
 S RET=$NA(^TMP("VFDRPARI",$J,"PATMEDS")) K @RET
 S INDX=$NA(^PXRMINDX("55NVA","IP",76))
 D PATMEDS1(RET,INDX,"$$NVADRG",STDT,EDT)
 S INDX=$NA(^PXRMINDX(55,"IP",87))
 D PATMEDS1(RET,INDX,"$$INDRG",STDT,EDT)
 S INDX=$NA(^PXRMINDX(52,"IP",87))
 D PATMEDS1(RET,INDX,"$$OUTDRG",STDT,EDT)
 Q RET
 ;
PATMEDS1(RET,INDX,SRN,STDT,EDT) ;Supports PATMEDS
 N CUR,DFN,MEDINFO,CALL
 I $G(RET)="" Q
 S STDT=$S($G(STDT)="":0,1:STDT-.1)
 S EDT=$S($G(EDT)="":9999999,1:EDT+.9)
 S CUR=INDX
 F  S CUR=$Q(@CUR) Q:CUR=""  Q:$QS(CUR,3)'=INDX  D
 . Q:STDT<$QS(CUR,5)  Q:EDT>$QS(CUR,5)
 . S DFN=$QS(CUR,4) Q:'+DFN
 . S CALL="S MEDINFO="_SRN_"($QS(CUR,7))"
 . X CALL
 . I MEDINFO'="" S @RET@(DFN)=MEDINFO
 . Q
 Q
 ;
PATPBLMS(ICDLST,STDT,EDT) ;Get a list of patients with specified problems
 N J,DATE,DFN,ICD,INDX,RET
 S STDT=$S($G(STDT)="":0,1:STDT-.1)
 S EDT=$S($G(EDT)="":9999999,1:EDT+.9)
 S RET=$NA(^TMP("VFDRPARI",$J,"PATPBLMS")) K @RET
 I $G(ICDLST)="" Q RET
 S ICD="" F  S ICD=$O(@ICDLST@(ICD)) Q:ICD=""  D
 . S INDX=$NA(^PXRMINDX(9000011,"ISPP",ICD,"A"))
 . S J="" F  S J=$O(@INDX@(J)) Q:J=""  D
 . . S DFN="" F  S DFN=$O(@INDX@(J,DFN)) Q:DFN=""  S DATE=STDT D
 . . . F  S DATE=$O(@INDX@(J,DFN,DATE)) Q:DATE=""!(DATE>EDT)  D
 . . . . I '$D(@RET@(DFN)) S @RET@(DFN)=ICD
 Q RET
 ;
NVADRG(DTL) ;Get the name of the drug indicated in the detail
 N DATA,RET
 S RET="" I $G(DTL)="" Q RET
 D NVA^PSOPXRM1(DTL,.DATA)
 I $G(DATA("STATUS"))="ACTIVE" S RET=$G(DATA("ORDERABLE ITEM"))
 Q RET
 ;
OUTDRG(DTL) ;Get the name of the outpatient drug
 N DATA,RET
 S RET="" I $G(DTL)="" Q RET
 D PSRX^PSOPXRM1(DTL,.DATA)
 I $D(DATA),$G(DATA("STATUS"))=0 S RET=$$GET1^DIQ(52,$P(DTL,";")_",",6)
 Q RET
 ;
INDRG(DTL) ;Get the name of the inpatient drug
 N DATA,RET
 S RET="" I $G(DTL)="" Q RET
 D OEL^PSJPXRM1(DTL,.DATA)
 I $D(DATA),$G(DATA("STAT"))="ACTIVE" S RET=$$GET1^DIQ(50,$G(DATA("OI"))_",",.01)
 Q RET
 ;
SNOLST(RET,STDT,EDT,FILEN,PATH) ;RPC to return snomed codes
 N SCRN,MSG,DATA,I,RAW,INTDT,DTS
 I $G(FILEN)="" S FILEN="PT_SNOMED.CSV"
 I $G(PATH)="" S PATH=$$DEFDIR^%ZISH("")
 S DATA=$NA(^TMP("VFDRPARI",$J)) K @DATA
 S RAW=$$LSTSTUFF(STDT,EDT,21640.01)
 S I=1 F  S I=$O(@RAW@(I)) Q:'+I  D
 . S @DATA@(I)=$P($G(@RAW@(I,0)),U,2,4)
 . D DT^DILF("T",$P(@DATA@(I),U,3),.INTDT)
 . S $P(@DATA@(I),U,3)=INTDT
 S @DATA@(0)="SNOMED_CODE^PT_IEN^VISIT_DT"
 S DTS(0)=3
 D CSVOUT(FILEN,DATA,U,U,.DTS,PATH)
 K @DATA,@RAW
 S RET="1^File "_FILEN_" written."
 Q
 ;
HFLST(RET,STDT,EDT,FILEN,PATH) ;RPC to return health factors
 N SCRN,MSG,DATA,I,RAW,INTDT,DTS
 I $G(FILEN)="" S FILEN="PT_HFACTOR.CSV"
 I $G(PATH)="" S PATH=$$DEFDIR^%ZISH("")
 S DATA=$NA(^TMP("VFDRPARI",$J))
 S RAW=$$LSTSTUFF(STDT,EDT,9000010.23)
 S I=1 F  S I=$O(@RAW@(I)) Q:'+I  D
 . S @DATA@(I)=$P($G(@RAW@(I,0)),U,2,4)
 . D DT^DILF("T",$P(@DATA@(I),U,3),.INTDT)
 . S $P(@DATA@(I),U,3)=INTDT
 S @DATA@(0)="HF_NAME^PT_IEN^VISIT_DT"
 S DTS(0)=3
 D CSVOUT(FILEN,DATA,U,U,.DTS,PATH)
 K @DATA,@RAW
 S RET="1^File "_FILEN_" written."
 Q
 ;
LSTSTUFF(STDT,EDT,FILE) ;Common code for getting the first 3 fields from files involving field .03 being a visit IFN.
 S STDT=STDT-.1,EDT=EDT+.9
 S SCRN="S II=$P(^(0),U,3) I +II>0 S XX=$$GET1^DIQ(9000010,$P(^(0),U,3)_"","",.01,""I"") I (XX>STDT)&(XX<EDT)"
 D LIST^DIC(FILE,,"@;.01;.02I;.03","P",,,,,SCRN)
 I $D(DIERR) D  Q RET
 . D MSG^DIALOG("AE",.MSG)
 . S RET="-1^ERROR: "_MSG($O(MSG("")))
 Q $NA(^TMP("DILIST",$J))
 ;
LABLST(RET,STDT,EDT,FILEN,PATH) ;Get lab results in a date/time
 N I,X,Y,Z,CUR,DAT0,DATA,DATLOC,DFN,DTRSLT,DTS,FLAG,INDX,LAB,LOINC
 N RSLT,STOP
 S X=$$DATE^VFDRPARU($G(STDT),$G(EDT)) I +X=-1 S RET=X Q
 S STDT=+X,EDT=$P(X,U,2)
 I $G(FILEN)="" S FILEN="PT_LAB.CSV"
 I $G(PATH)="" S PATH=$$DEFDIR^%ZISH("")
 S DATA=$NA(^TMP("VFDRPARI",$J)) K @DATA
 S INDX=$NA(^PXRMINDX(63,"PI")),CUR=INDX,STOP=$TR(INDX,")",",")
 S I=1
 F  S CUR=$Q(@CUR) Q:CUR'[STOP  D
 . Q:$QS(CUR,5)<STDT  Q:$QS(CUR,5)>EDT  Q:$P($QS(CUR,6),";",2)'="CH"
 . S DATLOC=$TR($QS(CUR,6),";",",")
 . S $P(DATLOC,",",2)=""""_$P(DATLOC,",",2)_""""
 . S DAT0=DATLOC,$P(DAT0,",",$L(DAT0,","))=0
 . S DAT0="^LR("_DAT0_")"
 . S DATLOC="^LR("_DATLOC_")"
 . S DTRSLT=$P(@DAT0,U,3)
 . S DFN=$QS(CUR,3),LAB=$QS(CUR,4)
 . S RSLT=$P(@DATLOC,U),LOINC=$P($P(@DATLOC,U,3),"!",3)
 . S X="LOINC^VFDLA00A"
 . I $T(@X)'="",LOINC'="" S @("LOINC=$$"_X_"(LOINC)")
 . S FLAG=$P(@DATLOC,U,2)
 . S @DATA@(I)=DFN_U_LAB_U_RSLT_U_FLAG_U_LOINC_U_DTRSLT
 . S I=I+1
 S @DATA@(0)="PT_IEN^LABORD_IEN^RESULT^FLAG^LOINC^RES_DT"
 S DTS(0)=6
 D CSVOUT(FILEN,DATA,U,U,.DTS,PATH)
 K @DATA
 S RET="1^File "_FILEN_" written successfully"
 Q
