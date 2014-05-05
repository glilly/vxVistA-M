VFDHLPID ;DSS/LM - HL7 PID Segment Generator ;April 4, 2011
 ;;2011.1.2;DSS,INC VXVISTA OPEN SOURCE;;28 Jan 2013;Build 153
 ;Copyright 1995-2013,Document Storage Systems Inc. All Rights Reserved
 ;
 Q
EN(VFDRSLT,VFDDFN,HLFS,HLECH,VFDSETID,VFDXACCT,VFDFLAGS) ;[Public] - Generate PID segment
 ; VFDRSLT=[Required]  - [By reference] Return array
 ; VFDDFN=[Required]   - Patient IEN =OR=
 ;                       List of Keyword^Value pairs (by reference)
 ;                         List(1)=Keyword1^value1
 ;                         List(2)=Keyword2^value2
 ;                         Etc.
 ;                       where the following keywords are supported:
 ;                         DFN      - Patient IEN
 ;                         HLFS     - HL7 Field separator
 ;                         HLEC     - (or HLECH) - HL7 Encoding characters
 ;                         SETID    - (or SET ID) - Segment set ID
 ;                         ACCOUNT# - Patient account number in external format
 ;                         FLAGS    - Extensible list of flags (VFDFLAGS parameter)
 ;                       * Keywords are not case sensitive
 ;                       * An explicit parameter (valued in the actual list) takes
 ;                       precedence of the corresponding keyword value pair.
 ;                         
 ; HLFS=[Optional]     - HL7 Field separator
 ; HLECH=[Optional]    - HL7 Encoding characters
 ; VFDSETID=[Optional] - Segment set ID
 ; VFDXACCT=[Optional] - Account number PID.18.1, in external format
 ; VFDFLAGS=[Optional] - Flags (extensible list)
 ;                         S=Return generated segment as string, regardless of length
 ;                         P=Suppress PHI
 ;                         R=Remove empty repetitions
 ;                           [default is array, if longer than 245 characters]
 ;
 D PARSE(.VFDDFN,.HLFS,.HLECH,.VFDSETID,.VFDXACCT,.VFDFLAGS)
 I $G(VFDDFN)>0,$L(HLFS)=1,$L(HLECH)=4,'(HLECH[HLFS),VFDSETID ;OK
 E  Q  ;Missing or invalid patient IEN, field separator, encoding characters or set ID
 N I,VAFPID,VFDFLDS,VFDRPT,VFDVX,Y,Z
 S VFDFLDS="",VFDVX="VX"
 F I=1:1:33 S VFDFLDS=VFDFLDS_I_","
 S VFDFLDS=VFDFLDS_34
 ; Get VAFC-valued fields
 N HL,HLQ S HLQ=""
 S Y=$$EN^VAFCPID(VFDDFN,VFDFLDS,VFDSETID)
 ; Ignore string length until segment is complete
 F I=1:1 Q:'$D(VAFPID(I))  S Y=Y_VAFPID(I)
 S VFDRSLT=Y ;Base VA-generated segment
 ; Add vxVistA data
 S VFD1=$E(HLECH),VFD2=$E(HLECH,4),VFDRPT=$E(HLECH,2)
 D 3 ;ALTERNATE ID(s)
 D 7 ;Date/Time of Birth
 D 9 ;Patient Alias
 D 10 ;Race
 D 11 ;Patient Address
 D 13 ;Phone Number - Home
 D 14 ;Phone Number - Business 
 D 15 ;Primary Language
 D 16 ;Marital Status
 D 17 ;Religion
 D 18 ;Account Number
 D 22 ;Ethnic Group
 ; End vxVistA field modifications
 ; Remove trailing spaces
 F I=$L(VFDRSLT):-1 Q:'($E(VFDRSLT,I)=" ")
 S VFDRSLT=$E(VFDRSLT,1,I)
 ; Respect PHI flag
 D:VFDFLAGS["P" PHI(.VFDRSLT)
 ; Respect flag "R" (remove empty repetitions)
 D:VFDFLAGS["R" SQUISH(.VFDRSLT)
 ; Respect 245 character node length limit
 I $L(VFDRSLT)>245,'(VFDFLAGS["S") D SPLIT(.VFDRSLT)
 Q
SPLIT(VFDSEG) ;[Public] Split long segment into base + continuation parts
 ; where base part in VFDSEG is 245 characters, first continuation in VFDSEG(1)
 ; is up to 245 characters, and so forth.
 ;
 ; VFDSEG=[Required] By reference, segment to be split
 ;
 N X I $L(VFDSEG)>245 D
 .S X=VFDSEG
 .F I=0:1 Q:'$L(X)  S VFDSEG(I)=$E(X,1,245),X=$E(X,246,$L(X))
 .S VFDSEG=VFDSEG(0) K VFDSEG(0)
 .Q
 Q
PARSE(VFDDFN,HLFS,HLECH,VFDSETID,VFDXACCT,VFDFLAGS) ;[Private] Parse input parameters
 ; Called by EN
 ; All parameters by reference
 ; 
 D:$D(VFDDFN)>1  ;First parameter is a list
 .N I,P,Q,X S I=0 F  S I=$O(VFDDFN(I)) Q:'I  D
 ..S X=VFDDFN(I),P=$$UP^XLFSTR($P(X,U)),Q=$P(X,U,2)
 ..I P="DFN" S VFDDFN=$G(VFDDFN,Q) Q
 ..I P="HLFS" S HLFS=$G(HLFS,Q) Q
 ..I P="HLEC"!(P="HLECH") S HLECH=$G(HLECH,Q) Q
 ..I P="SETID"!(P="SET ID") S VFDSETID=$G(VFDSETID,Q) Q
 ..I P?1"ACCOUNT".E!(P?1"ACCT".E) S VFDXACCT=$G(VFDXACCT,Q) Q
 ..I P="FLAGS" S VFDFLAGS=$G(VFDFLAGS,Q) Q
 ..Q
 .Q
 S HLFS=$G(HLFS,"|"),HLECH=$G(HLECH,"^~\&"),VFDSETID=+$G(VFDSETID,1)
 S VFDFLAGS=$G(VFDFLAGS)
 Q
PHI(VFDRSLT) ;[Private] "P" flag - Suppress PHI
 ; VFDRSLT=[Required] PID segment as continuous string
 N I,MSG,R,X S R=$E(HLECH,2) ;Repeat character
 S X=$P(VFDRSLT,HLFS,4) ;PID.3
 F I=1:1:$L(X,R) I $P(X,R,I)["SSN" S $P(X,R,I)=""
 S $P(VFDRSLT,HLFS,4)=X
 S MSG="PHI"_$E(HLECH)_"REMOVED"
 S $P(VFDRSLT,HLFS,6)=MSG ;PID.5 (Patient Name)
 I $P(VFDRSLT,HLFS,7)]"" S $P(VFDRSLT,HLFS,7)=MSG ;PID.6 Mother's maiden name
 I $P(VFDRSLT,HLFS,10)]"" S $P(VFDRSLT,HLFS,10)=MSG ;PID.9 Aliases
 I $P(VFDRSLT,HLFS,12)]"" S $P(VFDRSLT,HLFS,12)=MSG ;PID.11 Address
 I $P(VFDRSLT,HLFS,14)]"" S $P(VFDRSLT,HLFS,14)="" ;PID.13 Phone Number - Home
 I $P(VFDRSLT,HLFS,15)]"" S $P(VFDRSLT,HLFS,15)="" ;PID.14 Phone Number - Business
 S $P(VFDRSLT,HLFS,20)="" ;SSN
 Q
