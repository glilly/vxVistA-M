VFDGMPL ;DSS/LM - vxVistA Problem List Enhancements ;January 15, 2008
 ;;2009.2;DSS,INC VXVISTA OPEN SOURCE;;01 Dec 2009
 ;Copyright 1995-2009,Document Storage Systems Inc. All Rights Reserved
 ;
 Q
COMPARE(VFDRSLT,DFN,VFDNPUT,VFDOPT) ;Remote procedure VFD COMPARE PROBLEMS
 ;
 ; DFN    =[Required] Patient IEN (passed through)
 ; VFDNPUT=[Optional] Qualifying data for comparison, for example,
 ;                     (1)=ICD9-1, (2)=ICD9-2, etc. (default)
 ; VFDOPT =[Optional] Options controlling behavior of this RPC/API.
 ;                    Default is compare input list to active problems.
 ; 
 ; VFDRSLT=[By reference] (1)=-1^Error Text OR subscripted array of
 ;                    comparison results, for example,
 ;                    (1)=ICD9-1^Date of onset (ext), (2)=ICD9-2^Date ...
 ;                    where ICD9 codes represent ACTIVE problems, matching
 ;                    codes supplied in the qualifying data (VFDNPUT).
 ; 
 S DFN=+$G(DFN) I '(DFN>0) S VFDRSLT(1)="-1^Missing or invalid DFN" Q
 S VFDOPT=$G(VFDOPT)
 ; Future VFDOPT values may override VFDNPUT requirements
 I '$D(VFDNPUT(1)) S VFDRSLT(1)="-1^No input data for comparison" Q
 N VFDI,VFDJ,VFDK,VFDICD,VFDR,VFDX S VFDK=0
 S VFDR=$NA(^TMP("IB",$J,"INTERFACES",DFN,"GMP PATIENT ACTIVE PROBLEMS"))
 K @VFDR D ACTIVE^GMPLENFM S VFDI=0 F  S VFDI=$O(@VFDR@(VFDI)) Q:'VFDI  D
 .S VFDICD=$P($G(@VFDR@(VFDI)),U,2) S:VFDICD]"" VFDX(VFDICD,VFDI)="" ;ICD X-REF
 .Q
 F VFDI=1:1 Q:'$D(VFDNPUT(VFDI))  D
 .S VFDICD=$P(VFDNPUT(VFDI),U) Q:VFDICD=""
 .S VFDJ=$O(VFDX(VFDICD,"")) Q:'VFDJ
 .S VFDK=VFDK+1,VFDRSLT(VFDK)=VFDICD_U_$P(@VFDR@(VFDJ),U,3)
 .Q
 S:'VFDK VFDRSLT(1)="-1^No match found"
 K @VFDR
 Q
