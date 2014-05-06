VFDIPST1 ;DSS/LM - Post-install for vxVistA prescription processing ; 8/12/08 1:37pm
 ;;2009.2;DSS,INC VXVISTA OPEN SOURCE;;01 Dec 2009
 ;Copyright 1995-2009,Document Storage Systems Inc. All Rights Reserved
 ;
 Q
ORDSTUS(VFDPNMBR) ;;Add WRITTEN status to File 100.01 ORDER STATUS
 ;VFDPNMBR=Internal number of WRITTEN status entry, default=100.
 ;
 Q:$$FIND1^DIC(100.01,,"X","WRITTEN","B")  ;Entry exists
 S VFDPNMBR=$G(VFDPNMBR,100)
 N VFDPFDA,VFDPIENR,R
 S R=$NA(VFDPFDA(100.01,"+1,")),VFDPIENR(1)=VFDPNMBR
 S @R@(.01)="WRITTEN",@R@(.02)="wr",@R@(.1)="w"
 N XUMF S XUMF=1 ;Override Master File Server control on File 100.01
 D UPDATE^DIE(,"VFDPFDA","VFDPIENR") Q:'$G(VFDPIENR(1))
 ; Add description
 N VFDPWPR S VFDPWPR(1,0)="This status is used by vxVistA auto-finishing."
 D WP^DIE(100.01,VFDPIENR(1)_",",2,,"VFDPWPR")
 Q
NWPRSN ;;Add COMMERCIAL,PHARMACY entry to File 200 NEW PERSON
 ;
 Q:$$FIND1^DIC(200,,"X","COMMERCIAL,PHARMACY","B")  ;Entry exists
 N VFDPSVC S VFDPSVC=$$FIND1^DIC(49,,"X","PHARMACY","B")
 S:'VFDPSVC VFDPSVC=$$FIND1^DIC(49,,"X","IRM","B") ;Default if no PHARMACY
 Q:'VFDPSVC  N VFDPFDA,VFDPIENR,R S R=$NA(VFDPFDA(200,"+1,"))
 S @R@(.01)="COMMERCIAL,PHARMACY",@R@(1)="CPH",@R@(20.2)="PHARMACY COMMERCIAL"
 S @R@(29)=VFDPSVC,@R@(53.1)=1
 N DIC S (DIC,DIC(0))="" ;Anticipate LAYGO+1^XUA4A7
 D UPDATE^DIE(,"VFDPFDA","VFDPIENR") Q:'$G(VFDPIENR(1))
 ; Add KEY
 N VFDPKEY S VFDPKEY=$$FIND1^DIC(19.1,,"X","PSORPH","B") Q:'VFDPKEY
 S VFDPFDA(200.051,"?+1,"_VFDPIENR(1)_",",.01)=VFDPKEY
 D UPDATE^DIE(,"VFDPFDA")
 Q
MERGE  ;; Add merge routine to PACKAGE (#9.4) file.
 ;
 N FDA,RES,ERR,IEN,UPIEN 
 D FIND^DIC(9.4,,.01,"B","DSS,INC VXVISTA",,"B",,,"RES","ERR") Q:+RES("DILIST",0)=0  ;Entry does not exist
 S IEN=+$G(RES("DILIST",2,1)),ORIEN(1)=IEN_","
 ; add merge routine entry
 S FDA(9.402,"+2,"_IEN_",",.01)=2,FDA(9.402,"+2,"_IEN_",",3)="VFDMERU"
 S FDA(9.402,"+2,"_IEN_",",4)="S XDRZ=1"
 D UPDATE^DIE("E","FDA","UPIEN","ERR")
 U 0
 I $D(ERR) W !!,"Unable to add Package (#9.4) data."
 E  W !!,"Added Merge data to PACKAGE (#9.4) file."
 Q
 ;