SQUISH(VFDRSLT) ;[Private] "R" flag - Remove empty repetitions
 ; VFDRSLT=[Required] PID segment as continuous string
 Q:'$L($G(VFDRSLT))
 N I,J,L,RR,X S RR=VFDRPT_VFDRPT
 F I=1:1:$L(VFDRSLT,HLFS) S X=$P(VFDRSLT,HLFS,I) D:X[VFDRPT
 .F J=$L(X):-1 Q:'($E(X,J)=VFDRPT)
 .S X=$E(X,1,J) ;Remove trailing repetition separators
 .S L=$L(X,VFDRPT)
 .F  Q:'(X[RR)  S X=$P(X,RR)_VFDRPT_$P(X,RR,2,L) ;Remove empty repetitions
 .S $P(VFDRSLT,HLFS,I)=X
 .Q
 Q
3 ;[Private] ALTERNATE ID (repeats)
 N VFDI,VFDPID3,VFDNR,VFDX,VFDY
 S VFDPID3=$P(VFDRSLT,HLFS,4),VFDNR=$L(VFDPID3,VFDRPT)
 S VFDI=0 F  S VFDI=$O(^DPT(VFDDFN,21600,VFDI)) Q:'VFDI   S VFDX=$G(^(VFDI,0)) D
 .Q:'$L(VFDX)
 .; Construct repeat
 .S VFDY=$P(VFDX,U,2) ;ID number
 .S $P(VFDY,VFD1,5)=$P(VFDX,U,5) ;ID Type
 .S $P(VFDY,VFD1,6)=$$GET1^DIQ(4,+VFDX,.01) ;Assigning Facility
 .S $P(VFDY,VFD1,8)=$P(VFDX,U,3) ;Expiration Date
 .; Add repeat to field
 .S VFDNR=VFDNR+1,$P(VFDPID3,VFDRPT,VFDNR)=VFDY
 .Q
 ; Insert modified field in segment
 S $P(VFDRSLT,HLFS,4)=VFDPID3
 Q
7 ;[Private] Date/Time of Birth
 ; VistA File 2, field #.03 is a DATE field (w/o time)
 ; vxVistA adds field #21601.01 TIME OF BIRTH (in 24 hr format HH:MM)
 ;
 N VFDTOB S VFDTOB=$$GET1^DIQ(2,VFDDFN,21601.01) Q:'(VFDTOB?2N1":"2N)
 S $P(VFDRSLT,HLFS,8)=$P($P(VFDRSLT,HLFS,8),"-")_$TR(VFDTOB,":") ;_VFD1_"M"
 Q
8 ;[Private] Table 0001 Administrative SEX
 ;
 ; Table 0001
 ; User Administrative Sex
 ; 0001 A Ambiguous
 ; 0001 F Female
 ; 0001 M Male
 ; 0001 N Not applicable
 ; 0001 O Other
 ; 0001 U Unknown
 ;
 ; vxVistA values 'F', 'M', and 'U' are the same as suggested values.
 ; vxVistA does not presently support 'A', 'N', or 'O'.
 ;
 ; Therefore, no change is required to the Administrative SEX field.
 ;
 Q
9 ;{Private] Aliases - Not populated by VAFCPID
 ; Retained for backward-compatibility in Version 2.4 forward
 N VFDA,VFDI,VFDIENS,VFDNAM,VFDR,VFDY
 D GETS^DIQ(2,VFDDFN,"1*",,$NA(VFDA))
 S VFDR=0,(VFDIENS,VFDY)=""
 F  S VFDIENS=$O(VFDA(2.01,VFDIENS)) Q:'VFDIENS  D
 .S VFDNAM=VFDA(2.01,VFDIENS,.01) Q:'$L(VFDNAM)
 .S VFDR=VFDR+1,$P(VFDY,VFDRPT,VFDR)=$$NAMEFMT^XLFNAME(VFDNAM,"H",,VFD1)
 .Q
 S $P(VFDRSLT,HLFS,10)=VFDY
 Q
10 ;[Private] Table 0005 RACE
 N VFDX,VFDY,VFDZ S VFDX=$P(VFDRSLT,HLFS,11) Q:'VFDX  S VFDY=""
 ; VFDX=IEN (pointer to File 10)
 I $T(TABVALTR^VFDHHLOT)]"" D
 .S VFDZ=$$TABVALTR^VFDHHLOT("HL7 2X","0005",VFDX,"HLT") Q:VFDZ<0
 .S VFDY=$TR(VFDZ,U,VFD1)
 .Q
 I VFDY]"" S $P(VFDRSLT,HLFS,11)=VFDY_VFD1_VFDVX_"0005" Q
 ; Fall-through here if VFD HL7 EXCHANGE table resolution fails
 ; Table 0005 is small -
 ;
 ; User Race
 ; 0005 1002-5 American Indian or Alaska Native
 ; 0005 2028-9 Asian
 ; 0005 2054-5 Black or African American
 ; 0005 2076-8 Native Hawaiian or Other Pacific Islander
 ; 0005 2106-3 White
 ; 0005 2131-1 Other Race
 ;
 ; Translate in-line - Use code 21600-X for vxVistA values not in list above
 ;
 I VFDX=1 S $P(VFDRSLT,HLFS,11)="2054-5"_VFD1_"Black or African American"_VFD1_VFDVX_"0005" Q
 I VFDX=2 S $P(VFDRSLT,HLFS,11)="1002-5"_VFD1_"American Indian or Alaska Native"_VFD1_VFDVX_"0005" Q
 I VFDX=3 S $P(VFDRSLT,HLFS,11)="2106-3"_VFD1_"White"_VFD1_VFDVX_"0005" Q
 I VFDX=4 S $P(VFDRSLT,HLFS,11)="21600-4"_VFD1_"Hispanic, White"_VFD1_VFDVX_"0005" Q
 I VFDX=5 S $P(VFDRSLT,HLFS,11)="21600-5"_VFD1_"Asian of Pacific Islander"_VFD1_VFDVX_"0005" Q
 I VFDX=6 S $P(VFDRSLT,HLFS,11)="21600-6"_VFD1_"Hispanic, Black"_VFD1_VFDVX_"0005" Q
 I VFDX=7 S $P(VFDRSLT,HLFS,11)="21600-7"_VFD1_"Unknown"_VFD1_VFDVX_"0005" Q
 I VFDX=8 S $P(VFDRSLT,HLFS,11)="2028-9"_VFD1_"Asian"_VFD1_VFDVX_"0005" Q
 I VFDX=9 S $P(VFDRSLT,HLFS,11)="2054-5"_VFD1_"Black or African American"_VFD1_VFDVX_"0005" Q
 I VFDX=10 S $P(VFDRSLT,HLFS,11)="21600-10"_VFD1_"Declined to answer"_VFD1_VFDVX_"0005" Q
 I VFDX=11 S $P(VFDRSLT,HLFS,11)="2076-8"_VFD1_"Native Hawaiian or Other Pacific Islander"_VFD1_VFDVX_"0005" Q
 I VFDX=12 S $P(VFDRSLT,HLFS,11)="21600-12"_VFD1_"Unknown by patient"_VFD1_VFDVX_"0005" Q
 I VFDX=13 S $P(VFDRSLT,HLFS,11)="2106-3"_VFD1_"White"_VFD1_VFDVX_"0005" Q
 S $P(VFDRSLT,HLFS,11)="" ;If not in VFD HL7 EXCHANGE table or above explicit list
 Q
