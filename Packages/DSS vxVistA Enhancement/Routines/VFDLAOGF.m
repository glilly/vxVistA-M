VFDLAOGF ;DSS/JDB - ORDER GROUP FILE UTILITIES ;23 Nov 2010 10:04
 ;;2011.1.2;DSS,INC VXVISTA OPEN SOURCE;;28 Jan 2013;Build 25
 ;Copyright 1995-2013,Document Storage Systems Inc. All Rights Reserved
 ;
 Q
 ;
 ;
OERR6903(R69,R6901,R6903,OERR,OUT) ;
 ; Finds the OERR # for this record in file #69, or finds the
 ; R6903+IEN for the R69+R6901+OERR supplied.
 ;  If R6903 is null and OERR is supplied, will find the 69.03 IEN.
 ;  If OERR is null and R6903 supplied, will return the OERR #.
 ; Inputs
 ;     R69: #69 IEN
 ;   R6901: #69.01 IEN
 ;   R6903:<opt> #69.03 IEN
 ;    OERR:<opt> OERR #
 ;     OUT:<byref> See Outputs
 ; Outputs
 ;   Dependant on which Inputs were specified, returns either
 ;   the OERR # for this #69 record, or retuns the #69.03 IEN
 ;   that has the OERR # specified.
 ;   or returns 0^err num^err msg
 ;     OUT(OERR #,R6903)=""
 N DATA,STATUS,X
 S R69=+$G(R69)
 S R6901=+$G(R6901)
 S R6903=+$G(R6903)
 S OERR=$G(OERR)
 K OUT
 I 'R69 I 'R6901 Q "0^1^Insufficient data passed"
 I 'R6903&(OERR="") Q "0^2^Insufficient data passed"
 I R6903 I OERR'="" Q "0^3^Nothing to do"
 S STATUS="0^4^Not found"
 I R6903 D  ;
 . S OERR=""
 . S DATA=$G(^LRO(69,R69,1,R6901,2,R6903,0))
 . S OERR=$P(DATA,U,7)
 . I OERR="" Q
 . S STATUS=OERR
 ;
 I 'R6903 I OERR'="" D  ;
 . N STOP
 . S STOP=0
 . S R6903=0
 . F  S R6903=$O(^LRO(69,R69,1,R6901,2,R6903)) Q:'R6903  D  Q:STOP  ;
 . . S DATA=$G(^LRO(69,R69,1,R6901,2,R6903,0))
 . . S X=$P(DATA,U,7)
 . . S OUT(X,R6903)=""
 . . I X=OERR S STOP=1 S STATUS=R6903 Q
 . ;
 ;
 Q STATUS
 ;
 ;
FINDORD(OGN,R60,R61,R62,OUT) ;
 ; Find the order out of #69 using Order Group Number
 ; and OBR-4 (test) and OBR-15 (spec/sample);
 ; Will build an array of all of the order data first
 ; and then will check that array for matches.  This allows
 ; the ability to check for orders that dont match by test
 ; but do match by sample+specimen.
 ; Inputs
 ;     OGN: Order Group Number
 ;     R60:<opt> File #60 IEN (OBR-4)
 ;     R61:<opt> File #61 IEN (OBR-15)
 ;     R62:<opt> File #62 IEN (OBR-15)
 ;        : At least two of the three should be specified.
 ;     OUT:<byref>  See Outputs
 ; Outputs
 ;   Returns the R69^R6901^R6903
 ;   OUT array.  Sets OUT(21695)=#21695 ien
 ;    See ORDINFO & SAMPSPEC APIs for additional OUT nodes.
 ;     OUT("62+61")=R69^R6901
 ;       If Test not found, and if Sample & Specimen only
 ;       belong to one #69+#69.01 then this node will be defined.
 ;     OUT("A60",#60,#69,#69.01,#69.03)=""
 ;     OUT("A60A",#60,#62,#61,#69,#69.01,#69.03)=""
 ;     OUT("A60B",#60,#61,#62,#69,#69.01,#69.03)=""
 ;     OUT("A61",#61,#69,#69.01)=""
 ;     OUT("A61A",#61,#62,#69,#69.01)=""
 ;     OUT("A62",#62,#69,#69.01)=""
 ;     OUT("A62A",#62,#61,#69,#69.01)=""
 ;     OUT("A69",#69)=""
 ;     OUT("A6901",#69,#69.01)=""
 ;     OUT("A6903",#69,#69.01,#69.03)=""
 ;     OUT("LRDFN")=LRDFN
 ;     OUT("SINGLE")=0 or 1
 ;        1=Grouper # associated with just one #69+#69.01 record.
 ;
 N DATA,DATA2,ID,LABPKGIEN,STATUS,STOP,R69,R6901,R6903,X,LRDFN
 N R60B,R61B,R62B
 S OGN=$G(OGN)
 S R60=$G(R60)
 S R61=$G(R61)
 S R62=$G(R62)
 K OUT
 S STATUS=0
 ; Look up OGN
 S X=$$GETIDS^VFDUOGF(OGN,.DATA)
 I 'X Q "0^1^Order Group Number not found"
 ; DATA(id)=IEN#  DATA(id,10)=Rec Locator  DATA(id,2)=PKG IEN
 ; Loop through and find all associated LAB entries.
 ; DATA2 will hold all Lab IDs
 S OUT(21695)=DATA(0,21695)
 S LABPKGIEN=$$GETPKG^VFDUOGF("LAB SERVICE")
 I 'LABPKGIEN Q "0^2^LAB SERVICE not found in PACKAGE file"
 S ID=""
 F  S ID=$O(DATA(ID)) Q:ID=""  D  ;
 . I $G(DATA(ID,2))=LABPKGIEN M DATA2(ID)=DATA(ID)
 ;
 K DATA
 ; Note: Group Order number may refer to more than just one #69
 ; Loop thru lab group until we find a match
 S STOP=0
 S STATUS=0
 S ID=""
 F  S ID=$O(DATA2(ID)) Q:ID=""  D  ;
 . S X=$G(DATA2(ID,10))
 . I X="" Q
 . S R69=$P(X,";",1)
 . S R6901=$P(X,";",2)
 . S R6903=$P(X,";",3)
 . D ORDINFO(R69,R6901,R6903,.OUT)
 ;
 ; Data model built.  Now check for hits.
 S STATUS="0^1^Test+Sample+Specimen not found"
 ; Check test+sample+specimen
 I R60 I R62 I R61 I $D(OUT("A60A",R60,R62,R61)) D  ;
 . N NODE
 . S NODE=$NA(OUT("A60A",R60,R62,R61))
 . S NODE=$Q(@NODE)
 . S R69=$QS(NODE,5)
 . S R6901=$QS(NODE,6)
 . S R6903=$QS(NODE,7)
 . S DATA=$G(^LRO(69,R69,1,R6901,0))
 . S LRDFN=$P(DATA,U,1)
 . S OUT("LRDFN")=LRDFN
 . S STATUS=R69_"^"_R6901_"^"_R6903
 ;
 ; Check for sample+specimen
 I 'STATUS D  ;
 . S X=$$SAMPSPEC(R61,R62,.OUT,.OUT)
 . I 'X Q
 . S R69=$P(X,"^",1)
 . S R6901=$P(X,"^",2)
 . I 'R60 S STATUS=R69_"^"_R6901_"^0"
 ;
 ; Check if Grouper Number only refers to one #69 order
 I $D(OUT("A6901")) D  ;
 . S NODE="OUT(""A6901"")"
 . S NODE=$Q(@NODE)
 . S R69=$QS(NODE,2)
 . S R6901=$QS(NODE,3)
 . S X=$O(OUT("A6901",R69,R6901))
 . I 'X S OUT("SINGLE")=1
 . E  S OUT("SINGLE")=0
 ;
 I $G(OUT("LRDFN"))="" D  ;
 . I '$D(OUT("A6901")) Q
 . N NODE
 . S NODE="OUT(""A6901"")"
 . S NODE=$Q(@NODE)
 . S R69=$QS(NODE,2)
 . S R6901=$QS(NODE,3)
 . S DATA=$G(^LRO(69,R69,1,R6901,0))
 . S LRDFN=$P(DATA,U,1)
 . S OUT("LRDFN")=LRDFN
 ;
 Q STATUS
 ;
 ;
ORDINFO(R69,R6901,R6903,OUT) ;
 ; Builds order's info data model.
 ; Caller responsible for initializing OUT array.
 ; Inputs
 ;     R69: #69 ien
 ;   R6901: #69.01 ien
 ;   R6903:<opt> #69.03 ien
 ;        : If specified, retrieves values only for that #69.03
 ;     OUT:<byref>  See Ouputs
 ; Outputs
 ;     OUT("A60",#60,#69,#69.01,#69.03)=""
 ;     OUT("A60A",#60,#62,#61,#69,#69.01,#69.03)=""
 ;     OUT("A60B",#60,#61,#62,#69,#69.01,#69.03)=""
 ;     OUT("A61",#61,#69,#69.01)=""
 ;     OUT("A61A",#61,#62,#69,#69.01)=""
 ;     OUT("A62",#62,#69,#69.01)=""
 ;     OUT("A62A",#62,#61,#69,#69.01)=""
 ;     OUT("A69",#69)=""
 ;     OUT("A6901",#69,#69.01)=""
 ;     OUT("A6903",#69,#69.01,#69.03)=""
 ;     OUT("LRDFN")=LRDFN
 N DATA,R60B,R61B,R62B,REC
 S R69=$G(R69)
 S R6901=$G(R6901)
 S R6903=$G(R6903)
 I 'R69 Q
 S OUT("A69",R69)=""
 I 'R6901 Q
 S OUT("A6901",R69,R6901)=""
 S DATA=$G(^LRO(69,R69,1,R6901,0))
 S OUT("LRDFN")=$P(DATA,U,1)
 ; Check sample.
 S R62B=$P(DATA,U,3)
 S OUT("A62",R62B,R69,R6901)=""
 ; Check specimen
 ; Have to loop through because there may be no 'B' xref here
 S REC=0
 F  S REC=$O(^LRO(69,R69,1,R6901,4,REC)) Q:'REC  D  ;
 . S DATA=$G(^LRO(69,R69,1,R6901,4,REC,0))
 . S R61B=$P(DATA,U,1)
 . S R61B(R61B)=""
 . S OUT("A61",R61B,R69,R6901)=""
 . S OUT("A61A",R61B,R62B,R69,R6901)=""
 . S OUT("A62A",R62B,R61B,R69,R6901)=""
 ;
 S REC=R6903-1
 I REC<0 S REC=0
 S STOP=0
 F  S REC=$O(^LRO(69,R69,1,R6901,2,REC)) Q:'REC  D  Q:STOP  ;
 . I R6903 I REC=R6903 S STOP=1
 . S OUT("A6903",R69,R6901,REC)=""
 . ;
 . ; Check test
 . S DATA=$G(^LRO(69,R69,1,R6901,2,REC,0))
 . S R60B=$P(DATA,U,1)
 . S OUT("A60",R60B,R69,R6901,REC)=""
 . ;
 . ; Attach this test to sample + all specimens
 . S R61B=""
 . F  S R61B=$O(R61B(R61B)) Q:'R61B  D  ;
 . . S OUT("A60A",R60B,R62B,R61B,R69,R6901,REC)=""
 . . S OUT("A60B",R60B,R61B,R62B,R69,R6901,REC)=""
 . ;
 ;
 Q
 ;
 ;
SAMPSPEC(R61,R62,IN,OUT) ;
 ; Check for sample+specimen
 ; Inputs
 ;    R61: #61 ien
 ;    R62: #62 ien
 ;     IN:<byref> Data model from ORDINFO API.
 ;    OUT:<byref> Output array.  IN & OUT are usually the same array.
 ; Outputs
 ;  Returns R69^R6901 for qualifying entry
 ;   OUT array
 ;     OUT("62+61")=R69^R6901
 ;        If Test not found, and if Sample & Specimen only
 ;        belong to one #69+#69.01 then this node will be defined.
 ;     OUT("LRDFN")=LRDFN
 N LRDFN,NODE,R69,R6901,X
 S R61=$G(R61)
 S R62=$G(R62)
 S OUT("62+61")=""
 I 'R61 Q 0
 I 'R62 Q 0
 I '$D(IN("A62A",R62,R61)) Q 0
 S NODE=$NA(IN("A62A",R62,R61))
 S NODE=$Q(@NODE)
 S R69=$QS(NODE,4)
 S R6901=$QS(NODE,5)
 ; Check for uniqueness (only matches one R69+R6901 record)
 S X=$O(IN("A62A",R62,R61,"A"),-1)
 I X'=R69 Q 0
 S X=$O(IN("A62A",R62,R61,R69,"A"),-1)
 I X'=R6901 Q 0
 S OUT("62+61")=R69_"^"_R6901
 I $G(IN("LRDFN"))="" D  ;
 . S DATA=$G(^LRO(69,R69,1,R6901,0))
 . S LRDFN=$P(DATA,U,1)
 . S OUT("LRDFN")=LRDFN
 ;
 Q R69_"^"_R6901
