VFDFIX4 ;DSS/RAC - Clean up file 4 pointers ;11/13/2013@1500
 ;;2011.1.1;DSS,INC VXVISTA OPEN SOURCE;;;Build 
 ;Copyright 1995-2012,Document Storage Systems Inc. All Rights Reserved
 ;
EN ;
 D PAT
 D LAB
 D LABCH
 D LABAC
 D LABDIV
 D LABSH
 D LABSP
 D LABWK
 D USER
 D ALLERGY
 D HLOC
 D PSP
 D PSBR
 D PSBM
 D PSITE
 D REQ
 D HLE
 D PXR
 D TIU
 D OERRDC
 D IVMADD
 D OERREL
 D DGPM
 D DGPF
 D QAP
 Q
 ;
PAT ;
 N DA,DIE,DR,DUOUT,DTOUT,LAB,IEN
 S IEN=0
 W !,"Updating the Paitient File (#2)",!
 F  S IEN=$O(^DPT(IEN)) Q:'IEN  D
 . I $D(^DPT(IEN,.11)) D
 . . N DA,DIE,DR,DTOUT,DUOUT
 . . Q:$P(^DPT(IEN,.11),"^",15)'=2956
 . . S DA=IEN,DR=".12////1",DIE="^DPT(" D ^DIE W !,^DPT(IEN,.11)
 . . I $D(DTOUT)!($D(DUOUT)) W !,"*** Rec "_IEN_","_DR_" Patient Error"
 . . E  W !,"Rec "_IEN_","_DR_" Patient file-Institution changed from 2596 to 1"
 . . Q
 . I $D(^DPT(IEN,.121)) D
 . . N DA,DIE,DR,DTOUT,DUOUT
 . . Q:$P(^DPT(IEN,.121),U,14)'=2956
 . . S DA=IEN,DR=".12114////1",DIE="^DPT(" D ^DIE W !,^DPT(IEN,.121)
 . . I $D(DTOUT)!($D(DUOUT)) W !,"*** Rec "_IEN_","_DR_" Patient Error"
 . . E  W !,"Rec "_IEN_","_DR_" Patient file-Institution changed from 2596 to 1"
 . . Q
 . I $D(^DPT(IEN,.13)) D
 . . N DA,DIE,DR,DTOUT,DUOUT
 . . Q:$P(^DPT(IEN,.13),U,11)'=2956 
 . . S DA=IEN,DR=".13111////1",DIE="^DPT(" D ^DIE W !,^DPT(IEN,.13)
 . . I $D(DTOUT)!($D(DUOUT)) W !,"*** Rec "_IEN_","_DR_" Patient Error"
 . . E  W !,"Rec "_IEN_","_DR_" Patient file-Institution changed from 2596 to 1"
 . . Q
 . I $D(^DPT(IEN,.141)) D
 . . N DA,DIE,DR,DTOUT,DUOUT
 . . Q:$P(^DPT(IEN,.141),U,13)'=2956
 . . S DA=IEN,DR=".14113////1",DIE="^DPT(" D ^DIE W !,^DPT(IEN,.141)
 . . I $D(DTOUT)!($D(DUOUT)) W !,"*** Rec "_IEN_","_DR_" Patient Error"
 . . E  W !,"Rec "_IEN_","_DR_" Patient file-Institution changed from 2596 to 1"
 . . Q
 . I $D(^DPT(IEN,"MPI")) D
 . . N DA,DIE,DR,DTOUT,DUOUT
 . . Q:$P(^DPT(IEN,"MPI"),U,3)'=2956
 . . S DA=IEN,DR="991.03////1",DIE="^DPT(" D ^DIE W !,^DPT(IEN,"MPI")
 . . I $D(DTOUT)!($D(DUOUT)) W !,"*** Rec "_IEN_","_DR_" Patient Error"
 . . E  W !,"Rec "_IEN_","_DR_" Patient file-Institution changed from 2596 to 1"
 . . Q
 . W !,"Rec "_IEN_" Patient file-Institution changed from 2596 to 1"
 .Q
 W !,"Done"
 Q
 ;
