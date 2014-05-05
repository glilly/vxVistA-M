NVSPDS ;emciss/maw-scramble patient data in test system ; 09/01/02
 ;;6.0;EMC TEST ACCOUNT RESET UTILITIES; 01 Jun 1999;;Build 24
 ;
 ; original concept taken from routine ZDWGTDEM (author unknown).
 ; additional input to this procedure was provided by Warren Wright at
 ; VAMC Huntington, WV and Jack Snyder at VAMC Danville, IL.
 ;
 ;
 F  D  Q:$D(DIRUT)
 .I $G(IOF)'="" W @IOF
 .W !!,"ENTERPRISE MANAGEMENT CENTER :: TEST ACCOUNT RESET UTILITIES"
 .W !,"DATA SCRAMBLERS AND USER ACCESS UTILITIES"
 .W !!,"Note:  these are OPTIONAL procedures"
 .S DIR(0)="SA^1:PDS;2:NPPE;3:DISUSER;4:QUIT"
 .S DIR("A")="Select OPTION (1-4): "
 .S DIR("A",1)="  [1] Patient Data Scrambler"
 .S DIR("A",2)="  [2] New Person/Paid Employee Scrambler"
 .S DIR("A",3)="  [3] DISUSER User Accounts"
 .S DIR("A",4)="  [4] QUIT"
 .S DIR("A",5)=" "
 .S DIR("B")="4"
 .W !
 .D ^DIR K DIR
 .I +Y=4 S DIRUT=1
 .I $D(DIRUT) Q
 .S NVSOPT=+Y
 .I NVSOPT=1 D PDS Q
 .I NVSOPT=2 D ^NVSPDS4 Q
 .I NVSOPT=3 D ^NVSPDS6
 .K DIRUT,DTOUT,X,Y
 Q