11 ;[Private] Patient Address
 ; Add Address Type (Table 0190) and Temporary Address, if applicable
 N VFDA,VFDX,VFDY S VFDX=$P(VFDRSLT,HLFS,12) ;First address (returned by VAFCPID)
 I $L($P(VFDX,VFD1))!$L($P(VFDX,VFD1,3)),'$L($P(VFDX,VFD1,7)) S $P(VFDX,VFD1,7)="P"
 I $L(VFDX,VFDRPT)=1 D
 .D GETS^DIQ(2,VFDDFN,".1217;.1218;.12105","I",$NA(VFDA))
 .Q:DT<VFDA(2,VFDDFN_",",.1217,"I")  ;Temporary address start date
 .Q:VFDA(2,VFDDFN_",",.1218,"I")<DT  ;Temporary address end date
 .Q:VFDA(2,VFDDFN_",",.12105,"I")="N"
 .D GETS^DIQ(2,VFDDFN,".1211;.1212;.1214;.1215;.1216",,$NA(VFDA))
 .I $L(VFDA(2,VFDDFN_",",.1211))!$L(VFDA(2,VFDDFN_",",.1214)) D
 ..S VFDY=VFDA(2,VFDDFN_",",.1211)
 ..S $P(VFDY,VFD1,2)=VFDA(2,VFDDFN_",",.1212)
 ..S $P(VFDY,VFD1,3)=VFDA(2,VFDDFN_",",.1214)
 ..S $P(VFDY,VFD1,4)=VFDA(2,VFDDFN_",",.1215)
 ..S $P(VFDY,VFD1,5)=VFDA(2,VFDDFN_",",.1216)
 ..S $P(VFDY,VFD1,7)="C"
 ..S $P(VFDX,VFDRPT,2)=VFDY
 ..Q
 .Q
 S $P(VFDRSLT,HLFS,12)=VFDX
 Q
