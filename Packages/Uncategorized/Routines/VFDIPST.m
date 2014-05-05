VFDIPST ;DSS/LM - Post-install for vxVistA prescription processing
 ;;2009.2;DSS,INC VXVISTA OPEN SOURCE;;01 Dec 2009
 ;Copyright 1995-2009,Document Storage Systems Inc. All Rights Reserved
 ;
 Q
 ; Main entry point (drives T line selection)
EN1 ;
 D T1,T2,T3
 Q
 ;
T1 ;
 ;vXVistA - Setup for auto-finish outpatient pharmacy order
 ; New ORDER STATUS will be created as IEN=100 in File 100.01 unless
 ; a different IEN is specified as a parameter in the call to ORDSTUS.D ORDSTUS^VFDIPST1()
 ; For example, D ORDSTUS^VFDIPST1(16) creates the entry as IEN=16.
 ;
 D ORDSTUS^VFDIPST1() ;Verify/add WRITTEN to ORDER STATUS File 100.01
 Q
 ;
T2 ;
 ;vXVistA - Setup for auto-finish outpatient pharmacy order
 D NWPRSN^VFDIPST1 ;Verify/add "COMMERCIAL,PHARMACY" to NEW PERSON File 200
 Q
 ;
T3 ;
 ;vXVistA - Setup for merge of alternate IDs
 D MERGE^VFDIPST1  ;Verify/Add merge routine to PACKAGE (#9.4) file.
 Q
 
