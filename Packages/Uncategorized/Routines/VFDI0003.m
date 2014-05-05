VFDI0003 ;DSS/SGM - VXVISTA 2010.1.1 ENV/PRE/POST ; 01/30/2013 18:50
 ;;2011.1.2;DSS,INC VXVISTA OPEN SOURCE;;28 Jan 2013;Build 153
 ;Copyright 1995-2013,Document Storage Systems Inc. All Rights Reserved
 ;
 ;~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~
 ;NOTE:
 ;  v2011.1.1 and v2012.0.1 expect to have the Build VFD VXVISTA UPDATE
 ;  PRE 2011.1.1 or 2012.0.1 installed first.  Since these Builds are
 ;  exported as part of a MULT build set, the PRE Build will be the
 ;  first Build to be installed.  The 2011.1.1/2012.0.1 expect the new
 ;  versions of those routines in the PRE Build.  Those PRE Build
 ;  routines are also included in the UPDATE Build definition.
 ;~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~
 ;
 ;This is the only routine that should be invoked from KIDS via the
 ;environmental routine field or the pre and post install routine
 ;fields in the KIDS BUILD file for vxVistA 2010.1.1 (or 2011.1.1)
 ;
 ;The environmental entry point is the first line of this routine.
 ;
 ;Any other routines needed in support of the install process will use
 ;the routine name format of VFDI0003x since we are allowing the
 ;use of up to 16 character routine names.
 ;
 ;ICR #  SUPPORTED DESCRIPTION
 ;-----  --------------------------------------------
 ; 2051  $$FIND1^DIC
 ; 2916  ^DDMOD: DELIX, DELIXN
 ;10013  ^DIK: DIK, ENALL, IXALL
 ;10075  Fileman READ of OPTION file fields: .01
 ;10096  All nodes in ^%ZOSF are useable
 ;10156  Exporting, deleting, updating OPTIONS via KIDS
 ;       Unsupported References
 ;       --------------------------------------------
 ;       Direct global read and killing of file 81.3
 ;       Routine save of %ZOSV routine
 ;       Delete of OPTIONs or OPTION Menu items
 ;---------------------------------------------------------------------
MIN ;;2010.1
MAX ;;2013.0
 ;---------------------------------------------------------------------
 ;   entry points for env,pre,post VFD VXVISTA UPDATE MULT 2011.1.x
MULTENV ; environmental check
 ; check for min/max vxvista version
 N MAX,MIN
 S MIN=$P($T(MIN),";",3),MAX=$P($T(MAX),";",3)
 I $T(VERCK^VFDI0000)="" S XPDABORT=1
 E  I $$VERCK^VFDI0000(,MIN,MAX,1)'>0 S XPDABORT=1
 Q
 ;
MULTPR ; pre-install
 K VFDMUDUZ M VFDMUDUZ=DUZ S DUZ(0)="@" Q
 ;
MULTPO ; post-install
 I $D(VFDMUDUZ) K DUZ M DUZ=VFDMUDUZ K VFDMUDUZ
 E  S DUZ(0)=""
 Q
 ;---------------------------------------------------------------------
 ;   entry points for pre,post VFD VXVISTA UPDATE 2011.1.x
PRE ; pre-install entry point
 N I,X,Y,Z
 S VFDINDEX=$D(^DD(21640.01,.02,1,1,0))
 D PRE1 ; 12/14/2012
 D PRE2
 D PRE3
 D PRE4
 D PRE5
 D PRE6
 D PRE7
 D PRE8 ; 4/10/2012
 Q
 ;
 ;---------------------------------------------------------------------
POST ; post-install entry point
 N X,Y,Z,DA,DATA,DIK,RTN
 D POST1
 D POST2
 D POST3
 D POST4
 D POST5
 D POST6
 D POST7 ; 1/27/2012
 D POST8 ; 6/26/2012
 D POST^VFDI00031 ; 9/21/2012
 Q
 ;
 ;-----------------------  PRIVATE SUBROUTINES  -----------------------
 ;-----  DELETE FM DD CROSS REFERENCES  -------
 ;   if no field# then new style index
 ;   if truth test evaluates to true do not delete the index
