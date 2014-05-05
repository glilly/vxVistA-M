VFDXPDL ;DSS/SMP - PATCH UTIL AND INSTALL FILE ; 02/28/2013 10:45
 ;;3.1;DSS,INC VXVISTA SUPPORTED;;10 Dec 2012;Build 58
 ;Copyright 1995-2012,Document Storage Systems Inc. All Rights Reserved
 ;
 Q
 ;
8 ; Load Option
 N X,EXCEP,VFDKID S X=$$REPORTS(1) Q:X=-1
 I '$$DIR^VFDXPD0(12) Q
 D 8^VFDXPDJ
 Q
 ;
15 ; Load Reports
 N X,EXCEP,VFDKID S X=$$REPORTS Q:X=-1  D CNT
 Q
 ;
REPORTS(LOAD) ; check and load patches from a designated path
 N X,BATCH,ERR,INST,KIDS,LOW,MAX,NAME,NEW,QUIT,RAN,REQ,SEQE,SEQI
 W !!! D BATCH^VFDXPDG2(PID,,$G(FLAG)) I '$D(BATCH) D WR(1),CNT Q 0
 Q:$$CHECK<1 -1
 S MAX=$$DIR I MAX<0 Q 0
 S MAX=MAX-1 W !!,"Processing."
 S EXCEP=0
 S NAME="" F  S NAME=$O(BATCH("B",NAME)) Q:NAME=""  D INSTCHK(NAME)
 I $G(ERR) D  Q
 .S X=0 F  S X=$O(ERR(X)) Q:'X  W ERR(X),!
 F  D  Q:$G(QUIT)
 .W "."
 .N REQ,SEQI,SEQE,LOW
 .S QUIT=$$PROCESS(.INST,3) K INST
 .I $G(LOAD),'$G(RAN),$L(PATH) D  Q:$G(QUIT)
 ..D FILECHK I $D(NAME)!$D(KIDS) D  Q:$G(QUIT)  S RAN=1
 ...S QUIT=$$PROCESS(.NAME,8) Q:$G(QUIT)
 ...S QUIT=$$PROCESS(.KIDS,7) Q:$G(QUIT)
 .D GETREQ(.REQ) S QUIT=$$PROCESS(.REQ,4) Q:$G(QUIT)  W "."
 .D SEQINT(.SEQI) S QUIT=$$PROCESS(.SEQI,5) Q:$G(QUIT)  W "."
 .D SEQEXT(.LOW,.SEQE) S QUIT=$$PROCESS(.SEQE,6) Q:$G(QUIT)  W "."
 .I '$D(REQ),'$D(SEQI),'$D(SEQE) S QUIT=1
 D UPDATE
 S X=$$SUMMARY(.NEW) Q:'X 0 I EXCEP>MAX D WR(2) Q 0
 Q 1
 ;
 ;=============================================================
 ;            P R I V A T E   S U B R O U T I N E S
 ;=============================================================
 ;
ADD(IEN,PIECE) ; Add build to batch
 ;;Required by patches in the batch
 ;;Missing sequence numbers within the batch
 ;;Previous sequence numbers
 ;;
 N FLDS,ZZ,OUT,NM,PKG,VER,SEQ
 S FLDS=".01;.04;.05;.06;.061;.07;.1;.11;.12;.15;.16;.18;.9"
 S IEN=IEN_",",ZZ=$NA(OUT(21692,IEN))
 S OUT=$$GETS^VFDXPDA("OUT",21692,IEN,FLDS,"I")
 I +OUT=-1 Q
 D BATCH1^VFDXPDG2(+IEN,.OUT)
 S BATCH=BATCH+1,EXCEP=1+EXCEP,ZZ=BATCH(+IEN)
 S NM=$E($P(ZZ,U),1,30),PKG=$P(ZZ,U,5),VER=$P(ZZ,U,6),SEQ=+$P(ZZ,U,2)
 I $G(NEW(PKG,VER,SEQ))'="" D  Q
 .S $P(NEW(PKG,VER,SEQ),U,PIECE)="  X   "
 S $P(NM,U,2)=SEQ,$P(NM,U,PIECE)="  X   ",NEW(PKG,VER,SEQ)=NM
 Q
 ;