13 ;[Private] Phone Number - Home
 N VFDA,VFDI,VFDX,VFDZ S VFDI=0,VFDX=""
 D GETS^DIQ(2,VFDDFN,".131;.134",,$NA(VFDA))
 D:$L(VFDA(2,VFDDFN_",",.131))
 .S VFDZ=VFDA(2,VFDDFN_",",.131)
 .S $P(VFDZ,VFD1,2)="PRN"
 .S $P(VFDZ,VFD1,3)="PH"
 .S VFDI=VFDI+1,$P(VFDX,VFDRPT,VFDI)=VFDZ
 .Q
 D:$L(VFDA(2,VFDDFN_",",.134))
 .S VFDZ=VFDA(2,VFDDFN_",",.134)
 .S $P(VFDZ,VFD1,3)="CP"
 .S VFDI=VFDI+1,$P(VFDX,VFDRPT,VFDI)=VFDZ
 .Q
 S $P(VFDRSLT,HLFS,14)=VFDX
 Q
14 ;[Private] Phone Number - Business
 N VFDX S VFDX=$$GET1^DIQ(2,VFDDFN,.132) Q:'$L(VFDX)
 S $P(VFDX,VFD1,2,3)="WPN"_VFD1_"PH"
 S $P(VFDRSLT,HLFS,15)=VFDX
 Q
 ;