LAB ;
 N LAB,SND
 S LAB=0
 W !,"Updating the LAB file(#60)",!
 F  S LAB=$O(^LAB(60,LAB)) Q:'LAB  D
 . Q:'$D(^LAB(60,LAB,8,0))
 . Q:'$D(^LAB(60,LAB,8,2956,0))
 . S:$D(^LAB(60,LAB,8,2956,0)) SND=^LAB(60,LAB,8,2956,0) ;SAVE DATA
 . K ^LAB(60,LAB,8,2956,0),^LAB(60,LAB,8,2956,0)
 . S ^LAB(60,LAB,8,1,0)=1_"^"_SND,$P(^LAB(60,LAB,8,1,0),U,2)=1
 . S ^LAB(60,LAB,8,0)="^60.11PA^1^1"
 . W !,"Rec "_LAB_" Accession Area-Institution changed from 2596 to 1"
 . Q
 W !,"Done"
 Q
 ;
LABCH ;
 N LAB,LAB2,SIEN,SND
 S LAB=0
 W !,"Updating the LAB DATA file(#63)",!
 F  S LAB=$O(^LR(LAB)) Q:'LAB  D
 . S SND=0 
 . F  S SND=$O(^LR(LAB,"CH",SND)) Q:'SND  D
 . . Q:$P(^LR(LAB,"CH",SND,0),"^",14)'=2956 
 . . S $P(^LR(LAB,"CH",SND,0),"^",14)=1
 . . W !,"Rec "_LAB_","_SND_" Lab Micro-Institution changed from 2596 to 1"
 . . S LAB2=0 F  S LAB2=$O(^LR(LAB,"CH",SND,LAB2)) Q:'LAB2
 . . . Q:$P(^LR(LAB,"CH",SND,LAB2),"^",9)'=2956
 . . . S $P(^LR(LAB,"CH",SND,LAB2),"^",9)=1
 . . . W !,"Rec "_LAB_","_SND_","_LAB2_" Lab Micro-Institution changed from 2596 to 1"
 . . . Q
 . S SIEN=0
 . F  S SIEN=$O(^LR(LAB,"MI",SIEN)) Q:'SIEN  D
 . . Q:$P(^LR(LAB,"MI",SIEN,0),"^",14)'=2956
 . . S $P(^LR(LAB,"MI",SIEN,0),"^",14)=1
 . . W !,"Rec "_LAB_" Lab MICROBIOLOGY-Institution changed from 2596 to 1"
 . . Q
 . Q
 W !,"Done"
 Q
 ;
LABAC ;
 N LAB,LB1,LB2,DA,DIE,DR,DUOUT,DTOUT
 S LAB=0
 W !,"Updating the LAB ACCESSION file(#68)",!
 F  S LAB=$O(^LRO(68,LAB)) Q:'LAB  D
 . I $D(^LRO(68,LAB,3,0))  D
 . . Q:'$D(^LRO(68,LAB,3,2956,0))
 . . Q:^LRO(68,LAB,3,2956,0)'=2956
 . . S ^LRO(68,LAB,3,0)="^68.03PA^1^1"
 . . S ^LRO(68,LAB,3,1,0)=1,^LRO(68,LAB,3,"B",1,1)=""
 . . K ^LRO(68,LAB,3,2956,0),^LRO(68,LAB,3,"B",2956,2956)
 . . K ^LRO(68,LAB,3,0)
 . . W !,"Rec "_LAB_" Lab Accession-Institution changed from 2596 to 1"
 . . Q
 . Q
 W !,"Done"
 Q
 ;
LABDIV ;
 N LAB,LB1,LB2,DA,DIE,DR,DUOUT,DTOUT
 S LAB=0
 W !,"Updating the LAB ACCESSION - Division file(#68)",!
 F  S LAB=$O(^LRO(68,LAB)) Q:'LAB  D
 . S LB1=0
 . F  S LB1=$O(^LRO(68,LAB,1,LB1)) Q:'LB1  D
 . . S LB2=0
 . . F  S LB2=$O(^LRO(68,LAB,1,LB1,1,LB2)) Q:'LB2  D
 . . . Q:^LRO(68,LAB,1,LB1,1,LB2,.4)'=2956
 . . . S ^LRO(68,LAB,1,LB1,1,LB2,.4)=1
 . . . W !,"Rec "_LAB_" Lab Accession (.4)-Institution changed from 2596 to 1"
 . . . Q
 . . Q
 . Q
 W !,"Done"
 Q
 ;