P1 ; dd#^field#^index#^index_name^flag_to_manually_reindex^<truth_test>
 ;;2^^^AVFDDOD
 ;;2^^^AVFDIDX
 ;;2^^^AVFDIDX1
 ;;2^.01^21600^AVFDPX
 ;;2^.01^21601^AVFDSSN
 ;;21631^.01^1^B^Y
 ;;21631^.01^4^C^^I $G(^DD(21631,.01,1,4,0))="21631^C^KWIC",$G(^("DT"))=3110602
 ;;21630.001^.05^1^AVFDHL
 ;;
PRE1 ; pre-install to delete previous indexes no longer supported
 ; PATIENT file changes: moved AVFDPX, AVFDSSN xrefs on .01 field from
 ;         traditional to a single new style index
 ; FORMAT of local array VFDIX(s1,s2,s3,s4)=v1~v2 where
 ;   s1=dd#   s2=index_name   s3=field#   s4=index_number
 ;   v1=1 if need to manually reindex
 ;   v2=truth test - M code which sets $T such that $T=1 means do no
 ;      delete index 
 ;
 N A,I,J,X,Y,Z,FLG,DAT,VFD,VFDIX
 F I=1:1 S X=$P($T(P1+I),";",3,999) Q:X=""  D
 . K DAT F J=1:1:5 S DAT(J)=$P(X,U,J)
 . S DAT(6)=$P(X,U,6,999)
 . Q:DAT(1)'>0  ;  file#
 . ; check for valid new style index
 . I 'DAT(2),DAT(4)=""!DAT(3)!'$O(^DD("IX","BB",DAT(1),DAT(4),0)) Q
 . ; chec for valid traditional index
 . I DAT(2) S Y=1 D  Q:'Y
 . . I DAT(3)'=+DAT(3)!(DAT(4)="") S Y=0 Q
 . . S X=$G(^DD(DAT(1),DAT(2),1,DAT(3),0))
 . . I X=""!($P(X,U,2)'=DAT(4)) S Y=0
 . . Q
 . S FLG=$S(DAT(5)="Y":1,1:DAT(5)=1)
 . I $L(DAT(6)) X DAT(6) I  Q
 . S VFDIX(DAT(1),+DAT(2),+DAT(3),DAT(4))=FLG
 . Q
 ;
 Q:'$D(VFDIX)
 ; delete index DDs
 N VFILE,VFLD,VFLG,VFDMSG,VIDX,VIDXNM
 S Z="VFDIX" F  S Z=$Q(@Z) Q:Z=""  D
 . S VFILE=$QS(Z,1),VFLD=$QS(Z,2),VIDX=$QS(Z,3),VIDXNM=$QS(Z,4),VFLG=@Z
 . N Z,VFD
 . S X=$S(VFLG:"K",1:"")
 . I VFLD D DDELIXT^VFDI0000(VFILE,VFLD,VIDX,VIDXNM,X,.VFD)
 . S J=0 F  S J=$O(VFD(J)) Q:'J  I VFD(J)?1" --- D".E D
 . . S VFD(J)=VFD(J)_" - index "_VIDXNM
 . . Q
 . I 'VFLD D DDELIXN^VFDI0000(VFILE,VIDXNM,X,.VFD)
 . S X=">>>> FileMan Cross Reference(s) which were deleted:"
 . I $D(VFD) D
 . . S I=$O(VFDMSG(" "),-1) I 'I S I=1,VFDMSG(1)=X
 . . S J=0 F  S J=$O(VFD(J)) Q:'J  S I=I+1,VFDMSG(I)=VFD(J)
 . . Q
 . ; manual reindex logic
 . I VFLG,VFILE=21631 S I=0 D
 . . F  S I=$O(^VFD(FILE,I)) Q:'I  S X=$P(^(I,0),U),^VFD(FILE,VIDXNM,X,I)=""
 . . Q
 . Q
 I $D(VFDMSG) D MSG^VFDI0000(.VFDMSG)
 Q
 ;
 ;-----  DELETE DD FIELDS  ------
P2 ; dd# ^ field# ^ field name ^ <if 1 then del only if names same>
 ;;9000010.06^.019^AFF.DISC.CODE from V PROVIDER file
 ;;9000010^.26^PFSS ACCOUNT REFERENCE^1
 ;;44^21600.01^BILLING DIVISION^1
 ;;
PRE2 ; delete field data dictionary definitions
 N I,X,Y,Z,DA,DIK,DEL,FILE,FLD,NM,VFD,VFDMSG
 F I=1:1 S X=$P($T(P2+I),";",3) Q:X=""  D
 . S FILE=+X,FLD=$P(X,U,2),NM=$P(X,U,3),DEL=$P(X,U,4)
 . Q:'FILE  Q:'FLD  Q:'$$FLDEXIST(FILE,FLD)
 . S NM(0)=$P(^DD(FILE,FLD,0),U)
 . I 'DEL,NM'=NM(0) Q
 . I DEL,NM=NM(0) Q
 . S VFD(FILE,FLD)=NM
 . Q
 S VFD(0)=1
 S VFDM(1)="The following field definitions have been deleted"
 S VFD="VFD(0)" F  S VFD=$Q(@VFD) Q:VFD=""  D
 . S FILE=$QS(VFD,1),FLD=$QS(VFD,2),NM=@VFD
 . S VFD(0)=1+VFD(0),VFDM(VFD(0))="   ["_FILE_","_FLD_"] "_NM
 . K DA,DIK S DA(1)=FILE,DA=FLD,DIK="^DD("_FILE_"," D ^DIK
 .Q
 I VFD(0)>1 D MSG^VFDI0000(.VFDM)
 Q
 ;
PRE3 ; check to see if correct data in file 21631
 N X,Y
 S Y=$G(^VFD(21631,0)) Q:Y=""  Q:$P(Y,U,4)>93
 S X=$P(Y,U,1,2)_U_U K ^VFD(21631) S ^VFD(21631,0)=X
 Q
 ;
PRE4 ; check to see if CPT MODIFIERS file needs cleaning up
 I $G(^DIC(81.3,0,"GL"))'="" D
 .I $D(^DIC(81.3,10)),$G(^DIC(81.3,10,0))="" D
 ..N X M X=^DIC(81.3,0) K ^DIC(81.3) M ^DIC(81.3,0)=X
 ..S ^(0)=$P(^DIC(81.3,0),U,1,2)
 ..Q
 .Q
 Q
 ;
 ;-----  ADD KIDS EXPORT FIELD (#21609.6) TO TOP LEVEL OF FILE  -----
P5 ; DD# ^ DD# ^ ...
 ;;101.24^142.1
 ;;
PRE5 ; add KIDS EXPORT field to various files
 N I,J,X,Y,Z,VFDF
 F I=1:1 S X=$P($T(P5+I),";",3) Q:X=""  D
 . F J=1:1:$L(X,U) S Y=$P(X,U,J) S:Y>0 VFDF(Y)=""
 . Q
 S I=0 F  S I=$O(VFDF(I)) Q:'I  S VFDF(I)=$$KEXPORT^VFDI0000(I)
 ; if messaging desired, do it here
 Q
 ;
 ;-----  REMOVE OPTIONS FROM A MENU  ------
 ;   if line does not have ^ then it contains name of menu option
 ;   if line has ^ then it contains <delete option>^<option name>
P6 ; 
 ;;VFD ARRA MAIN MENU
 ;;1^VFD ARRA EDUCATION 1 REPORT
 ;;1^VFD ARRA EDUCATION 2 REPORT
 ;;
PRE6 ; clean up some VFD ARRA options - 4/30/2011
 Q
 N I,J,X,Y,Z,VFD,VOPT
 ; vopt(menu name)=menu ien
 ; vopt(menu name,item name)=p1^p2^p3 where
 ; p1 = item ien    p2 = delete item completely flag
 ; p3 = 1:item del from menu 0:failed to del item from menu
 ;      "":nothing done     -1^message
 F I=1:1 S X=$P($T(P6+I),";",3) Q:X=""  D
 . I X'[U S VOPT="",Y=$$OPTLK^VFDI0000(X) S:Y VOPT(X)=Y,VOPT=X Q
 . Q:VOPT=""
 . S Y=$P(X,U),X=$P(Y,U,2),Z=$$OPTLK^VFDI0000(X) Q:'Z
 . S VOPT(VOPT,X)=Z_U_Y
 . ; delete item from menu
 . S $P(VOPT(VOPT,X),U,3)=$$OPTDEL^VFDI0000(VOPT,X)
 . Q
 Q
 ;
PRE7 ; delete file 19650 if it exists ; 1/20/2012
 D DELFILE^VFDI0000(19650)
 Q
 ;
PRE8 ; rename identifiers for files importing data
 N X,Y,Z,DIERR,VFD,VFDER,VFDF
 S Z(0)="Herbal/OTC/Non-VA Medication"
 S Z(1)="Meds/OTC from Elsewhere"
 S X=$G(^ORD(101.24,1555,0)),X(2)=$G(^(2))
 I $P(X,U)'="ORRPW PHARMACY NON-VA MEDS" Q
 I $P(X(2),U,3)'=Z(1) S VFD(101.24,"1555,",.23)=Z(1)
 I $P(X(2),U,4)'=Z(1) S VFD(101.24,"1555,",.24)=Z(1)
 I $D(VFD) D FILE^DIE(,"VFD","VFDER")
 Q
 ;
 ;---------------------------------------------------------------------
POST1 ;
 ; check to see if all inpat admits have corresponding VISITs and that
 ; there is an entry in the V HOSPITALIZATION file - T20
 Q:'$$TEST("VFDDGPM0","EN2")
 N X S X=+$P($$SITE^VASITE,U,3)
 ; 2011.1.1 T17 - do not run at Idaho
 Q:$E(X,1,3)=104
 D EN2^VFDDGPM0
 Q
 ;
POST2 ;
 ; the AGENCY CODE field (#9) in the Kernel System Parameters file
 ; (#8989.3) may be set to 0 (zero) instead of O.
 N X S X=$P(^XTV(8989.3,1,0),U,8) S:X=0 $P(^(0),U,8)="O" Q
 ;
POST3 ; 4/23/2011 - new indexes added - reindex if necessary
 Q:'$G(VFDINDEX)  K VFDINDEX
 N X S X=" " F  S X=$O(^VFD(21640.01,X)) Q:X=""  K ^(X)
 N D0,DA,DIK S DIK="^VFD(21640.01," D IXALL^DIK
 Q
 ;
POST4 ; first came with 2011.1.1 T45
 Q:'$O(^VFD(21631,0))
 N D0,DA,DIK S DIK="^VFD(21631,",DIK(1)=".01^C" D ENALL^DIK
 Q
 ;
POST5 ; clean up identifiers on the PATIENT file ; 5/20/2011
 N X F X=.301,391,1901,"AFJX NETWORK ID" K ^DD(2,0,"ID",X)
 Q
 ;
POST6 ; update the vxVistA Version Number Parameter
 N X,DATA,VER
 S VER=$P($T(VFDI0003+1),";",3)
 S DATA("VFD VXVISTA VERSION","SYS",1,1)=U_VER_"^CHG"
 D EN^VFDXTPAR(,"CHG",.DATA)
 Q
 ;
POST7 ; change HUMANITARIAN EMERGENCY to NOT APPLICABLE
 N I,X,Y,Z,VFDAT,VFDF
 S VFDAT(.01)="NOT APPLICABLE",VFDAT(5)="NOT APPLICABLE"
 F VFDF=8,8.1 I $P($G(^DIC(VFDF,8,0)),U)="HUMANITARIAN EMERGENCY" D
 . N DIERR,VFD,VFDER M VFD(VFDF,"8,")=VFDAT D FILE^DIE(,"VFD","VFDER")
 . Q
 Q
 ;
POST8 ;
 ; after the MARITAL STATUS file (#11) is imported, make sure zeroth
 ; node correct
 N I,J,X,Y,Z
 Q:$P($G(^DIC(11,0)),U,3)<21600
 S Y=$O(^DIC(11,21600),-1) I Y>0 S $P(^DIC(11,0),U,3)=Y
 Q
 ;
 ;---------------------------------------------------------------------
FLDEXIST(FILE,FLD) Q $$DDFIELD^VFDI0000($G(FILE),$G(FLD))
 ;
FIND1(FILE,VAL) ; find one entry in top level file
 ; returns ien OR 0 if no match OR -1 if error
 N I,J,X,Y,Z,DIERR,VFDER
 S X=$$FIND1^DIC(FILE,,"QX",VAL,"B",,"VFDER")
 I X=""!$D(DIERR) S X=-1
 Q X
 ;
TEST(R,T) Q $$RTNTEST^VFDI0000($G(R),$G(T))
 ;
T1 ;
 ;;>>>>>>>>>>  ERROR - ERROR - ERROR  <<<<<<<<<<
 ;;This expects a certain vxVistA system version
 ;;  Minimum vxVistA Version: 
 ;;  Maximum vxVistA Version: 
 ;;  Current System  Version: 
 ;;
 ;;VFD VXVISTA VERSION parameter not valued
 ;;
