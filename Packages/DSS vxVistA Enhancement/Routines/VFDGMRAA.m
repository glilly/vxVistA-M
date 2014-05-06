VFDGMRAA ;DSS/WLC - ALLERGY/ADVERSE REACTIONS SUB-ROUTINES ;24 Mar 2011 17:30
 ;;2011.1.2;DSS,INC VXVISTA OPEN SOURCE;;28 Jan 2013;Build 153
 ;Copyright 1995-2013,Document Storage Systems Inc. All Rights Reserved
 ;
 ; This routine contains the processing sub-routines for the update of Allergies and Adverse Reactions
 ;
 Q
 ;
 ; Add/Edit Allergies:
 ;      INPUT:
 ;          GMRAIEN  = IEN (pointer) to PATIENT ALLERGIES (#120.8) file.
 ;          DFN      = IEN (pointer) to the PATIENT (#2) file.
 ;          GMRARRAY = List of data elemetns to be stored inside PATIENT ALLERGIES (#120.8) file.
 ;
 ;      OUTPUT:
 ;          ORY      = Error message on error, or 0 on success.
 ;
UPDATE(GMRAIEN,DFN,GMRARRAY) ;Add/edit allergies  RPC: VFDGMRA EDITSAVE
 N NEW,NKA,FDA,NODE,IEN,SUB,FILE,DA,DIK,SIEN,GMRAS0,GMRAL,GMRAPA,GMRAAR,GMRALL,GMRADFN,GMRAOUT,GMRAROT,GMRAPN
 S NEW='$G(GMRAIEN)
 I NEW,$$DUPCHK^GMRAOR0(DFN,$P(@GMRARRAY@("GMRAGNT"),U))=1 S ORY="-1^Patient already has a "_$P(@GMRARRAY@("GMRAGNT"),U)_" reaction entered.  No duplicates allowed." Q
 L +^XTMP("GMRAED",DFN):1 I '$T D MESS Q
 D SITE^GMRAUTL S GMRASITE(0)=$G(^GMRD(120.84,+GMRASITE,0))
 S NKA='$$NKA^GMRANKA(DFN) ;is patient NKA?
 I NKA,NEW D
 .S FDA(120.86,"?+"_DFN_",",.01)=DFN
 .S FDA(120.86,"?+"_DFN_",",1)=1
 .S FDA(120.86,"?+"_DFN_",",2)=DUZ
 .S FDA(120.86,"?+"_DFN_",",3)=$G(@GMRARRAY@("GMRAORDT"),$$NOW^XLFDT)
 .S IEN(DFN)=DFN
 .D UPDATE^DIE("","FDA","IEN")
 K FDA,IEN
 S NODE=$S($G(NEW):"+1,",1:(GMRAIEN_","))
 S:$G(NEW) FDA(120.8,NODE,.01)=DFN
 I $P($G(@GMRARRAY@("GMRAGNT")),U,2)["50.67" S $P(@GMRARRAY@("GMRAGNT"),U,2)=$$TGTOG^PSNAPIS($P(@GMRARRAY@("GMRAGNT"),U))_";PSNDF(50.6,"
 F SUB="GMRAGNT;.02","GMRATYPE;3.1","GMRANATR;17","GMRAORIG;5","GMRAORDT;4","GMRAOBHX;6" D
 .S FDA(120.8,NODE,$P(SUB,";",2))=$P(@GMRARRAY@($P(SUB,";")),U)
 .I (SUB["GMRAGNT"),NEW S FDA(120.8,NODE,1)=$P(@GMRARRAY@($P(SUB,";")),U,2)
 D UPDATE^DIE("","FDA","IEN")
 S:NEW GMRAIEN=IEN(1)
 K FDA
 F SUB="GMRACHT","GMRAIDBN" D
 .Q:'$D(@GMRARRAY@(SUB))  ;Stop if no updates
 .S FILE=$S(SUB="GMRACHT":120.813,1:120.814)
 .S FDA(FILE,"+1,"_GMRAIEN_",",.01)=@GMRARRAY@(SUB,1)
 .S FDA(FILE,"+1,"_GMRAIEN_",",1)=DUZ
 .D UPDATE^DIE("","FDA")
 K FDA
 S SUB=0 F  S SUB=$O(@GMRARRAY@("GMRASYMP",SUB)) Q:'+SUB  D
 .S GMRAS0=^(SUB) ;Naked from above
 .Q:$P(^(SUB),U)=""  ;25 No text or free text entered so don't store
 .S SIEN=$O(^GMR(120.8,GMRAIEN,10,"B",$P(GMRAS0,U),0))
 .I SIEN,$P(^GMR(120.8,GMRAIEN,10,SIEN,0),U,4)=$P(GMRAS0,U,3) Q  ;Exists and nothing has changed
 .I SIEN,$P(GMRAS0,U,5)="@" D
 . .N ACOM,DATE S ACOM=$O(@GMRARRAY@("GMRACMTS",0))-.3
 . .S Y=$$NOW^XLFDT X ^DD("DD") S DATE=Y
 . .S @GMRARRAY@("GMRACMTS",ACOM)="  "_$P(GMRAS0,U,2)_" deleted by "
 . .S @GMRARRAY@("GMRACMTS",(ACOM+.1))="  "_$$GET1^DIQ(200,DUZ_",",.01)_" on: "_DATE,@GMRARRAY@("GMRACMTS",(ACOM+.2))="  "
 . .S DIK="^GMR(120.8,"_GMRAIEN_",10,",DA(1)=GMRAIEN,DA=SIEN D ^DIK Q  ;Sign/symptom deleted
 .S:'SIEN FDA(120.81,"+1,"_GMRAIEN_",",.01)=$S($P(GMRAS0,U)="FT":$O(^GMRD(120.83,"B","OTHER REACTION",0)),1:$P(GMRAS0,U))
 .S NODE=$S(SIEN:SIEN_","_GMRAIEN,1:"+1,"_GMRAIEN_",")
 .S:$P(GMRAS0,U)="FT" FDA(120.81,NODE,1)=$P(GMRAS0,U,2)
 .S FDA(120.81,NODE,2)=DUZ
 .S FDA(120.81,NODE,3)=$P(GMRAS0,U,3)
 .D UPDATE^DIE("","FDA","","ERR")
 .S GMRAROT($P(GMRAS0,U,2))="" ;21 record s/s added
 .I NODE["+1" D
 . .N ACOM,DATE S ACOM=$O(@GMRARRAY@("GMRACMTS",0))-.3
 . .S Y=$$NOW^XLFDT X ^DD("DD") S DATE=Y
 . .S @GMRARRAY@("GMRACMTS",ACOM)="  "_$P(GMRAS0,U,2)_" Added by "
 . .S @GMRARRAY@("GMRACMTS",(ACOM+.1))="  "_$$GET1^DIQ(200,DUZ_",",.01)_" on: "_DATE,@GMRARRAY@("GMRACMTS",(ACOM+.2))="  "
 I NEW D
 .S GMRALL(GMRAIEN)="" D VAD^GMRAUTL1(DFN,,.GMRALOC,.GMRANAM) D EN7^GMRAMCB ;Send mark chart/ID band bulletin if needed.
 .I $P(@GMRARRAY@("GMRAOBHX"),U)="o" D  ;if observed reaction add data to 120.85
 ..S GMRAOUT=0 ;21
 ..S GMRAL(GMRAIEN,"O",GMRAIEN)=$G(@GMRARRAY@("GMRARDT"))_"^"_$G(@GMRARRAY@("GMRASEVR"))
 ..S GMRADFN=DFN
 ..S GMRAL(GMRAIEN)="^^"_$P($G(@GMRARRAY@("GMRAGNT")),U)_"^^^^"_$G(@GMRARRAY@("GMRAORIG"))
 ..M GMRAL(GMRAIEN,"S")=@GMRARRAY@("GMRASYMP")
 ..S SUB=0 F  S SUB=$O(GMRAL(GMRAIEN,"S",SUB)) Q:'+SUB  S $P(GMRAL(GMRAIEN,"S",SUB),U,2)=$P(GMRAL(GMRAIEN,"S",SUB),U,2)_"^" S:$P(GMRAL(GMRAIEN,"S",SUB),U)="FT" $P(GMRAL(GMRAIEN,"S",SUB),U)=$O(^GMRD(120.83,"B","OTHER REACTION",0))
 ..S GMRAL=GMRAIEN
 ..D ADVERSE^GMRAOR7(GMRAIEN,.GMRAL) ;adds entry to 120.85
 ..S GMRAIEN(GMRAIEN)="" ;21
 ..D EN1^GMRAPET0(GMRADFN,.GMRAIEN,"S",.GMRAOUT) ;21 File progress note
 ..I $G(@GMRARRAY@("GMRATYPE"))["D" S GMRAPA=GMRAIEN D EN1^GMRAPTB ;21 Send med-watch update
 .S GMRAAR=$P($G(@GMRARRAY@("GMRAGNT")),U,2),GMRAPA=GMRAIEN
 .D EN1^GMRAOR9 S ^TMP($J,"GMRASF",1,GMRAPA)="" D RANGE^GMRASIGN(1) ;add ingredients/classes send appropriate bulletins
 I $D(@GMRARRAY@("GMRACMTS")) D ADCOM(GMRAIEN,"O",$NA(@GMRARRAY@("GMRACMTS"))) ;Add comments if included
 S ORY=0_$S(+$G(GMRAPN)>0:("^"_+$G(GMRAPN)),1:"") ;38 If note was created send back IEN
 L -^XTMP("GMRAED",DFN)
 Q
 ;
MESS ;Give out locked message
 N GMRAXBOS,GMRAL1,GMRAL2
 S GMRAXBOS=$$BROKER^XWBLIB ;In GUI?
 S GMRAL1="Another user is editing this patient's allergy information."
 S GMRAL2="Please refresh/review the patient's information before proceeding."
 I 'GMRAXBOS W !,GMRAL1,!,GMRAL2 D WAIT^GMRAFX3 Q
 S ORY="-1^"_GMRAL1_"  "_GMRAL2
 Q
 ;
ADCOM(ENTRY,TYPE,GMRACOM) ;Add comments to allergies
 ;
 N FDA,GMRAI,X,DIWL,DIWR
 K ^UTILITY($J,"W") S DIWL=1,DIWR=60 S GMRAI=0 F  S GMRAI=$O(@GMRACOM@(GMRAI)) Q:'+GMRAI  S X=@GMRACOM@(GMRAI) D ^DIWP
 S GMRACOM="^UTILITY($J,""W"",1)"
 S FDA(120.826,"+1,"_ENTRY_",",.01)=$$NOW^XLFDT
 S FDA(120.826,"+1,"_ENTRY_",",1)=DUZ
 S FDA(120.826,"+1,"_ENTRY_",",1.5)=TYPE
 S FDA(120.826,"+1,"_ENTRY_",",2)=GMRACOM
 D UPDATE^DIE("","FDA")
 Q
 ;
