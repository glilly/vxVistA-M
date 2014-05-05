NVSTAR4 ;emc/maw-clean up and reset HL7, CIRN and MPI data and parameters ;09/01/02
 ;;6.0;EMC TEST ACCOUNT RESET UTILITIES; 01 Jun 1999;;Build 24
 ;
 ; NOTE:  the procedures are modularized in this routine so that if an
 ;        error occurs in any one of them, they can be re-run separately.
 ;
RAIMDS ;
 W !!,"CLEAN UP RAI/MDS DATA"
 W !,"This module loops through the WARD LOCATION file (#42) and sets the"
 W !,"RAI/MDS WARD field (#.035) to 0 (zero) to disable any possible HL7"
 W !,"transmissions to a COTS database (reference patch DG*5.3*190)."
 W !?2
 N CNT,NVSIEN
 S (CNT,NVSIEN)=0
 F  S NVSIEN=$O(^DIC(42,NVSIEN)) Q:'NVSIEN  D
 .S $P(^DIC(42,NVSIEN,0),"^",16)=0
 .S CNT=CNT+1
 .I '(CNT#10) W "."
 .I $X>(IOM-10) W !?2
 W !,"Done."
 K NVSIEN
 Q
 ;
HL7 ;
 S NVSNULDV=$P(^XTMP("NVSTAR","NULL DEVICE"),"^",2)
 W !!,"CLEAN UP HL7 PARAMETERS AND DATA"
 W !,"This module goes through the HL LOWER LEVEL PROTOCOL PARAMETER"
 W !,"(#869.2) and HL LOGICAL LINK (#870) and resets or deletes specific HL7"
 W !,"devices/parameters.  Note:  in file 869.2, there is a pointer to the"
 W !,"device file in field 200.01.  During this portion of the procedures, the"
 W !,"device listed in these HL7 file fields are placed out of service, etc."
 W !,"in the Device file (#3.5)."
 ;
HLLP ;
 W !!?2,"HL LOWER LEVEL PROTOCOL file (#869.2)."
 W !?4,"Delete TCP/IP addresses and disable HLLP devices..."
 S NVSI=0
 F  S NVSI=$O(^HLCS(869.2,NVSI)) Q:'NVSI  D
 .;
 .; delete TCP/IP address data...
 .I $D(^HLCS(869.2,NVSI,400)) D
 ..S NVSFILE(869.2,NVSI_",",400.01)="@"
 ..D FILE^DIE("E","NVSFILE","NVSDIERR")
 ..K NVSDIERR,NVSFILE
 .;
 .; check for and disable the hllp device in the Device file...
 .I $D(^HLCS(869.2,NVSI,200)) D
 ..S NVSDATA=^HLCS(869.2,NVSI,200)
 ..S NVSDEV=+NVSDATA
 ..I NVSDEV>0 D DEDIT(NVSDEV,NVSNULDV)
 ..K NVSDATA,NVSDEV
 K NVSI,NVSNULDV
 W "done."
 Q
 ;
HLCS ;
 W !?2,"HL COMMUNICATION SERVER PARAMETERS file (#869.3)."
 W !?4,"Set DEFAULT PROCESSING ID (field .03) to ""T"" for Test..."
 S NVSI=0
 F  S NVSI=$O(^HLCS(869.3,NVSI)) Q:'NVSI  D
 .S NVSFILE(869.3,NVSI_",",.03)="T"
 .D FILE^DIE("E","NVSFILE","NVSDIERR")
 .K NVSDIERR,NVSFILE
 K NVSI
 W "done."
 Q
 ;