PDS ;
 D HOME^%ZIS
 I $G(IOF)'="" W @IOF
 I '$D(DUZ) D
 .S DUZ=.5
 .S DUZ(0)="@"
 D DT^DICRW
 W !!,"ENTERPRISE MANAGEMENT CENTER :: PATIENT DATA SCRAMBLER UTILITY"
 ; make sure we're in the right place to run this utility...
 I '$D(NVSUCI) S NVSQUIT=0 D  I NVSQUIT'=0 K NVSOPSYS,NVSQUIT,NVSUCI Q
 .X $G(^%ZOSF("UCI"))
 .I '$D(Y) D  Q
 ..W $C(7)
 ..W !!,"ERROR:  UCI COULD NOT BE DETERMINED!  ABORTING!"
 ..S NVSQUIT=1
 .S NVSUCI=Y
 .S NVSOPSYS=$P($G(^%ZOSF("OS"),"undefined"),U)
 .;
 .W !!,"Current UCI: ",NVSUCI
 .I NVSUCI'["TST"&(NVSUCI'["TOU") D
 ..W $C(7)
 ..W !!,"WARNING:  THIS ACCOUNT DOESN'T APPEAR TO BE YOUR TEST SYSTEM!"
 ..W !,"MAKE SURE YOU'RE RUNNING THIS UTILITY IN YOUR TEST SYSTEM!"
 .S DIR(0)="YA"
 .S DIR("A")="Okay to continue? "
 .S DIR("B")="NO"
 .W ! D ^DIR K DIR
 .I Y'=1!($D(DIRUT)) D  Q
 ..S NVSQUIT=1
 ..W !!,"Patient File Scrambler aborted!"
 ..K DIRUT,DTOUT,X,Y
 .;
 .; check for existence of the process tracking global...
 .I $G(^XTMP("NVSPDS",0))="" D
 ..S NVSNOW=$$DT^XLFDT
 ..S X1=NVSNOW
 ..S X2=10
 ..D C^%DTC
 ..S ^XTMP("NVSPDS",0)=X_U_NVSNOW_U_"NVS Patient Data Scrambler Utility"
 ..K NVSNOW,X,X1,X2
 .;
 .I $G(^XTMP("NVSPDS","JOB"))'="" D  I $G(NVSQUIT)'=0 Q
 ..W !!,"The Patient Data Scrambler process tracking global"
 ..W !,"already exists in this account."
 ..W !!,"It was created ",$P(^XTMP("NVSPDS","JOB"),U)
 ..W !,"and contains these statistics:"
 ..W !!,"Total records in ^DPT: "
 ..W ?34,$J(+$P(^XTMP("NVSPDS","JOB"),U,5),10)
 ..W !,"Total records processed so far:"
 ..W ?34,$J(+$P(^XTMP("NVSPDS","JOB"),U,6),10)
 ..W !,"Last DFN processed:"
 ..W ?34,$J(+$P(^XTMP("NVSPDS","JOB"),U,4),10)
 ..W !!,"Caution:  if you choose to reset and start from the beginning,"
 ..W !,"any patient names already scrambled will be UNSCRAMBLED.  There may"
 ..W !,"be other problems, too.  It is recommended that you restart from"
 ..W !,"the last DFN processed."
 ..W !!,"Your options are:"
 ..S DIR(0)="SA^1:Reset/Restart;2:Restart;3:Quit"
 ..S DIR("A")="Select your option (1-3): "
 ..S DIR("A",1)="  1 : Reset the tracking global and restart from beginning"
 ..S DIR("A",2)="  2 : Restart from last DFN processed"
 ..S DIR("A",3)="  3 : Quit and take NO action"
 ..S DIR("A",4)=" "
 ..S DIR("B")="3"
 ..W !
 ..D ^DIR K DIR
 ..I $D(DIRUT)!(Y=3) S NVSQUIT=1 Q
 ..I Y'=1 Q
 ..K ^XTMP("NVSPDS","JOB")
 ..K ^XTMP("NVSPDS","E")
 ..K ^XTMP("NVSPDS","FATAL_ERROR")
 .;
 .I $G(^XTMP("NVSPDS","JOB"))="" D
 ..S ^XTMP("NVSPDS","JOB")=$$FMTE^XLFDT($$NOW^XLFDT)_"^0^^^^0"
 ..W !!,"I need to get an ACCURATE count of total number of"
 ..W !,"patient records...this may take a while, please be patient..."
 ..S $P(^XTMP("NVSPDS","JOB"),U,5)=$$DPTTOT^NVSPDSU
 ..W !!,"The record count in $P(^DPT(0),""^"",4)=",+$P(^DPT(0),U,4)
 ..W !,"The count I just completed=",+$P(^XTMP("NVSPDS","JOB"),U,5)
 .;
 .; if the global exists, ask to clear any errors...
 .I $D(^XTMP("NVSPDS","E")) D
 ..W !!,"Error notes exist in the tracking global."
 ..S DIR(0)="YA"
 ..S DIR("A")="Okay to delete them? "
 ..S DIR("B")="NO"
 ..W ! D ^DIR K DIR
 ..I Y=1 D  Q
 ...K ^XTMP("NVSPDS","E")
 ...W !,"  okay, errors deleted."
 ..W !!,"Okay, I'll append any errors found during this run of the"
 ..W !,"Patient Data Scrambler to the existing error list."
 ..W !,"Note that the last error number currently on file is "
 ..W $O(^XTMP("NVSPDS","E",0),-1)
 K NVSQUIT
 ;
 ; set the error trap...
 S $ZT="ET^NVSPDSU"
 ;
 ; set the progress screen...
 S NVSSTR=""
 S NVSIDTOT=+$P(^XTMP("NVSPDS","JOB"),U,5)
 S NVSCOUNT=+$P(^XTMP("NVSPDS","JOB"),U,6)
 D INIT^NVSPDSU1
 I NVSIDVT D
 .D TITLE^NVSPDSU1("TEST ACCOUNT PATIENT DATA SCRAMBLER")
 ;
 W !!,"Job beginning "
 S $P(^XTMP("NVSPDS","JOB"),U,3)=$$FMTE^XLFDT($$NOW^XLFDT)
 W $P(^XTMP("NVSPDS","JOB"),U,3)
 ;
 ; delete IVM xrefs from the Patient file...
 I '$D(^XTMP("NVSPDS","DELETE_XREFS")) D
 .W !!,"Permanently removing some undesired x-refs from the Patient file..."
 .D XREF^NVSPDSU1
 .S ^XTMP("NVSPDS","DELETE_XREFS")=$H
 ;
 ; temporarily move the notifications node from the MAS PARAMETERS file from
 ; ^DG(43,x,"NOT") to ^DG(43,x,"NVSNOT").  this will prevent alerts, bulletins,
 ; etc.  we'll put it back when were done, but if a fatal error should occur,
 ; the site may need to reset the node manually...
 I '$D(^XTMP("NVSPDS","MAS_XREFS")) D
 .W !!,"Temporarily moving notifications out of the MAS PARAMETERS file..."
 .S NVSX=0
 .F  S NVSX=$O(^DG(43,NVSX)) Q:'NVSX  D
 ..I $D(^DG(43,NVSX,"NVSNOT")) Q
 ..S NVSY=$G(^DG(43,NVSX,"NOT"))
 ..S ^DG(43,NVSX,"NOT")=""
 ..S ^DG(43,NVSX,"NVSNOT")=NVSY
 ..K NVSY
 .K NVSX
 .S ^XTMP("NVSPDS","MAS_XREFS")=$H
 .W "done."
 ;
 ; launch the procedure..
 ;
 ; **NOTE:  if this module stops due to a fatal error, or by programmer
 ;          intervention, restart it by D ^NVSPDS.  it will pick up from
 ;          the point where it stopped.
 ;
 W !!,"Any errors encountered will be displayed here, and logged in the tracking"
 W !,"global for later reference."
 W !!,"There are ",+$P(^XTMP("NVSPDS","JOB"),U,5)," total records to process.",!
 I $P(^XTMP("NVSPDS","JOB"),U,6)>0 D
 .W !,"Note ---> Records processed so far = "
 .W $P(^XTMP("NVSPDS","JOB"),U,6)
 ;
