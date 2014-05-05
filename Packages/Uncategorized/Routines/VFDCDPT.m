VFDCDPT ;DSS/SGM - MAIN ENTRY TO VFDCDPT ROUTINES ; 09/21/2012 14:50
 ;;2011.1.2;DSS,INC VXVISTA OPEN SOURCE;;28 Jan 2013;Build 153
 ;Copyright 1995-2013,Document Storage Systems Inc. All Rights Reserved
 ;
 ;This routine will be the main entry point into all of the VFDCDPT*
 ;routines.  Starting Mar1, 2006 all new DSS applications should only
 ;call line labels in this routine.  As this routine will potentially
 ;have many entry points, detailed documentation for entry point will
 ;be in the VFDCDPT* routine that is invoked.
 ;
 ;All Integration Agreements for VFDCDPT*
 ;DBIA#  Supported Reference
 ;-----  ----------------------------------------------------
 ; 2051  $$FIND1^DIC
 ; 2056  $$GET1^DIQ
 ; 2701  ^MPIF001: $$GETICN, $$GETDFN, $$IFLOCAL
 ; 3065  STDNAME^XLFNAME
 ; 3744  $$TESTPAT^VADPT
 ;10035  Direct global read of ^DPT(DFN,0), ssn
 ;10061  ^VADPT: ADD,DEM,ELIG,IN5,KVA,OAD,OPD
 ;10062  $$PID^VADPT6
 ;10103  $$FMTE^XLFDT
 ;10141  $$PATCH^XPDUTL
 ;  427  Global read of ^DIC(8,D0,0) - cont. sub. - not a subscriber
 ;
 ;Common variable defintions for all entry points
 ;===================================================================
 ;        |----------------- LINE TAG ---------------------|
 ;Variable|DEM|ICN|ICN2DFN|ID|IN|INQ|NAMECOM|TEST|GET|STATE|
 ;--------|---|---|-------|--|--|---|-------|----|---|-----|
 ;DATE    |   |   |       |  | O|   |       |    |   |     |
 ;DFN     | E |   |       |  | R| R |       |    |   |     |
 ;VFDCONF | O |   |       |  |  |   |       |    |   |     |
 ;VFDFLG  | O |   |       |  |  |   |       |    |   |  O  |
 ;FLAG    |   |   |       |  |  | O |       |    |   |     |
 ;FUN     |   | O |   O   | O|  | O |   O   |  O |   |     |
 ;ICN     |   |   |   R   |  |  |   |       |    |   |     |
 ;ISSSN   |   | O |       | R|  |   |       |  O |   |     |
 ;LODGE   |   |   |       |  | O| O |       |    |   |     |
 ;PAT     |   | R |       | R|  |   |       |  R | R |     |
 ;PERM    | O |   |       |  |  |   |       |    |   |     |
 ;SSN     | E |   |       |  |  |   |       |    |   |     |
 ;STATE   |   |   |       |  |  |   |       |    |   |  R  |
 ;TYPE    |   |   |       |  |  |   |       |    | O |     |
 ;VAPTYP  |   |   |       | O|  |   |       |    |   |     |
 ;VNAME   |   |   |       |  |  |   |   R   |    |   |     |
 ;  R:required  O:optional  E:one of these values is required
 ;
 ;Variable|Default|Description
 ;--------|-------|-----------------------------------------------------
 ;DATE    |  NOW  |FM format - get movement data as of date
 ;DFN     |       |pointer to the Patient file (#2)
 ;VFDCONF |   0   |Flag to return confidential address
 ;VFDCFLG |   0   |Boolean, if 1 return internal^external values
 ;FLAG    |       |String of codes determining which data to return
 ;FUN     |   0   |Boolean, 1:extrinsic function  0:DO w/params
 ;ICN     |       |ICN value to use a lookup value to convert to DFN
 ;ISSSN   |   0   |Boolean, 1:patient lookup is a SSN
 ;        |       |         0:then patient lookup is not a SSN
 ;LODGE   |   0   |Boolean, if 1 then include lodger movements
 ;PAT     |       |Patient file (#2) lookup value, DFN or name or SSN
 ;PERM    |   0   |Boolean, if 1 always return permanent address
 ;SSN     |       |9-digit SSN
 ;STATE   |       |lookup value
 ;TYPE    |   0   |Boolean, if 1 and PAT is 9-digits, then assume
 ;        |       |  PAT is a SSN
 ;VATYP   |       |pointer to file 8
 ;VNAME   |       |name to be parsed into components
 ;
OUT Q:'$G(FUN)  Q VFDC
 ;
 ;---------------------------------------------------------------
 ;                     CALLED BY RPCs or APIs
 ;---------------------------------------------------------------
DEM(VFDCDAT,DFN,SSN,PERM,VFDCONF,VFDFLG) ; RPC: VFDC DPT GET DEMO
 ;get patient demographics
 D DEM^VFDCDPT1(.VFDCDAT,$G(DFN),$G(SSN),$G(PERM),$G(VFDCONF),$G(VFDFLG))
 Q
 ;
ICN(VFDC,PAT,ISSSN,FUN) ; RPC: VFDC DPT GET ICN
 ;Return icn^national/local flag or -1^msg
 D ICN^VFDCDPT3(.VFDC,$G(PAT),$G(ISSSN))
 G OUT
 ;
ICN2DFN(VFDC,ICN,FUN) ; RPC: VFDC DPT ICN TO DFN
 ;Return DFN or -1^message
 D ICN2DFN^VFDCDPT3(.VFDC,$G(ICN))
 G OUT
 ;
ID(VFDC,PAT,ISSSN,VAPTYP,FUN) ; RPC VFDC DPT GET ID
 ;Return external primary patient id ^ brief pat id
 ;or if problems return -1^msg
 ;For non-VA systems, this returns the patient identifier
 ;For VA, this is the SSN (dashed) ^ last 4 of ssn
 ;Defaults to VA identifier
 D ID^VFDCDPT3(.VFDC,$G(PAT),$G(ISSSN),$G(VAPTYP),$G(FUN))
 G OUT
 ;
IN(VFDC,DFN,DATE,LODGE) ; RPC: VFDC DPT INP INFO
 ;Return information about a patient's inpatient stay
 D IN^VFDCDPT2(.VFDC,$G(DFN),$G(DATE),$G(LODGE))
 Q
 ;
INQ(VFDC,DFN,FLAG,LODGE,FUN) ; RPC: VFDC DPT INP INFO BRIEF
 ;Return specific information about the current admission
 D INQ^VFDCDPT2(.VFDC,$G(DFN),$G(FLAG),$G(LODGE))
 G OUT
 ;
NAMECOM(VFDCDAT,VNAME,FUN) ; RPC: VFDC XUTIL NAME COMPONENT
 ;Return name components for standard VistA name
 ;Return: LastName^FirstName^Middle^Suffix/Title
 D NAMECOM^VFDCDPT1(.VFDCDAT,$G(VNAME))
 G OUT
 ;
TEST(VFDC,PAT,ISSSN,FUN) ; RPC: VFDC DPT TEST PATIENT
 ;Return 1 if this is a test patient, else return 0 or -1^msg
 S VFDC=$$TEST^VFDCDPT3($G(PAT),$G(ISSSN))
 G OUT
 ;
 ;---------------------------------------------------------------
 ;                           M APIs Only
 ;---------------------------------------------------------------
COUNTY(ST,CNTY,FLG) ; return county name or number
 Q $$COUNTY^VFDCDPT1
 ;
GET(PAT,TYPE) ; return DFN^name^ssn;dashed-ssn for lookup value PAT
 Q $$GET^VFDCDPT1($G(PAT),$G(TYPE))
 ;
STATE(STATE,VFDFLG) ;  return state data
 ; VFDFLG - if 1 return state ien^name^abbreviation
 ;          if 0 return state abbreviation (or name if abbrev="")
 Q $$STATE^VFDCDPT1($G(STATE),$G(VFDFLG))
 ;
VXDEM(VFDDEM,DFN) ; return vxVistA file 2 fields
 N VFDFLG S VFDFLG=1
 D VX^VFDCDPT1(.VFDDEM,$G(DFN))
 Q