LABSH ;
 N LAB,LB1,DA,DIE,DR,DUOUT,DTOUT
 S LAB=0
 W !,"Updating the LAB SHIPPING CONFIGURATION file(#62.9)",!
 F  S LAB=$O(^LAHM(62.9,LAB)) Q:'LAB  D
 . Q:$G(^LAHM(62.9,LAB,0))=""
 . N DA,DIE,DR,DTOUT,DUOUT
 . I $P(^LAHM(62.9,LAB,0),"^",2)=2956  D
 . . S DA=LAB,DR=".02////1",DIE="^LAHM(62.9," D ^DIE
 . . I $D(DTOUT)!($D(DUOUT)) W !,"*** Rec "_LAB_","_LB1_" Lab Shipping Conf(.02)"
 . . E  W !,"Rec "_LAB_" Lab Shipping Configuration .02-Institution changed from 2596 to 1"
 . . Q
 . I $P(^LAHM(62.9,LAB,0),"^",3)=2956  D
 . . S DA=LAB,DR=".03////1",DIE="^LAHM(62.9," D ^DIE
 . . I $D(DTOUT)!($D(DUOUT)) W !,"*** Rec "_LAB_","_LB1_" Lab Shipping Conf(.03)"
 . . E  W !,"Rec "_LAB_" Lab Shipping Configuration .03-Institution changed from 2596 to 1"
 . . Q
 . I $P(^LAHM(62.9,LAB,0),"^",6)=2956  D
 . . S DA=LAB,DR=".06////1",DIE="^LAHM(62.9," D ^DIE
 . . I $D(DTOUT)!($D(DUOUT)) W !,"*** Rec "_LAB_","_LB1_" Lab Shipping Conf(.06)"
 . . E  W !,"Rec "_LAB_" Lab Shipping Configuration .06-Institution changed from 2596 to 1"
 . . Q
 . I $P(^LAHM(62.9,LAB,0),"^",11)=2956  D
 . . S DA=LAB,DR=".031////1",DIE="^LAHM(62.9," D ^DIE
 . . I $D(DTOUT)!($D(DUOUT)) W !,"*** Rec "_LAB_","_LB1_" Lab Shipping Conf(.031)"
 . . E  W !,"Rec "_LAB_" Lab Shipping Configuration .031-Institution changed from 2596 to 1"
 . . Q
 . Q
 W !,"Done"
 Q
 ; 
LABSP ;
 N LAB,LB1,DA,DIE,DR,DUOUT,DTOUT
 S LAB=0
 W !,"Updating the LAB SPECIMEN file(#69)",!
 F  S LAB=$O(^LRO(69,LAB)) Q:'LAB  D
 . S LB1=0 F  S LB1=$O(^LRO(69,LAB,1,LB1)) Q:'LB1  D
 . . Q:'$D(^LRO(69,LAB,1,LB1,1))
 . . N DA,DIE,DR,DTOUT,DUOUT
 . . Q:$P(^LRO(69,LAB,1,LB1,1),"^",8)'=2956
 . . S DA=LB1,DR="25////1",DIE="^LRO(69,LAB,1," D ^DIE
 . . I $D(DTOUT)!($D(DUOUT)) W !,"*** Rec "_LAB_","_LB1_" Lab Secimen Error"
 . . E  W !,"Rec "_LAB_" Lab Specimen-Institution changed from 2596 to 1"
 . Q
 W !,"Done"
 Q
 ;
LABWK ;
 N LAB
 S LAB=0
 W !,"Updating the LAB WorkLoad File(#64.1)",!
 F  S LAB=$O(^LRO(64.1,2956,LAB)) Q:'LAB  D
 . Q:'$D(^LRO(64.1,2956,0))
 . S ^LRO(64.1,1,0)=1
 . D LABWK1
 . S ^LRO(64.1,0)="WKLD DATA^64.1P^1^1"
 . S ^LRO(64.1,1,0)=1
 . S ^LRO(64.1,"B",1,1)=""
 . K ^LRO(64.1,2956),^LRO(64.1,"B",2956,2956)
 . Q
 W !,"Done"
 Q
 ;
