VFDTIU1 ;DSS/ASF/SMP - TIU OBJECTS ; 08/24/2013 13:00
 ;;2011.1.3;DSS,INC VXVISTA OPEN SOURCE;**6**;16 Aug 2013;Build 4
 ;Copyright 1995-2013,Document Storage Systems Inc. All Rights Reserved
 ; 
 ; Integration Agreements, etc.
 ; 
 ; 2051   $$FIND1^DIC
 ; 2056   $$GET1^DIQ
 ; 10061  DEM^VADPT
 ; 10103  ^XLFDT: $$FMTHL7, $$NOW
 ; 3065   STDNAME^XLFNAME
 Q
ADREG(DFN) ;DSS/ASF Last Admitting Regulation
 ;^DGPM("APID",DFN,Inverse Date_AS,DA)=""
 N VFDATE,VFDA,G,G12
 S VFDLG=""
 S VFDATE=0 F  S VFDATE=$O(^DGPM("ATID1",DFN,VFDATE)) Q:VFDATE'>0  Q:VFDLG'=""  D
 . S VFDA=$O(^DGPM("ATID1",DFN,VFDATE,0)) Q:VFDA'>0
 . S G=^DGPM(VFDA,0),G12=$P(G,U,12)
 . I +G12 S VFDLG="Last Legal Status: "_$S($D(^DIC(43.4,+G12,0)):$P(^(0),"^",1),1:"")_" on : "_$$FMTE^XLFDT(9999999-VFDATE)
 Q VFDLG
 ;
CLABS(DFN,SDATE,EDATE) ;critical ch labs by patient by date
 N %,%DT,I,X,CLABS,DATE,FLAG,IDT,ILST,REF,SUB
 I DFN'?1N.N Q
 I SDATE="" S SDATE=$E($$NOW^XLFDT,1,12)
 I EDATE="" S X="T-1" D ^%DT S EDATE=Y
 K ^TMP("LRRR",$J),^TMP($J,"ORATR","CLABS")
 S CLABS="^TMP($J,""ORATR"",""CLABS"")"
 D RR^LR7OR1(DFN,"",SDATE,EDATE,"","","","","","") ;Get LAB results for patient
 ;Output is set in ^TMP("LRRR",$J,dfn,subscript,inverse d/t,seq)=
 ; testID^result^flag^units^refrange^resultstatus(F or P)^^^natlCode^natlName^system^Verifyby^^Theraputicflag(T or "")^PrintName^Accession^Order#^Specimen
 S @CLABS@(1,0)="Critical Lab Results from "_$$FMTE^XLFDT(SDATE)_" TO "_$$FMTE^XLFDT(EDATE)
 S @CLABS@(2,0)="Test      Result            Date                   Ref Range"
 S @CLABS@(3,0)="No criticals found.",ILST=2
 S SUB="" F  S SUB=$O(^TMP("LRRR",$J,DFN,SUB)) Q:SUB=""  D
 . S IDT=0 F  S IDT=$O(^TMP("LRRR",$J,DFN,SUB,IDT)) Q:'IDT  D
 . . S I=0 F  S I=$O(^TMP("LRRR",$J,DFN,SUB,IDT,I)) Q:'I  S X=^(I) D
 . . . S DATE=$$FMTE^XLFDT(9999999-IDT),FLAG=$P(X,U,3)
 . . . S REF=$P(X,U,5)
 . . . S:$L(REF) REF="("_$P(X,U,5)_")"
 . . . S X=$P(X,U,15)_U_$P(X,U,2)_U_$P(X,U,4)_U_FLAG_U_DATE_U_REF
 . . . S X=$$TABPIECE(X,"1,2,3,4,5,6","9,18,24,27,50")
 . . . I FLAG?.E1"*".E S ILST=ILST+1,@CLABS@(ILST,0)=X ;list only criticals
 K ^TMP("LRRR",$J)
 Q "~@"_$NA(@CLABS)
 ;
