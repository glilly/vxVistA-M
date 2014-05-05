VFDA302R ;DSS/SGM - FILEMAN AUDIT LOG ARRA ; 08/24/2011 11:55
 ;;2011.1.2;DSS,INC VXVISTA OPEN SOURCE;;28 Jan 2013;Build 153
 ;Copyright 1995-2013,Document Storage Systems Inc. All Rights Reserved
 ;
 Q
EN ; 170.302.r - show Fileman AUDIT
 N I,J,X,Y,Z,VFILE,VSORT
 S VFILE=$$PFILE Q:VFILE<1  S VFILE(0)=$P(VFILE,U,2),VFILE=+VFILE
 S VSORT=$$SACT Q:"ADPRU"'[VSORT
 S (VSORT("ED"),VSORT("SD"))=""
 S X=$$SDATE I X<1,VSORT="D" Q
 I VSORT="D" Q:$$SDATE<1
 Q:$$SACC<0
 D SORT
 Q
 ;
 ;-----------------------  PRIVATE SUBROUTINES  -----------------------
ACT(FILE,IEN,FLG) ; compute action taken
 ; FILE - req - number of file that is audited
 ;  IEN - req - internal record number in ^DIA(DIA)
 ;  FLG - opt - if 0 just return key value - default
 ;                 1 just retrun full value
 ;                 2 return key^full value
 ;              where values are
 ;              A for new value for field
 ;              E for existing value of field changed
 ;              D for value for field deleted
 N I,J,X,Y,Z,VNEW,VOLD,RET
 S FLG=+$G(FLG)
 I $G(^DIA(+$G(FILE),+$G(IEN),0))="" Q -1
 I $D(^DIA(FILE,IEN,3.1))#2 S VNEW=$P(^(3.1),U)
 E  I $D(^DIA(FILE,IEN,3))#2 S $P(VNEW,U,2)=$P(^(3),U)
 I $D(^DIA(FILE,IEN,2.1))#2 S VOLD=$P(^(2.1),U)
 E  I $D(^DIA(FILE,IEN,2))#2 S $P(VOLD,U,2)=$P(^(2),U)
 I '$D(VOLD),'$D(VNEW) Q -1
 I '$D(VOLD) S RET="A"
 I '$D(RET),'$D(VNEW) S RET="D"
 I '$D(RET) S RET="E"
 S Y=$S(RET="A":"Added",RET="D":"Deleted",1:"Edited")
 S X=$S('FLG:RET,FLG=1:Y,1:RET_U_Y)
 Q X
 ;
DIR(DIR) ;
 N X,Y,DIROUT,DIRUT,DTOUT,DUOUT
 W ! D ^DIR S Y=$S($D(DUOUT):-1,$D(DTOUT):-1,Y="":-1,1:Y)
 Q $$UP^XLFSTR(Y)
 ;
PFILE() ; prompt for file
 N X,Y,Z,DIC S DIC=1,DIC(0)="QAEM" D ^DIC Q Y
 ;
SACC() ; prompt as to include accessed audit records
 N X,Y,Z
 S Z(0)="YOA",Z("B")="NO",Z("A")="Include accessed audit records? "
 S Y=$$DIR(.Z) S:Y>-1 VSORT("ACC")=Y
 Q Y
 ;
SACT() ; prompt for sorting criteria
 ;;A:action taken;D:date/time;P:patient ID;R:record #;U:user ID
 N X,Y,Z
 S Z(0)="SOM^"_$P($T(SACT+1),";",3,99),Z("B")="P"
 S Z("A")="Select Audit sorting criterion"
 Q $$UP^XLFSTR($$DIR(.Z))
 ;
SDATE() ; prompt for starting/ending date
 N I,J,X,Y,Z
 S X=$$DATE^VFDCFM(,,1) I X<1 Q -1
 S VSORT("SD")=+X,VSORT("ED")=+$P(X,U,3)
 Q 1
 ;
 ;8/24/2012 - sort is currently hard coded for the PROBLEM list only
 ; It is not generalized.  The purpose of this program was written for
 ; ARRA NQF reporting for auditing which is patient specific.  Since
 ; many files have patient data but no direct pointers to the patient
 ; file it is difficult to sort by patient.
 ; Note to self: add computed fields to the AUDIT file DD to display
 ;   add, edit, delete
 ;
SORT ; build the sorted array, return VFDRET()
 ;;Patient ID       Date/time       User ID   Action   AuditIEN  Record#
 ;;----------  -------------------  -------  --------  --------  -------
 N I,J,X,Y,Z,ACC,ACT,DATE,DFN,FLD,IFN,PAT,STOP,USER,VNEW,VOLD,VTMP
 S VTMP=$NA(^TMP("VFDA302R",$J)) K @VTMP
 S I=0 F  S I=$O(^DIA(VFILE,I)) Q:'I  S X=^(I,0) D
 .S IFN=+X,DFN=+$P($G(^AUPNPROB(IFN,0)),U,2)
 .S DATE=+$P(X,U,2),FLD=+$P(X,U,3),USER=+$P(X,U,4)
 .I VSORT("SD")'="",DATE<VSORT("SD") Q
 .I VSORT("ED")'="",DATE>VSORT("ED") Q
 .S ADD=($P(X,U,5)="A"),ACC=$P(X,U,6)
 .S VNEW=$P($G(^DIA(VFILE,I,3.1)),U) S:VNEW="" VNEW=$P($G(^(3)),U)
 .S VOLD=$P($G(^DIA(VFILE,I,2.1)),U) S:VOLD="" VOLD=$P($G(^(2)),U)
 .S ACT=$$ACT(VFILE,I,2)
 .I ACC S ACT="X:accessed" Q:'$G(VSORT("ACC"))
 .S Y=DFN_U_DATE_U_USER_U_$P(ACT,U,2)_U_I_U_IFN_U_ACC
 .I VSORT="D" S @VTMP@(2,DATE,I)=Y
 .I VSORT="U" S @VTMP@(2,USER,DATE,I)=Y
 .I VSORT="P" S @VTMP@(2,DFN,DATE,I)=Y
 .I VSORT="A" S @VTMP@(2,$P(ACT,U),DFN,DATE,I)=Y
 .I VSORT="R" S @VTMP@(2,IFN,DATE,I)=Y
 .Q
 W !!,$P($T(SORT+1),";",3),!,$P($T(SORT+2),";",3),!
 S Z=$NA(@VTMP@(2)),STOP=$E(Z,1,$L(Z)-1)_","
 F  S Z=$Q(@Z) Q:Z=""  Q:Z'[STOP  S X=@Z D
 .K Y F I=1:1:7 S Y(I)=$P(X,U,I)
 .S Y=$J(Y(1),7),$E(Y,13)=$TR($$FMTE^XLFDT(Y(2),"5Z"),"@"," ")
 .S $E(Y,34)=$J(Y(3),6),$E(Y,43)=Y(4),$E(Y,54)=$J(Y(5),7)
 .S $E(Y,64)=$J(Y(6),6)
 .W Y,!
 .Q
 K @VTMP
 Q