HLL ;
 S NVSNULDV=$P(^XTMP("NVSTAR","NULL DEVICE"),"^",2)
 W !?2,"HL LOGICAL LINK file (#870)."
 ; additional code has been added to make this code compatible post-HL*1.6*57...
 W !?4,"Reset the following fields:"
 W !?4,"AUTOSTART (field 4.5)         = ""Disabled"""
 W !?4,"SHUTDOWN LLP ? (field 14)     = ""YES"""
 W !?4,"TCP/IP ADDRESS (field 400.01) = delete any entry found"
 W !?4,"DOMAIN (field .03)            = delete any entry found"
 W !?4,"HLLP DEVICE (field 200.01)    = disable pointed to device in Device file"
 ;
 S NVSI=0
 F  S NVSI=$O(^HLCS(870,NVSI)) Q:'NVSI  D
 .;
 .; set AUTOSTART to disabled...
 .S NVSFILE(870,NVSI_",",4.5)="Disabled"
 .;
 .; set SHUTDOWN LLP ? to YES...
 .S NVSFILE(870,NVSI_",",14)="YES"
 .;
 .; delete TCP/IP address data...
 .I $D(^HLCS(870,NVSI,400)) S NVSFILE(870,NVSI_",",400.01)="@"
 .;
 .; delete pointer to the Domain file...
 .I $D(^HLCS(870,NVSI,0)) S NVSFILE(870,NVSI_",",.03)="@"
 .;
 .;  check for and disable the hllp device in the Device file...
 .I $D(^HLCS(870,NVSI,200)) D
 ..S NVSDATA=$G(^HLCS(870,NVSI,200))
 ..S NVSDEV=+NVSDATA
 ..I NVSDEV>0 D
 ...D DEDIT(NVSDEV,NVSNULDV)
 ..K NVSDATA
 .;
 .D FILE^DIE("E","NVSFILE","NVSDIERR")
 .K NVSDIERR,NVSFILE
 W !?2,"Done."
 K NVSDATA,NVSDEV,NVSNULDV
 Q
 ;
