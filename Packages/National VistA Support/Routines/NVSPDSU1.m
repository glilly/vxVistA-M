NVSPDSU1        ;emciss/maw-patient data scrambler functions/utilities ; 09/01/02
 ;;6.0;EMC TEST ACCOUNT RESET UTILITIES; 01 Jun 1999;;Build 24
 ;
 ; the screen control modules in this routine were borrowed from
 ; ^XPDID (thanks RD@CIOFO SF).  Variables' namespace changed to
 ; protect the innocent.
 ;
INIT ;initialize progress screen
 N X,NVSDSTR
 D HOME^%ZIS
 I IO'=IO(0)!(IOST'["C-VT") S NVSIDVT=0 Q
 I $T(PREP^XGF)="" S NVSIDVT=0 Q
 D PREP^XGF
 S NVSIDVT=1,X="IOSTBM",NVSDSTR="             25             50             75               "
 D ENDR^%ZISS
 S IOTM=4,IOBM=IOSL-4
 W @IOSTBM
 D FRAME^XGF(IOTM-2,0,IOTM-2,IOM-1)
 D FRAME^XGF(IOBM,0,IOBM,IOM-1)
 D FRAME^XGF(IOBM+1,10,IOBM+3,71)
 D SAY^XGF(IOBM+2,11,NVSDSTR)
 D SAY^XGF(IOBM+2,0,$J("0",5)_"%")
 D SAY^XGF(IOBM+3,0,"Complete")
 D IOXY^XGF(IOTM-2,0)
 Q
 ;
EXIT(NVSM) ;exit progress screen restore screen to normal
 I $G(NVSIDVT) D
 .S IOTM=1,IOBM=IOSL
 .W @IOSTBM,@IOF
 .W:$G(NVSM)]"" !!,NVSM,!!
 .D CLEAN^XGF
 K IOTM,IOBM,IOSTBM,NVSIDCNT,NVSIDMOD,NVSIDTOT,NVSIDVT
 Q
 ;
TITLE(X) ;display title X
 Q:'NVSIDVT
 N NVSOX,NVSOY
 S NVSOX=$X,NVSOY=$Y
 D SAY^XGF(0,0,$$CJ^XLFSTR(X,IOM_"T")),CURSOR
 Q
 ;
SETTOT(X) ;X=file # from build
 Q:'$D(NVSIDVT)
 S NVSIDTOT=$S(X=4:+$P($G(^XTMP("NVSI",NVSA,"BLD",NVSBLD,4,0)),U,4),X=9.8:+$G(^XTMP("NVSI",NVSA,"RTN")),1:+$P($G(^XTMP("NVSI",NVSA,"BLD",NVSBLD,"KRN",X,"NM",0)),U,4))
 S NVSIDMOD=$S(NVSIDTOT<60:1,1:NVSIDTOT\60),NVSIDCNT=0
 Q:'NVSIDVT
 D UPDATE(0)
 Q
 ;
UPDATE(NVSN) ;update the progress bar
 I '+$G(NVSIDVT) W "." Q
 N NVSLEN,NVSMC,NVSOX,NVSOY,NVSS,NVSSTR
 S NVSOX=$X,NVSOY=$Y,NVSMC=60,NVSSTR="             25             50             75               "
 S NVSLEN=$S(NVSIDTOT:NVSN/NVSIDTOT*NVSMC\1,1:0),NVSS=$E(NVSSTR,1,NVSLEN)
 D SAY^XGF(IOBM+2,11,NVSS,"R1")
 S NVSS=$E(NVSSTR,NVSLEN+1,NVSMC)
 D SAY^XGF(IOBM+2,11+NVSLEN,NVSS)
 D SAY^XGF(IOBM+2,0,$J(NVSLEN/NVSMC*100,5,0)),CURSOR
 Q
 ;
CURSOR ;put cursor back
 S:NVSOY>(IOBM-1) NVSOY=IOBM-1
 D IOXY^XGF(NVSOY,NVSOX)
 Q
 ;
