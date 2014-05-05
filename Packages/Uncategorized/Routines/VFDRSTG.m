VFDRSTG ;DSS/RAC - ARRA STRING TO GLOBAL ; 05/21/2011 18:54
 ;;2011.1.2;DSS,INC VXVISTA OPEN SOURCE;;28 Jan 2013;Build 153
 ;Copyright 1995-2013,Document Storage Systems Inc. All Rights Reserved
 ;
 ;This API returns a global of data string passed in
 ;
 ; Input:
 ;    File number (Optional) default = 1
 ;    String (Required) deliminated with "^" containing the following:
 ;      PQRI - Report number
 ;      ELIG - count eligible
 ;      MEETS - number that meet criteria
 ;      EXCL - number excluded
 ;      NOTMET - number not meeting criteria
 ;    Start Date
 ;    End Date
 ;
 ; Output:
 ;    Returns VFDRET the global name ^TMP("VFDRSTG",$J)
 ;
 ;    ^TMP(Routine Name, $J, File Number,"PQRI") =
 ;              the PQRI report number
 ;    ^TMP(Routine Name, $J, File Number,"ELIG") =
 ;              Number of eligible instances for the performance measure. 
 ;    ^TMP(Routine Name, $J, File Number,"MEETS") =
 ;              Number of instances of quality service performed.
 ;    ^TMP(Routine Name, $J, File Number,"EXCL") =
 ;              Number of performance exclusions for the PQRI measure
 ;    ^TMP(Routine Name, $J, File Number,"NOTMET") =
 ;               Number of instances that do NOT meet the performance
 ;               criteria, even though Routine occurred.
 ;
 Q
 ;
EN(VFDR,STRING,START,END,FILE) ;Entry point RPC:  VFD ARRA IN PT XML
 N X,Y,Z,FIL,VFD,VFDEG,VFDEX,VFDFIL,VFDMT,VFDNM,VFDPQ
 N VFDSDT,VFDEDT,VFDSTR,VFDRET
 S VFDSTR=$G(STRING),VFDFIL=$G(FILE)
 S VFDSDT=$G(START),VFDEDT=$G(END)
 I (VFDSDT="")!(VFDEDT="") S VFDR="-1^Invaild date(s)" Q
 I VFDSTR="" S VFDR="-1^Invalid input string" Q
 S:VFDFIL="" VFDFIL=1
 S VFDPQ=$P(VFDSTR,U,1),VFDEG=$P(VFDSTR,U,2),VFDMT=$P(VFDSTR,U,3)
 S VFDEX=$P(VFDSTR,U,4),VFDNM=$P(VFDSTR,U,5)
 I VFDPQ="" S VFDR="-1^Invalid PQRI Report Name" Q
 I $G(VFDEG)="" S VFDEG=0
 I $G(VFDMT)="" S VFDMT=0
 I $G(VFDEX)="" S VFDEX=0
 I $G(VFDNM)="" S VFDNM=0
 S VFDRET=$NA(^TMP("VFDRSTG",$J)),Z=$NA(@VFDRET@(VFDFIL)) K @Z
 S @Z@("PQRI")=VFDPQ
 S @Z@("ELIG")=VFDEG
 S @Z@("MEETS")=VFDMT
 S @Z@("EXCL")=VFDEX
 S @Z@("NOTMET")=VFDNM
 D IXML^VFDRPARX(.VFDR,"VFDRSTG",VFDSDT,VFDEDT,VFDRET)
 Q
