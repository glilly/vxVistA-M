VFDXPDF3 ;DSS/SMP - FILE DATA TO FILE 21692 ; 02/27/2012 08:45
 ;;3.1;DSS,INC VXVISTA SUPPORTED;;10 Dec 2012;Build 58
 ;Copyright 1995-2012,Document Storage Systems Inc. All Rights Reserved
 ;
 ;This routine is only only invoked via the VFDXPD routine.
 ;
FILE(ADD,VFDLOC) ; file data 21692
 ; ADD - opt - Boolean as to whether or not to update existing records
 ;             in file 21692.  New records will always be added
 ;VFDLOC - req - named reference for list of Builds to upd file 21692
 ; where @vfdloc has format at ^TMP("VFDXPD",$J,"DATA") - see 1^VFDXPDF
 N I,J,X,Y,Z,ERR,KID,VCNT,VFDL,VFDN,VFDX,VIEN,VTOT
 S (X,ERR(0),VCNT,VFDN,VTOT)=0
 S ADD=$G(ADD),VFDLOC=$G(VFDLOC) Q:VFDLOC=""  Q:$O(@VFDLOC@(0))=""
 F  S X=$O(@VFDLOC@(X)) Q:X=""  S VTOT=1+VTOT
 ; first make sure all records have a corresponding entry in file 21692
 D FILE1
 ; now convert any IN-MULTI text names to file 21692 pointers
 D FILE2
 ; now convert any REQUIRED BUILD names to file 21692 pointers
 D FILE3
 ; now determine if any other fields need updating in 21692 record
 D FILE4
 I $G(ERR(0)) K ERR(0) D ERR^VFDXPDF0(6,.ERR)
 Q
 ;
 ;-----------------------  PRIVATE SUBROUTINES  -----------------------