CHECK() ;
 N DATE,DIR,EX,NMSP,OUT,RET,SERVER
 S OUT=$$GETS^VFDXPDA("OUT",21692.1,PID,".04:.07","I") Q:OUT<0 0
 S SERVER=OUT(21692.1,PID_",",.04,"I")
 I $T(SRVNAME^VFDVMOS)'="" S SERVER(1)=$$SRVNAME^VFDVMOS
 S SERVER(1)=$G(SERVER(1))
 S NMSP=OUT(21692.1,PID_",",.05,"I")
 I $T(CUR^VFDVMOS)'="" S NMSP(1)=$$CUR^VFDVMOS
 S NMSP(1)=$G(NMSP(1))
 S DATE=OUT(21692.1,PID_",",.06,"I")
 S EX=OUT(21692.1,PID_",",.07,"I")
 I 'DATE D
 .W "Load Report has not been ran for this batch before"
 E  D
 .W !!!,"Load Report last ran for "_PID(0)_" on "_$$FMTE^XLFDT(DATE),!!
 .W "Server:      "_SERVER I SERVER'=SERVER(1) D
 ..W ?30,"** Different Server **"
 .W !,"Namespace:   "_NMSP I NMSP'=NMSP(1) D
 ..W ?30,"** Different Namespace **"
 .W !,"Exceptions:  "_+EX,!!
 .I EX["*" D WR(3)
 W ! S DIR(0)="Y",DIR("A")="Would you like to run the load report"
 S DIR("B")="YES" S RET=$$DIR^VFDXPDA(.DIR)
 Q RET
 ;
CNT ;
 S DIR(0)="E" S DIR=$$DIR^VFDXPDA(.DIR) I DIR<0 Q 0
 Q 1
 ;
DIR() ;
 ;;There are potentially many discrepancies in this batch and this report
 ;;could take a lot longer to process than anticipated.  In order to reduce
 ;;this time, please enter the max number of exceptions to find before 
 ;;halting this utility.
 ;;  
 N DIR,X,Y
 S DIR(0)="N^10:1000000:0"
 S DIR("A")="Stop processing after how many exceptions?"
 S DIR("B")=50
 W !! F X=1:1:4 W $TR($T(DIR+X),";"," "),!
 W !
 Q $$DIR^VFDXPDA(.DIR)
 ;
FILECHK ;
 ; checks the patches in the KID files compared to those in the batch
 ; if there are "extra" patches in the KID files, report that
 ;
 N X,Y,Z,I,C,CNT,FILE,IN,IOPAR,IOUPAR,LIST,OPEN,POP,TEMP
 D LIST^VFDXPDC(PATH,,.LIST) M NAME=BATCH("B")
 S X="" F  S X=$O(LIST(X)) Q:X=""  I $$UP^VFDXPD0(X)'[".KID" K LIST(X)
 S X="NAME" F  S X=$Q(@X) Q:X=""  S Y=$P(BATCH(@X),U,9) I 'Y!(Y=3) K @X
 S FILE="" F C=1:1 S FILE=$O(LIST(FILE)) Q:FILE=""  D
 .Q:$$UP^VFDXPD0(FILE)'["KID"
 .N L1,L2,L3,TEMP
 .W:C#50=0 "."
 .S OPEN=$$OPEN^VFDXPDC(PATH,FILE,"OUTPUT","R")
 .U IO R L1:DT,L2:DT,L3:DT
 .I L3'["**KIDS**" D CLOSE^VFDXPDC("OUTPUT"),WR(1,FILE) S VFDERR=1 Q
 .F I=1:1 U IO R TEMP(I):DT Q:TEMP(I)=""
 .D CLOSE^VFDXPDC("OUTPUT") U IO
 .D FILECHK1
 I $D(BATCH("C","LEX")) S X="" F  S X=$O(NAME(X)) Q:X=""  D
 .S TEMP=BATCH(NAME(X)),IN=$P(TEMP,U,11) Q:IN=""!(IN=NAME(X))
 .I $P(TEMP,U,9)=2,$P($G(BATCH($P(TEMP,U,11))),U)["LEX" D
 ..I $D(KIDS($P($G(BATCH($P(TEMP,U,11))),U))) K NAME(X),KIDS(X)
 S X="" F  S X=$O(KIDS(X)) Q:X=""  D
 .I $D(NAME(X)) D SET(KIDS(X)) K KIDS(X),NAME(X) Q
 .N IEN,SEQ S IEN=$$GETIEN^VFDXPDG2(X) S:IEN KIDS(IEN)=""
 .K KIDS(X)
 S X="" F  S X=$O(NAME(X)) Q:X=""  S NAME(NAME(X))="" K NAME(X)
 Q
 ;
 ;
FILECHK1 ;
 ; L3 should be defined and start with "**KIDS**:"
 ; TEMP(1+i) might be defined
 N X,J
 S X=$P(L3,"**KIDS**:",2) F I=1:1:$L(X,U)-1 S KIDS($P(X,U,I))=FILE
 F I=1:1 S X=$G(TEMP(I)) Q:X=""  D
 .F J=1:1:$L(X,U)-1 S KIDS($P(X,U,J))=FILE
 Q
 ;
FIND(RET,PKG,VER) ;
 ; find all the builds with the same package and version
 ; returns:  RET(ien) = name ^ seq#
 ;           RET("S",seq#,ien)=""
 ;
 N X,Y,Z,OUT,VAL,VFDERR
 S VAL(1)=PKG,VAL(2)=VER,VAL=1
 S Y=$$FIND^VFDXPDA("OUT",21692,,".07;.05","OP",.VAL,"*","AD")
 F I=1:1:Y S X=$G(OUT(I,0)) Q:X=""  D
 .N SEQ,IEN,NM
 .S IEN=+X,NM=$P(X,U,2),SEQ=$P(X,U,3) Q:'IEN
 .Q:$P(X,U,4)'=PKG
 .S RET(IEN)=NM_U_SEQ,RET("S",SEQ,IEN)=""
 Q
 ;
FIND1(PKG,VER,SEQ) ;
 N IEN,VAL,VFDERR
 S VAL(1)=PKG,VAL(2)=VER,VAL(3)=SEQ,VAL=1
 S IEN=$$FIND1^VFDXPDA(21692,,"O","AD",,.VAL)
 Q $S(IEN>0:IEN,1:0)
 ;
GETREQ(RTN) ;
 N X,Y,Z,CNT,IEN,NAME,SEQ,STAT,TEMP
 S IEN="" F  S IEN=$O(BATCH(IEN)) Q:'IEN  D
 .N REQ S Y=$$GETS^VFDXPDA("REQ",21692,IEN_",","6*","I")
 .Q:'$D(REQ)!(Y'=1)
 .S X="REQ" F  S X=$Q(@X) Q:X=""  S Y=@X D
 ..Q:$D(BATCH(Y))!('$$GET1^VFDXPDA(21692,Y,.1,"I"))
 ..S NAME=$$GET1^VFDXPDA(21692,Y,.01),STAT=$$LAST^VFDXPD0(,NAME,3)
 ..Q:+$P(STAT,U,4)=3  S RTN(Y)=""
 Q
 ;
INSTCHK(NAME) ;
 ; check to see if any of the patches have been installed or loaded
 N LAST,IEN,STAT
 S LAST=$$LAST^VFDXPD0(,NAME,3),IEN=$G(BATCH("B",NAME))
 S STAT=$P($P(LAST,U,4),";") I STAT=3 S INST(IEN)="" Q
 ;D ADD(IEN,3) Q
 I STAT'="" S ERR=1 D
 .S ERR(IEN)=NAME_" has install status of "_$P($P(LAST,U,4),";",2)
 Q
 ;
PROCESS(ARR,PIECE) ;
 N X
 S X=0 F  S X=$O(ARR(X)) Q:'X  D ADD(X,PIECE) Q:EXCEP>MAX
 Q EXCEP>MAX
 ;
QACHK(IEN) ;
 N SUB Q:NAME'["PSN" 1
 S IEN=$P(IEN,",")
 S SUB=$$GET1^VFDXPDA(21692,IEN,.9)
 I NAME["PSN",SUB["PMI" Q 0
 Q 1
 ;
SEQEXT(LOW,RTN) ;
 N X,Y,I,AD,FLAG,IEN,PKG,SEQ,TARR,VER
 S X=$NA(LOW(0))
 F  S X=$Q(@X) Q:X=""  S PKG=$QS(X,1),VER=$QS(X,2),SEQ=@X D
 .N OUT S FLAG=0
 .Q:'SEQ  S IEN=$$FIND1(PKG,VER,SEQ)
 .Q:+$P($$LAST^VFDXPD0(,$$GET1^VFDXPDA(21692,IEN,.01),3),U,4)=3
 .D FIND(.OUT,PKG,VER)
 .S Y=SEQ F  S Y=$O(OUT("S",Y),-1) Q:Y=""  D  Q:FLAG
 ..S IEN="" F  S IEN=$O(OUT("S",Y,IEN)) Q:'IEN  D  Q:FLAG
 ...S FLAG=$$SEQEXT1(IEN_",")
 S X=$NA(TARR("")) F Y=1:1 S X=$Q(@X) Q:X=""  S RTN(Y)=@X
 Q
 ;
 ;
 ;
SEQEXT1(IEN) ;
 N LAST,NAME,OUT,STATUS,TEMP
 S OUT=$$GETS^VFDXPDA("OUT",21692,IEN,".01;.1","I")
 S STATUS=$G(OUT(21692,IEN,.1,"I")) Q:'STATUS!(STATUS=3) 0
 S NAME=$G(OUT(21692,IEN,.01,"I")) Q:NAME="" 0
 S LAST=$$LAST^VFDXPD0(,NAME,3)
 I +$P(LAST,U,4)'=3 S RTN(+IEN)="" Q 0
 Q 1
 ;
SEQINT(RTN) ; checks for missing SEQ #'s w/in a batch
 ; sets LOW for use in SEQEXT
 N I,X,CBATCH,FIRST,IEN,INFO,NAME,LAST,PKG,SEQ,STATUS,TARR,TEMP,VER
 ;D WR(6)
 M CBATCH=BATCH("C")
 S PKG="" F  S PKG=$O(CBATCH(PKG)) Q:PKG=""  D
 .S VER="" F  S VER=$O(CBATCH(PKG,VER)) Q:VER=""  D
 ..S FIRST=$O(CBATCH(PKG,VER,"")),LOW(PKG,VER)=FIRST
 ..S LAST=$O(CBATCH(PKG,VER,""),-1) Q:FIRST=LAST
 ..K TEMP F I=FIRST:1:LAST S:'$D(CBATCH(PKG,VER,I)) TEMP(I)=""
 ..S SEQ="" F  S SEQ=$O(TEMP(SEQ)) Q:SEQ=""  D SEQINT1(SEQ)
 Q
 ;
SEQINT1(SEQ) ;
 N INFO,IEN,SUB
 S IEN=$$FIND1(PKG,VER,SEQ) Q:'IEN
 S IEN=IEN_",",INFO=$$GETS^VFDXPDA("INFO",21692,IEN,".01;.1","I")
 Q:'INFO  S STATUS=INFO(21692,IEN,.1,"I") Q:'STATUS
 S NAME=INFO(21692,IEN,.01,"I")
 I STATUS'=3 S RTN(+IEN)=""
 Q
 ;
SET(FILE) ;
 S FILE=$P($$UP^VFDXPD0(FILE),".KID")
 S VFDKID(FILE)="" Q
 ;
SUMMARY(RPT) ;
 ;Inst  - Build has been installed previously.
 ;Reqd  - Build is required by a build in the batch, but is not in the 
 ;        batch itself.
 ;Miss  - There are gaps in sequence numbers for a given package and version
 ;        within the batch.  These are the installable builds that are missing.
 ;Prev  - These are installable builds that have not been installed, are not 
 ;        in the batch, and have a lower sequence number than builds that are
 ;        currently in the batch.
 ;KIDS  - There are builds that are listed in the KIDS files in the user 
 ;        supplied directory that are not listed in the batch.
 ;Batch - There are installable builds that are listed in the batch but are
 ;        not listed in the KIDS files in the user supplied directory.
 ;
 ;
 ;Scott
 ;
 ;**** STEVE ****
 ;Reqd - The batch consists of builds which may or may not require other builds.
 ;       This column indicates those required builds that have not been installed
 ;       and are not members of the batch.
 ;
 ;Miss - The builds in this batch were examined and the 
 ;
 ;
 ;Prev - For members of the batch, this will get the lowest equence number for a given package and version.  It will then determine the next lowest sequence numbered, installable build in that package and version
 ;
 ;Prev - Builds that are not in the batch, but have a lower sequence number
 ;       than those in the batch and have not been installed.
 ;Theo
 ;Prev - There are installable builds with lower sequence numbers not in the
 ;       batch that have not been installed.
 ;Theo
 ;Prev - There are builds with a lower sequence number than the builds within 
 ;       this batch that have not been installed.
 ;
 ;
 ;SOME SORT OF VISUAL CUE TO WHAT IS IN THE BATCH AND WHAT IS NOT
 ;***********REPORT MISSING SEQ # (INTERNAL) EVEN IF INSTALLED
 ;
 ;
 N X,Y,Z,I,J,HEADER,DIR
 I '$D(RPT),'EXCEP W "This batch has no exceptions." Q 0
 ;        "                              |             |    Not In Batch    |"
 S HEADER="Build                         | Seq# | Inst | Reqd | Miss | Prev | KIDS | Batch"
 W #,$$CJ^XLFSTR(PID(0),80),!!!,"Key:",!
 F I=1:1 S X=$P($T(SUMMARY+I),";",2,99) Q:X=""  W X,!
 S DIR(0)="E" S DIR=$$DIR^VFDXPDA(.DIR) I DIR<0 Q 0
 W !!,HEADER,!,$$REPEAT^XLFSTR("-",80)
 S X="RPT" F I=1:1 S X=$Q(@X) Q:X=""  S Y=@X D
 .S Z=$$LJ^XLFSTR($P(Y,U),30)_"|" F J=2:1:8 S $P(Z,"|",J)=$$CJ^XLFSTR($P(Y,U,J),6)
 .W Z,!
 .I I#15=0,$Q(@X)'="" D
 ..W $$REPEAT^XLFSTR("-",80),HEADER,!,$$REPEAT^XLFSTR("-",80)
 W !!,"Total Exceptions:   "_EXCEP,!!
 Q 1
 ;
UPDATE ; Update 21692.1 to show when/where load report was last ran
 ; .04 - Server Name
 ; .05 - Namespace
 ; .06 - Date/Time
 ; .07 - # of Exceptions
 ;
 N X,IENS,VFDERR,VFDFDA
 S IENS=PID_","
 I $T(SRVNAME^VFDVMOS)'="" D
 .S VFDFDA(21692.1,IENS,.04)=$$SRVNAME^VFDVMOS
 I $T(CUR^VFDVMOS)'="" D
 .S VFDFDA(21692.1,IENS,.05)=$$CUR^VFDVMOS
 S VFDFDA(21692.1,IENS,.06)=$$NOW^XLFDT
 S VFDFDA(21692.1,IENS,.07)=$S(EXCEP<MAX:EXCEP,1:EXCEP_"*")
 D FILE^DIE(,"VFDFDA","VFDERR")
 Q
 ;
WR(LINE,FILE) ;
 ;;There are no builds associated with this batch.  Please try again.
 ;;Processing was halted due to the excessive amount of exceptions.
 ;;*** Processing was halted due to a large amount of exceptions last time ***
 ;; is not a valid KIDS file
 N TEXT S TEXT=$P($T(WR+LINE),";;",2,99)
 I $G(FILE) S TEXT=FILE_TEXT
 W TEXT,!
 Q