XREF ; clean up Patient file x-refs that contain triggers in the event edits
 ; are made to various patient file fields...
 N NVSCHK,NVSFLD,X,Y
 W !,"Patient file cross references..."
 W !!,"  NAME field (.01), xref 301..."
 I '$D(^DD(2,.01,1,301)) W "already deleted."
 I $D(^DD(2,.01,1,301)) D
 .D DELIX^DDMOD(2,.01,301,"W")
 .W !,"Done."
 W !!,"  NAME field (.01), xref 2005..."
 I '$D(^DD(2,.01,1,2005)) W "already deleted."
 I $D(^DD(2,.01,1,2005)) D
 .D DELIX^DDMOD(2,.01,2005,"W")
 .W !,"Done."
 W !!,"  SSN field (.09), xref 9..."
 I '$D(^DD(2,.01,1,9)) W "already deleted."
 I $D(^DD(2,.01,1,9)) D
 .D DELIX^DDMOD(2,.09,9,"W")
 .W !,"Done."
 W !!,"  SSN field (.09), xref 301..."
 I '$D(^DD(2,.09,1,301)) W "...already deleted."
 I $D(^DD(2,.09,1,301)) D
 .D DELIX^DDMOD(2,.09,301,"W")
 .W !,"Done."
 W !!,"  SSN field (.09), xref 2005..."
 I '$D(^DD(2,.09,1,2005)) W "already deleted."
 I $D(^DD(2,.09,1,2005)) D
 .D DELIX^DDMOD(2,.09,2005,"W")
 .W !,"Done."
 ;
 W !!,"Now, searching Patient file to delete AVAF* x-refs..."
 S (NVSCHK,NVSFLD)=0
 F  S NVSFLD=$O(^DD(2,NVSFLD)) Q:'NVSFLD  D
 .I '$D(^DD(2,NVSFLD,1,991)) Q
 .W !!?2,$P(^DD(2,NVSFLD,0),"^")," field (",NVSFLD,")..."
 .D DELIX^DDMOD(2,NVSFLD,991,"W")
 .W !?2,"Done."
 .S NVSCHK=NVSCHK+1
 I NVSCHK=0 W "already deleted."
 Q
 ;
REINDX(DFN,OK)  ; re-index the "ADOB" and "B" x-refs for a record...
 ; DFN = record number in the Patient file
 ; OK  = a flag passed by reference that will be set to 0 (zero) if re-index fails
 ; this module is called after all scrambling has been accomplished.  in order
 ; for a record to be indexed (and therefore able to be looked up), the basic
 ; scrambling mechanism for name and SSN must have completed -- completion is
 ; indicated by the existence of a temporary node ^DPT(DFN,"NVS").
 N NVSDATA,NVSNAME,NVSSSN
 S NVSDATA=$G(^DPT(+$G(DFN),0))
 I NVSDATA="" Q
 S NVSNAME=$P(NVSDATA,"^")
 S NVSSSN=$P(NVSDATA,"^",9)
 S NVSDOB=$P(NVSDATA,"^",3)
 I +NVSNAME'=0!(NVSNAME="") S OK=0 Q
 I $L(NVSSSN)>9&($E(NVSSSN,$L(NVSSSN))'="P") S OK=0 Q
 I $L(NVSSSN)<9 S OK=0 Q
 I NVSDOB="" S OK=0 Q
 S ^DPT("ADOB",NVSDOB,DFN)=""
 S ^DPT("B",NVSNAME,DFN)=""
 Q
 ;
MREC(DFN)       ; deal with merged records...
 ; DFN = record number of the merged record
 ; "Merged" records are identified in the Patient file by the existence of the node
 ; ^DPT(DFN,-9).  This node contains a number that is a pointer to the record in the
 ; Patient file into which the data from this record was merged.  This module will
 ; set zero-eth node of this merged record equal to the NAME field in the actual record
 ; (don't ask, just trust me)...
 N NVSNAME,NVSXDFN
 S NVSXDFN=+$G(^DPT(DFN,-9))
 I NVSXDFN'>0 Q
 S NVSNAME=$P($G(^DPT(NVSXDFN,0)),"^")
 I NVSNAME="" D
 .S NVSNAME=$P(^DPT(DFN,0),"^")
 .;DSS/RAC BEGIN MODS-If using Vx Scrambler send Sex to scramble name
 .;S NVSNAME=$$REVN^NVSPDSU(NVSNAME)
 .I $D(^TMP("VFDNVS01",$J)) S NVSNAME=$$NAME^VFDNVS02($P(^DPT(DFN,0),U,2))
 .I '$D(^TMP("VFDNVS01",$J)) S NVSNAME=$$REVN^NVSPDSU(NVSNAME)
 .;DSS/RAC END MODS
 I NVSNAME="" S NVSNAME="ZZPATIENT,MERGED"
 S ^DPT(DFN,0)=NVSNAME
 Q
 ;
CDOB(DFN)       ; deal with records which have no date of birth...
 ; DFN = record number in Patient file
 ; This module sets the Date of Birth field (and "ADOB" x-ref) with 2541227 so that
 ; a pseudo-SSN can be created and the record can be scrambled.
 N NVSDATA
 I +$G(DFN)'>0 Q
 S $P(^DPT(DFN,0),"^",3)=2541227
 Q