LABWK1 ;
 N LB1,LB2,LB3
 S LB1=0
 F  S LB1=$O(^LRO(64.1,2956,LAB,LB1)) Q:'LB1  D
 . W !,^LRO(64.1,2956,LAB,LB1,0)
 . S ^LRO(64.1,1,LAB,1,0)=^LRO(64.1,2956,LAB,0)
 . S ^LRO(64.1,1,LAB,LB1,0)=^LRO(64.1,2956,LAB,LB1,0)
 . S LB2=0
 . F  S LB2=$O(^LRO(64.1,2956,LAB,LB1,1,LB2)) Q:'LB2  D
 . . W !,^LRO(64.1,2956,LAB,LB1,1,LB2,0)
 . . S ^LRO(64.1,1,LAB,LB1,1,LB2,0)=^LRO(64.1,2956,LAB,LB1,1,LB2,0)
 . . S LB3=0
 . . F  S LB3=$O(^LRO(64.1,2956,LAB,LB1,1,LB2,1,LB3)) Q:'LB3  D
 . . . W !,^LRO(64.1,2956,LAB,LB1,1,LB2,1,LB3,0)
 . . . S ^LRO(64.1,1,LAB,LB1,1,LB2,1,LB3,0)=^LRO(64.1,2956,LAB,LB1,1,LB2,1,LB3,0)
 . . . S ^LRO(64.1,1,LAB,1,"B",LB2,LB2)=""
 . . . Q
 . S ^LRO(64.1,1,LAB,"B",LB1,LB1)=""
 . . Q
 . W !,"Record "_LAB_"  in the LAB WorkLoad Changed from 2956 to 1"
 . Q
 Q
 ;
USER ;                                                                      
 N IEN
 S IEN=0
 W !,"Updating the USER file(#200)",!
 F  S IEN=$O(^VA(200,IEN)) Q:'IEN  D
 . Q:'$D(^VA(200,IEN,2,0))
 . Q:$P(^VA(200,IEN,2,0),U,3)'=2956
 . K ^VA(200,IEN,2)
 . S ^VA(200,IEN,2,0)="^200.02P^1^1",^VA(200,IEN,2,1,0)=1
 . S ^VA(200,IEN,2,"B",1,1)=""
 . W !,"Rec "_IEN_" User-Institution changed from 2596 to 1"
 Q
 ;
ALLERGY ;
 N IEN,SIEN
 S IEN=0
 W !,"Updating the ALLERGY file(#120.84)",!
 F  S IEN=$O(^GMRD(120.84,IEN)) Q:'IEN  D
 . Q:'$D(^GMRD(120.84,IEN,6,0))
 . S SIEN=0 F  S SIEN=$O(^GMRD(120.84,IEN,6,SIEN)) Q:'SIEN  D
 . . Q:^GMRD(120.84,IEN,6,SIEN,0)'=2956
 . . K ^GMRD(120.84,IEN,6,SIEN,0),^GMRD(120.84,IEN,6,"B",2956,SIEN)
 . . K ^GMRD(120.84,"SITE",2956,1,1)
 . . S ^GMRD(120.84,IEN,6,SIEN,0)=1,^GMRD(120.84,IEN,6,"B",1,SIEN)=""
 . . S ^GMRD(120.84,"SITE",1,IEN,SIEN)=""
 . . W !,"Rec "_IEN_" Allergy-Institution changed from 2596 to 1"
 . . Q
 W !,"Done"
 Q
 ;
HLOC ;
 N IEN
 S IEN=0
 W !!,"Updating Hospital Location File (#44)",!
 F  S IEN=$O(^SC(IEN)) Q:'IEN  D
 . Q:'$D(^SC(IEN,0))
 . N DA,DIE,DR,DTOUT,DUOUT
 . Q:$P(^SC(IEN,0),"^",4)'=2956
 . S DA=IEN,DR="3////1",DIE="^SC(" D ^DIE W !,^SC(IEN,0)
 . I $D(DTOUT)!($D(DUOUT)) W !,"*** Rec "_IEN_" Hospital Location Error"
 . E  W !,"Rec "_IEN_" Hospital Location-Institution changed from 2596 to 1"
 . Q
 W !,"Done"
 Q
 ;
PSP ;
 N IEN
 S IEN=0
 W !!,"Updating Pharmacy Pending Outpaient File (#52.41)",!
 F  S IEN=$O(^PS(52.41,IEN)) Q:'IEN  D
 . Q:'$D(^PS(52.41,IEN,"INI"))
 . N DA,DIE,DR,DTOUT,DUOUT
 . Q:^PS(52.41,IEN,"INI")'=2956
 . S DA=IEN,DR="100////1",DIE="^PS(52.41," D ^DIE
 . I $D(DTOUT)!($D(DUOUT)) W !,"*** Rec "_IEN_","_LB1_" Pharmacy Pending Outpaient Error"
 . E  W !,"Rec "_IEN_" Pharmacy Pending Outpatient-Institution changed from 2596 to 1"
 . Q
 W !,"Done"
 Q
 ;