CREATE(VFDN,VFDR) ; find or create stub record in 21692
 ; vfdn - req - kids build name
 ; vfdr - opt - named location where the data resides
 ;              see ^TMP("VFDXPD-DATA",$J,build_name) from VFDXPDF
 ; Extrinsic function returns
 ;    -1, 21692_ien or if new record return 21692_ien^build name
 N A,I,X,Y,Z,VFDER,VFDT
 I $G(VFDN)="" Q -1
 S VFDT=VFDN,VFDER="Lookup failed to find entry "
 S X=$$FINDBLD^VFDXPD0(.VFDT) I $D(@VFDR) D
 .I X<1 D ERR(1,VFDN,X) S X=-1
 .S Y="" I X>0 S Y=$P(X,U,2)
 .S @VFDR@("STAT")=$S(X=-1:"Problems",Y'="":"New",1:"")
 .I X>0 S @VFDR@("IEN")=+X
 .I Y'="" S Z=0 F  S Z=$O(VFDT(Z)) Q:Z=""  I $G(@VFDR@(Z))="",VFDT(Z)'="" S @VFDR@(Z)=VFDT(Z)
 .Q
 Q X
 ;
DINIT(A) D XINIT^VFDXPDF0(,A) Q
DSP(T,INC) D XDSP^VFDXPDF0($G(T),,$G(INC)) Q
 ;
ERR(A,NM,MORE) ;
 ;;Lookup failure (21692):;
 ;;Failed to resolve IN-MULTI field value to IEN for;
 ;;Following required Builds not converted to iens for;
 ;;Expected but did not find 21692 ien for;
 ;;Filing error:;
 ;;Field text date not converted to FM format for;
 S ERR(0)=ERR(0)+1
 I $G(A) S ERR(ERR(0))=$TR($T(ERR+A),";"," ")_NM
 I $G(MORE)'="" S ERR(0)=ERR(0)+1,ERR(ERR(0))="     "_MORE
 Q
 ;
FILE1 ;;Filing Data [Get IENS / Create Stub Records]
 N I,X,Y,Z,VCNT,VFDL,VFDN
 D DINIT(5)
 S (VCNT,VFDN)=0 F  S VFDN=$O(@VFDLOC@(VFDN)) Q:VFDN=""  D
 .D DSP(VFDN) S VFDL=$NA(@VFDLOC@(VFDN))
 .S:'$G(@VFDL@("IEN")) X=$$CREATE(VFDN,VFDL)
 .Q
 Q
 ;
FILE2 ;;Filing Data [Convert IN to Pointers]
 ; the only entries with IN values should have come from HFS multi-
 ; build.  FILE1 should have created the stub record in file 21692
 N I,J,T,X,Y,Z,VCNT,VFDL,VFDN
 D DINIT(6)
 S (VCNT,VFDN)=0 F  S VFDN=$O(@VFDLOC@(VFDN)) Q:VFDN=""  D
 .S VFDL=$NA(@VFDLOC@(VFDN))
 .S Y=$G(@VFDL@("IN")),Z=$G(@VFDL@("IN",0))
 .S T=$S(Y=""!Z:"",1:VFDN) D:T'="" DSP(T) I T="" D DSP(,2) Q
 .S X=$G(@VFDLOC@(Y,"IEN")),Z=$G(@VFDLOC@(Y,"BLD"))
 .I 'X D ERR(2,VFDN,"No 21692 ien found for "_Z) Q
 .S @VFDL@("IN",0)=X
 .Q
 Q
 ;
FILE3 ;;Filing Data [Convert Req Builds to Pointers]
 ; this should convert all @vfdl@("REQ",build name)="" to
 ;   @vfdl@("REQ",build name)=21692 ien
 N I,T,X,Y,Z,VCNT,VFDL,VFDN,VFDX,VFDY
 D DINIT(7)
 S (VCNT,VFDN)=0 F  S VFDN=$O(@VFDLOC@(VFDN)) Q:VFDN=""  D
 .S VFDL=$NA(@VFDLOC@(VFDN))
 .S T=$S($D(@VFDL@("REQ")):VFDN,1:"")
 .D:T'="" DSP(T) I T="" D DSP(,2) Q
 .S VFDX=0 F  S VFDX=$O(@VFDL@("REQ",VFDX)) Q:VFDX=""  D
 ..Q:@VFDL@("REQ",VFDX)>0
 ..S X=$G(@VFDLOC@(VFDX,"IEN")) I X S @VFDL@("REQ",VFDX)=X Q
 ..K VFDY S VFDY="VFDY",X=$$CREATE(VFDX,VFDY)
 ..I X<1 D ERR(3,VFDN,VFDX) Q
 ..S @VFDL@("REQ",VFDX)=+X,Y=$P(X,U,2) Q:Y=""
 ..; required build did not exist in file 21692 previously
 ..I VFDX'=Y K @VFDL@("REQ",VFDX) S @VFDL@("REQ",Y)=+X
 ..I '$D(@VFDLOC@(Y)) M @VFDLOC@(Y)=VFDY
 ..Q
 .Q
 Q
 ;
FILE4 ;;Filing Data [File Remaining Data to File 21692]
 ; no new 21692 records should be required to be created at this point
 ; only update fields that are null or if ADD then any differences
 N A,B,I,J,X,Y,Z,SAVE,VCNT,VFDL,VFDN,VFDX,VFDY,VFLDS,VMAP
 D DINIT(8),MAP
 S (VCNT,VFDN)=0 F  S VFDN=$O(@VFDLOC@(VFDN)) Q:VFDN=""  D
 .N REQ,SAVE,VDATA,VFDA,VERRCK,VIEN,VMAP
 .S VFDL=$NA(@VFDLOC@(VFDN)) M VDATA=@VFDL
 .; vdata() from @vfdloc = ^tmp("vfdxpd",$j,"data")
 .S VIEN=$G(VDATA("IEN")) I 'VIEN D ERR(4,VFDN) Q
 .S VERRCK=0
 .; get all the data from the file
 .S Y=$$GETS^VFDXPDA("VFDA",21692,VIEN_",","**","EI")
 .I Y<1 Q  ; should not happen - error
 .M VFDA(0)=VFDA(21692,VIEN_",")
 .; get top level fields and mapping
 .D MAP
 .;
 .; get top level fields to be updated
 .; check numeric fields
 .F I=.06,.061,.07,.08,.16 S X=VMAP(I) D
 ..K VMAP(I)
 ..S A=$G(VDATA(X)),B=$G(VFDA(0,I,"I"))
 ..I A>0,$S('B:1,'ADD:0,1:A'=B) S SAVE(I)=A Q
 ..I A=0,B="" S SAVE(I)=A
 ..Q
 .; convert text dates to FM
 .F I=.04,.09 S X=VMAP(I) D
 ..K VMAP(I)
 ..S A=$G(VDATA(X)),B=$G(VFDA(0,I,"I")) Q:A=""
 ..I A'?7N.E S A=$P($$HTFM^VFDXPD0(A),U)
 ..I A'?7N.E D ERR(6,VFDN_"(#"_I_")") S VERRCK=1 Q
 ..I I=.04 S A=$P(A,".")
 ..I A,$S('B:1,'ADD:0,1:A'=B) S SAVE(I)=A
 ..Q
 .; check rest of the fields
 .S I=0 F  S I=$O(VMAP(I)) Q:'I  S X=VMAP(I) D
 ..S A=$S(I'=.15:$G(VDATA(X)),1:$G(VDATA(X,0)))
 ..S B=$G(VFDA(0,I,"I"))
 ..I A'="",$S(B="":1,'ADD:0,1:A'=B) S SAVE(I)=A
 ..Q
 .; now get all required Builds
 .; z(build name)=ien, z(ien)=build name
 .K Z S I=0 F  S I=$O(VFDA(21692.06,I)) Q:I=""  D
 ..S X=VFDA(21692.06,I,.01,"E"),Y=VFDA(21692.06,I,.01,"I")
 ..S Z(X)=Y,Z(Y)=X
 ..Q
 .S X=0 F  S X=$O(VDATA("REQ",X)) Q:X=""  D
 ..S Y=VDATA("REQ",X) I '$D(Z(X)),Y S SAVE("REQ",Y)=""
 ..Q
 .D:'$D(SAVE) DSP(,2) D:$D(SAVE) DSP(VFDN),SAVE
 .Q
 Q
 ;
MAP ; map text nodes to field numbers
 ;;REL^.04
 ;;PKG^.05
 ;;VER^.06
 ;;PATCH^.061
 ;;SEQ^.07
 ;;MSGID^.08
 ;;DATE^.09
 ;;IN^.15
 ;;ORD^.16
 ;;SUBJ^.9
 ;;MES^.901
 ;;ENV^.91
 ;;PRE^.911
 ;;POST^.912
 ;;KID^.92
 ;;TXT^.921
 ;;FOIA KID^.922
 ;;FOIA TXT^.923
 ;;
 ; vmap(text)=fld#, vmap(fld#)=text
 N I,X,Y K VMAP
 F I=1:1 S X=$P($T(MAP+I),";",3) Q:X=""  D
 .S Y=$P(X,U,2),X=$P(X,U)
 .S VMAP(X)=Y,VMAP(Y)=X
 .Q
 Q
 ;
SAVE ; save data to file 21692 for a single record
 ; expects VIEN, SAVE(field#)=value, SAVE("REQ",ien)=""
 N I,J,X,Y,Z,VFDY
 I $O(SAVE(0))>0 D
 .S I=0 F  S I=$O(SAVE(I)) Q:'I  S VFDY(I)=SAVE(I)
 .S X=$$FILE^VFDXPDA(21692,VIEN,.VFDY)
 .I +X=-1 D ERR(5,VFDN,$P(X,U,2)) S VERRCK=1
 .Q
 I $D(SAVE("REQ")) D
 .K VFDY S (I,J)=0
 .F  S I=$O(SAVE("REQ",I)) Q:'I  S J=J+1,VFDY(J,.01)=I
 .S X=$$UPDDINUM^VFDXPDA(21692.06,","_VIEN_",",.VFDY)
 .I +X=-1 D ERR(5,VFDN,$P(X,U,2)) S VERRCK=1
 .Q
 S X=$S('VERRCK:"Updated",1:"Upd/Prob"),Y=$G(@VFDL@("STAT"))
 I $E(Y)="P",X="Updated" S X="Upd/Prob"
 I Y="New",X="Upd/Prob" S (X,Y)="New/Prob"
 I Y'="New" S @VFDL@("STAT")=X
 Q
 ;
UP(A) S:A?.E1L.E A=$$UP^XLFSTR(A) Q A
