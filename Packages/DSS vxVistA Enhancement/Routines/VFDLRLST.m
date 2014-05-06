VFDLRLST ;DSS/JDB/RAF - Lab order print form build ; 11/4/11 4:57pm
 ;;2011.1.2;DSS,INC VXVISTA OPEN SOURCE;;28 Jan 2013;Build 25
 ;Copyright 1995-2013,Document Storage Systems Inc. All Rights Reserved
 ;
 Q
 ;DBIA# Description of all VistA APIs in the VFDMOS routines
 ;----- ------------------------------------------------------
 ;      CLEAN^DILF
 ;      $$GET1^DIQ
 ;      GETS^DIQ
 ;      ^DIWP
 ;      $$VALUE^ORX8
 ;      $$TRIM^XLFSTR
LAB(VFDOUT,VFDORLST,VFDEVENT,FUTURE) ;
 ; VFDEVENT=PRINT EVENT CODE^PRINT OVERRIDE (1)
 ; FUTURE = placeholder for possible ref lab IEN????
 ; RPC - VFD LR TEST ORDER SHEET - documentation for the LAB call
 ; RPC - VFD ORDER PRINT DATA - from ^VFDORP
 ; Inputs
 ;    VFDOUT:<byref>  See Outputs
 ;  VFDORLST:<byref>
 ;       VFDORLST(seq)=ORIFN (OERR#)
 ;  VFDEVENT:<byref>
 ;       1=ORDER, 2=REPRINT, 3=PRINT ,4=REPRINT with override
 ;    FUTURE:<placeholder>
 ;       to be used when reprint comment is available
 ; Outputs
 ;   Creates the ^TMP("VFDLRLST-OUT",$J) global.
 ;    VFDOUT=ERROR MESSAGE
 ;    VFDOUT(n)=Field Name^data
 ;  VFDOUT(n)="$START LRFORM"
 ;  VFDOUT(n)="$START PID"
 ;  VFDOUT(n)=...
 ;  VFDOUT(n)="$END PID"
 ;  VFDOUT(n)="$START ORDER"
 ;  VFDOUT(n)=...
 ;  VFDOUT(n)="$END ORDER"
 ;  VFDOUT(n)="$END LRFORM"
 ;  VFDOUT(n)=$START LRFORM"   <= beginning marker of order record
 ;  VFDOUT(n)=$START PID
 ;  VFDOUT(n)=DIAG^
 ;  VFDOUT(n)=PAT AD CITY^city of patient
 ;  VFDOUT(n)=PAT AD L1^1st line of patient address
 ;  VFDOUT(n)=PAT AD L2^2nd line of patient address
 ;  VFDOUT(n)=PAT AD L3^3rd line of patient address
 ;  VFDOUT(n)=PAT AD STATE^state of patient address
 ;  VFDOUT(n)=PAT AD ZIP^zip code of patient address
 ;  VFDOUT(n)=PAT DOB^date of birth of patient
 ;  VFDOUT(n)=PAT NAME^name of patient
 ;  VFDOUT(n)=PAT SSN^SSN of patient
 ;  VFDOUT(n)=PHONE #^home phone of patient
 ;  VFDOUT(n)=$END PID
 ;  VFDOUT(n)=$START TEST
 ;  VFDOUT(n)=COL TYP^collect type
 ;  VFDOUT(n)=DX^a;b;c;....
 ;  VFDOUT(n)=LOC^patient location name
 ;  VFDOUT(n)=MD^ordering physician name
 ;  VFDOUT(n)=REF LAB^name of the reference lab
 ;  VFDOUT(n)=TEST^
 ;  VFDOUT(n)=TEST CMTi^        (multi)
 ;  VFDOUT(n)=TEST CODE^
 ;  VFDOUT(n)=TEST CPT^
 ;  VFDOUT(n)=TEST LRORD^lab order number
 ;  VFDOUT(n)=TEST START^CPRS start date/time
 ;  VFDOUT(n)=TEST SAMP^collection sample
 ;  VFDOUT(n)=$END TEST
 ;  Optional section.  This is for "missed" tests.
 ;  VFDOUT(n)=$START INFO
 ;  VFDOUT(n)=ORIFN^Order text from file 100
 ;  VFDOUT(n)=$END INFO
 ;  VFDOUT(n)=$END LRFORM   <= end marker of order record
 ; parameters are needed to determine the following lab specific traits
 ; should the MD order groups get a unique group number
 ; should the orders use the OERR_ORIFN instead of the group ID
 K VFDOUT,VFDDLIEN,VFDDLNAME
 N VFDMD,VFD1,VFDRL,VFDX1,VFDOGN,VFDMISS,VFDGO,VFDID,X
 K ^TMP("VFDLRLST-OUT",$J)
 K ^TMP("VFDLRLST-BLD",$J)
 S X=$$X^VFDXTX("VFDLRLST~LAB",1)
 I $$TRIM^XLFSTR(X)'="" D  Q
 . X X
 I $G(VFDEVENT)=4 S VFDGO=1,VFDEVENT=2
 ; line above connerts a 4 event type to a reprint with override, no related order check will be done.
 ;New code set for VFDEVENT
 I '$D(VFDEVENT) S VFDEVENT=3  ;default to PRINT if not defined
 S VFDDLIEN=$$GET^XPAR("DIV","VFDLA QUICK ORDER DEFAULT LAB",1,"I")
 S VFDDLNAME=$$GET1^DIQ(9999999.64,VFDDLIEN_",",.01,"E","VFDERR")
 D STATUS(.VFDORLST)
 ; STATUS screens out all but PENDING orders and
 ; returns VFDLST() and VFDRL() arrays
 I (VFDEVENT=2)&($G(VFDGO)'=1) D RELATED^VFDLAOG1(.VFDRL,.VFDREL)
 ; RELATED looks for associated orders that are not part of
 ; the list to be printed
 I (VFDEVENT=2)&($G(VFDGO)'=1) D GRPCHK(.VFDREL)
 ; GRPCHK call sets VFDMISS array with data to be added to VFDOUT
 D BUILDTMP(.VFDLST)
 D BUILDOUT(.VFDOUT)
 I $D(VFDMISS) D ADDTO(.VFDMISS)
 D UPDATE(.VFDOUT)
 I '$D(VFDMISS) D NWSORT(.VFDMD)  ;D ORDID(.VFDMD)
 K ^TMP("VFDLRLST-BLD",$J)
 Q
BUILDOUT(VFDOUT) ;
 ; Creates the VFDOUT array from the ^TMP("VFDLRST") global
 ; Private method
 ; Inputs
 ;   VFDOUT:<byref>  See Outputs
 ; Outputs
 ;   VFDOUT array
 N FLD,I,NODE,ORIFN,SECT,STOP,X
 K VFDOUT
 K ^TMP("VFDLRLST-OUT",$J)
 ; Error message
 I $G(^TMP("VFDLRLST-BLD",$J,0))'="" D  Q  ;
 . S X=^TMP("VFDLRLST-BLD",$J,0)
 . S VFDOUT=X
 . S ^TMP("VFDLRST-OUT",$J)=X
 S VFDOUT(1)="$START LRFORM"
 D SETTMP2("$START LRFORM")
 ; Build PID section first
 S SECT=0
 S STOP=0
 S NODE=$NA(^TMP("VFDLRLST-BLD",$J,"PID"))
 F  S NODE=$Q(@NODE) Q:NODE=""  D  Q:STOP  ;
 . I $QS(NODE,1)'="VFDLRLST-BLD" S STOP=1 Q
 . I $QS(NODE,2)'=$J S STOP=1 Q
 . I $QS(NODE,3)'="PID" S STOP=1 Q
 . I SECT=0 D  ;
 . . S I=$O(VFDOUT(""),-1)+1
 . . S VFDOUT(I)="$START PID"
 . . D SETTMP2("$START PID")
 . . S SECT=1
 . S FLD=$QS(NODE,4)
 . S I=$O(VFDOUT(""),-1)+1
 . S VFDOUT(I)=FLD_"^"_@NODE
 . D SETTMP2(FLD_"^"_@NODE)
 I SECT D  ;
 . S I=$O(VFDOUT(""),-1)+1
 . S VFDOUT(I)="$END PID"
 . D SETTMP2("$END PID")
 ; Build non-PID nodes
 S SECT=0
 S STOP=0
 S NODE=$NA(^TMP("VFDLRLST-BLD",$J))
 F  S NODE=$Q(@NODE) Q:NODE=""  D  Q:STOP  ;
 . I $QS(NODE,1)'="VFDLRLST-BLD" S STOP=1 Q
 . I $QS(NODE,2)'=$J S STOP=1 Q
 . I '$QS(NODE,3) S STOP=1 Q
 . S ORIFN=$QS(NODE,3)
 . S FLD=$QS(NODE,4)
 . I SECT=0 D  ;
 . . S I=$O(VFDOUT(""),-1)+1
 . . S VFDOUT(I)="$START ORDER"
 . . D SETTMP2("$START ORDER")
 . . S SECT=1
 . S I=$O(VFDOUT(""),-1)+1
 . S VFDOUT(I)=FLD_"^"_@NODE
 . D SETTMP2(FLD_"^"_@NODE)
 . ; Lookahead
 . S NODE(1)=$Q(@NODE)
 . S X=$QS(NODE(1),3)
 . I X'=ORIFN D  ;
 . . S I=$O(VFDOUT(""),-1)+1
 . . S VFDOUT(I)="$END ORDER"
 . . D SETTMP2("$END ORDER")
 . . S SECT=0
 S I=$O(VFDOUT(""),-1)+1
 S VFDOUT(I)="$END LRFORM"
 D SETTMP2("$END LRFORM")
 K ^TMP("VFDLRLST-BLD",$J)
 Q
BUILDTMP(VFDORLST) ;
 ; Builds the ^TMP("VFDLRLST") global.
 ;     ^TMP("VFDLRLST",$J,ORIFN#,fieldName)=value
 ;     ^TMP("VFDLRLST",$J,"PID",fieldName)=value
 ; Inputs
 ;   VFDORLST:<byref>  Array of ORIFNs
 ;           :  VFDORLST(seq)=orifn
 N DATA,DIAG,DIERR,I,NUM,ORIFN,X
 N VFDDATA,VFDDFN,VFDDIAG,VFDGRP,VFDMSG
 N VFDOUT,VFDORDERGROUP,VFDRLAB
 K ^TMP("VFDLRLST",$J)
 ; Get first array entry and build PID info
 S NUM=+$O(VFDORLST(0)) Q:'NUM
 S ORIFN=VFDORLST(NUM)
 S VFDDFN=+$$GET1^DIQ(100,ORIFN,.02,"I")
 I 'VFDDFN D  Q  ;
 . D SETTMP("No DFN",0)
 S X=$$PID(VFDDFN)
 I 'X D  Q  ;
 . S X="PID error. "_$P(X,"^",2,999)
 . D SETTMP(X,0)
 ; Loop through ORIFNs and build Order nodes
 S NUM=0
 F  S NUM=$O(VFDORLST(NUM)) Q:'NUM  D
 . S ORIFN=VFDORLST(NUM)
 . N NUM ;protect NUM
 . K VFDOUT,VFDDATA
 . ; Note, field 21600.01 not VA field
 . S X="@;1;5.1*;6;33;21600.01"
 . D GETS^DIQ(100,ORIFN,X,"IE","VFDOUT","","VFDMSG")
 . I '$D(VFDOUT) Q
 . M VFDDATA=VFDOUT(100,ORIFN_",")
 . M VFDDATA(100.051)=VFDOUT(100.051)
 . K VFDOUT
 . D SETTMP(ORIFN,ORIFN,"ORIFN")
 . ; MD
 . S X=$G(VFDDATA(1,"E"))_"^"_$G(VFDDATA(1,"I"))
 . D SETTMP(X,ORIFN,"MD") S VFDMD(+$$CLNUM($G(VFDDATA(6,"I"))),+$$INST(+$G(VFDDATA(21600.01,"I"))),$P(X,U,2),ORIFN)="" ;S VFDMD($P(X,U,2),ORIFN)=""
 . S X=$G(VFDDATA(1,"I")) ;#200 IEN
 . S X=$$NPI^VFDPSUTL(X)
 . D SETTMP(X,ORIFN,"MD NPI")
 . ; LOC
 . S X=+$G(VFDDATA(6,"I"))
 . S X=$$GET1^DIQ(44,X_",",21600.02,"E","","VFDMSG")
 . D SETTMP(X,ORIFN,"CLIENT ID")
 . S X=$G(VFDDATA(6,"I"))
 . I X'="" S X=+X
 . S X=$G(VFDDATA(6,"E"))_"^"_X
 . D SETTMP(X,ORIFN,"LOC")
 . ; REF LAB
 . S VFDRLAB1=0  ;innitialize needed variable for SETPFAC call
 . S VFDRLAB=$$GET1^DIQ(9999999.64,($G(VFDDATA(21600.01,"I"))_","),.01,"E")
 . S X=VFDRLAB_"^"_$G(VFDDATA(21600.01,"I"))
 . I X="^" D  ;set default if no VFDRLAB found
 . .D GETHFLAB(VFDDFN)  ;overwrites VFDDLIEN and VFDDLNAME if patient has default HF lab
 . .S X=$G(VFDDLNAME)_U_$G(VFDDLIEN),VFDRLAB=$G(VFDDLNAME),VFDRLAB1=1
 . .D SETPFAC($G(VFDDLIEN),ORIFN)  ;call to set the 21600.01 PERFORMING FACILITY field in file 100
 . D SETTMP(X,ORIFN,"REF LAB")
 . ; get diagnosis from CPRS order
 . K DIAG,VFDDIAG
 . S VFDDIAG=""
 . ; VFDDATA(100.051,"1,1,",.01,"E")="100.0"
 . I $D(VFDDATA(100.051)) D  ;
 . . S I=0
 . . F  S I=$O(VFDDATA(100.051,I)) Q:'I  D  ;
 . . . S X=$G(VFDDATA(100.051,I,.01,"E"))
 . . . S VFDDIAG=VFDDIAG_X_";"
 . ; VFDDIAG="1;2;3;"  (etc)
 . ; DX
 . S VFDDIAG=$$TRIM^XLFSTR(VFDDIAG,"R",";")
 . D SETTMP(VFDDIAG,ORIFN,"DX")
 . ; COLLECT
 . S X=$$VALUE^ORX8(ORIFN,"COLLECT",,"I")
 . D SETTMP(X,ORIFN,"COL TYP")
 . K VFDDATA
 . D GETMORE(ORIFN,VFDRLAB)
 K VFDDATA
 ; gather ORIFN info for new Order Group Number
 ;  VFDORDERGROUP(ORIFN)=recordLocator  (eg 3071102;2;1)
 S I=0
 S ORIFN=0
 F  S ORIFN=$O(VFDORDERGROUP(ORIFN)) Q:'ORIFN  D  ;
 . S I=I+1
 . S VFDDATA(I)=ORIFN
 . S VFDDATA(I,1)=VFDORDERGROUP(ORIFN) ;recLocator
 K VFDORDERGROUP,VFDOGN
 I '$D(VFDDATA) Q
 ;DSS/RAF if new RPC needed for print button, this is taken out
 ;  VFDDATA(i)=ORIFN      VFDDATA(i,1)=recLocator
 ; Create new Order Group
 S VFDOGN="" ;S VFDOGN=$$ORDERID^VFDOR(.VFDDATA,VFDEVENT)
 ; Add data nodes
 ;D SETTMP(VFDOGN,"PID","ORD ID")  ;not used by GUI, can be removed
 S I=0
 F  S I=$O(VFDDATA(I)) Q:'I  D  ;
 . S ORIFN=VFDDATA(I)
 . D SETTMP(VFDOGN,ORIFN,"ORD ID")
 D CLEAN^DILF
 K VFDLST
 Q
GETMORE(ORIFN,VFDRLAB) ;
 ; Get additional test level data
 ; Inputs
 ;    ORIFN: ORIFN
 ;  VFDRLAB: The Referral Lab name (external)
 N DIERR,I,IEN,NUM,R69,R6901,R6903
 N VFD10143,VFD10045,VFD60,VFDCPT,VFDGRP,VFDHL7V,VFDMSG
 N VFDOGN,VFDORDT,VFDWP,VFDREF
 S VFD10143=$$VALUE^ORX8(ORIFN,"ORDERABLE",,"I")
 S VFD60=$$GET1^DIQ(101.43,+VFD10143,2,"I","","VFDMSG")
 S VFD10045=$$GET1^DIQ(100,ORIFN,33,"I","","VFDMSG")
 S R69=$P(VFD10045,";",2)
 S R6901=$P(VFD10045,";",3)
 S R6903=0
 S VFDREF=""
 S VFDORDT=$$GET1^DIQ(100,ORIFN,4,"I","","VFDMSG")
 I R69 I R6901 D  ;
 . S R6903=$$OERR6903^VFDLAOGF(R69,R6901,"",ORIFN)
 . I 'R6903 S R6903=$O(^LRO(69,R69,1,R6901,2,"B",+VFD60,0))
 . S VFDREF=R69_";"_R6901_";"_R6903
 . S VFDORDERGROUP(ORIFN)=VFDREF
 . S IEN=R6903_","_R6901_","_R69_","
 . S X=$$GET1^DIQ(69.03,IEN,99,"","VFDWP","VFDMSG")
 . S I=0
 . F  S I=$O(VFDWP(I)) Q:'I  D  ;
 . . D SETTMP(VFDWP(I),ORIFN,"TEST CMT"_I)
 K VFDWP
 S X=$$GET1^DIQ(60,+VFD60,4,"I")
 D SETTMP(X,ORIFN,"SUB")
 ; get CPT code from National VA Lab Code
 S X=$$LABCPT(+VFD60,VFDORDT)
 S VFDCPT=""
 I X S VFDCPT=X
 D SETTMP(VFDCPT,ORIFN,"TEST CPT")
 S VFDHL7V=$$REFTEST(VFDRLAB,+VFD60)
 I $P(VFDHL7V,"^",1)'=0 D  ;
 . ; no $$TEST error
 . S X=$P(VFDHL7V,U,2,99)
 . D SETTMP(X,ORIFN,"TEST")
 . S X=$P(VFDHL7V,U,1)
 . D SETTMP(X,ORIFN,"TEST CODE")
 . S X=+$$GET1^DIQ(100,ORIFN,33,"I","VFDMSG")
 . D SETTMP(X,ORIFN,"TEST LRORD")
 . S X=$$GET1^DIQ(100,ORIFN,21,"E","VFDMSG")
 . D SETTMP(X,ORIFN,"TEST START")
 . S X=$$VALUE^ORX8(ORIFN,"SAMPLE",,"E")
 . D SETTMP(X,ORIFN,"TEST SAMP")
 E  D  ;
 . ; $$TEST error
 . S X=$$GET1^DIQ(60,+VFD60,.01,"E",,"VFDMSG")
 . D SETTMP(X,ORIFN,"TEST")
 . D SETTMP("",ORIFN,"TEST CODE")
 . S X=+$$GET1^DIQ(100,ORIFN,33,"I","VFDMSG")
 . D SETTMP(X,ORIFN,"TEST LRORD")
 . S X=$$GET1^DIQ(100,ORIFN,21,"E","VFDMSG")
 . D SETTMP(X,ORIFN,"TEST START")
 . S X=$$VALUE^ORX8(ORIFN,"SAMPLE",,"E")
 . D SETTMP(X,ORIFN,"TEST SAMP")
 Q
LABCPT(R60,ORDT) ;
 ; API to return the active CPT code for a lab test by
 ; getting the National VA code entry from file 60 and using it
 ; to get the CPT code associated with the NLT code in file 64
 ; Inputs
 ;    R60: #60 IEN
 ;   ORDT: Order Date FMDT
 ; Outputs
 ;   Returns the active CPT code for this order date  or  0 or null
 N VFDDATA,X
 S X=$$CPTINFO(R60,.VFDDATA)
 I 'X Q 0
 Q $$ACTVCPT(.VFDDATA,ORDT)
CPTINFO(R60,VFDOUT) ;
 ; Inputs
 ;      R60: #60 IEN
 ;   VFDOUT:<byref>  See Outputs
 ; Outputs
 ;   Returns 1 or 0^errNum^errMsg on error
 ;   VFDOUT(cpt)=cpt^inactiveFMDT^releaseFMDT^^type
 N CODE,CODES,DATA,DIERR,FLD,FLDS,I,IEN,NLT,STATUS
 N VFDDATA
 K VFDOUT
 S NLT=$$GET1^DIQ(60,R60,64,"I")
 I NLT="" Q "0^1^No NLT code found"
 S IEN=NLT_","
 K VFDDATA
 D GETS^DIQ(64,IEN,"18*","NRE","VFDDATA")
 I '$D(VFDDATA) Q "0^2^No CPT data available for NLT:"_$G(NLT)
 ; find all CODEs first
 K CODES
 S IEN=0
 F  S IEN=$O(VFDDATA(64.018,IEN)) Q:'IEN  D  ;
 . S CODE=$G(VFDDATA(64.018,IEN,"CODE","E"))
 . I CODE="" Q
 . S CODE=$P(CODE," ",1)
 . S CODES(IEN)=CODE
 S STATUS="0^3^No codes found"
 S IEN=0
 F  S IEN=$O(CODES(IEN)) Q:'IEN  D  ;
 . S STATUS=1
 . S CODE=CODES(IEN)
 . S VFDOUT(CODE)=CODE
 . S X=$G(VFDDATA(64.018,IEN,"INACTIVE DATE","I"))
 . S $P(VFDOUT(CODE),U,2)=X
 . S X=$G(VFDDATA(64.018,IEN,"RELEASE DATE","I"))
 . S $P(VFDOUT(CODE),U,3)=X
 . S X=$G(VFDDATA(64.018,IEN,"TYPE","I"))
 . S $P(VFDOUT(CODE),U,5)=X
 Q STATUS
ACTVCPT(VFDIN,ORDT) ;
 ; Compare order date against the inactive date to find the correct
 ; CPT code associated with the order at the time it was placed.
 ; Inputs
 ;    VFDIN:<byref>
 ;      VFDIN(cptCode)=cptCode^inactiveDate^releaseDate^type
 ;     ORDT:
 ; Outputs
 ;   null or the correct CPT code
 N CODE,INADT,REDT,CPT
 S ORDT=$G(ORDT)
 S CPT=""
 S CODE=0
 F  S CODE=$O(VFDIN(CODE)) Q:'CODE  D
 . S INADT=+$P(VFDIN(CODE),U,2)
 . S REDT=+$P(VFDIN(CODE),U,3)
 . I 'INADT S CPT=CODE
 . I ORDT'>0 Q
 . I ORDT<INADT I ORDT>REDT S CPT=CODE
 Q CPT
REFTEST(RLAB,R60) ;
 ; Inputs
 ;  RLAB:
 ;  R60: #60 IEN
 ; Outputs
 ;  Returns $$TRANS  or  "0^"_$P($$TRANS,"^",2,999) on error.
 N TBL,LIST,X
 I $T(TRANS^VFDHHLOT)="" Q 0
 ;S TBL=$S(RLAB="QUEST":"VXLRORDER",RLAB="THOMASON HOSPITAL":"VXLRORDER",1:"")  ;temporary VX101 -VXLRORDER
 ;I RLAB="THOMASON HOSPITAL" S RLAB="oldTHOMASON HOSPITAL"  ;temporary DEVPRE mod
 S X=$$TRANS^VFDHHLOT(RLAB,"VXLRORDER",R60,"HLT")
 ; fix for inconsistent error return values
 I X'?1"-1^"0.E D  ;
 . I X="DATA TRANSFORM ERROR" S X="-1^"_X Q
 . I X?0.E1" DATA TYPE NOT FOUND IN "0.E S X="-1^"_X Q
 . I X?1"-1_Table:"0.E S X="-1^"_$P(X,"_",2,999) Q
 I X?1"-1^"0.E D  ;
 . S X="0^"_$P(X,"^",2,999) I $G(VFDRLAB1)=1 D SETPFAC("@",ORIFN)  ;deletes performing lab entry in file 100
 ; removing the 21600.01 entry from 100 stops the test from going out in the ORM
 ; without a valid order code.
 Q X
SETTMP(VAL,SUB1,SUB2) ;
 S VAL=$G(VAL)
 S SUB1=$G(SUB1)
 S SUB2=$G(SUB2)
 I SUB2'="" S ^TMP("VFDLRLST-BLD",$J,SUB1,SUB2)=VAL Q
 S ^TMP("VFDLRLST-BLD",$J,SUB1)=VAL Q
 Q
PID(DFN) ;
 ; get primary diagnosis for the patient
 ; Inputs
 ;   DFN: Patient's DFN
 N VFDDATA,X
 K VFDDATA
 D DEM^VFDCDPT(.VFDDATA,DFN)
 I $G(VFDDATA)?1"-1^"0.E D  Q X
 . S X="0^1^"_$P(VFDDATA,"^",2,999)
 S X=$G(VFDDATA(1))
 D SETTMP(X,"PID","PAT NAME")
 S X=$G(VFDDATA(11))
 D SETTMP(X,"PID","PAT AD L1")
 S X=$G(VFDDATA(12))
 D SETTMP(X,"PID","PAT AD L2")
 S X=$G(VFDDATA(13))
 D SETTMP(X,"PID","PAT AD L3")
 S X=$G(VFDDATA(14))
 D SETTMP(X,"PID","PAT AD CITY")
 S X=$G(VFDDATA(15))
 D SETTMP(X,"PID","PAT AD STATE")
 S X=$G(VFDDATA(16))
 D SETTMP(X,"PID","PAT AD ZIP")
 S X=$P($G(VFDDATA(3)),";",2)
 D SETTMP(X,"PID","PAT DOB")
 S X=$G(VFDDATA(18))
 D SETTMP(X,"PID","PHONE #")
 S X=$P($G(VFDDATA(2)),";")
 D SETTMP(X,"PID","PAT SSN")
 Q 1
GETWP(FILE,IEN,FLD) ;
 ; Gets a WP field
 ; The "raw" data is stored in ^TMP(TMPNM-GETWP,$J,FILE,IENS,FLD)
 ; The formatted output will be in ^UTILITY($J,"W")
 N DATA,DIERR,NODE,STOP,TMP,TMPNM,VFDMSG,VFDWP,X
 K ^UTILITY($J,"W")
 S TMPNM="ZZFR002"
 S TMPNM=TMPNM_"-GETWP"
 S TMP=$NA(^TMP(TMPNM,$J))
 K ^TMP(TMPNM,$J)
 I $G(DIWL)="" N DIWL S DIWL=1
 I $G(DIWR)="" N DIWR S DIWR=$G(IOM,79)
 I $G(DIWF)["W" S X=DIWF N DIWF S DIWF=$TR(X,"W","")
 D GETS^DIQ(FILE,IEN,FLD,"I",TMP,"VFDMSG")
 ; return = ^TMP(TMPNM-GETWP,$J,FILE,IENS,FLD,x)=data
 I '$D(@TMP) Q
 ; go through ^TMP and use WP API to format
 S STOP=0
 S NODE=TMP
 F  S NODE=$Q(@NODE) Q:NODE=""  D  Q:STOP  ;
 . I $QS(NODE,1)'=TMPNM S STOP=1 Q
 . I $QS(NODE,2)'=$J S STOP=1 Q
 . I '$QS(NODE,6) S STOP=1 Q
 . S X=@NODE
 . D ^DIWP
 Q
SETTMP2(VAL,SUB) ;
 Q
 S VAL=$G(VAL)
 S SUB=$G(SUB)
 I 'SUB S SUB=$O(^TMP("VFDLRLST-OUT",$J,"A"),-1)+1
 S ^TMP("VFDLRLST-OUT",$J,SUB)=VAL
 Q
STATUS(VFDORLST) ; screens out all but pending orders
 ; file 100.01 - PENDING=5
 N CNT,NUM,ORIFN,STATUS
 S CNT=1
 S NUM=0 F  S NUM=$O(VFDORLST(NUM)) Q:'NUM  D
 . S ORIFN=VFDORLST(NUM),STATUS=$$GET1^DIQ(100,ORIFN_",",5,"I",)
 . I STATUS=5 S VFDLST(CNT)=ORIFN,CNT=CNT+1,VFDRL(ORIFN)=""
 K STATUS
 Q
GRPCHK(VFDREL) ; for reprints, check to see if any tests have
 ; not been selected that were part of other print/reprint order
 ; groups
 ; If the array comes back empty allow the code to continue
 ; If the array has value, create the $START INFO section and
 ; add it to the end of VFDOUT. Also set an error value
 N IEN,NUM,ORIFN,STATUS,X
 S ORIFN=0 F  S ORIFN=$O(VFDREL(ORIFN)) Q:'ORIFN  D
 . Q:$D(VFDRL(ORIFN))
 . I $$GET1^DIQ(100,ORIFN_",",5,"I",)=5 D
 . . S IEN="1,"_ORIFN_","
 . . S X=$$GET1^DIQ(100.008,IEN,.1,"I","VFDTXT","VFDMSG")
 . . S VFDMISS(ORIFN)=ORIFN_U_$G(VFDTXT(1))
 K VFDREL,VFDTXT,X
 Q
ADDTO(VFDMISS) ; add missing test info to end of VFDOUT array
 N NUM,NEXT
 S NUM=$O(VFDOUT(""),-1)
 S VFDOUT(NUM)="$START INFO",NUM=NUM+1
 S NEXT=0 F  S NEXT=$O(VFDMISS(NEXT)) Q:'NEXT  D
 . S VFDOUT(NUM)=VFDMISS(NEXT),NUM=NUM+1
 S VFDOUT(NUM)="$END INFO",NUM=NUM+1
 S VFDOUT(NUM)="$END FORM"
 Q
ORDID(VFDMD) ; get order ID for each doctors order group
 N CNT,MD,NUM,NUM1
 S CNT=1
 S NUM=0 F  S NUM=$O(VFDMD(NUM)) Q:'NUM  D  D GETID(.VFDX,MD)
 . S MD=NUM S NUM1=0 F  S NUM1=$O(VFDMD(NUM,NUM1)) Q:'NUM1  D
 . . S VFDX(CNT)=NUM1,CNT=CNT+1
 K VFDX
 Q
UPDATE(VFDOUT) ; called to create VFD1() to be used to update ORD ID in VFDOUT
 N NUM,MD
 S NUM=0 F  S NUM=$O(VFDOUT(NUM)) Q:'NUM  D
 . I $G(VFDOUT(NUM))["MD^" S MD=$P(VFDOUT(NUM),U,3) S VFD1(MD,"MD",NUM)=""
 . I $G(VFDOUT(NUM))["ORD ID^" S VFD1(MD,"ORD ID",NUM)=""
 . I $G(VFDOUT(NUM))["ORIFN^" S VFD1(MD,"ORIFN",NUM)=$P(VFDOUT(NUM),U,2),VFDID($P(VFDOUT(NUM),U,2),NUM-1)=""
 . I $G(VFDOUT(NUM))["SUB^" S VFD1(MD,"SUB",NUM)=$P(VFDOUT(NUM),U,2)
 Q
GETID(VFDX,MD) ; set each physicians order group number
 S VFDX1(MD)=$$ORDERID^VFDOR(.VFDX,VFDEVENT)  ;NUM changed to MD
 N NXT,SEQ
 S NXT=0 F  S NXT=$O(VFDX(NXT)) Q:'NXT  D
 . S SEQ=$O(VFDID(VFDX(NXT),0))
 . S VFDOUT(SEQ)="ORD ID"_U_$S(+VFDX1(MD)>0:VFDX1(MD),1:"") ;don't store error message for not creating group ID
 K VFDX
 Q
CLNUM(LOC) ;resolve Quest client number for VFDMD array - ADDED 4/29/10
 N CLNUM,IENS
 S IENS=+LOC
 S CLNUM=+$$GET1^DIQ(44,IENS,21600.02,"I","VFDMSG")
 ;set default if no number found?
 I CLNUM=0 Q 1
 Q CLNUM
INST(X) ;
 N R4,RLAB
 S RLAB=+$$GET1^DIQ(9999999.64,+$G(VFDDATA(21600.01,"I"))_",",.01,"E","VFDMSG")
 S R4=$$LKUP^XUAF4(+RLAB)
 I R4=0 Q 1
 Q R4
NWSORT(VFDMD) ; resort by MD and client # then call ORDID
 ;VFDMD(CLIENT #,INST IEN,MD,ORIFN)
 N CN,CNT,LAB,MD,NUM,NUM1,ORD,VFDX
 S CNT=1
 S CN=0 F  S CN=$O(VFDMD(CN)) Q:'CN  D
 . S LAB=0 F  S LAB=$O(VFDMD(CN,LAB)) Q:'LAB  D
 . . S MD=0 F  S MD=$O(VFDMD(CN,LAB,MD)) Q:'MD  D  D GETID(.VFDX,MD) S CNT=1  ;reset cnt between groups
 . . . S ORD=0 F  S ORD=$O(VFDMD(CN,LAB,MD,ORD)) Q:'ORD  D
 . . . . ;S VFDXS(MD,LAB,CN,ORD)=""
 . . . . S VFDX(CNT)=ORD,CNT=CNT+1
 K VFDX
 Q
SETPFAC(VFDVAL,ORIFN) ; sets up and makes fileman call to delete the PERFORMING FACILITY (#21600.01)
 ; entry after it is determined that no order code was found in the 
 ; HL7 exchange table
 N VFDORFDA
 S VFDORFDA(100,ORIFN_",",21600.01)=VFDVAL
 L +^OR(100,ORIFN,21600):10
 D FILE^DIE(,"VFDORFDA","VFDMSG")
 L -^OR(100,ORIFN,21600)
 Q
GETHFLAB(VFDDFN) ; if available, set default reference lab as identified by
 ; the health factor entry for the patient
 N NEXT,NODE,VFDHF
 D HFLAB^VFDOR(.VFDHF,VFDDFN)
 S NEXT="" F  S NEXT=$O(VFDHF(NEXT)) Q:NEXT=""  D
 . I $P(VFDHF(NEXT),U,3)]"" S NODE=$G(VFDHF(NEXT)) D
 . . S VFDDLIEN=$P(NODE,U),VFDDLNAME=$$GET1^DIQ(9999999.64,VFDDLIEN_",",.01,"E","VFDERR")
 Q
