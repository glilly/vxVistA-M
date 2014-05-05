VFDGMRO ;DSS/LM - vxVistA Vitals RPCs ;February 9, 2010
 ;;2011.1.2;DSS,INC VXVISTA OPEN SOURCE;;28 Jan 2013;Build 153
 ;Copyright 1995-2013,Document Storage Systems Inc. All Rights Reserved
 ;
 Q
EN ;[Public] - From option VFD ADD VITAL TYPE
 ; Create new GMRV VITAL TYPE entry, with associated data
 ; 
 N DIR,DIRUT,VFDABR,VFDCAT,VFDCIEN,VFDI,VFDNAM,VFDERR,VFDQUAL,VFDY,X,Y
 S DIR(0)="F^1:50",DIR("A")="Enter VITAL TYPE name, NOT abbreviation"
 D ^DIR Q:$D(DIRUT)  S VFDNAM=Y
 I $$FIND1^DIC(120.51,,"X",VFDNAM,"B")>0 D  Q
 .W !,"Error: Vital type "_VFDNAM_" already exists."
 .Q
 S DIR(0)="F^1:5",DIR("A")="Enter abbreviation (1-5 characters)"
 D ^DIR Q:$D(DIRUT)  S VFDABR=Y
 S DIR(0)="F^2:40",DIR("A")="Enter VITAL CATEGORY for "_VFDNAM
 D ^DIR Q:$D(DIRUT)  S VFDCAT=Y
 S VFDY=$$FIND1^DIC(120.53,,"X",VFDCAT,"B") ;Lookup category
 I 'VFDY I '$$YN("Are you adding a new category "_VFDCAT) D  Q
 .W !,"Please examine existing entries in the GMRV VITAL CATEGORY file and restart."
 .Q
 W !,"Qualifiers:"
 S VFDCIEN=+VFDY F VFDI=1:1 Q:$D(DIRUT)  D
 .S DIR(0)="F^2:50",DIR("A")="Enter VITAL QUALIFIER ("_VFDI_") for "_VFDNAM_" '^' to quit"
 .D ^DIR Q:$D(DIRUT)  S:Y]"" VFDQUAL(VFDI)=Y
 .Q
 W !!,"Thank you!  Vital type "_VFDNAM_" will be created.  Abbreviation: "_VFDABR
 S VFDERR=0 F VFDI=1:1 Q:'VFDQUAL(VFDI)!VFDERR  D
 .Q:$$FIND1^DIC(120.52,,"X",VFDQUAL(VFDI),"B")>0
 .W !,"Qualifier "_VFDQUAL(VFDI)_" will be added to the VITAL QUALIFIER file."
 .S DIR(0)="F^1:3",DIR("A")="Enter SYNONYM for QUALIFIER "_VFDQUAL(VFDI)
 .D ^DIR I DIRUT S VFDERR=1 Q
 .S VFDQUAL(VFDI)=VFDQUAL(VFDI)_U_Y
 .Q
 Q:VFDERR
 I $$FIND1^DIC(120.53,,"X",VFDCAT,"B")>0 D
 .W !,"Existing category "_VFDCAT_" will be used."
 .Q
 E  D
 .W !,"New VITAL CATEGORY "_VFDCAT_" will be created."
 .Q
 W !
 S DIR(0)="Y",DIR("A")="Entries will be created now.  Are you sure"
 D ^DIR Q:$D(DIRUT)  Q:'(Y=1)
 ; Create file entries
 N VFDFDA,VFDIENR,VFDMSG,VFDQIEN,VFDR,VFDUID,XUMF
 ; GMRV VITAL TYPE (stub)
 S VFDR=$NA(VFDFDA(120.51,"+1,")),XUMF=1
 S @VFDR@(.01)=VFDNAM,@VFDR@(1)=VFDABR
 S VFDUID=$$UID W !!,"UID="_VFDUID
 S @VFDR@(99.98)=1,@VFDR@(99.99)=VFDUID
 D UPDATE^DIE(,$NA(VFDFDA),$NA(VFDIENR),$NA(VFDMSG))
 I $D(VFDMSG) D
 .W !!,"Error: UPDATE~DIE returned an error." S VFDERR=1
 .W !,$G(VFDMSG("DIERR",1,"TEXT",1))
 .Q
 I '$G(VFDIENR(1)) W !!,"VITAL TYPE "_VFDNAM_" failed." S VFDERR=1
 Q:VFDERR  S VFDVT=VFDIENR(1)
 D 99(120.51,VFDVT) ;99.991 multiple
 ; End GMRV VITAL TYPE (stub)
 I 'VFDCIEN D  ;GMRV VITAL CATEGORY
 .K VFDFDA S VFDR=$NA(VFDFDA(120.53,"+1,"))
 .S @VFDR@(.01)=VFDCAT,@VFDR@(99.98)=1,@VFDR@(99.99)=VFDUID
 .D UPDATE^DIE(,$NA(VFDFDA),$NA(VFDIENR),$NA(VFDMSG))
 .S VFDCIEN=$G(VFDIENR(1))
 .Q
 I 'VFDCIEN D  Q
 .W !!,"Error: VITAL CATEGORY "_VFDCAT_" was not found and could not be added."
 .Q
 I $$FIND1^DIC(120.531,","_VFDCIEN_",","X",VFDNAM,"B")>0
 E  D
 .K VFDFDA S VFDR=$NA(VFDFDA(120.531,"+1,"_VFDCIEN_","))
 .S @VFDR@(.01)=VFDVT ;CATEGORY->VITAL TYPE
 .D UPDATE^DIE(,$NA(VFDFDA),$NA(VFDIENR),$NA(VFDMSG))
 .I '$G(VFDIENR(1)) W !!,"Error: VITAL CATEGORY : VITAL TYPE failed to file."
 .Q
 ; End GMRV VITAL CATEGORY
 ;
 ; Begin GMRV VITAL QUALIFIER
 F VFDI=1:1 Q:'$D(VFDQUAL(VFDI))!VFDERR  D
 .Q:$$FIND1^DIC(120.52,,"X",$P(VFDQUAL(VFDI),U),"B")>0
 .K VFDFDA S VFDR=$NA(VFDFDA(120.52,"+"_VFDI_","))
 .S @VFDR@(.01)=$P(VFDQUAL(VFDI),U),@VFDR@(.02)=$P(VFDQUAL(VFDI),U,2)
 .S @VFDR@(99.98)=1,@VFDR@(99.99)=VFDUID
 .D UPDATE^DIE(,$NA(VFDFDA),$NA(VFDIENR),$NA(VFDMSG))
 .I '$G(VFDIENR(VFDI)) D  S VFDERR=1 Q
 ..W !!,"Error: VITAL QUALIFIER "_$P(VFDQUAL(VFDI),U)_" was not filed."
 ..Q
 .S VFDQIEN=VFDIENR(VFDI) D 99(120.52,VFDQIEN) ;99.991 multiple
 .K VFDFDA S VFDR=$NA(VFDFDA(120.521,"+1,"_VFDQIEN_","))
 .S @VFDR@(.01)=VFDVT,@VFDR@(.02)=VFDCIEN
 .D UPDATE^DIE(,$NA(VFDFDA),$NA(VFDIENR),$NA(VFDMSG))
 .I '$G(VFDIENR(1)) D  S VFDERR=1 Q
 ..W !!,"Error: VITAL QUALIFIER "_$P(VFDQUAL(VFDI),U)_" : "_VFDNAM_" failed to file."
 ..Q
 .Q
 Q:VFDERR
 F VFDI=1:1 Q:'$D(VFDQUAL(VFDI))!VFDERR  D
 .S VFDQIEN=$$FIND1^DIC(120.52,,"X",$P(VFDQUAL(VFDI),U),"B") Q:'(VFDQIEN>0)
 .K VFDFDA S VFDR=$NA(VFDFDA(120.521,"+1,"_VFDQIEN_","))
 .S @VFDR@(.01)=VFDVT,@VFDR@(.02)=VFDCIEN
 .D UPDATE^DIE(,$NA(VFDFDA),$NA(VFDIENR),$NA(VFDMSG))
 .I '$G(VFDIENR(1)) D  S VFDERR=1 Q
 ..W !!,"Error: VITAL QUALIFIER "_$P(VFDQUAL(VFDI),U)_" : "_VFDNAM_" failed to file."
 ..Q
 .Q
 ; End GMRV VITAL QUALIFIER
 ;
 ; GMRV VITAL TYPE - Complete entry
 N VFDRATE,VFDRIN,VFDRHLP,VFDPCE
 I $$YN("Does vital type "_VFDNAM_" have an associated RATE")=1 S VFDRATE=1
 S (VFDRIN,VFDRHLP)="" I VFDRATE=1 D
 .; Do not ask RATE INPUT TRANSFORM here (M code requires programmer)
 .S DIR(0)="F^3:30",DIR("A")="Enter RATE HELP"
 .D ^DIR Q:$D(DIRUT)  S VFDHLP=$G(Y)
 .Q
 S DIR(0)="F^1:10",DIR("A")="Enter PCE ABBREVIATION for "_VFDNAM
 D ^DIR Q:$D(DIRUT)  S VFDPCE=$G(Y)
 K VFDFDA S VFDR=$NA(VFDFDA(120.51,VFDVT_","))
 S @VFDR@(3)=VFDRATE
 S:VFDRATE @VFDR@(4)="S X=X" ;Placeholder for RATE INPUT TRANSFORM
 S:VFDHLP]"" @VFDR@(5)=VFDHLP
 S:VFDPCE]"" @VFDR@(7)=VFDPCE
 D FILE^DIE(,$NA(VFDFDA),$NA(VFDMSG))
 W !!,VFDNAM_" filed."
 I $D(VFDMSG) W !,"Some data not filed.. "_$G(VFDMSG("DIERR",1,"TEXT",1))
 ; End GMRV VITAL TYPE
 Q
UID() ;[Private] - Next UID
 ;
 N X,Y S Y=$O(^GMRD(120.51,"AVUID",""),-1) S:Y<21600000 Y=216000000
 S X=$O(^GMRD(120.52,"AVUID",""),-1) S:Y<X Y=X
 S X=$O(^GMRD(120.53,"AVUID",""),-1) S:Y<X Y=X
 Q Y+1
 ;
YN(VFDPRMPT) ;Present prompt and return '1' if and only if reply is YES
 ;
 N DIR,X,Y
 S DIR(0)="Y",DIR("A")=$G(VFDPRMPT) D ^DIR Q:$D(DIRUT) ""
 Q Y
99(VFDFILE,VFDIEN) ;Add 99.991 multiple
 ;
 I U_120.51_U_120.52_U_120.53_U[(U_VFDFILE_U),VFDIEN>0 N VFDFDA,VFDR
 E  Q
 S VFDR=$NA(VFDFDA(VFDFILE_99,"+1,"_VFDIEN_","))
 S @VFDR@(.01)=$$NOW^XLFDT,@VFDR@(.02)=1
 D UPDATE^DIE(,$NA(VFDFDA))
 Q