15 ;[Private] Table 0296 Primary Language
 N VFDL S VFDL=$$GET1^DIQ(2,VFDDFN,21601.02,"I") Q:'VFDL
 S $P(VFDRSLT,HLFS,16)=$$GET1^DIQ(.85,VFDL,.03)_VFD1_$$GET1^DIQ(.85,VFDL,1)_VFD1_"ISO-639"
 Q
16 ;[Private] Table 0002 Marital Status
 N VFDX,VFDY,VFDZ S VFDX=$P(VFDRSLT,HLFS,17) Q:'$L(VFDX)  S VFDY=""
 Q:'(VFDX?1U)  ;Marital Status Code, as translated by ^VAFCPID
 I $T(TABVALTR^VFDHHLOT)]"" D
 .S VFDZ=$$TABVALTR^VFDHHLOT("HL7 2X","0002",VFDX,"HLT") Q:VFDZ<0
 .S VFDY=$TR(VFDZ,U,VFD1)
 .Q
 I VFDY]"" S $P(VFDRSLT,HLFS,17)=VFDY_VFD1_VFDVX_"0002" Q
 ; Fall-through here if VFD HL7 EXCHANGE table resolution fails
 ; Note that ^VAFCPID translates codes N to S and S to A
 I VFDX="D" S VFDY=VFDX_VFD1_"DIVORCED"
 E  I VFDX="M" S VFDY=VFDX_VFD1_"MARRIED"
 E  I VFDX="S" S VFDY=VFDX_VFD1_"NEVER MARRIED"
 E  I VFDX="A" S VFDY=VFDX_VFD1_"SEPARATED"
 E  I VFDX="W" S VFDY=VFDX_VFD1_"WIDOWED"
 E  I VFDX="U" S VFDY=VFDX_VFD1_"UNKNOWN"
 I VFDY]"" S $P(VFDRSLT,HLFS,17)=VFDY_VFD1_VFDVX_"0002"
 Q
