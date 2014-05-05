VFDUOGF ;DSS/JDB - ORDER GROUP FILE UTILITIES ;23 Nov 2010 10:04
 ;;2011.1.2;DSS,INC VXVISTA OPEN SOURCE;;28 Jan 2013;Build 25
 ;Copyright 1995-2013,Document Storage Systems Inc. All Rights Reserved
 ;
 ;        EN^XPAR/2263
 ;     FIND1^DIC/2051
 ;      GET1^DIQ/2056
 ;       GET^XPAR/2263
 ;    UPDATE^DIE/2053
 ;
 Q
 ;
 ;
ADDGROUP(VFDIDS,EVENT) ;
 ; Add new Order Groups (File #21695) entry
 ; Inputs
 ;   VFDIDS:<byref><opt> Array of IDs for this group.
 ;      VFIDS(0,5,Related Group Number)=""  <opt>
 ;      VFIDS(ID)=""
 ;      VFIDS(ID,1)=Record Locator
 ;      VFIDS(ID,2)=#9.4 IEN
 ;      VFIDS(ID,2.4)=Created reason (defaults to 1)
 ;    EVENT: Event code
 ; Outputs
 ;  Returns the #21695 IEN and Group Number (w checksum)
 ;      eg  1^123455
 N DATA,DIERR,VFDMSG,VFDFDA,NUM,OGN,VFDIEN,VFDRELATED,I,ID,IEN,X
 S EVENT=+$G(EVENT)
 I EVENT<0 S EVENT=0
 F  L +^VFD(21695,0):10 Q:$T
 S NUM=$$MAKENUM()
 S NUM=NUM_$$VHCSUM^VFDUCSUM(NUM)
 S VFDFDA(1,21695,"?+1,",.01)=NUM
 S VFDFDA(1,21695,"?+1,",.04)=EVENT
 D UPDATE^DIE("","VFDFDA(1)","VFDIEN","VFDMSG")
 S VFDIEN=+$G(VFDIEN(1))
 L -^VFD(21695,0)
 ; Adding ID info
 I VFDIEN I $D(VFDIDS) D  ;
 . F  L +^VFD(21695,VFDIEN):10 Q:$T
 . S OGN=^VFD(21695,VFDIEN,0)
 . S OGN=$P(OGN,"^",1)
 . I $D(VFDIDS(0,5)) D  ;
 . . ; Add Related Group Numbers
 . . S I=0
 . . K DIERR,VFDFDA,VFDMSG
 . . S X=""
 . . F  S X=$O(VFDIDS(0,5,X)) Q:X=""  D  ;
 . . . I X=OGN Q
 . . . I '$O(^VFD(21695,"B",X,0)) Q
 . . . S I=I+1
 . . . S IEN="?+"_I_","_VFDIEN_","
 . . . S VFDFDA(1,21695.0002,IEN,.01)=X
 . . ;
 . . I $D(VFDFDA) D  ;
 . . . D UPDATE^DIE("","VFDFDA(1)","","VFDMSG")
 . . ;
 . ;
 . ; Set IDs
 . S ID=0
 . K VFDRELATED
 . F  S ID=$O(VFDIDS(ID)) Q:ID=""  D  ;
 . . S X=$O(^VFD(21695,"AE",ID,0)) ; 1st group number
 . . I X I X'=OGN S VFDRELATED(X)=""
 . . K DIERR,VFDFDA,VFDMSG
 . . S IEN="?+1,"_VFDIEN_","
 . . S VFDFDA(1,21695.0001,IEN,.01)=ID
 . . S X=$G(VFDIDS(ID,1))
 . . I X'="" S VFDFDA(1,21695.0001,IEN,1)=X
 . . S DATA=$G(VFDIDS(ID,2))
 . . S X=$P(DATA,"^",1)
 . . I X'="" S VFDFDA(1,21695.0001,IEN,2)=X
 . . S X=$G(VFDIDS(ID,2.4),1)
 . . S VFDFDA(1,21695.0001,IEN,2.4)=X
 . . D  ;
 . . . N I
 . . . D UPDATE^DIE("","VFDFDA(1)","","VFDMSG")
 . . ;
 . ;
 . ; Add Related Groups for non-order events
 . I '$D(VFDIDS(0,5)) I EVENT>1 D  ;
 . . K VFDFDA
 . . S I=0
 . . S X=""
 . . F  S X=$O(VFDRELATED(X)) Q:X=""  D  ;
 . . . I X=OGN Q
 . . . I '$O(^VFD(21695,"B",X,0)) Q
 . . . K DIERR,VFDFDA,VFDMSG
 . . . S I=I+1
 . . . S IEN="?+"_I_","_VFDIEN_","
 . . . S VFDFDA(1,21695.0002,IEN,.01)=X
 . . . ;
 . . I $D(VFDFDA) D  ;
 . . . D UPDATE^DIE("","VFDFDA(1)","","VFDMSG")
 . . ;
 . ;
 . L -^VFD(21695,VFDIEN)
 ;
 I $Q Q +VFDIEN_"^"_NUM
 Q
 ;
 ;
ADDID(R21695,VFDID) ;
 ; Add an ID to an existing Order Group Entry.
 ; Inputs
 ;   R21695: #21695 IEN
 ;    VFDID:<byref> Data array:
 ;       VFID(ID)="" (required)
 ;       VFID(ID,1)=Record Locator
 ;       VFID(ID,2)=#9.4 IEN (required)
 ;       VFDID(ID,2.4)=Created Reason (defaults to zero)
 ; Outputs
 ;  #61295.001 IEN or "0^err num^err msg"
 N ID,DIERR,IEN,STATUS,VFDMSG,VFDIEN,VFDIENS,X
 S R21695=$G(R21695)
 I R21695'>0 Q "0^1^Invalid record #"
 I '$D(^VFD(21695,R21695)) Q "0^2^Record does not exist"
 S ID=$O(VFDID(0))
 I ID="" Q "0^3^No ID specified"
 I '$G(VFDID(ID,2)) Q "0^4^No PACKAGE IEN specified"
 S IEN="?+1,"_R21695_","
 S VFDIEN(1,21695.0001,IEN,.01)=ID
 S VFDIEN(1,21695.0001,IEN,1)=$G(VFDID(ID,1))
 S VFDIEN(1,21695.0001,IEN,2)=VFDID(ID,2)
 S VFDIEN(1,21695.0001,IEN,2.4)=$G(VFDID(ID,2.4),0)
 F  L +^VFD(21695,R21695):10 Q:$T
 D UPDATE^DIE("","VFDIEN(1)","VFDIENS","VFDMSG")
 L -^VFD(21695,R21695)
 S STATUS=$G(VFDIENS(1))
 I 'STATUS S STATUS="0^5^FileMan error"
 Q STATUS
 ;
 ;
MAKENUM() ;
 ; Creates the Order Group number for file #21695 field .01
 ; Private method
 ; Outputs
 ;   Returns Order Group number (without check digit)
 ;   Also updates the PARAMETER file entry.
 N NUM,X,I
 S NUM=0
 F  L +^VFD(21695,0):10 Q:$T
 F  L +^XTV(8989.51,"B","VFD ORDER GROUP NUMBER"):10 Q:$T
 ;
 ; Check PARAMETER
 S X=$$GETPARAM()
 I X>0 D  ;
 . S I=$O(^VFD(21695,"AC","A"),-1) ;last number
 . I X<I S X=I
 . F  S X=X+1  D  Q:NUM  ;
 . . I '$D(^VFD(21695,"AC",X)) S NUM=X
 . ;
 ;
 ; If no PARAMETER entry, get last used # from file.
 I 'NUM D  ;
 . S X=$O(^VFD(21695,"AC","A"),-1)
 . Q:'X
 . S NUM=X+1
 ;
 ; If still no number, use starting point
 I 'NUM D  ;
 . S NUM=12543
 ;
 D SETPARAM(NUM)
 L -^XTV(8989.51,"B","VFD ORDER GROUP NUMBER")
 L -^VFD(21695,0)
 Q NUM
 ;
 ;
GETPARAM() ;
 ; Check PARAM file for last group #
 ; Private method
 Q $$GET^XPAR("SYS","VFD ORDER GROUP NUMBER",1,"Q")
 ;
 ;
SETPARAM(NUM) ;
 ; Sets PARAM file to this group NUM
 ; Private method
 N ERR
 D EN^XPAR("SYS","VFD ORDER GROUP NUMBER",1,NUM,.ERR)
 Q
 ;
 ;
GETIDS(GPNUM,OUT) ;
 ; Return array of IDs (OERR #s) for this Order Group number.
 ; Inputs
 ;   GPNUM: Group Order number
 ;     OUT:<byref> See Outputs
 ; Outputs
 ;   Returns the number of IDs for this Order Group or zero
 ;   OUT(0,21695)= #21695 IEN
 ;   OUT(id)=num   where num is ID's subfile IEN
 ;   OUT(id,2)=PKG IEN
 ;   OUT(id,10)=record locator (field #10)
 N CNT,DATA,R21695,REC2,NODE,STOP,X
 S GPNUM=$G(GPNUM)
 K OUT
 S R21695=$O(^VFD(21695,"B",GPNUM,0))
 I 'R21695 Q "0^1^Not found"
 S OUT(0,21695)=R21695
 ; Loop thru IDs
 ; ^VFD(21695,DA1,10,"B",id,DA)=""
 S NODE="^VFD(21695,R21695,10,""B"")"
 S (CNT,STOP)=0
 F  S NODE=$Q(@NODE) Q:NODE=""  D  Q:STOP
 . I $QS(NODE,4)'="B" S STOP=1 Q
 . I $QS(NODE,3)'=10 S STOP=1 Q
 . I $QS(NODE,2)'=R21695 S STOP=1 Q
 . I $QS(NODE,1)'=21695 S STOP=1 Q
 . S CNT=CNT+1
 . S X=$QS(NODE,5)
 . S OUT(X)=$QS(NODE,6)
 . S REC2=$QS(NODE,6) ;IEN #2
 . S DATA=$G(^VFD(21695,R21695,10,REC2,1)) ;Record Locator
 . S X=$QS(NODE,5)
 . S OUT(X,10)=DATA
 . S DATA=$G(^VFD(21695,R21695,10,REC2,2))
 . S OUT(X,2)=$P(DATA,U,1) ;PKG IEN
 ;
 Q CNT
 ;
 ;
GETPKG(IN) ;
 ; Returns the PACKAGE (#9.4) IEN or name, dependant on
 ; input type.
 ; Inputs
 ;   IN:<req>   Numeric (IEN) or non-numeric (package name)
 ; Outputs
 ;   If IN was numeric, will return the .01 field.
 ;   If IN was non-numeric, will return IEN of #9.4 entry.
 ;   If not found, returns zero.
 N VFDMSG,DIERR
 S IN=$G(IN)
 I IN'=+IN Q +$$FIND1^DIC(9.4,"","CO",IN,"B","","VFDMSG")
 Q $$GET1^DIQ(9.4,IN_",",.01,"I","","VFDMSG")
 ;
 ;
GNUMDATA(NUM,ID,FLAGS,VFDOUT) ;
 ; Returns data elements for an entire Order Group Number
 ; or just an ID in an Order Group.
 ;  VFDOUT(NUM)=""
 ;  VFDOUT(NUM,0)=#21695 IEN^Date Created^Created By (DUZ)^Event (num)
 ;  VFDOUT(NUM,5,NUMa)="" (Related Groups)
 N R21695,DATA,STATUS
 S NUM=$G(NUM)
 S ID=$G(ID)
 S FLAGS=$G(FLAGS)
 K VFDOUT
 S STATUS=0
 S R21695=$O(^VFD(21695,"B",NUM,0))
 I 'R21695 Q 0
 S DATA=$G(^VFD(21695,R21695,0))
 S X=R21695_"^"_$P(DATA,U,2,4)
 S VFDOUT(NUM)=""
 S VFDOUT(NUM,0)=X
 ; Related Groups
 S X=""
 F  S X=$O(^VFD(21695,R21695,5,"B",X)) Q:X=""  D  ;
 . S VFDOUT(NUM,5,X)=""
 ;
 ; IDs
 S ID=""
 F  S ID=$O(^VFD(21695,R21695,10,"B",ID)) Q:ID=""  D  ;
 . S VFDOUT(NUM,10,ID)=""
 . K DATA
 . S X=$$IDDATA(NUM,ID,.DATA)
 . M VFDOUT=DATA
 . K DATA
 ;
 I $Q Q R21695
 Q
 ;
 ;
IDDATA(NUM,ID,VFDOUT) ;
 ; Returns data array for an individual ID in an Order Group
 ; Inputs
 ;      NUM: Order Group number
 ;       ID: Order Group ID
 ;   VFDOUT:<byref>  See Outputs
 ; Outputs
 ;   Returns 0 on error  or  #21695 ien_^_#21695.0001 ien
 ;     VFDOUT(NUM,10,ID,1)=Record Locator
 ;     VFDOUT(NUM,10,ID,2)=#9.4 IEN
 N R21695,R216950001,DATA
 S NUM=$G(NUM)
 S ID=$G(ID)
 K VFDOUT
 S R21695=$O(^VFD(21695,"B",NUM,0))
 I 'R21695 Q:$Q "0^1" Q
 S R216950001=$O(^VFD(21695,R21695,10,"B",ID,0))
 I 'R216950001 Q:$Q "0^2" Q
 S VFDOUT(NUM,10,ID)=""
 S X=$G(^VFD(21695,R21695,10,R216950001,1))
 S VFDOUT(NUM,10,ID,1)=X
 S DATA=$G(^VFD(21695,R21695,10,R216950001,2))
 S VFDOUT(NUM,10,ID,2)=$P(DATA,U,1)
 I $Q Q R21695_"^"_R216950001
 Q
 ;
 ;
FINDGRP(IDS) ;
 ; Find the group number for these IDs
 ; Inputs
 ;  IDS:<byref>
 ;     :  IDS(id,2)=#9.4 IEN
 ; Outputs
 ;    The Order Group number or null.
 ;
 ;  1) Loop through all passed IDs and get the group number(s)
 ;     for each ID (from the 'AE' xref.
 ;  2) Pick one of the IDs.  Loop through all of its Group Numbers 
 ;     (backwards to start with most recent) and then check that
 ;     all other IDs passed in have that group number also.
 ;     If they dont, that Group Number is removed from the list.
 ;  3) Now that we have a list of all related Group Numbers for
 ;     the IDs passed in, we need to check if any of those
 ;     group numbers have other lab IDs on them.  If so, they
 ;     dont qualify as an associated group.
 ;  4) Last, get the most recent (highest numbered) Group Number
 ;     from the list generated and return.
 N ID,ID1,IDGROUPS,GNUM,GROUP,GROUPS,NODE,R94,STOP,STOP2
 S ID=""
 S GROUP=0
 F  S ID=$O(IDS(ID)) Q:ID=""  D  ;
 . S R94=$G(IDS(ID,2))
 . I 'R94 Q
 . S NODE=$NA(^VFD(21695,"AE",ID))
 . ; build GROUPS array
 . S STOP=0
 . F  S NODE=$Q(@NODE) Q:NODE=""  D  Q:STOP  ;
 . . S X=$$IDGROUPS(ID,1,.IDGROUPS)  ; IDGROUPS(id,GroupNum)=""
 . ;
 . ; all IDs
 ;
 S (ID,ID1)=$O(IDS("")) ;pick one ID
 S GNUM=""
 S (STOP,GROUP)=0
 ; go backwards to check the most current group first
 F  S GNUM=$O(IDGROUPS(ID1,GNUM),-1) Q:GNUM=""  D  Q:STOP  ;
 . S GROUPS(GNUM)=""
 . S ID=ID1
 . S STOP2=0
 . ; check if all IDs have this group number
 . F  S ID=$O(IDS(ID)) Q:ID=""  D  Q:STOP2  ;
 . . S R94=$G(IDS(ID,2))
 . . I 'R94 Q
 . . I '$D(IDGROUPS(ID,GNUM)) K GROUPS(GNUM) S STOP2=1 Q
 . . I $D(IDGROUPS(ID,GNUM)) S GROUPS(GNUM)=""
 . ;
 ; We now have a list of all group numbers these IDs have in
 ; common contained in GROUPS array.  GROUPS(GroupNumber)=""
 ; Now we have to check if any of these groups have more IDs
 ; than the ones we have.  If a group does, then its not the
 ; group we want.
 S STOP=0
 S GNUM=""
 S R94=$$GETPKG("LAB SERVICE")
 F  S GNUM=$O(GROUPS(GNUM),-1)  Q:GNUM=""  D  Q:STOP
 . K OUT
 . S X=$$GETIDS(GNUM,.OUT)
 . I 'X K GROUPS(GNUM) Q
 . S R21695=$O(^VFD(21695,"B",GNUM,0))
 . I 'R21695 K GROUPS(GNUM) Q
 . ; check all IDs (that are LAB) in this group
 . S ID=""
 . F  S ID=$O(OUT(ID)) Q:ID=""  D  ;
 . . S R2=OUT(ID) ;subfile IEN
 . . S DATA=$G(^VFD(21695,R21695,10,R2,2))
 . . S X=$P(DATA,U,1) ;#9.4 IEN
 . . I X'=R94 Q
 . . I '$D(IDS(ID)) K GROUPS(GNUM) Q
 . ;
 . I $D(GROUPS(GNUM)) S STOP=1
 ;
 Q GNUM
 ;
 ;
IDGROUPS(ID,FLAGS,OUT) ;
 ; Returns a list of group numbers for this ID
 ; Inputs
 ;     ID: ID
 ;  FLAGS:
 ;    OUT:<byref> See Outputs
 ; Outputs
 ;     OUT(Group Number)=""
 ;     If FLAG=1 then :
 ;          OUT(ID,Group Number)="" (and OUT isnt initialized)
 N CNT,GNUM
 S ID=$G(ID)
 S FLAGS=$G(FLAGS)
 I FLAGS'[1 K OUT
 S GNUM=""
 S CNT=0
 F  S GNUM=$O(^VFD(21695,"AE",ID,GNUM)) Q:GNUM=""  D  ;
 . I FLAGS="" S OUT(GNUM)=""
 . I FLAGS=1 S OUT(ID,GNUM)=""
 . S CNT=CNT+1
 ;
 Q CNT
 ;
 ;
ADDREL(OGN,RELATED) ;
 ; Add related Order Groups to an existing Order Group Number
 ; Inputs
 ;      OGN: Order Group Number
 ;  RELATED:<byref> Array of related Order Group Numbers
 ;         :  eg  RELATED(orderGroupNumber)=""
 ; Outputs
 ;  Returns 1^count  OR   0^errNum^errMsg  on error.
 N DIERR,I,IEN,R21695,STATUS,VFDFDA,VFDMSG,X
 S OGN=$G(OGN)
 S R21695=$O(^VFD(21695,"B",OGN,0))
 I 'R21695 Q:$Q "0^1^Order Group Number not found" Q
 S I=0
 S X=""
 F  S X=$O(RELATED(X)) Q:X=""  D  ;
 . I X=OGN Q
 . I '$O(^VFD(21695,"B",X,0)) Q
 . S I=I+1
 . S IEN="?+"_I_","_R21695_","
 . S VFDFDA(1,21695.0002,IEN,.01)=X
 . ;
 ;
 S STATUS="0^2^Nothing to add"
 I $D(VFDFDA) D  ;
 . S STATUS="1^"_I
 . D UPDATE^DIE("","VFDFDA(1)","","VFDMSG")
 . I '$D(VFDMSG) Q
 . N I,STR,VFDERR
 . D MSG^DIALOG("AEHM",.VFDERR,"","","VFDMSG")
 . S STR=""
 . S I=0
 . F  S I=$O(VFDERR(I)) Q:'I  D  ;
 . . S STR=STR_VFDERR(I)_" "
 . ;
 . S STR=$TR(STR,"^","~")
 . S STR=$$TRIM^XLFSTR(STR)
 . I STR="" S STR="FileMan error"
 . S STATUS="0^4^"_STR
 ;
 I $Q Q STATUS
 Q
