VFDDGPMU ;DSS/WLC - PATIENT MOVEMENT UTILITIES ;02/17/2011 12:36
 ;;2011.1.2;DSS,INC VXVISTA OPEN SOURCE;;11 Jun 2013;Build 7
 ;Copyright 1995-2013,Document Storage Systems Inc. All Rights Reserved
 ;
Q  ; call by line tag only
 ;
ADMIT(VFDRT,START,END)  ;RPC: VFD DGPM ADMIT (admissions only during time frame)
 ;
 ;  INPUT:
 ;
 ;    START= Start date for extract (FM Format)
 ;      END= End date for extract (FM format)
 ;
 ;  OUTPUT:
 ;
 ;   VFDRT (^TMP("VFDDGPMU",$J) ) where:
 ;     VFDRT(DFN,IEN TO ^DGPM) = FILEMAN D/T of ADMISSION movement 
 ;
 N CNT,DAT,DFN,IEN
 S VFDRT=$NA(^TMP("VFDDGPMU",$J)) K @VFDRT
 S START=$G(START) I 'START S @VFDRT@(0)="-1^Invalid Start date." Q
 S END=$G(END) I 'END S @VFDRT@(0)="-1^Invalid End Date" Q
 I END<START S @VFDRT@(0)="-1^Start date must be before End Date." Q
 S (CNT,DFN)=0 F  S DFN=$O(^DGPM("APTT1",DFN)) Q:'DFN  D
 . S DAT=0 F  S DAT=$O(^DGPM("APTT1",DFN,DAT)) Q:'DAT  D
 . . I DAT'<START,DAT'>END D
 . . . S IEN=0 F  S IEN=$O(^DGPM("APTT1",DFN,DAT,IEN)) Q:'IEN  D
 . . . . S @VFDRT@(DFN,IEN)=DAT,CNT=CNT+1
 S @VFDRT@(0)=CNT
 Q
 ;
DISCH(VFDRT,START,END)  ; RPC:  VFD DGPM DISCH (discharges during time frame)
 ;
 ;  INPUT:
 ;
 ;    START= Start date for extract (FM Format)
 ;      END= End date for extract (FM format)
 ;
 ;  OUTPUT:
 ;
 ;   VFDRT (^TMP("VFDDGPMU",$J) ) where:
 ;     VFDRT(DFN,IEN TO ^DGPM) = FILEMAN D/T of DISCHARGE movement 
 ;
 N CNT,DAT,DFN,IEN
 S VFDRT=$NA(^TMP("VFDDGPMU",$J)) K @VFDRT
 S START=$G(START) I 'START S @VFDRT@(0)="-1^Invalid Start date." Q
 S END=$G(END) I 'END S @VFDRT@(0)="-1^Invalid End Date" Q
 I END<START S @VFDRT@(0)="-1^Start date must be before End Date." Q
 S (CNT,DFN)=0 F  S DFN=$O(^DGPM("APTT3",DFN)) Q:'DFN  D
 . S DAT=0 F  S DAT=$O(^DGPM("APTT3",DFN,DAT)) Q:'DAT  D
 . . I DAT'<START,DAT'>END D
 . . . S IEN=0 F  S IEN=$O(^DGPM("APTT3",DFN,DAT,IEN)) Q:'IEN  D
 . . . . S @VFDRT@(DFN,IEN)=DAT,CNT=CNT+1
 S @VFDRT@(0)=CNT
 Q
 ;
INPAT(VFDRT,START,END)  ; RPC:  VFD DGPM INPT (all inpatients in date range)
 ;
 ;  INPUT:
 ;
 ;    START= Start date for extract (FM Format)
 ;      END= End date for extract (FM format)
 ;
 ;  OUTPUT:
 ;
 ;   VFDRT (^TMP("VFDDGPMU",$J) ) where:
 ;     VFDRT(DFN,IEN TO ^DGPM) = FILEMAN D/T of ADMISSION or DISCHARGE movement 
 ;
 N CNT,DAT,DFN,IEN
 S VFDRT=$NA(^TMP("VFDDGPMU",$J)) K @VFDRT
 S START=$G(START) I 'START S @VFDRT@(0)="-1^Invalid Start date." Q
 S END=$G(END) I 'END S @VFDRT@(0)="-1^Invalid End Date" Q
 I END<START S @VFDRT@(0)="-1^Start date must be before End Date." Q
 S (CNT,DFN)=0 F  S DFN=$O(^DGPM("APTT1",DFN)) Q:'DFN  D
 . S DAT=0 F  S DAT=$O(^DGPM("APTT1",DFN,DAT)) Q:'DAT  D
 . . Q:DAT>END
 . . K VAIP S VAIP("D")=DAT D IN5^VADPT
 . . I VAIP(13),+VAIP(13,1)<END,'VAIP(14) S @VFDRT@(DFN,VAIP(13))=+VAIP(13,1),CNT=CNT+1 Q
 . . I VAIP(13),+VAIP(14,1)>START,+VAIP(14,1)<END S @VFDRT@(DFN,VAIP(14))=+VAIP(14,1),CNT=CNT+1 Q
 S @VFDRT@(0)=CNT
 Q
 ;
