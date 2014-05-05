VFDDGPM1 ;DSS/LM - PAMS Movement Events Support ; 3/4/2013 14:35
 ;;2011.1.2;DSS,INC VXVISTA OPEN SOURCE;;11 Jun 2013;Build 7
 ;Copyright 1995-2013,Document Storage Systems Inc. All Rights Reserved
 ;
 ; Only to be called from routine VFDDGPM
 ;
 ; ICR#  Supported Description
 ; ----  ---------------------
 ; 1609  Lexicon setup search parameters
 ; 3990  ICD code API
 ; 
 Q
 ;
ADMITDX() ; expects X=lookup value
 N I,J,X,Y,D0,DA,DIC,DTOUT,DUOUT
 D CONFIG^LEXSET("ICD",,DT)
 S DIC="^LEX(757.01,",DIC(0)="EQM",DIC("A")="DIAGNOSIS [ICD]: " D ^DIC
 Q:$G(Y(1))<1 ""
 Q +$$ICDDX^ICDCODE(Y(1),DT)
 ;