RLABS(DFN,EDATE) ;recent ch labs by patient by date
 N IDT,ILST,REF,SUB,DATE,FLAG
 I DFN'?1N.N Q  ;--> out
 D NOW^%DTC S SDATE=%
 I EDATE="" S EDATE="T-199" ;CHANGE THIS
 S X=EDATE D ^%DT S EDATE=Y
 K ^TMP("LRRR",$J),^TMP($J,"ORATR","CLABS")
 S CLABS="^TMP($J,""ORATR"",""CLABS"")"
 D RR^LR7OR1(DFN,"",SDATE,EDATE,"","","","","","") ;Get LAB results for patient
 ;Output is set in ^TMP("LRRR",$J,dfn,subscript,inverse d/t,seq)=
 ; testID^result^flag^units^refrange^resultstatus(F or P)^^^natlCode^natlName^system^Verifyby^^Theraputicflag(T or "")^PrintName^Accession^Order#^Specimen
 S @CLABS@(1,0)="Recent Lab Results from "_$$FMTE^XLFDT(SDATE)_" TO "_$$FMTE^XLFDT(EDATE)
 S @CLABS@(2,0)="Test      Result            Date                   Ref Range"
 S @CLABS@(3,0)="None found.",ILST=2
 S SUB="" F  S SUB=$O(^TMP("LRRR",$J,DFN,SUB)) Q:SUB=""  D
 . S IDT=0 F  S IDT=$O(^TMP("LRRR",$J,DFN,SUB,IDT)) Q:'IDT  D
 . . S I=0 F  S I=$O(^TMP("LRRR",$J,DFN,SUB,IDT,I)) Q:'I  S X=^(I) D
 . . . S DATE=$$FMTE^XLFDT(9999999-IDT),FLAG=$P(X,U,3)
 . . . S REF=$P(X,U,5)
 . . . S:$L(REF) REF="("_$P(X,U,5)_")"
 . . . S X=$P(X,U,15)_U_$P(X,U,2)_U_$P(X,U,4)_U_FLAG_U_DATE_U_REF
 . . . S X=$$TABPIECE(X,"1,2,3,4,5,6","9,18,24,27,50")
 . . . S ILST=ILST+1,@CLABS@(ILST,0)=X ;list only criticals
 K ^TMP("LRRR",$J)
 Q "~@"_$NA(@CLABS) ;-->out
 ;
SS(DFN) ;current smoking status
 N N,N1,X,Y,CAT,DIC,VDATE,VFDSMOKE,VFDSS,VHF,VST,YSLRDIC
 S VFDSS="no smoking HF"
 S Y=$$FIND1(9999999.64,,"QX","SMOKING STATUS") I Y<1 Q VFDSS
 S CAT=+Y
 S N=0 F  S N=$O(^AUPNVHF("C",DFN,N)) Q:N'>0  D
 . S G=^AUPNVHF(N,0)
 . Q:'$D(^AUTTHF("AC",CAT,+G))  ;ONLY SMOKING ENTRIES
  . S VHF=$P(^AUTTHF(+G,0),U)
 . S VST=$P(G,U,3),VDATE=+(^AUPNVSIT(VST,0))
 . S VFDSMOKE(9999999-VDATE)=VHF
 S VFDSS="smoking staus not entered"
 I $D(VFDSMOKE) D
 . S Y=$O(VFDSMOKE(0)),VFDSS=VFDSMOKE(Y)
 . S VFDSS=VFDSS_" documented on "_$$DATE($$FMTE^XLFDT(9999999-Y))
 . Q
 Q VFDSS
 ;
 ;-----------------------  PRIVATE SUBROUTINES  -----------------------
DATE(Y) Q $P($TR(Y,"@"," "),":",1,2)
 ;
FIND1(P1,P2,P3,P4,P5,P6) ;
 N I,J,X,Y,Z,DIERR,VFDER
 S P1=$G(P1),P2=$G(P2),P3=$G(P3)
 S X=$$FIND1^DIC(P1,P2,P3,.P4,.P5,.P6,"VFDER")
 I $D(DIERR) S X=$$MSG^VFDCFM("E",,,,"VFDER")
 Q X
 ;
TABPIECE(X,PIECES,TABS) ; return pieces with withspace between them
 N I,J,Y,APIECE S Y=""
 F I=1:1:$L(PIECES,",") S APIECE=+$P(PIECES,",",I) D
 . S Y=Y_$P(X,U,APIECE)
 . F J=$L(Y):1:+$P(TABS,",",I) S Y=Y_" "
 Q Y
