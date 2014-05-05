VFDSSN ;DSS/SGM - COMMON ENTRY FOR ALL THINGS SSN ; 02/02/2012 14:45
 ;;2011.1.2;DSS,INC VXVISTA OPEN SOURCE;;28 Jan 2013;Build 153
 ;Copyright 1995-2013,Document Storage Systems Inc. All Rights Reserved
 ;
 ; Various entry points for managing social security numbers
 ;
OPT ; option: VFD SSN CORRECTION
 ; fix ssn inconsistencies
 ; if scheduled through Tasman then default variables
 I $D(ZTQUEUED),$G(MODE)="" N MODE,WR S MODE=1,WR=0
 ;
OPT1 ; called from post-installs to fix patient records
 ; MODE and WR must be defined
 ; if SAVE=1 then do not kill off the report global
 N VFDLIST S VFDLIST=$NA(^TMP("VFDSSN",$J)) K @VFDLIST
 D FIXSSN^VFDSSN02(VFDLIST,$G(MODE),$G(WR))
 K:'$G(SAVE) @VFDLIST
 Q
 ;
XREF ;
 ;called from a whole file, new style index (AVFDIDX) on the PATIENT
 ;file [FS01^VFDPTIX].  The purpose is to generate a pseudo-SSN if the
 ;SSN field is null whenever a new patient record is created or a
 ;patient's name is edited.
 I $G(DA)>0 D XREF^VFDSSN01
 Q
 ;
 ;------------  PRIVATE - Common APIs for VFDSSN* Routines  -----------
CURSSN(DFN) ; return current value of SSN
 Q $$CURSSN^VFDSSN01($G(DFN))
 ;
FILE(VFDA) ; call FILE^DIE to update existing entries in any file
 ; .VFDA - req - Fileman FDA() for file^die
 ; extrinsic function retutn 1 or -1^msg
 Q $$FILE^VFDSSN01(.VFDA)
 ;
GSSN(DFN) ; generate a MRN (or pseudo-SSN)
 ; value returned may be equal to the existing value
 Q $$GSSN^VFDSSN01($G(DFN))
 ;
ISGEN(DFN,VAL) ; is value a vxvista generated value?
 Q $$ISGEN^VFDSSN01($G(DFN),$G(VAL))
 ;
ISPAT(DFN) ; is value a patient file entry
 Q $$IEN^VFDSSN01($G(DFN))
