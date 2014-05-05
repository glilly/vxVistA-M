NVSPDS4 ;emciss/maw,lh-scramble data in files 200 and 450 ; 09/01/02
 ;;6.0;EMC TEST ACCOUNT RESET UTILITIES; 01 Jun 1999;;Build 24
 ;
 ; This routine is based on original work done by Lynn Howell at
 ; VAMC Bay Pines, Florida and incorporated into the National VistA
 ; Support Test Account Reset Utilities July 2001.
 ;
 ; Changes from the original routine include using NEW PERSON file as
 ; basis for the scramble -- ALL names in NEW PERSON are scrambled.  If
 ; NEW PERSON record has a pointer to PAID EMPLOYEE (450), then the record
 ; in 450 is also scrambled to match.  If, however, there is no pointer
 ; from 200 to 450, the last step is to run through all 450 records and
 ; scramble them even if there isn't a pointer relationship with 200.
 ; All records in both files get scrambled.
 ;
 N D450,D200,IEN,IEN200,NM450,SSN450,SSN
 I $G(IOF)'="" W @IOF
 W !,$$CJ^XLFSTR("ENTERPRISE MANAGEMENT CENTER: TEST ACCOUNT RESET UTILITIES",80)
 W !,$$CJ^XLFSTR("NEW PERSON (file 200) and PAID EMPLOYEE (file 450) DATA SCRAMBLER",80)
 W !,$$CJ^XLFSTR("**WARNING**WARNING**WARNING**WARNING**",80)
 W !,$$CJ^XLFSTR("**DO NOT RUN THIS UTILITY IN YOUR PRODUCTION SYSTEM!!**",80)
 W !!,"This scrambling procedure is done in two parts.  First, NEW PERSON"
 W !,"records will be scrambled along with its associated record in PAID"
 W !,"EMPLOYEE if any.  A tracking node is kept in the PAID EMPLOYEE file"
 W !,"denoting records that have been scrambled.  After all records in NEW"
 W !,"PERSON have been scrambled, part two of this procedure looks for any"
 W !,"PAID EMPLOYEE records that have not been flagged.  The records will"
 W !,"then be scrambled separately."
 W !!,"CAUTION:  ONCE SCRAMBLED, THESE FILES CANNOT BE UN-SCRAMBLED.  USER"
 W !,"AND EMPLOYEE NAMES, SSNs, ETC. WILL BE COMPLETELY UNRECOGNIZABLE."
 W !,"BE ABSOLUTELY CERTAIN THAT YOU WANT TO DO THIS AND WHY YOU'RE DOING IT."
 W !!,"Additionally, if you plan to use the DISUSER option, it is likely"
 W !,"that you will NOT be able to decipher user names to exclude."
 ;
 W !!,"There are ",+$P(^VA(200,0),"^",4)," NEW PERSON records."
 ;DSS/RAC - BEGIN MODS- Dose file 450 exist
 ;W " and ",+$P(^PRSPC(0),"^",4)," PAID EMPLOYEE records."
 W:$G(^PRSPC(0))'="" " and ",+$P(^PRSPC(0),"^",4)," PAID EMPLOYEE records."
 ;DSS/RAC - END MODS
 W !,"Log-ins should be disabled and no users on the system while this runs."
 S DIR(0)="YA"
 S DIR("A")="Are you ABSOLUTELY CERTAIN it is okay to continue? "
 S DIR("B")="NO"
 W ! D ^DIR K DIR
 I Y'=1 W "  ABORTED!" Q
 ;
