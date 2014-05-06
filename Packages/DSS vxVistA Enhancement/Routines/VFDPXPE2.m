VFDPXPE2 ;CFS - Special Routine ;05/22/2103
 ;;2011.1.3;DSS,INC VXVISTA OPEN SOURCE;**1**;08 Aug 2013
 ;Copyright 1995-2013,Document Storage Systems Inc. All Rights Reserved
 ;  VARIABLES
 ; See variables lists under each line tag
 ;
 ;
SPEC ;Populate other v files
 ;  VARIABLES
 ; PXKAV(0)  = The AFTER variables created in VFDPXE0
 ; PXKBV(0)  = The BEFORE variables created in VFDPXE0
 ; PXKFG(ED,DE,AD) =The EDIT,DELETE,ADD flags
 ; PXKCAT    = The category being $o through in VFDPXE0
 ; PXKIN     = The pointer value of first piece in the mapping file
 ; PXKPXD    = An array with all the entries to be mapped this go around
 ; PXKDIEN   = IEN of the coding file
 ;
 ;******************BEGIN NOTE*****************************
 ;If any vxVistA tabs need to have any mapping done in
 ;^PXD(811.1, more vxVistA coding will need to be done.
 ;See routine BEFORE^PXKMAIN at the line:
 ;I $D(^TMP("PXKSAVE",$J)) D RECALL^PXKMAIN2
 ;for examples on how to code.
 ;******************END NOTE*******************************
 ;
 N PXKDONE
 S PXKDONE=0
 Q:PXKFGED=1
 I (PXKFGAD=1) D
 .I $D(^PXD(811.1,"AA",PXKAV(0,1),""_PXKCAT_"",1)) D
 ..S PXKDONE=$O(^PXD(811.1,"AA",PXKAV(0,1),""_PXKCAT_"",1,PXKDONE))
 ..S PXJ(1)=$G(^PXD(811.1,PXKDONE,0)) ;8TH IEN
 ..S PXJ(2)=$P(PXJ(1),"^",2) ;SECOND PIECE OF 8TH IEN
 ..S PXJ(3)=$P(PXJ(2),";",1) ;FIRST PIECE OF ABOVE
 ..S PXJ(4)=$P(PXJ(1),"^",4) ;TO
 ..S PXKDONE=$O(^PXD(811.1,"AA",PXJ(3),""_PXJ(4)_"",1,0))
 ..S:PXKDONE="" PXKDONE=0  I '$D(PXKPXD($G(PXKDONE))) D POP
 I (PXKFGDE=1) D
 .I $D(^PXD(811.1,"AA",PXKBV(0,1),""_PXKCAT_"",1)) D
 ..S PXKDONE=$O(^PXD(811.1,"AA",PXKBV(0,1),""_PXKCAT_"",1,PXKDONE))
 ..S PXJ(1)=$G(^PXD(811.1,PXKDONE,0)) ;8TH IEN
 ..S PXJ(2)=$P(PXJ(1),"^",2) ;SECOND PIECE OF 8TH IEN
 ..S PXJ(3)=$P(PXJ(2),";",1) ;FIRST PIECE OF ABOVE
 ..S PXJ(4)=$P(PXJ(1),"^",4) ;TO
 ..S PXKDONE=$O(^PXD(811.1,"AA",PXJ(3),""_PXJ(4)_"",1,0))
 ..S:PXKDONE="" PXKDONE=0  I '$D(PXKPXD($G(PXKDONE))) D POP
 K PXKDONE
 Q
 ;
POP ;Population of more than one v file using PCE CODE MAPPING file 811.1
 ;
 ;N PXKPXD
 N PXKROU,PXKIN,PXKX,PXKXX,PXKDIEN,PXKTO
 S PXKIN=$S(PXKFGAD=1:PXKAV(0,1),PXKFGDE=1:PXKBV(0,1),1:"")
 S PXKDIEN=0 F  S PXKDIEN=$O(^PXD(811.1,"AA",PXKIN,PXKCAT,1,PXKDIEN)) Q:PXKDIEN=""  D
 .S PXKPXD(PXKDIEN)=$G(^PXD(811.1,PXKDIEN,0))
 S (PXKX,PXKXX)=0 F  S PXKX=$O(PXKPXD(PXKX)) Q:PXKX=""  S PXKXX=PXKXX+.01 D
 .I TMPPX[("^"_PXKX_"^") Q
 .S PXKTO=$P(PXKPXD(PXKX),"^",4)
 .S PXKROU=$P(PXKPXD(PXKX),"^",3)_"^PXKF"_PXKTO_"1" D @PXKROU
 .S TMPPX=TMPPX_PXKX_"^"
 S PXKNORG("SOR")=$G(^TMP("PXK",$J,"SOR"))
 S PXKNORG("VSTIEN")=$G(^TMP("PXK",$J,"VST",1,"IEN"))
 Q
