VFDIPSS9 ;DSS/WLC - Pre/Post-installation routine for NewCrop KID Build ;23 Nov 2010 10:04
 ;;2011.1.2;VENDOR - DOCUMENT STORAGE SYS;;02 Oct 2013;Build 4
 ;Copyright 1995-2013,Document Storage Systems Inc. All Rights Reserved
 ;
POST  ; post-installation routine
 ; create order dialog for routing
 S EN=$$FIND1^DIC(101.41,,"X","VFD PSO ROUTING") G:EN>1 POST5
 D BMES^XPDUTL("O.K. LET'S MAKE an Order Dialog: ")
 K VFDFDA
 K DD,DO S DIC="^ORD(101.41,",DIC(0)="L",X="VFD PSO ROUTING" D FILE^DICN G:+Y<1 POST5
 S DA=+Y_"," W X
 S VFDFDA(101.41,DA,2)="VFD PSO Routing"
 S VFDFDA(101.41,DA,4)="prompt"
 S VFDFDA(101.41,DA,7)="ORDER ENTRY/RESULTS REPORTING"
 S VFDFDA(101.41,DA,11)="set of codes"
 S VFDFDA(101.41,DA,12)="E:ePHARMACY;I:IN-HOUSE;P:PRINTED SCRIPT;C:ADMINISTERED IN CLINIC"
 ;EXTERNAL FORMAT VALUES USE FLAG
 D FILE^DIE("E","VFDFDA") 
 ;
POST5 ;
 S IEN10141=$O(^ORD(101.41,"B","OR GTX ROUTING","")) I IEN10141'="" D
 . S X=$P($G(^ORD(101.41,IEN10141,1)),U,2) I X'["I:IN-HOUSE" D 
 . . S:$E(X,$L(X))=";" X=$E(X,1,$L(X)-1)
 . . S $P(X,";",$L(X,";")+1)="I:IN-HOUSE"
 . . K VFDFDA S VFDFDA(101.41,IEN10141_",",11)="set of codes"
 . . S VFDFDA(101.41,IEN10141_",",12)=X
 . . D FILE^DIE("E","VFDFDA") 
 . . D BMES^XPDUTL("Order Dialog OR GTX ROUTING has been updated to "_X)
 D BMES^XPDUTL("...done")
 Q
 ;