RESTART ; in the event of an error or some other reason the scrambler is
 ; stopped, this module can be called to restart from the last record
 ; completed (stored in $P(^XTMP("NVSPDS4"),"^",1))...
 W !!,"NEW PERSON and PAID EMPLOYEE file scrambler starting "
 W $$FMTE^XLFDT($$NOW^XLFDT)
 I '$D(^XTMP("NVSPDS4",0)) D
 .S ^XTMP("NVSPDS4",0)="0^0"
 .S ^XTMP("NVSPDS4","SSN")="0^0^0"
 S IEN200=+$P(^XTMP("NVSPDS4",0),"^")
 F  S IEN200=$O(^VA(200,IEN200)) Q:'IEN200  D
 .; don't scramble POSTMASTER and SHARED,MAIL...
 .I IEN200'>.9 Q
 .W !!,"NEW PERSON record ",IEN200
 .I $G(^VA(200,IEN200,0))="" W !?2,"No zero-eth node...200 scramble aborted."
 .;
 .; scramble the New Person file record...
 .I $G(^VA(200,IEN200,0))'="" D S200(IEN200) W "...done"
 .S $P(^XTMP("NVSPDS4"),"^")=IEN200
 .;
 .; scramble this PERSON's PAID EMPLOYEE record (if it exists)...
 .S IEN450=+$G(^VA(200,IEN200,450))
 .I IEN450'>0 W !?2,"No PAID EMPLOYEE record." K IEN450 Q
 .W !?2,"PAID EMPLOYEE record ",IEN450
 .I $D(^PRSPC(IEN450,"ZZNVSPDS")) W !?2,"done" Q
 .D S450(IEN450,IEN200)
 .S ^PRSPC(IEN450,"ZZNVSPDS")=""
 .S $P(^XTMP("NVSPDS4"),"^",2)=IEN450
 .W !?2,"done"
 ;
 ; now, run through the records in file 450 and scramble any that didn't
 ; have a file 200 record...
 ;DSS/RAC - BEGIN MODS- Dose file 450 exist
 I $G(^PRSPC(0))="" G REIND
 ;DSS/RAC - END MODS
 W !!,"Done with NEW PERSON file records.  Now, checking for any un-scrambled"
 W !,"records in PAID EMPLOYEE..."
 S IEN450=0
 F  S IEN450=$O(^PRSPC(IEN450)) Q:'IEN450  D
 .I $D(^PRSPC(IEN450,"ZZNVSPDS")) Q
 .W !!?2,"Record number ",IEN450
 .D S450(IEN450,0)
 .W !?2,"done"
 ;
 ;DSS/RAC - BEGIN MODS-re-index...
