VFDHDIA ; DSS/WLC - Add entry to Standardized file ; 04/26/2013 10:20
 ;;2011.1.2;DSS,INC VXVISTA OPEN SOURCE;;11 Jun 2013;Build 7
 ;Copyright 1995-2013,Document Storage Systems Inc. All Rights Reserved
 ;
 ; Routine adds value to existing file that has been standardized.
EN(VFOK,FILE,IEN,LIST) ;  RPC:  VFD ADD STD FIELD
 ; INPUT:
 ;    FILE = file number
 ;    IEN = Internal Entry number in file (default = +1,)
 ;          Send "+1," to add entry to file.
 ;    LIST = Array of values to add, with field number (fld #^Value)
 ;         i.e.:  LIST(1)=".01^Adding description to file"
 ; OUTPUT:
 ;     VFOK = -1^Error, or, 1 for success
 ;
 N I,X,DIERR,ENTRY,FIELD,HLPM,VFDERRM,VFDFDA,XUMF
 S VFOK=0,XUMF=1
 S FILE=$G(FILE),IEN=$G(IEN) S:IEN="" IEN="+1,"
 I '$D(LIST) S VFOK=$$EN2(2) Q
 S X=$$VFILE^DILFD(FILE) I 'X D EN2(1) Q
 S I="" F  S I=$O(LIST(I)) Q:'I  D  Q:VFOK<0
 . K DIERR,VFDERRM
 . S FIELD=$P(LIST(I),U),ENTRY=$P(LIST(I),U,2)
 . S X=$$VFIELD^DILFD(FILE,FIELD) I 'X D EN2(3) Q
 . D VAL^DIE(FILE,IEN,FIELD,"H",ENTRY,,"VFDERRM")
 . I $G(ERRM)="^" D EN3 Q
 . S VFDFDA(FILE,IEN,FIELD)=ENTRY
 . Q
 Q:VFOK<0
 I IEN["+1" D UPDATE^DIE(,"VFDFDA",,"VFDERRM") I 1
 E  D FILE^DIE(,"VFDFDA","VFDERRM")
EN1 ;
 I '$D(DIERR) S VFOK=1
 E  D EN3
 Q
 ;
EN2(N) ;
 N X
 I N=1 S X="File #"_FILE_" is not valid."
 I N=2 S X="No field data defined"
 I N=3 S X="Field #"_FIELD_" does not exist in File #"_FILE
 S VFOK="-1^"_X
 Q
 ;
EN3 S VFOK="-1^"_$$MSG^VFDCFM("E",,,,"VFDERRM") Q
 ;
VUIDG(FILE,FLG) ; Generate VUID for Standardized files
 ; INPUT:
 ;    FILE = file number to standardize
 ;    FLG = set to indicate DSS Standard VUID (DSS; site = 100)
 N I,L,X,Y,LAST,ROOT,SITE,ST,VFDR
 S FLG=+$G(FLG) S:+$G(VFDXUMF) FLG=+VFDXUMF
 S X=$$SITE^VASITE,SITE=+$P(X,U,3) S:SITE<1 SITE=+X I SITE<1 Q -1
 S:FLG SITE=100
 S L=$S(SITE<100:9,1:10),ST=$E(SITE_"0000000000",1,L)
 S ROOT=$$ROOT^VFDCFM(,$G(FILE),,1) I +ROOT=-1 Q ROOT
 S LAST=$O(@ROOT@("AVUID",""),-1)
 I LAST'?1N.N!($E(LAST,1,$L(SITE))'=SITE) S LAST=ST
 S X=LAST+1
 Q X
 ;
 ; $$VUIDG invoked by trigger cross-reference from following .01 fields
 ;120.51,120.52,120.53
