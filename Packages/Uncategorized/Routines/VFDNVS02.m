VFDNVS02 ;DSS/RAC - DSS Scrambler for patients and new persons ;18 July 2011 9:00
 ;;6.0;EMC TEST ACCOUNT RESET UTILITIES; 13 Jun 2011;;Build 24
 ;Copyright 1995-2011,Document Storage Systems Inc. All Rights Reserved
 ;
 ; ICR#  Supported Description
 ;-----  ----------------------------------------------------------
 ;       ^%ZIS
 ;       ^%ZISC
 ;       ^%ZTLOAD
 ;       FILE^DIE
 ;
 ; Called from the following routines:  ^NVSPDS1 and ^NVSPDS4
 ;
 ; Uses values entered into file 21619 multiple under
 ; the Postmaster user to randomlly select based on sex
 ; a Female or Male name
 ;
 ; Generate a valid DEA number all Users if one exists using
 ; DEA entry algorithm.
 ;
 ;
 ;-----------------------  PRIVATE SUBROUTINES  ----------------------
 ;
DEA(IEN,DEA)  ;Generate new DEA # to match new name  If DEA # exist
 N DEAIT,DEANM,II,IJ,ODEA,Y
 S IEN=$G(IEN),ODEA=$G(DEA),DEANM=$G(^VA(200,IEN,0))
 Q:ODEA=""
 ;Get first initial of first and last name
 S DEAIT=$E($P($P(DEANM,U),",",1),1,1)
 N II F II=1:1:6 S X(II)=$$RN(9)
 S X(7)=(X(1)+X(3)+X(5)+(2*(X(2)+X(4)+X(6))))#10
 N IJ S Y=""
 F IJ=1:1:7 S Y=Y_X(IJ)
 Q "A"_DEAIT_Y
 ;
NAME(VFDSEX)  ;Entry point to scramble name
 N FN,LN,MI,VFDZ
 S SEX=$G(VFDSEX)
 S FN=$$FNAM(SEX),LN=$$LNAM(),MI=$C($$RN(26)+65)
 Q LN_","_FN_" "_MI
 ;
FNAM(SEX) ;Randomly select a First name
 N PST,RN,VFDX,X,Z
 S SEX=$G(SEX),VFDX="NOFIRST",Z=""
 S PST="",PST=$O(^VFD(21619,"B",".5;VA(200,",PST))
 S RN=$P(^VFD(21619,PST,1,0),U,4),X=$$RN(RN)
 S:SEX="F" Z=1
 S:SEX="M" Z=2
 S:'$D(Z) Z=$$RN(2)
 S:Z<1 Z=1
 S:Z>1 Z=2
 I X=0 S X=9
 S VFDX=^VFD(21619,PST,Z,X,0)
 Q VFDX
 ;
LNAM()  ;randomly select LAST name
 N PST,RN,VFDX,Z
 S VFDX="NOLAST"
 S PST="",PST=$O(^VFD(21619,"B",".5;VA(200,",PST))
 S RN=$P(^VFD(21619,PST,3,0),U,4)
 S Z=$$RN(RN)
 S:Z<1 Z=1
 S VFDX=^VFD(21619,PST,3,Z,0)
 Q VFDX
 ;
RN(NUM)  ;Generate a random number based on number
 N J
 S NUM=$G(NUM)  ;Number range
 F J=$R(NUM) Q:J>0
 Q J