PSBR ;
 N IEN
 S IEN=0
 W !!,"Updating BCMA Report Request File (#53.69)",!
 F  S IEN=$O(^PSB(53.69,IEN)) Q:'IEN  D
 . Q:'$D(^PSB(53.69,IEN,0))
 . N DA,DIE,DR,DTOUT,DUOUT
 . Q:$P(^PSB(53.69,IEN,0),"^",4)'=2956
 . S DA=IEN,DR=".04////1",DIE="^PSB(53.69," D ^DIE
 . I $D(DTOUT)!($D(DUOUT)) W !,"*** Rec "_IEN_" BCMA Report Request Error"
 . E  W !,"Rec "_IEN_" BCMA Report Request-Institution changed from 2596 to 1"
 . Q
 W !,"Done"
 Q
 ;
PSITE ;
 N IEN
 S IEN=0
 W !!,"Updating Outpatient Site File (#59)",!
 F  S IEN=$O(^PS(59,IEN)) Q:'IEN  D
 . Q:'$D(^PS(59,IEN,0))
 . N DA,DIE,DR,DTOUT,DUOUT
 . I $P(^PS(59,IEN,"INI"),"^")=2956  D
 . S DA=IEN,DR="100////1",DIE="^PS(59," D ^DIE
 . I $D(DTOUT)!($D(DUOUT)) W !,"*** Rec "_IEN_" Outpatient Site 100 Error"
 . E  W !,"Rec "_IEN_" Outpatient Site 100-Institution changed from 2596 to 1"
 . Q:'$D(^PS(59,IEN,"INI1",0))
 . S SIEN=0
 . F  S SIEN=$O(^PS(59,IEN,"INI1",SIEN)) Q:'SIEN  D
 . . I ^PS(59,IEN,"INI1",SIEN,0)=2956  D
 . . . S ^PS(59,IEN,"INI1",SIEN,0)=1,^PS(59,IEN,"INI1","B",1,SIEN)=""
 . . . K ^PS(59,IEN,"INI1","B",2956,SIEN)
 . . . W !,"Rec "_IEN_" Outpatient Site  .01 -Institution changed from 2596 to 1"
 . . . Q
 . . Q
 . Q
 W !,"Done"
 Q
 ;
PSBM ;
 N IEN
 S IEN=0
 W !!,"Updating BCMA Medication Log File (#53.79)",!
 F  S IEN=$O(^PSB(53.79,IEN)) Q:'IEN  D
 . Q:'$D(^PSB(53.79,IEN,0))
 . N DA,DIE,DR,DTOUT,DUOUT
 . Q:$P(^PSB(53.79,IEN,0),"^",3)'=2956
 . S DA=IEN,DR=".03////1",DIE="^PSB(53.79," D ^DIE
 . I $D(DTOUT)!($D(DUOUT)) W !,"*** Rec "_IEN_" BCMA Medication Log Error"
 . E  W !,"Rec "_IEN_" BCMA Medication Log-Institution changed from 2596 to 1"
 . Q
 W !,"Done"
 Q
 ;
REQ ;
 N IEN,SIEN
 S IEN=0
 W !,"Updating the REQUEST/Consultation File(#123)",!
 F  S IEN=$O(^GMR(123,IEN)) Q:'IEN  D
 . Q:'$D(^GMR(123,IEN,0))
 . N DA,DIE,DR,DTOUT,DUOUT
 . Q:$P(^GMR(123,IEN,0),"^",21)'=2956
 . S DA=IEN,DR=".05////1",DIE="^GMR(123," D ^DIE
 . I $D(DTOUT)!($D(DUOUT)) W !,"*** Rec "_IEN_" REQUEST/Consultation Log Error"
 . E  W !,"Rec "_IEN_" REQUEST/Consultation-Institution changed from 2596 to 1"
 . Q
 W !,"Done"
 Q
 ;
