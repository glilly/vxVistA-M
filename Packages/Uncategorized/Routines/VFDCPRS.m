VFDCPRS ;DSS/LM - Miscellaneous vxCPRS support ;September 9, 2009
 ;;2011.1.2;DSS,INC VXVISTA OPEN SOURCE;;28 Jan 2013;Build 153
 ;Copyright 1995-2013,Document Storage Systems Inc. All Rights Reserved
 ;
 Q
VER(VFDRSLT,VFDCLVER) ;[RPC] VFD CPRS CLIENT VERSIONS
 ; VFDCLVER=[Required] Client version ID
 ; 
 ; Returns 1=TRUE (or YES) if and only if client version instance of
 ; parameter VFD CPRS CLIENT VERSIONS is valued 1=TRUE (or YES)
 ; 
 ; This RPC also sets application-wide variable ORWCLVER equal to
 ; the corresponding VA CPRS version ID, if the client version is
 ; supported.
 ;
 S VFDCLVER=$G(VFDCLVER)
 S VFDRSLT=+$$GET^XPAR("SYS","VFD CPRS CLIENT VERSIONS",VFDCLVER,"Q")
 S:VFDRSLT ORWCLVER=$P(VFDCLVER,".")_".0."_$P(VFDCLVER,".",2,3)
 Q
