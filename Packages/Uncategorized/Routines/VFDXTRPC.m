VFDXTRPC ;DSS/LM - RPC Registration ; 8/14/2008
 ;;2009.2;DSS,INC VXVISTA OPEN SOURCE;;01 Dec 2009
 ;Copyright 1995-2009,Document Storage Systems Inc. All Rights Reserved
 ;
 ;  POST-INSTALL RPC Registration API
 ;  
 Q
 ;
 ;  API Usage Notes:
 ;  
 ;  A post-install routine that needs to register or unregister
 ;  one or more RPCs to/from a "B" (Broker) type option should
 ;  call this API as follows:
 ;  
 ;  DO EN^VFDXTRPC(<<"B" option name>>,<<RPCs to be [un]registered>>,<<action desired>>)
 ;  
 ;  The first parameter should have the full and exact name of the
 ;  "B" option, e.g. "VFD CPRS GUI CHART"
 ;  
 ;  The second parameter lists the RPCs to be added, merged or
 ;  deleted.  The format is either a list of names, by reference -
 ;  
 ;      VFDATA(1)="RPC one"
 ;      VFDATA(2)="RPC two"
 ;      
 ;  or an entry reference, e.g. VFDATA="ADD^MYRTN", where ADD
 ;  is a tag in routine MYRTN, followed by data in the form -
 ;  
 ;      ;;RPC one
 ;      ;;RPC two
 ;      ;;
 ;  
 ;  and ending in a null line or line that is null after ";;"
 ;  
 ;  Note that RPC names must also be complete and exact names.
 ;  Partial names and internal entry numbers are not accepted.
 ;  
 ;  The third (optional) parameter specifies the action to be taken,
 ;  either "M" for add/merge (the default) or "D" for delete.
 ;  
 ;
EN(VFDOPT,VFDATA,VFDOWHAT) ;[Public] Register or unregister RPCs
 ; VFDOPT=[Required] Existing "B" type OPTION name (File 19 field #.01)
 ; VFDATA=[Required] Either ENTRYREF for data =OR= List of RPCs
 ;                   subscripted (1), (2), (3), etc.
 ; VFDOWHAT=[Optional] M=Add/merge (default); D=Delete (remove).
 ; 
 ; Note that this API will *not* create a new "B" type option
 ; 
 I $L($G(VFDOPT)),$L($G(VFDATA))!($D(VFDATA)>1) S VFDOWHAT=$$UP^XLFSTR($G(VFDOWHAT,"M"))
 E  Q  ;Missing or invalid parameter
 N VFDOPTDA S VFDOPTDA=$$FIND1^DIC(19,,"X",VFDOPT,"B") ;Find option
 I VFDOPTDA,$$GET1^DIQ(19,VFDOPTDA,4,"I")="B" ;Verify Broker type
 E  Q  ;Option not found or invalid type
 Q:$L($G(VFDATA))&($D(VFDATA)>1)  ;Ambiguous (two lists)
 N VFDI,VFDX
 I $L($G(VFDATA)) F VFDI=1:1 D  Q:VFDX=""
 .S VFDX=$P($T(@($P(VFDATA,U)_"+"_VFDI_U_$P(VFDATA,U,2))),";;",2,99) Q:VFDX=""
 .S VFDATA(VFDI)=VFDX
 .Q
 D MERGE(VFDOPTDA,.VFDATA):VFDOWHAT="M",DEL(VFDOPTDA,.VFDATA):VFDOWHAT="D"
 Q
MERGE(VFDA,VFDATA) ;[Private] Add/merge RPCs to "B" OPTION
 ; VFDA=File 19 IEN
 ; VFDATA=List of RPCs names to merge
 ; 
 N VFDFDA,VFDI,VFDR S VFDR=$NA(VFDFDA(19.05))
 F VFDI=1:1 S VFDX=$G(VFDATA(VFDI)) Q:VFDX=""  D
 .S @VFDR@("?+"_VFDI_","_VFDA_",",.01)=$P(VFDX,U)
 .; RPC Key and M-Code rules are not presently supported here
 .Q
 D UPDATE^DIE("E",$NA(VFDFDA))
 Q
DEL(VFDA,VFDATA) ;[Private] Delete RPCs from "B" OPTION
 ; VFDA=File 19 IEN
 ; VFDATA=List of RPCs names to delete
 ;
 N DA,DIK,VFDI,VFDX
 S DA(1)=VFDA,DIK="^DIC(19,"_VFDA_",""RPC"","
 F VFDI=1:1 S VFDX=$G(VFDATA(VFDI)) Q:VFDX=""  D
 .S DA=$$FIND1^DIC(19.05,","_VFDA_",","X",$P(VFDX,U),"B") Q:'DA
 .D ^DIK
 .Q
 Q
