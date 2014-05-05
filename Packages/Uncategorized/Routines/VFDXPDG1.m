VFDXPDG1 ;DSS/SGM - INSTALLATION ORDER REPORT ; 06/12/2011 23:45
 ;;3.1;DSS,INC VXVISTA SUPPORTED;;10 Dec 2012;Build 58
 ;Copyright 1995-2012,Document Storage Systems Inc. All Rights Reserved
 ;
 ; This routine should only be invoked via the VFDXPD routine
 ;DESCRIPTION OF ^TMP("VFDXPD",$J) nodes
 ;  ien = record number in file 21692
 ;--------------------------------------
 ;^("B") and ^("DATA") for all builds in batch
 ;  sub = pkg-vv.dd-seq
 ;^("B",sub) = ien
 ;^("DATA",ien) = p1^p2^...^p11
 ;     p1 = build name     p5 = patch#      p9 = post-install
 ;     p2 = release date   p6 = seq#       p10 = in-multi (ptr)
 ;     p3 = package        p7 = status     p11 = string for sorting
 ;     p4 = version        p8 = pre-install      pkg-vv.dd-ssss
 ;^("DATA",ien,"REQ",req_ien) = build name (req_ien ptr to 21692)
 ;^("DATA",ien,"REQ",req_build_name,req_build_ien) = ""
 ;   LAST - for each primary build in batch, get its current status
 ;          in the INSTALL file on the target system
 ;^("LAST",<int install status>)=ext. install status
 ;^("LAST",-1)="" for builds which are not installable
 ;^("LAST",<int install stat>,sub)=p1^p2^p3 where
 ;     p1=build name   p2=INSTALL file (#9.7) ien
 ;     p3=INSTALL file date int;ext
 ;     OR if err or not found -1^msg
 ;   MISS - list of missing patches
 ;          may be a required build
 ;          if from batch list, then missing indicates the immediate
 ;           previous installable patch has not been installed
 ;^("MISS",n,sub) = p1^p2^p3^p4^p5 where
 ;     n=1 for builds in batch     n=2 for required builds
 ;     p1=build name of first patch in batch list
 ;     p2=build name
 ;     p3=INSTALL FM date int;ext
 ;     p4=INSTALL status int;ext
 ;     if INSTALL not found then p2=message, p3="", p4=""
 ;^("ERR","GET",sub)="" where sub=build name or zien-<ien>
 ;^("MSG","
 ;^("POST",build name,n,0) = post-install instructions
 ;^("PRE",build name,n,0) = pre-install instructions
 ;^("REQ",ien)=pien^pien^pien^... list of all required builds
 ;    where ien=ptr_21692 of req_build
 ;          pien=21692 entry requiring this build
 ;   SORT is first pass sort by name removing multi-builds
 ;^("SORT",sub) = ien [single build or primary in multi-build]
 ;^("SORT",sub,"MULT",s-sub) = sien
 ;   s-sub - refers to secondary builds in multi-build
 ;
 N I,J,X,Y,Z,VFDR
 S VFDR=$NA(^TMP("VFDXPD",$J)) K @VFDR
 D GETBLD(32)
 ; check and clean up required builds
 D REQ
 ; get INSTALL status of all primary builds in the batch
 D GETLAST
 ; for patches, see if last installable patch has been installed
 D GETPREV
 Q
 ;
 ;-----------------------  PRIVATE SUBROUTINES  -----------------------
GETBLD(PID) ; get list of all Builds in a batch group
 N I,J,X,Y,Z,MULTI,VFDERR,VFDI
 S (VFDI,VFDERR)=0
 F  S VFDI=$O(^VFDV(21692.1,PID,1,VFDI)) Q:'VFDI  D
 .I $G(@VFDR@("DATA",VFDI))="" D G1(VFDI)
 .Q
 ; create SORT node
 S I=0 F  S I=$O(@VFDR@("DATA",I)) Q:'I  D G3(I)
 Q
 ;
G1(VFDY) ; get data, set ^tmp global
 N A,F,I,J,X,Y,Z,DIERR,FLDS,MULTI,VFDA,VFDER,VIENS
 S VIENS=VFDY_","
 D GETS^DIQ(21692,VIENS,"**","EI","VFDA","VFDER")
 I $D(DIERR) D  Q
 .S X=$P($G(^VFDV(21692,VDFY,0)),U) S:X="" X="zien-"_VFDY
 .S @VFDR@("ERR","GET",X)=""
 .Q 
 K FLDS M FLDS=VFDA(21692,VIENS)
 S X="",Z=".01^.04^.05^.06^.061^.07^.1^.11^.12^.15"
 F I=1:1:$L(Z,U) S F=$P(Z,U,I),$P(X,U,I)=FLDS(F,"I")
 S $P(X,U,11)=$$SUB($P(X,U,3),$P(X,U,4),$P(X,U,6))
 S MULTI=FLDS(.15,"I") I MULTI,MULTI=VFDY S $P(X,U,10)="",MULTI=""
 I X'?.11"^" D
 .S @VFDR@("DATA",VFDY)=X
 .S @VFDR@("B",$P(X,U,11))=VFDY
 .Q
 E  Q
 ; pre/post installation instructions
 S Z=$P(X,U,11),Y=FLDS(.01,"E")
 I $O(FLDS(2,0)) D
 .M @VFDR@("PRE",Z)=FLDS(2)
 .K @VFDR@("PRE",Z,"E"),^("I") S @VFDR@("PRE",Z)=Y
 .Q
 I $O(FLDS(3,0)) D
 .M @VFDR@("POST",$P(X,U,11))=FLDS(3)
 .K @VFDR@("POST",Z,"E"),^("I") S @VFDR@("POST",Z)=Y
 .Q
 ; required builds, put secondary req builds in multi under primary
 S Y=$S(MULTI:MULTI,1:VFDY) D G2(Y)
 Q
 ;
G2(VFDY) ; required builds - put into ^TMP global
 N I,J,X,Y,Z
 S J=0 F  S J=$O(VFDA(21692.06,J)) Q:J=""  D
 .S X=VFDA(21692.06,J,.01,"I"),Y=VFDA(21692.06,J,.01,"E")
 .S @VFDR@("DATA",VFDY,"REQ",X)=Y,^(Y,X)=""
 .S Z=$G(@VFDR@("REQ",X)),^(X)=Z_VFDY_U
 .Q
 Q
 ;
G3(VFDY) ; set up sort list of builds to be installed
 N I,X,Y,Z,MULTI,NM,SUB
 S X=@VFDR@("DATA",VFDY)
 S MULTI=$P(X,U,10),SUB=$P(X,U,11)
 I 'MULTI S @VFDR@("SORT",SUB)=VFDY Q
 S X=@VFDR@("DATA",MULTI)
 S SUB(0)=$P(X,U,11)
 S @VFDR@("SORT",SUB(0),"MULT",SUB)=VFDY
 Q
 ;
GETLAST ; get last installed patch on this server
 ; only check for those builds marked as installable in 21692
 N I,J,X,Y,Z,IEN,LAST,STAT,STOP,SUB,VFDS
 S STOP=0,VFDS=$NA(@VFDR@("SORT"))
 F  S VFDS=$Q(@VFDS) Q:VFDS=""  D  Q:STOP
 .S J=$QL(VFDS) I J<3 S STOP=1 Q
 .I $QS(VFDS,2)'=$J!($QS(VFDS,3)'="SORT") S STOP=1 Q
 .I J'=4 Q  ; do not process multi
 .S IEN=@VFDS,NM=$P(@VFDR@("DATA",IEN),U),STAT=$P(^(IEN),U,7)
 .; check in entry in batch is installable
 .I STAT'=1,STAT'=2 Q
 .S SUB=$QS(VFDS,4)
 .S X=$$LAST^VFDXPD0(,NM,3),LAST=$P(X,U,4)
 .I +X=-1 S X=NM,LAST="-1;No Entry in the Install file"
 .S:$G(@VFDR@("LAST",+LAST))="" ^(+LAST)=$P(LAST,";",2)
 .S @VFDR@("LAST",+LAST,SUB)=$P(X,U,1,3)
 .Q
 Q
 ;
GETPREV ; for patches, get status of last installable patch prior
 ; to the first patch*ver*seq
 N I,J,X,Y,Z,IEN,LAST,NM,PKG,SEQ,STAT,STOP,SUB,VER
 S SUB="" F  S SUB=$O(@VFDR@("B",SUB)) Q:SUB=""  D
 .S IEN=@VFDR@("B",SUB)
 .S PKG=$P(SUB,"-"),VER=+$P(SUB,"-",2),SEQ=+$P(SUB,"-",3)
 .S NM=$P(@VFDR@("DATA",IEN),U)
 .Q:SEQ<2  ; new version OR 1st no need to check patches
 .S STOP=0,J=SEQ
 .F  S J=$O(^VFDV(21692,"AD",PKG,VER,J),-1) Q:'J  D  Q:STOP
 ..S IEN=$O(^VFDV(21692,"AD",PKG,VER,J,0))
 ..S Y=$$INSTCK(IEN)
 ..Q:Y=-2  ; not an installable patch
 ..I Y=3 S STOP=1 Q  ; previous patch installed
 ..S X=$P(Y,U,6,8) S:+X=-1 X="No INSTALL file entry found"
 ..S @VFDR@("MISS",1,SUB)=NM_U_X,STOP=1
 ..Q
 .Q
 Q
 ;
INSTCK(I) ; check if build is installable & whether it was installed
 ; I - req - pointer to file 21692
 ; Return -2 if the build in not installable
 ;        -1 if there is no INSTALL file entry
 ;         3 if last INSTALL file entry has a status of completed
 ;         else return p1^p2^...^p8 where
 ;           p1=build name   p2=pkg   p3=ver   p4=patch   p5=seq
 ;           p6=INSTALL file ien
 ;           p7=INSTALL date int;ext
 ;           p8=INSTALL status int;ext
 ;
 N J,X,Y,Z,NM,PATCH,PKG,SEQ,STAT,VER
 S X=^VFDV(21692,I,0),PATCH=+$P(X,U,9),STAT=$P(X,U,10)
 S NM=$P(X,U),PKG=$P(X,U,5),VER=+$P(X,U,6),SEQ=+$P(X,U,7)
 ; if status is not 1 or 2 then not an installable build
 I STAT'=1,STAT'=2 Q -2
 ; get the last INSTALL history record for this build
 S Z=$$LAST^VFDXPD0(,NM,3)
 I +$P(Z,U,4)=3 Q 3
 S Y=$P(Z,U,2,4) S:+Z=-1 Y=-1
 Q NM_U_PKG_U_VER_U_PATCH_U_SEQ_U_Y
 ;
REQ ; check required builds
 N I,J,X,Y,Z,NM,SUB
 S Z=$NA(@VFDR@("REQ"))
 ; removed Builds from list if req builds in the batch set
 S I=0 F  S I=$O(@Z@(I)) Q:'I  K:$D(@VFDR@("DATA",I)) @Z@(I)
 Q:'$O(@Z@(0))
 ; check remaining required builds to see that they are installed
 S I=0 F  S I=$O(@Z@(I)) Q:'I  D
 .S X=$$INSTCK(I)
 .; required build is not an installable build
 .I X=-2 K @Z@(I) Q
 .; required build is installed
 .I X=3 K @Z@(I) Q
 .S Y=$P(X,U,6,8) I +Y=-1 S Y="No Install file entry found"
 .S NM=$P(X,U),SUB=$$SUB($P(X,U,2),$P(X,U,3),$P(X,U,5))
 .S @VFDR@("MISS",2,SUB)=NM_U_Y
 .Q
 Q
 ;
SUB(PKG,VER,SEQ) ; return single string that will sort properly
 N X,Y,Z
 I $L(VER)<5 S VER=$$RJ^XLFSTR($J(VER,0,2),5,0)
 S SEQ=$$RJ^XLFSTR(SEQ,4,0)
 Q PKG_"-"_VER_"-"_SEQ
