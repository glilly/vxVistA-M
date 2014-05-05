VFDVOH ;DSS/LM - Receive and process ORDER messages ; 09 Apr 2013  10:51 AM
 ;;2011.1.2;DSS,INC VXVISTA OPEN SOURCE;;11 Jun 2013
 ;Copyright 1995-2013,Document Storage Systems Inc. All Rights Reserved
 ;
 ; Active integration agreements
 ; 
 ; 2164   GENERATE^HLMA
 ; 3630   BLDPID^VAFCQRY
 ; 10063  ^%ZTLOAD
 ; 10108  CREATE^HLTF
 Q
 ;
EN(VFDVMSG,VFDVTO) ;;Main entry
 ; VFDVMSG (array or name of array)
 ; VFDVTO=Namespace of target application -
 ;        DGPM, FH, GMRC, LRAP, LRBB, LRCH, ORG, PS, RA
 ;
 Q:'$$ACTIVE^VFDVOHU("VFDV VISTA")
 Q:'$D(VFDVMSG)  Q:$G(VFDVTO)=""  Q:$T(@VFDVTO)=""
 ; collect common HL7 fields that multiple packages may want to examine
 ; and other values
 N VFDORD D PARSE^VFDVOH01(.VFDORD) Q:($G(VFDORD)=""!($G(VFDORD("PSAUTO"))=0))
 ;
 I $G(VFDORD("TASK"))=0 G DQ
 N I,J,X,Y,Z,ZTDESC,ZTDTH,ZTIO,ZTRTN,ZTSAVE,ZTSK
 F X="VFDORD*","VFDVMSG(","VFDVTO" S ZTSAVE(X)=""
 S ZTIO="",ZTDTH=$$NOW^XLFDT(),ZTRTN="DQ^VFDVOH"
 S ZTDESC="vxVistA Orders HL7"
 D ^%ZTLOAD
 Q
 ;
