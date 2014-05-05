SISREGU ;SIS/LM - Non-VA Registration Utilities
 ;;1.0;NON-VA REGISTRATION;;;Build 15
 ;Copyright 2008 - 2009, Sea Island Systems, Inc.  Rights are granted as follows:
 ;Sea Island Systems, Inc. conveys this modified VistA routine to the PUBLIC DOMAIN.
 ;This software comes with NO warranty whatsoever.  Sea Island Systems, Inc. will NOT be
 ;liable for any damages that may result from either the use or misuse of this software.
 ;
 Q
STUFFID ;Stuff values for veteran-specific required identifiers
 I $G(DPTID)=391 D  Q
 .N SISPBTYP S SISPBTYP=$$FIND1^DIC(391,,"X","NON-VETERAN (OTHER)","B")
 .Q:'SISPBTYP  S DPT("DR")=DPT("DR")_"///"_SISPBTYP
 .Q
 I $G(DPTID)=.301!($G(DPTID)=1901) S DPT("DR")=DPT("DR")_"///N"
DISP ;From ^DGREG - Registration date/time (DISPOSITION LOG... multiple)
 ; Substitute for call to ^DIC in REG^DGREG
 ; Hard-set subfields 2, 2.1 and 13 in #2.101
 ; 
 I $G(DA(1))>0,$G(X)>0,$G(DINUM) N SISFDA,SISIENR,SISIENS,SISR
 E  Q  ;Invalid context
 S SISIENS="?+1,"_DA(1)_",",SISR=$NA(SISFDA(2.101,SISIENS)),SISIENR(1)=DINUM
 S @SISR@(.01)=X,@SISR@(2)=3,@SISR@(2.1)=5,@SISR@(13)=8
 D UPDATE^DIE(,$NA(SISFDA),$NA(SISIENR))
 Q
PRE ;From ^SISREG and ^SISSDM
 ; Edit non-VA fields before common fields
 ;
 N SISDR S SISDR=$$GET^XPAR("SYS","SIS REG PRE INPUT TEMPLATE")
 S:SISDR="" SISDR="SIS DGREG PRE"
 Q:'$$FIND1^DIC(.402,,"X",SISDR,"B")
 Q:'$G(DFN)  N DA,DIE,DR
 S DA=DFN,DIE="^DPT(",DR="["_SISDR_"]",DIE("NO")="BACKOUTOK"
 D ^DIE
 Q
POST ;From ^DGREG
 ; Edit non-VA fields not edited in PRE group
 ;
 N SISDR S SISDR=$$GET^XPAR("SYS","SIS REG POST INPUT TEMPLATE")
 S:SISDR="" SISDR="SIS DGREG POST"
 Q:'$$FIND1^DIC(.402,,"X",SISDR,"B")
 Q:'$G(DFN)  N DA,DIE,DR W !
 S DA=DFN,DIE="^DPT(",DR="["_SISDR_"]",DIE("NO")="BACKOUTOK"
 D ^DIE
 Q