HLE ;
 N IEN,SIEN
 S IEN=0
 W !,"Updating the HL7 Monitor Event File(#776.4)",!
 F  S IEN=$O(^HLEV(776.4,IEN)) Q:'IEN  D
 . Q:'$D(^HLEV(776.4,IEN,0))
 . N DA,DIE,DR,DTOUT,DUOUT
 . Q:$P(^HLEV(776.4,IEN,0),"^",3)'=2956
 . S DA=IEN,DR=".03////1",DIE="^HLEV(776.4," D ^DIE
 . I $D(DTOUT)!($D(DUOUT)) W !,"*** Rec "_IEN_" HL7 Monitor Event Error"
 . E  W !,"Rec "_IEN_" HL7 Monitor Event-Institution changed from 2596 to 1"
 . Q
 W !,"Done"
 Q
 ;
PXR ;
 N IEN,SIEN
 S IEN=0
 W !,"Updating the Reminder File(#810.1)",!
 F  S IEN=$O(^PXRMPT(810.1,IEN)) Q:'IEN  D
 . Q:'$D(^PXRMPT(810.1,IEN,6))
 . Q:^PXRMPT(810.1,IEN,6,1,0)'=2956
 . K ^PXRMPT(810.1,IEN,6,0),^PXRMPT(810.1,IEN,6,1,0),^PXRMPT(810.1,IEN,6,"B",2956,1)
 . S ^PXRMPT(810.1,IEN,6,0)="^810.13PA^1^1"
 . S ^PXRMPT(810.1,IEN,6,1,0)=1
 . S ^PXRMPT(810.1,IEN,6,"B",1,1)=""
 . W !,"Rec "_IEN_" Reminder File(#810.1)-Institution changed from 2596 to 1"
 . Q
 W !,"Done"
 Q
 ;
TIU ;
 N IEN,SIEN
 S IEN=0
 W !,"Updating the TIU Document File(#8925)",!
 F  S IEN=$O(^TIU(8925,IEN)) Q:'IEN  D
 . Q:'$D(^TIU(8925,IEN,12))
 . N DA,DIE,DR,DTOUT,DUOUT
 . Q:$P(^TIU(8925,IEN,12),"^",12)'=2956
 . S DA=IEN,DR="1212////1",DIE="^TIU(8925," D ^DIE
 . I $D(DTOUT)!($D(DUOUT)) W !,"*** Rec "_IEN_" TIU Document Event Error"
 . E  W !,"Rec "_IEN_" TIU Document-Institution changed from 2596 to 1"
 . Q
 W !,"Done"
 Q
 ;
OERRDC ;
 N IEN
 S IEN=0
 W !!,"Updating OE/RR AUTO-DC Rules File (#100.6)",!
 F  S IEN=$O(^ORD(100.6,IEN)) Q:'IEN  D
 . Q:'$D(^ORD(100.6,IEN,0))
 . N DA,DIE,DR,DTOUT,DUOUT
 . I $P(^ORD(100.6,IEN,0),"^",3)=2956  D
 . . S DA=IEN,DR="3////1",DIE="^ORD(100.6," D ^DIE
 . . I $D(DTOUT)!($D(DUOUT)) W !,"*** Rec "_IEN_","_LB1_" OE/RR AUTO-DC Rules 3 Error"
 . . E  W !,"Rec "_IEN_" OE/RR AUTO-DC Rules 3-Institution changed from 2596 to 1"
 . . Q
 . Q:'$D(^ORD(100.6,IEN,6,0))
 . I $P(^ORD(100.6,IEN,6,0),"^",3)=2956  D
 . . K ^ORD(100.6,IEN,6,0),^ORD(100.6,IEN,6,2956,0),^ORD(100.6,IEN,6,"B",2956,2956)
 . . S ^ORD(100.6,IEN,6,0)="^100.66P^1^1"
 . . S ^ORD(100.6,IEN,6,1,0)=1
 . . S ^ORD(100.6,IEN,6,"B",1,1)=""
 . . W !,"Rec "_IEN_" OE/RR AUTO-DC Rules 6.01-Institution changed from 2596 to 1"
 . . Q
 . Q
 W !,"Done"
 Q
 ;