DQ ;;Dequeue task - Process message
 ; D DEBUG(,"DQ")
 N I,J,X,Y,Z,DFN,HL,HLA,HLEXROU,VFDVERR,VFDVI,VFDVPID,VFDVRSLT
 S VFDVERR=""
 Q:$$INIT^VFDVOHU(.HL,"VFDV ORM-O01 SERVER")
 S X=$E($G(VFDVMSG(1)),1,3) I X="BHS"!(X="BTS") D BHS,QUIT Q  ;HL batch
 ;
 ; Single message
 S DFN=$G(VFDORD("DFN")) Q:'DFN  ; DFN required
 ; Omit EVN
 D BLDPID^VAFCQRY(DFN,1,"1,2,3,7,18,19",.VFDVPID,.HL,.VFDVERR)
 ; D DEBUG(.VFDVERR)
 Q:'$D(VFDVPID)
 S VFDVI=1 S HLA("HLS",VFDVI)=VFDVPID(1)
 F J=2:1 Q:'$D(VFDVPID(J))  S HLA("HLS",VFDVI,J-1)=VFDVPID(J)
 S VFDVI=VFDVI+1,HLA("HLS",VFDVI)=$$PV1^VFDVOHU1(DFN)
 F I=1:1 Q:'$D(VFDVMSG(I))  D  ;Merge remaining segments
 . K X M X=VFDVMSG(I) Q:"MSH^PID^PV1"[$E(X,1,3)!($E(X)="Z")
 . S VFDVI=VFDVI+1 M HLA("HLS",VFDVI)=X
 . Q
 ; Coding in progress
 D @VFDVTO
 ; Coding in progress
 K HLEXROU,VFDVRSLT D GENERATE^HLMA(HL("EID"),"LM",1,.VFDVRSLT)
 ; D DEBUG(.VFDVRSLT)
 D QUIT
 ;
 ;------------  PROCESSING MODULES FOR EACH VISTA PACKAGE  ------------
BHS ; Process batch here
 Q  ; Ignore batch wrapper.  Process included messages individually.
 ; D DEBUG(,"BHS")
 N HLEXROU,HLRSLT,VFDVBCNT,VFDVBEID,VFDVBIEN,VFDVBMID,VFDVBMSG,VFDVI
 N VFDVJ
 S VFDVBEID=HL("EID") ;From DQ
 D CREATE^HLTF(.VFDVBMID,.VFDVBIEN) Q:'$G(VFDVBMID)
 S VFDVBCNT=0,VFDVBMSG=$NA(^TMP("HLS",$J)) K @VFDVBMSG
 ; Generate component messages here
 ; First approximation has no change to messages, except to replace MSH
 S VFDVJ=0 F VFDVI=2:1 Q:'$D(VFDVMSG(VFDVI))  D
 . I VFDVMSG(VFDVI)?1"MSH".E D  Q
 . . S VFDVBCNT=1+VFDVBCNT K HLEXROU,HLRSLT S HLRSLT=""
 . . D MSH^HLFNC2(.HL,VFDVBMID_"-"_VFDVBCNT,.HLRSLT)
 . . S VFDVJ=1+VFDVJ,@VFDVBMSG@(VFDVJ)=HLRSLT
 . . Q
 .; Modify PID etc. here
 . S VFDVJ=1+VFDVJ,@VFDVBMSG@(VFDVJ)=VFDVMSG(VFDVI)
 . Q
 ; Coding in progress - Application specific modifications
 ; Finally -
 Q:'$G(VFDVBCNT)!'$D(@VFDVBMSG)  ;No batch contents
 K HLRSLT D GENERATE^HLMA(VFDVBEID,"GB",1,.HLRSLT,VFDVBIEN)
 D QUIT
 Q
 ;
DGPM ;
 ; D DEBUG(,"DGPM")
 Q
 ;
FH ;
 ; D DEBUG(,"FH")
 Q
 ;
GMRC ;
 ; D DEBUG(,"GMRC")
 Q
 ;
LRAP ;
 ; D DEBUG(,"LRAP")
 Q
 ;
LRBB ;
 ; D DEBUG(,"LRBB")
 Q
 ;
LRCH ;
 ; D DEBUG(,"LRCH")
 Q
 ;
NOP ; VFDVOH*1.0*1 [No-operation] Dummy processing routine
 ; Attach to VFDV ORM-O01 CLIENT protocol when no logical link
 ; is attached to this protocol.
 Q
 ;
ORG ;
 ;D DEBUG(,"ORG")
 Q
 ;
PS ;
 ; D DEBUG(,"PS")
 N X S X=$$PS^VFDVOH01 I +X S X=$P(X,"~",2,99) D:X]"" @X
 Q
 ;
RA ;
 ; D DEBUG(,"RA")
 Q
 ;
QUIT ; Final cleanup
 ; D DEBUG(,"Q")
 Q
 ;
 ;-------------------  PRIVATE COMMON SUBROUTINES  --------------------
DEBUG(Z,T) ;
 S T=$G(T) I T'="" D
 . I T="BHS" S T="BHS~VFDVOH" Q
 . I T="Q" S T="Quit" Q
 . I T="DQ" S T="DQ~VFDVOH reached.  ZTSK="_$G(ZTSK)_", $J="_$J Q
 . I T="DGPM" S T="PIMS"
 . I T="FH" S T="Diet"
 . I T="GMRC" S T="Consult"
 . I T="LRAP" S T="Anatomic Pathology"
 . I T="LRBB" S T="Blood Bank"
 . I T="LRCH" S T="LAB"
 . I T="ORG" S T="Generic"
 . I T="PS" S T="Pharmacy"
 . I T="RA" S T="Radiology"
 . S T=T_" ("_Z_") order message received."
 . Q
 I T="",$D(Z) M T=Z
 I $D(T) D DEBUG^VFDVOHU(.T)
 Q
