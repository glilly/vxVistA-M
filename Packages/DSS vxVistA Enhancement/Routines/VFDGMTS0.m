VFDGMTS0 ;TPA/SGM - CONTINGENCY HEALTH SUM UTILITY ;05/23/2001 13:15
 ;;2009.2;DSS,INC VXVISTA OPEN SOURCE;;01 Dec 2009
 ;Copyright 1995-2009,Document Storage Systems Inc. All Rights Reserved
 ;
 ; Adapted from routine ^GMTSZHS0 (Tampa)
 ;;2.7;;;
 ; called from gmtszhs* (VFDGMTS*)
CRFN(PRE,DFN) ;  create file name for patient DFN
 ;  PRE - optional - prefix for filename
 ;  return null or prefix_patientname_last6ssn.txt
 N I,J,X,Y,ASSN,NAME,PUN,RET,SEP
 S RET="",SEP="_",PUN=" ,~`!@#$%^&*()-+={}[]|\:;'.<>/?"_$C(34)
 ;  only allow non-test patients who are not dead
 S X=$G(^DPT(+$G(DFN),0)),NAME=$P(X,U),ASSN=$E($P(X,U,9),4,11)
 S Y=ASSN,ASSN="",I=0
 F  S I=$O(^ASL(+$G(DFN),21600,I)) Q:'I  S J=^(I,0) D  Q:ASSN'=""
 .I $P(J,U,5)="MRN" S ASSN=$P(J,U,2)
 .Q
 I ASSN="",Y'="" S ASSN=Y
 S PRE=$TR($G(PRE),PUN,"__"),NAME=$TR(NAME,PUN,"__")
 I X]"",'+$G(^(.35)),'$P(X,U,21) D
 .I PRE="" S Y=NAME_SEP_ASSN
 .E  S Y=PRE_SEP_$E(NAME,1,37-$L(ASSN)-$L(PRE))_SEP_ASSN
 .S RET=Y_".TXT"
 .Q
 Q RET
 ;
DEF ;  get default health summaries,paths, and divisions only
 ;  def(0,"I")         facility inpat hs ien
 ;  def(0,"I","PATH")  host system path for inpat hs files
 ;  def(0,"I","NT")    nt path to where the files will end up
 ;  def(0,"O")         facility outpat hs ien
 ;  def(0,"O","PATH")  host system path for outpat hs files
 ;  def(0,"O","NT")    nt pather to where the files will end up
 ;  def(0,"NTDEST")    parent nt path to ftp files to
 ;  def(#)             zeroth node of field 6.1 where #=division ien
 ;  def(0,"HFS")       name of HFS device to use to write hs
 K DEF N I,J,X,Y,Z
 ;DSS/LM - INSTANCE=2 (Outpatient)
 S DEF(0,"O")=$$GET^XPAR("SYS","VFD GMTS CONTINGENCY TYPE",2)
 S DEF(0,"O","PATH")=$$GET^XPAR("SYS","VFD GMTS CONTINGENCY PATH",2)
 S:'$L(DEF(0,"O","PATH")) DEF(0,"O","PATH")="D:\HFS\HS\"
 S DEF(0,"HFS")="HFS"
 S DEF(0,"O","NT")=""
 ;
 ;Q  ;DSS/LM Remove conditional QUIT.  Continue to INPATIENT defaults
 ;
 S Z="",Z(2)=""
 ;DSS/LM - INSTANCE=1 (Inpatient)
 S DEF(0,"I")=$$GET^XPAR("SYS","VFD GMTS CONTINGENCY TYPE",1)
 S DEF(0,"I","PATH")=$$GET^XPAR("SYS","VFD GMTS CONTINGENCY PATH",1)
 S:'$L(DEF(0,"I","PATH")) DEF(0,"I","PATH")=$P(Z,U,3),DEF(0,"O","PATH")=$P(Z,U,4)
 S DEF(0,"I","NT")=$P(Z(2),U),DEF(0,"O","NT")=$P(Z(2),U,2)
 S DEF(0,"NTDEST")=$P(Z,U,5),I=0
 Q
 ;
