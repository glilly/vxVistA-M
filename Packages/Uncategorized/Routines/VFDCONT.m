VFDCONT ;DSS/SGM - CONTINGENCY REPORT MAIN DRIVER;23 Nov 2010 10:04
 ;;2011.1.2;DSS,INC VXVISTA OPEN SOURCE;;28 Jan 2013;Build 153
 ;Copyright 1995-2013,Document Storage Systems Inc. All Rights Reserved
 ;;Copyright 1995-2010,Document Storage Systems Inc.,All Rights Reserved
 ;
 ;
 ;This is the main driver/entry point for all contingency reporting
 ;software solutions.  This includes health summaries, MARs, and MAHs.
 ;This is software to print out vxVistA reports on a routine basis just
 ;in case the system goes down for whatever reasone and will be down
 ;for an extended period of time such that the site needs to invoke
 ;their contingency plan for EMR down time.
 ;
 ;So all contingency reports should operate on the same principles
 ;which is that the parameters needed for site configurability will
 ;presume that the report will run for all patients and/or locations
 ;unless there is a parameter to override that.
 ;
 ;For large implementations a single threaded report generation job may
 ;not (actually most likely will not) complete before the next cycle of
 ;report generation will be started.  If that is the case, then ALL
 ;contingency reporting software MUST allow for multi-threaded jobs for
 ;the purpose of generating all the contingency reports for a given
 ;report cycle.  Also, ALL contingency software must allow for being
 ;invoked interactively, or by Taskman, or by a OS script which will
 ;call into this routine.
 ;
 ;----------------------------------------------------------------------
 ;                       INPATIENT REPORTS
 ;----------------------------------------------------------------------
 ;**********************************************************************
 ;               Start a New Batch of Contingency Reports
 ;**********************************************************************
HSI ; print inpatient Health Summaries
 D COMINP("HSI",1,"HS^VFDCONT2(DFN,HS)")
 Q
 ;
MAH ; print inpatient Medication Administration History
 D COMINP("MAH",1,"MAH^VFDCONT2(DFN)")
 Q
 ;
MAR ; print inpatient Medication Administration Record
 D COMINP("MAR",1,"MAR^VFDCONT2(DFN)")
 Q
 ;
 ;**********************************************************************
 ;       Start a 2nd, 3rd, etc. Processor of Contingency Reports
 ;**********************************************************************
HSITASK ; Assistant processor for inpatient Health Summaries
 D COMINP("HSI",,"HS^VFDCONT2(DFN,HS)")
 Q
 ;
MAHTASK ; Assistant processor for inpatient Medication Admin History
 D COMINP("MAH",,"MAH^VFDCONT2(DFN)")
 Q
 ;
MARTASK ; Assistant processor for inpatient Medication Admin Record
 D COMINP("MAR",,"MAR^VFDCONT2(DFN)")
 Q
 ;
 ;----------------------------------------------------------------------
 ;                         OUTPATIENT REPORTS
 ;----------------------------------------------------------------------
 ;**********************************************************************
 ;        Start a New Batch of Health Summary Contingency Reports
 ;**********************************************************************
HSO ; print outpatient health summaries
 N I,X,Y,Z,NODE,VINIT
 S VINIT=1,NODE="HSO"
 I $G(DUZ)<.5 D INITOS^VFDCONT0
 Q:'$$INITGLB^VFDCONT0(NODE)
 D GETPARMS^VFDCONT0(NODE)
 D OUT^VFDCONT1
 Q
 ;
 ;**********************************************************************
 ;Start a 2nd, 3rd, etc. Processor of Health Summary Contingency Reports
 ;**********************************************************************
HSOTASK ; print outpatient health summaries
 N I,X,Y,Z,NODE,VINIT
 S VINIT=0,NODE="HSO"
 I $G(DUZ)<.5 D INITOS^VFDCONT0
 D GETPARMS^VFDCONT0(NODE)
 D OUT^VFDCONT1
 Q
 ;
 ;-----------------------  private subroutines  ------------------------
COMINP(NODE,INIT,ROU) ; same code for all inpatient contingency reports
 ; NODE - req - inpatient report type
 ; INIT - opt - Boolean, only pass this parameter if this job is the one
 ;              to initialize ^XTMP() for this report batch generation
 ;  ROU - req - argument of a DO command to actually run the contigency
 ;              report on a per patient basis.  ROU should expect that
 ;              output device is OPENed and USEd.  ROU should not close
 ;              the device.  You can expect that DFN is defined for the
 ;              patient.
 N I,J,X,Y,Z,PATH
 Q:$G(NODE)=""  Q:$G(ROU)=""
 I NODE="MAR" N MARTYPE
 I $G(DUZ)<.5 D INITOS^VFDCONT0
 I $G(INIT)>0 Q:'$$INITGLB^VFDCONT0(NODE)
 D GETPARMS^VFDCONT0(NODE)
 I "-1"'[$P(PATH,U) D INP^VFDCONT1(NODE,ROU)
 I $G(ZTQUEUED)>0 S ZTREQ="@"
 Q
 ;
 ;Description of ^XTMP global
 ;----------------------------------------------------------------------
 ;  NODE can be HS, MAH, or MAR
 ;^XTMP("VFDCONT",0)=purge_date^date_node_set^conting_type
 ;GLB=$NA(^XTMP("VFDCONT",node,0)) where node = HSI  HSO  MAH  MAR
 ; @GLB@("START")=date.time_batch_started^servername^$J
 ; @GLB@("JOB",server,$J)="" [additional jobs only, not original]
 ; @GLB@("LAST")="~" if all pats have been processed
 ; @GLB@("LAST")=last $NA(^DPT("CN",ward,dfn)) [inpatients]
 ; @GLB@("LAST")=last clin_ien processed [outpatient HS]
 ; @GLB@("LAST","VST")=last dfn processed
 ;       for visit file loop for outpatient HS only
 ; @GLB@("LOG") ==> log of filenames generated
 ; @GLB@("LOG",n)=patient name^dfn^path^filename for n=1,2,3,...
 ;GLB=$NA(^XTMP("VFDCONT",node,"HS")) where node = HSI  HSO
 ; @GLB@(44,clinic_ien)=HS_ien
 ; @GLB@(4,division_ien)=HS_ien
 ; @GLB2("SYS")=HS_ien
 ;^XTMP("VFDCONT","HSO","PAT",DFN,HS_IEN)="" record of health summaries
 ;  already generated for this patient and HS.
 ;
 ;Description of KERNEL PARAMETERS
 ;----------------------------------------------------------------------
 ;VFD CONTING PATH: full directory (or path) where files will be placed
 ;                  for each contingency type
