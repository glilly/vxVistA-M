VFDPSUT1 ;DSS/WLC - Utilities supporting vxVistA prescription processing ;23 Nov 2010 10:04
 ;;2011.1.2;DSS,INC VXVISTA OPEN SOURCE;;28 Jan 2013;Build 148
 ;Copyright 1995-2013,Document Storage Systems Inc. All Rights Reserved
 ;
 ; ICR#  Supported Description
 ;-----  --------------------------------------------------
 ; 2051  $$FIND1^DIC
 ; 2056  ^DIQ: $$GET1, GETS
 ;10060  Fileman read of fields in file 200
 ;10056  Fileman read of fields in file 5
 ;10090  f
 ;10103  $$DT^XLFDT
 ; 3065  ^XLFNAME: $$STDNAME, $$NAMEFMT
 ;10104  $$UP^XLFSTR
 ; 2541  $$KSP^XUPARAM
 ;       Fileman read of all fields in files:
 ;10056      5
 ;10060    200
 ;10090      4
 ;       ----------  Unsupported Calls  ----------
 ;       Fileman read of files:  40.8, 44, 52, 52.41, 59, 100
 ;       Direct global read of ^PSRX
 ;       Direct global set of ^PSRX
 Q
 ;
ACCT(VFDP)  ; RPC:  VFD PSO ACCT INFO
 ; RPC to return address and phone information for NewCrop interface
 ;  INPUT:
 ;
 ;   NONE.
 ;
 ;  OUTPUT:
 ;
 ; VFDP, where:
 ;
 ;    VFDP(1)=Institution IEN
 ;    VFDP(2)=Institution Name
 ;    VFDP(3)=Institution Site ID
 ;    VFDP(4)=Institution Address Line 1
 ;    VFDP(5)=Institution Address Line 2
 ;    VFDP(6)=Institution City
 ;    VFDP(7)=Institution State
 ;    VFDP(8)=Institution Zip (base 5)
 ;    VFDP(9)=Institution Zip (ext 4)
 ;    VFDP(10)=Institution Country (default US)
 ;    VFDP(11)=Institution Primary phone
 ;    VFDP(12)=Institution Primary FAX
 ;
 N I,J,VFDINST,VFDFLDS
 S VFDFLDS=".01;.05;4.01;4.02;4.03;4.04;4.05;21612.01"
 S VFDINST=+$$SITE^VASITE I 'VFDINST S VFDP(1)="Site not found." Q
 D GETS^DIQ(4,VFDINST_",",VFDFLDS,"EI","INSTL") S VFDAIEN=INSTL(4,VFDINST_",",21612.01,"I")
 N VFDADR D GETS^DIQ(21612,VFDAIEN_",","*",,$NA(VFDADR))
 N VFDR S VFDR=$NA(VFDADR(21612,VFDAIEN_",")) D
 .S VFDP(1)=VFDINST
 .S VFDP(2)=INSTL(4,VFDINST_",",.01,"E")
 .S VFDP(3)=INSTL(4,VFDINST_",",.05,"E")
 .S VFDP(4)=INSTL(4,VFDINST_",",4.01,"E")
 .S VFDP(5)=INSTL(4,VFDINST_",",4.02,"E")
 .S VFDP(6)=INSTL(4,VFDINST_",",4.03,"E")
 .S VFDP(7)=INSTL(4,VFDINST_",",4.04,"E")
 .S VFDP(8)=$E(INSTL(4,VFDINST_",",4.05,"E"),1,5)
 .S VFDP(9)=$P(INSTL(4,VFDINST_",",4.05,"E"),"-",2)
 .S I=$$GET1^DIQ(21612,VFDAIEN_",",.117,"I"),VFDP(10)=$$GET1^DIQ(779.004,I_",",1.2)
 .S VFDP(11)=$$GET1^DIQ(21612,VFDAIEN_",",.131)
 .S VFDP(12)=$$GET1^DIQ(21612,VFDAIEN_",",.134)
 Q
 ;
