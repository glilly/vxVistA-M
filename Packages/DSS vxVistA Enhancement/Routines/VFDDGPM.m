VFDDGPM ;DSS/SGM - DG ADT OPTIONS AND UTILITIES ; 3/1/2013 18:20
 ;;2011.1.2;DSS,INC VXVISTA OPEN SOURCE;;11 Jun 2013;Build 7
 ;Copyright 1995-2013,Document Storage Systems Inc. All Rights Reserved
 ;
 ;No VFDDGPM* routines should be called directly except by this routine
 ;
 ;-------------------------  PROGRAMMER APIS  -------------------------
ADMITDX() ;
 ; Also called from modified [DGPM ADMIT] input template,
 ; Return pointer to File 80 ICD DIAGNOSIS (coded admit diagnosis)
 Q $$ADMITDX^VFDDGPM1()
 ;
 ;-----------------------  DATA DICITIONARIES  ------------------------
 ;
 ;--------------------------  KIDS INSTALLS  --------------------------
POST ; called from POST1^VFDI0003
 D POST^VFDDGPM2(1,0)
 Q
 ;
 ;-------------------------  INPUT TEMPLATES  -------------------------
 ;
 ;-----------------------------  OPTIONS  -----------------------------
 ;
 ;----------------------------  PROTOCOLS  ----------------------------
 ;
EN ; Protocol VFD DGPM ADMIT/VISIT EVENTS action
 ; This VFD protocol is an item in the Protocol DGPM MOVEMENT EVENTS
 D EN^VFDDGPM2
 Q
 ;
 ;------------------------  REMOTE PROCEDURES  ------------------------
