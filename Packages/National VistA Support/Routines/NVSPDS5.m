NVSPDS5 ;emciss/maw-scramble patient SSNs ; 09/01/02
 ;;6.0;EMC TEST ACCOUNT RESET UTILITIES; 01 Jun 1999;;Build 24
 ;
 ; New SSN scrambling algorithm.  Uses a base prefix of
 ; 101-01.  Loops through the existing last-4 SSN cross
 ; reference (^DPT("BS")) and simply increments the base
 ; prefix as required for the number of records with the
 ; same last-4 SSN.  For example, 3 patients that have
 ; the same last-4 SSN of 1234:
 ; 
 ;       ^DPT("BS",1234,1)=""    SSN=509-61-1234
 ;       ^DPT("BS",1234,2)=""    SSN=512-88-1234
 ;       ^DPT("BS",1234,3)=""    SSN=489-22-1234
 ; 
 ; This routine would start with the base prefix of
 ; 101-01.  The "01" portion is incremented for each
 ; record, so the resulting scrambled SSNs would be:
 ; 
 ;       ^DPT("BS",1234,1)=""    SSN=101-01-1234
 ;       ^DPT("BS",1234,2)=""    SSN=101-02-1234
 ;       ^DPT("BS",1234,3)=""    SSN=101-03-1234
 ;
 I +$G(NVSIDVT)=0 D INIT^NVSPDSU1
 ;
 W !!,"Deleting ^DPT(""SSN"",...)"
 K ^DPT("SSN")
 ;DSS/RAC - BEGIN MOD
 K ^DPT("BS") ;Reindex to make all SSN's have a BS index
 S DIK="^DPT(",DIK(1)=".09^BS" ;re-index SSN x-refS
 D ENALL^DIK
 ;DSS/RAC - END MOD
 W "done."
 W !!,"Scrambling and re-indexing"
 ;
 S (NVSCOUNT,NVSL4)=0
 ;DSS/RAC - BEGIN MOD
 S NVSL4=""
 ;F  S NVSL4=$O(^DPT("BS",NVSL4)) Q:'NVSL4  D
 ;DSS/RAC - END MOD
 F  S NVSL4=$O(^DPT("BS",NVSL4)) Q:NVSL4=""  D
 .S NVSCOUNT=NVSCOUNT+1
 .D UPDATE^NVSPDSU1(NVSCOUNT)
 .S NVSBASE="101^01"
 .S NVSDFN=0
 .F  S NVSDFN=$O(^DPT("BS",NVSL4,NVSDFN)) Q:'NVSDFN  D
 ..S NVSXS1=$P(NVSBASE,"^")
 ..S NVSXS2=$P(NVSBASE,"^",2)
 ..S NVSNSSN=NVSXS1_NVSXS2_NVSL4
 ..;
 ..; update SSN data...
 ..S $P(^DPT(NVSDFN,0),"^",9)=NVSNSSN
 ..S ^DPT("SSN",NVSNSSN,NVSDFN)=""
 ..S NVSESSN=NVSNSSN
 ..; set PRIMARY LONG ID field (#.363) and PRIMARY SHORT ID field (#.364)
 ..; to SSN...
 ..I $D(^DPT(NVSDFN,.36)) D
 ...S $P(^DPT(NVSDFN,.36),U,3)=$$SSND^NVSPDSU(NVSESSN)
 ...S $P(^DPT(NVSDFN,.36),U,4)=$$SSNS^NVSPDSU(NVSESSN)
 ..; in the ELIGIBILITY field (2.0361) multiple, set SSN into fields
 ..; LONG ID (#.03) and SHORT ID (#.04)...
 ..S NVSX=0
 ..F  S NVSX=$O(^DPT(NVSDFN,"E",NVSX)) Q:'NVSX  D
 ...S NVSXDATA=$G(^DPT(NVSDFN,"E",NVSX,0))
 ...I NVSXDATA="" K NVSXDATA Q
 ...S $P(NVSXDATA,"^",3)=$$SSND^NVSPDSU(NVSESSN)
 ...S $P(NVSXDATA,"^",4)=$$SSNS^NVSPDSU(NVSESSN)
 ...S ^DPT(NVSDFN,"E",NVSX,0)=NVSXDATA
 ...K NVSXDATA
 ..K NVSESSN,NVSNSSN,NVSX,NVSXDATA
 ..;
 ..; increment NVSBASE...
 ..S NVSXS2=NVSXS2+1
 ..I NVSXS2<10 S NVSXS2="0"_NVSXS2
 ..I NVSXS2>99 D
 ...S NVSXS1X=NVSXS1+1
 ...I NVSXS1X<10 S NVSXS1="10"_NVSXS1X
 ...I NVSXS1X>10&(NVSXS1X<100) S NVSXS1="1"_NVSXS1X
 ...S NVSXS2="01"
 ..S $P(NVSBASE,"^")=NVSXS1
 ..S $P(NVSBASE,"^",2)=NVSXS2
 ..K NVSXS1,NVSXS1X,NVSXS2
 K NVSBASE,NVSCOUNT,NVSDFN
 Q