VFDNCROP(VFDP,VFDLOC)  ; RPC:  VFD PSO NEWCROP LOC
 ; RPC to return address and phone information for NewCrop interface
 ;  INPUT:
 ;
 ;   VFDLOC:  Location IEN ^ VFDPROV: Provider IEN
 ;
 ;  OUTPUT:
 ;
 ; VFDP, where:
 ;
 ;    VFDP(1)=Location IEN
 ;    VFDP(2)=Location Name
 ;    VFDP(3)=Location Site ID
 ;    VFDP(4)=Location Address Line 1
 ;    VFDP(5)=Location Address Line 2
 ;    VFDP(6)=Location City
 ;    VFDP(7)=Location State
 ;    VFDP(8)=Location Zip (base 5)
 ;    VFDP(9)=Location Zip (ext 4)
 ;    VFDP(10)=Location Country (default US)
 ;    VFDP(11)=Provider Primary phone
 ;    VFDP(12)=Provider Alternate Phone #1
 ;    VFDP(13)=Provider Alternate Phone #2
 ;    VFDP(14)=Provider Primary FAX
 ;
 N I,J,VFDARR,VFDLC,VFDPRV,VFDAIEN,VFDDEFP,VFDINT
 S VFDLOC=$G(VFDLOC) I +VFDLOC=0 S VFDP(1)="-1^No location pointer sent." Q
 I +$P(VFDLOC,U,2)=0 S VFDP(1)="-1^No Provider IEN sent." Q
 S VFDLC=+VFDLOC,VFDPRV=$P(VFDLOC,U,2)
 I '$D(^VA(200,VFDPRV)) S VFDP(1)="-1^Provider IEN not found." Q
 S VFDINST=$$GET1^DIQ(44,VFDLC,3,"I") I 'VFDINST S VFDP(1)="No Institution file pointer in Location file." Q
 S VFDAIEN=$O(^VFD(21612,"D",VFDINST,"ERX",""))
 I 'VFDAIEN D  Q:+VFDP(1)<0
 . S VFDAIEN=$$GET1^DIQ(4,VFDINST,21612.01,"I") ;Rx VFD ADDRESS IEN
 . I 'VFDAIEN S VFDP(1)="-1^No RX PRINT ADDRESS defined." Q
 D GETS^DIQ(4,VFDINST_",",".01;.05","E","INSTL")
 N VFDADR D GETS^DIQ(21612,VFDAIEN_",","*",,$NA(VFDADR))
 N VFDR S VFDR=$NA(VFDADR(21612,VFDAIEN_",")) D
 .S VFDP(1)=VFDLC
 .S VFDP(2)=INSTL(4,VFDINST_",",.01,"E")
 .S VFDP(3)=INSTL(4,VFDINST_",",.05,"E")
 .S VFDP(4)=@VFDR@(.111)
 .S VFDP(5)=@VFDR@(.112)
 .S VFDP(6)=@VFDR@(.114)
 .S I=@VFDR@(.115),J=$O(^DIC(5,"B",I,0)),VFDP(7)=$$GET1^DIQ(5,J_",",1)
 .S VFDP(8)=$E(@VFDR@(.116),1,5)
 .S VFDP(9)=$P(@VFDR@(.116),"-",2)
 .S I=$$GET1^DIQ(21612,VFDAIEN_",",.117,"I"),VFDP(10)=$$GET1^DIQ(779.004,I_",",1.2)
 .S VFDP(11)=$$GET1^DIQ(200,VFDPRV_",",.132,"E")
 .S VFDP(12)=$$GET1^DIQ(200,VFDPRV_",",.133,"E")
 .S VFDP(13)=$$GET1^DIQ(200,VFDPRV_",",.134,"E")
 .S VFDP(14)=$$GET1^DIQ(200,VFDPRV_",",.136,"E")
 .S:@VFDR@(.131)]"" VFDP(11)=@VFDR@(.131)  ; override with default
 .S:@VFDR@(.132)]"" VFDP(12)=@VFDR@(.132)  ; override with default
 .S:@VFDR@(.133)]"" VFDP(13)=@VFDR@(.133)  ; override with default
 .S:@VFDR@(.134)]"" VFDP(14)=@VFDR@(.134)  ; override with default
 Q
