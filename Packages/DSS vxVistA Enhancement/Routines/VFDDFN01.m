VFDDFN01 ;DSS/LM,JG - PATIENT lookup (Cont) ; 11/13/2013 16:00
 ;;2011.1.3;DSS,INC VXVISTA OPEN SOURCE;**12**;11 Jun 2013;Build 2
 ;Copyright 1995-2013,Document Storage Systems Inc. All Rights Reserved
 ;
 ; This routine is only invoked via the VFDDFN routine
 ;
 ; See also routine ^VFDWDPT, ^VFDPT
 ;ICR #  SUPOORTED DESCRIPTION
 ;-----  --------------------------------
 ; 2263  $$GET^XPAR
 ;10103  $$DT^XLFDT
 ;10104  $$UP^XLFSTR
 ;10112  $$SITE^VASITE
 ;       $$BROKER^XWBLIB
 ;       Direct global read of ^DPT(ien,0), 9th piece
 ;
 ;EXTERNAL CALLS INTO THIS ROUTINE
 ;--------------------------------
 ;PIDQ^VADPT6 calls $$ID
 ;
OUT ; exit extrinsic function (either $$ID or $$DFN)
 ; expects X = value to be returned
 S:X="" X=$$ERR(8) I X<0,$G(NOERR) S X=""
 Q X
 ;
DFN ; convert alternate id to dfn
 N A,I,J,L,X,Y,Z,ALTID,DFN,PARM,SSN
 S X=0,Y=$$SETUP,AID=$G(AID) I AID="" S X=$$ERR(4) G OUT
 ; build ALTID()
 F  S DFN=$O(^DPT("VFD",AID,DFN)) Q:'DFN  S I=0 D
 . F  S I=$O(^DPT("VFD",AID,DFN,I)) Q:'I  D ID1(DFN,I)
 . Q
 I '$D(ALTID) S X="" G OUT
 ; check if only one match found
 I ALTID(0)=1 S X=$O(ALTID("B",0)) G OUT
 ;
 ; altid(0)>1, are all on a single patient?
 S X=$O(ALTID("B",0)),Y=$O(ALTID("B",X)) I Y="" G OUT
 ;
 ; at this point, more than 1 DFN found which match input
 ; check list of defaults
 I $G(ALTID("DEF")) D  G OUT
 . I ALTID("DEF")=1 S X=$O(ALTID("DEF",0))
 . E  S X=$$ERR(5)
 . Q
 S X=$$ERR(6)
 G OUT
 ;
ID ;
 N I,J,X,Y,Z,ALTID,ERR,PARM,SSN
 S X=$$SETUP() I +X=-1 G OUT
 ; cases 1-9 remaining
 I PARM=1 S X=SSN S:'$L(X) X=$$ERR(7) G OUT
 I PARM=2 S X=SSN S:'$L(X) X="*"_DFN_"*" G OUT
 ;
 ; cases 3-9 remaining all alternate ID cases
 ; if explicit type passed in, then check for that first
 ;
 S ALTID(0)=0
 S I=0 F  S I=$O(^DPT(DFN,21600,I)) Q:'I  D ID1(DFN,I)
 I '$D(ALTID) S X="" G OUT
 S X=$$ID2(DFN,TYPE) I X'="" G OUT
 ;
 ; case 9 says default always first
 I PARM=9 S I=+$G(ALTID("B",DFN,"DEF")) I I S X=ALTID(I) G OUT
 I PARM=9 S PARM=3
 ; cases 3-8 remaining, all return the one alt id marked as MRN first
 S X=$$ID2(DFN,"MRN") I X'="" G OUT
 ;
 ; no alternate IDs with type MRN
 I PARM=3 S X="" G OUT
 ;
 ; cases 4-8 remaining, return default ID if it exists
 S I=+$G(ALTID("B",DFN,"DEF")) I I S X=ALTID(I) G OUT
 ;
 ; no alternate ID marked as default
 ; cases 4-8 remaining, cases 6,7,8 have explicit value to return next
 I PARM>5 D  G OUT
 . I PARM=6 S X="*"_DFN_"*"
 . I PARM=7 S X=SSN S:'$L(X) X=$$ERR(7)
 . I PARM=8 S X=""
 . Q
 ;
 ; cases 4-5 remain
 I ALTID(0)=1 S X=ALTID(1)
 E  S X="" S:PARM=4 X="*"_DFN_"*"
 G OUT
 ;