RESTART ; if fatal error occurs, the error is trapped and handled in ^NVSPDSU and
 ; restarted by a call to this entry point...
 S U="^"
 I '$D(^DPT("ANVSPDS","SSN")) S ^DPT("ANVSPDS","SSN")="0^0"
 S NVSIDTOT=+$P($G(^XTMP("NVSPDS","JOB")),U,5)
 I NVSIDTOT'>0 D
 .S $P(^XTMP("NVSPDS","JOB"),U,5)=$$DPTTOT^NVSPDSU
 .S NVSIDTOT=+$P($G(^XTMP("NVSPDS","JOB")),U,5)
 S NVSCOUNT=+$P($G(^XTMP("NVSPDS","JOB")),U,6)
 S NVSDFN=+$P($G(^XTMP("NVSPDS","JOB")),U,4)
 F  S NVSDFN=$O(^DPT(NVSDFN)) Q:'NVSDFN  D
 .W !,"Record # ",NVSDFN
 .S $P(^XTMP("NVSPDS","JOB"),U,4)=NVSDFN
 .S NVSCOUNT=$G(NVSCOUNT)+1
 .S $P(^XTMP("NVSPDS","JOB"),U,6)=NVSCOUNT
 .I '(NVSCOUNT#1000) D
 ..W !!?5,"** STATUS **"
 ..W !?5,$$FMTE^XLFDT($$NOW^XLFDT)
 ..W !?7,"Total records     = ",$J($P(^XTMP("NVSPDS","JOB"),U,5),8)
 ..W !?7,"Records processed = ",$J(NVSCOUNT,8)
 ..W !?7,"Records remaining = ",$J((NVSIDTOT-NVSCOUNT),8)
 ..W !!?5,"************"
 ..R NVSXX:5
 ..K NVSXX
 .;
 .; initial record check...
 .; if this is not a valid record (e.g., merged, marked-as-duplicate record, or incomplete)
 .; forget it.  Note that merged records are dealt with after Scrambler has completed...
 .S NVSOK=1
 .I $G(^DPT(NVSDFN,0))="" S NVSOK=0
 .I +$G(^DPT(NVSDFN,-9)) S NVSOK=0
 .I +$P($G(^DPT(NVSDFN,0)),"^")'=0 S NVSOK=0
 .I $G(^DPT(NVSDFN,"NVS"))'="" S NVSOK=0
 .;DSS/RAC - BEGIN MOD - If in exclusion file skip record & mark as updated
 .I $$VFD(2,NVSDFN) S NVSOK=0,^DPT(NVSDFN,"NVS")=$H
 .;DSS/RAC - END MOD
 .;
 .S NVSDATA=$G(^DPT(NVSDFN,0))
 .; check for DOB, if none create one...
 .I $P(NVSDATA,U,3)="" D
 ..D CDOB^NVSPDSU1(NVSDFN)
 ..S $P(NVSDATA,U,3)=$P($G(^DPT(NVSDFN,0)),U,3)
 ..I $P(NVSDATA,U,3)="" S NVSOK=0
 .;
 .; if the record didn't pass the initial checks, update the counter and quit...
 .I NVSOK'=1 D UPDATE^NVSPDSU1(NVSCOUNT) Q
 .K NVSDATA,NVSOK
 .;
 .; perform the changes for this patient record...
 .D ^NVSPDS1
 .D ^NVSPDS2
 .D ^NVSPDS3
 .;
 .; update the monitor screen and set the completion flag in this record...
 .D UPDATE^NVSPDSU1(NVSCOUNT)
 .S ^DPT(NVSDFN,"NVS")=$H
 ;
 ; scramble SSNs in all patient records...
 W !!,"Scrambling SSNs..."
 ; need to reset NVSIDTOT to the number of unique last-4 SSNs...
 ;DSS/RAC - BEGIN MOD
 ;S (NVSIDTOT,NVSL4)=0
 ;F  S NVSL4=$O(^DPT("BS",NVSL4)) Q:'NVSL4  S NVSIDTOT=NVSIDTOT+1
 S NVSIDTOT=0,NVSL4=""
 F  S NVSL4=$O(^DPT("BS",NVSL4)) Q:NVSL4=""  S NVSIDTOT=NVSIDTOT+1
 ;DSS/RAC - END MOD
 K NVSL4
 D ^NVSPDS5
 W "done."
 ;
 ; re-index the "ADOB" and "B" x-refs in the Patient file...
 W !!,"Re-indexing Patient file cross references"
 W !?2,"Deleting ^DPT(""ADOB"",...)"
 K ^DPT("ADOB") W " -- done."
 W !?2,"Deleting ^DPT(""B"",...)"
 K ^DPT("B") W " -- done."
 ;
 W !,"Re-indexing..."
 S NVSIDTOT=$P(^XTMP("NVSPDS","JOB"),"^",5)
 S (NVSCOUNT,NVSDFN)=0
 F  S NVSDFN=$O(^DPT(NVSDFN)) Q:'NVSDFN  D
 .S NVSCOUNT=NVSCOUNT+1
 .D UPDATE^NVSPDSU1(NVSCOUNT)
 .;
 .; deal with merged records...
 .I $D(^DPT(NVSDFN,-9)) D  Q
 ..D MREC^NVSPDSU1(NVSDFN)
 ..K ^DPT(NVSDFN,"NVS")
 .I '$D(^DPT(NVSDFN,"NVS")) Q
 .S NVSDATA=$G(^DPT(NVSDFN,0))
 .I $P(NVSDATA,U)=""!($P(NVSDATA,U,9)="") Q
 .S NVSOK=1
 .D REINDX^NVSPDSU1(NVSDFN,.NVSOK)
 .I NVSOK=0 D ERR^NVSPDSU("Record # "_NVSDFN_" not re-indexed.") Q
 .K ^DPT(NVSDFN,"NVS")
 K NVSOK
 ;
 ; module completed -- put the MAS PARAMETERS notifications node(s) back in place...
 I $D(^XTMP("NVSPDS","MAS_XREFS")) D
 .W !!,"Replacing notifications in the MAS PARAMETERS file..."
 .S NVSX=0
 .F  S NVSX=$O(^DG(43,NVSX)) Q:'NVSX  D
 ..S NVSY=$G(^DG(43,NVSX,"NVSNOT"))
 ..I NVSY="" Q
 ..S ^DG(43,NVSX,"NOT")=NVSY
 ..K ^DG(43,NVSX,"NVSNOT")
 ..K NVSY
 .K ^XTMP("NVSPDS","MAS_XREFS")
 .W "done."
 ;
 ; remove the temporary holding node for SSN scrambling...
 K ^DPT("ANVSPDS","SSN")
 ;
 ; done...
 W !!,"Processing ended ",$$FMTE^XLFDT($$NOW^XLFDT)
 I '$D(^XTMP("NVSPDS","E")) W !!,"No errors or messages in the log."
 I $D(^XTMP("NVSPDS","E")) W !!,"Errors are in the log.  Check global ^XTMP(""NVSPDS"") for details."
 ;
 S DIR(0)="EA"
 S DIR("A")="Press enter to continue..."
 W ! D ^DIR K DIR
 D EXIT^NVSPDSU1("DONE")
 K NVSCOUNT,NVSDFN,NVSNSSN,NVSOPSYS,NVSRECS,NVSUCI,NVSX,DIRUT,DTOUT,X,Y
 S $ZT=""
 Q
 ;
 ;DSS/RAC - BEGIN MODS, called from various points
VFD(FILE,IEN) ;Determine if the person is in the exclusion file
 S FILE=$G(FILE),IEN=$G(IEN)
 I FILE'[2 Q 0
 I 'IEN Q 0
 N VFD,VFDX
 S VFD=$S(FILE=2:"DPT(",FILE=200:"VA(200,")
 S VFDX=IEN_";"_VFD
 Q $O(^VFD(21619,"B",VFDX,0))