HLMA ;
 W !?2,"HL7 MESSAGE ADMINISTRATION file (#773)."
 W !?4,"Search ^HLMA(""AG"",...) for any records marked"
 W !?4,"'PENDING TRANSMISSION'."
 W !?4,"For any such records found, reset STATUS (field 20)"
 W !?4,"to 'SUCCESSFULLY COMPLETED'."
 I '$D(^HLMA("AG",1)) D
 .W !?2,"Note: there are 0 records marked 'PENDING TRANSMISSION'."
 .W !?2,"The cross reference ^HLMA(""AG"",1,...) is empty."
 I $D(^HLMA("AG",1)) D
 .N NVSC,NVSDATA,NVSFILE,NVSI
 .S NVSC="F ZZ=1:1:10 W $C(8)"
 .S (NVSCOUNT,NVSI)=0
 .F  S NVSI=$O(^HLMA("AG",1,NVSI)) Q:'NVSI  S NVSCOUNT=NVSCOUNT+1
 .W !?4,"Records processed = "
 .W ?26,$J(NVSCOUNT,10)
 .I NVSCOUNT>0 D
 ..S NVSI=0
 ..F  S NVSI=$O(^HLMA("AG",1,NVSI)) Q:'NVSI  D
 ...S NVSCOUNT=NVSCOUNT+1
 ...X NVSC
 ...W $J(NVSCOUNT,10)
 ...S NVSDATA=$G(^HLMA(NVSI,"P"))
 ...; is the record really marked 'PENDING'?  If not, reset the x-ref and move on...
 ...I +NVSDATA'=1 D  Q
 ....K ^HLMA("AG",1,NVSI)
 ....; if the pointer at +NVSDATA exists in ^HL(771.6, correct the x-ref...
 ....I $D(^HL(771.6,+NVSDATA,0)) S ^HLMA("AG",+NVSDATA,NVSI)=""
 ....K NVSDATA
 ...; reset the STATUS field to 3 (SUCCESSFULLY COMPLETED) and reset the x-ref...
 ...S $P(^HLMA(NVSI,"P"),"^")=3
 ...K ^HLMA("AG",1,NVSI)
 ...S ^HLMA("AG",3,NVSI)=""
 .W !?2,"Done."
 ;
 W !!?2,"Deleting the cross reference ^HLMA(""AC"")..."
 K ^HLMA("AC")
 W "done."
 K NVSC,NVSCOUNT,NVSDATA,NVSFILE,NVSI
 Q
 ;
DELMPI ;
 ; delete CIRN MPI data brought over from production account
 W !!,"CLEAN UP/RESET CIRN MPI DATA"
 W !,"This procedure loops through ^DPT(""AICN"",...) and deletes CIRN MPI"
 W !,"data brought over from the production system.  Only CMOR activity"
 W !,"scores will be left intact.  This procedure will also kill several"
 W !,"CIRN-related cross references.  Finally, it will delete the entries"
 W !,"in the following files:"
 W !?2,"SUBSCRIPTION CONTROL file (#774)"
 W !?2,"TREATING FACILITY file (#391.91)"
 W !?2,"PATIENT DATA EXCEPTION file (#391.98)"
 W !?2,"PATIENT DATA ELEMENT file (#391.99)"
 ;
 ; Code copied from module DEL^NVSCIRN1 on 5/29/02 (maw)
 ;
 W !!?2,"Searching cross reference ^DPT(""AICN"",...)..."
 I +$O(^DPT("AICN",0))=0 D
 .W !?2,"Note: there are 0 records in this cross reference."
 I +$O(^DPT("AICN",0))>0 D
 .W !?4,"^DPT(""AICN"") records processed ="
 .W ?40,$J("0",10)
 .N CNT,DFN,ICN,NVSC
 .S NVSC="F ZZ=1:1:10 W $C(8)"
 .S (CNT,ICN)=0
 .F  S ICN=$O(^DPT("AICN",ICN)) Q:'ICN  D
 ..S CNT=CNT+1
 ..X NVSC
 ..W $J(CNT,10)
 ..S DFN=+$O(^DPT("AICN",ICN,0))
 ..I $D(^DPT(DFN,"MPI")) D
 ...S $P(^DPT(DFN,"MPI"),"^",1,5)="^^^^"
 ...K ^DPT(DFN,"MPIFHIS")
 W !?2,"Patient file MPI data clean up/reset completed."
 ;
 W !!?2,"Deleting MPI-related Patient file cross references..."
 K ^DPT("ACMOR")
 W !?4,"""ACMOR"" xref"
 K ^DPT("AHICN")
 W !?4,"""AHICN"" xref"
 K ^DPT("AICN")
 W !?4,"""AICN"" xref"
 K ^DPT("AICNL")
 W !?4,"""AICNL"" xref"
 K ^DPT("AMPIMIS")
 W !?4,"""AMPIMIS"" xref"
 K ^DPT("ASCN2")
 W !?4,"""ASCN2"" xref"
 W !?2,"Done."
 ;
 W !!?2,"Reset SUBSCRIPTION CONTROL file (#774)..."
 W !?4,"Deleting ",+$P($G(^HLS(774,0)),"^",4)," record(s)..."
 K ^HLS(774)
 S ^HLS(774,0)="SUBSCRIPTION CONTROL^774^0^0"
 W "done."
 ;
 W !?2,"Reset TREATING FACILITY LIST file (#391.91)..."
 W !?4,"Deleting ",+$P($G(^DGCN(391.91,0)),"^",4)," record(s)..."
 K ^DGCN(391.91)
 S ^DGCN(391.91,0)="TREATING FACILITY LIST^391.91PI^0^0"
 W "done."
 ;
 W !?2,"Reset PATIENT DATA EXCEPTION file (#391.98)..."
 W !?4,"Deleting ",+$P($G(^DGCN(391.98,0)),"^",4)," record(s)..."
 K ^DGCN(391.98)
 S ^DGCN(391.98,0)="PATIENT DATA EXCEPTION^391.98P^0^0"
 W "done."
 ;
 W !?2,"Reset PATIENT DATA ELEMENT file (#391.99)..."
 W !?4,"Deleting ",+$P($G(^DGCN(391.99,0)),"^",4)," record(s)..."
 K ^DGCN(391.99)
 S ^DGCN(391.99,0)="PATIENT DATA ELEMENT^391.99P^0^0"
 W "done."
 W !,"Patient file MPI data clean up completed."
 Q
 ;
DEDIT(DEVIEN,NULLDEV)   ; edit device file fields...
 ; DEVIEN  = device file record number
 ; NULLDEV = the $I value for this system's NULL device
 ;
 I $G(DEVIEN)'>0 Q
 N NVSDIERR,NVSFILE
 ;
 ; set OUT-OF-SERVICE DATE field to today's date...
 S NVSFILE(3.5,DEVIEN_",",6)=$$FMTE^XLFDT($$DT^XLFDT)
 ;
 ; set QUEUEING field to not allowed...
 S NVSFILE(3.5,DEVIEN_",",5.5)="NOT ALLOWED"
 ;
 ; edit $I to that of the null device...
 I $P($G(NULLDEV),"^",2)'="" S NVSFILE(3.5,DEVIEN_",",1)=$P(NULLDEV,"^",2)
 ;
 ; delete anything in the OPEN PARAMETERS field...
 S NVSFILE(3.5,DEVIEN_",",19)="@"
 ;
 ; call FM DBS to update the record...
 D FILE^DIE("E","NVSFILE","NVSDIERR")
 Q
