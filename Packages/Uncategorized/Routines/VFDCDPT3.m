VFDCDPT3 ;DSS/SGM - PATIENT INFO UTILITES ;03/07/2006 00:36
 ;;2011.1.2;DSS,INC VXVISTA OPEN SOURCE;;28 Jan 2013;Build 153
 ;Copyright 1995-2013,Document Storage Systems Inc. All Rights Reserved
 ;
 ;Not independently invoked - called from VFDCDPT routine only
 ;
ICN(VFDC,PAT,ISSSN,FUN) ; RPC: VFDC DPT GET ICN
 ; return ICN information for a patient DFN
 ; return p1^p2 or -1^message where
 ;   p1 = ICN - national, if no national, then local icn
 ;              icn will include checksum
 ;   p2 = flag indicating whether ICN is national or local
 ;        N:national; L:local
 N X,Y,Z,ICN,LOCAL
 S X=$$GET^VFDCDPT1($G(PAT),+$G(ISSSN))
 I +X=-1 S VFDC=X G OUT
 S PAT=+X,ICN=$$GETICN^MPIF001(PAT) I +ICN=-1 S VFDC=ICN G OUT
 S LOCAL=$$IFLOCAL^MPIF001(PAT)
 S VFDC=ICN_U_$E("NL",1+LOCAL)
OUT Q:$G(FUN) VFDC Q
 ;
ICN2DFN(VFDC,ICN,FUN) ; RPC: VFDC DPT ICN TO DFN
 ; ICN - req - ICN to do lookup to convert to DFN
 ; FUN - opt - default to 0, if 1 then extrinsic function
 ; Return DFN or -1^message
 N X S VFDC=$$GETDFN^MPIF001($G(ICN))
 G OUT
 ;
ID(PAT,ISSSN,VAPTYP) ; get external primary/brief patient identifier
 ; If eligibility is configured, returns those values
 ; Else, it returns 9 digit SSN (dashed) ^ last 4 of SSN 
 ; VAPTYP - opt - pointer to file 8
 N X,Y,Z,DFN,VA
 S VFDC=$$GET^VFDCDPT(PAT,ISSSN) I VFDC<0 G OUT
 I $G(VAPTYP)'="" I VAPTYP\1'=VAPTYP!'$D(^DIC(8,+VAPTYP,0)) K VAPTYP
 D PID^VADPT6
 S X=$G(VA("PID")),Y=$G(VA("BID"))
 I X'=""!(Y'="") S VFDC=X_U_Y
 I X="",Y="" S VFDC="-1^Problem encountered getting patient ID information"
 G OUT
 ;
TEST(PAT,ISSSN) ; Boolean 1/0 - 1 if a test patient, else 0
 N X,Y,Z S VFDC=$$GET^VFDCDPT(PAT,ISSSN)
 I +VFDC>0 S VFDC=$$TESTPAT^VADPT(+VFDC)
 G OUT