PARM ; return system parameter value
 ; also called from RPCIDL^VFDDFN
 N X S X=$$GET^XPAR("SYS","VFD PATIENT ID",1,"Q")
 I X<1!(X'?1N) S X=1
 S PARM=X,X=$$GET^XPAR("SYS","VFD PATIENT ID LABEL",1,"Q")
 S PARM("LABEL")=X I X'="",PARM=1 S PARM=6
 Q
 ;
 ;---------------------------  SUB-MODULES  ---------------------------
ALTID(DFN,NODE) ; apply common filtering logic
 ;  DFN - req - PATIENT file IEN
 ; NODE - req - IEN for field 21600 multiple
 ; Extrinsic function returns null or
 ;  p1^p2^p3^p4^p5^p6  where
 ;  p1 - p5 are the 1st to 5th pieces of alternate id node (uppercased)
 ;  p6 = alternate id (case-sensitive)
 N A,I,J,K,X,Z
 I '$G(DFN)!'$G(NODE) Q ""
 S X=$G(^DPT(DFN,21600,NODE,0)) I X="" Q ""
 S X(0)=X I X?.EL1.E S X(0)=$$UP(X)
 S Z="",$P(Z,U,6)=$P(X,U,2) ; case sensitive id
 F J=1:1:5 S A=$P(X(0),U,J),X(J)=A,$P(Z,U,J)=A
 ; filter invalid records
 I 'X(3) S X(3)=DT+.25 ;   give an expiration date
 I X(2)="" Q "" ;          no ID
 I +LOC,LOC'=X(1) Q "" ;   filter based upon location
 I XDT'="",X(3)<XDT Q "" ; exp date < filter date
 Q Z
 ;
ERR(N) ;
 ;;Invalid location value
 ;;Patient record does not exist
 ;;No valid DFN value received
 ;;No alternate ID received
 ;;Multiple records found with ID marked as default
 ;;Multiple matches found
 ;;No SSN value found
 ;;No matches found
 Q "-1^"_$P($T(ERR+N),";",3)
 ;
ID1(DFN,NODE) ; Build local array of alternate IDS
 ; does not kill or purge altid()
 ; called from both ID and DFN
 ; ALTID(0)                     = total count
 ;                                (across all patients in TAG DFN case)
 ; ALTID(j)                     = alternate ID value  for j=1,2,3,4,...
 ; ALTID(j,0)                   = DFN
 ; ALTID("B",DFN)               = total number per patient
 ; ALTID("B",DFN,j)             = alternate id value
 ; ALTID("B",DFN,"DEF")         = j for alt id marked are default
 ; ALTID("B",DFN,"TYPE",type)   = total number of type of alt ids
 ; ALTID("B",DFN,"TYPE",type,j) = ""
 ; ALTID("DEF")                 = total number with alt id as default
 ; ALTID("DEF",DFN,j)           = ""
 N I,J,K,X,Z
 S X=$$ALTID($G(DFN),$G(NODE)) Q:X=""
 S J=1+$G(ALTID(0)),ALTID(0)=J
 S ALTID(J)=$P(X,U,6) ; get case-sensitive ID value
 S ALTID(J,0)=DFN
 S ALTID("B",DFN)=1+$G(ALTID("B",DFN))
 S ALTID("B",DFN,J)=ALTID(J)
 S Y=$P(X,U,5) I Y'="" D
 . S ALTID("B",DFN,"TYPE",Y)=1+$G(ALTID("B",DFN,"TYPE",Y))
 . S ALTID("B",DFN,"TYPE",Y,J)=""
 . Q
 I $P(X,U,4)=1 D
 . S ALTID("B",DFN,"DEF")=J ; ^DD ensures 1&only 1 record
 . S ALTID("DEF")=1+$G(ALTID("DEF"))
 . S ALTID("DEF",DFN,J)=""
 . Q
 Q
 ;
ID2(DFN,TYPE) ; if specific type passed in, check it out
 ; if null is returned, then continue above, else done, get out
 ; expects DFN,TYPE
 N I,J,X,Y,Z
 I $G(TYPE)="" Q ""
 I $G(DFN)<1 Q ""
 M Z=ALTID("B",DFN,"TYPE",TYPE)
 S I=+$G(Z) I 'I Q ""
 I I=1 S J=$O(Z(0)) Q ALTID(J)
 Q $$ERR(6)_" with type "_TYPE
 ;
SETUP() ; initialize common variables
 ; called from ID, DFN
 ; returns "" if no problems, else -1^msg
 ; local variables or input params for all modules
 ; DFN, LOC, PARM, SSN, TYPE, XDT
 N X,Y,Z
 S DFN=+$G(DFN)
 S SSN="" S:DFN SSN=$P($G(^DPT(DFN,0)),U,9)
 S TYPE=$$UP($G(TYPE))
 D PARM I $G(CASE),CASE?1N S PARM=CASE
 S:$G(XDT)="" XDT=DT S:XDT'=+XDT XDT=DT
 I $G(LOC)="" S LOC=+$$SITE^VASITE
 S X=0 I 'LOC,"*"'[LOC S X=$$ERR(1)
 Q X
 ;
UP(B) N X,Y,Z S:B?.E1L.E B=$$UP^XLFSTR(B) Q B
