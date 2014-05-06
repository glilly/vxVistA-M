VFDPXPE1 ;CFS - Main Routine for Data Capture ;05/26/2013
 ;;2011.1.3;DSS,INC VXVISTA OPEN SOURCE;**1**;08 Aug 2013
 ;Copyright 1995-2013,Document Storage Systems Inc. All Rights Reserved
 ;+This routine is responsible for:
 ;+ - creating new entries in PCE files,
 ;+ - processing modifications to existing entries,
 ;+ - deleting entries,
 ;+ - ensuring all required variables are present,
 ;+ - setting both Audit fields (EDITED FLAG and AUDIT TRAIL),
 ;+ - checking for duplicate entries,
 ;+ - some error reporting.
 ;+
 ;+LOCAL VARIABLE LIST
 ;+ MOST VARIABLES ARE DEFINED AT THE TOP OF  PXKMAIN
 ;+ PXKSEQ   = Sequence number in PXK tmp global
 ;+ PXKCAT   = Category of entry (CPT,MSR,VST...)
 ;+ PXKREF   = Root of temp global
 ;+ PXKPIEN  = IEN of v file
 ;+ PXKAUDIT = data located in the audit field of the v file
 ;+ PXKER    = field data use to build the dr string (eg .04///^S X=$G()
 ;+ PXKFLD   = field number gleened from the file routines
 ;+ PXKNOD   = same as the subscript in a global node
 ;+ PXKPCE   = the piece where the data is found on that node
 ;
 ;
 W !,"This is not an entry point" Q
LOOP(PXKAV,PXKBV) ;+Copy delimited strings into sub-arrays.
 F PXKI=1:1:$L(PXKAFT(PXKSUB),"^") I $P(PXKAFT(PXKSUB),"^",PXKI)'="" S PXKAV(PXKSUB,PXKI)=$P(PXKAFT(PXKSUB),"^",PXKI)
 F PXKI=1:1:$L(PXKBEF(PXKSUB),"^") I $P(PXKBEF(PXKSUB),"^",PXKI)'="" S PXKBV(PXKSUB,PXKI)=$P(PXKBEF(PXKSUB),"^",PXKI)
 K PXKI,PXKJ
 Q
 ;
ERROR(PXKAV,PXKERROR) ;+Check for missing required fields
 Q:$G(PXKAV(0,1))["@"!('$D(PXKAV(0,1)))
 N PXJ,PXJJ,PXKER,PXKFLD,PXKNOD,PXKPCE
 S PXKNOD=0,PXKPCE=0
 D EN1^@PXKRTN
 S PXKER=$P(PXKER," * ",1)
 I PXKER="" Q
 F PXJ=1:1:$L(PXKER,",") D
 . S PXJJ=$P(PXKER,",",PXJ)
 . I '$D(PXKAV(PXKNOD,PXJJ)) D
 . . S PXKPCE=PXJJ
 . . D EN2^@PXKRTN
 . . S PXKFLD=$P(PXKFD,"/",1)
 . . S:PXKFLD["*" PXKFLD=$P(PXKFLD," * ",2)
 . . S PXKERROR(PXKCAT,PXKSEQ,0,PXKFLD)="Missing Required Fields"
 Q
 ;
CLEAN(PXKAV,PXKBV) ;
 ;Clean out the PXKAV array by comparing
 ;PXKBV (before change array) with PXKAV (after change array)
 ;so that only modified data in the PXKAV array will be updated
 ;when ^DIE is called.
 S PXKJ=""
 F  S PXKJ=$O(PXKBV(PXKJ)) Q:PXKJ=""  D
 . S PXKI=""
 . F  S PXKI=$O(PXKBV(PXKJ,PXKI)) Q:PXKI=""  D
 . . I $G(PXKBV(PXKJ,PXKI))=$G(PXKAV(PXKJ,PXKI)) K PXKAV(PXKJ,PXKI)
 K PXKI,PXKJ ; Not sure about NEW here.
 Q
 ;
FILE(PXKSORR,PXKPIEN,PXKAV) ;+Create a new entry in file.
 ;+This is the code that adds new entries to V-files.
 ;
 K DD,DO
 N PXKAUDIT
 S PXKAUDIT=""
 S DIC=$P($T(GLOBAL^@PXKRTN),";;",2)
 S DIC(0)="",DIC("DR")="",DR=""
 S PXKNOD=""
 F  S PXKNOD=$O(PXKAV(PXKNOD)) Q:PXKNOD=""  D
 . S PXKPCE=$S(PXKNOD=0:1,1:0)
 . F  S PXKPCE=$O(PXKAV(PXKNOD,PXKPCE)) Q:PXKPCE=""  D
 ..D EN1^@PXKRTN
 ..I $G(PXKER)'="" D
 ...I PXKER["~" D
 ....I $P(PXKER,"~",2)["A" S PXKER=$P(PXKER,"~") Q
 ....I $P(PXKER,"~",2)'["A" S PXKER="" Q
 ...I +PXKER=0 D
 ....I PXKAV(PXKNOD,PXKPCE)=+PXKAV(PXKNOD,PXKPCE) S PXKER=$P(PXKER," * ",2)
 ....I PXKAV(PXKNOD,PXKPCE)'=+PXKAV(PXKNOD,PXKPCE) S PXKER=$P(PXKER," * ",3),PXKPTR(PXKPIEN,PXKNOD,PXKPCE)=""
 ..I $G(PXKER)'="" S DR=DR_PXKER_"PXKAV("_PXKNOD_","_PXKPCE_"));"
 S X=$G(PXKAV(0,1))
 D AUD2(.DR,.PXKAUDIT,PXKSORR)
 S DIC("DR")=DR
 D FILE^DICN
 S PXKPIEN=+Y
 S DR=""
 K DIC,Y,X
 Q
 ;
DRDIE(PXKSORR,PXKAV) ;--Set the DR string and DO DIE during Edit phase.
 ;PXKSORR = Source information for the 801 node.
 N PXKAUDIT,PXKER,PXKLR,PXKNOD,PXKPCE
 S (PXKAUDIT,DR)=""
 D AUD12(.DR,.PXKAUDIT,PXKSORR)
 S DIE=$P($T(GLOBAL^@PXKRTN),";;",2) K PXKPTR
 S PXKLR=$P($T(GLOBAL^@PXKRTN),";;",2)_"DA)"
 S PXKNOD=""
 F  S PXKNOD=$O(PXKAV(PXKNOD)) Q:PXKNOD=""  D
 . S PXKPCE=0
 . F  S PXKPCE=$O(PXKAV(PXKNOD,PXKPCE)) Q:PXKPCE=""  D
 ..D EN1^@PXKRTN
 ..I $G(PXKER)'="" D
 ...I PXKER["~" D
 ....I $P(PXKER,"~",2)["E",PXKFGED=1 S PXKER=$P(PXKER,"~") Q
 ....I $P(PXKER,"~",2)'["E",PXKFGED=1 S PXKER="" Q
 ...I +PXKER=0 D
 ....I PXKAV(PXKNOD,PXKPCE)=+PXKAV(PXKNOD,PXKPCE) S PXKER=$P(PXKER," * ",2)
 ....I PXKAV(PXKNOD,PXKPCE)'=+PXKAV(PXKNOD,PXKPCE) S PXKER=$P(PXKER," * ",3),PXKPTR(PXKPIEN,PXKNOD,PXKPCE)=""
 ..I $G(PXKER)'="" S DR=DR_PXKER_"PXKAV("_PXKNOD_","_PXKPCE_"));"
 ..I $L(DR)>200 D DIE(.DR)
 D DIE(.DR)
 K DIE,PXKLR,DIC(0)
 D ER
 Q
 ;
DELETE(PXKPIEN) ;+Use FM ^DIK call to delete entry identified by PXKPIEN.
 S DA=PXKPIEN
 S DIK=$P($T(GLOBAL^@PXKRTN),";;",2)
 D ^DIK
 K DIK
 S DA=""
 Q
 ;
AUD12(DR,PXKAUDIT,PXKSORR) ;--Set both audit fields done during the Edit phase.
 S PXKAUDIT=$P($T(GLOBAL^@PXKRTN),";;",2)_"DA,801)"
 S PXKAUDIT=$P($G(@PXKAUDIT),"^",2)_PXKSORR_";"
 I $L(PXKAUDIT,";")>5 S $P(PXKAUDIT,";",2,$L(PXKAUDIT,";"))="+;"_$P(PXKAUDIT,";",4,$L(PXKAUDIT,";")) ;PX*1*124   Change 8 to 5
 S PXKNOD=801
 F PXKPCE=1,2 D EN1^@PXKRTN S DR=DR_PXKER
 S PXKFVDLM=""
 Q
 ;
AUD2(DR,PXKAUDIT,PXKSORR) ;--Set second audit fields done during the Add phase.
 S PXKAUDIT=PXKSORR_";"
 S PXKNOD=801
 S PXKPCE=2
 D EN1^@PXKRTN
 S DR=DR_PXKER
 S PXKFVDLM=""
 Q
 ;
DIE(DR) ;+Lock global and invoke FM ^DIE call.
 L +@PXKLR:10
 D ^DIE
 L -@PXKLR
 K DR
 S DR=""
 Q
 ;
DUP(PXFG) ;+Code to check for duplicates
 N GBL,PX,PXJ,PXJJ,PXJJJ,PXKER,PXKNOD,PXKPCE,PXKRTN,PXKVRTN
 I '$D(PXKPIEN) N PXKPIEN S PXKPIEN=""
 S PXKNOD=0
 S PXKPCE=0
 S PXKRTN="VFDPX"_$E(PXKVCAT,6,8)
 S PXKVRTN=$P($T(GLOBAL^@PXKRTN),";;",2)
 S GBL=PXKVRTN_"""AD"""_","_PXKVST_")"
 S PXJJJ=0
 D EN1^@PXKRTN
 I $P(PXKER," * ",3)'=0 D
 .S PXKER=$P(PXKER," * ",2)
 .I PXKER="" Q
 .S (PX,PXFG)=0
 . F  S PX=$O(@GBL@(PX)) Q:PX=""  D  Q:PXFG=1
 ..S PXJJJ=0
 ..F PXJ=1:1:$L(PXKER,",") S PXJJ=$P(PXKER,",",PXJ) D
 ...I $P($G(@GBL@(PX,$P(PXJJ,"+",1))),"^",$P(PXJJ,"+",2))=$G(PXKAV($P(PXJJ,"+",1),$P(PXJJ,"+",2))),PX'=PXKPIEN S PXJJJ=PXJJJ+1
 ..I $L(PXKER,",")=PXJJJ S PXFG=1
 Q
 ;
ER ;--PXKERROR MAKING IF NOT POPULATED CORRECTLY
 N PXKRT,PXKMOD,PXKSTR
 S PXKMOD=PXKSEQ#1 I $G(PXKMOD) Q
 S PXKN=""
 F  S PXKN=$O(PXKAV(PXKN)) Q:PXKN=""  D
 . S PXKP=""
 . F  S PXKP=$O(PXKAV(PXKN,PXKP)) Q:PXKP=""  D
 .. S PXKRRT=$P($T(GLOBAL^@PXKRTN),";;",2)_DA_","
 .. S PXKRRT=PXKRRT_PXKN_")"
 .. I PXKAV(PXKN,PXKP)'=$P($G(@PXKRRT),"^",$S(PXKN=1:1,1:PXKP)) D
 ... Q:PXKAV(PXKN,PXKP)["@"
 ... S PXKNOD=PXKN,PXKPCE=PXKP
 ... I PXKNOD=1,PXKCAT="CPT" S PXKPCE=1
 ... D EN2^@PXKRTN
 ... S PXKFLD=$P(PXKFD,"/",1)
 ... S:PXKFLD["*" PXKFLD=$P(PXKFLD," * ",2)
 ... Q:PXKFLD=1101
 ... S PXKSTR="Not Stored = "_PXKAV(PXKN,PXKP)
 ... I $G(PXKERROR(PXKCAT,PXKSEQ,DA,PXKFLD))]"" D
 .... S PXKSTR=PXKERROR(PXKCAT,PXKSEQ,DA,PXKFLD)_","_PXKAV(PXKN,PXKP)
 ... S PXKERROR(PXKCAT,PXKSEQ,DA,PXKFLD)=PXKSTR
 Q
