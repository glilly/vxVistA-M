VFDNVS01 ;DSS/RAC-scramble patient data in test system ;18 July 2011 9:00
 ;;6.0;EMC TEST ACCOUNT RESET UTILITIES; 13 Jun 2011;;Build 24
 ;Copyright 1995-2011,Document Storage Systems Inc. All Rights Reserved
 ;
 ;
 ; ICR#  Supported Description
 ;-----  ----------------------------------------------------------
 ;       ^%ZIS
 ;       ^%ZISC
 ;       FILE^DIE
 ;       UPDATE^DIE
 ;       ^DIR          
 ;
 ; This is a leader routine for the scrambler of Patient/User,
 ; calls are made to NVSPDS and NVSPDS4.
 ;
EN ;Entry point for option
 N DIR,DTOUT,DUOUT,DIRUT,DIROUT,Z,Y
 S DTIME=100
 I $D(^TMP("VFDNVS01")) K ^TMP("VFDNVS01")
 S Z=$$SCRHDR  ;Display screen header
 Q:Z<1!(Z="")
 I Z=2 S ^TMP("VFDNVS01",$J)=Z_U_$$NOW^XLFDT
 D SCRAM  ;Scramble person's data
 I $D(^TMP("VFDNVS01",$J)) D:$D(^TMP("VFDNVS01",$J)) ALL^VFDNVSPN
 D USCRAM
END ;
 K ^TMP("VFDNVS01",$J)
 Q
 ;
EPU ;Entry point - Exclusion of patients and users
 N DIR,DTOUT,DUOTU,DIRUT,DIROUT,Z
 I $G(IOF)'="" W @IOF
EPU1 ;
 S DIR("?")="  "
 S DIR("?",1)="You have the option to choose records that are excluded"
 S DIR("?",2)="from being scrambled.  You can enter Patients and Users."
 S DIR(0)="SA^1:Enter/Edit;2:List Exclusions"
 S DIR("A")="Select your option (1-2): "
 S DIR("A",1)=" Exclusion Menu"
 S DIR("A",2)=" "
 S DIR("A",3)="   1 : Enter/Edit Persons to be Excluded"
 S DIR("A",4)="   2 : List Persons to be excluded from Scrambling"
 S DIR("A",5)=" "
 S DIR("B")=""
 S Z=$$DIR(.DIR)
 Q:Z<1!(Z="")
 I Z=1 D SCMADD G EPU1
 I Z=2 D SCMLST G EPU1
 G EPU1
 ;
 ;-----------------------  PRIVATE SUBROUTINES  ----------------------
 ;
DIR(DIR) ;
 N DIROUT,DIRUT,DTOUT,DUOUT,Z
 D ^DIR
 S Z=$S($D(DIRUT):-1,$D(DIROUT):-2,$D(DTOUT):-3,1:Y)
 Q Z
 ;
SCMADD ;Add/Edit patients/new person to exclude from scrambling
 N DA,DR,DIE,DIC,Y
 S DIC=21619,DIC(0)="AELQZ" D ^DIC Q:+Y'>0
 S DIE="^VFD(21619,",DA=$P(Y,U),DR=.01 D ^DIE
 Q:$D(DUOUT)!($D(DTOUT))
 G SCMADD
 ;
HDR ;
 ;;              Person's NOT to be Scrambled
 ;;
 ;;  IEN      NAME                            FILE
 ;;-------  ------------------------------  ------------------------
 W @IOF W !,$P($T(HDR+1),";",3)
 N II F II=2,3,4 W !,$P($T(HDR+II),";",3)
 Q
 ;
SCRAM ;Scramble patient data
 N DIR,Z
 S DIR("A",1)="              ARE YOU ABSOLUTELY SURE?"
 S DIR("A",2)="  You WILL NOT BE ABLE TO RECOVER the original data!!!"
 S DIR("A",3)=" "
 S DIR("A")="  Are you SURE you want to scramble PATIENT data? "
 S DIR(0)="YA",DIR("B")="N"
 Q:$$DIR(.DIR)<1
 D PDS^NVSPDS  ;Scrambler for patients
 Q
 ;
SCMLST ;List patient/new person
 N IEN,L1,PCNT,POP,UCNT,VFDF,VFDLST,VFDN,VFDX,VFDY,VFDZ
 D ^%ZIS Q:POP  U IO D HDR
 S VFDX="",PCNT=0,UCNT=0
 F  S VFDX=$O(^VFD(21619,"B",VFDX)) Q:'VFDX  D
 .S VFDY=""
 .F  S VFDY=$O(^VFD(21619,"B",VFDX,VFDY)) Q:'VFDY  D
 ..S IEN=$P(VFDX,";"),VFDF=$P(VFDX,";",2),VFDZ="^"_VFDF_IEN_",0)"
 ..S VFDN=$G(@VFDZ)
 ..W !,IEN,?9,$P(VFDN,U),?41
 ..W:VFDF["V" "User File"
 ..W:VFDF["D" "Patient File"
 ..S:VFDF["V" UCNT=UCNT+1
 ..S:VFDF["D" PCNT=PCNT+1
 W !!," Total number of Patient excluded from Scrambling is ",PCNT
 W !," Total number of Users excluded from Scrambling is ",UCNT
 W !!,"   Total number of persons excluded from Scrambling is ",PCNT+UCNT
 D ^%ZISC
 Q
 ;
SCRHDR()  ;Screen Header
 N DIR
 W @IOF
 S DIR("?")="  "
 S DIR("?",1)="   The VA scrambler method does the following:"
 S DIR("?",2)="   * Patient File (#2) demographic data and Users file (#200) names"
 S DIR("?",3)="     * Scramble the name with random letters."
 S DIR("?",4)="       Presenting names like 'AKKFOI,MMD'."
 S DIR("?",5)=" "
 S DIR("?",6)="   The vxScrambler method does the following:"
 S DIR("?",7)="   * Patient File (#2) demographic data, HIS Patient File(#9000001)"
 S DIR("?",8)="         and Users file (#200) names"
 S DIR("?",9)="     ** Names are realistic, based on the following:"
 S DIR("?",10)="       * First Name is randomly selected based on sex"
 S DIR("?",11)="         from the postmaster record in file# 21619"
 S DIR("?",12)="       * Last Name is randomly selected from the post-"
 S DIR("?",13)="         master record in file# 21619."
 S DIR("?",14)="   * Option to scramble Progress Notes"
 S DIR("?",15)="   * Allows the exclusion of both Patients and Users"
 S DIR("?",16)="   * If the DEA # is populated generate new DEA #"
 S DIR("?",17)="     based on the DEA requirements algorithm"
 S DIR("?",18)=" "
 S DIR(0)="SA^1:VA Scambler;2:vxScrambler"
 S DIR("A")="Select your option (1-2): "
 S DIR("A",1)=" Scramble Patient and User Data Menu"
 S DIR("A",2)=" "
 S DIR("A",3)="   1 : VA Scrambler"
 S DIR("A",4)="   2 : vxScrambler"
 S DIR("B")=""
 S Z=$$DIR(.DIR)
 Q Z
 ;
USCRAM ;Scramble user data
 N DIR,Z
 S DIR("A",1)="              ARE YOU ABSOLUTELY SURE?"
 S DIR("A",2)="  You WILL NOT BE ABLE TO RECOVER the original data!!!"
 S DIR("A",3)=" "
 S DIR("A")="  Are you SURE you want to scramble USER data? "
 S DIR(0)="YA",DIR("B")="N"
 Q:$$DIR(.DIR)<1
 D ^NVSPDS4  ;Scrambler for users - File 200
 Q
