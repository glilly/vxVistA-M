VFDVOHU ;DSS/LM - Utilities ; 3/22/2013 09:50
 ;;2011.1.2;DSS,INC VXVISTA OPEN SOURCE;;11 Jun 2013
 ;Copyright 1995-2013,Document Storage Systems Inc. All Rights Reserved
 ;
 ; Active integration agreements
 ; 
 ; 2161   INIT^HLFNC2
 ; 2051   $$FIND1^DIC
 ; 2056   $$GET1^DIQ
 ; 
 Q
 ;
ACTIVE(HLAPP) ; Return 1=TRUE if and only if HL7 Application is Active
 ; From ^SISIUTL by permission
 Q:'$L($G(HLAPP)) 0
 S:'$G(HLAPP) HLAPP=$$FIND1(771,,"X",HLAPP)
 Q:'$G(HLAPP) 0
 Q $$DIQ1(771,HLAPP,2,"I")="a"
 ;
FS(FS) ; get field delimiter
 N X S X=$G(FS) S:X="" X=$G(HL("FS")) S:X="" X="|" Q X
 ;
GET1(MSG,SEG,F) ; Get one field value from segment
 ; .MSG - req - HL7 message array
 ;  SEQ - req - name of segment to retrieve data from
 ;    F - req - M $P value of segment with delimiter $$FS
 ; RETURN:
 ;   Extrinsic function returns '-ERR' if problems
 ;   If segment not found, then return "-1^NO SEG"
 ;   Else return value of field
 N I,J,X,Y,Z,FS
 I '$D(MSG)!($G(SEG)="")!('$G(F)) Q "-ERR"
 S FS=$$FS,(I,J)=0,Y="",SEG(0)="-1^NO SEG"
 F  S I=$O(MSG(I)) Q:'I  S X=MSG(I) D  Q:SEG(0)=""
 . I $P(X,FS)=SEG S Y=$P(X,FS,F),SEG(0)=""
 . Q
 Q $S(SEG(0)="":Y,1:SEG(0))
 ;
INIT(HL,PROT) ; Set up HL7 environment variables
 ; Return 0=Success or 1=Failure
 ; HL=Return array of HL7 variables [by reference]
 ; PROT=Event Driver protocol
 Q:'$L($G(PROT)) 1 S HL("EID")=$$FIND1(101,,,PROT)
 Q:'HL("EID") 1  D INIT^HLFNC2(HL("EID"),.HL)
 Q +$G(HL)
 ;
MSGDFN(MSG,FS) ; Extract DFN from single message
 ; MSG=Internal order message array
 S FS=$$FS($G(FS))
 N I F I=1:1 Q:"PID"[$E($G(MSG(I)),1,3)
 Q +$P($G(MSG(I)),FS,4) ;Internal message has PID.3=DFN
 ;
RMV(MSG,SEGID) ; Remove segments from HL7 message
 ; Adapted from previous applications
 ;
 ; MSG=Name of message array for subscript indirection
 ; SEGID=3-character segment ID
 ;
 I $L($G(MSG)),$D(@(MSG))>1,$G(SEGID)?1A2AN
 E  Q
 N I,K,X S K=0
 F I=1:1 Q:'$D(@MSG@(I))  D
 .K X M X=@MSG@(I) K @MSG@(I)
 .Q:SEGID=$E(X,1,3)  ;Remove segment
 .S K=K+1 M @MSG@(K)=X ;Include continuations
 .Q
 Q
 ;
SQUISH(X,C) ; Remove trailing characters from string (From ^DENTVHLU)
 ; C=Character to be removed
 I $L($G(X)),$L($G(C))=1 ;Required
 E  Q $G(X)
 N % F %=$L(X):-1:1 Q:'($E(X,%)=C)
 Q $E(X,1,%)
 ;
 ;----------------------------  UTILITIES  ----------------------------
DIQ1(FILE,IENS,FLD,FLG,VFDWP) ;
 N I,J,X,Y,Z,DIERR,VFDER
 I '$G(FILE)!'$G(IENS)!'$G(FLD) Q ""
 Q $$GET1^DIQ(FILE,IENS,FLD,$G(FLG),$G(VFDWP),"VFDER")
 ;
FIND1(FILE,IENS,FLAGS,VAL,INDX,SCR) ;
 N I,J,X,Y,Z,DIERR,VFDER
 I '$G(FILE)!'$D(VAL) Q -1
 Q $$FIND1^DIC(FILE,$G(IENS),$G(FLAGS),.VAL,.INDX,.SCR,"VFDER")
 ;
 ;-------------------------  DEBUG UTILITIES  -------------------------
DEBUG(X) ; From ^SISIUTL (c) Sea Island Systems, Inc.
 ; Used by permission
 Q:'$G(^XTMP("VFDVOH"))  ;Debug off
 N %,VFDVNKD S:$T(LGR^%ZOSV)]"" VFDVNKD=$$LGR^%ZOSV ;Save naked
 S (%,^(0))=1+$G(^XTMP("VFDVOH",0)),^(%,0)=$H_"%%"_$G(X)
 M:$D(X)>1 ^("SUBS")=X S:$D(X)>1 ^("SUBS")=""
 S:$L($G(VFDVNKD)) VFDVNKD=$D(@VFDVNKD) ;Restore naked
 Q
DBGON ; Debug on
 S ^XTMP("VFDVOH")=1
 Q
DBGOFF ; Debug off
 K ^XTMP("VFDVOH")
 Q
DBGRST ; Debug reset
 ; Cycle off (clear) and on
 D DBGOFF,DBGON
 Q
