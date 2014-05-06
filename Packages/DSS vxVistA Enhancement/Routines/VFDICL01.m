VFDICL01 ;DSS/LM - Core Clinical Pre/Post-Install ; 7/14/2008
 ;;2009.2;DSS,INC VXVISTA OPEN SOURCE;;01 Dec 2009
 ;Copyright 1995-2009,Document Storage Systems Inc. All Rights Reserved
 ;
 ;** Standard vxVistA pre- and post- install routine **
 ;  Include in build, whether or not code is present.
 ;
ENV ;Environment check
 N VFDNIEN
 S VFDNIEN=$O(^XPD(9.7,"B","VFDCORE-OS 0001 CPRS 2008.1",""),-1) ;vxCPRS menu context
 I 'VFDNIEN D MES^XPDUTL("This build requires VFDCORE-OS 0001 CPRS 2008.1") S XPDQUIT=1 Q
 I '($$GET1^DIQ(9.7,VFDNIEN,.02,"I")=3) D  S XPDQUIT=1 Q
 .D MES^XPDUTL("VFDCORE-OS 0001 CPRS 2008.1 install was not completed.")
 .Q
 Q
PRE ;
 Q
POST ;
 D EN^VFDVOHXX,EN1^VFDIPST,EN^VFDIHDI
 Q
