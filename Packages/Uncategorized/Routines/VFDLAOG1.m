VFDLAOG1 ;DSS/JDB - ORDER GROUP FILE UTILITIES ;23 Nov 2010 10:04
 ;;2011.1.2;DSS,INC VXVISTA OPEN SOURCE;;28 Jan 2013;Build 25
 ;Copyright 1995-2013,Document Storage Systems Inc. All Rights Reserved
 ;
 ;      GET1^DIQ/2056
 ;
 Q
 ;
 ;
RELATED(OERRS,OUT) ;
 ; Find related Order Groups for these OERR #s.
 ; Inputs
 ;   OERRS:<byref>  OERRS(oerr#)=""
 ;     OUT:<byref>  See Outputs
 ; Outputs
 ;     OUT array     OUT(oerr#, #60 ien, order group)=""
 ;
 N GRPNUM,GRPS,OERR,TMPNM
 S TMPNM="VFDLAOG1"
 K OUT
 K ^TMP(TMPNM,$J)
 S OERR=""
 F  S OERR=$O(OERRS(OERR)) Q:'OERR  D  ;
 . K GRPS
 . D GETOGNS(OERR,.GRPS)
 . S GRPNUM=""
 . F  S GRPNUM=$O(GRPS(GRPNUM)) Q:GRPNUM=""  D  ;
 . . ;update TMP
 . . D IDS2TMP(TMPNM,GRPNUM)
 . ;
 ;
 M OUT=^TMP(TMPNM,$J,1)
 K ^TMP(TMPNM,$J)
 Q
 ;
 ;
GETOGNS(OERR,GRPNUMS) ;
 ; Find all Order Group Numbers for this OERR#
 ; Inputs
 ;    OERR: OERR #
 ;  GRPNUMS:<byref>  See Outputs
 ; Outputs
 ;  GRPNUMS array    GRPNUMS(Order Group #)=""
 N I,NODE,STOP,X
 S OERR=$G(OERR)
 K GRPNUMS
 S STOP=0
 S (NODE,NODE(0))=$NA(^VFD(21695,"AE",OERR))
 F  S NODE=$Q(@NODE) Q:NODE=""  D  Q:STOP  ;
 . F I=1:1:$QL(NODE(0)) I $QS(NODE,I)'=$QS(NODE(0),I) S STOP=1 Q
 . I STOP Q
 . S X=$QS(NODE,4) ;group #
 . S GRPNUMS(X)=""
 ;
 Q
 ;
 ;
IDS2TMP(TMPNM,OGN) ;
 ; Build TMP global.
 ; 60 node prevents us from having to lookup the lab test for every
 ;   OERR# found.
 ;             ^TMP(TMPNM,$J,60,id)=#60
 ;             ^TMP(TMPNM,$J,1,ID,R60,OGN)=""
 ;             ^TMP(TMPNM,$J,2,69,69.01,69.03)=""
 ; Inputs
 ;   TMPNM: ^TMP name
 ;     OGN: Order Group #
 N DIERR,ID,IDS,IEN,PKGLAB,R60,R69,R6901,R6903,R94,RECLOC,VFDMSG
 S TMPNM=$G(TMPNM)
 S OGN=$G(OGN)
 I TMPNM="" S TMPNM="VFDLAOG1"
 S PKGLAB=$$GETPKG^VFDUOGF("LAB SERVICE")
 ; get IDs on this OGN
 D GETIDS^VFDUOGF(OGN,.IDS)
 S ID=""
 F  S ID=$O(IDS(ID)) Q:ID=""  D  ;
 . S R94=$G(IDS(ID,2))
 . I R94'=PKGLAB Q
 . I $D(^TMP(TMPNM,$J,60,ID)) D  Q  ;
 . . S R60=^TMP(TMPNM,$J,60,ID)
 . . S ^TMP(TMPNM,$J,1,ID,R60,OGN)=""
 . ;
 . S RECLOC=$G(IDS(ID,10))
 . I RECLOC'?1.N1";"1.N1";"1.N Q
 . S R69=$P(RECLOC,";",1)
 . S R6901=$P(RECLOC,";",2)
 . S R6903=$P(RECLOC,";",3)
 . I 'R6903 Q
 . S IEN=R6903_","_R6901_","_R69_","
 . K VFDMSG,DIERR
 . S R60=$$GET1^DIQ(69.03,IEN,.01,"I","","VFDMSG")
 . I 'R60 Q
 . S ^TMP(TMPNM,$J,60,ID)=R60
 . S ^TMP(TMPNM,$J,1,ID,R60,OGN)=""
 . S ^TMP(TMPNM,$J,2,R69,R6901,R6903)=""
 ;
 ;
 D CLEAN^DILF
 Q