REIND ;
 ;DSS/RAC - END MODS
 W !!,"Re-indexing file 200"
 K ^VA(200,"B")
 K ^VA(200,"BS")
 K ^VA(200,"BS5")
 K ^VA(200,"C")
 K ^VA(200,"D")
 K ^VA(200,"SSN")
 S X=0
 S IEN200=.9
 F  S IEN200=$O(^VA(200,IEN200)) Q:'IEN200  D
 .S X=X+1
 .I '(X#100) W "."
 .S NVSDATA(0)=$G(^VA(200,IEN200,0))
 .S NVSDATA(.1)=$G(^VA(200,IEN200,.1))
 .S NVSDATA(1)=$G(^VA(200,IEN200,1))
 .S NAME200=$P(NVSDATA(0),"^")
 .S SSN200=$P(NVSDATA(1),"^",9)
 .S INIT200=$P(NVSDATA(0),"^",2)
 .S NICK200=$P(NVSDATA(.1),"^",4)
 .I NAME200'="" D
 ..S ^VA(200,"B",NAME200,IEN200)=""
 .I SSN200'="" D
 ..S ^VA(200,"BS",$E(SSN200,1,4),IEN200)=""
 ..S ^VA(200,"BS5",($E(NAME200)_$E(SSN200,6,9)),IEN200)=""
 ..S ^VA(200,"SSN",SSN200,IEN200)=""
 .I INIT200'="" D
 ..S ^VA(200,"C",INIT200,IEN200)=""
 .I NICK200'="" D
 ..S ^VA(200,"D",NICK200,IEN200)=""
 .K INIT200,NAME200,NICK200,NVSDATA,SSN200
 K IEN200
 W "done."
 ;
 ;
 ;DSS/RAC - BEGIN MODS- Dose file 450 exist
 I $G(^PRSPC(0))="" G DONE
 ;DSS/RAC - END MODS
 W !!,"Re-indexing file 450..."
 S X="ATL"
 F  S X=$O(^PRSPC(X)) Q:X=""!($E(X,1,3)'="ATL")  K ^PRSPC(X)
 K ^PRSPC("B")
 K ^PRSPC("BS")
 K ^PRSPC("BS1")
 K ^PRSPC("SSN")
 S (IEN450,X)=0
 F  S IEN450=$O(^PRSPC(IEN450)) Q:'IEN450  D
 .S X=X+1
 .I '(X#100) W "."
 .S NAME450=$P($G(^PRSPC(IEN450,0)),"^")
 .S ATL450=$P($G(^PRSPC(IEN450,0)),"^",8)
 .S SSN450=$P($G(^PRSPC(IEN450,0)),"^",9)
 .I NAME450'="" D
 ..S ^PRSPC("B",NAME450,IEN450)=""
 .I SSN450'="" D
 ..S ^PRSPC("BS",($E(NAME450)_$E(SSN450,6,9)),IEN450)=""
 ..S ^PRSPC("BS1",($E(NAME450)_$E(SSN450,6,9)),IEN450)=""
 ..S ^PRSPC("SSN",SSN450,IEN450)=""
 .I ATL450'="" D
 ..S ^PRSPC("ATL"_ATL450,NAME450,IEN450)=""
 K ATL450,IEN450,NAME450,SSN450
 ;DSS/RAC - BEGIN MODS- Dose file 450 exist
DONE ;
 ;DSS/RAC - END MOD
 W "done."
 ;
 ; finished...
 W !!,"NEW PERSON and PAID EMPLOYEE file scramblers completed "
 W $$FMTE^XLFDT($$NOW^XLFDT)
 S DIR(0)="YA"
 S DIR("A")="Okay to delete the tracking global ^XTMP(""NVSPDS4"")? "
 S DIR("B")="YES"
 S DIR("?")="Unless you have a reason to keep it, answer YES to delete it."
 W ! D ^DIR K DIR
 I Y=1 D
 .W !!,"Okay...cleaning up...a moment please..."
 .S IEN=0
 .F  S IEN=$O(^PRSPC(IEN)) Q:'IEN  K ^PRSPC(IEN,"ZZNVSPDS")
 .K ^XTMP("NVSPDS4") W "done."
 E  W !,"NO clean up done -- tracking global still defined."
 Q
 ;
S200(IEN)       ; scramble NEW PERSON file record...
 ; IEN = record number in file 200 to be scrambled
 N D200,I,IEN20,INIT200,NAME200,NICK200,SSN200
 ;DSS/RAC - BEGIN MODS - Do not scramble if user is in the 
 ; exclusion file, but scramble DEA if exists.
 I $$VFD^NVSPDS(200,IEN) D DEA Q
 ;DSS/RAC END MODS 
 S D200(0)=^VA(200,IEN,0)
 S NAME200=$P(D200(0),"^")
 ; get record number in NAME COMPONENT file...
 S IEN20=+$O(^VA(20,"C",NAME200,0))
 S INIT200=$P(D200(0),"^",2)
 S NICK200=$P($G(^VA(200,IEN,.1)),"^",4)
 S SSN200=$P($G(^VA(200,IEN,1)),"^",9)
 W !?4,"Name: ",NAME200
 ;DSS/RAC - BEGIN MOD - Vx scramble send sex to scramble name
 I $D(^TMP("VFDNVS01",$J)) S NAME200=$$NAME^VFDNVS02($P(^VA(200,IEN,1),U,4))
 I '$D(^TMP("VFDNVS01",$J)) S NAME200=$$REVN^NVSPDSU(NAME200)
 ;DSS/RAC - END MODS
 S INIT200=$$REVN^NVSPDSU(INIT200)
 S NICK200=$$REVN^NVSPDSU(NICK200)
 W " scrambled to ",NAME200
 S $P(D200(0),"^")=NAME200
 S $P(D200(0),"^",2)=INIT200
 S ^VA(200,IEN,0)=D200(0)
 S $P(^VA(200,IEN,.1),"^",4)=NICK200
 ;
 ; update NAME COMPONENT file with scrambled name components...
 I +IEN20 D
 .S NAME20X=$TR(NAME200,",","^")
 .S NAME20=$TR(NAME20X," ","^")
 .S NAMLAST=$P(NAME20,"^")
 .S NAMFIRST=$P(NAME20,"^",2)
 .S NAMMIDL=$P(NAME20,"^",3)
 .S DIE="^VA(20,"
 .S DA=IEN20
 .S DR="1///^S X=NAMLAST"
 .I NAMFIRST'="" S DR=DR_";2///^S X=NAMFIRST"
 .I NAMMIDL'="" S DR=DR_";3///^S X=NAMMIDL"
 .D ^DIE
 .K DA,DIE,DR,NAMFIRST,NAMLAST,NAMMIDL
 ;
 ; electronic signature block...
 S ESIGBLK=$P($G(^VA(200,IEN,20)),"^",2)
 I ESIGBLK'="" D
 .S ESIGBLK=$$REVN^NVSPDSU(ESIGBLK)
 .S $P(^VA(200,IEN,20),"^",2)=ESIGBLK
 K ESIGBLK
 ;
 ; ssn...
 S SSN200X=0
 W !?4,"SSN: "
 D SSN(.SSN200)
 I SSN200'="COMPLETE" D
 .S $P(^VA(200,IEN,1),"^",9)=SSN200
 .S SSN200X=1
 I SSN200="COMPLETE" S SSN200=$P(^VA(200,IEN,1),"^",9)
 W SSN200
 I SSN200X'=1 W "*NOT SCRAMBLED*",!?4
 ;
 ; address...
 W "...address"
 S D200(.11)=$G(^VA(200,IEN,.11))
 F I=1:1:4 D
 .I $P(D200(.11),"^",I)="" Q
 .S $P(D200(.11),"^",I)=$$REVN^NVSPDSU($P(D200(.11),"^",I))
 S $P(D200(.11),"^",6)="00001"
 S ^VA(200,IEN,.11)=D200(.11)
 ;
 ; temp address...
 W "...temp address"
 S D200(.121)=$G(^VA(200,IEN,.121))
 F I=1:1:4 D
 .I $P(D200(.121),"^",I)="" Q
 .S $P(D200(.121),"^",I)=$$REVN^NVSPDSU($P(D200(.121),"^",I))
 S $P(D200(.121),"^",6)="00001"
 S ^VA(200,IEN,.121)=D200(.121)
 ;
 ; delete phone numbers...
 W "...phone #s"
 S ^VA(200,IEN,.13)="^^^^^^^^"
 ;
 ; delete email address...
 W "...email address"
 S ^VA(200,IEN,.15)="^"
 ;
 ; delete alias(es)...
 W !?4,"...aliases"
 K ^VA(200,IEN,3)
 S ^VA(200,IEN,3,0)="^200.04^^"
 ;
 ; delete network address...
 W "...network address"
 K ^VA(200,IEN,500)
 S ^VA(200,IEN,500,0)="^200.005A^^"
 ;
 ;DSS/RAC - BEGIN MODS - Generate DEA # if user currently defined
 ;
DEA ;
 N DEA,NDEA
 Q:'$D(^VA(200,IEN,"PS"))
 S NDEA=""
 S DEA=$P(^VA(200,IEN,"PS"),U,2)
 Q:DEA=""
 S NDEA=$$DEA^VFDNVS02(IEN,DEA)
 S $P(^VA(200,IEN,"PS"),U,2)=NDEA
 Q
 ;
 ;DSS/RAC - END MODS
 ;
S450(IEN450,IEN200)     ; scramble PAID EMPLOYEE file record...
 ; IEN450 = record number in file 450 to be scrambled
 ; IEN200 = associated file 200 record (name, ssn, etc. will be used from 200)
 ;          if IEN200 is passed = 0, then that means there is no file 200
 ;          entry for this PAID EMPLOYEE record.  this module will scramble
 ;          the file 450 data anyway...
 N D450,I,NAME200,NAME450,NICK200,SSN200,SSN450
 S D450(0)=$G(^PRSPC(IEN450,0))
 I D450(0)="" Q
 S NAME450=$P(D450(0),"^")
 W !?4,"Name: ",NAME450
 S SSN450=$P(D450(0),"^",9)
 ; if a file 200 record exists, get name and ssn...
 I IEN200>0 D
 .S NAME200=$P(^VA(200,IEN200,0),"^")
 .S SSN200=$P(^VA(200,IEN200,1),"^",9)
 ; if a file 200 record does not exist, scramble the 450 name and ssn...
 I IEN200=0 D
 .S NAME200=$$REVN^NVSPDSU(NAME450)
 .D SSN(.SSN200)
 .I SSN200="COMPLETE" S SSN200=SSN450
 W " scrambled to ",NAME200
 W !?4,"SSN ",SSN200
 S $P(^PRSPC(IEN450,0),"^")=NAME200
 S $P(^PRSPC(IEN450,0),"^",9)=SSN200
 ; clean up address node while here
 W "...address"
 S D450("ADD")=$G(^PRSPC(IEN450,"ADD"))
 I D450("ADD")="" Q
 ; delete check mailing address...
 W "...check mailing address"
 F I=1:1:5 S $P(D450("ADD"),"^",I)=""
 ; scramble current address node...
 W "...current address"
 S $P(D450("ADD"),"^",8)=$$CITY^NVSPDSU
 S $P(D450("ADD"),"^",6)=+$$ST^NVSPDSU
 S $P(D450("ADD"),"^",10)=$$ZIP^NVSPDSU($P(D450("ADD"),"^",10))
 S ^PRSPC(IEN450,"ADD")=D450("ADD")
 S ^PRSPC(IEN450,"ZZNVSPDS")=""
 Q
 ;
SSN(X) ; create an SSN...
 ; X is passed by reference = "" and returned with the created SSN
 ; note:  uses the node ^XTMP("NVSPDS4","SSN" to maintain last created SSN used
 N F3,I,L4,M2,XSSN
 I $G(^XTMP("NVSPDS4","SSN"))="" S ^XTMP("NVSPDS4","SSN")="0^0^0"
 S XSSN=""
 F I=1:1:3 S XSSN=XSSN_$P(^XTMP("NVSPDS4","SSN"),"^",I)
 I XSSN=999999999 S X="COMPLETE" Q
 ;
 S $P(^XTMP("NVSPDS4","SSN"),"^",3)=$P(^XTMP("NVSPDS4","SSN"),"^",3)+1
 I $P(^XTMP("NVSPDS4","SSN"),"^",3)>9999 D
 .S $P(^XTMP("NVSPDS4","SSN"),"^",3)=1
 .S $P(^XTMP("NVSPDS4","SSN"),"^",2)=$P(^XTMP("NVSPDS4","SSN"),"^",2)+1
 .I $P(^XTMP("NVSPDS4","SSN"),"^",2)>99 D
 ..S $P(^XTMP("NVSPDS4","SSN"),"^",2)=1
 ..S $P(^XTMP("NVSPDS4","SSN"),"^")=$P(^XTMP("NVSPDS4","SSN"),"^")+1
 ;
 S L4=$P(^XTMP("NVSPDS4","SSN"),"^",3)
 I $L(L4)<4 D
 .F I=1:1 Q:$L(L4)=4  S L4="0"_L4
 S M2=$P(^XTMP("NVSPDS4","SSN"),"^",2)
 I $L(M2)'=2 S M2="0"_M2
 S F3=$P(^XTMP("NVSPDS4","SSN"),"^")
 I $L(F3)<3 D
 .F I=1:1 Q:$L(F3)=3  S F3="0"_F3
 S X=F3_M2_L4
 Q 
