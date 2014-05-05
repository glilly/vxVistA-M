VFDVOHU1 ;DSS/LM - Utilities ; 4/7/2013 21:20
 ;;2011.1.2;DSS,INC VXVISTA OPEN SOURCE;;11 Jun 2013
 ;Copyright 1995-2013,Document Storage Systems Inc. All Rights Reserved
 ; (c) Document Storage Systems, Inc. 2005
 ;
 ; Active integration agreements
 ; 
 ; 2051   $$FIND1^DIC
 ; 2056   $$GET1^DIQ
 ; 
 Q
PCLASS(DFN) ;;Patient class: I[npatient] or [O]utpatient
 I $G(DFN),$D(^DPT(DFN)) Q $S($$GET1^DIQ(2,DFN,.105,"I")>0:"I",1:"O")
 Q ""
 ;
RM(RMBD) ;;Room
 ; Depends on sender's ROOM-BED format - Edit as required
 Q $P($G(RMBD),"-")
 ;
BD(RMBD) ;;Bed
 ; Depends on sender's ROOM-BED format - Edit as required
 Q $P($G(RMBD),"-",2,9)
 ;
PLOC(DFN,VFDVCLS,E1) ;;Patient Assigned Location
 I $G(DFN) S VFDVCLS=$G(VFDVCLS,$$PCLASS(DFN)),E1=$G(E1,"^")
 Q:'$L($G(VFDVCLS)) ""
 I VFDVCLS="I" N RMBD S RMBD=$$GET1^DIQ(2,DFN,.101)
 I  Q $$GET1^DIQ(2,DFN,.1)_E1_$$RM(RMBD)_E1_$$BD(RMBD)
 Q "OP" ;To do: Compute outpatient location
 ;
APHY(DFN,VFDVCLS,E1) ;;Current attending physician
 I $G(DFN) S VFDVCLS=$G(VFDVCLS,$$PCLASS(DFN)),E1=$G(E1,"^")
 Q:'$L($G(VFDVCLS)) ""
 I VFDVCLS="I" Q $$GET1^DIQ(2,DFN,.1041,"I")_E1_$TR($$GET1^DIQ(2,DFN,.1041),",",E1)
 I VFDVCLS="O" Q $TR($TR($$OUTPTPR^SDUTL3(DFN,,2),U,E1),",",E1)
 Q ""
PPHY(DFN,VFDVCLS,E1) ;;Current primary provider
 I $G(DFN) S VFDVCLS=$G(VFDVCLS,$$PCLASS(DFN)),E1=$G(E1,"^")
 Q:'$L($G(VFDVCLS)) ""
 I VFDVCLS="I" Q $$GET1^DIQ(2,DFN,.104,"I")_E1_$TR($$GET1^DIQ(2,DFN,.104),",",E1)
 I VFDVCLS="O" Q $TR($TR($$OUTPTPR^SDUTL3(DFN,,1),U,E1),",",E1)
 Q ""
HLADT(DFN) ;;Admit date/time in HL7 format
 I $G(DFN) N DGPM S DGPM=$$GET1^DIQ(2,DFN,.105,"I")
 I $G(DGPM) Q $$FMTHL7^XLFDT($$GET1^DIQ(405,DGPM,.01,"I"))
 E  Q ""
 ;
PV1(DFN) ;;Build PV1 segment
 I $G(DFN),$D(^DPT(DFN)) N FS,EC S FS=$G(HL("FS"),"|"),EC=$G(HL("ECH"),"^~\&")
 I $T,$L(FS)=1,$L(EC)=4 N %,E1,E2,E3,E4 F %=1:1:4 S @("E"_%_"=$E(EC,%)")
 E  Q "PV1"
 N VFDVPV1 S VFDVPV1="PV1"_FS_1 ;PV1.1 Set ID
 N VFDVCLS S VFDVCLS=$$PCLASS(DFN)
 S $P(VFDVPV1,FS,3)=VFDVCLS ;PV1.2 Patient class
 S $P(VFDVPV1,FS,4)=$$PLOC(DFN,VFDVCLS,E1) ;PV1.3 Assigned patient location
 S $P(VFDVPV1,FS,8)=$$APHY(DFN,VFDVCLS,E1) ;PV1.7 Attending physician
 S $P(VFDVPV1,FS,18)=$$PPHY(DFN,VFDVCLS,E1) ;PV1.17 Primary provider
 S $P(VFDVPV1,FS,45)=$$HLADT(DFN) ;PV1.44 Admit date/time
 ; Coding in progress
 Q $$SQUISH(VFDVPV1,FS)
 ;
SQUISH(X,C) ;;Remove trailing characters from string (From ^DENTVHLU)
 ; C=Character to be removed
 I $L($G(X)),$L($G(C))=1 ;Required
 E  Q $G(X)
 N % F %=$L(X):-1:1 Q:'($E(X,%)=C)
 Q $E(X,1,%)
 ;