17 ;[Private] Table 0006 Religion
 N VFDX,VFDY,VFDZ S VFDX=$P(VFDRSLT,HLFS,18) Q:'$L(VFDX)  S VFDY=""
 S VFDX=$$FIND1^DIC(13,,"X",VFDX,"C") Q:'(VFDX>0)  ;Code -> IEN
 I $T(TABVALTR^VFDHHLOT)]"" D
 .S VFDZ=$$TABVALTR^VFDHHLOT("HL7 2X","0006",VFDX,"HLT") Q:VFDZ<0
 .S VFDY=$TR(VFDZ,U,VFD1)
 .Q
 I VFDY]"" S $P(VFDRSLT,HLFS,18)=VFDY_VFD1_VFDVX_"0006" Q
 ; Fall-through here if VFD HL7 EXCHANGE table resolution fails
 ; Note that $$EN^VAFCPID returns '29' Unknown / No preference if RELIGION is not valued
 K VFDZ D GETS^DIQ(13,VFDX,"*",,$NA(VFDZ)) Q:'$L(VFDZ(13,VFDX_",",.01))
 S $P(VFDRSLT,HLFS,18)=VFDZ(13,VFDX_",",3)_VFD1_VFDZ(13,VFDX_",",.01)_VFD1_VFDVX_"0006"
 Q
18 ;[Private] Patient Account Number
 Q:'$L($G(VFDXACCT))  ;Optional input parameter
 ; Assigning authority is a place-holder in next, subject to discussion
 S $P(VFDRSLT,HLFS,19)=VFDXACCT_VFD1_VFD1_VFD1_"vxVistA"
 Q
22 ;[Private] Table 0189 Ethnic Group
 ; Does not repeat in HL7
 ;
 ; User Ethnic Group
 ; 0189 H Hispanic or Latino
 ; 0189 N Not Hispanic or Latino
 ; 0189 U Unknown
 ;
 ; VAFCPID generates a multi-component value for this field
 ; e.g., 2186-5-SLF^^0189
 ;
 N VFDX,VFDY,VFDZ S VFDX=$P(VFDRSLT,HLFS,23) Q:'$L(VFDX)  S VFDY=""
 S VFDX=$$FIND1^DIC(10.2,,"X",$P($P(VFDX,VFD1),"-",1,2),"AHL7") Q:'(VFDX>0)  ;Code -> IEN
 I $T(TABVALTR^VFDHHLOT)]"" D
 .S VFDZ=$$TABVALTR^VFDHHLOT("HL7 2X","0189",VFDX,"HLT") Q:VFDZ<0
 .S VFDY=$TR(VFDZ,U,VFD1)
 .Q
 I VFDY]"" S $P(VFDRSLT,HLFS,23)=VFDY_VFD1_VFDVX_"0189" Q
 ; Fall-through here if VFD HL7 EXCHANGE table resolution fails
 K VFDZ D GETS^DIQ(10.2,VFDX,"*",,$NA(VFDZ)) Q:'$L(VFDZ(10.2,VFDX_",",.01))
 S $P(VFDRSLT,HLFS,23)=VFDZ(10.2,VFDX_",",3)_VFD1_VFDZ(10.2,VFDX_",",.01)_VFD1_VFDVX_"0189"
 Q
