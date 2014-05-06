VFDPXENC ;CFS - Builds the array of all encounter data for the event point ; 05/13/2013 11:53am
 ;;2011.1.3;DSS,INC VXVISTA OPEN SOURCE;**1**;08 Aug 2013
 ;Copyright 1995-2013,Document Storage Systems Inc. All Rights Reserved
 ;;Copyright 1995-2013,Document Storage Systems Inc. All Rights Reserved
 Q
 ;
GETENC(DFN,ENCDT,HLOC) ;Get all of the encounter data
 ;Parameters:
 ;  DFN    Pointer to the patient (#9000001)
 ;  ENCDT  Date/Time of the encounter in Fileman format
 ;  HLOC   Pointer to Hospital Location (#44)
 ;
 ;Returns:
 ;  -2  if called incorrectly
 ;  -1  if could not find encounter
 ;  >0  Visit ien(s) separated by ^
 ;
 ;  The encounter is returned in the array
 ;    ^TMP("PXKENC",$J,pointer to visit)
 ;  may contain more than one visit
 ;
 N VISITIEN,REVDT,RETURN
 K ^TMP("PXKENC",$J)
 S RETURN=-1
 Q:DFN'>0!(ENCDT<1800000)!(HLOC'>0) -2
 S REVDT=(9999999-$P(+ENCDT,".",1))_$S($P(+ENCDT,".",2)'="":"."_$P(+ENCDT,".",2),1:"")
 S VISITIEN=0
 F  S VISITIEN=$O(^AUPNVSIT("AA",+DFN,REVDT,VISITIEN)) Q:'VISITIEN  D
 . I $P($G(^AUPNVSIT(VISITIEN,0)),"^",22)=HLOC,"C~S"'[$P($G(^AUPNVSIT(VISITIEN,150)),"^",3) D
 .. D ENCEVENT(VISITIEN,1)
 .. I RETURN<1 S RETURN=VISITIEN
 .. E  S RETURN=RETURN_"^"_VISITIEN
 Q RETURN
 ;
ENCEVENT(VISITIEN,PXKROOT) ;Create the ^TMP("PXKENC",$J, array of all the
 ;  information about vxVistA encounter for one visit.
 ;Parameters:
 ;  VISITIEN  Pointer to the Visit (#9000010)
 ;  PXKROOT   ^TMP("PXKENC",$J,pointer to visit)
 ;
 ;  The encounter is returned in the array
 ;    ^TMP("PXKENC",$J,pointer to visit)
 ;
 N IEN,FILE,FILESTR,NODE,PXKNODE,REF,VFILE
 F FILE="SN4" D
 . S FILESTR="VFDPX"_FILE
 . S VFILE=$P($T(GLOBAL^@(FILESTR)),";;",2)
 . S REF=VFILE_"""AD"""_","_VISITIEN_")"
 . S IEN="" F  S IEN=$O(@REF@(IEN)) Q:'IEN  D
 .. S NODE=VFILE_IEN_")"
 .. S PXKNODE=""
 .. F  S PXKNODE=$O(@NODE@(PXKNODE)) Q:PXKNODE=""  D:PXKNODE'=801
 ... S @PXKROOT@(FILESTR,IEN,PXKNODE)=$G(@NODE@(PXKNODE))
 Q
 ;
COEVENT(VISITIEN,PXKROOT) ;Add to the ^TMP("PXKCO",$J, array all of the
 ;   information that is not already there.
 I '$D(^AUPNVSIT(VISITIEN)) Q
 N PXKROOT
 S PXKROOT=$NA(@("^TMP(""PXKCO"",$J,"_VISITIEN_")"))
 ;
 N FILE,FILESTR,IEN,NODE,REF,VFILE,PXKNODE
 F FILE="SN4" D
 . S FILESTR="VFDPX"_FILE
 . S VFILE=$P($T(GLOBAL^@(FILESTR)),";;",2)
 . S REF=VFILE_"""AD"""_","_VISITIEN_")"
 . S IEN="" F  S IEN=$O(@REF@(IEN)) Q:'IEN  D
 .. S NODE=VFILE_IEN_")"
 .. S PXKNODE=""
 .. I '$D(@PXKROOT@(FILESTR,IEN)) D
 ... F  S PXKNODE=$O(@NODE@(PXKNODE)) Q:PXKNODE=""  D:PXKNODE'=801
 .... S @PXKROOT@(FILESTR,IEN,PXKNODE,"BEFORE")=$G(@NODE@(PXKNODE))
 .... S @PXKROOT@(FILESTR,IEN,PXKNODE,"AFTER")=$G(@NODE@(PXKNODE))
 Q
 ;