IVMADD ;
 N IEN
 S IEN=0
 W !!,"Updating IVM Address Change Log File (#301.7)",!
 F  S IEN=$O(^IVM(301.7,IEN)) Q:'IEN  D
 . Q:'$D(^IVM(301.7,IEN,0))
 . N DA,DIE,DR,DTOUT,DUOUT
 . I $P(^IVM(301.7,IEN,0),"^",5)=2956  D
 . . S DA=IEN,DR="3.5////1",DIE="^IVM(301.7," D ^DIE
 . . I $D(DTOUT)!($D(DUOUT)) W !,"*** Rec "_IEN_","_LB1_" IVM Address Change Log File 3.5 Error"
 . . E  W !,"Rec "_IEN_" IVM Address Change Log File 3.5-Institution changed from 2596 to 1"
 . . Q
 . Q:'$D(^IVM(301.7,IEN,1))
 . I $P(^IVM(301.7,IEN,1),"^",3)=2956  D
 . . S DA=IEN,DR="6////1",DIE="^IVM(301.7," D ^DIE
 . . I $D(DTOUT)!($D(DUOUT)) W !,"*** Rec "_IEN_","_LB1_" IVM Address Change Log File 6 Error"
 . . E  W !,"Rec "_IEN_" IVM Address Change Log File 6-Institution changed from 2596 to 1"
 . . Q
 . Q
 W !,"Done"
 Q
 ;
OERREL ;
 N IEN
 S IEN=0
 W !!,"Updating OERR Release Event File (#100.5)",!
 F  S IEN=$O(^ORD(100.5,IEN)) Q:'IEN  D
 . Q:'$D(^ORD(100.5,IEN,0))
 . N DA,DIE,DR,DTOUT,DUOUT
 . I $P(^ORD(100.5,IEN,0),"^",3)=2956  D
 . . S DA=IEN,DR="3////1",DIE="^ORD(100.5," D ^DIE
 . . I $D(DTOUT)!($D(DUOUT)) W !,"*** Rec "_IEN_","_LB1_" OERR Release Event File 3 Error"
 . . E  W !,"Rec "_IEN_" OERR Release Event 3-Institution changed from 2596 to 1"
 . . Q
 . Q
 W !,"Done"
 Q
 ;
DGPM ;
 N IEN
 S IEN=0
 W !!,"Updating Patient Movement File (#405)",!
 F  S IEN=$O(^DGPM(IEN)) Q:'IEN  D
 . Q:'$D(^DGPM(IEN,0))
 . N DA,DIE,DR,DTOUT,DUOUT
 . I $P(^DGPM(IEN,0),"^",5)=2956  D
 . . S DA=IEN,DR=".05////1",DIE="^DGPM(" D ^DIE
 . . I $D(DTOUT)!($D(DUOUT)) W !,"*** Rec "_IEN_","_LB1_" Patient Movement File .05 Error"
 . . E  W !,"Rec "_IEN_" Patient Movement .05-Institution changed from 2596 to 1"
 . . Q
 . Q
 W !,"Done"
 Q
 ;
DGPF ;
 N IEN
 S IEN=0
 W !!,"Updating PRF Assignment File (#26.13)",!
 F  S IEN=$O(^DGPF(26.13,IEN)) Q:'IEN  D
 . Q:'$D(^DGPF(26.13,IEN,0))
 . I $P(^DGPF(26.13,IEN,0),"^",4)=2956  D
 . . S $P(^DGPF(26.13,IEN,0),"^",4)=1
 . . W !,"Rec "_IEN_" PRF Assignment File .04-Institution changed from 2596 to 1"
 . . Q
 . I $P(^DGPF(26.13,IEN,0),"^",5)=2956  D
 . . S $P(^DGPF(26.13,IEN,0),"^",5)=1
 . . W !,"Rec "_IEN_" PRF Assignment File .05-Institution changed from 2596 to 1"
 . . Q
 . I $D(^DGPF(26.13,"AOWN",2956,IEN,IEN))  D
 . . S ^DGPF(26.13,"AOWN",1,1,IEN)=""
 . . K ^DGPF(26.13,"AOWN",2956,1,IEN)
 . . Q
 . Q
 W !,"Done"
 Q
 ;
QAP ;
 W !!,"Updating Quality Assurance Site Parameter File (#740)",!
 I ^QA(740,1,0)=2956  D
 . S ^QA(740,1,0)=1
 . S ^QA(740,"B",1,1)=""
 . K:$D(^QA(740,"B",2956,1)) ^QA(740,"B",2956,1)
 . W !,"QA Site Parameter File .01-Institution changed from 2596 to 1"
 . Q
 W !,"Done"
 Q
